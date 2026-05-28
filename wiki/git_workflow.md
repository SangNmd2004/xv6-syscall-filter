# Quy ước làm việc với Git (Git Workflow)

Để tránh xung đột (Conflict), nhóm thống nhất quy trình sau:

### 1. Phân chia nhánh (Branching)
* `main`: Nhánh chính, chỉ chứa code đã chạy ổn định.
* `dev1/kernel-internals`: Nhánh của Dev 1.
* `dev2/syscall-interface`: Nhánh của Dev 2.
* `dev3/testing-infra`: Nhánh Dev 3(Tester).

### 2. Quy ước Commit Message
Mọi commit phải ghi rõ vai trò và nội dung:
* Cấu trúc: `Dev [Số]: [Nội dung ngắn gọn]`
* Ví dụ: `Dev 3: Update syscall table wiki`

### 3. Quy trình cập nhật code
1. Code xong ở nhánh cá nhân.
2. Push lên GitHub.
3. Tạo **Pull Request (PR)** để nhóm trưởng review trước khi Merge vào `main`.