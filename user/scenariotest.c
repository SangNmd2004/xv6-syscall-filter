#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h" 

#define BLOCK(n) (1L << (n))

void run_scenario_test() {
    int pid = fork();
    if (pid < 0) {
        printf("[Scenario Test] Loi: Khong the fork!\n");
        exit(1);
    }

    if (pid == 0) {
        // --- Tien trinh con ---
        printf("\n[Child] Bat Sandbox: Cấm hàm open()...\n");
        
        if (setfilter(BLOCK(SYS_open)) < 0) {
            printf("[Child] Loi setfilter!\n");
            exit(1);
        }

        printf("[Child] Khoi chay tien trinh 'cat README'...\n");
        // Gọi chương trình cat. Lệnh cat này sẽ tự động gọi open("README")
        char *argv[] = {"cat", "README", 0};
        
        // exec() sẽ thành công vì ta chưa cấm exec
        exec("cat", argv);
        
        // Nếu exec lỗi mới chạy xuống đây
        printf("[Child] Loi: Khong the exec(cat)!\n");
        exit(1);
    } else {
        // --- Tien trinh cha ---
        int status;
        wait(&status);
        
        printf("\n[Parent] 'cat' da ket thuc.\n");
        
        // Neu cat bi chặn open, nó sẽ in lỗi "cat: cannot open README"
        // và tự thoát gracefully (xem file user/cat.c, nếu open < 0, nó thoát với exit(0) hoặc gọi báo lỗi)
        // Trong xv6, cat.c nếu open < 0 sẽ print lỗi rồi exit(1).
        
        if (status == 1) { // cat exited with 1 meaning failure to open
            printf("[PASS] Scenario Test: 'cat' bi chan doc file an toan (Graceful Fail)!\n");
        } else {
            printf("[FAIL] Scenario Test: Sandbox that bai, 'cat' van doc duoc file!\n");
        }
    }
}

int main(int argc, char *argv[]) {
    printf("--- BAT DAU SCENARIO TEST ---\n");
    run_scenario_test();
    exit(0);
}
