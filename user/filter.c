#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int filter_enable(long blacklist_mask) {
    // Truyền thẳng mask xuống Kernel (Bit 1 = BỊ CHẶN)
    return setfilter(blacklist_mask);
}

int filter_add_rule(int sys_num) {
    long current_mask = getfilter();
    return setfilter(current_mask | BLOCK(sys_num));
}

int filter_is_blocked(int sys_num) {
    long current_mask = getfilter();
    return (current_mask & BLOCK(sys_num)) != 0;
}
