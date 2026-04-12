#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Định nghĩa số hiệu syscall (phải khớp với kernel/syscall.h)
#define N_FORK    1
#define N_WAIT    3
#define N_READ    5
#define N_WRITE   16
#define N_GETPID  11

// Hàm in đơn giản để tránh lỗi định dạng và lỗi bảo mật trên xv6
void test_line(char *name, int num, int res) {
    printf("Syscall: ");
    printf("%s", name);
    printf(" | Num: %d", num);
    printf(" | Res: %d", res);
    printf(" | Status: ");
    if (res >= 0) {
        printf("SUCCESS\n");
    } else {
        printf("FAILED\n");
    }
}

int main(int argc, char *argv[]) {
    int res;
    char buf[10];

    printf("--- START SYSCALL BASELINE TEST ---\n");

    // 1. Test getpid
    res = getpid();
    test_line("getpid", N_GETPID, res);

    // 2. Test write (ghi 0 byte vào stdout)
    res = write(1, "", 0);
    test_line("write", N_WRITE, res);

    // 3. Test read (đọc thử từ fd 99 không tồn tại để lấy kết quả FAILED)
    res = read(99, buf, 0);
    test_line("read", N_READ, res);

    // 4. Test fork & wait
    int pid = fork();
    if(pid < 0){
        test_line("fork", N_FORK, -1);
    } else if(pid == 0){
        // Tiến trình con: thoát ngay
        exit(0);
    } else {
        // Tiến trình cha: in kết quả fork và chờ con
        test_line("fork", N_FORK, pid);
        int status;
        int wait_res = wait(&status);
        test_line("wait", N_WAIT, wait_res);
    }

    printf("--- END SYSCALL BASELINE TEST ---\n");
    exit(0);
}