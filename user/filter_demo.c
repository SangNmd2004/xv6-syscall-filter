#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int main(void) {
    // 1. In thông báo TRƯỚC khi bật filter
    printf("--- KHOI DONG DEMO SANDBOX ---\n");
    printf("Buoc 1: Dang bat bo loc (CAM write và open)...\n");

    // Giả sử logic của bạn là Blacklist (như Dev 1 yêu cầu)
    // Chặn WRITE và OPEN
    uint64 mask = SANDBOX_BLOCK(SYS_write) | SANDBOX_BLOCK(SYS_open); 

    if(setfilter(mask) < 0){
        // Nếu lỗi này hiện ra nghĩa là setfilter thất bại
        exit(1);
    }

    // 2. Thử gọi lệnh bị cấm
    // Lưu ý: Sau dòng này, printf sẽ KHÔNG hoạt động nữa
    open("secret.txt", 0); 
    
    // 3. Kết thúc
    // Lệnh exit phải được cho phép để tiến trình thoát sạch sẽ
    exit(0); 
}