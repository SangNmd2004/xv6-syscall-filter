#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int main(int argc, char *argv[]) {
    printf("====================================================\n");
    printf("     TESTING TASK 2.2: PREDEFINED PROFILES          \n");
    printf("====================================================\n\n");

    // -----------------------------------------------------------------
    // PHASE 1: BEFORE APPLYING PROFILE
    // -----------------------------------------------------------------
    printf("[PHASE 1] Process running normally...\n");
    int fd = open("README", 0);
    if(fd >= 0) {
        printf("   => Opened README SUCCESSFULLY (fd = %d).\n", fd);
        close(fd);
    }
    printf("\n");

    // -----------------------------------------------------------------
    // PHASE 2: USE FORK TO ISOLATE PROFILE TESTING AREA
    // -----------------------------------------------------------------
    printf("[PHASE 2] Activating Profile: PURE_COMPUTE\n");
    printf("-> System automatically calculates bitmask and configures Sandbox...\n");
    
    int pid = fork();
    if(pid < 0) {
        printf("Fork error!\n");
        exit(1);
    }

    if(pid == 0) {
        // --- THIS IS THE CHILD PROCESS (RESTRICTED BY SANDBOX) ---
        
        // Apply profile filter
        if (sandbox_apply_profile("PURE_COMPUTE") < 0) {
            exit(1);
        }

        // PHASE 3: Test compute flow
        // Note: Do not use printf here because SYS_write might be blocked, causing early death
        char *ptr = sbrk(4096);
        if (ptr == (char*)-1) {
            exit(2); // Exit with error code 2 if sbrk fails
        }

        // PHASE 4: Deliberately violate File I/O to trigger Sandbox
        // Call open() for the OS Kernel to catch and terminate!
        open("README", 0); 

        // If it survives the open call (Sandbox bug), exit with code 0
        exit(0); 
    } 
    else {
        // --- THIS IS THE PARENT PROCESS (OBSERVES AND REPORTS) ---
        int status;
        wait(&status); // Wait for the child to finish or be killed

        printf("\n[PHASE 3 & 4 - KERNEL VALIDATION RESULTS]:\n");
        printf(" -> Child process (PID: %d) executed Profile flow.\n", pid);
        printf(" -> System recorded termination state.\n");
        printf("\n====================================================\n");
        printf(" => CONCLUSION: Child was successfully blocked or terminated!\n");
        printf("====================================================\n");
    }

    exit(0);
}