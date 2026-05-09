#include "kernel/types.h"
#include "user/filter.h"
#include "user/user.h"

// Giả định các bitmask cho các syscall (phụ thuộc vào cách bạn định nghĩa trong kernel)
// Ví dụ: SYS_read là 5, SYS_write là 16, SYS_open là 15, v.v.
// Ở đây ta sử dụng một mask mô phỏng: 
// 1 << 5 (read), 1 << 16 (write), 1 << 2 (exit), 1 << 1 (fork)
#define MASK_SAFE ((1 << 2) | (1 << 16) | (1 << 5)) 

void test_sandbox() {
    int pid = fork();

    if (pid < 0) {
        printf("Sandbox: Fork failed\n");
        exit(1);
    }

    if (pid == 0) {
        // --- Tiến trình con (Target Sandbox) ---
        printf("\n[Child] Start setting up the Sandbox...\n");

        // Áp dụng bộ lọc: chỉ cho phép read, write và exit
        if (setfilter(MASK_SAFE) < 0) {
            printf("[Child] Error: Unable to set the filter!\n");
            exit(1);
        }

        printf("[Child] Sandbox is active. Testing write operation (Allowed)...\n");
        write(1, "[Child] Write operation succeeded!\n", 34);

        printf("[Child] Testing open operation (Forbidden)...\n");
        // Hệ thống sẽ gửi SIGKILL hoặc trả về lỗi tùy vào cách bạn xử lý trong kernel
        open("secret.txt", 0); 

        printf("[Child] Error: You should not see this line if the sandbox is working!\n");
        exit(0);
    } else {
        // --- Tiến trình cha ---
        int status;
        wait(&status);
        printf("\n[Parent] Target process has finished.\n");
        if (status != 0) {
            printf("[Parent] Identification: Child process was killed for violating the Sandbox.\n");
        } else {
            printf("[Parent] Child process completed safely.\n");
        }
    }
}

int main(int argc, char *argv[]) {
    printf("--- SANDBOX DEMO ON XV6 ---\n");
    test_sandbox();
    exit(0);
}