
user/_test_child:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_read>:
#include "kernel/stat.h"
#include "user/user.h"
#include "user/filter.h"
#include "kernel/fcntl.h"

void test_read(char *name) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	e84a                	sd	s2,16(sp)
   8:	1800                	addi	s0,sp,48
   a:	892a                	mv	s2,a0
    int fd = open("README", O_RDONLY);
   c:	4581                	li	a1,0
   e:	00001517          	auipc	a0,0x1
  12:	99250513          	addi	a0,a0,-1646 # 9a0 <malloc+0x100>
  16:	3d6000ef          	jal	3ec <open>
    if(fd < 0){
  1a:	02054b63          	bltz	a0,50 <test_read+0x50>
  1e:	ec26                	sd	s1,24(sp)
  20:	84aa                	mv	s1,a0
        printf("%s: Khong the mo file README\n", name);
        return;
    }
    
    char buf[10];
    if(read(fd, buf, sizeof(buf)) < 0){
  22:	4629                	li	a2,10
  24:	fd040593          	addi	a1,s0,-48
  28:	39c000ef          	jal	3c4 <read>
  2c:	02054a63          	bltz	a0,60 <test_read+0x60>
        printf("%s: READ BI CHAN! (Thanh cong)\n", name);
    } else {
        printf("%s: READ BINH THUONG! (Chua bi chan)\n", name);
  30:	85ca                	mv	a1,s2
  32:	00001517          	auipc	a0,0x1
  36:	9be50513          	addi	a0,a0,-1602 # 9f0 <malloc+0x150>
  3a:	7b2000ef          	jal	7ec <printf>
    }
    close(fd);
  3e:	8526                	mv	a0,s1
  40:	394000ef          	jal	3d4 <close>
  44:	64e2                	ld	s1,24(sp)
}
  46:	70a2                	ld	ra,40(sp)
  48:	7402                	ld	s0,32(sp)
  4a:	6942                	ld	s2,16(sp)
  4c:	6145                	addi	sp,sp,48
  4e:	8082                	ret
        printf("%s: Khong the mo file README\n", name);
  50:	85ca                	mv	a1,s2
  52:	00001517          	auipc	a0,0x1
  56:	95e50513          	addi	a0,a0,-1698 # 9b0 <malloc+0x110>
  5a:	792000ef          	jal	7ec <printf>
        return;
  5e:	b7e5                	j	46 <test_read+0x46>
        printf("%s: READ BI CHAN! (Thanh cong)\n", name);
  60:	85ca                	mv	a1,s2
  62:	00001517          	auipc	a0,0x1
  66:	96e50513          	addi	a0,a0,-1682 # 9d0 <malloc+0x130>
  6a:	782000ef          	jal	7ec <printf>
  6e:	bfc1                	j	3e <test_read+0x3e>

0000000000000070 <main>:

