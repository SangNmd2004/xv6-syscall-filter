#ifndef _FILTER_H_
#define _FILTER_H_

#include "kernel/syscall.h"

// Macro tạo mask bằng cách dịch bit 1 sang trái n lần
#define BLOCK(n) (1L << (n))

#endif