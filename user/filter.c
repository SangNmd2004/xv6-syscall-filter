#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int sandbox_set_mask(uint64 mask) {
    // Truyền thẳng mask xuống Kernel (Bit 1 = BỊ CHẶN)
    return setfilter(mask);
}

int sandbox_block_syscall(int sys_num) {
    uint64 current_mask = getfilter();
    return setfilter(current_mask | SANDBOX_BLOCK(sys_num));
}

int sandbox_is_blocked(int sys_num) {
    uint64 current_mask = getfilter();
    return (current_mask & SANDBOX_BLOCK(sys_num)) != 0;
}
