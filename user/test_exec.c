#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int main() {
    printf("--- TEST EXEC: Kiem tra tinh duy tri cua filter ---\n");
    printf("1. Tien trinh hien tai dang co quyen in an (write).\n");

    // Thiet lap filter chan write
    if(setfilter(FILTER_WRITE) < 0){
        printf("Loi: Khong the setfilter\n");
        exit(1);
    }

    // Sau dong nay, moi lenh printf/write cua tien trinh nay se bi chan
    // Nen chung ta se khong in gi nua ma goi exec luon.

    char *args[] = { "ls", 0 };
    
    // Goi exec sang chuong trinh "ls"
    // "ls" chac chan can goi write() de in danh sach file ra man hinh
    exec("ls", args);

    // Neu exec thanh cong, code se khong bao gio chay den day.
    // Neu exec loi (do chinh exec cung bi chan?), no se in ra:
    exit(0);
}