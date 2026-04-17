#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  uint64 mask_test = 0x12345;
  uint64 result;

  printf("FILTERTEST: Bat dau kiem tra...\n");

  // 1. Kiem tra setfilter
  if(setfilter(mask_test) < 0){
    printf("FILTERTEST: Loi khi goi setfilter\n");
    exit(1);
  }
  printf("FILTERTEST: Da set mask = 0x12345\n");

  // 2. Kiem tra getfilter
  result = getfilter();
  
  if(result == mask_test){
    printf("FILTERTEST: Get dung gia tri! (Ket qua: 0x%x)\n", (int)result);
  } else {
    printf("FILTERTEST: SAI! Mong doi 0x12345, nhan duoc 0x%x\n", (int)result);
    exit(1);
  }

  // 3. Kiem tra voi gia tri khac
  setfilter(88);
  if(getfilter() == 88){
    printf("FILTERTEST: Test voi gia tri 88: SUCCESS\n");
  }

  printf("FILTERTEST: Hoan thanh tat ca kiem tra.\n");

  // Lenh nay cuc ky quan trong de dung process
  exit(0);
}