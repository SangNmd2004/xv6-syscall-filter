#include "kernel/types.h"
#include "user/user.h"

// Hàm kiểm tra tự động
void assert(int condition, char *test_name) {
    if (condition) {
        printf("[PASS] %s\n", test_name);
    } else {
        printf("[FAIL] %s\n", test_name);
    }
}

int main(int argc, char *argv[]) {
    printf("--- RUNNING KAN-28 AUTOMATED TESTS ---\n");

    // Test 1: Thử chặn syscall write (số 16)
    setfilter(1 << 16); 
    int ret = write(1, "x", 1); // Hành động này sẽ bị chặn
    
    // TẮT BỘ LỌC ĐỂ IN KẾT QUẢ
    setfilter(0); 
    
    // Kiểm tra kết quả (ret phải bằng -1 vì bị chặn)
    assert(ret == -1, "Test #1: Block write() syscall");

    // Test 2: Kiểm tra chức năng getfilter()
    uint64 test_mask = 0x1234; 
    setfilter(test_mask);
    uint64 current_mask = getfilter();
    
    assert(current_mask == test_mask, "Test #2: Check mask application");

    // Dọn dẹp
    setfilter(0);
    exit(0);
}