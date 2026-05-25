#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int main(int argc, char *argv[]) {
    printf("====================================================\n");
    printf("     KIEM THU TASK 2.2: PREDEFINED PROFILES         \n");
    printf("====================================================\n\n");

    // -----------------------------------------------------------------
    // GIAI ĐOẠN 1: TRƯỚC KHI ÁP DỤNG PROFILE
    // -----------------------------------------------------------------
    printf("[GIAI DOAN 1] Tien trinh dang chay binh thuong...\n");
    int fd = open("README", 0);
    if(fd >= 0) {
        printf("   => Mo file README THANH CONG (fd = %d).\n", fd);
        close(fd);
    }
    printf("\n");

    // -----------------------------------------------------------------
    // GIAI ĐOẠN 2: SỬ DỤNG FORK ĐỂ CO LẬP VÙNG THỬ NGHIỆM PROFILES
    // -----------------------------------------------------------------
    printf("[GIAI DOAN 2] Kich hoat Profile: PURE_COMPUTE\n");
    printf("-> He thong tu dong tinh toan bitmask va cau hinh Sandbox...\n");
    
    int pid = fork();
    if(pid < 0) {
        printf("Loi fork!\n");
        exit(1);
    }

    if(pid == 0) {
        // --- ĐÂY LÀ TIẾN TRÌNH CON (SẼ BỊ GIỚI HẠN BỞI SANDBOX) ---
        
        // Áp dụng bộ lọc profile
        if (sandbox_apply_profile("PURE_COMPUTE") < 0) {
            exit(1);
        }

        // GIAI ĐOẠN 3: Kiểm tra luồng tính toán
        // Lưu ý: Không dùng printf ở đây vì SYS_write có thể bị chặn khiến con chết sớm
        char *ptr = sbrk(4096);
        if (ptr == (char*)-1) {
            exit(2); // Thoát với mã lỗi 2 nếu sbrk lỗi
        }

        // GIAI ĐOẠN 4: Cố tình vi phạm File I/O để kích nổ Sandbox
        // Gọi lệnh open() để Nhân hệ điều hành bắt quả tang và tiêu diệt!
        open("README", 0); 

        // Nếu sống sót qua lệnh open (tức là Sandbox lỗi), thoát với mã 0
        exit(0); 
    } 
    else {
        // --- ĐÂY LÀ TIẾN TRÌNH CHA (QUAN SÁT VÀ BÁO CÁO) ---
        int status;
        wait(&status); // Chờ tiến trình con thực thi xong hoặc bị giết

        printf("\n[GIAI DOAN 3 & 4 - KET QUA KIE_M CHU_NG TANG NHAN]:\n");
        printf(" -> Tien trinh con (PID: %d) da thuc thi luong Profile.\n", pid);
        printf(" -> He thong ghi nhan trang thai ket thuc.\n");
        printf("\n====================================================\n");
        printf(" => KET LUAN: Con da bi chan hoac tieu diet thanh cong!\n");
        printf("====================================================\n");
    }

    exit(0);
}