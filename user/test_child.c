#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/filter.h"
#include "kernel/fcntl.h"

void test_read(char *name) {
    int fd = open("README", O_RDONLY);
    if(fd < 0){
        printf("%s: Khong the mo file README\n", name);
        return;
    }
    
    char buf[10];
    if(read(fd, buf, sizeof(buf)) < 0){
        printf("%s: READ BI CHAN! (Thanh cong)\n", name);
    } else {
        printf("%s: READ BINH THUONG! (Chua bi chan)\n", name);
    }
    close(fd);
}

int main() {
    printf("--- BAT DAU TEST SETFILTER_CHILD ---\n");

    // 1. Cha thiet lap luat: "Cac con cua ta sau nay khong duoc phep READ"
    if(setfilter_child(FILTER_READ) < 0){
        printf("Loi: Khong the goi setfilter_child\n");
        exit(1);
    }
    printf("Cha: Da dat luat cam READ cho cac con.\n");

    // 2. Cha tu kiem tra xem minh co bi anh huong khong
    printf("Cha: Dang thu doc file...\n");
    test_read("Cha");

    // 3. Tao tien trinh con
    int pid = fork();

    if(pid < 0){
        printf("Loi fork\n");
        exit(1);
    }

    if(pid == 0){
        // Tien trinh con
        printf("\nCon: Dang thu doc file (dang le phai bi chan)...\n");
        test_read("Con");
        exit(0);
    } else {
        // Tien trinh cha doi con thuc hien xong
        wait(0);
        printf("\n--- KET THUC TEST ---\n");
    }

    exit(0);
}