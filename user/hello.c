#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void)
{
  hello();
  printf("user: hello() returned\n");
  exit(0);
}
