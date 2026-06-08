#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "user/filter.h"

#define BLOCK(n) (1L << (n))

void print_result(char *test, int success) {
    if (success) {
        printf("[PASS] %s\n", test);
    } else {
        printf("[FAIL] %s\n", test);
    }
}

int main() {
    printf("\n--- HIPS DEEP INSPECTION TEST ---\n");

    // Block the syscalls to activate Deep Inspection
    uint64 mask = BLOCK(SYS_kill) | BLOCK(SYS_exec) | BLOCK(SYS_unlink) | BLOCK(SYS_sbrk);
    if (setfilter(mask) < 0) {
        printf("Failed to set filter\n");
        exit(1);
    }

    // 1. Test SYS_kill
    int r1 = kill(1); // Try to kill init
    print_result("SYS_kill: Block killing PID 1 (init)", r1 == -1);

    int child_pid = fork();
    if (child_pid == 0) {
        while(1); // Child spins
    } else {
        int r2 = kill(child_pid); // Try to kill normal child
        print_result("SYS_kill: Allow killing normal PID", r2 == 0);
        wait(0);
    }

    // 2. Test SYS_unlink
    int fd = open("dummy.txt", O_CREATE | O_WRONLY);
    if(fd >= 0) close(fd);
    
    int r3 = unlink("/bin/ls");
    print_result("SYS_unlink: Block deleting /bin/ls", r3 == -1);
    
    int r4 = unlink("dummy.txt");
    print_result("SYS_unlink: Allow deleting normal file", r4 == 0);

    // 3. Test SYS_sbrk
    char *p1 = sbrk(2 * 1024 * 1024); // Request 2MB at once
    print_result("SYS_sbrk: Block allocating > 1MB", (uint64)p1 == (uint64)-1);

    char *p2 = sbrk(1024); // Request 1KB
    print_result("SYS_sbrk: Allow allocating 1KB", (uint64)p2 != (uint64)-1);

    // 4. Test SYS_exec
    int exec_pid = fork();
    if (exec_pid == 0) {
        char *argv[] = {"sh", 0};
        exec("sh", argv); // Should be blocked
        exit(123); // Exit with 123 if blocked successfully
    } else {
        int status;
        wait(&status);
        print_result("SYS_exec: Block exec(\"sh\")", status == 123);
    }

    int exec_pid2 = fork();
    if (exec_pid2 == 0) {
        char *argv[] = {"echo", "(This echo confirms SYS_exec bypass works)", 0};
        exec("echo", argv); // Should succeed and print
        exit(123); // Should not reach here
    } else {
        int status;
        wait(&status);
        print_result("SYS_exec: Allow exec(\"echo\")", status != 123);
    }

    printf("---------------------------------\n\n");
    exit(0);
}
