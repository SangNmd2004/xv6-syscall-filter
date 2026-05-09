
user/_full_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_fork>:
#include "kernel/syscall.h" // Chứa macro SYS_write

// Giả sử SYS_write là 16. Nếu file header của ông khác, hãy thay vào đây.
#define FILTER_WRITE (1 << SYS_write)

void test_fork() {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
    printf("Test #3: Testing Fork Inheritance...\n");
   8:	00001517          	auipc	a0,0x1
   c:	98850513          	addi	a0,a0,-1656 # 990 <malloc+0x100>
  10:	7cc000ef          	jal	7dc <printf>
    // KHÔNG bật setfilter ở đây nữa!

    int pid = fork();
  14:	380000ef          	jal	394 <fork>
    if (pid < 0) {
  18:	02054063          	bltz	a0,38 <test_fork+0x38>
        printf("[FAIL] Fork failed!\n");
        return;
    }
    
    if (pid == 0) {
  1c:	c50d                	beqz	a0,46 <test_fork+0x46>
        } else {
            printf("[FAIL] Fork: Child did NOT inherit mask!\n");
        }
        exit(0);
    } else {
        wait(0); // Cha đợi con xong
  1e:	4501                	li	a0,0
  20:	384000ef          	jal	3a4 <wait>
        printf("Debug: Cha da doi con xong.\n");
  24:	00001517          	auipc	a0,0x1
  28:	a2c50513          	addi	a0,a0,-1492 # a50 <malloc+0x1c0>
  2c:	7b0000ef          	jal	7dc <printf>
    }
}
  30:	60e2                	ld	ra,24(sp)
  32:	6442                	ld	s0,16(sp)
  34:	6105                	addi	sp,sp,32
  36:	8082                	ret
        printf("[FAIL] Fork failed!\n");
  38:	00001517          	auipc	a0,0x1
  3c:	98050513          	addi	a0,a0,-1664 # 9b8 <malloc+0x128>
  40:	79c000ef          	jal	7dc <printf>
        return;
  44:	b7f5                	j	30 <test_fork+0x30>
  46:	e426                	sd	s1,8(sp)
        setfilter(FILTER_WRITE); 
  48:	6541                	lui	a0,0x10
  4a:	3f2000ef          	jal	43c <setfilter>
        int ret = write(1, "Child process attempt\n", 22);
  4e:	4659                	li	a2,22
  50:	00001597          	auipc	a1,0x1
  54:	98058593          	addi	a1,a1,-1664 # 9d0 <malloc+0x140>
  58:	4505                	li	a0,1
  5a:	362000ef          	jal	3bc <write>
  5e:	84aa                	mv	s1,a0
        setfilter(0); 
  60:	4501                	li	a0,0
  62:	3da000ef          	jal	43c <setfilter>
        if (ret == -1) {
  66:	57fd                	li	a5,-1
  68:	00f48b63          	beq	s1,a5,7e <test_fork+0x7e>
            printf("[FAIL] Fork: Child did NOT inherit mask!\n");
  6c:	00001517          	auipc	a0,0x1
  70:	9b450513          	addi	a0,a0,-1612 # a20 <malloc+0x190>
  74:	768000ef          	jal	7dc <printf>
        exit(0);
  78:	4501                	li	a0,0
  7a:	322000ef          	jal	39c <exit>
            printf("[PASS] Fork: Child inherited mask, write() blocked!\n");
  7e:	00001517          	auipc	a0,0x1
  82:	96a50513          	addi	a0,a0,-1686 # 9e8 <malloc+0x158>
  86:	756000ef          	jal	7dc <printf>
  8a:	b7fd                	j	78 <test_fork+0x78>

000000000000008c <test_exec>:
void test_exec() {
  8c:	7179                	addi	sp,sp,-48
  8e:	f406                	sd	ra,40(sp)
  90:	f022                	sd	s0,32(sp)
  92:	1800                	addi	s0,sp,48
    printf("\nTest #4: Testing Exec Persistence...\n");
  94:	00001517          	auipc	a0,0x1
  98:	9dc50513          	addi	a0,a0,-1572 # a70 <malloc+0x1e0>
  9c:	740000ef          	jal	7dc <printf>
    setfilter(FILTER_WRITE);
  a0:	6541                	lui	a0,0x10
  a2:	39a000ef          	jal	43c <setfilter>
    
    // Thử exec "echo". 
    // Nếu filter bền bỉ, 'exec' (hoặc các syscall bên trong echo) sẽ bị chặn và trả về -1
    char *argv[] = {"echo", "This should not print", 0};
  a6:	00001517          	auipc	a0,0x1
  aa:	9f250513          	addi	a0,a0,-1550 # a98 <malloc+0x208>
  ae:	fca43c23          	sd	a0,-40(s0)
  b2:	00001797          	auipc	a5,0x1
  b6:	9ee78793          	addi	a5,a5,-1554 # aa0 <malloc+0x210>
  ba:	fef43023          	sd	a5,-32(s0)
  be:	fe043423          	sd	zero,-24(s0)
    int ret = exec("echo", argv);
  c2:	fd840593          	addi	a1,s0,-40
  c6:	30e000ef          	jal	3d4 <exec>
    
    // Nếu exec trả về -1 tức là bị chặn
    if (ret == -1) {
  ca:	57fd                	li	a5,-1
  cc:	00f50c63          	beq	a0,a5,e4 <test_exec+0x58>
        printf("[PASS] Exec: Filter persisted, exec/write blocked!\n");
    } else {
        printf("[FAIL] Exec: Filter did not persist!\n");
  d0:	00001517          	auipc	a0,0x1
  d4:	a2050513          	addi	a0,a0,-1504 # af0 <malloc+0x260>
  d8:	704000ef          	jal	7dc <printf>
    }
}
  dc:	70a2                	ld	ra,40(sp)
  de:	7402                	ld	s0,32(sp)
  e0:	6145                	addi	sp,sp,48
  e2:	8082                	ret
        printf("[PASS] Exec: Filter persisted, exec/write blocked!\n");
  e4:	00001517          	auipc	a0,0x1
  e8:	9d450513          	addi	a0,a0,-1580 # ab8 <malloc+0x228>
  ec:	6f0000ef          	jal	7dc <printf>
  f0:	b7f5                	j	dc <test_exec+0x50>

00000000000000f2 <main>:

int main(int argc, char *argv[]) {
  f2:	1141                	addi	sp,sp,-16
  f4:	e406                	sd	ra,8(sp)
  f6:	e022                	sd	s0,0(sp)
  f8:	0800                	addi	s0,sp,16
    test_fork();
  fa:	f07ff0ef          	jal	0 <test_fork>
    test_exec();
  fe:	f8fff0ef          	jal	8c <test_exec>
    exit(0);
 102:	4501                	li	a0,0
 104:	298000ef          	jal	39c <exit>

0000000000000108 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e406                	sd	ra,8(sp)
 10c:	e022                	sd	s0,0(sp)
 10e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 110:	fe3ff0ef          	jal	f2 <main>
  exit(r);
 114:	288000ef          	jal	39c <exit>

0000000000000118 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11e:	87aa                	mv	a5,a0
 120:	0585                	addi	a1,a1,1
 122:	0785                	addi	a5,a5,1
 124:	fff5c703          	lbu	a4,-1(a1)
 128:	fee78fa3          	sb	a4,-1(a5)
 12c:	fb75                	bnez	a4,120 <strcpy+0x8>
    ;
  return os;
}
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret

0000000000000134 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 134:	1141                	addi	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cb91                	beqz	a5,152 <strcmp+0x1e>
 140:	0005c703          	lbu	a4,0(a1)
 144:	00f71763          	bne	a4,a5,152 <strcmp+0x1e>
    p++, q++;
 148:	0505                	addi	a0,a0,1
 14a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14c:	00054783          	lbu	a5,0(a0)
 150:	fbe5                	bnez	a5,140 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 152:	0005c503          	lbu	a0,0(a1)
}
 156:	40a7853b          	subw	a0,a5,a0
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strlen>:

