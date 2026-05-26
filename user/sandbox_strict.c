#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  // Bitmask to block SYS_uptime (Usually bit 14 in xv6)
  uint64 uptime_mask = (1ULL << 14); 

  printf("====================================================\n");
  printf("  STRICT MODE (SANDBOX) TEST SCENARIOS              \n");
  printf("====================================================\n\n");

  // -----------------------------------------------------------------
  // SCENARIO 1: STRICT MODE DISABLED (DEFAULT - SOFT PENALTY)
  // -----------------------------------------------------------------
  printf("[SCENARIO 1] Testing with Strict Mode = 0 (Disabled)\n");
  setfilter(uptime_mask);
  setstrict(0); // Ensure strict mode is disabled
  printf("-> Blocked uptime but DID NOT enable strict mode.\n");

  printf("-> Process attempting to call uptime()...\n");
  int result = uptime();
  
  if (result == -1) {
    printf("[SUCCESS] uptime() blocked and returned -1 as designed. Process is still alive!\n\n");
  } else {
    printf("[FAILED] uptime() was not blocked (Returned: %d)!\n\n", result);
  }

  // Remove filter for scenario 2
  setfilter(0);

  // -----------------------------------------------------------------
  // SCENARIO 2: STRICT MODE ENABLED (KILL ON VIOLATION)
  // -----------------------------------------------------------------
  printf("----------------------------------------------------\n");
  printf("[SCENARIO 2] Testing with Strict Mode = 1 (Enabled)\n");
  
  // We will fork a child process to test
  // If the child is killed, parent survives to report
  int pid = fork();

  if (pid < 0) {
    printf("Error: Cannot fork child process!\n");
    exit(1);
  }

  if (pid == 0) {
    // Child process flow inside Sandbox
    setfilter(uptime_mask);
    setstrict(1); // ENABLE STRICT MODE!
    printf("[Child - PID: %d] Blocked uptime and ENABLED Strict Mode.\n", getpid());
    printf("[Child - PID: %d] Preparing to call violating uptime()...\n", getpid());
    
    uptime(); // This triggers the trap to kill the process!

    // If Kernel logic works, this line WILL NEVER BE PRINTED!
    printf("[CRITICAL ERROR] Child process survived after Strict Mode violation!\n");
    exit(0);
  } 
  else {
    // Parent process flow
    int status;
    // Wait for child to exit and harvest state
    wait(&status);
    
    printf("\n[Parent] Child process (PID: %d) has terminated.\n", pid);
    printf("[CONCLUSION]:\n");
    printf("  => If the system printed:\n");
    printf("     \"Sandbox: Process %d KILLED due to strict violation!\"\n", pid);
    printf("  => Then Strict Mode (Kill on Violation) is WORKING PERFECTLY!\n");
    printf("====================================================\n");
  }

  exit(0);
}