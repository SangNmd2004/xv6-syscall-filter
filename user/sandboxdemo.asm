
user/_sandboxdemo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_sandbox>:
#include "user/user.h"


#define MASK_FORBIDDEN (FILTER_OPEN) // Cấm gọi hàm open()

void test_sandbox() {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    int pid = fork();
   8:	350000ef          	jal	358 <fork>
    if (pid < 0) exit(1);
   c:	06054563          	bltz	a0,76 <test_sandbox+0x76>

    if (pid == 0) {
  10:	e941                	bnez	a0,a0 <test_sandbox+0xa0>
        printf("\n[Child] Bat dau thiet lap Sandbox...\n");
  12:	00001517          	auipc	a0,0x1
  16:	99e50513          	addi	a0,a0,-1634 # 9b0 <filter_is_blocked+0x2a>
  1a:	786000ef          	jal	7a0 <printf>

        // Áp dụng bộ lọc: CẤM open()
        if (filter_enable(MASK_FORBIDDEN) < 0) {
  1e:	6521                	lui	a0,0x8
  20:	12d000ef          	jal	94c <filter_enable>
  24:	04054c63          	bltz	a0,7c <test_sandbox+0x7c>
            printf("[Child] Loi: Khong the set filter!\n");
            exit(1);
        }

        printf("[Child] Thu ham write (Duoc phep)...\n");
  28:	00001517          	auipc	a0,0x1
  2c:	9d850513          	addi	a0,a0,-1576 # a00 <filter_is_blocked+0x7a>
  30:	770000ef          	jal	7a0 <printf>
        write(1, "[Child] Write van chay binh thuong!\n", 36);
  34:	02400613          	li	a2,36
  38:	00001597          	auipc	a1,0x1
  3c:	9f058593          	addi	a1,a1,-1552 # a28 <filter_is_blocked+0xa2>
  40:	4505                	li	a0,1
  42:	33e000ef          	jal	380 <write>

        printf("[Child] Thu ham open (Bi cam)...\n");
  46:	00001517          	auipc	a0,0x1
  4a:	a0a50513          	addi	a0,a0,-1526 # a50 <filter_is_blocked+0xca>
  4e:	752000ef          	jal	7a0 <printf>
        // Hàm open sẽ bị Kernel (Dev 1) chặn và trả về -1
        int fd = open("secret.txt", 0); 
  52:	4581                	li	a1,0
  54:	00001517          	auipc	a0,0x1
  58:	a2450513          	addi	a0,a0,-1500 # a78 <filter_is_blocked+0xf2>
  5c:	344000ef          	jal	3a0 <open>
        
        if (fd < 0) {
  60:	02054763          	bltz	a0,8e <test_sandbox+0x8e>
            printf("[Child] Success! open() da bi sandbox chan.\n");
            exit(0);
        } else {
            printf("[Child] FAIL! Sandbox hoat dong sai.\n");
  64:	00001517          	auipc	a0,0x1
  68:	a5450513          	addi	a0,a0,-1452 # ab8 <filter_is_blocked+0x132>
  6c:	734000ef          	jal	7a0 <printf>
            exit(1);
  70:	4505                	li	a0,1
  72:	2ee000ef          	jal	360 <exit>
    if (pid < 0) exit(1);
  76:	4505                	li	a0,1
  78:	2e8000ef          	jal	360 <exit>
            printf("[Child] Loi: Khong the set filter!\n");
  7c:	00001517          	auipc	a0,0x1
  80:	95c50513          	addi	a0,a0,-1700 # 9d8 <filter_is_blocked+0x52>
  84:	71c000ef          	jal	7a0 <printf>
            exit(1);
  88:	4505                	li	a0,1
  8a:	2d6000ef          	jal	360 <exit>
            printf("[Child] Success! open() da bi sandbox chan.\n");
  8e:	00001517          	auipc	a0,0x1
  92:	9fa50513          	addi	a0,a0,-1542 # a88 <filter_is_blocked+0x102>
  96:	70a000ef          	jal	7a0 <printf>
            exit(0);
  9a:	4501                	li	a0,0
  9c:	2c4000ef          	jal	360 <exit>
        }
    } else {
        wait(0);
  a0:	4501                	li	a0,0
  a2:	2c6000ef          	jal	368 <wait>
    }
}
  a6:	60a2                	ld	ra,8(sp)
  a8:	6402                	ld	s0,0(sp)
  aa:	0141                	addi	sp,sp,16
  ac:	8082                	ret

00000000000000ae <main>:

int main() {
  ae:	1141                	addi	sp,sp,-16
  b0:	e406                	sd	ra,8(sp)
  b2:	e022                	sd	s0,0(sp)
  b4:	0800                	addi	s0,sp,16
    printf("--- SANDBOX DEMO ON XV6 ---\n");
  b6:	00001517          	auipc	a0,0x1
  ba:	a2a50513          	addi	a0,a0,-1494 # ae0 <filter_is_blocked+0x15a>
  be:	6e2000ef          	jal	7a0 <printf>
    test_sandbox();
  c2:	f3fff0ef          	jal	0 <test_sandbox>
    exit(0);
  c6:	4501                	li	a0,0
  c8:	298000ef          	jal	360 <exit>

00000000000000cc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  d4:	fdbff0ef          	jal	ae <main>
  exit(r);
  d8:	288000ef          	jal	360 <exit>

00000000000000dc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e422                	sd	s0,8(sp)
  e0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e2:	87aa                	mv	a5,a0
  e4:	0585                	addi	a1,a1,1
  e6:	0785                	addi	a5,a5,1
  e8:	fff5c703          	lbu	a4,-1(a1)
  ec:	fee78fa3          	sb	a4,-1(a5)
  f0:	fb75                	bnez	a4,e4 <strcpy+0x8>
    ;
  return os;
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret

00000000000000f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  fe:	00054783          	lbu	a5,0(a0)
 102:	cb91                	beqz	a5,116 <strcmp+0x1e>
 104:	0005c703          	lbu	a4,0(a1)
 108:	00f71763          	bne	a4,a5,116 <strcmp+0x1e>
    p++, q++;
 10c:	0505                	addi	a0,a0,1
 10e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 110:	00054783          	lbu	a5,0(a0)
 114:	fbe5                	bnez	a5,104 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 116:	0005c503          	lbu	a0,0(a1)
}
 11a:	40a7853b          	subw	a0,a5,a0
 11e:	6422                	ld	s0,8(sp)
 120:	0141                	addi	sp,sp,16
 122:	8082                	ret

