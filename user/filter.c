#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int filter_apply(long blacklist_mask) {
    // Vì kernel của bạn đang dùng Whitelist (1 là cho phép), 
    // nhưng API này dùng Blacklist (1 là chặn), chúng ta cần đảo bit.
    return setfilter(~blacklist_mask);
}

int filter_block_syscall(int sys_num) {
    long current_mask = getfilter();
    // Tắt bit tương ứng với syscall đó trong whitelist
    return setfilter(current_mask & ~BLOCK(sys_num));
}

int filter_reset(void) {
    return setfilter(0xFFFFFFFFFFFFFFFFL); // Cho phép tất cả
}

int filter_is_blocked(int sys_num) {
    long current_mask = getfilter();
    return !(current_mask & BLOCK(sys_num));
}

void filter_debug_status(void) {
    long m = getfilter();
    printf("\n[Sandbox Monitor]\n");
    printf("Whitelist Mask: %ld\n", m);
    printf("Security Level: %s\n", (m == 0xFFFFFFFFFFFFFFFFL) ? "LOW (Permissive)" : "HIGH (Restricted)");
    
    if(filter_is_blocked(SYS_open)) printf(" - File access: LOCKED\n");
    if(filter_is_blocked(SYS_fork)) printf(" - Process creation: LOCKED\n");
    printf("------------------\n");
}