#ifndef FILTER_H
#define FILTER_H

#include "kernel/syscall.h"

// Định nghĩa Macro để tạo Mask cho từng Syscall
// Logic Blacklist: Bit 1 tại vị trí SYS_num nghĩa là syscall đó bị CẤM
#define BLOCK(num) (1L << (num))

// Các mask tiện ích
#define FILTER_NONE    0L
#define FILTER_OPEN    BLOCK(SYS_open)
#define FILTER_READ    BLOCK(SYS_read)
#define FILTER_WRITE   BLOCK(SYS_write)
#define FILTER_EXIT    BLOCK(SYS_exit)
#define FILTER_UPTIME  BLOCK(SYS_uptime)
#define FILTER_SBRK    BLOCK(SYS_sbrk)
#define FILTER_SETFILTER  BLOCK(SYS_setfilter)
#define FILTER_GETFILTER  BLOCK(SYS_getfilter)

// Các hàm giao tiếp User-space
int filter_enable(long blacklist_mask);
int filter_add_rule(int sys_num);
int filter_is_blocked(int sys_num);

#endif