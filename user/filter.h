#include "kernel/syscall.h"

// Định nghĩa macro dịch bit tương ứng với số hiệu syscall
#define FILTER_FORK    (1ULL << SYS_fork)
#define FILTER_EXIT    (1ULL << SYS_exit)
#define FILTER_WAIT    (1ULL << SYS_wait)
#define FILTER_PIPE    (1ULL << SYS_pipe)
#define FILTER_READ    (1ULL << SYS_read)
#define FILTER_KILL    (1ULL << SYS_kill)
#define FILTER_EXEC    (1ULL << SYS_exec)
#define FILTER_FSTAT   (1ULL << SYS_fstat)
#define FILTER_CHDIR   (1ULL << SYS_chdir)
#define FILTER_DUP     (1ULL << SYS_dup)
#define FILTER_GETPID  (1ULL << SYS_getpid)
#define FILTER_SBRK    (1ULL << SYS_sbrk)
#define FILTER_SLEEP   (1ULL << SYS_sleep)
#define FILTER_UPTIME  (1ULL << SYS_uptime)
#define FILTER_OPEN    (1ULL << SYS_open)
#define FILTER_WRITE   (1ULL << SYS_write)
#define FILTER_MKNOD   (1ULL << SYS_mknod)
#define FILTER_UNLINK  (1ULL << SYS_unlink)
#define FILTER_LINK    (1ULL << SYS_link)
#define FILTER_MKDIR   (1ULL << SYS_mkdir)
#define FILTER_CLOSE   (1ULL << SYS_close)

// Thêm syscall mới của m vào đây nếu muốn lọc chính nó
#define FILTER_SETFILTER (1ULL << SYS_setfilter)
#define FILTER_GETFILTER (1ULL << SYS_getfilter)