#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Định nghĩa ID các syscall dựa trên file syscall.h tiêu chuẩn của xv6
#define SYS_FORK          1
#define SYS_UPTIME       14
#define SYS_WRITE        16

// Hàm hỗ trợ in bitmask 64-bit dưới dạng Hex cho scannable trong báo cáo
void print_mask(uint64 mask) {
    printf("0x%x%x", (uint32)(mask >> 32), (uint32)mask);
}

int main(int argc, char *argv[]) {
    if(argc < 2) {
        printf("Huong dan su dung: sandbox [mac_dinh | test_con | test_audit]\n");
        exit(1);
    }

    // --- KỊCH BẢN 1: KIỂM TRA MẶT NẠ MẶC ĐỊNH ---
    if(strcmp(argv[1], "mac_dinh") == 0) {
        uint64 current = getfilter();
        printf("[Sandbox] Bo loc hien tai cua tien trinh: ");
        print_mask(current);
        printf("\n[Sandbox] Mac dinh = 0 (Khong co syscall nao bi chan).\n");
        printf("[Sandbox] Thu goi uptime()... Ket qua tick: %d\n", uptime());
        exit(0);
    }

    // --- KỊCH BẢN 2: ÉP BỘ LỌC LÊN CON QUA SETFILTER_CHILD ---
    if(strcmp(argv[1], "test_con") == 0) {
        // Bật bit thứ 14 để CHẶN hệ thống lệnh SYS_UPTIME
        uint64 block_uptime_mask = (1ULL << SYS_UPTIME);

        printf("[Parent] Dang thiet lap child_syscall_mask de chan uptime cho con...\n");
        
        // Gọi chính xác hàm từ file user.h của bạn
        setfilter_child(block_uptime_mask); 

        int pid = fork();
        if(pid < 0) {
            printf("[Error] Fork failed!\n");
            exit(1);
        }

        if(pid == 0) {
            // Tien trinh con (Child)
            printf("[Child] Tien trinh con da duoc sinh ra.\n");
            printf("[Child] Bo loc hien tai cua con: ");
            print_mask(getfilter());
            printf("\n[Child] Con bat dau goi uptime()...\n");
            
            uptime(); // Kích nổ cơ chế chặn của Kernel tại đây
            
            printf("[Child] [THAT BAI] Dong nay khong duoc phep in ra neu sandbox hoat dong!\n");
            exit(0);
        } else {
            // Tien trinh cha (Parent)
            int status;
            wait(&status);
            printf("[Parent] Tien trinh con (PID: %d) da ket thuc.\n", pid);
        }
        exit(0);
    }

    // --- KỊCH BẢN 3: KIỂM THỬ TÍNH NĂNG KIỂM TOÁN (SETAUDIT) ---
    if(strcmp(argv[1], "test_audit") == 0) {
        printf("[Parent] Kich hoat co kiem toan an ninh qua setaudit(1)...\n");
        setaudit(1); 

        uint64 block_write_mask = (1ULL << SYS_WRITE);
        printf("[Parent] Tuoc quyen ghi (SYS_WRITE) cua tien trinh con...\n");
        setfilter_child(block_write_mask);

        int pid = fork();
        if(pid == 0) {
            // Con cố tình ghi dữ liệu (gọi sys_write -> ID 16) khi đã bị cấm
            printf("[Child] Co tinh vi pham an ninh bang cach goi printf/write...\n");
            exit(0);
        } else {
            int status;
            wait(&status);
            printf("[Parent] Hoan tat kiem thu Audit. Hay kiem tra Console cua Kernel de xem log.\n");
        }
        exit(0);
    }

    printf("[Error] Tham so khong hop le.\n");
    exit(1);
}