int main() {
  70:	1141                	addi	sp,sp,-16
  72:	e406                	sd	ra,8(sp)
  74:	e022                	sd	s0,0(sp)
  76:	0800                	addi	s0,sp,16
    printf("--- BAT DAU TEST SETFILTER_CHILD ---\n");
  78:	00001517          	auipc	a0,0x1
  7c:	9a050513          	addi	a0,a0,-1632 # a18 <malloc+0x178>
  80:	76c000ef          	jal	7ec <printf>

    // 1. Cha thiet lap luat: "Cac con cua ta sau nay khong duoc phep READ"
    if(setfilter_child(FILTER_READ) < 0){
  84:	02000513          	li	a0,32
  88:	3d4000ef          	jal	45c <setfilter_child>
  8c:	04054863          	bltz	a0,dc <main+0x6c>
        printf("Loi: Khong the goi setfilter_child\n");
        exit(1);
    }
    printf("Cha: Da dat luat cam READ cho cac con.\n");
  90:	00001517          	auipc	a0,0x1
  94:	9d850513          	addi	a0,a0,-1576 # a68 <malloc+0x1c8>
  98:	754000ef          	jal	7ec <printf>

    // 2. Cha tu kiem tra xem minh co bi anh huong khong
    printf("Cha: Dang thu doc file...\n");
  9c:	00001517          	auipc	a0,0x1
  a0:	9f450513          	addi	a0,a0,-1548 # a90 <malloc+0x1f0>
  a4:	748000ef          	jal	7ec <printf>
    test_read("Cha");
  a8:	00001517          	auipc	a0,0x1
  ac:	a0850513          	addi	a0,a0,-1528 # ab0 <malloc+0x210>
  b0:	f51ff0ef          	jal	0 <test_read>

    // 3. Tao tien trinh con
    int pid = fork();
  b4:	2f0000ef          	jal	3a4 <fork>

    if(pid < 0){
  b8:	02054b63          	bltz	a0,ee <main+0x7e>
        printf("Loi fork\n");
        exit(1);
    }

    if(pid == 0){
  bc:	e131                	bnez	a0,100 <main+0x90>
        // Tien trinh con
        printf("\nCon: Dang thu doc file (dang le phai bi chan)...\n");
  be:	00001517          	auipc	a0,0x1
  c2:	a0a50513          	addi	a0,a0,-1526 # ac8 <malloc+0x228>
  c6:	726000ef          	jal	7ec <printf>
        test_read("Con");
  ca:	00001517          	auipc	a0,0x1
  ce:	a3650513          	addi	a0,a0,-1482 # b00 <malloc+0x260>
  d2:	f2fff0ef          	jal	0 <test_read>
        exit(0);
  d6:	4501                	li	a0,0
  d8:	2d4000ef          	jal	3ac <exit>
        printf("Loi: Khong the goi setfilter_child\n");
  dc:	00001517          	auipc	a0,0x1
  e0:	96450513          	addi	a0,a0,-1692 # a40 <malloc+0x1a0>
  e4:	708000ef          	jal	7ec <printf>
        exit(1);
  e8:	4505                	li	a0,1
  ea:	2c2000ef          	jal	3ac <exit>
        printf("Loi fork\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	9ca50513          	addi	a0,a0,-1590 # ab8 <malloc+0x218>
  f6:	6f6000ef          	jal	7ec <printf>
        exit(1);
  fa:	4505                	li	a0,1
  fc:	2b0000ef          	jal	3ac <exit>
    } else {
        // Tien trinh cha doi con thuc hien xong
        wait(0);
 100:	4501                	li	a0,0
 102:	2b2000ef          	jal	3b4 <wait>
        printf("\n--- KET THUC TEST ---\n");
 106:	00001517          	auipc	a0,0x1
 10a:	a0250513          	addi	a0,a0,-1534 # b08 <malloc+0x268>
 10e:	6de000ef          	jal	7ec <printf>
    }

    exit(0);
 112:	4501                	li	a0,0
 114:	298000ef          	jal	3ac <exit>

0000000000000118 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e406                	sd	ra,8(sp)
 11c:	e022                	sd	s0,0(sp)
 11e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 120:	f51ff0ef          	jal	70 <main>
  exit(r);
 124:	288000ef          	jal	3ac <exit>

0000000000000128 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 128:	1141                	addi	sp,sp,-16
 12a:	e422                	sd	s0,8(sp)
 12c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 12e:	87aa                	mv	a5,a0
 130:	0585                	addi	a1,a1,1
 132:	0785                	addi	a5,a5,1
 134:	fff5c703          	lbu	a4,-1(a1)
 138:	fee78fa3          	sb	a4,-1(a5)
 13c:	fb75                	bnez	a4,130 <strcpy+0x8>
    ;
  return os;
}
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret

0000000000000144 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 144:	1141                	addi	sp,sp,-16
 146:	e422                	sd	s0,8(sp)
 148:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	cb91                	beqz	a5,162 <strcmp+0x1e>
 150:	0005c703          	lbu	a4,0(a1)
 154:	00f71763          	bne	a4,a5,162 <strcmp+0x1e>
    p++, q++;
 158:	0505                	addi	a0,a0,1
 15a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 15c:	00054783          	lbu	a5,0(a0)
 160:	fbe5                	bnez	a5,150 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 162:	0005c503          	lbu	a0,0(a1)
}
 166:	40a7853b          	subw	a0,a5,a0
 16a:	6422                	ld	s0,8(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret

0000000000000170 <strlen>:

uint
strlen(const char *s)
{
 170:	1141                	addi	sp,sp,-16
 172:	e422                	sd	s0,8(sp)
 174:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 176:	00054783          	lbu	a5,0(a0)
 17a:	cf91                	beqz	a5,196 <strlen+0x26>
 17c:	0505                	addi	a0,a0,1
 17e:	87aa                	mv	a5,a0
 180:	86be                	mv	a3,a5
 182:	0785                	addi	a5,a5,1
 184:	fff7c703          	lbu	a4,-1(a5)
 188:	ff65                	bnez	a4,180 <strlen+0x10>
 18a:	40a6853b          	subw	a0,a3,a0
 18e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 190:	6422                	ld	s0,8(sp)
 192:	0141                	addi	sp,sp,16
 194:	8082                	ret
  for(n = 0; s[n]; n++)
 196:	4501                	li	a0,0
 198:	bfe5                	j	190 <strlen+0x20>

000000000000019a <memset>:

void*
memset(void *dst, int c, uint n)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e422                	sd	s0,8(sp)
 19e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1a0:	ca19                	beqz	a2,1b6 <memset+0x1c>
 1a2:	87aa                	mv	a5,a0
 1a4:	1602                	slli	a2,a2,0x20
 1a6:	9201                	srli	a2,a2,0x20
 1a8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ac:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1b0:	0785                	addi	a5,a5,1
 1b2:	fee79de3          	bne	a5,a4,1ac <memset+0x12>
  }
  return dst;
}
 1b6:	6422                	ld	s0,8(sp)
 1b8:	0141                	addi	sp,sp,16
 1ba:	8082                	ret

00000000000001bc <strchr>:

char*
strchr(const char *s, char c)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e422                	sd	s0,8(sp)
 1c0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1c2:	00054783          	lbu	a5,0(a0)
 1c6:	cb99                	beqz	a5,1dc <strchr+0x20>
    if(*s == c)
 1c8:	00f58763          	beq	a1,a5,1d6 <strchr+0x1a>
  for(; *s; s++)
 1cc:	0505                	addi	a0,a0,1
 1ce:	00054783          	lbu	a5,0(a0)
 1d2:	fbfd                	bnez	a5,1c8 <strchr+0xc>
      return (char*)s;
  return 0;
 1d4:	4501                	li	a0,0
}
 1d6:	6422                	ld	s0,8(sp)
 1d8:	0141                	addi	sp,sp,16
 1da:	8082                	ret
  return 0;
 1dc:	4501                	li	a0,0
 1de:	bfe5                	j	1d6 <strchr+0x1a>

00000000000001e0 <gets>:

