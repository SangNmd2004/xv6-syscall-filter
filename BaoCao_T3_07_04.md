# Báo Cáo Phân Tích Thực Thi System Call (T3 07/04)

Báo cáo này giải thích quá trình thực thi từ User Space vào Kernel Space của một tiến trình khi gọi system call, thông qua 3 hàm cốt lõi: `uservec`, `usertrap()`, và `syscall()`.

---

## 1. kernel/trampoline.S -> Hàm `uservec`

Đây là đoạn Assembly đóng vai trò như "cổng chào" (entry-point) ngay khi phần cứng nhảy từ User sang Kernel. Nhiệm vụ chính của nó là sao chép lại toàn bộ trạng thái (context) của CPU lúc user đang chạy vào một cấu trúc dữ liệu (`trapframe`) để sau này có thể phục hồi lại.

```assembly
uservec:    
        # a0 của user đang chứa một tham số nào đó. Ta đổi giấu nó vào sscratch.
        # Lúc này sscratch giữ giá trị cũ của a0, còn a0 trống để ta dùng.
        csrw sscratch, a0

        # TRAPFRAME là địa chỉ ảo mà cả kernel và user đều map giống hệt nhau
        # Nó trỏ tới vùng nhớ p->trapframe của tiến trình hiện tại.
        li a0, TRAPFRAME
        
        # Lấy a0 (chính là con trỏ trapframe) làm gốc, tiến hành LƯU TOÀN BỘ 
        # các thanh ghi của chương trình user vào vùng nhớ này.
        sd ra, 40(a0)
        sd sp, 48(a0)
        ... (giản lược các lệnh sd khác) ...
        sd t6, 280(a0)

        # Lấy lại giá trị cũ của a0 từ sscratch để lưu nốt vào trapframe
        csrr t0, sscratch
        sd t0, 112(a0)

        # Nạp con trỏ stack của hạt lõi kernel (để kernel có bộ nhớ stack mà hoạt động)
        ld sp, 8(a0)

        # Trích xuất hartid (ID của CPU)
        ld tp, 32(a0)

        # Lấy địa chỉ hàm usertrap() trong môi trường kernel
        ld t0, 16(a0)

        # Nạp bảng trang (Page Table) của kernel để chuẩn bị truy cập được vùng nhớ kernel
        ld t1, 0(a0)
        csrw satp, t1   # Kể từ lệnh này, ta hoàn toàn nằm trong không gian của kernel

        # Xóa bộ đệm TLB chuyển đổi trang
        sfence.vma zero, zero

        # Nhảy tới hàm usertrap() để xử lý ngắt/syscall
        jalr t0
```

---

## 2. kernel/trap.c -> Hàm `usertrap()`

Sau khi Assembly xử lý xong phần bề nổi (lưu thanh ghi, chuyển page table), luồng chạy vào một hàm viết bằng C - `usertrap()`. Hàm này sẽ hỏi phần cứng: "Vừa có ngắt gì xảy ra vậy, và do ai gọi?".

```c
uint64 usertrap(void)
{
  ...
  struct proc *p = myproc(); // Lấy block điều khiển của tiến trình hiện tại
  
  // sepc (Supervisor Exception Program Counter) lưu địa chỉ của bộ đếm 
  // chương trình lúc bị ngắt (thường là địa chỉ của lệnh ecall).
  // Ta phải lưu lại nó vào trapframe trước khi nó bị các ngắt tiếp theo ghi đè.
  p->trapframe->epc = r_sepc();
  
  // RẼ NHÁNH XỬ LÝ DỰA VÀO NGUYÊN NHÂN NGẮT
  // r_scause() trả về thanh ghi chứa mã số biểu thị nguyên nhân
  if(r_scause() == 8){
    // 8 là mã của "Environment Call from U-mode", tức là một system call
    
    // Kiểm tra xem tiến trình có đang bị kill hay không
    if(killed(p)) kexit(-1);

    // KẾT QUẢ ĐẦU RA CẦN NHỚ:
    // Vì r_sepc() đang trỏ thẳng vào lệnh 'ecall', nếu sau khi xử lý xong
    // hệ thống cứ thế khôi phục về lại sepc thì nó sẽ vĩnh viễn lặp lại 'ecall'.
    // Do đó, ta phải TĂNG epc lên thêm 4 byte để bỏ qua độ dài của lệnh ecall.
    p->trapframe->epc += 4;

    // Bật lại ngắt vì ta đã an toàn trong kernel (bất đồng bộ)
    intr_on();

    // Tiếp tục chuyển tiếp xuống hàm chuyên viên để xử lý Syscall
    syscall();
  }
  ...
}
```

