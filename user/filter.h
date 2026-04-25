#ifndef _FILTER_H_
#define _FILTER_H_

#include "kernel/syscall.h"

// Macro tạo mask bằng cách dịch bit 1 sang trái n lần
#define BLOCK(n) (1L << (n))

// ── Core process management ──────────────────────────────────────────────────
#define FILTER_FORK      BLOCK(SYS_fork)    // block fork()
#define FILTER_EXIT      BLOCK(SYS_exit)    // block exit()
#define FILTER_WAIT      BLOCK(SYS_wait)    // block wait()
#define FILTER_EXEC      BLOCK(SYS_exec)    // block exec()
#define FILTER_GETPID    BLOCK(SYS_getpid)  // block getpid()
#define FILTER_KILL      BLOCK(SYS_kill)    // block kill()
#define FILTER_PAUSE     BLOCK(SYS_pause)   // block pause()

// ── File / I/O ───────────────────────────────────────────────────────────────
#define FILTER_READ      BLOCK(SYS_read)    // block read()
#define FILTER_WRITE     BLOCK(SYS_write)   // block write()
#define FILTER_OPEN      BLOCK(SYS_open)    // block open()
#define FILTER_CLOSE     BLOCK(SYS_close)   // block close()
#define FILTER_PIPE      BLOCK(SYS_pipe)    // block pipe()
#define FILTER_DUP       BLOCK(SYS_dup)     // block dup()
#define FILTER_FSTAT     BLOCK(SYS_fstat)   // block fstat()

// ── Filesystem ───────────────────────────────────────────────────────────────
#define FILTER_MKNOD     BLOCK(SYS_mknod)   // block mknod()
#define FILTER_UNLINK    BLOCK(SYS_unlink)  // block unlink()
#define FILTER_LINK      BLOCK(SYS_link)    // block link()
#define FILTER_MKDIR     BLOCK(SYS_mkdir)   // block mkdir()
#define FILTER_CHDIR     BLOCK(SYS_chdir)   // block chdir()

// ── Memory ───────────────────────────────────────────────────────────────────
#define FILTER_SBRK      BLOCK(SYS_sbrk)    // block sbrk()

// ── Miscellaneous ────────────────────────────────────────────────────────────
#define FILTER_UPTIME    BLOCK(SYS_uptime)  // block uptime()
#define FILTER_HELLO     BLOCK(SYS_hello)   // block hello()

// ── Compound helpers ─────────────────────────────────────────────────────────
// Block ALL I/O-related syscalls at once
#define FILTER_ALL_IO    (FILTER_READ | FILTER_WRITE | FILTER_OPEN  | \
                          FILTER_CLOSE | FILTER_PIPE | FILTER_DUP   | \
                          FILTER_FSTAT)

// Block all filesystem mutation syscalls
#define FILTER_ALL_FS    (FILTER_MKNOD | FILTER_UNLINK | FILTER_LINK | \
                          FILTER_MKDIR | FILTER_CHDIR)

#endif // _FILTER_H_