uint
strlen(const char *s)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 166:	00054783          	lbu	a5,0(a0)
 16a:	cf91                	beqz	a5,186 <strlen+0x26>
 16c:	0505                	addi	a0,a0,1
 16e:	87aa                	mv	a5,a0
 170:	86be                	mv	a3,a5
 172:	0785                	addi	a5,a5,1
 174:	fff7c703          	lbu	a4,-1(a5)
 178:	ff65                	bnez	a4,170 <strlen+0x10>
 17a:	40a6853b          	subw	a0,a3,a0
 17e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret
  for(n = 0; s[n]; n++)
 186:	4501                	li	a0,0
 188:	bfe5                	j	180 <strlen+0x20>

000000000000018a <memset>:

void*
memset(void *dst, int c, uint n)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 190:	ca19                	beqz	a2,1a6 <memset+0x1c>
 192:	87aa                	mv	a5,a0
 194:	1602                	slli	a2,a2,0x20
 196:	9201                	srli	a2,a2,0x20
 198:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 19c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a0:	0785                	addi	a5,a5,1
 1a2:	fee79de3          	bne	a5,a4,19c <memset+0x12>
  }
  return dst;
}
 1a6:	6422                	ld	s0,8(sp)
 1a8:	0141                	addi	sp,sp,16
 1aa:	8082                	ret

00000000000001ac <strchr>:

