#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  // Mặt nạ bitmask để chặn SYS_uptime (Thường là bit thứ 14 trong xv6)
  uint64 uptime_mask = (1ULL << 14); 

  printf("====================================================\n");
  printf("  KỊCH BẢN KIỂM THỬ TÍNH NĂNG STRICT MODE (SANDBOX) \n");
  printf("====================================================\n\n");

  // -----------------------------------------------------------------
  // KỊCH BẢN 1: TẮT STRICT MODE (CHẾ ĐỘ MẶC ĐỊNH - SOFT PENALTY)
  // -----------------------------------------------------------------
  printf("[KỊCH BẢN 1] Thử nghiệm với Strict Mode = O (Tắt)\n");
  setfilter(uptime_mask);
  setstrict(0); // Đảm bảo tắt strict mode
  printf("-> Đã chặn lệnh uptime nhưng CHƯA bật chế độ nghiêm ngặt.\n");

  printf("-> Tiến trình thử gọi lệnh uptime()...\n");
  int result = uptime();
  
  if (result == -1) {
    printf("[THÀNH CÔNG] Lệnh uptime() bị chặn và trả về mã lỗi -1 đúng như thiết kế. Tiến trình vẫn sống an toàn!\n\n");
  } else {
    printf("[THẤT BẠI] Lệnh uptime() không bị chặn (Trả về: %d)!\n\n", result);
  }

  // Gỡ bỏ bộ lọc cũ để chuẩn bị cho kịch bản 2
  setfilter(0);

  // -----------------------------------------------------------------
  // KỊCH BẢN 2: BẬT STRICT MODE (STRICT MODE - KILL ON VIOLATION)
  // -----------------------------------------------------------------
  printf("----------------------------------------------------\n");
  printf("[KỊCH BẢN 2] Thử nghiệm với Strict Mode = 1 (Bật)\n");
  
  // Chúng ta sẽ tạo một tiến trình con bằng fork để thử nghiệm
  // Nếu tiến trình con bị giết, tiến trình cha vẫn sống để in kết quả báo cáo
  int pid = fork();

  if (pid < 0) {
    printf("Lỗi: Không thể fork tiến trình con!\n");
    exit(1);
  }

  if (pid == 0) {
    // Luồng xử lý của Tiến trình Con nằm trong Sandbox
    setfilter(uptime_mask);
    setstrict(1); // KÍCH HOẠT CHẾ ĐỘ STRICT MODE!
    printf("[Con - PID: %d] Đã bật bộ lọc uptime và KÍCH HOẠT Strict Mode.\n", getpid());
    printf("[Con - PID: %d] Chuẩn bị gọi lệnh vi phạm uptime()...\n", getpid());
    
    uptime(); // Dòng này sẽ kích nổ bẫy hệ thống trong nhân để tiêu diệt tiến trình con!

    // Nếu logic code vùng Nhân chạy ĐÚNG, dòng chữ này SẼ KHÔNG BAO GIỜ ĐƯỢC IN RA!
    printf("[LỖI NGHIÊM TRỌNG] Tiến trình con vẫn sống sau khi vi phạm bộ lọc Strict Mode!\n");
    exit(0);
  } 
  else {
    // Luồng xử lý của Tiến trình Cha
    int status;
    // Chờ tiến trình con kết thúc và thu hồi trạng thái
    wait(&status);
    
    printf("\n[Cha] Tiến trình con (PID: %d) đã kết thúc giải phóng cấu hình.\n", pid);
    printf("[KẾT LUẬN BÁO CÁO]:\n");
    printf("  => Nếu màn hình in dòng thông báo hệ thống:\n");
    printf("     \"Sandbox: Process %d KILLED due to strict violation!\"\n", pid);
    printf("  => Thì tính năng Strict Mode (Kill on Violation) đã HOÀN THÀNH HOÀN HẢO!\n");
    printf("====================================================\n");
  }

  exit(0);
}