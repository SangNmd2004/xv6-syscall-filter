
user/_scenariotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <run_scenario_test>:
#include "user/user.h"
#include "kernel/syscall.h" 

#define BLOCK(n) (1L << (n))

void run_scenario_test() {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
    int pid = fork();
   8:	370000ef          	jal	378 <fork>
    if (pid < 0) {
   c:	04054f63          	bltz	a0,6a <run_scenario_test+0x6a>
        printf("[Scenario Test] Loi: Khong the fork!\n");
        exit(1);
    }

    if (pid == 0) {
  10:	ed3d                	bnez	a0,8e <run_scenario_test+0x8e>
        // --- Tien trinh con ---
        printf("\n[Child] Bat Sandbox: Cấm hàm open()...\n");
  12:	00001517          	auipc	a0,0x1
  16:	9ee50513          	addi	a0,a0,-1554 # a00 <filter_is_blocked+0x5a>
  1a:	7a6000ef          	jal	7c0 <printf>
        
        if (setfilter(BLOCK(SYS_open)) < 0) {
  1e:	6521                	lui	a0,0x8
  20:	400000ef          	jal	420 <setfilter>
  24:	04054c63          	bltz	a0,7c <run_scenario_test+0x7c>
            printf("[Child] Loi setfilter!\n");
            exit(1);
        }

        printf("[Child] Khoi chay tien trinh 'cat README'...\n");
  28:	00001517          	auipc	a0,0x1
  2c:	a2050513          	addi	a0,a0,-1504 # a48 <filter_is_blocked+0xa2>
  30:	790000ef          	jal	7c0 <printf>
        // Gọi chương trình cat. Lệnh cat này sẽ tự động gọi open("README")
        char *argv[] = {"cat", "README", 0};
  34:	00001517          	auipc	a0,0x1
  38:	a4450513          	addi	a0,a0,-1468 # a78 <filter_is_blocked+0xd2>
  3c:	fca43c23          	sd	a0,-40(s0)
  40:	00001797          	auipc	a5,0x1
  44:	a4078793          	addi	a5,a5,-1472 # a80 <filter_is_blocked+0xda>
  48:	fef43023          	sd	a5,-32(s0)
  4c:	fe043423          	sd	zero,-24(s0)
        
        // exec() sẽ thành công vì ta chưa cấm exec
        exec("cat", argv);
  50:	fd840593          	addi	a1,s0,-40
  54:	364000ef          	jal	3b8 <exec>
        
        // Nếu exec lỗi mới chạy xuống đây
        printf("[Child] Loi: Khong the exec(cat)!\n");
  58:	00001517          	auipc	a0,0x1
  5c:	a3050513          	addi	a0,a0,-1488 # a88 <filter_is_blocked+0xe2>
  60:	760000ef          	jal	7c0 <printf>
        exit(1);
  64:	4505                	li	a0,1
  66:	31a000ef          	jal	380 <exit>
        printf("[Scenario Test] Loi: Khong the fork!\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	96650513          	addi	a0,a0,-1690 # 9d0 <filter_is_blocked+0x2a>
  72:	74e000ef          	jal	7c0 <printf>
        exit(1);
  76:	4505                	li	a0,1
  78:	308000ef          	jal	380 <exit>
            printf("[Child] Loi setfilter!\n");
  7c:	00001517          	auipc	a0,0x1
  80:	9b450513          	addi	a0,a0,-1612 # a30 <filter_is_blocked+0x8a>
  84:	73c000ef          	jal	7c0 <printf>
            exit(1);
  88:	4505                	li	a0,1
  8a:	2f6000ef          	jal	380 <exit>
    } else {
        // --- Tien trinh cha ---
        int status;
        wait(&status);
  8e:	fd840513          	addi	a0,s0,-40
  92:	2f6000ef          	jal	388 <wait>
        
        printf("\n[Parent] 'cat' da ket thuc.\n");
  96:	00001517          	auipc	a0,0x1
  9a:	a1a50513          	addi	a0,a0,-1510 # ab0 <filter_is_blocked+0x10a>
  9e:	722000ef          	jal	7c0 <printf>
        
        // Neu cat bi chặn open, nó sẽ in lỗi "cat: cannot open README"
        // và tự thoát gracefully (xem file user/cat.c, nếu open < 0, nó thoát với exit(0) hoặc gọi báo lỗi)
        // Trong xv6, cat.c nếu open < 0 sẽ print lỗi rồi exit(1).
        
        if (status == 1) { // cat exited with 1 meaning failure to open
  a2:	fd842703          	lw	a4,-40(s0)
  a6:	4785                	li	a5,1
  a8:	00f70c63          	beq	a4,a5,c0 <run_scenario_test+0xc0>
            printf("[PASS] Scenario Test: 'cat' bi chan doc file an toan (Graceful Fail)!\n");
        } else {
            printf("[FAIL] Scenario Test: Sandbox that bai, 'cat' van doc duoc file!\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	a6c50513          	addi	a0,a0,-1428 # b18 <filter_is_blocked+0x172>
  b4:	70c000ef          	jal	7c0 <printf>
        }
    }
}
  b8:	70a2                	ld	ra,40(sp)
  ba:	7402                	ld	s0,32(sp)
  bc:	6145                	addi	sp,sp,48
  be:	8082                	ret
            printf("[PASS] Scenario Test: 'cat' bi chan doc file an toan (Graceful Fail)!\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	a1050513          	addi	a0,a0,-1520 # ad0 <filter_is_blocked+0x12a>
  c8:	6f8000ef          	jal	7c0 <printf>
  cc:	b7f5                	j	b8 <run_scenario_test+0xb8>

00000000000000ce <main>:

int main(int argc, char *argv[]) {
  ce:	1141                	addi	sp,sp,-16
  d0:	e406                	sd	ra,8(sp)
  d2:	e022                	sd	s0,0(sp)
  d4:	0800                	addi	s0,sp,16
    printf("--- BAT DAU SCENARIO TEST ---\n");
  d6:	00001517          	auipc	a0,0x1
  da:	a8a50513          	addi	a0,a0,-1398 # b60 <filter_is_blocked+0x1ba>
  de:	6e2000ef          	jal	7c0 <printf>
    run_scenario_test();
  e2:	f1fff0ef          	jal	0 <run_scenario_test>
    exit(0);
  e6:	4501                	li	a0,0
  e8:	298000ef          	jal	380 <exit>

00000000000000ec <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e406                	sd	ra,8(sp)
  f0:	e022                	sd	s0,0(sp)
  f2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  f4:	fdbff0ef          	jal	ce <main>
  exit(r);
  f8:	288000ef          	jal	380 <exit>

00000000000000fc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 102:	87aa                	mv	a5,a0
 104:	0585                	addi	a1,a1,1
 106:	0785                	addi	a5,a5,1
 108:	fff5c703          	lbu	a4,-1(a1)
 10c:	fee78fa3          	sb	a4,-1(a5)
 110:	fb75                	bnez	a4,104 <strcpy+0x8>
    ;
  return os;
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret

0000000000000118 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 11e:	00054783          	lbu	a5,0(a0)
 122:	cb91                	beqz	a5,136 <strcmp+0x1e>
 124:	0005c703          	lbu	a4,0(a1)
 128:	00f71763          	bne	a4,a5,136 <strcmp+0x1e>
    p++, q++;
 12c:	0505                	addi	a0,a0,1
 12e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 130:	00054783          	lbu	a5,0(a0)
 134:	fbe5                	bnez	a5,124 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 136:	0005c503          	lbu	a0,0(a1)
}
 13a:	40a7853b          	subw	a0,a5,a0
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret

0000000000000144 <strlen>:

uint
strlen(const char *s)
{
 144:	1141                	addi	sp,sp,-16
 146:	e422                	sd	s0,8(sp)
 148:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	cf91                	beqz	a5,16a <strlen+0x26>
 150:	0505                	addi	a0,a0,1
 152:	87aa                	mv	a5,a0
 154:	86be                	mv	a3,a5
 156:	0785                	addi	a5,a5,1
 158:	fff7c703          	lbu	a4,-1(a5)
 15c:	ff65                	bnez	a4,154 <strlen+0x10>
 15e:	40a6853b          	subw	a0,a3,a0
 162:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret
  for(n = 0; s[n]; n++)
 16a:	4501                	li	a0,0
 16c:	bfe5                	j	164 <strlen+0x20>

000000000000016e <memset>:

void*
memset(void *dst, int c, uint n)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 174:	ca19                	beqz	a2,18a <memset+0x1c>
 176:	87aa                	mv	a5,a0
 178:	1602                	slli	a2,a2,0x20
 17a:	9201                	srli	a2,a2,0x20
 17c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 180:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 184:	0785                	addi	a5,a5,1
 186:	fee79de3          	bne	a5,a4,180 <memset+0x12>
  }
  return dst;
}
 18a:	6422                	ld	s0,8(sp)
 18c:	0141                	addi	sp,sp,16
 18e:	8082                	ret

0000000000000190 <strchr>:

char*
strchr(const char *s, char c)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  for(; *s; s++)
 196:	00054783          	lbu	a5,0(a0)
 19a:	cb99                	beqz	a5,1b0 <strchr+0x20>
    if(*s == c)
 19c:	00f58763          	beq	a1,a5,1aa <strchr+0x1a>
  for(; *s; s++)
 1a0:	0505                	addi	a0,a0,1
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	fbfd                	bnez	a5,19c <strchr+0xc>
      return (char*)s;
  return 0;
 1a8:	4501                	li	a0,0
}
 1aa:	6422                	ld	s0,8(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret
  return 0;
 1b0:	4501                	li	a0,0
 1b2:	bfe5                	j	1aa <strchr+0x1a>

00000000000001b4 <gets>:

char*
gets(char *buf, int max)
{
 1b4:	711d                	addi	sp,sp,-96
 1b6:	ec86                	sd	ra,88(sp)
 1b8:	e8a2                	sd	s0,80(sp)
 1ba:	e4a6                	sd	s1,72(sp)
 1bc:	e0ca                	sd	s2,64(sp)
 1be:	fc4e                	sd	s3,56(sp)
 1c0:	f852                	sd	s4,48(sp)
 1c2:	f456                	sd	s5,40(sp)
 1c4:	f05a                	sd	s6,32(sp)
 1c6:	ec5e                	sd	s7,24(sp)
 1c8:	1080                	addi	s0,sp,96
 1ca:	8baa                	mv	s7,a0
 1cc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ce:	892a                	mv	s2,a0
 1d0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d2:	4aa9                	li	s5,10
 1d4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d6:	89a6                	mv	s3,s1
 1d8:	2485                	addiw	s1,s1,1
 1da:	0344d663          	bge	s1,s4,206 <gets+0x52>
    cc = read(0, &c, 1);
 1de:	4605                	li	a2,1
 1e0:	faf40593          	addi	a1,s0,-81
 1e4:	4501                	li	a0,0
 1e6:	1b2000ef          	jal	398 <read>
    if(cc < 1)
 1ea:	00a05e63          	blez	a0,206 <gets+0x52>
    buf[i++] = c;
 1ee:	faf44783          	lbu	a5,-81(s0)
 1f2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f6:	01578763          	beq	a5,s5,204 <gets+0x50>
 1fa:	0905                	addi	s2,s2,1
 1fc:	fd679de3          	bne	a5,s6,1d6 <gets+0x22>
    buf[i++] = c;
 200:	89a6                	mv	s3,s1
 202:	a011                	j	206 <gets+0x52>
 204:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 206:	99de                	add	s3,s3,s7
 208:	00098023          	sb	zero,0(s3)
  return buf;
}
 20c:	855e                	mv	a0,s7
 20e:	60e6                	ld	ra,88(sp)
 210:	6446                	ld	s0,80(sp)
 212:	64a6                	ld	s1,72(sp)
 214:	6906                	ld	s2,64(sp)
 216:	79e2                	ld	s3,56(sp)
 218:	7a42                	ld	s4,48(sp)
 21a:	7aa2                	ld	s5,40(sp)
 21c:	7b02                	ld	s6,32(sp)
 21e:	6be2                	ld	s7,24(sp)
 220:	6125                	addi	sp,sp,96
 222:	8082                	ret

0000000000000224 <stat>:

int
stat(const char *n, struct stat *st)
{
 224:	1101                	addi	sp,sp,-32
 226:	ec06                	sd	ra,24(sp)
 228:	e822                	sd	s0,16(sp)
 22a:	e04a                	sd	s2,0(sp)
 22c:	1000                	addi	s0,sp,32
 22e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 230:	4581                	li	a1,0
 232:	18e000ef          	jal	3c0 <open>
  if(fd < 0)
 236:	02054263          	bltz	a0,25a <stat+0x36>
 23a:	e426                	sd	s1,8(sp)
 23c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 23e:	85ca                	mv	a1,s2
 240:	198000ef          	jal	3d8 <fstat>
 244:	892a                	mv	s2,a0
  close(fd);
 246:	8526                	mv	a0,s1
 248:	160000ef          	jal	3a8 <close>
  return r;
 24c:	64a2                	ld	s1,8(sp)
}
 24e:	854a                	mv	a0,s2
 250:	60e2                	ld	ra,24(sp)
 252:	6442                	ld	s0,16(sp)
 254:	6902                	ld	s2,0(sp)
 256:	6105                	addi	sp,sp,32
 258:	8082                	ret
    return -1;
 25a:	597d                	li	s2,-1
 25c:	bfcd                	j	24e <stat+0x2a>

000000000000025e <atoi>:

int
atoi(const char *s)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 264:	00054683          	lbu	a3,0(a0)
 268:	fd06879b          	addiw	a5,a3,-48
 26c:	0ff7f793          	zext.b	a5,a5
 270:	4625                	li	a2,9
 272:	02f66863          	bltu	a2,a5,2a2 <atoi+0x44>
 276:	872a                	mv	a4,a0
  n = 0;
 278:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 27a:	0705                	addi	a4,a4,1
 27c:	0025179b          	slliw	a5,a0,0x2
 280:	9fa9                	addw	a5,a5,a0
 282:	0017979b          	slliw	a5,a5,0x1
 286:	9fb5                	addw	a5,a5,a3
 288:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 28c:	00074683          	lbu	a3,0(a4)
 290:	fd06879b          	addiw	a5,a3,-48
 294:	0ff7f793          	zext.b	a5,a5
 298:	fef671e3          	bgeu	a2,a5,27a <atoi+0x1c>
  return n;
}
 29c:	6422                	ld	s0,8(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret
  n = 0;
 2a2:	4501                	li	a0,0
 2a4:	bfe5                	j	29c <atoi+0x3e>

00000000000002a6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e422                	sd	s0,8(sp)
 2aa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2ac:	02b57463          	bgeu	a0,a1,2d4 <memmove+0x2e>
    while(n-- > 0)
 2b0:	00c05f63          	blez	a2,2ce <memmove+0x28>
 2b4:	1602                	slli	a2,a2,0x20
 2b6:	9201                	srli	a2,a2,0x20
 2b8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2bc:	872a                	mv	a4,a0
      *dst++ = *src++;
 2be:	0585                	addi	a1,a1,1
 2c0:	0705                	addi	a4,a4,1
 2c2:	fff5c683          	lbu	a3,-1(a1)
 2c6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ca:	fef71ae3          	bne	a4,a5,2be <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ce:	6422                	ld	s0,8(sp)
 2d0:	0141                	addi	sp,sp,16
 2d2:	8082                	ret
    dst += n;
 2d4:	00c50733          	add	a4,a0,a2
    src += n;
 2d8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2da:	fec05ae3          	blez	a2,2ce <memmove+0x28>
 2de:	fff6079b          	addiw	a5,a2,-1
 2e2:	1782                	slli	a5,a5,0x20
 2e4:	9381                	srli	a5,a5,0x20
 2e6:	fff7c793          	not	a5,a5
 2ea:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ec:	15fd                	addi	a1,a1,-1
 2ee:	177d                	addi	a4,a4,-1
 2f0:	0005c683          	lbu	a3,0(a1)
 2f4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f8:	fee79ae3          	bne	a5,a4,2ec <memmove+0x46>
 2fc:	bfc9                	j	2ce <memmove+0x28>

00000000000002fe <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e422                	sd	s0,8(sp)
 302:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 304:	ca05                	beqz	a2,334 <memcmp+0x36>
 306:	fff6069b          	addiw	a3,a2,-1
 30a:	1682                	slli	a3,a3,0x20
 30c:	9281                	srli	a3,a3,0x20
 30e:	0685                	addi	a3,a3,1
 310:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 312:	00054783          	lbu	a5,0(a0)
 316:	0005c703          	lbu	a4,0(a1)
 31a:	00e79863          	bne	a5,a4,32a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 31e:	0505                	addi	a0,a0,1
    p2++;
 320:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 322:	fed518e3          	bne	a0,a3,312 <memcmp+0x14>
  }
  return 0;
 326:	4501                	li	a0,0
 328:	a019                	j	32e <memcmp+0x30>
      return *p1 - *p2;
 32a:	40e7853b          	subw	a0,a5,a4
}
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret
  return 0;
 334:	4501                	li	a0,0
 336:	bfe5                	j	32e <memcmp+0x30>

