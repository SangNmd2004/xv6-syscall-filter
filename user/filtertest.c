#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    printf("--- BAT DAU TEST ---\n"); // Dòng này là "phao cứu sinh"
    
    uint64 mask = getfilter();
    printf("DEBUG: Gia tri mask nhan duoc la: %d\n", (int)mask);
    
    exit(0);
}