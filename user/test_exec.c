#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int main() {
    printf("--- TEST EXEC: Check filter persistence ---\n");
    printf("1. Current process has permission to print (write).\n");

    // Set filter to block write
    if(setfilter(SANDBOX_BLOCK(SYS_write)) < 0){
        printf("Error: Cannot setfilter\n");
        exit(1);
    }

    // After this line, all printf/write of this process will be blocked
    // So we won't print anything else and just call exec.

    char *args[] = { "ls", 0 };
    
    // Exec the "ls" program
    // "ls" definitely needs to call write() to print the file list
    exec("ls", args);

    // If exec succeeds, code never reaches here.
    // If exec fails (because exec itself is blocked?), it would exit:
    exit(0);
}