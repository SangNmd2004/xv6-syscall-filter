#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int main(void) {
    // 1. Print message BEFORE enabling filter
    printf("--- INITIALIZING SANDBOX DEMO ---\n");
    printf("Step 1: Enabling filter (BLOCK write and open)...\n");

    // Assuming your logic is Blacklist (as Dev 1 requested)
    // Block WRITE and OPEN
    uint64 mask = SANDBOX_BLOCK(SYS_write) | SANDBOX_BLOCK(SYS_open); 

    if(setfilter(mask) < 0){
        // If this error shows up, setfilter failed
        exit(1);
    }

    // 2. Try calling blocked commands
    // Note: After this line, printf will NOT work anymore
    open("secret.txt", 0); 
    
    // 3. Finish
    // exit command must be allowed for the process to exit cleanly
    exit(0); 
}