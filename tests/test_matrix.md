# Test Matrix - Task 09/04 (Baseline)

| ID | Syscall | Num | Expected | Reality | Status |
|:---|:---|:---|:---|:---|:---|
| 1 | fork | 1 | Success | Success | PASS |
| 2 | wait | 3 | Success | Success | PASS |
| 3 | read | 5 | Success | Failed (No data) | PASS (Expected behavior) |
| 4 | getpid | 11 | Success | Success | PASS |
| 5 | write | 16 | Success | Success | PASS |