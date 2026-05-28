#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Định nghĩa mã syscall nếu chưa có trong thư viện user
#define SYS_write 16 

int main(int argc, char *argv[]) {
    printf("--- STARTING TEST STRICT ---\n");
    
    int pid = fork();
    if (pid < 0) {
        printf("Fork failed!\n");
        exit(1);
    }

    if (pid == 0) {
        // Bên trong tiến trình CON
        // Kích hoạt chế độ nghiêm ngặt (Strict Mode)
        setstrict(1); 
        
        // Giả định hàm setfilter nhận mask cấm bitwise (chặn SYS_write)
        setfilter(1 << SYS_write); 
        
        // Cố tình gọi write để vi phạm Sandbox
        printf("Child: Attempting forbidden write()...\n");
        write(1, "Bypass Attempt\n", 15);
        
        // Nếu cơ chế Strict hoạt động đúng, nhân sẽ GIẾT chết tiến trình con ngay lập tức.
        // Dòng printf dưới đây KHÔNG bao giờ được phép chạy đến.
        printf("[FAIL] Strict mode did not terminate the child!\n");
        exit(0); 
    } else {
        // Bên trong tiến trình CHA
        int status;
        wait(&status);
        
        // Trong xv6, nếu tiến trình bị kill bởi nhân (vô điều kiện do vi phạm), 
        // giá trị status trả về từ wait() sẽ khác 0 (hoặc mang trạng thái lỗi).
        if (status != 0) {
            printf("[PASS] Test Strict: Child was abruptly terminated by kernel as expected!\n");
            exit(0);
        } else {
            printf("[FAIL] Test Strict: Child exited gracefully with status 0!\n");
            exit(1);
        }
    }
}