char*
strchr(const char *s, char c)
{
 1ac:	1141                	addi	sp,sp,-16
 1ae:	e422                	sd	s0,8(sp)
 1b0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	cb99                	beqz	a5,1cc <strchr+0x20>
    if(*s == c)
 1b8:	00f58763          	beq	a1,a5,1c6 <strchr+0x1a>
  for(; *s; s++)
 1bc:	0505                	addi	a0,a0,1
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	fbfd                	bnez	a5,1b8 <strchr+0xc>
      return (char*)s;
  return 0;
 1c4:	4501                	li	a0,0
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret
  return 0;
 1cc:	4501                	li	a0,0
 1ce:	bfe5                	j	1c6 <strchr+0x1a>

00000000000001d0 <gets>:

char*
gets(char *buf, int max)
{
 1d0:	711d                	addi	sp,sp,-96
 1d2:	ec86                	sd	ra,88(sp)
 1d4:	e8a2                	sd	s0,80(sp)
 1d6:	e4a6                	sd	s1,72(sp)
 1d8:	e0ca                	sd	s2,64(sp)
 1da:	fc4e                	sd	s3,56(sp)
 1dc:	f852                	sd	s4,48(sp)
 1de:	f456                	sd	s5,40(sp)
 1e0:	f05a                	sd	s6,32(sp)
 1e2:	ec5e                	sd	s7,24(sp)
 1e4:	1080                	addi	s0,sp,96
 1e6:	8baa                	mv	s7,a0
 1e8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ea:	892a                	mv	s2,a0
 1ec:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ee:	4aa9                	li	s5,10
 1f0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1f2:	89a6                	mv	s3,s1
 1f4:	2485                	addiw	s1,s1,1
 1f6:	0344d663          	bge	s1,s4,222 <gets+0x52>
    cc = read(0, &c, 1);
 1fa:	4605                	li	a2,1
 1fc:	faf40593          	addi	a1,s0,-81
 200:	4501                	li	a0,0
 202:	1b2000ef          	jal	3b4 <read>
    if(cc < 1)
 206:	00a05e63          	blez	a0,222 <gets+0x52>
    buf[i++] = c;
 20a:	faf44783          	lbu	a5,-81(s0)
 20e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 212:	01578763          	beq	a5,s5,220 <gets+0x50>
 216:	0905                	addi	s2,s2,1
 218:	fd679de3          	bne	a5,s6,1f2 <gets+0x22>
    buf[i++] = c;
 21c:	89a6                	mv	s3,s1
 21e:	a011                	j	222 <gets+0x52>
 220:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 222:	99de                	add	s3,s3,s7
 224:	00098023          	sb	zero,0(s3)
  return buf;
}
 228:	855e                	mv	a0,s7
 22a:	60e6                	ld	ra,88(sp)
 22c:	6446                	ld	s0,80(sp)
 22e:	64a6                	ld	s1,72(sp)
 230:	6906                	ld	s2,64(sp)
 232:	79e2                	ld	s3,56(sp)
 234:	7a42                	ld	s4,48(sp)
 236:	7aa2                	ld	s5,40(sp)
 238:	7b02                	ld	s6,32(sp)
 23a:	6be2                	ld	s7,24(sp)
 23c:	6125                	addi	sp,sp,96
 23e:	8082                	ret

0000000000000240 <stat>:

int
stat(const char *n, struct stat *st)
{
 240:	1101                	addi	sp,sp,-32
 242:	ec06                	sd	ra,24(sp)
 244:	e822                	sd	s0,16(sp)
 246:	e04a                	sd	s2,0(sp)
 248:	1000                	addi	s0,sp,32
 24a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24c:	4581                	li	a1,0
 24e:	18e000ef          	jal	3dc <open>
  if(fd < 0)
 252:	02054263          	bltz	a0,276 <stat+0x36>
 256:	e426                	sd	s1,8(sp)
 258:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25a:	85ca                	mv	a1,s2
 25c:	198000ef          	jal	3f4 <fstat>
 260:	892a                	mv	s2,a0
  close(fd);
 262:	8526                	mv	a0,s1
 264:	160000ef          	jal	3c4 <close>
  return r;
 268:	64a2                	ld	s1,8(sp)
}
 26a:	854a                	mv	a0,s2
 26c:	60e2                	ld	ra,24(sp)
 26e:	6442                	ld	s0,16(sp)
 270:	6902                	ld	s2,0(sp)
 272:	6105                	addi	sp,sp,32
 274:	8082                	ret
    return -1;
 276:	597d                	li	s2,-1
 278:	bfcd                	j	26a <stat+0x2a>

000000000000027a <atoi>:

int
atoi(const char *s)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 280:	00054683          	lbu	a3,0(a0)
 284:	fd06879b          	addiw	a5,a3,-48
 288:	0ff7f793          	zext.b	a5,a5
 28c:	4625                	li	a2,9
 28e:	02f66863          	bltu	a2,a5,2be <atoi+0x44>
 292:	872a                	mv	a4,a0
  n = 0;
 294:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 296:	0705                	addi	a4,a4,1
 298:	0025179b          	slliw	a5,a0,0x2
 29c:	9fa9                	addw	a5,a5,a0
 29e:	0017979b          	slliw	a5,a5,0x1
 2a2:	9fb5                	addw	a5,a5,a3
 2a4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2a8:	00074683          	lbu	a3,0(a4)
 2ac:	fd06879b          	addiw	a5,a3,-48
 2b0:	0ff7f793          	zext.b	a5,a5
 2b4:	fef671e3          	bgeu	a2,a5,296 <atoi+0x1c>
  return n;
}
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
  n = 0;
 2be:	4501                	li	a0,0
 2c0:	bfe5                	j	2b8 <atoi+0x3e>

00000000000002c2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e422                	sd	s0,8(sp)
 2c6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2c8:	02b57463          	bgeu	a0,a1,2f0 <memmove+0x2e>
    while(n-- > 0)
 2cc:	00c05f63          	blez	a2,2ea <memmove+0x28>
 2d0:	1602                	slli	a2,a2,0x20
 2d2:	9201                	srli	a2,a2,0x20
 2d4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2d8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2da:	0585                	addi	a1,a1,1
 2dc:	0705                	addi	a4,a4,1
 2de:	fff5c683          	lbu	a3,-1(a1)
 2e2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2e6:	fef71ae3          	bne	a4,a5,2da <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
    dst += n;
 2f0:	00c50733          	add	a4,a0,a2
    src += n;
 2f4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2f6:	fec05ae3          	blez	a2,2ea <memmove+0x28>
 2fa:	fff6079b          	addiw	a5,a2,-1
 2fe:	1782                	slli	a5,a5,0x20
 300:	9381                	srli	a5,a5,0x20
 302:	fff7c793          	not	a5,a5
 306:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 308:	15fd                	addi	a1,a1,-1
 30a:	177d                	addi	a4,a4,-1
 30c:	0005c683          	lbu	a3,0(a1)
 310:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 314:	fee79ae3          	bne	a5,a4,308 <memmove+0x46>
 318:	bfc9                	j	2ea <memmove+0x28>