char*
gets(char *buf, int max)
{
 1e0:	711d                	addi	sp,sp,-96
 1e2:	ec86                	sd	ra,88(sp)
 1e4:	e8a2                	sd	s0,80(sp)
 1e6:	e4a6                	sd	s1,72(sp)
 1e8:	e0ca                	sd	s2,64(sp)
 1ea:	fc4e                	sd	s3,56(sp)
 1ec:	f852                	sd	s4,48(sp)
 1ee:	f456                	sd	s5,40(sp)
 1f0:	f05a                	sd	s6,32(sp)
 1f2:	ec5e                	sd	s7,24(sp)
 1f4:	1080                	addi	s0,sp,96
 1f6:	8baa                	mv	s7,a0
 1f8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fa:	892a                	mv	s2,a0
 1fc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1fe:	4aa9                	li	s5,10
 200:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 202:	89a6                	mv	s3,s1
 204:	2485                	addiw	s1,s1,1
 206:	0344d663          	bge	s1,s4,232 <gets+0x52>
    cc = read(0, &c, 1);
 20a:	4605                	li	a2,1
 20c:	faf40593          	addi	a1,s0,-81
 210:	4501                	li	a0,0
 212:	1b2000ef          	jal	3c4 <read>
    if(cc < 1)
 216:	00a05e63          	blez	a0,232 <gets+0x52>
    buf[i++] = c;
 21a:	faf44783          	lbu	a5,-81(s0)
 21e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 222:	01578763          	beq	a5,s5,230 <gets+0x50>
 226:	0905                	addi	s2,s2,1
 228:	fd679de3          	bne	a5,s6,202 <gets+0x22>
    buf[i++] = c;
 22c:	89a6                	mv	s3,s1
 22e:	a011                	j	232 <gets+0x52>
 230:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 232:	99de                	add	s3,s3,s7
 234:	00098023          	sb	zero,0(s3)
  return buf;
}
 238:	855e                	mv	a0,s7
 23a:	60e6                	ld	ra,88(sp)
 23c:	6446                	ld	s0,80(sp)
 23e:	64a6                	ld	s1,72(sp)
 240:	6906                	ld	s2,64(sp)
 242:	79e2                	ld	s3,56(sp)
 244:	7a42                	ld	s4,48(sp)
 246:	7aa2                	ld	s5,40(sp)
 248:	7b02                	ld	s6,32(sp)
 24a:	6be2                	ld	s7,24(sp)
 24c:	6125                	addi	sp,sp,96
 24e:	8082                	ret

0000000000000250 <stat>:

int
stat(const char *n, struct stat *st)
{
 250:	1101                	addi	sp,sp,-32
 252:	ec06                	sd	ra,24(sp)
 254:	e822                	sd	s0,16(sp)
 256:	e04a                	sd	s2,0(sp)
 258:	1000                	addi	s0,sp,32
 25a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25c:	4581                	li	a1,0
 25e:	18e000ef          	jal	3ec <open>
  if(fd < 0)
 262:	02054263          	bltz	a0,286 <stat+0x36>
 266:	e426                	sd	s1,8(sp)
 268:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 26a:	85ca                	mv	a1,s2
 26c:	198000ef          	jal	404 <fstat>
 270:	892a                	mv	s2,a0
  close(fd);
 272:	8526                	mv	a0,s1
 274:	160000ef          	jal	3d4 <close>
  return r;
 278:	64a2                	ld	s1,8(sp)
}
 27a:	854a                	mv	a0,s2
 27c:	60e2                	ld	ra,24(sp)
 27e:	6442                	ld	s0,16(sp)
 280:	6902                	ld	s2,0(sp)
 282:	6105                	addi	sp,sp,32
 284:	8082                	ret
    return -1;
 286:	597d                	li	s2,-1
 288:	bfcd                	j	27a <stat+0x2a>

000000000000028a <atoi>:

int
atoi(const char *s)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 290:	00054683          	lbu	a3,0(a0)
 294:	fd06879b          	addiw	a5,a3,-48
 298:	0ff7f793          	zext.b	a5,a5
 29c:	4625                	li	a2,9
 29e:	02f66863          	bltu	a2,a5,2ce <atoi+0x44>
 2a2:	872a                	mv	a4,a0
  n = 0;
 2a4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a6:	0705                	addi	a4,a4,1
 2a8:	0025179b          	slliw	a5,a0,0x2
 2ac:	9fa9                	addw	a5,a5,a0
 2ae:	0017979b          	slliw	a5,a5,0x1
 2b2:	9fb5                	addw	a5,a5,a3
 2b4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b8:	00074683          	lbu	a3,0(a4)
 2bc:	fd06879b          	addiw	a5,a3,-48
 2c0:	0ff7f793          	zext.b	a5,a5
 2c4:	fef671e3          	bgeu	a2,a5,2a6 <atoi+0x1c>
  return n;
}
 2c8:	6422                	ld	s0,8(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
  n = 0;
 2ce:	4501                	li	a0,0
 2d0:	bfe5                	j	2c8 <atoi+0x3e>

00000000000002d2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d8:	02b57463          	bgeu	a0,a1,300 <memmove+0x2e>
    while(n-- > 0)
 2dc:	00c05f63          	blez	a2,2fa <memmove+0x28>
 2e0:	1602                	slli	a2,a2,0x20
 2e2:	9201                	srli	a2,a2,0x20
 2e4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2e8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ea:	0585                	addi	a1,a1,1
 2ec:	0705                	addi	a4,a4,1
 2ee:	fff5c683          	lbu	a3,-1(a1)
 2f2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f6:	fef71ae3          	bne	a4,a5,2ea <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2fa:	6422                	ld	s0,8(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret
    dst += n;
 300:	00c50733          	add	a4,a0,a2
    src += n;
 304:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 306:	fec05ae3          	blez	a2,2fa <memmove+0x28>
 30a:	fff6079b          	addiw	a5,a2,-1
 30e:	1782                	slli	a5,a5,0x20
 310:	9381                	srli	a5,a5,0x20
 312:	fff7c793          	not	a5,a5
 316:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 318:	15fd                	addi	a1,a1,-1
 31a:	177d                	addi	a4,a4,-1
 31c:	0005c683          	lbu	a3,0(a1)
 320:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 324:	fee79ae3          	bne	a5,a4,318 <memmove+0x46>
 328:	bfc9                	j	2fa <memmove+0x28>

000000000000032a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e422                	sd	s0,8(sp)
 32e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 330:	ca05                	beqz	a2,360 <memcmp+0x36>
 332:	fff6069b          	addiw	a3,a2,-1
 336:	1682                	slli	a3,a3,0x20
 338:	9281                	srli	a3,a3,0x20
 33a:	0685                	addi	a3,a3,1
 33c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 33e:	00054783          	lbu	a5,0(a0)
 342:	0005c703          	lbu	a4,0(a1)
 346:	00e79863          	bne	a5,a4,356 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 34a:	0505                	addi	a0,a0,1
    p2++;
 34c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 34e:	fed518e3          	bne	a0,a3,33e <memcmp+0x14>
  }
  return 0;
 352:	4501                	li	a0,0
 354:	a019                	j	35a <memcmp+0x30>
      return *p1 - *p2;
 356:	40e7853b          	subw	a0,a5,a4
}
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret
  return 0;
 360:	4501                	li	a0,0
 362:	bfe5                	j	35a <memcmp+0x30>

