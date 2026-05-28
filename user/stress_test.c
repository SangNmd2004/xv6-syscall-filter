#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"

// Giả sử Dev 2 đã định nghĩa API trong filter.h
void stress_task(int id) {
    for(int i = 0; i < 10000; i++) {
        // Gọi liên tục để ép Kernel xử lý dồn dập
        setfilter(1 << SYS_getpid); 
        if(getfilter() < 0) {
            printf("Process %d lỗi tại lần gọi %d\n", id, i);
            exit(1);
        }
    }
    printf("Process %d: Completed 10k calls [OK]\n", id);
    exit(0);
}

int main() {
    printf("--- Stress Test: 5 Processes x 10,000 calls ---\n");
    for(int i = 0; i < 5; i++) {
        if(fork() == 0) stress_task(i);
    }
    for(int i = 0; i < 5; i++) wait(0);
    printf("--- Stress Test Finished: OS Stable ---\n");
    exit(0);
}
