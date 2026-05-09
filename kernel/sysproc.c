#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) {
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    if(addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_hello(void)
{
  printf("hello\n");
  return 0;
}

// set syscall filter
// Security Policy C – Additive-only ratchet:
//   A process may only SET bits (block more syscalls).
//   It can never CLEAR a bit that is already set (inherited or self-set).
//   This prevents a child from escaping a sandbox established by its parent.
uint64
sys_setfilter(void)
{
  uint64 mask;
  if(argaddr(0, &mask) < 0)
    return -1;
  
  struct proc *p = myproc();

  // Enforce the ratchet: new mask must be a superset of current mask
  if((mask & p->syscall_mask) != p->syscall_mask) {
    return -1;
  }

  p->syscall_mask = mask;
  return 0;
}

// get syscall filter
uint64
sys_getfilter(void)
{
  return myproc()->syscall_mask;  // return mask for current process
}

uint64
sys_setfilter_child(void)
{
  uint64 mask;
  struct proc *p = myproc();

  // Lấy tham số đầu tiên (mask) từ thanh ghi a0
  if(argaddr(0, &mask) < 0)
    return -1;

  // Enforce Policy C for child mask too:
  // Parent cannot spawn a child that is less restricted than itself.
  if((mask & p->syscall_mask) != p->syscall_mask) {
    return -1;
  }

  p->child_syscall_mask = mask;
  return 0;
}