0000000000000338 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e406                	sd	ra,8(sp)
 33c:	e022                	sd	s0,0(sp)
 33e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 340:	f67ff0ef          	jal	2a6 <memmove>
}
 344:	60a2                	ld	ra,8(sp)
 346:	6402                	ld	s0,0(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret

000000000000034c <sbrk>:

char *
sbrk(int n) {
 34c:	1141                	addi	sp,sp,-16
 34e:	e406                	sd	ra,8(sp)
 350:	e022                	sd	s0,0(sp)
 352:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 354:	4585                	li	a1,1
 356:	0b2000ef          	jal	408 <sys_sbrk>
}
 35a:	60a2                	ld	ra,8(sp)
 35c:	6402                	ld	s0,0(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret

0000000000000362 <sbrklazy>:

char *
sbrklazy(int n) {
 362:	1141                	addi	sp,sp,-16
 364:	e406                	sd	ra,8(sp)
 366:	e022                	sd	s0,0(sp)
 368:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 36a:	4589                	li	a1,2
 36c:	09c000ef          	jal	408 <sys_sbrk>
}
 370:	60a2                	ld	ra,8(sp)
 372:	6402                	ld	s0,0(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret

0000000000000378 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 378:	4885                	li	a7,1
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <exit>:
.global exit
exit:
 li a7, SYS_exit
 380:	4889                	li	a7,2
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <wait>:
.global wait
wait:
 li a7, SYS_wait
 388:	488d                	li	a7,3
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 390:	4891                	li	a7,4
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <read>:
.global read
read:
 li a7, SYS_read
 398:	4895                	li	a7,5
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <write>:
.global write
write:
 li a7, SYS_write
 3a0:	48c1                	li	a7,16
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <close>:
.global close
close:
 li a7, SYS_close
 3a8:	48d5                	li	a7,21
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b0:	4899                	li	a7,6
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b8:	489d                	li	a7,7
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <open>:
.global open
open:
 li a7, SYS_open
 3c0:	48bd                	li	a7,15
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c8:	48c5                	li	a7,17
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d0:	48c9                	li	a7,18
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d8:	48a1                	li	a7,8
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <link>:
.global link
link:
 li a7, SYS_link
 3e0:	48cd                	li	a7,19
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e8:	48d1                	li	a7,20
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f0:	48a5                	li	a7,9
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f8:	48a9                	li	a7,10
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 400:	48ad                	li	a7,11
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 408:	48b1                	li	a7,12
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <pause>:
.global pause
pause:
 li a7, SYS_pause
 410:	48b5                	li	a7,13
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 418:	48b9                	li	a7,14
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <setfilter>:
.global setfilter
setfilter:
 li a7, SYS_setfilter
 420:	48dd                	li	a7,23
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <getfilter>:
.global getfilter
getfilter:
 li a7, SYS_getfilter
 428:	48e1                	li	a7,24
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <setfilter_child>:
.global setfilter_child
setfilter_child:
 li a7, SYS_setfilter_child
 430:	48e5                	li	a7,25
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 438:	1101                	addi	sp,sp,-32
 43a:	ec06                	sd	ra,24(sp)
 43c:	e822                	sd	s0,16(sp)
 43e:	1000                	addi	s0,sp,32
 440:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 444:	4605                	li	a2,1
 446:	fef40593          	addi	a1,s0,-17
 44a:	f57ff0ef          	jal	3a0 <write>
}
 44e:	60e2                	ld	ra,24(sp)
 450:	6442                	ld	s0,16(sp)
 452:	6105                	addi	sp,sp,32
 454:	8082                	ret

0000000000000456 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 456:	715d                	addi	sp,sp,-80
 458:	e486                	sd	ra,72(sp)
 45a:	e0a2                	sd	s0,64(sp)
 45c:	f84a                	sd	s2,48(sp)
 45e:	0880                	addi	s0,sp,80
 460:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 462:	c299                	beqz	a3,468 <printint+0x12>
 464:	0805c363          	bltz	a1,4ea <printint+0x94>
  neg = 0;
 468:	4881                	li	a7,0
 46a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 46e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 470:	00000517          	auipc	a0,0x0
 474:	71850513          	addi	a0,a0,1816 # b88 <digits>
 478:	883e                	mv	a6,a5
 47a:	2785                	addiw	a5,a5,1
 47c:	02c5f733          	remu	a4,a1,a2
 480:	972a                	add	a4,a4,a0
 482:	00074703          	lbu	a4,0(a4)
 486:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 48a:	872e                	mv	a4,a1
 48c:	02c5d5b3          	divu	a1,a1,a2
 490:	0685                	addi	a3,a3,1
 492:	fec773e3          	bgeu	a4,a2,478 <printint+0x22>
  if(neg)
 496:	00088b63          	beqz	a7,4ac <printint+0x56>
    buf[i++] = '-';
 49a:	fd078793          	addi	a5,a5,-48
 49e:	97a2                	add	a5,a5,s0
 4a0:	02d00713          	li	a4,45
 4a4:	fee78423          	sb	a4,-24(a5)
 4a8:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4ac:	02f05a63          	blez	a5,4e0 <printint+0x8a>
 4b0:	fc26                	sd	s1,56(sp)
 4b2:	f44e                	sd	s3,40(sp)
 4b4:	fb840713          	addi	a4,s0,-72
 4b8:	00f704b3          	add	s1,a4,a5
 4bc:	fff70993          	addi	s3,a4,-1
 4c0:	99be                	add	s3,s3,a5
 4c2:	37fd                	addiw	a5,a5,-1
 4c4:	1782                	slli	a5,a5,0x20
 4c6:	9381                	srli	a5,a5,0x20
 4c8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4cc:	fff4c583          	lbu	a1,-1(s1)
 4d0:	854a                	mv	a0,s2
 4d2:	f67ff0ef          	jal	438 <putc>
  while(--i >= 0)
 4d6:	14fd                	addi	s1,s1,-1
 4d8:	ff349ae3          	bne	s1,s3,4cc <printint+0x76>
 4dc:	74e2                	ld	s1,56(sp)
 4de:	79a2                	ld	s3,40(sp)
}
 4e0:	60a6                	ld	ra,72(sp)
 4e2:	6406                	ld	s0,64(sp)
 4e4:	7942                	ld	s2,48(sp)
 4e6:	6161                	addi	sp,sp,80
 4e8:	8082                	ret
    x = -xx;
 4ea:	40b005b3          	neg	a1,a1
    neg = 1;
 4ee:	4885                	li	a7,1
    x = -xx;
 4f0:	bfad                	j	46a <printint+0x14>

00000000000004f2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f2:	711d                	addi	sp,sp,-96
 4f4:	ec86                	sd	ra,88(sp)
 4f6:	e8a2                	sd	s0,80(sp)
 4f8:	e0ca                	sd	s2,64(sp)
 4fa:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4fc:	0005c903          	lbu	s2,0(a1)
 500:	28090663          	beqz	s2,78c <vprintf+0x29a>
 504:	e4a6                	sd	s1,72(sp)
 506:	fc4e                	sd	s3,56(sp)
 508:	f852                	sd	s4,48(sp)
 50a:	f456                	sd	s5,40(sp)
 50c:	f05a                	sd	s6,32(sp)
 50e:	ec5e                	sd	s7,24(sp)
 510:	e862                	sd	s8,16(sp)
 512:	e466                	sd	s9,8(sp)
 514:	8b2a                	mv	s6,a0
 516:	8a2e                	mv	s4,a1
 518:	8bb2                	mv	s7,a2
  state = 0;
 51a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 51c:	4481                	li	s1,0
 51e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 520:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 524:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 528:	06c00c93          	li	s9,108
 52c:	a005                	j	54c <vprintf+0x5a>
        putc(fd, c0);
 52e:	85ca                	mv	a1,s2
 530:	855a                	mv	a0,s6
 532:	f07ff0ef          	jal	438 <putc>
 536:	a019                	j	53c <vprintf+0x4a>
    } else if(state == '%'){
 538:	03598263          	beq	s3,s5,55c <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 53c:	2485                	addiw	s1,s1,1
 53e:	8726                	mv	a4,s1
 540:	009a07b3          	add	a5,s4,s1
 544:	0007c903          	lbu	s2,0(a5)
 548:	22090a63          	beqz	s2,77c <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 54c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 550:	fe0994e3          	bnez	s3,538 <vprintf+0x46>
      if(c0 == '%'){
 554:	fd579de3          	bne	a5,s5,52e <vprintf+0x3c>
        state = '%';
 558:	89be                	mv	s3,a5
 55a:	b7cd                	j	53c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 55c:	00ea06b3          	add	a3,s4,a4
 560:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 564:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 566:	c681                	beqz	a3,56e <vprintf+0x7c>
 568:	9752                	add	a4,a4,s4
 56a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 56e:	05878363          	beq	a5,s8,5b4 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 572:	05978d63          	beq	a5,s9,5cc <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 576:	07500713          	li	a4,117
 57a:	0ee78763          	beq	a5,a4,668 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 57e:	07800713          	li	a4,120
 582:	12e78963          	beq	a5,a4,6b4 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 586:	07000713          	li	a4,112
 58a:	14e78e63          	beq	a5,a4,6e6 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 58e:	06300713          	li	a4,99
 592:	18e78e63          	beq	a5,a4,72e <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 596:	07300713          	li	a4,115
 59a:	1ae78463          	beq	a5,a4,742 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 59e:	02500713          	li	a4,37
 5a2:	04e79563          	bne	a5,a4,5ec <vprintf+0xfa>
        putc(fd, '%');
 5a6:	02500593          	li	a1,37
 5aa:	855a                	mv	a0,s6
 5ac:	e8dff0ef          	jal	438 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	b769                	j	53c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5b4:	008b8913          	addi	s2,s7,8
 5b8:	4685                	li	a3,1
 5ba:	4629                	li	a2,10
 5bc:	000ba583          	lw	a1,0(s7)
 5c0:	855a                	mv	a0,s6
 5c2:	e95ff0ef          	jal	456 <printint>
 5c6:	8bca                	mv	s7,s2
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	bf8d                	j	53c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5cc:	06400793          	li	a5,100
 5d0:	02f68963          	beq	a3,a5,602 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5d4:	06c00793          	li	a5,108
 5d8:	04f68263          	beq	a3,a5,61c <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5dc:	07500793          	li	a5,117
 5e0:	0af68063          	beq	a3,a5,680 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5e4:	07800793          	li	a5,120
 5e8:	0ef68263          	beq	a3,a5,6cc <vprintf+0x1da>
        putc(fd, '%');
 5ec:	02500593          	li	a1,37
 5f0:	855a                	mv	a0,s6
 5f2:	e47ff0ef          	jal	438 <putc>
        putc(fd, c0);
 5f6:	85ca                	mv	a1,s2
 5f8:	855a                	mv	a0,s6
 5fa:	e3fff0ef          	jal	438 <putc>
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bf35                	j	53c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 602:	008b8913          	addi	s2,s7,8
 606:	4685                	li	a3,1
 608:	4629                	li	a2,10
 60a:	000bb583          	ld	a1,0(s7)
 60e:	855a                	mv	a0,s6
 610:	e47ff0ef          	jal	456 <printint>
        i += 1;
 614:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 616:	8bca                	mv	s7,s2
      state = 0;
 618:	4981                	li	s3,0
        i += 1;
 61a:	b70d                	j	53c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 61c:	06400793          	li	a5,100
 620:	02f60763          	beq	a2,a5,64e <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 624:	07500793          	li	a5,117
 628:	06f60963          	beq	a2,a5,69a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 62c:	07800793          	li	a5,120
 630:	faf61ee3          	bne	a2,a5,5ec <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 634:	008b8913          	addi	s2,s7,8
 638:	4681                	li	a3,0
 63a:	4641                	li	a2,16
 63c:	000bb583          	ld	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	e15ff0ef          	jal	456 <printint>
        i += 2;
 646:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 648:	8bca                	mv	s7,s2
      state = 0;
 64a:	4981                	li	s3,0
        i += 2;
 64c:	bdc5                	j	53c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 64e:	008b8913          	addi	s2,s7,8
 652:	4685                	li	a3,1
 654:	4629                	li	a2,10
 656:	000bb583          	ld	a1,0(s7)
 65a:	855a                	mv	a0,s6
 65c:	dfbff0ef          	jal	456 <printint>
        i += 2;
 660:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 662:	8bca                	mv	s7,s2
      state = 0;
 664:	4981                	li	s3,0
        i += 2;
 666:	bdd9                	j	53c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 668:	008b8913          	addi	s2,s7,8
 66c:	4681                	li	a3,0
 66e:	4629                	li	a2,10
 670:	000be583          	lwu	a1,0(s7)
 674:	855a                	mv	a0,s6
 676:	de1ff0ef          	jal	456 <printint>
 67a:	8bca                	mv	s7,s2
      state = 0;
 67c:	4981                	li	s3,0
 67e:	bd7d                	j	53c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 680:	008b8913          	addi	s2,s7,8
 684:	4681                	li	a3,0
 686:	4629                	li	a2,10
 688:	000bb583          	ld	a1,0(s7)
 68c:	855a                	mv	a0,s6
 68e:	dc9ff0ef          	jal	456 <printint>
        i += 1;
 692:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 694:	8bca                	mv	s7,s2
      state = 0;
 696:	4981                	li	s3,0
        i += 1;
 698:	b555                	j	53c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 69a:	008b8913          	addi	s2,s7,8
 69e:	4681                	li	a3,0
 6a0:	4629                	li	a2,10
 6a2:	000bb583          	ld	a1,0(s7)
 6a6:	855a                	mv	a0,s6
 6a8:	dafff0ef          	jal	456 <printint>
        i += 2;
 6ac:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ae:	8bca                	mv	s7,s2
      state = 0;
 6b0:	4981                	li	s3,0
        i += 2;
 6b2:	b569                	j	53c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6b4:	008b8913          	addi	s2,s7,8
 6b8:	4681                	li	a3,0
 6ba:	4641                	li	a2,16
 6bc:	000be583          	lwu	a1,0(s7)
 6c0:	855a                	mv	a0,s6
 6c2:	d95ff0ef          	jal	456 <printint>
 6c6:	8bca                	mv	s7,s2
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	bd8d                	j	53c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6cc:	008b8913          	addi	s2,s7,8
 6d0:	4681                	li	a3,0
 6d2:	4641                	li	a2,16
 6d4:	000bb583          	ld	a1,0(s7)
 6d8:	855a                	mv	a0,s6
 6da:	d7dff0ef          	jal	456 <printint>
        i += 1;
 6de:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e0:	8bca                	mv	s7,s2
      state = 0;
 6e2:	4981                	li	s3,0
        i += 1;
 6e4:	bda1                	j	53c <vprintf+0x4a>
 6e6:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6e8:	008b8d13          	addi	s10,s7,8
 6ec:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6f0:	03000593          	li	a1,48
 6f4:	855a                	mv	a0,s6
 6f6:	d43ff0ef          	jal	438 <putc>
  putc(fd, 'x');
 6fa:	07800593          	li	a1,120
 6fe:	855a                	mv	a0,s6
 700:	d39ff0ef          	jal	438 <putc>
 704:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 706:	00000b97          	auipc	s7,0x0
 70a:	482b8b93          	addi	s7,s7,1154 # b88 <digits>
 70e:	03c9d793          	srli	a5,s3,0x3c
 712:	97de                	add	a5,a5,s7
 714:	0007c583          	lbu	a1,0(a5)
 718:	855a                	mv	a0,s6
 71a:	d1fff0ef          	jal	438 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 71e:	0992                	slli	s3,s3,0x4
 720:	397d                	addiw	s2,s2,-1
 722:	fe0916e3          	bnez	s2,70e <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 726:	8bea                	mv	s7,s10
      state = 0;
 728:	4981                	li	s3,0
 72a:	6d02                	ld	s10,0(sp)
 72c:	bd01                	j	53c <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 72e:	008b8913          	addi	s2,s7,8
 732:	000bc583          	lbu	a1,0(s7)
 736:	855a                	mv	a0,s6
 738:	d01ff0ef          	jal	438 <putc>
 73c:	8bca                	mv	s7,s2
      state = 0;
 73e:	4981                	li	s3,0
 740:	bbf5                	j	53c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 742:	008b8993          	addi	s3,s7,8
 746:	000bb903          	ld	s2,0(s7)
 74a:	00090f63          	beqz	s2,768 <vprintf+0x276>
        for(; *s; s++)
 74e:	00094583          	lbu	a1,0(s2)
 752:	c195                	beqz	a1,776 <vprintf+0x284>
          putc(fd, *s);
 754:	855a                	mv	a0,s6
 756:	ce3ff0ef          	jal	438 <putc>
        for(; *s; s++)
 75a:	0905                	addi	s2,s2,1
 75c:	00094583          	lbu	a1,0(s2)
 760:	f9f5                	bnez	a1,754 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 762:	8bce                	mv	s7,s3
      state = 0;
 764:	4981                	li	s3,0
 766:	bbd9                	j	53c <vprintf+0x4a>
          s = "(null)";
 768:	00000917          	auipc	s2,0x0
 76c:	41890913          	addi	s2,s2,1048 # b80 <filter_is_blocked+0x1da>
        for(; *s; s++)
 770:	02800593          	li	a1,40
 774:	b7c5                	j	754 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 776:	8bce                	mv	s7,s3
      state = 0;
 778:	4981                	li	s3,0
 77a:	b3c9                	j	53c <vprintf+0x4a>
 77c:	64a6                	ld	s1,72(sp)
 77e:	79e2                	ld	s3,56(sp)
 780:	7a42                	ld	s4,48(sp)
 782:	7aa2                	ld	s5,40(sp)
 784:	7b02                	ld	s6,32(sp)
 786:	6be2                	ld	s7,24(sp)
 788:	6c42                	ld	s8,16(sp)
 78a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 78c:	60e6                	ld	ra,88(sp)
 78e:	6446                	ld	s0,80(sp)
 790:	6906                	ld	s2,64(sp)
 792:	6125                	addi	sp,sp,96
 794:	8082                	ret

0000000000000796 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 796:	715d                	addi	sp,sp,-80
 798:	ec06                	sd	ra,24(sp)
 79a:	e822                	sd	s0,16(sp)
 79c:	1000                	addi	s0,sp,32
 79e:	e010                	sd	a2,0(s0)
 7a0:	e414                	sd	a3,8(s0)
 7a2:	e818                	sd	a4,16(s0)
 7a4:	ec1c                	sd	a5,24(s0)
 7a6:	03043023          	sd	a6,32(s0)
 7aa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ae:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b2:	8622                	mv	a2,s0
 7b4:	d3fff0ef          	jal	4f2 <vprintf>
}
 7b8:	60e2                	ld	ra,24(sp)
 7ba:	6442                	ld	s0,16(sp)
 7bc:	6161                	addi	sp,sp,80
 7be:	8082                	ret

00000000000007c0 <printf>:

void
printf(const char *fmt, ...)
{
 7c0:	711d                	addi	sp,sp,-96
 7c2:	ec06                	sd	ra,24(sp)
 7c4:	e822                	sd	s0,16(sp)
 7c6:	1000                	addi	s0,sp,32
 7c8:	e40c                	sd	a1,8(s0)
 7ca:	e810                	sd	a2,16(s0)
 7cc:	ec14                	sd	a3,24(s0)
 7ce:	f018                	sd	a4,32(s0)
 7d0:	f41c                	sd	a5,40(s0)
 7d2:	03043823          	sd	a6,48(s0)
 7d6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7da:	00840613          	addi	a2,s0,8
 7de:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7e2:	85aa                	mv	a1,a0
 7e4:	4505                	li	a0,1
 7e6:	d0dff0ef          	jal	4f2 <vprintf>
}
 7ea:	60e2                	ld	ra,24(sp)
 7ec:	6442                	ld	s0,16(sp)
 7ee:	6125                	addi	sp,sp,96
 7f0:	8082                	ret

00000000000007f2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f2:	1141                	addi	sp,sp,-16
 7f4:	e422                	sd	s0,8(sp)
 7f6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fc:	00001797          	auipc	a5,0x1
 800:	8047b783          	ld	a5,-2044(a5) # 1000 <freep>
 804:	a02d                	j	82e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 806:	4618                	lw	a4,8(a2)
 808:	9f2d                	addw	a4,a4,a1
 80a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 80e:	6398                	ld	a4,0(a5)
 810:	6310                	ld	a2,0(a4)
 812:	a83d                	j	850 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 814:	ff852703          	lw	a4,-8(a0)
 818:	9f31                	addw	a4,a4,a2
 81a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 81c:	ff053683          	ld	a3,-16(a0)
 820:	a091                	j	864 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 822:	6398                	ld	a4,0(a5)
 824:	00e7e463          	bltu	a5,a4,82c <free+0x3a>
 828:	00e6ea63          	bltu	a3,a4,83c <free+0x4a>
{
 82c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82e:	fed7fae3          	bgeu	a5,a3,822 <free+0x30>
 832:	6398                	ld	a4,0(a5)
 834:	00e6e463          	bltu	a3,a4,83c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 838:	fee7eae3          	bltu	a5,a4,82c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 83c:	ff852583          	lw	a1,-8(a0)
 840:	6390                	ld	a2,0(a5)
 842:	02059813          	slli	a6,a1,0x20
 846:	01c85713          	srli	a4,a6,0x1c
 84a:	9736                	add	a4,a4,a3
 84c:	fae60de3          	beq	a2,a4,806 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 850:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 854:	4790                	lw	a2,8(a5)
 856:	02061593          	slli	a1,a2,0x20
 85a:	01c5d713          	srli	a4,a1,0x1c
 85e:	973e                	add	a4,a4,a5
 860:	fae68ae3          	beq	a3,a4,814 <free+0x22>
    p->s.ptr = bp->s.ptr;
 864:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 866:	00000717          	auipc	a4,0x0
 86a:	78f73d23          	sd	a5,1946(a4) # 1000 <freep>
}
 86e:	6422                	ld	s0,8(sp)
 870:	0141                	addi	sp,sp,16
 872:	8082                	ret

0000000000000874 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 874:	7139                	addi	sp,sp,-64
 876:	fc06                	sd	ra,56(sp)
 878:	f822                	sd	s0,48(sp)
 87a:	f426                	sd	s1,40(sp)
 87c:	ec4e                	sd	s3,24(sp)
 87e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 880:	02051493          	slli	s1,a0,0x20
 884:	9081                	srli	s1,s1,0x20
 886:	04bd                	addi	s1,s1,15
 888:	8091                	srli	s1,s1,0x4
 88a:	0014899b          	addiw	s3,s1,1
 88e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 890:	00000517          	auipc	a0,0x0
 894:	77053503          	ld	a0,1904(a0) # 1000 <freep>
 898:	c915                	beqz	a0,8cc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89c:	4798                	lw	a4,8(a5)
 89e:	08977a63          	bgeu	a4,s1,932 <malloc+0xbe>
 8a2:	f04a                	sd	s2,32(sp)
 8a4:	e852                	sd	s4,16(sp)
 8a6:	e456                	sd	s5,8(sp)
 8a8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8aa:	8a4e                	mv	s4,s3
 8ac:	0009871b          	sext.w	a4,s3
 8b0:	6685                	lui	a3,0x1
 8b2:	00d77363          	bgeu	a4,a3,8b8 <malloc+0x44>
 8b6:	6a05                	lui	s4,0x1
 8b8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8bc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c0:	00000917          	auipc	s2,0x0
 8c4:	74090913          	addi	s2,s2,1856 # 1000 <freep>
  if(p == SBRK_ERROR)
 8c8:	5afd                	li	s5,-1
 8ca:	a081                	j	90a <malloc+0x96>
 8cc:	f04a                	sd	s2,32(sp)
 8ce:	e852                	sd	s4,16(sp)
 8d0:	e456                	sd	s5,8(sp)
 8d2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8d4:	00000797          	auipc	a5,0x0
 8d8:	73c78793          	addi	a5,a5,1852 # 1010 <base>
 8dc:	00000717          	auipc	a4,0x0
 8e0:	72f73223          	sd	a5,1828(a4) # 1000 <freep>
 8e4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8e6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ea:	b7c1                	j	8aa <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8ec:	6398                	ld	a4,0(a5)
 8ee:	e118                	sd	a4,0(a0)
 8f0:	a8a9                	j	94a <malloc+0xd6>
  hp->s.size = nu;
 8f2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f6:	0541                	addi	a0,a0,16
 8f8:	efbff0ef          	jal	7f2 <free>
  return freep;
 8fc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 900:	c12d                	beqz	a0,962 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 902:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 904:	4798                	lw	a4,8(a5)
 906:	02977263          	bgeu	a4,s1,92a <malloc+0xb6>
    if(p == freep)
 90a:	00093703          	ld	a4,0(s2)
 90e:	853e                	mv	a0,a5
 910:	fef719e3          	bne	a4,a5,902 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 914:	8552                	mv	a0,s4
 916:	a37ff0ef          	jal	34c <sbrk>
  if(p == SBRK_ERROR)
 91a:	fd551ce3          	bne	a0,s5,8f2 <malloc+0x7e>
        return 0;
 91e:	4501                	li	a0,0
 920:	7902                	ld	s2,32(sp)
 922:	6a42                	ld	s4,16(sp)
 924:	6aa2                	ld	s5,8(sp)
 926:	6b02                	ld	s6,0(sp)
 928:	a03d                	j	956 <malloc+0xe2>
 92a:	7902                	ld	s2,32(sp)
 92c:	6a42                	ld	s4,16(sp)
 92e:	6aa2                	ld	s5,8(sp)
 930:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 932:	fae48de3          	beq	s1,a4,8ec <malloc+0x78>
        p->s.size -= nunits;
 936:	4137073b          	subw	a4,a4,s3
 93a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 93c:	02071693          	slli	a3,a4,0x20
 940:	01c6d713          	srli	a4,a3,0x1c
 944:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 946:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 94a:	00000717          	auipc	a4,0x0
 94e:	6aa73b23          	sd	a0,1718(a4) # 1000 <freep>
      return (void*)(p + 1);
 952:	01078513          	addi	a0,a5,16
  }
}
 956:	70e2                	ld	ra,56(sp)
 958:	7442                	ld	s0,48(sp)
 95a:	74a2                	ld	s1,40(sp)
 95c:	69e2                	ld	s3,24(sp)
 95e:	6121                	addi	sp,sp,64
 960:	8082                	ret
 962:	7902                	ld	s2,32(sp)
 964:	6a42                	ld	s4,16(sp)
 966:	6aa2                	ld	s5,8(sp)
 968:	6b02                	ld	s6,0(sp)
 96a:	b7f5                	j	956 <malloc+0xe2>

