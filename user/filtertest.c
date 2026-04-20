#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    printf("--- BAT DAU TEST ---\n");

    // 1. Bật bộ lọc: Chặn syscall số 16 (write)
    printf("Dang set filter de chan syscall write...\n");
    setfilter(1 << 16); 

    // 2. Thực hiện write (Lúc này nó sẽ bị chặn, trả về -1)
    int ret = write(1, "Test\n", 5); 

    // 3. TẮT BỘ LỌC NGAY: Mở cửa cho printf làm việc
    setfilter(0); 

    // 4. In kết quả (Lúc này printf đã được thông quan)
    if (ret < 0) {
        printf("[PASS] Syscall write da bi chan thanh cong! (ret = %d)\n", ret);
    } else {
        printf("[FAIL] Syscall write KHONG bi chan (ret = %d)\n", ret);
    }
    
    exit(0);
}