000000000000031a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 31a:	1141                	addi	sp,sp,-16
 31c:	e422                	sd	s0,8(sp)
 31e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 320:	ca05                	beqz	a2,350 <memcmp+0x36>
 322:	fff6069b          	addiw	a3,a2,-1
 326:	1682                	slli	a3,a3,0x20
 328:	9281                	srli	a3,a3,0x20
 32a:	0685                	addi	a3,a3,1
 32c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 32e:	00054783          	lbu	a5,0(a0)
 332:	0005c703          	lbu	a4,0(a1)
 336:	00e79863          	bne	a5,a4,346 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 33a:	0505                	addi	a0,a0,1
    p2++;
 33c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 33e:	fed518e3          	bne	a0,a3,32e <memcmp+0x14>
  }
  return 0;
 342:	4501                	li	a0,0
 344:	a019                	j	34a <memcmp+0x30>
      return *p1 - *p2;
 346:	40e7853b          	subw	a0,a5,a4
}
 34a:	6422                	ld	s0,8(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret
  return 0;
 350:	4501                	li	a0,0
 352:	bfe5                	j	34a <memcmp+0x30>

0000000000000354 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 354:	1141                	addi	sp,sp,-16
 356:	e406                	sd	ra,8(sp)
 358:	e022                	sd	s0,0(sp)
 35a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 35c:	f67ff0ef          	jal	2c2 <memmove>
}
 360:	60a2                	ld	ra,8(sp)
 362:	6402                	ld	s0,0(sp)
 364:	0141                	addi	sp,sp,16
 366:	8082                	ret

0000000000000368 <sbrk>:

char *
sbrk(int n) {
 368:	1141                	addi	sp,sp,-16
 36a:	e406                	sd	ra,8(sp)
 36c:	e022                	sd	s0,0(sp)
 36e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 370:	4585                	li	a1,1
 372:	0b2000ef          	jal	424 <sys_sbrk>
}
 376:	60a2                	ld	ra,8(sp)
 378:	6402                	ld	s0,0(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret

000000000000037e <sbrklazy>:

char *
sbrklazy(int n) {
 37e:	1141                	addi	sp,sp,-16
 380:	e406                	sd	ra,8(sp)
 382:	e022                	sd	s0,0(sp)
 384:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 386:	4589                	li	a1,2
 388:	09c000ef          	jal	424 <sys_sbrk>
}
 38c:	60a2                	ld	ra,8(sp)
 38e:	6402                	ld	s0,0(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret

0000000000000394 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 394:	4885                	li	a7,1
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <exit>:
.global exit
exit:
 li a7, SYS_exit
 39c:	4889                	li	a7,2
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a4:	488d                	li	a7,3
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ac:	4891                	li	a7,4
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <read>:
.global read
read:
 li a7, SYS_read
 3b4:	4895                	li	a7,5
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <write>:
.global write
write:
 li a7, SYS_write
 3bc:	48c1                	li	a7,16
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <close>:
.global close
close:
 li a7, SYS_close
 3c4:	48d5                	li	a7,21
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3cc:	4899                	li	a7,6
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d4:	489d                	li	a7,7
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <open>:
.global open
open:
 li a7, SYS_open
 3dc:	48bd                	li	a7,15
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e4:	48c5                	li	a7,17
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ec:	48c9                	li	a7,18
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f4:	48a1                	li	a7,8
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <link>:
.global link
link:
 li a7, SYS_link
 3fc:	48cd                	li	a7,19
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 404:	48d1                	li	a7,20
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 40c:	48a5                	li	a7,9
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <dup>:
.global dup
dup:
 li a7, SYS_dup
 414:	48a9                	li	a7,10
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 41c:	48ad                	li	a7,11
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 424:	48b1                	li	a7,12
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <pause>:
.global pause
pause:
 li a7, SYS_pause
 42c:	48b5                	li	a7,13
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 434:	48b9                	li	a7,14
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <setfilter>:
.global setfilter
setfilter:
 li a7, SYS_setfilter
 43c:	48dd                	li	a7,23
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <getfilter>:
.global getfilter
getfilter:
 li a7, SYS_getfilter
 444:	48e1                	li	a7,24
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <setfilter_child>:
.global setfilter_child
setfilter_child:
 li a7, SYS_setfilter_child
 44c:	48e5                	li	a7,25
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 454:	1101                	addi	sp,sp,-32
 456:	ec06                	sd	ra,24(sp)
 458:	e822                	sd	s0,16(sp)
 45a:	1000                	addi	s0,sp,32
 45c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 460:	4605                	li	a2,1
 462:	fef40593          	addi	a1,s0,-17
 466:	f57ff0ef          	jal	3bc <write>
}
 46a:	60e2                	ld	ra,24(sp)
 46c:	6442                	ld	s0,16(sp)
 46e:	6105                	addi	sp,sp,32
 470:	8082                	ret

0000000000000472 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 472:	715d                	addi	sp,sp,-80
 474:	e486                	sd	ra,72(sp)
 476:	e0a2                	sd	s0,64(sp)
 478:	f84a                	sd	s2,48(sp)
 47a:	0880                	addi	s0,sp,80
 47c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 47e:	c299                	beqz	a3,484 <printint+0x12>
 480:	0805c363          	bltz	a1,506 <printint+0x94>
  neg = 0;
 484:	4881                	li	a7,0
 486:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 48a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 48c:	00000517          	auipc	a0,0x0
 490:	69450513          	addi	a0,a0,1684 # b20 <digits>
 494:	883e                	mv	a6,a5
 496:	2785                	addiw	a5,a5,1
 498:	02c5f733          	remu	a4,a1,a2
 49c:	972a                	add	a4,a4,a0
 49e:	00074703          	lbu	a4,0(a4)
 4a2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4a6:	872e                	mv	a4,a1
 4a8:	02c5d5b3          	divu	a1,a1,a2
 4ac:	0685                	addi	a3,a3,1
 4ae:	fec773e3          	bgeu	a4,a2,494 <printint+0x22>
  if(neg)
 4b2:	00088b63          	beqz	a7,4c8 <printint+0x56>
    buf[i++] = '-';
 4b6:	fd078793          	addi	a5,a5,-48
 4ba:	97a2                	add	a5,a5,s0
 4bc:	02d00713          	li	a4,45
 4c0:	fee78423          	sb	a4,-24(a5)
 4c4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4c8:	02f05a63          	blez	a5,4fc <printint+0x8a>
 4cc:	fc26                	sd	s1,56(sp)
 4ce:	f44e                	sd	s3,40(sp)
 4d0:	fb840713          	addi	a4,s0,-72
 4d4:	00f704b3          	add	s1,a4,a5
 4d8:	fff70993          	addi	s3,a4,-1
 4dc:	99be                	add	s3,s3,a5
 4de:	37fd                	addiw	a5,a5,-1
 4e0:	1782                	slli	a5,a5,0x20
 4e2:	9381                	srli	a5,a5,0x20
 4e4:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4e8:	fff4c583          	lbu	a1,-1(s1)
 4ec:	854a                	mv	a0,s2
 4ee:	f67ff0ef          	jal	454 <putc>
  while(--i >= 0)
 4f2:	14fd                	addi	s1,s1,-1
 4f4:	ff349ae3          	bne	s1,s3,4e8 <printint+0x76>
 4f8:	74e2                	ld	s1,56(sp)
 4fa:	79a2                	ld	s3,40(sp)
}
 4fc:	60a6                	ld	ra,72(sp)
 4fe:	6406                	ld	s0,64(sp)
 500:	7942                	ld	s2,48(sp)
 502:	6161                	addi	sp,sp,80
 504:	8082                	ret
    x = -xx;
 506:	40b005b3          	neg	a1,a1
    neg = 1;
 50a:	4885                	li	a7,1
    x = -xx;
 50c:	bfad                	j	486 <printint+0x14>

