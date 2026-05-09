# Danh sách Syscall sử dụng trong Hệ thống

Bảng dưới đây liệt kê các syscall được sử dụng để kiểm thử bộ lọc (Syscall Filter). Số hiệu (ID) được tra cứu từ file `kernel/syscall.h`.

| Tên Syscall | Số hiệu (ID) | Tham số | Ý nghĩa |
|:---|:---|:---|:---|
| **SYS_fork** | 1 | void | Tạo một tiến trình con mới. |
| **SYS_wait** | 3 | int* | Đợi tiến trình con kết thúc. |
| **SYS_read** | 5 | int, void*, int | Đọc dữ liệu từ file descriptor. |
| **SYS_getpid** | 11 | void | Lấy ID của tiến trình hiện tại. |
| **SYS_write** | 16 | int, void*, int | Ghi dữ liệu ra file descriptor (màn hình). |

*Ghi chú: Các syscall này sẽ được sử dụng để làm Baseline cho việc phát triển bộ lọc ở Tuần 2.*