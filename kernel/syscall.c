#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "syscall.h"
#include "defs.h"
#include "fcntl.h"

// Fetch the uint64 at addr from the current process.
int
fetchaddr(uint64 addr, uint64 *ip)
{
  struct proc *p = myproc();
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    return -1;
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    return -1;
  return 0;
}

// Fetch the nul-terminated string at addr from the current process.
// Returns length of string, not including nul, or -1 for error.
int
fetchstr(uint64 addr, char *buf, int max)
{
  struct proc *p = myproc();
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    return -1;
  return strlen(buf);
}

static uint64
argraw(int n)
{
  struct proc *p = myproc();
  switch (n) {
  case 0:
    return p->trapframe->a0;
  case 1:
    return p->trapframe->a1;
  case 2:
    return p->trapframe->a2;
  case 3:
    return p->trapframe->a3;
  case 4:
    return p->trapframe->a4;
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  *ip = argraw(n);
  return 0;
}

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
  *ip = argraw(n);
  return 0; // Hoặc logic kiểm tra lỗi của bạn
}
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
}

// Prototypes for the functions that handle system calls.
extern uint64 sys_fork(void);
extern uint64 sys_exit(void);
extern uint64 sys_wait(void);
extern uint64 sys_pipe(void);
extern uint64 sys_read(void);
extern uint64 sys_kill(void);
extern uint64 sys_exec(void);
extern uint64 sys_fstat(void);
extern uint64 sys_chdir(void);
extern uint64 sys_dup(void);
extern uint64 sys_getpid(void);
extern uint64 sys_sbrk(void);
extern uint64 sys_pause(void);
extern uint64 sys_uptime(void);
extern uint64 sys_open(void);
extern uint64 sys_write(void);
extern uint64 sys_mknod(void);
extern uint64 sys_unlink(void);
extern uint64 sys_link(void);
extern uint64 sys_mkdir(void);
extern uint64 sys_close(void);
extern uint64 sys_hello(void);
extern uint64 sys_setfilter(void); // set syscall filter
extern uint64 sys_getfilter(void); // get syscall filter
extern uint64 sys_setfilter_child(void);
extern uint64 sys_setaudit(void);
extern uint64 sys_setstrict(void);
// An array mapping syscall numbers from syscall.h
// to the function that handles the system call.
static uint64 (*syscalls[])(void) = {
[SYS_fork]    sys_fork,
[SYS_exit]    sys_exit,
[SYS_wait]    sys_wait,
[SYS_pipe]    sys_pipe,
[SYS_read]    sys_read,
[SYS_kill]    sys_kill,
[SYS_exec]    sys_exec,
[SYS_fstat]   sys_fstat,
[SYS_chdir]   sys_chdir,
[SYS_dup]     sys_dup,
[SYS_getpid]  sys_getpid,
[SYS_sbrk]    sys_sbrk,
[SYS_pause]   sys_pause,
[SYS_uptime]  sys_uptime,
[SYS_open]    sys_open,
[SYS_write]   sys_write,
[SYS_mknod]   sys_mknod,
[SYS_unlink]  sys_unlink,
[SYS_link]    sys_link,
[SYS_mkdir]   sys_mkdir,
[SYS_close]   sys_close,
[SYS_hello]   sys_hello,
[SYS_setfilter] sys_setfilter, // set syscall filter
[SYS_getfilter] sys_getfilter, // get syscall filter
[SYS_setfilter_child] sys_setfilter_child,
[SYS_setaudit] sys_setaudit,
[SYS_setstrict] sys_setstrict,
};


void
syscall(void)
{
  int num; // This is the original num variable of xv6, KEEP IT!
  struct proc *p = myproc();

  num = p->trapframe->a7; // Fetch syscall number from a7
  
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    
    // --- SANDBOX FILTERING LOGIC ---
    // Check if the bit corresponding to 'num' is set in the syscall_mask
    if(p->syscall_mask & ((uint64)1 << num)) {
      
      // 1. Argument Filtering for SYS_open (Read-Only safe paths)
      if (num == SYS_open) {
          int omode = p->trapframe->a1;
          char path[MAXPATH];
          if (fetchstr(p->trapframe->a0, path, MAXPATH) < 0) {
              p->trapframe->a0 = -1;
              return;
          }
          if (!(omode & O_WRONLY) && !(omode & O_RDWR) && strncmp(path, "secret", 6) != 0) {
              p->trapframe->a0 = syscalls[num]();
              return;
          }
      }
      // 2. Argument Filtering for SYS_kill (Protect PID 1 and 2)
      else if (num == SYS_kill) {
          int target_pid = p->trapframe->a0;
          if (target_pid > 2) {
              p->trapframe->a0 = syscalls[num]();
              return;
          }
      }
      // 3. Argument Filtering for SYS_exec (Whitelist/Blacklist)
      else if (num == SYS_exec) {
          char path[MAXPATH];
          if (fetchstr(p->trapframe->a0, path, MAXPATH) < 0) {
              p->trapframe->a0 = -1;
              return;
          }
          // Block "sh" and "rm", allow everything else
          if (strncmp(path, "sh", 3) != 0 && strncmp(path, "rm", 3) != 0) {
              p->trapframe->a0 = syscalls[num]();
              return;
          }
      }
      // 4. Argument Filtering for SYS_unlink (Protect System Files & Audit Log)
      else if (num == SYS_unlink) {
          char path[MAXPATH];
          if (fetchstr(p->trapframe->a0, path, MAXPATH) < 0) {
              p->trapframe->a0 = -1;
              return;
          }
          if (strncmp(path, "/bin/", 5) != 0 && strncmp(path, "README", 6) != 0 && strncmp(path, "audit.log", 9) != 0) {
              p->trapframe->a0 = syscalls[num]();
              return;
          }
      }
      // 5. Argument Filtering for SYS_sbrk (Resource Limit / DoS Protection)
      else if (num == SYS_sbrk) {
          int n = p->trapframe->a0;
          // Bypass if allocating <= 1MB at once, and total size <= 10MB
          if (n <= 1024 * 1024 && (p->sz + n) <= 10 * 1024 * 1024) {
              p->trapframe->a0 = syscalls[num]();
              return;
          }
      }

      // Handle Strict Mode (Kill on Violation)
      if (p->strict_mode) { 
        printf("Sandbox: Process %d KILLED due to strict violation!\n", p->pid);
        p->killed = 1; 
        if(p->audit_enabled) audit_log_write(p->pid, num);
        p->trapframe->a0 = -1;
        return;
      } 

      p->trapframe->a0 = -1; 
      
      if(p->audit_enabled) {
          printf("Sandbox Audit: Process %d (%s) blocked Syscall %d!\n", p->pid, p->name, num);
          audit_log_write(p->pid, num);
      }
      
      return; // Terminate early, do not execute syscalls[num]()
    }
    // ------------------------------

    // If not blocked, proceed with normal execution
    p->trapframe->a0 = syscalls[num]();
  } else {
    printf("%d %s: unknown sys call %d\n",
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}