0000000000000124 <strlen>:

uint
strlen(const char *s)
{
 124:	1141                	addi	sp,sp,-16
 126:	e422                	sd	s0,8(sp)
 128:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 12a:	00054783          	lbu	a5,0(a0)
 12e:	cf91                	beqz	a5,14a <strlen+0x26>
 130:	0505                	addi	a0,a0,1
 132:	87aa                	mv	a5,a0
 134:	86be                	mv	a3,a5
 136:	0785                	addi	a5,a5,1
 138:	fff7c703          	lbu	a4,-1(a5)
 13c:	ff65                	bnez	a4,134 <strlen+0x10>
 13e:	40a6853b          	subw	a0,a3,a0
 142:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret
  for(n = 0; s[n]; n++)
 14a:	4501                	li	a0,0
 14c:	bfe5                	j	144 <strlen+0x20>

000000000000014e <memset>:

void*
memset(void *dst, int c, uint n)
{
 14e:	1141                	addi	sp,sp,-16
 150:	e422                	sd	s0,8(sp)
 152:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 154:	ca19                	beqz	a2,16a <memset+0x1c>
 156:	87aa                	mv	a5,a0
 158:	1602                	slli	a2,a2,0x20
 15a:	9201                	srli	a2,a2,0x20
 15c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 160:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 164:	0785                	addi	a5,a5,1
 166:	fee79de3          	bne	a5,a4,160 <memset+0x12>
  }
  return dst;
}
 16a:	6422                	ld	s0,8(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret

0000000000000170 <strchr>:

char*
strchr(const char *s, char c)
{
 170:	1141                	addi	sp,sp,-16
 172:	e422                	sd	s0,8(sp)
 174:	0800                	addi	s0,sp,16
  for(; *s; s++)
 176:	00054783          	lbu	a5,0(a0)
 17a:	cb99                	beqz	a5,190 <strchr+0x20>
    if(*s == c)
 17c:	00f58763          	beq	a1,a5,18a <strchr+0x1a>
  for(; *s; s++)
 180:	0505                	addi	a0,a0,1
 182:	00054783          	lbu	a5,0(a0)
 186:	fbfd                	bnez	a5,17c <strchr+0xc>
      return (char*)s;
  return 0;
 188:	4501                	li	a0,0
}
 18a:	6422                	ld	s0,8(sp)
 18c:	0141                	addi	sp,sp,16
 18e:	8082                	ret
  return 0;
 190:	4501                	li	a0,0
 192:	bfe5                	j	18a <strchr+0x1a>

0000000000000194 <gets>:

char*
gets(char *buf, int max)
{
 194:	711d                	addi	sp,sp,-96
 196:	ec86                	sd	ra,88(sp)
 198:	e8a2                	sd	s0,80(sp)
 19a:	e4a6                	sd	s1,72(sp)
 19c:	e0ca                	sd	s2,64(sp)
 19e:	fc4e                	sd	s3,56(sp)
 1a0:	f852                	sd	s4,48(sp)
 1a2:	f456                	sd	s5,40(sp)
 1a4:	f05a                	sd	s6,32(sp)
 1a6:	ec5e                	sd	s7,24(sp)
 1a8:	1080                	addi	s0,sp,96
 1aa:	8baa                	mv	s7,a0
 1ac:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ae:	892a                	mv	s2,a0
 1b0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1b2:	4aa9                	li	s5,10
 1b4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1b6:	89a6                	mv	s3,s1
 1b8:	2485                	addiw	s1,s1,1
 1ba:	0344d663          	bge	s1,s4,1e6 <gets+0x52>
    cc = read(0, &c, 1);
 1be:	4605                	li	a2,1
 1c0:	faf40593          	addi	a1,s0,-81
 1c4:	4501                	li	a0,0
 1c6:	1b2000ef          	jal	378 <read>
    if(cc < 1)
 1ca:	00a05e63          	blez	a0,1e6 <gets+0x52>
    buf[i++] = c;
 1ce:	faf44783          	lbu	a5,-81(s0)
 1d2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d6:	01578763          	beq	a5,s5,1e4 <gets+0x50>
 1da:	0905                	addi	s2,s2,1
 1dc:	fd679de3          	bne	a5,s6,1b6 <gets+0x22>
    buf[i++] = c;
 1e0:	89a6                	mv	s3,s1
 1e2:	a011                	j	1e6 <gets+0x52>
 1e4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e6:	99de                	add	s3,s3,s7
 1e8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ec:	855e                	mv	a0,s7
 1ee:	60e6                	ld	ra,88(sp)
 1f0:	6446                	ld	s0,80(sp)
 1f2:	64a6                	ld	s1,72(sp)
 1f4:	6906                	ld	s2,64(sp)
 1f6:	79e2                	ld	s3,56(sp)
 1f8:	7a42                	ld	s4,48(sp)
 1fa:	7aa2                	ld	s5,40(sp)
 1fc:	7b02                	ld	s6,32(sp)
 1fe:	6be2                	ld	s7,24(sp)
 200:	6125                	addi	sp,sp,96
 202:	8082                	ret

0000000000000204 <stat>:

int
stat(const char *n, struct stat *st)
{
 204:	1101                	addi	sp,sp,-32
 206:	ec06                	sd	ra,24(sp)
 208:	e822                	sd	s0,16(sp)
 20a:	e04a                	sd	s2,0(sp)
 20c:	1000                	addi	s0,sp,32
 20e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 210:	4581                	li	a1,0
 212:	18e000ef          	jal	3a0 <open>
  if(fd < 0)
 216:	02054263          	bltz	a0,23a <stat+0x36>
 21a:	e426                	sd	s1,8(sp)
 21c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 21e:	85ca                	mv	a1,s2
 220:	198000ef          	jal	3b8 <fstat>
 224:	892a                	mv	s2,a0
  close(fd);
 226:	8526                	mv	a0,s1
 228:	160000ef          	jal	388 <close>
  return r;
 22c:	64a2                	ld	s1,8(sp)
}
 22e:	854a                	mv	a0,s2
 230:	60e2                	ld	ra,24(sp)
 232:	6442                	ld	s0,16(sp)
 234:	6902                	ld	s2,0(sp)
 236:	6105                	addi	sp,sp,32
 238:	8082                	ret
    return -1;
 23a:	597d                	li	s2,-1
 23c:	bfcd                	j	22e <stat+0x2a>

000000000000023e <atoi>:

int
atoi(const char *s)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 244:	00054683          	lbu	a3,0(a0)
 248:	fd06879b          	addiw	a5,a3,-48
 24c:	0ff7f793          	zext.b	a5,a5
 250:	4625                	li	a2,9
 252:	02f66863          	bltu	a2,a5,282 <atoi+0x44>
 256:	872a                	mv	a4,a0
  n = 0;
 258:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 25a:	0705                	addi	a4,a4,1
 25c:	0025179b          	slliw	a5,a0,0x2
 260:	9fa9                	addw	a5,a5,a0
 262:	0017979b          	slliw	a5,a5,0x1
 266:	9fb5                	addw	a5,a5,a3
 268:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 26c:	00074683          	lbu	a3,0(a4)
 270:	fd06879b          	addiw	a5,a3,-48
 274:	0ff7f793          	zext.b	a5,a5
 278:	fef671e3          	bgeu	a2,a5,25a <atoi+0x1c>
  return n;
}
 27c:	6422                	ld	s0,8(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret
  n = 0;
 282:	4501                	li	a0,0
 284:	bfe5                	j	27c <atoi+0x3e>

0000000000000286 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 286:	1141                	addi	sp,sp,-16
 288:	e422                	sd	s0,8(sp)
 28a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 28c:	02b57463          	bgeu	a0,a1,2b4 <memmove+0x2e>
    while(n-- > 0)
 290:	00c05f63          	blez	a2,2ae <memmove+0x28>
 294:	1602                	slli	a2,a2,0x20
 296:	9201                	srli	a2,a2,0x20
 298:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 29c:	872a                	mv	a4,a0
      *dst++ = *src++;
 29e:	0585                	addi	a1,a1,1
 2a0:	0705                	addi	a4,a4,1
 2a2:	fff5c683          	lbu	a3,-1(a1)
 2a6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2aa:	fef71ae3          	bne	a4,a5,29e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ae:	6422                	ld	s0,8(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret
    dst += n;
 2b4:	00c50733          	add	a4,a0,a2
    src += n;
 2b8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ba:	fec05ae3          	blez	a2,2ae <memmove+0x28>
 2be:	fff6079b          	addiw	a5,a2,-1
 2c2:	1782                	slli	a5,a5,0x20
 2c4:	9381                	srli	a5,a5,0x20
 2c6:	fff7c793          	not	a5,a5
 2ca:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2cc:	15fd                	addi	a1,a1,-1
 2ce:	177d                	addi	a4,a4,-1
 2d0:	0005c683          	lbu	a3,0(a1)
 2d4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d8:	fee79ae3          	bne	a5,a4,2cc <memmove+0x46>
 2dc:	bfc9                	j	2ae <memmove+0x28>

00000000000002de <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e4:	ca05                	beqz	a2,314 <memcmp+0x36>
 2e6:	fff6069b          	addiw	a3,a2,-1
 2ea:	1682                	slli	a3,a3,0x20
 2ec:	9281                	srli	a3,a3,0x20
 2ee:	0685                	addi	a3,a3,1
 2f0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2f2:	00054783          	lbu	a5,0(a0)
 2f6:	0005c703          	lbu	a4,0(a1)
 2fa:	00e79863          	bne	a5,a4,30a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2fe:	0505                	addi	a0,a0,1
    p2++;
 300:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 302:	fed518e3          	bne	a0,a3,2f2 <memcmp+0x14>
  }
  return 0;
 306:	4501                	li	a0,0
 308:	a019                	j	30e <memcmp+0x30>
      return *p1 - *p2;
 30a:	40e7853b          	subw	a0,a5,a4
}
 30e:	6422                	ld	s0,8(sp)
 310:	0141                	addi	sp,sp,16
 312:	8082                	ret
  return 0;
 314:	4501                	li	a0,0
 316:	bfe5                	j	30e <memcmp+0x30>

0000000000000318 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 318:	1141                	addi	sp,sp,-16
 31a:	e406                	sd	ra,8(sp)
 31c:	e022                	sd	s0,0(sp)
 31e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 320:	f67ff0ef          	jal	286 <memmove>
}
 324:	60a2                	ld	ra,8(sp)
 326:	6402                	ld	s0,0(sp)
 328:	0141                	addi	sp,sp,16
 32a:	8082                	ret

