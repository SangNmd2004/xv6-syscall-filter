#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/filter.h"
#include "kernel/fcntl.h"

void test_read(char *name) {
    int fd = open("README", O_RDONLY);
    if(fd < 0){
        printf("%s: Cannot open README file\n", name);
        return;
    }
    
    char buf[10];
    if(read(fd, buf, sizeof(buf)) < 0){
        printf("%s: READ BLOCKED! (Success)\n", name);
    } else {
        printf("%s: READ NORMAL! (Not blocked)\n", name);
    }
    close(fd);
}

int main() {
    printf("--- START SETFILTER_CHILD TEST ---\n");

    // 1. Parent sets the rule: "My future children cannot READ"
    if(setfilter_child(SANDBOX_BLOCK(SYS_read)) < 0){
        printf("Error: Cannot call setfilter_child\n");
        exit(1);
    }
    printf("Parent: Set rule to block READ for children.\n");

    // 2. Parent checks if it's affected
    printf("Parent: Trying to read file...\n");
    test_read("Parent");

    // 3. Create child process
    int pid = fork();

    if(pid < 0){
        printf("Fork error\n");
        exit(1);
    }

    if(pid == 0){
        // Child process
        printf("\nChild: Trying to read file (should be blocked)...\n");
        test_read("Child");
        exit(0);
    } else {
        // Parent process waits for child to finish
        wait(0);
        printf("\n--- END OF TEST ---\n");
    }

    exit(0);
}