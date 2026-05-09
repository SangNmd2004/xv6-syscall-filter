#ifndef _FILTER_H_
#define _FILTER_H_

#include "kernel/syscall.h"

/**
 * MACRO DEFINITIONS
 * Sử dụng cơ chế Blacklist: Đánh dấu bit 1 tại vị trí syscall muốn CHẶN.
 */
#define BLOCK(n) (1L << (n))

// ── Core Process Management (Quản lý tiến trình) ───────────────────────────
#define FILTER_FORK      BLOCK(SYS_fork)    // Chặn fork()
#define FILTER_EXIT      BLOCK(SYS_exit)    // Chặn exit()
#define FILTER_WAIT      BLOCK(SYS_wait)    // Chặn wait()
#define FILTER_PIPE      BLOCK(SYS_pipe)    // Chặn pipe()
#define FILTER_GETPID    BLOCK(SYS_getpid)  // Chặn getpid()
#define FILTER_KILL      BLOCK(SYS_kill)    // Chặn kill()
#define FILTER_EXEC      BLOCK(SYS_exec)    // Chặn exec()

// ── File & I/O Operations (Thao tác tệp tin và Nhập/Xuất) ──────────────────
#define FILTER_READ      BLOCK(SYS_read)    // Chặn read()
#define FILTER_WRITE     BLOCK(SYS_write)   // Chặn write()
#define FILTER_OPEN      BLOCK(SYS_open)    // Chặn open()
#define FILTER_CLOSE     BLOCK(SYS_close)   // Chặn close()
#define FILTER_DUP       BLOCK(SYS_dup)     // Chặn dup()
#define FILTER_FSTAT     BLOCK(SYS_fstat)   // Chặn fstat()

// ── Filesystem Mutation (Thay đổi hệ thống tệp tin) ────────────────────────
#define FILTER_MKNOD     BLOCK(SYS_mknod)   // Chặn mknod()
#define FILTER_UNLINK    BLOCK(SYS_unlink)  // Chặn unlink()
#define FILTER_LINK      BLOCK(SYS_link)    // Chặn link()
#define FILTER_MKDIR     BLOCK(SYS_mkdir)   // Chặn mkdir()
#define FILTER_CHDIR     BLOCK(SYS_chdir)   // Chặn chdir()

// ── Memory & System (Bộ nhớ và Hệ thống) ───────────────────────────────────
#define FILTER_SBRK      BLOCK(SYS_sbrk)    // Chặn sbrk()
#define FILTER_UPTIME    BLOCK(SYS_uptime)  // Chặn uptime()

// ── Custom & Meta Syscalls (Syscall tùy chỉnh) ──────────────────────────────
#define FILTER_HELLO     BLOCK(SYS_hello)
#define FILTER_SETFILTER BLOCK(SYS_setfilter)
#define FILTER_GETFILTER BLOCK(SYS_getfilter)

// ── Compound Presets (Các bộ lọc cấu hình sẵn) ──────────────────────────────
// Chặn toàn bộ các thao tác liên quan đến I/O
#define FILTER_ALL_IO    (FILTER_READ | FILTER_WRITE | FILTER_OPEN  | \
                          FILTER_CLOSE | FILTER_PIPE | FILTER_DUP   | \
                          FILTER_FSTAT)

// Chặn toàn bộ các thao tác thay đổi cấu trúc thư mục/tệp tin
#define FILTER_ALL_FS    (FILTER_MKNOD | FILTER_UNLINK | FILTER_LINK | \
                          FILTER_MKDIR | FILTER_CHDIR)

// Chặn các thao tác nguy hiểm có thể chiếm quyền điều khiển hệ thống
#define FILTER_DANGER    (FILTER_EXEC | FILTER_KILL | FILTER_MKNOD)


/**
 * USER-SPACE LIBRARY API
 * Các hàm hỗ trợ để tương tác với Sandbox một cách trực quan.
 */

// Kích hoạt bộ lọc dựa trên mask (Blacklist: bit 1 là chặn)
int filter_enable(long blacklist_mask);

// Chặn thêm một syscall cụ thể vào bộ lọc hiện tại
int filter_add_rule(int sys_num);

// Kiểm tra xem một syscall có đang bị chặn hay không (1: bị chặn, 0: được phép)
int filter_is_blocked(int sys_num);

// Xóa bỏ mọi bộ lọc, cho phép tất cả syscall
int filter_clear_all(void);

// Hiển thị trạng thái bảo mật hiện tại của tiến trình
void filter_status_report(void);

#endif // _FILTER_H_