000000000000096c <filter_enable>:
#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int filter_enable(long blacklist_mask) {
 96c:	1141                	addi	sp,sp,-16
 96e:	e406                	sd	ra,8(sp)
 970:	e022                	sd	s0,0(sp)
 972:	0800                	addi	s0,sp,16
    // Truyền thẳng mask xuống Kernel (Bit 1 = BỊ CHẶN)
    return setfilter(blacklist_mask);
 974:	aadff0ef          	jal	420 <setfilter>
}
 978:	60a2                	ld	ra,8(sp)
 97a:	6402                	ld	s0,0(sp)
 97c:	0141                	addi	sp,sp,16
 97e:	8082                	ret

0000000000000980 <filter_add_rule>:

int filter_add_rule(int sys_num) {
 980:	1101                	addi	sp,sp,-32
 982:	ec06                	sd	ra,24(sp)
 984:	e822                	sd	s0,16(sp)
 986:	e426                	sd	s1,8(sp)
 988:	1000                	addi	s0,sp,32
 98a:	84aa                	mv	s1,a0
    long current_mask = getfilter();
 98c:	a9dff0ef          	jal	428 <getfilter>
    return setfilter(current_mask | BLOCK(sys_num));
 990:	4785                	li	a5,1
 992:	009797b3          	sll	a5,a5,s1
 996:	8d5d                	or	a0,a0,a5
 998:	a89ff0ef          	jal	420 <setfilter>
}
 99c:	60e2                	ld	ra,24(sp)
 99e:	6442                	ld	s0,16(sp)
 9a0:	64a2                	ld	s1,8(sp)
 9a2:	6105                	addi	sp,sp,32
 9a4:	8082                	ret

00000000000009a6 <filter_is_blocked>:

int filter_is_blocked(int sys_num) {
 9a6:	1101                	addi	sp,sp,-32
 9a8:	ec06                	sd	ra,24(sp)
 9aa:	e822                	sd	s0,16(sp)
 9ac:	e426                	sd	s1,8(sp)
 9ae:	1000                	addi	s0,sp,32
 9b0:	84aa                	mv	s1,a0
    long current_mask = getfilter();
 9b2:	a77ff0ef          	jal	428 <getfilter>
    return (current_mask & BLOCK(sys_num)) != 0;
 9b6:	40955533          	sra	a0,a0,s1
}
 9ba:	8905                	andi	a0,a0,1
 9bc:	60e2                	ld	ra,24(sp)
 9be:	6442                	ld	s0,16(sp)
 9c0:	64a2                	ld	s1,8(sp)
 9c2:	6105                	addi	sp,sp,32
 9c4:	8082                	ret
