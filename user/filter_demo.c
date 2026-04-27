#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int
main(void)
{
  // MASK: Chỉ cho phép SETFILTER, GETFILTER và EXIT. 
  // KHÔNG cho phép WRITE.
  uint64 mask = FILTER_SETFILTER | FILTER_GETFILTER | FILTER_EXIT;

  printf("TEST_ERRNO: Dang bat bo loc (cam WRITE)...\n");

  if(setfilter(mask) < 0){
    printf("TEST_ERRNO: Khong the thiet lap bo loc.\n");
    exit(1);
  }

  // Co gang goi write vao stdout (fd = 1)
  char *msg = "Dong nay se bi chan!\n";
  int n = write(1, msg, 21);

  // Vi write da bi chan, printf duoi day se KHONG HIEN THI tren man hinh 
  printf("Gia tri n nhan duoc: %d\n", n);
  // CACH KIEM TRA: Neu m thay n < 0, nghia la syscall tra ve loi (tuong tu errno)
  if(n < 0) {
    printf("XAC NHAN: Syscall write da bi chan gia (tra ve -1)!\n");
    // Neu muon thay dong nay, m phai tam mo WRITE trong kernel printf
    // Hoac kiem tra qua log cua Kernel (da lam o buoc truoc)
  }

  exit(0);
}