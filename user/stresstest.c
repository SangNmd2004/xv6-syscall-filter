#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h" // de lay cac macro SYS_

// MACRO tao mask cấm (chuẩn Blacklist của Dev 1)
#define BLOCK(n) (1L << (n))

void run_stress_test() {
    printf("[Stress Test] Initializing 10 child processes...\n");
    int pids[10];
    
    for (int i = 0; i < 10; i++) {
        pids[i] = fork();
        if (pids[i] < 0) {
            printf("[Stress Test] Error: Cannot fork!\n");
            exit(1);
        }
        
        if (pids[i] == 0) {
            // --- Child process ---
            // Enable light Sandbox (e.g. block sbrk)
            if (setfilter(BLOCK(SYS_sbrk)) < 0) {
                printf("[Child %d] setfilter error!\n", getpid());
                exit(1);
            }
            
            // Call getfilter 10000 times
            for (int j = 0; j < 10000; j++) {
                uint64 m = getfilter();
                // Check to ensure Sandbox is not broken
                if (m != BLOCK(SYS_sbrk)) {
                    printf("[Child %d] Error: Mask changed unexpectedly!\n", getpid());
                    exit(1);
                }
            }
            // Exit safely
            exit(0);
        }
    }
    
    // --- Parent process ---
    int success = 1;
    for (int i = 0; i < 10; i++) {
        int status;
        wait(&status);
        if (status != 0) {
            success = 0;
            printf("[Stress Test] Child process died due to error!\n");
        }
    }
    
    if (success) {
        printf("[PASS] Stress Test 10000 iterations x 10 processes working perfectly.\n");
        printf("[PASS] No Race Conditions occurred in Kernel!\n");
    } else {
        printf("[FAIL] Stress Test Failed.\n");
    }
}

int main(int argc, char *argv[]) {
    printf("--- START STRESS TEST ---\n");
    run_stress_test();
    exit(0);
}
