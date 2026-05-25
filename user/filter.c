#include "kernel/types.h"
#include "kernel/syscall.h" // Nhớ include file này để có các hằng số SYS_open, SYS_write...
#include "user/user.h"
#include "user/filter.h"

int sandbox_apply_profile(const char* profile) { //
    if (strcmp(profile, "PURE_COMPUTE") == 0) { //
        // Chặn các thao tác tệp tin (File operations): open, write, mknod, unlink, etc.
        uint64 mask = 0; //
        
        // Nhóm lệnh File I/O cần chặn để bảo vệ hệ thống:
        mask |= (1ULL << SYS_open);   // Khóa mở tệp
        mask |= (1ULL << SYS_write);  // Khóa ghi tệp / xuất dữ liệu ra màn hình
        mask |= (1ULL << SYS_read);   // Khóa đọc tệp
        mask |= (1ULL << SYS_mknod);  // Khóa tạo tệp thiết bị
        mask |= (1ULL << SYS_unlink); // Khóa xóa tệp
        mask |= (1ULL << SYS_link);   // Khóa tạo liên kết cứng tệp
        mask |= (1ULL << SYS_mkdir);  // Khóa tạo thư mục mới
        mask |= (1ULL << SYS_chdir);  // Khóa thay đổi thư mục làm việc hiện tại

        // Đẩy mặt nạ cấu hình tự động tính toán này lên Nhân hệ điều hành
        return setfilter(mask); //
    }
    
    // Xử lý trường hợp chuỗi profile truyền vào không hợp lệ
    return -1; //
}
int sandbox_block_syscall(int syscall_num) {
    // Gọi đến hàm hệ thống chặn đơn lẻ cũ của Duy (ví dụ bạn đặt tên là block_syscall chẳng hạn)
    // Nếu bạn chặn bằng mask thì:
    return setfilter(1ULL << syscall_num); 
}

int sandbox_set_audit(int enable) {
    // Gọi đến hàm hệ thống setaudit cũ của Duy
    return setaudit(enable); 
}