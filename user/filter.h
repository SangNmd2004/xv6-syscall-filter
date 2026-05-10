#ifndef FILTER_H
#define FILTER_H

#include "kernel/syscall.h"

// Định nghĩa Macro để tạo Mask dễ dàng cho từng Syscall
// Logic Blacklist: Bit 1 tại vị trí sys_num nghĩa là syscall đó bị CẤM
#define SANDBOX_BLOCK(num) (1ULL << (num))

// Các hàm Sandbox API chuyên nghiệp
int sandbox_set_mask(uint64 mask);
int sandbox_block_syscall(int sys_num);
int sandbox_is_blocked(int sys_num);

#endif