000000000000032c <sbrk>:

char *
sbrk(int n) {
 32c:	1141                	addi	sp,sp,-16
 32e:	e406                	sd	ra,8(sp)
 330:	e022                	sd	s0,0(sp)
 332:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 334:	4585                	li	a1,1
 336:	0b2000ef          	jal	3e8 <sys_sbrk>
}
 33a:	60a2                	ld	ra,8(sp)
 33c:	6402                	ld	s0,0(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret

0000000000000342 <sbrklazy>:

char *
sbrklazy(int n) {
 342:	1141                	addi	sp,sp,-16
 344:	e406                	sd	ra,8(sp)
 346:	e022                	sd	s0,0(sp)
 348:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 34a:	4589                	li	a1,2
 34c:	09c000ef          	jal	3e8 <sys_sbrk>
}
 350:	60a2                	ld	ra,8(sp)
 352:	6402                	ld	s0,0(sp)
 354:	0141                	addi	sp,sp,16
 356:	8082                	ret

0000000000000358 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 358:	4885                	li	a7,1
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <exit>:
.global exit
exit:
 li a7, SYS_exit
 360:	4889                	li	a7,2
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <wait>:
.global wait
wait:
 li a7, SYS_wait
 368:	488d                	li	a7,3
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 370:	4891                	li	a7,4
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <read>:
.global read
read:
 li a7, SYS_read
 378:	4895                	li	a7,5
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <write>:
.global write
write:
 li a7, SYS_write
 380:	48c1                	li	a7,16
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <close>:
.global close
close:
 li a7, SYS_close
 388:	48d5                	li	a7,21
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <kill>:
.global kill
kill:
 li a7, SYS_kill
 390:	4899                	li	a7,6
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <exec>:
.global exec
exec:
 li a7, SYS_exec
 398:	489d                	li	a7,7
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <open>:
.global open
open:
 li a7, SYS_open
 3a0:	48bd                	li	a7,15
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a8:	48c5                	li	a7,17
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b0:	48c9                	li	a7,18
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b8:	48a1                	li	a7,8
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <link>:
.global link
link:
 li a7, SYS_link
 3c0:	48cd                	li	a7,19
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c8:	48d1                	li	a7,20
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d0:	48a5                	li	a7,9
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d8:	48a9                	li	a7,10
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e0:	48ad                	li	a7,11
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e8:	48b1                	li	a7,12
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3f0:	48b5                	li	a7,13
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f8:	48b9                	li	a7,14
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <setfilter>:
.global setfilter
setfilter:
 li a7, SYS_setfilter
 400:	48dd                	li	a7,23
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <getfilter>:
.global getfilter
getfilter:
 li a7, SYS_getfilter
 408:	48e1                	li	a7,24
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <setfilter_child>:
.global setfilter_child
setfilter_child:
 li a7, SYS_setfilter_child
 410:	48e5                	li	a7,25
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 418:	1101                	addi	sp,sp,-32
 41a:	ec06                	sd	ra,24(sp)
 41c:	e822                	sd	s0,16(sp)
 41e:	1000                	addi	s0,sp,32
 420:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 424:	4605                	li	a2,1
 426:	fef40593          	addi	a1,s0,-17
 42a:	f57ff0ef          	jal	380 <write>
}
 42e:	60e2                	ld	ra,24(sp)
 430:	6442                	ld	s0,16(sp)
 432:	6105                	addi	sp,sp,32
 434:	8082                	ret

