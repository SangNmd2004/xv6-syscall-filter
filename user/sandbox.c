#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Định nghĩa ID các syscall dựa trên file syscall.h tiêu chuẩn của xv6
#define SYS_FORK          1
#define SYS_UPTIME       14
#define SYS_WRITE        16

// Hàm hỗ trợ in bitmask 64-bit dưới dạng Hex cho scannable trong báo cáo
void print_mask(uint64 mask) {
    printf("0x%x%x", (uint32)(mask >> 32), (uint32)mask);
}

int main(int argc, char *argv[]) {
    if(argc < 2) {
        printf("Usage: sandbox [default | test_child | test_audit]\n");
        exit(1);
    }

    // --- SCENARIO 1: CHECK DEFAULT MASK ---
    if(strcmp(argv[1], "default") == 0) {
        uint64 current = getfilter();
        printf("[Sandbox] Current process filter: ");
        print_mask(current);
        printf("\n[Sandbox] Default = 0 (No syscalls are blocked).\n");
        printf("[Sandbox] Try calling uptime()... Result tick: %d\n", uptime());
        exit(0);
    }

    // --- SCENARIO 2: FORCE FILTER ON CHILD VIA SETFILTER_CHILD ---
    if(strcmp(argv[1], "test_child") == 0) {
        // Enable bit 14 to BLOCK SYS_UPTIME system call
        uint64 block_uptime_mask = (1ULL << SYS_UPTIME);

        printf("[Parent] Setting child_syscall_mask to block uptime for child...\n");
        
        // Call the exact function from your user.h
        setfilter_child(block_uptime_mask); 

        int pid = fork();
        if(pid < 0) {
            printf("[Error] Fork failed!\n");
            exit(1);
        }

        if(pid == 0) {
            // Child process
            printf("[Child] Child process created.\n");
            printf("[Child] Current child filter: ");
            print_mask(getfilter());
            printf("\n[Child] Child starts calling uptime()...\n");
            
            uptime(); // Trigger Kernel blocking mechanism here
            
            printf("[Child] [FAILED] This line should not be printed if sandbox works!\n");
            exit(0);
        } else {
            // Parent process
            int status;
            wait(&status);
            printf("[Parent] Child process (PID: %d) has terminated.\n", pid);
        }
        exit(0);
    }

    // --- SCENARIO 3: TEST AUDIT FEATURE (SETAUDIT) ---
    if(strcmp(argv[1], "test_audit") == 0) {
        printf("[Parent] Enable security audit flag via setaudit(1)...\n");
        setaudit(1); 

        uint64 block_write_mask = (1ULL << SYS_WRITE);
        printf("[Parent] Revoke write permission (SYS_WRITE) of child process...\n");
        setfilter_child(block_write_mask);

        int pid = fork();
        if(pid == 0) {
            // Child intentionally writes data (calls sys_write -> ID 16) when forbidden
            printf("[Child] Intentionally violate security by calling printf/write...\n");
            exit(0);
        } else {
            int status;
            wait(&status);
            printf("[Parent] Audit test completed. Please check Kernel Console for logs.\n");
        }
        exit(0);
    }

    printf("[Error] Invalid parameter.\n");
    exit(1);
}