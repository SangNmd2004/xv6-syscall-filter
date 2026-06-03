#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/filter.h"
#include "kernel/syscall.h"

// Mô phỏng hệ thống Master-Worker (Giống mô hình của NGINX hoặc Web Server)
// Master process có toàn quyền. Worker process xử lý dữ liệu không tin cậy sẽ bị nhốt vào Sandbox.

void handle_client_request(int client_id) {
    int pid = fork();

    if (pid < 0) {
        printf("[Master] Error: Cannot fork worker for client %d\n", client_id);
        return;
    }

    if (pid == 0) {
        // --- WORKER PROCESS ---
        printf("\n   [Worker %d] Started processing untrusted data...\n", client_id);
        
        // 1. Nhốt Worker vào Sandbox để giới hạn quyền hạn.
        // Chỉ cho phép xử lý toán học (CPU), CẤM TẠO TIẾN TRÌNH (fork), CẤM CHẠY LỆNH (exec), CẤM MỞ FILE (open)
        uint64 mask = SANDBOX_BLOCK(SYS_exec) | SANDBOX_BLOCK(SYS_fork) | SANDBOX_BLOCK(SYS_open);
        
        if (setfilter(mask) < 0) {
            printf("   [Worker %d] Error: Sandbox initialization failed!\n", client_id);
            exit(1);
        }

        // Bật Strict Mode (Tử hình ngay lập tức nếu Worker bị hack và cố gọi lệnh cấm)
        setstrict(1);
        printf("   [Worker %d] Sandbox LOCKED & Strict Mode ENABLED.\n", client_id);

        // 2. Simulate normal data processing
        printf("   [Worker %d] Doing harmless computation... (Valid)\n", client_id);
        for(volatile int i=0; i<10000000; i++); // Busy wait loop

        // 3. Mô phỏng: Kẻ tấn công lợi dụng lỗ hổng Buffer Overflow trong lúc Worker đang xử lý dữ liệu
        // Kẻ tấn công cố tình gọi exec("sh") để chiếm quyền điều khiển shell của máy chủ
        printf("   [Worker %d] [WARNING] Buffer overflow exploited by attacker!\n", client_id);
        printf("   [Worker %d] [WARNING] Attacker is attempting to spawn a root shell via exec(\"sh\")...\n", client_id);
        
        char *args[] = {"sh", 0};
        exec("sh", args); // Lệnh này sẽ kích nổ bẫy Sandbox và tiêu diệt Worker ngay lập tức!

        // Nếu Sandbox thất bại, Hacker đã có Shell
        printf("   [Worker %d] [CRITICAL] Sandbox failed! Attacker has ROOT SHELL!\n", client_id);
        exit(0);
    } else {
        // --- MASTER PROCESS ---
        int status;
        wait(&status);
        
        if (status == 0) {
            printf("[Master] Worker for client %d finished normally.\n", client_id);
        } else {
            // Worker bị Sandbox tiêu diệt (status != 0)
            printf("[Master] [ALERT] Worker for client %d was KILLED by Kernel (Sandbox Violation)!\n", client_id);
            printf("[Master] [ALERT] Threat neutralized. Master process is safe and continues to serve other clients.\n");
        }
        printf("----------------------------------------------------\n");
    }
}

int main(void) {
    printf("====================================================\n");
    printf("     REAL-WORLD SANDBOX APPLICATION: SECURE SERVER  \n");
    printf("====================================================\n");
    printf("[Master] Server started. Listening for connections...\n");
    printf("----------------------------------------------------\n");

    // Giả lập 2 Request gửi tới Server
    printf("[Master] Received Request 1 (Normal User)...\n");
    handle_client_request(1);

    printf("[Master] Received Request 2 (Malicious Hacker)...\n");
    handle_client_request(2);

    printf("[Master] Server shutting down safely.\n");
    exit(0);
}

//Tinh huống giả định: Server đang xử lý một yêu cầu xử lý file dữ liệu (ví dụ: nén file, dịch ngược code)
//Worker bị lọt vào tay kẻ tấn công do lỗ hổng Buffer Overflow.
//Kết quả: Hệ thống đã dùng Sandbox Kill Worker và tiếp tục xử lý Request khác

// Worker process (Master): có toàn quyền
// Worker process (child): xử lý dữ liệu không tin cậy sẽ bị nhốt vào Sandbox