0000000000000436 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 436:	715d                	addi	sp,sp,-80
 438:	e486                	sd	ra,72(sp)
 43a:	e0a2                	sd	s0,64(sp)
 43c:	f84a                	sd	s2,48(sp)
 43e:	0880                	addi	s0,sp,80
 440:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 442:	c299                	beqz	a3,448 <printint+0x12>
 444:	0805c363          	bltz	a1,4ca <printint+0x94>
  neg = 0;
 448:	4881                	li	a7,0
 44a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 44e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 450:	00000517          	auipc	a0,0x0
 454:	6b850513          	addi	a0,a0,1720 # b08 <digits>
 458:	883e                	mv	a6,a5
 45a:	2785                	addiw	a5,a5,1
 45c:	02c5f733          	remu	a4,a1,a2
 460:	972a                	add	a4,a4,a0
 462:	00074703          	lbu	a4,0(a4)
 466:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 46a:	872e                	mv	a4,a1
 46c:	02c5d5b3          	divu	a1,a1,a2
 470:	0685                	addi	a3,a3,1
 472:	fec773e3          	bgeu	a4,a2,458 <printint+0x22>
  if(neg)
 476:	00088b63          	beqz	a7,48c <printint+0x56>
    buf[i++] = '-';
 47a:	fd078793          	addi	a5,a5,-48
 47e:	97a2                	add	a5,a5,s0
 480:	02d00713          	li	a4,45
 484:	fee78423          	sb	a4,-24(a5)
 488:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 48c:	02f05a63          	blez	a5,4c0 <printint+0x8a>
 490:	fc26                	sd	s1,56(sp)
 492:	f44e                	sd	s3,40(sp)
 494:	fb840713          	addi	a4,s0,-72
 498:	00f704b3          	add	s1,a4,a5
 49c:	fff70993          	addi	s3,a4,-1
 4a0:	99be                	add	s3,s3,a5
 4a2:	37fd                	addiw	a5,a5,-1
 4a4:	1782                	slli	a5,a5,0x20
 4a6:	9381                	srli	a5,a5,0x20
 4a8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4ac:	fff4c583          	lbu	a1,-1(s1)
 4b0:	854a                	mv	a0,s2
 4b2:	f67ff0ef          	jal	418 <putc>
  while(--i >= 0)
 4b6:	14fd                	addi	s1,s1,-1
 4b8:	ff349ae3          	bne	s1,s3,4ac <printint+0x76>
 4bc:	74e2                	ld	s1,56(sp)
 4be:	79a2                	ld	s3,40(sp)
}
 4c0:	60a6                	ld	ra,72(sp)
 4c2:	6406                	ld	s0,64(sp)
 4c4:	7942                	ld	s2,48(sp)
 4c6:	6161                	addi	sp,sp,80
 4c8:	8082                	ret
    x = -xx;
 4ca:	40b005b3          	neg	a1,a1
    neg = 1;
 4ce:	4885                	li	a7,1
    x = -xx;
 4d0:	bfad                	j	44a <printint+0x14>

