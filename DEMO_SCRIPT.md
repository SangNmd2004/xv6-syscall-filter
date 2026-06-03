# KỊCH BẢN DEMO HỆ THỐNG SANDBOX TRÊN XV6
**Người trình bày:** Nguyễn Minh Sang
**Mục đích:** Trình diễn toàn bộ các tính năng bảo mật của hệ thống Sandbox đã phát triển trên nhân xv6.

---

## PHẦN 1: CHUẨN BỊ VÀ KHỞI ĐỘNG
**1. Lời mở đầu:**
> "Chào thầy/cô và các bạn. Hôm nay em xin phép demo hệ thống Sandbox được tích hợp trực tiếp vào Kernel của hệ điều hành xv6. Hệ thống này giúp giới hạn quyền hạn của các tiến trình, ngăn chặn mã độc và tăng cường bảo mật."

**2. Khởi động hệ điều hành:**
*   Mở terminal, gõ lệnh biên dịch và chạy xv6:
    ```bash
    make qemu
    ```
*   *Nhấn mạnh:* Hệ thống xv6 đã được boot thành công với các thay đổi bên dưới Kernel.

---

## PHẦN 2: DEMO TÍNH NĂNG 1 - LỌC SYSCALL CƠ BẢN VÀ AUDIT
**Hành động:** Chạy chương trình `sandboxdemo`
```bash
$ sandboxdemo
```

**Thuyết minh trong khi chạy:**
1.  "Đầu tiên là tính năng cơ bản nhất: Syscall Filtering và Auditing."
2.  "Chương trình sẽ tự nhốt nó vào Sandbox. Em cấu hình cho phép gọi hàm `write()` (in ra màn hình) nhưng cấm gọi hàm `open()` (mở file)."
3.  "Như mọi người thấy trên màn hình, khi tiến trình gọi `write()`, nó in ra bình thường."
4.  "Nhưng khi nó cố gắng gọi `open()`, Kernel lập tức chặn lại và in ra dòng log đỏ/cảnh báo: `Sandbox Audit: Process 4 blocked Syscall 15!`. Đây là tính năng Audit giúp quản trị viên giám sát hệ thống."

---

## PHẦN 3: DEMO TÍNH NĂNG 2 - STRICT MODE (TỬ HÌNH TIẾN TRÌNH VI PHẠM)
**Hành động:** Chạy chương trình `sandbox_strict`
```bash
$ sandbox_strict
```

**Thuyết minh trong khi chạy:**
1.  "Tiếp theo, em xin demo 'Strict Mode' - Chế độ nghiêm ngặt."
2.  "Bình thường, nếu gọi syscall bị cấm, Kernel chỉ trả về mã lỗi -1 (tiến trình vẫn sống). Nhưng kẻ tấn công có thể lợi dụng điều đó để thử các lỗ hổng khác."
3.  "Ở Kịch bản 1 (Strict Mode OFF): Hàm `uptime()` bị chặn và trả về -1, tiến trình báo [SUCCESS] vì vẫn còn sống."
4.  "Ở Kịch bản 2 (Strict Mode ON): Khi tiến trình vi phạm, Kernel lập tức ra tay tiêu diệt. Dòng thông báo `Sandbox: Process X KILLED due to strict violation!` hiện ra. Kẻ tấn công bị chặn đứng hoàn toàn."

---

## PHẦN 4: DEMO TÍNH NĂNG 3 - ỨNG DỤNG THỰC TẾ (MASTER-WORKER)
**Hành động:** Chạy chương trình `realworld_app`
```bash
$ realworld_app
```

**Thuyết minh trong khi chạy:**
1.  "Để chứng minh tính thực tiễn, em đã viết một ứng dụng mô phỏng Web Server (như Nginx)."
2.  "Tiến trình Master đứng ngoài nhận request, sau đó tạo ra các Worker (tiến trình con) để xử lý dữ liệu. Master nhốt Worker vào Sandbox (cấm `fork`, `exec`, `open`) và bật Strict Mode."
3.  "Ở Request 1: Một kẻ tấn công khai thác lỗi tràn bộ đệm (Buffer Overflow) trên Worker và cố gắng mở shell bằng lệnh `exec("sh")`."
4.  "Lập tức Sandbox kích hoạt, tiêu diệt Worker 1. *Nhưng điểm ăn tiền ở đây là:* Tiến trình Master vẫn an toàn vô sự và tiếp tục phục vụ Request 2. Lỗi ở một Worker không làm sập cả hệ thống!"

---

## PHẦN 5: DEMO TÍNH NĂNG 4 - KIỂM THỬ SỨC CHỊU ĐẢNG (STRESS TEST)
**Hành động:** Chạy chương trình `stresstest`
```bash
$ stresstest
```

**Thuyết minh trong khi chạy:**
1.  "Cuối cùng, thêm tính năng vào Kernel rất dễ gây treo máy (Race Condition). Nên em có viết bài test độ ổn định."
2.  "Chương trình này tạo ra 10 tiến trình chạy song song, liên tục thiết lập và gọi syscall trong 10.000 vòng lặp."
3.  "Kết quả trả về `[PASS] No Race Conditions occurred in Kernel!`. Điều này khẳng định mã nguồn Kernel do em thiết kế chạy cực kỳ ổn định trên kiến trúc đa nhân (multi-core CPU)."

---

**Kết luận:**
> "Đó là toàn bộ luồng hoạt động của hệ thống Sandbox. Hệ thống đáp ứng đầy đủ tính cô lập, thực thi luật, giám sát và cực kỳ ổn định. Xin cảm ơn mọi người đã theo dõi."
