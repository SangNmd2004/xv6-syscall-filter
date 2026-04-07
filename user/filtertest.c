#include "kernel/types.h"
#include "user/user.h"

// Hàm này để in ra PASS nếu đúng, FAIL nếu sai
void test(char *name, int condition) {
    if (condition) {
        printf("TEST %s: PASS\n", name);
    } else {
        printf("TEST %s: FAIL\n", name);
    }
}

int main() {
    printf("--- KHOI CHAY HE THONG KIEM THU ---\n");

    // Đây là khung (skeleton) mẫu cho Dev 1 và Dev 2 điền vào sau
    test("kiem_tra_moi_truong", 1); 

    exit(0);
}