00000000000004d2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d2:	711d                	addi	sp,sp,-96
 4d4:	ec86                	sd	ra,88(sp)
 4d6:	e8a2                	sd	s0,80(sp)
 4d8:	e0ca                	sd	s2,64(sp)
 4da:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4dc:	0005c903          	lbu	s2,0(a1)
 4e0:	28090663          	beqz	s2,76c <vprintf+0x29a>
 4e4:	e4a6                	sd	s1,72(sp)
 4e6:	fc4e                	sd	s3,56(sp)
 4e8:	f852                	sd	s4,48(sp)
 4ea:	f456                	sd	s5,40(sp)
 4ec:	f05a                	sd	s6,32(sp)
 4ee:	ec5e                	sd	s7,24(sp)
 4f0:	e862                	sd	s8,16(sp)
 4f2:	e466                	sd	s9,8(sp)
 4f4:	8b2a                	mv	s6,a0
 4f6:	8a2e                	mv	s4,a1
 4f8:	8bb2                	mv	s7,a2
  state = 0;
 4fa:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4fc:	4481                	li	s1,0
 4fe:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 500:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 504:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 508:	06c00c93          	li	s9,108
 50c:	a005                	j	52c <vprintf+0x5a>
        putc(fd, c0);
 50e:	85ca                	mv	a1,s2
 510:	855a                	mv	a0,s6
 512:	f07ff0ef          	jal	418 <putc>
 516:	a019                	j	51c <vprintf+0x4a>
    } else if(state == '%'){
 518:	03598263          	beq	s3,s5,53c <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 51c:	2485                	addiw	s1,s1,1
 51e:	8726                	mv	a4,s1
 520:	009a07b3          	add	a5,s4,s1
 524:	0007c903          	lbu	s2,0(a5)
 528:	22090a63          	beqz	s2,75c <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 52c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 530:	fe0994e3          	bnez	s3,518 <vprintf+0x46>
      if(c0 == '%'){
 534:	fd579de3          	bne	a5,s5,50e <vprintf+0x3c>
        state = '%';
 538:	89be                	mv	s3,a5
 53a:	b7cd                	j	51c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 53c:	00ea06b3          	add	a3,s4,a4
 540:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 544:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 546:	c681                	beqz	a3,54e <vprintf+0x7c>
 548:	9752                	add	a4,a4,s4
 54a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 54e:	05878363          	beq	a5,s8,594 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 552:	05978d63          	beq	a5,s9,5ac <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 556:	07500713          	li	a4,117
 55a:	0ee78763          	beq	a5,a4,648 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 55e:	07800713          	li	a4,120
 562:	12e78963          	beq	a5,a4,694 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 566:	07000713          	li	a4,112
 56a:	14e78e63          	beq	a5,a4,6c6 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 56e:	06300713          	li	a4,99
 572:	18e78e63          	beq	a5,a4,70e <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 576:	07300713          	li	a4,115
 57a:	1ae78463          	beq	a5,a4,722 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 57e:	02500713          	li	a4,37
 582:	04e79563          	bne	a5,a4,5cc <vprintf+0xfa>
        putc(fd, '%');
 586:	02500593          	li	a1,37
 58a:	855a                	mv	a0,s6
 58c:	e8dff0ef          	jal	418 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 590:	4981                	li	s3,0
 592:	b769                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 594:	008b8913          	addi	s2,s7,8
 598:	4685                	li	a3,1
 59a:	4629                	li	a2,10
 59c:	000ba583          	lw	a1,0(s7)
 5a0:	855a                	mv	a0,s6
 5a2:	e95ff0ef          	jal	436 <printint>
 5a6:	8bca                	mv	s7,s2
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	bf8d                	j	51c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5ac:	06400793          	li	a5,100
 5b0:	02f68963          	beq	a3,a5,5e2 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5b4:	06c00793          	li	a5,108
 5b8:	04f68263          	beq	a3,a5,5fc <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5bc:	07500793          	li	a5,117
 5c0:	0af68063          	beq	a3,a5,660 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5c4:	07800793          	li	a5,120
 5c8:	0ef68263          	beq	a3,a5,6ac <vprintf+0x1da>
        putc(fd, '%');
 5cc:	02500593          	li	a1,37
 5d0:	855a                	mv	a0,s6
 5d2:	e47ff0ef          	jal	418 <putc>
        putc(fd, c0);
 5d6:	85ca                	mv	a1,s2
 5d8:	855a                	mv	a0,s6
 5da:	e3fff0ef          	jal	418 <putc>
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	bf35                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4685                	li	a3,1
 5e8:	4629                	li	a2,10
 5ea:	000bb583          	ld	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	e47ff0ef          	jal	436 <printint>
        i += 1;
 5f4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f6:	8bca                	mv	s7,s2
      state = 0;
 5f8:	4981                	li	s3,0
        i += 1;
 5fa:	b70d                	j	51c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5fc:	06400793          	li	a5,100
 600:	02f60763          	beq	a2,a5,62e <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 604:	07500793          	li	a5,117
 608:	06f60963          	beq	a2,a5,67a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 60c:	07800793          	li	a5,120
 610:	faf61ee3          	bne	a2,a5,5cc <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 614:	008b8913          	addi	s2,s7,8
 618:	4681                	li	a3,0
 61a:	4641                	li	a2,16
 61c:	000bb583          	ld	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	e15ff0ef          	jal	436 <printint>
        i += 2;
 626:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 628:	8bca                	mv	s7,s2
      state = 0;
 62a:	4981                	li	s3,0
        i += 2;
 62c:	bdc5                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 62e:	008b8913          	addi	s2,s7,8
 632:	4685                	li	a3,1
 634:	4629                	li	a2,10
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	dfbff0ef          	jal	436 <printint>
        i += 2;
 640:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 2;
 646:	bdd9                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 648:	008b8913          	addi	s2,s7,8
 64c:	4681                	li	a3,0
 64e:	4629                	li	a2,10
 650:	000be583          	lwu	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	de1ff0ef          	jal	436 <printint>
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bd7d                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 660:	008b8913          	addi	s2,s7,8
 664:	4681                	li	a3,0
 666:	4629                	li	a2,10
 668:	000bb583          	ld	a1,0(s7)
 66c:	855a                	mv	a0,s6
 66e:	dc9ff0ef          	jal	436 <printint>
        i += 1;
 672:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
        i += 1;
 678:	b555                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4681                	li	a3,0
 680:	4629                	li	a2,10
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	dafff0ef          	jal	436 <printint>
        i += 2;
 68c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 2;
 692:	b569                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 694:	008b8913          	addi	s2,s7,8
 698:	4681                	li	a3,0
 69a:	4641                	li	a2,16
 69c:	000be583          	lwu	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	d95ff0ef          	jal	436 <printint>
 6a6:	8bca                	mv	s7,s2
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	bd8d                	j	51c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	4681                	li	a3,0
 6b2:	4641                	li	a2,16
 6b4:	000bb583          	ld	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	d7dff0ef          	jal	436 <printint>
        i += 1;
 6be:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
        i += 1;
 6c4:	bda1                	j	51c <vprintf+0x4a>
 6c6:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6c8:	008b8d13          	addi	s10,s7,8
 6cc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6d0:	03000593          	li	a1,48
 6d4:	855a                	mv	a0,s6
 6d6:	d43ff0ef          	jal	418 <putc>
  putc(fd, 'x');
 6da:	07800593          	li	a1,120
 6de:	855a                	mv	a0,s6
 6e0:	d39ff0ef          	jal	418 <putc>
 6e4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e6:	00000b97          	auipc	s7,0x0
 6ea:	422b8b93          	addi	s7,s7,1058 # b08 <digits>
 6ee:	03c9d793          	srli	a5,s3,0x3c
 6f2:	97de                	add	a5,a5,s7
 6f4:	0007c583          	lbu	a1,0(a5)
 6f8:	855a                	mv	a0,s6
 6fa:	d1fff0ef          	jal	418 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6fe:	0992                	slli	s3,s3,0x4
 700:	397d                	addiw	s2,s2,-1
 702:	fe0916e3          	bnez	s2,6ee <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 706:	8bea                	mv	s7,s10
      state = 0;
 708:	4981                	li	s3,0
 70a:	6d02                	ld	s10,0(sp)
 70c:	bd01                	j	51c <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 70e:	008b8913          	addi	s2,s7,8
 712:	000bc583          	lbu	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	d01ff0ef          	jal	418 <putc>
 71c:	8bca                	mv	s7,s2
      state = 0;
 71e:	4981                	li	s3,0
 720:	bbf5                	j	51c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 722:	008b8993          	addi	s3,s7,8
 726:	000bb903          	ld	s2,0(s7)
 72a:	00090f63          	beqz	s2,748 <vprintf+0x276>
        for(; *s; s++)
 72e:	00094583          	lbu	a1,0(s2)
 732:	c195                	beqz	a1,756 <vprintf+0x284>
          putc(fd, *s);
 734:	855a                	mv	a0,s6
 736:	ce3ff0ef          	jal	418 <putc>
        for(; *s; s++)
 73a:	0905                	addi	s2,s2,1
 73c:	00094583          	lbu	a1,0(s2)
 740:	f9f5                	bnez	a1,734 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 742:	8bce                	mv	s7,s3
      state = 0;
 744:	4981                	li	s3,0
 746:	bbd9                	j	51c <vprintf+0x4a>
          s = "(null)";
 748:	00000917          	auipc	s2,0x0
 74c:	3b890913          	addi	s2,s2,952 # b00 <filter_is_blocked+0x17a>
        for(; *s; s++)
 750:	02800593          	li	a1,40
 754:	b7c5                	j	734 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 756:	8bce                	mv	s7,s3
      state = 0;
 758:	4981                	li	s3,0
 75a:	b3c9                	j	51c <vprintf+0x4a>
 75c:	64a6                	ld	s1,72(sp)
 75e:	79e2                	ld	s3,56(sp)
 760:	7a42                	ld	s4,48(sp)
 762:	7aa2                	ld	s5,40(sp)
 764:	7b02                	ld	s6,32(sp)
 766:	6be2                	ld	s7,24(sp)
 768:	6c42                	ld	s8,16(sp)
 76a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 76c:	60e6                	ld	ra,88(sp)
 76e:	6446                	ld	s0,80(sp)
 770:	6906                	ld	s2,64(sp)
 772:	6125                	addi	sp,sp,96
 774:	8082                	ret

0000000000000776 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 776:	715d                	addi	sp,sp,-80
 778:	ec06                	sd	ra,24(sp)
 77a:	e822                	sd	s0,16(sp)
 77c:	1000                	addi	s0,sp,32
 77e:	e010                	sd	a2,0(s0)
 780:	e414                	sd	a3,8(s0)
 782:	e818                	sd	a4,16(s0)
 784:	ec1c                	sd	a5,24(s0)
 786:	03043023          	sd	a6,32(s0)
 78a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 78e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 792:	8622                	mv	a2,s0
 794:	d3fff0ef          	jal	4d2 <vprintf>
}
 798:	60e2                	ld	ra,24(sp)
 79a:	6442                	ld	s0,16(sp)
 79c:	6161                	addi	sp,sp,80
 79e:	8082                	ret

00000000000007a0 <printf>:

void
printf(const char *fmt, ...)
{
 7a0:	711d                	addi	sp,sp,-96
 7a2:	ec06                	sd	ra,24(sp)
 7a4:	e822                	sd	s0,16(sp)
 7a6:	1000                	addi	s0,sp,32
 7a8:	e40c                	sd	a1,8(s0)
 7aa:	e810                	sd	a2,16(s0)
 7ac:	ec14                	sd	a3,24(s0)
 7ae:	f018                	sd	a4,32(s0)
 7b0:	f41c                	sd	a5,40(s0)
 7b2:	03043823          	sd	a6,48(s0)
 7b6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ba:	00840613          	addi	a2,s0,8
 7be:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c2:	85aa                	mv	a1,a0
 7c4:	4505                	li	a0,1
 7c6:	d0dff0ef          	jal	4d2 <vprintf>
}
 7ca:	60e2                	ld	ra,24(sp)
 7cc:	6442                	ld	s0,16(sp)
 7ce:	6125                	addi	sp,sp,96
 7d0:	8082                	ret

00000000000007d2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d2:	1141                	addi	sp,sp,-16
 7d4:	e422                	sd	s0,8(sp)
 7d6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7dc:	00001797          	auipc	a5,0x1
 7e0:	8247b783          	ld	a5,-2012(a5) # 1000 <freep>
 7e4:	a02d                	j	80e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7e6:	4618                	lw	a4,8(a2)
 7e8:	9f2d                	addw	a4,a4,a1
 7ea:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ee:	6398                	ld	a4,0(a5)
 7f0:	6310                	ld	a2,0(a4)
 7f2:	a83d                	j	830 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f4:	ff852703          	lw	a4,-8(a0)
 7f8:	9f31                	addw	a4,a4,a2
 7fa:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7fc:	ff053683          	ld	a3,-16(a0)
 800:	a091                	j	844 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 802:	6398                	ld	a4,0(a5)
 804:	00e7e463          	bltu	a5,a4,80c <free+0x3a>
 808:	00e6ea63          	bltu	a3,a4,81c <free+0x4a>
{
 80c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80e:	fed7fae3          	bgeu	a5,a3,802 <free+0x30>
 812:	6398                	ld	a4,0(a5)
 814:	00e6e463          	bltu	a3,a4,81c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 818:	fee7eae3          	bltu	a5,a4,80c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 81c:	ff852583          	lw	a1,-8(a0)
 820:	6390                	ld	a2,0(a5)
 822:	02059813          	slli	a6,a1,0x20
 826:	01c85713          	srli	a4,a6,0x1c
 82a:	9736                	add	a4,a4,a3
 82c:	fae60de3          	beq	a2,a4,7e6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 830:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 834:	4790                	lw	a2,8(a5)
 836:	02061593          	slli	a1,a2,0x20
 83a:	01c5d713          	srli	a4,a1,0x1c
 83e:	973e                	add	a4,a4,a5
 840:	fae68ae3          	beq	a3,a4,7f4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 844:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 846:	00000717          	auipc	a4,0x0
 84a:	7af73d23          	sd	a5,1978(a4) # 1000 <freep>
}
 84e:	6422                	ld	s0,8(sp)
 850:	0141                	addi	sp,sp,16
 852:	8082                	ret

0000000000000854 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 854:	7139                	addi	sp,sp,-64
 856:	fc06                	sd	ra,56(sp)
 858:	f822                	sd	s0,48(sp)
 85a:	f426                	sd	s1,40(sp)
 85c:	ec4e                	sd	s3,24(sp)
 85e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 860:	02051493          	slli	s1,a0,0x20
 864:	9081                	srli	s1,s1,0x20
 866:	04bd                	addi	s1,s1,15
 868:	8091                	srli	s1,s1,0x4
 86a:	0014899b          	addiw	s3,s1,1
 86e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 870:	00000517          	auipc	a0,0x0
 874:	79053503          	ld	a0,1936(a0) # 1000 <freep>
 878:	c915                	beqz	a0,8ac <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 87c:	4798                	lw	a4,8(a5)
 87e:	08977a63          	bgeu	a4,s1,912 <malloc+0xbe>
 882:	f04a                	sd	s2,32(sp)
 884:	e852                	sd	s4,16(sp)
 886:	e456                	sd	s5,8(sp)
 888:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 88a:	8a4e                	mv	s4,s3
 88c:	0009871b          	sext.w	a4,s3
 890:	6685                	lui	a3,0x1
 892:	00d77363          	bgeu	a4,a3,898 <malloc+0x44>
 896:	6a05                	lui	s4,0x1
 898:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 89c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a0:	00000917          	auipc	s2,0x0
 8a4:	76090913          	addi	s2,s2,1888 # 1000 <freep>
  if(p == SBRK_ERROR)
 8a8:	5afd                	li	s5,-1
 8aa:	a081                	j	8ea <malloc+0x96>
 8ac:	f04a                	sd	s2,32(sp)
 8ae:	e852                	sd	s4,16(sp)
 8b0:	e456                	sd	s5,8(sp)
 8b2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8b4:	00000797          	auipc	a5,0x0
 8b8:	75c78793          	addi	a5,a5,1884 # 1010 <base>
 8bc:	00000717          	auipc	a4,0x0
 8c0:	74f73223          	sd	a5,1860(a4) # 1000 <freep>
 8c4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ca:	b7c1                	j	88a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8cc:	6398                	ld	a4,0(a5)
 8ce:	e118                	sd	a4,0(a0)
 8d0:	a8a9                	j	92a <malloc+0xd6>
  hp->s.size = nu;
 8d2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d6:	0541                	addi	a0,a0,16
 8d8:	efbff0ef          	jal	7d2 <free>
  return freep;
 8dc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e0:	c12d                	beqz	a0,942 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e4:	4798                	lw	a4,8(a5)
 8e6:	02977263          	bgeu	a4,s1,90a <malloc+0xb6>
    if(p == freep)
 8ea:	00093703          	ld	a4,0(s2)
 8ee:	853e                	mv	a0,a5
 8f0:	fef719e3          	bne	a4,a5,8e2 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8f4:	8552                	mv	a0,s4
 8f6:	a37ff0ef          	jal	32c <sbrk>
  if(p == SBRK_ERROR)
 8fa:	fd551ce3          	bne	a0,s5,8d2 <malloc+0x7e>
        return 0;
 8fe:	4501                	li	a0,0
 900:	7902                	ld	s2,32(sp)
 902:	6a42                	ld	s4,16(sp)
 904:	6aa2                	ld	s5,8(sp)
 906:	6b02                	ld	s6,0(sp)
 908:	a03d                	j	936 <malloc+0xe2>
 90a:	7902                	ld	s2,32(sp)
 90c:	6a42                	ld	s4,16(sp)
 90e:	6aa2                	ld	s5,8(sp)
 910:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 912:	fae48de3          	beq	s1,a4,8cc <malloc+0x78>
        p->s.size -= nunits;
 916:	4137073b          	subw	a4,a4,s3
 91a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 91c:	02071693          	slli	a3,a4,0x20
 920:	01c6d713          	srli	a4,a3,0x1c
 924:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 926:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 92a:	00000717          	auipc	a4,0x0
 92e:	6ca73b23          	sd	a0,1750(a4) # 1000 <freep>
      return (void*)(p + 1);
 932:	01078513          	addi	a0,a5,16
  }
}
 936:	70e2                	ld	ra,56(sp)
 938:	7442                	ld	s0,48(sp)
 93a:	74a2                	ld	s1,40(sp)
 93c:	69e2                	ld	s3,24(sp)
 93e:	6121                	addi	sp,sp,64
 940:	8082                	ret
 942:	7902                	ld	s2,32(sp)
 944:	6a42                	ld	s4,16(sp)
 946:	6aa2                	ld	s5,8(sp)
 948:	6b02                	ld	s6,0(sp)
 94a:	b7f5                	j	936 <malloc+0xe2>

