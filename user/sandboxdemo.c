#include "kernel/types.h"
#include "user/filter.h"
#include "user/user.h"


#define MASK_FORBIDDEN (FILTER_OPEN) // Cấm gọi hàm open()

void test_sandbox() {
    int pid = fork();
    if (pid < 0) exit(1);

    if (pid == 0) {
        printf("\n[Child] Bat dau thiet lap Sandbox...\n");

        // Áp dụng bộ lọc: CẤM open()
        if (filter_enable(MASK_FORBIDDEN) < 0) {
            printf("[Child] Loi: Khong the set filter!\n");
            exit(1);
        }

        printf("[Child] Thu ham write (Duoc phep)...\n");
        write(1, "[Child] Write van chay binh thuong!\n", 36);

        printf("[Child] Thu ham open (Bi cam)...\n");
        // Hàm open sẽ bị Kernel (Dev 1) chặn và trả về -1
        int fd = open("secret.txt", 0); 
        
        if (fd < 0) {
            printf("[Child] Success! open() da bi sandbox chan.\n");
            exit(0);
        } else {
            printf("[Child] FAIL! Sandbox hoat dong sai.\n");
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