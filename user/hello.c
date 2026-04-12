#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    // Gọi syscall hello() và nhận giá trị trả về
    int result = hello();
    
    // In kết quả nhận được từ kernel ra màn hình
    printf("User: hello() returned %d\n", result);
    
    exit(0);
}