000000000000094c <filter_enable>:
#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int filter_enable(long blacklist_mask) {
 94c:	1141                	addi	sp,sp,-16
 94e:	e406                	sd	ra,8(sp)
 950:	e022                	sd	s0,0(sp)
 952:	0800                	addi	s0,sp,16
    // Truyền thẳng mask xuống Kernel (Bit 1 = BỊ CHẶN)
    return setfilter(blacklist_mask);
 954:	aadff0ef          	jal	400 <setfilter>
}
 958:	60a2                	ld	ra,8(sp)
 95a:	6402                	ld	s0,0(sp)
 95c:	0141                	addi	sp,sp,16
 95e:	8082                	ret

0000000000000960 <filter_add_rule>:

int filter_add_rule(int sys_num) {
 960:	1101                	addi	sp,sp,-32
 962:	ec06                	sd	ra,24(sp)
 964:	e822                	sd	s0,16(sp)
 966:	e426                	sd	s1,8(sp)
 968:	1000                	addi	s0,sp,32
 96a:	84aa                	mv	s1,a0
    long current_mask = getfilter();
 96c:	a9dff0ef          	jal	408 <getfilter>
    return setfilter(current_mask | BLOCK(sys_num));
 970:	4785                	li	a5,1
 972:	009797b3          	sll	a5,a5,s1
 976:	8d5d                	or	a0,a0,a5
 978:	a89ff0ef          	jal	400 <setfilter>
}
 97c:	60e2                	ld	ra,24(sp)
 97e:	6442                	ld	s0,16(sp)
 980:	64a2                	ld	s1,8(sp)
 982:	6105                	addi	sp,sp,32
 984:	8082                	ret

0000000000000986 <filter_is_blocked>:

int filter_is_blocked(int sys_num) {
 986:	1101                	addi	sp,sp,-32
 988:	ec06                	sd	ra,24(sp)
 98a:	e822                	sd	s0,16(sp)
 98c:	e426                	sd	s1,8(sp)
 98e:	1000                	addi	s0,sp,32
 990:	84aa                	mv	s1,a0
    long current_mask = getfilter();
 992:	a77ff0ef          	jal	408 <getfilter>
    return (current_mask & BLOCK(sys_num)) != 0;
 996:	40955533          	sra	a0,a0,s1
}
 99a:	8905                	andi	a0,a0,1
 99c:	60e2                	ld	ra,24(sp)
 99e:	6442                	ld	s0,16(sp)
 9a0:	64a2                	ld	s1,8(sp)
 9a2:	6105                	addi	sp,sp,32
 9a4:	8082                	ret
