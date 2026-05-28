#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    printf("--- STARTING TEST PROFILE ---\n");

    // Áp dụng profile tính toán thuần túy (Khóa toàn bộ IO, open, write...)
    int res = sandbox_apply_profile("PURE_COMPUTE");
    if (res < 0) {
        printf("[FAIL] Failed to apply profile PURE_COMPUTE\n");
        exit(1);
    }
    printf("Profile 'PURE_COMPUTE' applied successfully.\n");

    // Kịch bản 1: Thực hiện tính toán toán học thuần túy (Phải THÀNH CÔNG)
    int a = 10, b = 20;
    int c = a * b + 50;
    if (c == 250) {
        printf("[OK] Math computation executed successfully in sandbox.\n");
    }

    // Kịch bản 2: Cố tình gọi open("README", 0) mở file hệ thống (Phải THẤT BẠI)
    printf("Attempting forbidden open('README', 0)...\n");
    int fd = open("README", 0);
    
    if (fd == -1) {
        printf("[PASS] Test Profile: open() was successfully blocked and returned -1!\n");
        exit(0);
    } else {
        printf("[FAIL] Test Profile: open() succeeded with fd = %d! Sandbox escaped!\n", fd);
        close(fd);
        exit(1);
    }
}