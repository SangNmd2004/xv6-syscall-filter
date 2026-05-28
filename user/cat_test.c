#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"

int main() {
    printf("Test: Blocking open() then executing cat...\n");
    
    // Chặn quyền mở file
    setfilter(1 << SYS_open);
    
    int pid = fork();
    if(pid == 0) {
        // Thử chạy cat. Cat bắt buộc phải dùng syscall open() để đọc file.
        char *argv[] = {"cat", "README", 0};
        exec("cat", argv); 
        exit(0);
    } else {
        int status;
        wait(&status);
        printf("\n=> Kịch bản kết thúc. Nếu thấy 'cat: cannot open README' là PASS.\n");
        printf("=> Hệ thống không crash là PASS.\n");
    }
    exit(0);
}