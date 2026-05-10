# Hướng Dẫn Coding & Chữa Lỗi (Dành cho Dev 3)

Chào Dev 3, 
Dựa trên yêu cầu của Milestone Tuần 5, các bài test cũ của bạn (full_test, k28_test) không đúng với định hướng của dự án. Kernel hiện tại đã chốt sử dụng **Cơ chế Blacklist** (chặn thì set bit 1) và **Policy C** (không bao giờ được phép gỡ lệnh cấm bằng `setfilter(0)`).

Để hoàn thành nhiệm vụ Tuần 5, bạn hãy tạo mới 2 bài test dưới đây và nộp lại nhé.

---

## 1. Bài Test Kịch Bản (Scenario Test)
**Yêu cầu:** Chặn hàm `open()`, sau đó gọi chương trình `cat`. Yêu cầu `cat` phải báo lỗi Graceful chứ không được làm sập cả hệ thống.

**Hành động:** Bạn hãy tạo file `user/scenariotest.c` và dán nguyên đoạn code sau vào:

```c
#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int main() {
    printf("--- SCENARIO TEST: BLOCKING 'cat' ---\n");

    int pid = fork();
    if (pid < 0) {
        printf("[FAIL] Fork error!\n");
        exit(1);
    }

    if (pid == 0) {
        // TIẾN TRÌNH CON: Bật Sandbox để CẤM hàm open()
        if (filter_enable(FILTER_OPEN) < 0) {
            printf("[FAIL] Cannot set filter\n");
            exit(1);
        }

        printf("[Child] Sandbox activated (open blocked). Trying to run 'cat README'...\n");
        printf("[Child] Expecting 'cat: cannot open README' error message:\n\n");

        // Gọi lệnh cat. Lệnh này sẽ lén lút gọi hàm open() ở dưới nền.
        // Vì open() đã bị Sandbox chặn, cat sẽ báo lỗi graceful.
        char *argv[] = {"cat", "README", 0};
        exec("cat", argv);
        
        // Dòng này sẽ không bao giờ chạy tới nếu exec thành công
        printf("[FAIL] Exec failed unexpectedly\n");
        exit(1);
    } else {
        // TIẾN TRÌNH CHA: Đứng chờ tiến trình con kết thúc
        int status;
        wait(&status);
        printf("\n[Parent] Child exited with status %d\n", status);
        printf("=> [PASS] Scenario Test Completed Successfully!\n");
    }

    exit(0);
}
```

---

## 2. Bài Stress Test (Kiểm tra chịu tải)
**Yêu cầu:** Gọi `setfilter/getfilter` 10.000 lần trên nhiều tiến trình chạy song song để xem Kernel có bị tràn hay sập không.

**Hành động:** Bạn hãy tạo file `user/stresstest.c` với nội dung sau:

```c
#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

#define NUM_PROCESSES 5
#define NUM_ITERATIONS 10000

int main() {
    printf("--- STRESS TEST: %d processes, %d iterations ---\n", NUM_PROCESSES, NUM_ITERATIONS);

    int pids[NUM_PROCESSES];

    // 1. Tạo ra nhiều tiến trình chạy song song
    for (int i = 0; i < NUM_PROCESSES; i++) {
        pids[i] = fork();
        
        if (pids[i] == 0) {
            // TIẾN TRÌNH CON: Bắt đầu Spam Kernel
            for (int j = 0; j < NUM_ITERATIONS; j++) {
                // Liên tục kiểm tra mask để tạo tải cho hệ thống
                filter_is_blocked(SYS_open);
            }
            // Thử cấm một lệnh trước khi tắt
            filter_enable(FILTER_WRITE);
            exit(0);
        }
    }

    // 2. Tiến trình cha thu gom các tiến trình con
    int success_count = 0;
    for (int i = 0; i < NUM_PROCESSES; i++) {
        int status;
        wait(&status);
        if (status == 0) {
            success_count++;
        }
    }

    // 3. Đánh giá kết quả
    if (success_count == NUM_PROCESSES) {
        printf("\n=> [PASS] Stress Test Completed. Kernel survived %d system calls!\n", NUM_PROCESSES * NUM_ITERATIONS);
    } else {
        printf("\n=> [FAIL] Some processes crashed during stress test!\n");
    }

    exit(0);
}
```

---

## 3. Cập nhật Makefile
Để hệ thống biên dịch 2 bài test này, bạn hãy vào file `Makefile`, tìm đến phần `UPROGS` và thêm 2 dòng sau vào cuối danh sách:

```makefile
	$U/_scenariotest\
	$U/_stresstest\
```

Bạn hãy xóa các file test bị lỗi cũ đi, dùng bộ code này và biên dịch chạy thử `make qemu`. Nếu kết quả in ra `[PASS]`, bạn hãy push lên nhánh `dev3/testing-infra` để team Review lại nhé. Cảm ơn bạn!