0000000000000364 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 364:	1141                	addi	sp,sp,-16
 366:	e406                	sd	ra,8(sp)
 368:	e022                	sd	s0,0(sp)
 36a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 36c:	f67ff0ef          	jal	2d2 <memmove>
}
 370:	60a2                	ld	ra,8(sp)
 372:	6402                	ld	s0,0(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret

0000000000000378 <sbrk>:

char *
sbrk(int n) {
 378:	1141                	addi	sp,sp,-16
 37a:	e406                	sd	ra,8(sp)
 37c:	e022                	sd	s0,0(sp)
 37e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 380:	4585                	li	a1,1
 382:	0b2000ef          	jal	434 <sys_sbrk>
}
 386:	60a2                	ld	ra,8(sp)
 388:	6402                	ld	s0,0(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret

000000000000038e <sbrklazy>:

char *
sbrklazy(int n) {
 38e:	1141                	addi	sp,sp,-16
 390:	e406                	sd	ra,8(sp)
 392:	e022                	sd	s0,0(sp)
 394:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 396:	4589                	li	a1,2
 398:	09c000ef          	jal	434 <sys_sbrk>
}
 39c:	60a2                	ld	ra,8(sp)
 39e:	6402                	ld	s0,0(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret

00000000000003a4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3a4:	4885                	li	a7,1
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ac:	4889                	li	a7,2
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3b4:	488d                	li	a7,3
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3bc:	4891                	li	a7,4
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <read>:
.global read
read:
 li a7, SYS_read
 3c4:	4895                	li	a7,5
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <write>:
.global write
write:
 li a7, SYS_write
 3cc:	48c1                	li	a7,16
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <close>:
.global close
close:
 li a7, SYS_close
 3d4:	48d5                	li	a7,21
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3dc:	4899                	li	a7,6
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3e4:	489d                	li	a7,7
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <open>:
.global open
open:
 li a7, SYS_open
 3ec:	48bd                	li	a7,15
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3f4:	48c5                	li	a7,17
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3fc:	48c9                	li	a7,18
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 404:	48a1                	li	a7,8
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <link>:
.global link
link:
 li a7, SYS_link
 40c:	48cd                	li	a7,19
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 414:	48d1                	li	a7,20
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 41c:	48a5                	li	a7,9
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <dup>:
.global dup
dup:
 li a7, SYS_dup
 424:	48a9                	li	a7,10
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 42c:	48ad                	li	a7,11
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 434:	48b1                	li	a7,12
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <pause>:
.global pause
pause:
 li a7, SYS_pause
 43c:	48b5                	li	a7,13
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 444:	48b9                	li	a7,14
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <setfilter>:
.global setfilter
setfilter:
 li a7, SYS_setfilter
 44c:	48dd                	li	a7,23
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <getfilter>:
.global getfilter
getfilter:
 li a7, SYS_getfilter
 454:	48e1                	li	a7,24
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <setfilter_child>:
.global setfilter_child
setfilter_child:
 li a7, SYS_setfilter_child
 45c:	48e5                	li	a7,25
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 464:	1101                	addi	sp,sp,-32
 466:	ec06                	sd	ra,24(sp)
 468:	e822                	sd	s0,16(sp)
 46a:	1000                	addi	s0,sp,32
 46c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 470:	4605                	li	a2,1
 472:	fef40593          	addi	a1,s0,-17
 476:	f57ff0ef          	jal	3cc <write>
}
 47a:	60e2                	ld	ra,24(sp)
 47c:	6442                	ld	s0,16(sp)
 47e:	6105                	addi	sp,sp,32
 480:	8082                	ret

0000000000000482 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 482:	715d                	addi	sp,sp,-80
 484:	e486                	sd	ra,72(sp)
 486:	e0a2                	sd	s0,64(sp)
 488:	f84a                	sd	s2,48(sp)
 48a:	0880                	addi	s0,sp,80
 48c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 48e:	c299                	beqz	a3,494 <printint+0x12>
 490:	0805c363          	bltz	a1,516 <printint+0x94>
  neg = 0;
 494:	4881                	li	a7,0
 496:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 49a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 49c:	00000517          	auipc	a0,0x0
 4a0:	68c50513          	addi	a0,a0,1676 # b28 <digits>
 4a4:	883e                	mv	a6,a5
 4a6:	2785                	addiw	a5,a5,1
 4a8:	02c5f733          	remu	a4,a1,a2
 4ac:	972a                	add	a4,a4,a0
 4ae:	00074703          	lbu	a4,0(a4)
 4b2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4b6:	872e                	mv	a4,a1
 4b8:	02c5d5b3          	divu	a1,a1,a2
 4bc:	0685                	addi	a3,a3,1
 4be:	fec773e3          	bgeu	a4,a2,4a4 <printint+0x22>
  if(neg)
 4c2:	00088b63          	beqz	a7,4d8 <printint+0x56>
    buf[i++] = '-';
 4c6:	fd078793          	addi	a5,a5,-48
 4ca:	97a2                	add	a5,a5,s0
 4cc:	02d00713          	li	a4,45
 4d0:	fee78423          	sb	a4,-24(a5)
 4d4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4d8:	02f05a63          	blez	a5,50c <printint+0x8a>
 4dc:	fc26                	sd	s1,56(sp)
 4de:	f44e                	sd	s3,40(sp)
 4e0:	fb840713          	addi	a4,s0,-72
 4e4:	00f704b3          	add	s1,a4,a5
 4e8:	fff70993          	addi	s3,a4,-1
 4ec:	99be                	add	s3,s3,a5
 4ee:	37fd                	addiw	a5,a5,-1
 4f0:	1782                	slli	a5,a5,0x20
 4f2:	9381                	srli	a5,a5,0x20
 4f4:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4f8:	fff4c583          	lbu	a1,-1(s1)
 4fc:	854a                	mv	a0,s2
 4fe:	f67ff0ef          	jal	464 <putc>
  while(--i >= 0)
 502:	14fd                	addi	s1,s1,-1
 504:	ff349ae3          	bne	s1,s3,4f8 <printint+0x76>
 508:	74e2                	ld	s1,56(sp)
 50a:	79a2                	ld	s3,40(sp)
}
 50c:	60a6                	ld	ra,72(sp)
 50e:	6406                	ld	s0,64(sp)
 510:	7942                	ld	s2,48(sp)
 512:	6161                	addi	sp,sp,80
 514:	8082                	ret
    x = -xx;
 516:	40b005b3          	neg	a1,a1
    neg = 1;
 51a:	4885                	li	a7,1
    x = -xx;
 51c:	bfad                	j	496 <printint+0x14>

000000000000051e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 51e:	711d                	addi	sp,sp,-96
 520:	ec86                	sd	ra,88(sp)
 522:	e8a2                	sd	s0,80(sp)
 524:	e0ca                	sd	s2,64(sp)
 526:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 528:	0005c903          	lbu	s2,0(a1)
 52c:	28090663          	beqz	s2,7b8 <vprintf+0x29a>
 530:	e4a6                	sd	s1,72(sp)
 532:	fc4e                	sd	s3,56(sp)
 534:	f852                	sd	s4,48(sp)
 536:	f456                	sd	s5,40(sp)
 538:	f05a                	sd	s6,32(sp)
 53a:	ec5e                	sd	s7,24(sp)
 53c:	e862                	sd	s8,16(sp)
 53e:	e466                	sd	s9,8(sp)
 540:	8b2a                	mv	s6,a0
 542:	8a2e                	mv	s4,a1
 544:	8bb2                	mv	s7,a2
  state = 0;
 546:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 548:	4481                	li	s1,0
 54a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 54c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 550:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 554:	06c00c93          	li	s9,108
 558:	a005                	j	578 <vprintf+0x5a>
        putc(fd, c0);
 55a:	85ca                	mv	a1,s2
 55c:	855a                	mv	a0,s6
 55e:	f07ff0ef          	jal	464 <putc>
 562:	a019                	j	568 <vprintf+0x4a>
    } else if(state == '%'){
 564:	03598263          	beq	s3,s5,588 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 568:	2485                	addiw	s1,s1,1
 56a:	8726                	mv	a4,s1
 56c:	009a07b3          	add	a5,s4,s1
 570:	0007c903          	lbu	s2,0(a5)
 574:	22090a63          	beqz	s2,7a8 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 578:	0009079b          	sext.w	a5,s2
    if(state == 0){
 57c:	fe0994e3          	bnez	s3,564 <vprintf+0x46>
      if(c0 == '%'){
 580:	fd579de3          	bne	a5,s5,55a <vprintf+0x3c>
        state = '%';
 584:	89be                	mv	s3,a5
 586:	b7cd                	j	568 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 588:	00ea06b3          	add	a3,s4,a4
 58c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 590:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 592:	c681                	beqz	a3,59a <vprintf+0x7c>
 594:	9752                	add	a4,a4,s4
 596:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 59a:	05878363          	beq	a5,s8,5e0 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 59e:	05978d63          	beq	a5,s9,5f8 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5a2:	07500713          	li	a4,117
 5a6:	0ee78763          	beq	a5,a4,694 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5aa:	07800713          	li	a4,120
 5ae:	12e78963          	beq	a5,a4,6e0 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5b2:	07000713          	li	a4,112
 5b6:	14e78e63          	beq	a5,a4,712 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5ba:	06300713          	li	a4,99
 5be:	18e78e63          	beq	a5,a4,75a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5c2:	07300713          	li	a4,115
 5c6:	1ae78463          	beq	a5,a4,76e <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5ca:	02500713          	li	a4,37
 5ce:	04e79563          	bne	a5,a4,618 <vprintf+0xfa>
        putc(fd, '%');
 5d2:	02500593          	li	a1,37
 5d6:	855a                	mv	a0,s6
 5d8:	e8dff0ef          	jal	464 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5dc:	4981                	li	s3,0
 5de:	b769                	j	568 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5e0:	008b8913          	addi	s2,s7,8
 5e4:	4685                	li	a3,1
 5e6:	4629                	li	a2,10
 5e8:	000ba583          	lw	a1,0(s7)
 5ec:	855a                	mv	a0,s6
 5ee:	e95ff0ef          	jal	482 <printint>
 5f2:	8bca                	mv	s7,s2
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	bf8d                	j	568 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5f8:	06400793          	li	a5,100
 5fc:	02f68963          	beq	a3,a5,62e <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 600:	06c00793          	li	a5,108
 604:	04f68263          	beq	a3,a5,648 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 608:	07500793          	li	a5,117
 60c:	0af68063          	beq	a3,a5,6ac <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 610:	07800793          	li	a5,120
 614:	0ef68263          	beq	a3,a5,6f8 <vprintf+0x1da>
        putc(fd, '%');
 618:	02500593          	li	a1,37
 61c:	855a                	mv	a0,s6
 61e:	e47ff0ef          	jal	464 <putc>
        putc(fd, c0);
 622:	85ca                	mv	a1,s2
 624:	855a                	mv	a0,s6
 626:	e3fff0ef          	jal	464 <putc>
      state = 0;
 62a:	4981                	li	s3,0
 62c:	bf35                	j	568 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 62e:	008b8913          	addi	s2,s7,8
 632:	4685                	li	a3,1
 634:	4629                	li	a2,10
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	e47ff0ef          	jal	482 <printint>
        i += 1;
 640:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 1;
 646:	b70d                	j	568 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 648:	06400793          	li	a5,100
 64c:	02f60763          	beq	a2,a5,67a <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 650:	07500793          	li	a5,117
 654:	06f60963          	beq	a2,a5,6c6 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 658:	07800793          	li	a5,120
 65c:	faf61ee3          	bne	a2,a5,618 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 660:	008b8913          	addi	s2,s7,8
 664:	4681                	li	a3,0
 666:	4641                	li	a2,16
 668:	000bb583          	ld	a1,0(s7)
 66c:	855a                	mv	a0,s6
 66e:	e15ff0ef          	jal	482 <printint>
        i += 2;
 672:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
        i += 2;
 678:	bdc5                	j	568 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4685                	li	a3,1
 680:	4629                	li	a2,10
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	dfbff0ef          	jal	482 <printint>
        i += 2;
 68c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 2;
 692:	bdd9                	j	568 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 694:	008b8913          	addi	s2,s7,8
 698:	4681                	li	a3,0
 69a:	4629                	li	a2,10
 69c:	000be583          	lwu	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	de1ff0ef          	jal	482 <printint>
 6a6:	8bca                	mv	s7,s2
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	bd7d                	j	568 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	4681                	li	a3,0
 6b2:	4629                	li	a2,10
 6b4:	000bb583          	ld	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	dc9ff0ef          	jal	482 <printint>
        i += 1;
 6be:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
        i += 1;
 6c4:	b555                	j	568 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c6:	008b8913          	addi	s2,s7,8
 6ca:	4681                	li	a3,0
 6cc:	4629                	li	a2,10
 6ce:	000bb583          	ld	a1,0(s7)
 6d2:	855a                	mv	a0,s6
 6d4:	dafff0ef          	jal	482 <printint>
        i += 2;
 6d8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
        i += 2;
 6de:	b569                	j	568 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6e0:	008b8913          	addi	s2,s7,8
 6e4:	4681                	li	a3,0
 6e6:	4641                	li	a2,16
 6e8:	000be583          	lwu	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	d95ff0ef          	jal	482 <printint>
 6f2:	8bca                	mv	s7,s2
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	bd8d                	j	568 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f8:	008b8913          	addi	s2,s7,8
 6fc:	4681                	li	a3,0
 6fe:	4641                	li	a2,16
 700:	000bb583          	ld	a1,0(s7)
 704:	855a                	mv	a0,s6
 706:	d7dff0ef          	jal	482 <printint>
        i += 1;
 70a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 70c:	8bca                	mv	s7,s2
      state = 0;
 70e:	4981                	li	s3,0
        i += 1;
 710:	bda1                	j	568 <vprintf+0x4a>
 712:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 714:	008b8d13          	addi	s10,s7,8
 718:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 71c:	03000593          	li	a1,48
 720:	855a                	mv	a0,s6
 722:	d43ff0ef          	jal	464 <putc>
  putc(fd, 'x');
 726:	07800593          	li	a1,120
 72a:	855a                	mv	a0,s6
 72c:	d39ff0ef          	jal	464 <putc>
 730:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 732:	00000b97          	auipc	s7,0x0
 736:	3f6b8b93          	addi	s7,s7,1014 # b28 <digits>
 73a:	03c9d793          	srli	a5,s3,0x3c
 73e:	97de                	add	a5,a5,s7
 740:	0007c583          	lbu	a1,0(a5)
 744:	855a                	mv	a0,s6
 746:	d1fff0ef          	jal	464 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 74a:	0992                	slli	s3,s3,0x4
 74c:	397d                	addiw	s2,s2,-1
 74e:	fe0916e3          	bnez	s2,73a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 752:	8bea                	mv	s7,s10
      state = 0;
 754:	4981                	li	s3,0
 756:	6d02                	ld	s10,0(sp)
 758:	bd01                	j	568 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 75a:	008b8913          	addi	s2,s7,8
 75e:	000bc583          	lbu	a1,0(s7)
 762:	855a                	mv	a0,s6
 764:	d01ff0ef          	jal	464 <putc>
 768:	8bca                	mv	s7,s2
      state = 0;
 76a:	4981                	li	s3,0
 76c:	bbf5                	j	568 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 76e:	008b8993          	addi	s3,s7,8
 772:	000bb903          	ld	s2,0(s7)
 776:	00090f63          	beqz	s2,794 <vprintf+0x276>
        for(; *s; s++)
 77a:	00094583          	lbu	a1,0(s2)
 77e:	c195                	beqz	a1,7a2 <vprintf+0x284>
          putc(fd, *s);
 780:	855a                	mv	a0,s6
 782:	ce3ff0ef          	jal	464 <putc>
        for(; *s; s++)
 786:	0905                	addi	s2,s2,1
 788:	00094583          	lbu	a1,0(s2)
 78c:	f9f5                	bnez	a1,780 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 78e:	8bce                	mv	s7,s3
      state = 0;
 790:	4981                	li	s3,0
 792:	bbd9                	j	568 <vprintf+0x4a>
          s = "(null)";
 794:	00000917          	auipc	s2,0x0
 798:	38c90913          	addi	s2,s2,908 # b20 <malloc+0x280>
        for(; *s; s++)
 79c:	02800593          	li	a1,40
 7a0:	b7c5                	j	780 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7a2:	8bce                	mv	s7,s3
      state = 0;
 7a4:	4981                	li	s3,0
 7a6:	b3c9                	j	568 <vprintf+0x4a>
 7a8:	64a6                	ld	s1,72(sp)
 7aa:	79e2                	ld	s3,56(sp)
 7ac:	7a42                	ld	s4,48(sp)
 7ae:	7aa2                	ld	s5,40(sp)
 7b0:	7b02                	ld	s6,32(sp)
 7b2:	6be2                	ld	s7,24(sp)
 7b4:	6c42                	ld	s8,16(sp)
 7b6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7b8:	60e6                	ld	ra,88(sp)
 7ba:	6446                	ld	s0,80(sp)
 7bc:	6906                	ld	s2,64(sp)
 7be:	6125                	addi	sp,sp,96
 7c0:	8082                	ret

00000000000007c2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7c2:	715d                	addi	sp,sp,-80
 7c4:	ec06                	sd	ra,24(sp)
 7c6:	e822                	sd	s0,16(sp)
 7c8:	1000                	addi	s0,sp,32
 7ca:	e010                	sd	a2,0(s0)
 7cc:	e414                	sd	a3,8(s0)
 7ce:	e818                	sd	a4,16(s0)
 7d0:	ec1c                	sd	a5,24(s0)
 7d2:	03043023          	sd	a6,32(s0)
 7d6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7da:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7de:	8622                	mv	a2,s0
 7e0:	d3fff0ef          	jal	51e <vprintf>
}
 7e4:	60e2                	ld	ra,24(sp)
 7e6:	6442                	ld	s0,16(sp)
 7e8:	6161                	addi	sp,sp,80
 7ea:	8082                	ret

00000000000007ec <printf>:

void
printf(const char *fmt, ...)
{
 7ec:	711d                	addi	sp,sp,-96
 7ee:	ec06                	sd	ra,24(sp)
 7f0:	e822                	sd	s0,16(sp)
 7f2:	1000                	addi	s0,sp,32
 7f4:	e40c                	sd	a1,8(s0)
 7f6:	e810                	sd	a2,16(s0)
 7f8:	ec14                	sd	a3,24(s0)
 7fa:	f018                	sd	a4,32(s0)
 7fc:	f41c                	sd	a5,40(s0)
 7fe:	03043823          	sd	a6,48(s0)
 802:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 806:	00840613          	addi	a2,s0,8
 80a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 80e:	85aa                	mv	a1,a0
 810:	4505                	li	a0,1
 812:	d0dff0ef          	jal	51e <vprintf>
}
 816:	60e2                	ld	ra,24(sp)
 818:	6442                	ld	s0,16(sp)
 81a:	6125                	addi	sp,sp,96
 81c:	8082                	ret

000000000000081e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81e:	1141                	addi	sp,sp,-16
 820:	e422                	sd	s0,8(sp)
 822:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 824:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	00000797          	auipc	a5,0x0
 82c:	7d87b783          	ld	a5,2008(a5) # 1000 <freep>
 830:	a02d                	j	85a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 832:	4618                	lw	a4,8(a2)
 834:	9f2d                	addw	a4,a4,a1
 836:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 83a:	6398                	ld	a4,0(a5)
 83c:	6310                	ld	a2,0(a4)
 83e:	a83d                	j	87c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 840:	ff852703          	lw	a4,-8(a0)
 844:	9f31                	addw	a4,a4,a2
 846:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 848:	ff053683          	ld	a3,-16(a0)
 84c:	a091                	j	890 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84e:	6398                	ld	a4,0(a5)
 850:	00e7e463          	bltu	a5,a4,858 <free+0x3a>
 854:	00e6ea63          	bltu	a3,a4,868 <free+0x4a>
{
 858:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85a:	fed7fae3          	bgeu	a5,a3,84e <free+0x30>
 85e:	6398                	ld	a4,0(a5)
 860:	00e6e463          	bltu	a3,a4,868 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 864:	fee7eae3          	bltu	a5,a4,858 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 868:	ff852583          	lw	a1,-8(a0)
 86c:	6390                	ld	a2,0(a5)
 86e:	02059813          	slli	a6,a1,0x20
 872:	01c85713          	srli	a4,a6,0x1c
 876:	9736                	add	a4,a4,a3
 878:	fae60de3          	beq	a2,a4,832 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 87c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 880:	4790                	lw	a2,8(a5)
 882:	02061593          	slli	a1,a2,0x20
 886:	01c5d713          	srli	a4,a1,0x1c
 88a:	973e                	add	a4,a4,a5
 88c:	fae68ae3          	beq	a3,a4,840 <free+0x22>
    p->s.ptr = bp->s.ptr;
 890:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 892:	00000717          	auipc	a4,0x0
 896:	76f73723          	sd	a5,1902(a4) # 1000 <freep>
}
 89a:	6422                	ld	s0,8(sp)
 89c:	0141                	addi	sp,sp,16
 89e:	8082                	ret

00000000000008a0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a0:	7139                	addi	sp,sp,-64
 8a2:	fc06                	sd	ra,56(sp)
 8a4:	f822                	sd	s0,48(sp)
 8a6:	f426                	sd	s1,40(sp)
 8a8:	ec4e                	sd	s3,24(sp)
 8aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ac:	02051493          	slli	s1,a0,0x20
 8b0:	9081                	srli	s1,s1,0x20
 8b2:	04bd                	addi	s1,s1,15
 8b4:	8091                	srli	s1,s1,0x4
 8b6:	0014899b          	addiw	s3,s1,1
 8ba:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8bc:	00000517          	auipc	a0,0x0
 8c0:	74453503          	ld	a0,1860(a0) # 1000 <freep>
 8c4:	c915                	beqz	a0,8f8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c8:	4798                	lw	a4,8(a5)
 8ca:	08977a63          	bgeu	a4,s1,95e <malloc+0xbe>
 8ce:	f04a                	sd	s2,32(sp)
 8d0:	e852                	sd	s4,16(sp)
 8d2:	e456                	sd	s5,8(sp)
 8d4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8d6:	8a4e                	mv	s4,s3
 8d8:	0009871b          	sext.w	a4,s3
 8dc:	6685                	lui	a3,0x1
 8de:	00d77363          	bgeu	a4,a3,8e4 <malloc+0x44>
 8e2:	6a05                	lui	s4,0x1
 8e4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ec:	00000917          	auipc	s2,0x0
 8f0:	71490913          	addi	s2,s2,1812 # 1000 <freep>
  if(p == SBRK_ERROR)
 8f4:	5afd                	li	s5,-1
 8f6:	a081                	j	936 <malloc+0x96>
 8f8:	f04a                	sd	s2,32(sp)
 8fa:	e852                	sd	s4,16(sp)
 8fc:	e456                	sd	s5,8(sp)
 8fe:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 900:	00000797          	auipc	a5,0x0
 904:	71078793          	addi	a5,a5,1808 # 1010 <base>
 908:	00000717          	auipc	a4,0x0
 90c:	6ef73c23          	sd	a5,1784(a4) # 1000 <freep>
 910:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 912:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 916:	b7c1                	j	8d6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 918:	6398                	ld	a4,0(a5)
 91a:	e118                	sd	a4,0(a0)
 91c:	a8a9                	j	976 <malloc+0xd6>
  hp->s.size = nu;
 91e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 922:	0541                	addi	a0,a0,16
 924:	efbff0ef          	jal	81e <free>
  return freep;
 928:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92c:	c12d                	beqz	a0,98e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 930:	4798                	lw	a4,8(a5)
 932:	02977263          	bgeu	a4,s1,956 <malloc+0xb6>
    if(p == freep)
 936:	00093703          	ld	a4,0(s2)
 93a:	853e                	mv	a0,a5
 93c:	fef719e3          	bne	a4,a5,92e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 940:	8552                	mv	a0,s4
 942:	a37ff0ef          	jal	378 <sbrk>
  if(p == SBRK_ERROR)
 946:	fd551ce3          	bne	a0,s5,91e <malloc+0x7e>
        return 0;
 94a:	4501                	li	a0,0
 94c:	7902                	ld	s2,32(sp)
 94e:	6a42                	ld	s4,16(sp)
 950:	6aa2                	ld	s5,8(sp)
 952:	6b02                	ld	s6,0(sp)
 954:	a03d                	j	982 <malloc+0xe2>
 956:	7902                	ld	s2,32(sp)
 958:	6a42                	ld	s4,16(sp)
 95a:	6aa2                	ld	s5,8(sp)
 95c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 95e:	fae48de3          	beq	s1,a4,918 <malloc+0x78>
        p->s.size -= nunits;
 962:	4137073b          	subw	a4,a4,s3
 966:	c798                	sw	a4,8(a5)
        p += p->s.size;
 968:	02071693          	slli	a3,a4,0x20
 96c:	01c6d713          	srli	a4,a3,0x1c
 970:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 972:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 976:	00000717          	auipc	a4,0x0
 97a:	68a73523          	sd	a0,1674(a4) # 1000 <freep>
      return (void*)(p + 1);
 97e:	01078513          	addi	a0,a5,16
  }
}
 982:	70e2                	ld	ra,56(sp)
 984:	7442                	ld	s0,48(sp)
 986:	74a2                	ld	s1,40(sp)
 988:	69e2                	ld	s3,24(sp)
 98a:	6121                	addi	sp,sp,64
 98c:	8082                	ret
 98e:	7902                	ld	s2,32(sp)
 990:	6a42                	ld	s4,16(sp)
 992:	6aa2                	ld	s5,8(sp)
 994:	6b02                	ld	s6,0(sp)
 996:	b7f5                	j	982 <malloc+0xe2>
