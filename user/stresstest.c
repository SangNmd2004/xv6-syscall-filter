#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h" // de lay cac macro SYS_

// MACRO tao mask cấm (chuẩn Blacklist của Dev 1)
#define BLOCK(n) (1L << (n))

void run_stress_test() {
    printf("[Stress Test] Dang khoi tao 10 tien trinh con...\n");
    int pids[10];
    
    for (int i = 0; i < 10; i++) {
        pids[i] = fork();
        if (pids[i] < 0) {
            printf("[Stress Test] Loi: Khong the fork!\n");
            exit(1);
        }
        
        if (pids[i] == 0) {
            // --- Tien trinh con ---
            // Bật khiên Sandbox nhẹ (ví dụ chặn lệnh sbrk)
            if (setfilter(BLOCK(SYS_sbrk)) < 0) {
                printf("[Child %d] Loi setfilter!\n", getpid());
                exit(1);
            }
            
            // Goi getfilter 10000 lan
            for (int j = 0; j < 10000; j++) {
                uint64 m = getfilter();
                // Kiem tra dam bao Sandbox k bi vo
                if (m != BLOCK(SYS_sbrk)) {
                    printf("[Child %d] Loi: Mask bi thay doi dot ngot!\n", getpid());
                    exit(1);
                }
            }
            // Thoat an toan
            exit(0);
        }
    }
    
    // --- Tien trinh cha ---
    int success = 1;
    for (int i = 0; i < 10; i++) {
        int status;
        wait(&status);
        if (status != 0) {
            success = 0;
            printf("[Stress Test] Tien trinh con da chet vi loi!\n");
        }
    }
    
    if (success) {
        printf("[PASS] Stress Test 10000 lan x 10 tien trinh hoat dong hoan hao.\n");
        printf("[PASS] Khong co Race Condition nao xay ra tren Kernel!\n");
    } else {
        printf("[FAIL] Stress Test That Bai.\n");
    }
}

int main(int argc, char *argv[]) {
    printf("--- BAT DAU STRESS TEST ---\n");
    run_stress_test();
    exit(0);
}
