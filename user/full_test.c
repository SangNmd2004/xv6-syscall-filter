#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h" // Chứa macro SYS_write

// Giả sử SYS_write là 16. Nếu file header của ông khác, hãy thay vào đây.
#define FILTER_WRITE (1 << SYS_write)

void test_fork() {
    printf("Test #3: Testing Fork Inheritance...\n");
    // KHÔNG bật setfilter ở đây nữa!

    int pid = fork();
    if (pid < 0) {
        printf("[FAIL] Fork failed!\n");
        return;
    }
    
    if (pid == 0) {
        // --- TRONG PROCESS CON ---
        
        // 1. Chỉ bật bộ lọc ngay tại đây để test việc chặn
        setfilter(FILTER_WRITE); 

        // 2. Cố gắng write (hành động này sẽ bị chặn)
        int ret = write(1, "Child process attempt\n", 22);

        // 3. TẮT BỘ LỌC NGAY LẬP TỨC để có thể in kết quả
        setfilter(0); 

        // 4. Bây giờ mới in kết quả PASS/FAIL
        if (ret == -1) {
            printf("[PASS] Fork: Child inherited mask, write() blocked!\n");
        } else {
            printf("[FAIL] Fork: Child did NOT inherit mask!\n");
        }
        exit(0);
    } else {
        wait(0); // Cha đợi con xong
        printf("Debug: Cha da doi con xong.\n");
    }
}
void test_exec() {
    printf("\nTest #4: Testing Exec Persistence...\n");
    setfilter(FILTER_WRITE);
    
    // Thử exec "echo". 
    // Nếu filter bền bỉ, 'exec' (hoặc các syscall bên trong echo) sẽ bị chặn và trả về -1
    char *argv[] = {"echo", "This should not print", 0};
    int ret = exec("echo", argv);
    
    // Nếu exec trả về -1 tức là bị chặn
    if (ret == -1) {
        printf("[PASS] Exec: Filter persisted, exec/write blocked!\n");
    } else {
        printf("[FAIL] Exec: Filter did not persist!\n");
    }
}

int main(int argc, char *argv[]) {
    test_fork();
    test_exec();
    exit(0);
}