#include "kernel/types.h"
#include "user/filter.h"
#include "user/user.h"




void test_sandbox() {
    int pid = fork();
    if (pid < 0) exit(1);

    if (pid == 0) {
        printf("\n[Child] Initializing Sandbox...\n");

        // Apply filter: BLOCK open()
        if (sandbox_block_syscall(SYS_open) < 0) {
            printf("[Child] Error: Cannot set filter!\n");
            exit(1);
        }
        
        // Enable Sandbox Audit logging
        if (sandbox_set_audit(1) < 0) {
            printf("[Child] Error: Cannot enable Audit!\n");
            exit(1);
        }

        printf("[Child] Testing write() (Allowed)...\n");
        write(1, "[Child] Write works normally!\n", 30);

        printf("[Child] Testing open() (Blocked)...\n");
        // open() will be blocked by Kernel and return -1
        int fd = open("secret.txt", 0); 
        
        if (fd < 0) {
            printf("[Child] Success! open() was blocked by sandbox.\n");
            exit(0);
        } else {
            printf("[Child] FAIL! Sandbox malfunctioned.\n");
            exit(1);
        }
    } else {
        wait(0);
    }
}

int main() {
    printf("--- SANDBOX DEMO ON XV6 ---\n");
    test_sandbox();
    exit(0);
}

//Kiến trúc dual-mask 
//Tiến trình Cha thiết lập một ranh giới bảo mật riêng biệt và bơm nó cho Tiến trình Con ngay tại thời điểm khởi tạo.
//Kết quả : Tiến trình Con bị tước quyền gọi hàm open(), nhưng Tiến trình Cha vẫn giữ nguyên 100% quyền lực. 
//Khi phát hiện vi phạm, Kernel chặn đứng tiến trình Con và trả về mã lỗi -1 (Graceful Fail) thay vì làm sập ứng dụng.
