#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h" 

#define BLOCK(n) (1L << (n))

void run_scenario_test() {
    int pid = fork();
    if (pid < 0) {
        printf("[Scenario Test] Error: Cannot fork!\n");
        exit(1);
    }

    if (pid == 0) {
        // --- Child process ---
        printf("\n[Child] Enable Sandbox: Block open()...\n");
        
        if (setfilter(BLOCK(SYS_open)) < 0) {
            printf("[Child] setfilter error!\n");
            exit(1);
        }

        printf("[Child] Starting 'cat secret.txt' process...\n");
        // Call cat program. This cat command will automatically call open("secret.txt")
        char *argv[] = {"cat", "secret.txt", 0};
        
        // exec() will succeed because we haven't blocked exec
        exec("cat", argv);
        
        // If exec fails, it will execute this
        printf("[Child] Error: Cannot exec(cat)!\n");
        exit(1);
    } else {
        // --- Parent process ---
        int status;
        wait(&status);
        
        printf("\n[Parent] 'cat' has terminated.\n");
        
        // If cat's open is blocked, it prints "cat: cannot open secret.txt"
        // and exits gracefully (see user/cat.c, if open < 0, it exits with exit(1) usually)
        
        if (status == 1) { // cat exited with 1 meaning failure to open
            printf("[PASS] Scenario Test: 'cat' was safely blocked from reading file (Graceful Fail)!\n");
        } else {
            printf("[FAIL] Scenario Test: Sandbox failed, 'cat' read the file!\n");
        }
    }
}

int main(int argc, char *argv[]) {
    printf("--- START SCENARIO TEST ---\n");
    run_scenario_test();
    exit(0);
}