000000000000050e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 50e:	711d                	addi	sp,sp,-96
 510:	ec86                	sd	ra,88(sp)
 512:	e8a2                	sd	s0,80(sp)
 514:	e0ca                	sd	s2,64(sp)
 516:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 518:	0005c903          	lbu	s2,0(a1)
 51c:	28090663          	beqz	s2,7a8 <vprintf+0x29a>
 520:	e4a6                	sd	s1,72(sp)
 522:	fc4e                	sd	s3,56(sp)
 524:	f852                	sd	s4,48(sp)
 526:	f456                	sd	s5,40(sp)
 528:	f05a                	sd	s6,32(sp)
 52a:	ec5e                	sd	s7,24(sp)
 52c:	e862                	sd	s8,16(sp)
 52e:	e466                	sd	s9,8(sp)
 530:	8b2a                	mv	s6,a0
 532:	8a2e                	mv	s4,a1
 534:	8bb2                	mv	s7,a2
  state = 0;
 536:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 538:	4481                	li	s1,0
 53a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 53c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 540:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 544:	06c00c93          	li	s9,108
 548:	a005                	j	568 <vprintf+0x5a>
        putc(fd, c0);
 54a:	85ca                	mv	a1,s2
 54c:	855a                	mv	a0,s6
 54e:	f07ff0ef          	jal	454 <putc>
 552:	a019                	j	558 <vprintf+0x4a>
    } else if(state == '%'){
 554:	03598263          	beq	s3,s5,578 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 558:	2485                	addiw	s1,s1,1
 55a:	8726                	mv	a4,s1
 55c:	009a07b3          	add	a5,s4,s1
 560:	0007c903          	lbu	s2,0(a5)
 564:	22090a63          	beqz	s2,798 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 568:	0009079b          	sext.w	a5,s2
    if(state == 0){
 56c:	fe0994e3          	bnez	s3,554 <vprintf+0x46>
      if(c0 == '%'){
 570:	fd579de3          	bne	a5,s5,54a <vprintf+0x3c>
        state = '%';
 574:	89be                	mv	s3,a5
 576:	b7cd                	j	558 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 578:	00ea06b3          	add	a3,s4,a4
 57c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 580:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 582:	c681                	beqz	a3,58a <vprintf+0x7c>
 584:	9752                	add	a4,a4,s4
 586:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 58a:	05878363          	beq	a5,s8,5d0 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 58e:	05978d63          	beq	a5,s9,5e8 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 592:	07500713          	li	a4,117
 596:	0ee78763          	beq	a5,a4,684 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 59a:	07800713          	li	a4,120
 59e:	12e78963          	beq	a5,a4,6d0 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5a2:	07000713          	li	a4,112
 5a6:	14e78e63          	beq	a5,a4,702 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5aa:	06300713          	li	a4,99
 5ae:	18e78e63          	beq	a5,a4,74a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5b2:	07300713          	li	a4,115
 5b6:	1ae78463          	beq	a5,a4,75e <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5ba:	02500713          	li	a4,37
 5be:	04e79563          	bne	a5,a4,608 <vprintf+0xfa>
        putc(fd, '%');
 5c2:	02500593          	li	a1,37
 5c6:	855a                	mv	a0,s6
 5c8:	e8dff0ef          	jal	454 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5cc:	4981                	li	s3,0
 5ce:	b769                	j	558 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5d0:	008b8913          	addi	s2,s7,8
 5d4:	4685                	li	a3,1
 5d6:	4629                	li	a2,10
 5d8:	000ba583          	lw	a1,0(s7)
 5dc:	855a                	mv	a0,s6
 5de:	e95ff0ef          	jal	472 <printint>
 5e2:	8bca                	mv	s7,s2
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	bf8d                	j	558 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5e8:	06400793          	li	a5,100
 5ec:	02f68963          	beq	a3,a5,61e <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f0:	06c00793          	li	a5,108
 5f4:	04f68263          	beq	a3,a5,638 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5f8:	07500793          	li	a5,117
 5fc:	0af68063          	beq	a3,a5,69c <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 600:	07800793          	li	a5,120
 604:	0ef68263          	beq	a3,a5,6e8 <vprintf+0x1da>
        putc(fd, '%');
 608:	02500593          	li	a1,37
 60c:	855a                	mv	a0,s6
 60e:	e47ff0ef          	jal	454 <putc>
        putc(fd, c0);
 612:	85ca                	mv	a1,s2
 614:	855a                	mv	a0,s6
 616:	e3fff0ef          	jal	454 <putc>
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bf35                	j	558 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 61e:	008b8913          	addi	s2,s7,8
 622:	4685                	li	a3,1
 624:	4629                	li	a2,10
 626:	000bb583          	ld	a1,0(s7)
 62a:	855a                	mv	a0,s6
 62c:	e47ff0ef          	jal	472 <printint>
        i += 1;
 630:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 632:	8bca                	mv	s7,s2
      state = 0;
 634:	4981                	li	s3,0
        i += 1;
 636:	b70d                	j	558 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 638:	06400793          	li	a5,100
 63c:	02f60763          	beq	a2,a5,66a <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 640:	07500793          	li	a5,117
 644:	06f60963          	beq	a2,a5,6b6 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 648:	07800793          	li	a5,120
 64c:	faf61ee3          	bne	a2,a5,608 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 650:	008b8913          	addi	s2,s7,8
 654:	4681                	li	a3,0
 656:	4641                	li	a2,16
 658:	000bb583          	ld	a1,0(s7)
 65c:	855a                	mv	a0,s6
 65e:	e15ff0ef          	jal	472 <printint>
        i += 2;
 662:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
        i += 2;
 668:	bdc5                	j	558 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 66a:	008b8913          	addi	s2,s7,8
 66e:	4685                	li	a3,1
 670:	4629                	li	a2,10
 672:	000bb583          	ld	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	dfbff0ef          	jal	472 <printint>
        i += 2;
 67c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
        i += 2;
 682:	bdd9                	j	558 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 684:	008b8913          	addi	s2,s7,8
 688:	4681                	li	a3,0
 68a:	4629                	li	a2,10
 68c:	000be583          	lwu	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	de1ff0ef          	jal	472 <printint>
 696:	8bca                	mv	s7,s2
      state = 0;
 698:	4981                	li	s3,0
 69a:	bd7d                	j	558 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 69c:	008b8913          	addi	s2,s7,8
 6a0:	4681                	li	a3,0
 6a2:	4629                	li	a2,10
 6a4:	000bb583          	ld	a1,0(s7)
 6a8:	855a                	mv	a0,s6
 6aa:	dc9ff0ef          	jal	472 <printint>
        i += 1;
 6ae:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b0:	8bca                	mv	s7,s2
      state = 0;
 6b2:	4981                	li	s3,0
        i += 1;
 6b4:	b555                	j	558 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b6:	008b8913          	addi	s2,s7,8
 6ba:	4681                	li	a3,0
 6bc:	4629                	li	a2,10
 6be:	000bb583          	ld	a1,0(s7)
 6c2:	855a                	mv	a0,s6
 6c4:	dafff0ef          	jal	472 <printint>
        i += 2;
 6c8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ca:	8bca                	mv	s7,s2
      state = 0;
 6cc:	4981                	li	s3,0
        i += 2;
 6ce:	b569                	j	558 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6d0:	008b8913          	addi	s2,s7,8
 6d4:	4681                	li	a3,0
 6d6:	4641                	li	a2,16
 6d8:	000be583          	lwu	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	d95ff0ef          	jal	472 <printint>
 6e2:	8bca                	mv	s7,s2
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	bd8d                	j	558 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e8:	008b8913          	addi	s2,s7,8
 6ec:	4681                	li	a3,0
 6ee:	4641                	li	a2,16
 6f0:	000bb583          	ld	a1,0(s7)
 6f4:	855a                	mv	a0,s6
 6f6:	d7dff0ef          	jal	472 <printint>
        i += 1;
 6fa:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fc:	8bca                	mv	s7,s2
      state = 0;
 6fe:	4981                	li	s3,0
        i += 1;
 700:	bda1                	j	558 <vprintf+0x4a>
 702:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 704:	008b8d13          	addi	s10,s7,8
 708:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 70c:	03000593          	li	a1,48
 710:	855a                	mv	a0,s6
 712:	d43ff0ef          	jal	454 <putc>
  putc(fd, 'x');
 716:	07800593          	li	a1,120
 71a:	855a                	mv	a0,s6
 71c:	d39ff0ef          	jal	454 <putc>
 720:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 722:	00000b97          	auipc	s7,0x0
 726:	3feb8b93          	addi	s7,s7,1022 # b20 <digits>
 72a:	03c9d793          	srli	a5,s3,0x3c
 72e:	97de                	add	a5,a5,s7
 730:	0007c583          	lbu	a1,0(a5)
 734:	855a                	mv	a0,s6
 736:	d1fff0ef          	jal	454 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 73a:	0992                	slli	s3,s3,0x4
 73c:	397d                	addiw	s2,s2,-1
 73e:	fe0916e3          	bnez	s2,72a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 742:	8bea                	mv	s7,s10
      state = 0;
 744:	4981                	li	s3,0
 746:	6d02                	ld	s10,0(sp)
 748:	bd01                	j	558 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 74a:	008b8913          	addi	s2,s7,8
 74e:	000bc583          	lbu	a1,0(s7)
 752:	855a                	mv	a0,s6
 754:	d01ff0ef          	jal	454 <putc>
 758:	8bca                	mv	s7,s2
      state = 0;
 75a:	4981                	li	s3,0
 75c:	bbf5                	j	558 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 75e:	008b8993          	addi	s3,s7,8
 762:	000bb903          	ld	s2,0(s7)
 766:	00090f63          	beqz	s2,784 <vprintf+0x276>
        for(; *s; s++)
 76a:	00094583          	lbu	a1,0(s2)
 76e:	c195                	beqz	a1,792 <vprintf+0x284>
          putc(fd, *s);
 770:	855a                	mv	a0,s6
 772:	ce3ff0ef          	jal	454 <putc>
        for(; *s; s++)
 776:	0905                	addi	s2,s2,1
 778:	00094583          	lbu	a1,0(s2)
 77c:	f9f5                	bnez	a1,770 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 77e:	8bce                	mv	s7,s3
      state = 0;
 780:	4981                	li	s3,0
 782:	bbd9                	j	558 <vprintf+0x4a>
          s = "(null)";
 784:	00000917          	auipc	s2,0x0
 788:	39490913          	addi	s2,s2,916 # b18 <malloc+0x288>
        for(; *s; s++)
 78c:	02800593          	li	a1,40
 790:	b7c5                	j	770 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 792:	8bce                	mv	s7,s3
      state = 0;
 794:	4981                	li	s3,0
 796:	b3c9                	j	558 <vprintf+0x4a>
 798:	64a6                	ld	s1,72(sp)
 79a:	79e2                	ld	s3,56(sp)
 79c:	7a42                	ld	s4,48(sp)
 79e:	7aa2                	ld	s5,40(sp)
 7a0:	7b02                	ld	s6,32(sp)
 7a2:	6be2                	ld	s7,24(sp)
 7a4:	6c42                	ld	s8,16(sp)
 7a6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7a8:	60e6                	ld	ra,88(sp)
 7aa:	6446                	ld	s0,80(sp)
 7ac:	6906                	ld	s2,64(sp)
 7ae:	6125                	addi	sp,sp,96
 7b0:	8082                	ret

00000000000007b2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b2:	715d                	addi	sp,sp,-80
 7b4:	ec06                	sd	ra,24(sp)
 7b6:	e822                	sd	s0,16(sp)
 7b8:	1000                	addi	s0,sp,32
 7ba:	e010                	sd	a2,0(s0)
 7bc:	e414                	sd	a3,8(s0)
 7be:	e818                	sd	a4,16(s0)
 7c0:	ec1c                	sd	a5,24(s0)
 7c2:	03043023          	sd	a6,32(s0)
 7c6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ca:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ce:	8622                	mv	a2,s0
 7d0:	d3fff0ef          	jal	50e <vprintf>
}
 7d4:	60e2                	ld	ra,24(sp)
 7d6:	6442                	ld	s0,16(sp)
 7d8:	6161                	addi	sp,sp,80
 7da:	8082                	ret

00000000000007dc <printf>:

void
printf(const char *fmt, ...)
{
 7dc:	711d                	addi	sp,sp,-96
 7de:	ec06                	sd	ra,24(sp)
 7e0:	e822                	sd	s0,16(sp)
 7e2:	1000                	addi	s0,sp,32
 7e4:	e40c                	sd	a1,8(s0)
 7e6:	e810                	sd	a2,16(s0)
 7e8:	ec14                	sd	a3,24(s0)
 7ea:	f018                	sd	a4,32(s0)
 7ec:	f41c                	sd	a5,40(s0)
 7ee:	03043823          	sd	a6,48(s0)
 7f2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7f6:	00840613          	addi	a2,s0,8
 7fa:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7fe:	85aa                	mv	a1,a0
 800:	4505                	li	a0,1
 802:	d0dff0ef          	jal	50e <vprintf>
}
 806:	60e2                	ld	ra,24(sp)
 808:	6442                	ld	s0,16(sp)
 80a:	6125                	addi	sp,sp,96
 80c:	8082                	ret

000000000000080e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80e:	1141                	addi	sp,sp,-16
 810:	e422                	sd	s0,8(sp)
 812:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 814:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 818:	00000797          	auipc	a5,0x0
 81c:	7e87b783          	ld	a5,2024(a5) # 1000 <freep>
 820:	a02d                	j	84a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 822:	4618                	lw	a4,8(a2)
 824:	9f2d                	addw	a4,a4,a1
 826:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 82a:	6398                	ld	a4,0(a5)
 82c:	6310                	ld	a2,0(a4)
 82e:	a83d                	j	86c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 830:	ff852703          	lw	a4,-8(a0)
 834:	9f31                	addw	a4,a4,a2
 836:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 838:	ff053683          	ld	a3,-16(a0)
 83c:	a091                	j	880 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83e:	6398                	ld	a4,0(a5)
 840:	00e7e463          	bltu	a5,a4,848 <free+0x3a>
 844:	00e6ea63          	bltu	a3,a4,858 <free+0x4a>
{
 848:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 84a:	fed7fae3          	bgeu	a5,a3,83e <free+0x30>
 84e:	6398                	ld	a4,0(a5)
 850:	00e6e463          	bltu	a3,a4,858 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 854:	fee7eae3          	bltu	a5,a4,848 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 858:	ff852583          	lw	a1,-8(a0)
 85c:	6390                	ld	a2,0(a5)
 85e:	02059813          	slli	a6,a1,0x20
 862:	01c85713          	srli	a4,a6,0x1c
 866:	9736                	add	a4,a4,a3
 868:	fae60de3          	beq	a2,a4,822 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 86c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 870:	4790                	lw	a2,8(a5)
 872:	02061593          	slli	a1,a2,0x20
 876:	01c5d713          	srli	a4,a1,0x1c
 87a:	973e                	add	a4,a4,a5
 87c:	fae68ae3          	beq	a3,a4,830 <free+0x22>
    p->s.ptr = bp->s.ptr;
 880:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 882:	00000717          	auipc	a4,0x0
 886:	76f73f23          	sd	a5,1918(a4) # 1000 <freep>
}
 88a:	6422                	ld	s0,8(sp)
 88c:	0141                	addi	sp,sp,16
 88e:	8082                	ret

0000000000000890 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 890:	7139                	addi	sp,sp,-64
 892:	fc06                	sd	ra,56(sp)
 894:	f822                	sd	s0,48(sp)
 896:	f426                	sd	s1,40(sp)
 898:	ec4e                	sd	s3,24(sp)
 89a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89c:	02051493          	slli	s1,a0,0x20
 8a0:	9081                	srli	s1,s1,0x20
 8a2:	04bd                	addi	s1,s1,15
 8a4:	8091                	srli	s1,s1,0x4
 8a6:	0014899b          	addiw	s3,s1,1
 8aa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ac:	00000517          	auipc	a0,0x0
 8b0:	75453503          	ld	a0,1876(a0) # 1000 <freep>
 8b4:	c915                	beqz	a0,8e8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b8:	4798                	lw	a4,8(a5)
 8ba:	08977a63          	bgeu	a4,s1,94e <malloc+0xbe>
 8be:	f04a                	sd	s2,32(sp)
 8c0:	e852                	sd	s4,16(sp)
 8c2:	e456                	sd	s5,8(sp)
 8c4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8c6:	8a4e                	mv	s4,s3
 8c8:	0009871b          	sext.w	a4,s3
 8cc:	6685                	lui	a3,0x1
 8ce:	00d77363          	bgeu	a4,a3,8d4 <malloc+0x44>
 8d2:	6a05                	lui	s4,0x1
 8d4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8dc:	00000917          	auipc	s2,0x0
 8e0:	72490913          	addi	s2,s2,1828 # 1000 <freep>
  if(p == SBRK_ERROR)
 8e4:	5afd                	li	s5,-1
 8e6:	a081                	j	926 <malloc+0x96>
 8e8:	f04a                	sd	s2,32(sp)
 8ea:	e852                	sd	s4,16(sp)
 8ec:	e456                	sd	s5,8(sp)
 8ee:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8f0:	00000797          	auipc	a5,0x0
 8f4:	72078793          	addi	a5,a5,1824 # 1010 <base>
 8f8:	00000717          	auipc	a4,0x0
 8fc:	70f73423          	sd	a5,1800(a4) # 1000 <freep>
 900:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 902:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 906:	b7c1                	j	8c6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 908:	6398                	ld	a4,0(a5)
 90a:	e118                	sd	a4,0(a0)
 90c:	a8a9                	j	966 <malloc+0xd6>
  hp->s.size = nu;
 90e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 912:	0541                	addi	a0,a0,16
 914:	efbff0ef          	jal	80e <free>
  return freep;
 918:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 91c:	c12d                	beqz	a0,97e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 920:	4798                	lw	a4,8(a5)
 922:	02977263          	bgeu	a4,s1,946 <malloc+0xb6>
    if(p == freep)
 926:	00093703          	ld	a4,0(s2)
 92a:	853e                	mv	a0,a5
 92c:	fef719e3          	bne	a4,a5,91e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 930:	8552                	mv	a0,s4
 932:	a37ff0ef          	jal	368 <sbrk>
  if(p == SBRK_ERROR)
 936:	fd551ce3          	bne	a0,s5,90e <malloc+0x7e>
        return 0;
 93a:	4501                	li	a0,0
 93c:	7902                	ld	s2,32(sp)
 93e:	6a42                	ld	s4,16(sp)
 940:	6aa2                	ld	s5,8(sp)
 942:	6b02                	ld	s6,0(sp)
 944:	a03d                	j	972 <malloc+0xe2>
 946:	7902                	ld	s2,32(sp)
 948:	6a42                	ld	s4,16(sp)
 94a:	6aa2                	ld	s5,8(sp)
 94c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 94e:	fae48de3          	beq	s1,a4,908 <malloc+0x78>
        p->s.size -= nunits;
 952:	4137073b          	subw	a4,a4,s3
 956:	c798                	sw	a4,8(a5)
        p += p->s.size;
 958:	02071693          	slli	a3,a4,0x20
 95c:	01c6d713          	srli	a4,a3,0x1c
 960:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 962:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 966:	00000717          	auipc	a4,0x0
 96a:	68a73d23          	sd	a0,1690(a4) # 1000 <freep>
      return (void*)(p + 1);
 96e:	01078513          	addi	a0,a5,16
  }
}
 972:	70e2                	ld	ra,56(sp)
 974:	7442                	ld	s0,48(sp)
 976:	74a2                	ld	s1,40(sp)
 978:	69e2                	ld	s3,24(sp)
 97a:	6121                	addi	sp,sp,64
 97c:	8082                	ret
 97e:	7902                	ld	s2,32(sp)
 980:	6a42                	ld	s4,16(sp)
 982:	6aa2                	ld	s5,8(sp)
 984:	6b02                	ld	s6,0(sp)
 986:	b7f5                	j	972 <malloc+0xe2>
