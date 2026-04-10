// user/filtertest.c — skeleton tuần 1
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h"
static int passed = 0, failed = 0;
void test(char *name, int condition) {
if (condition) {
printf(" [PASS] %s\n", name);
passed++;
} else {
printf(" [FAIL] %s\n", name);
failed++;
}
}
// Placeholder — tuần 2 sẽ implement
void tc01_placeholder(void) {
printf("TC-01: Framework sanity check\n");
test("1 + 1 == 2", 1 + 1 == 2);
test("getpid() > 0", getpid() > 0);
}
int main(void) {
printf("=== Syscall Filter Test Suite ===\n");
tc01_placeholder();
printf("\nResults: %d passed, %d failed\n", passed, failed);
exit(failed > 0 ? 1 : 0);
}