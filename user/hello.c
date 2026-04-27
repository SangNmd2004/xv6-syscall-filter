#include "kernel/types.h"
#include "user/user.h"

int main() {
    write(1, "hello\n", 6);
    exit(0);
}
