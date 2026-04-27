#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/filter.h"

static void result(const char *name, int ok) {
  if (ok)
    printf("[PASS] %s\n", name);
  else
    printf("[FAIL] %s\n", name);
}

// TC1: Default Mask - New process starts with syscall_mask == 0
void test1_initial_mask_zero(void) {
  int pid = fork();
  if (pid == 0) {
    uint64 mask = getfilter();
    exit(mask == 0 ? 1 : 0);
  } else {
    int status;
    wait(&status);
    result("TC1: Default mask == 0", status == 1);
  }
}

// TC2: Set and Get
void test2_set_get_mask(void) {
  int pid = fork();
  if (pid == 0) {
    uint64 want = FILTER_UPTIME;
    setfilter(want);
    uint64 got = getfilter();
    exit(got == want ? 1 : 0);
  } else {
    int status;
    wait(&status);
    result("TC2: Set and Get filter mask", status == 1);
  }
}

// TC3: Fork Inheritance
void test3_fork_inheritance(void) {
  int pid1 = fork();
  if (pid1 == 0) {
    uint64 parent_mask = FILTER_UPTIME;
    setfilter(parent_mask);

    int pid2 = fork();
    if (pid2 == 0) {
      uint64 child_mask = getfilter();
      exit(child_mask == parent_mask ? 1 : 0);
    } else {
      int status;
      wait(&status);
      exit(status);
    }
  } else {
    int status;
    wait(&status);
    result("TC3: Fork inheritance", status == 1);
  }
}

// TC4: Policy C: Weaken -> Deny
void test4_policy_weaken(void) {
  int pid = fork();
  if (pid == 0) {
    setfilter(FILTER_UPTIME); 
    int r = setfilter(0);    // Attempt to weaken
    exit(r == -1 ? 1 : 0);
  } else {
    int status;
    wait(&status);
    result("TC4: Policy C (Deny weaken)", status == 1);
  }
}

// TC5: Policy C: Tighten -> Allow
void test5_policy_tighten(void) {
  int pid = fork();
  if (pid == 0) {
    setfilter(FILTER_UPTIME);
    int r = setfilter(FILTER_UPTIME | FILTER_SBRK); // tighter mask
    exit(r == 0 ? 1 : 0);
  } else {
    int status;
    wait(&status);
    result("TC5: Policy C (Allow tighten)", status == 1);
  }
}

// TC6: Write Blocked
void test6_write_blocked(void) {
  int pid = fork();
  if (pid == 0) {
    setfilter(FILTER_WRITE);
    // Since write is blocked, printf is no longer available.
    int r = write(1, "should fail\n", 12);
    // write MUST return -1
    exit(r == -1 ? 1 : 0);
  } else {
    int status;
    wait(&status);
    result("TC6: write() is properly blocked", status == 1);
  }
}

int main(void) {
  printf("\n--- BO TEST FILTER (NGHIEM THU TUAN 3,4) ---\n");
  test1_initial_mask_zero();
  test2_set_get_mask();
  test3_fork_inheritance();
  test4_policy_weaken();
  test5_policy_tighten();
  test6_write_blocked();
  printf("------------------------------------------\n\n");
  exit(0);
}