---

## 3. kernel/syscall.c -> Hàm `syscall()`

Khi mọi thủ tục đã xong, hàm này sẽ đảm đương việc tra cứu xem user muốn gọi quyền năng nào của hệ điều hành.

```c
void syscall(void)
{
  int num;
  struct proc *p = myproc();

  // Theo quy ước của RISC-V: Thanh ghi a7 sẽ chứa [mã số hiệu thẻ System Call]
  // (Ví dụ: SYS_write có mã là 16)
  num = p->trapframe->a7;
  
  // Kiểm tra mã hiệu hợp lệ để tránh lỗi
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    // Gọi hàm xử lý cốt lõi tùy vào số hiệu lấy từ a7 (như sys_write).
    // Giá trị trả về từ hàm đó sẽ được GHI ĐÈ ngược lại vào thanh ghi a0 trong trapframe.
    // Tại vì khi user program hoạt động lại, quy ước C sẽ lấy giá trị trả về ở a0.
    p->trapframe->a0 = syscalls[num]();
  } else {
    // Gọi tào lao thì trả về lỗi -1
    printf("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}
```

---

## TỔNG KẾT GHI CHÚ CHUYÊN SÂU

### `scause == 8` là gì?
- **`scause`** (Supervisor Cause Register) là một thanh ghi phần cứng của CPU RISC-V. Bất cứ khi nào có Trap (Ngắt, Lỗi, hoặc Syscall), CPU sẽ tự ghi vào đây một mã số chỉ ra lý do tại sao dòng chảy chương trình bị gián đoạn.
- **Giá trị `8`**: Định nghĩa chuẩn của kiến trúc RISC-V quy định số 8 mang ý nghĩa `"Environment call from U-mode"`. Nghĩa là ứng dụng ở chế độ User đã chủ động khởi chiếu một ngoại lệ phần mềm bằng từ khóa `ecall` (thông qua thư viện hệ thống) để xin chuyển mạch lên hỏi ý Supervisor (Kernel). Do vậy, khi `scause == 8`, hệ điều hành sẽ rẽ nhanh vào module Syscall thay vì các module khác như ngắt bộ đếm timer.

### `sepc` làm gì?
- **`sepc`** (Supervisor Exception Program Counter) lưu trữ địa chỉ vùng nhớ chứa câu lệnh hiện tại vừa gây ra Trap (chính là địa chỉ của cái lệnh `ecall`).
- **Nó dùng để làm gì?** Giúp Hệ điều hành có được "tọa độ trở về" (như lưu checkpoint game). Khi HĐH lo liệu xong công việc ở mức nhân quyền năng, lệnh `sret` (supervisor return) sẽ đưa luồng CPU quay xe về lại môi trường user bằng cách nhảy tới tọa độ ghi trong `sepc`. 
- **Lưu ý nhỏ trong Syscall:** Do `sepc` lúc đó đang trỏ đúng vào lệnh `ecall`, ta bắt buộc phải chạy `p->trapframe->epc += 4;` để chỉ thị cho CPU quay trở lại vị trí câu lệnh C kế tiếp (lệnh ngay sau `ecall`).

---
*(Báo cáo hoàn thành cho task T3 07/04 - Đọc hiểu cơ chế trap).*
