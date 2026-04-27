
user/_k28_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <assert>:
#include "kernel/types.h"
#include "user/user.h"

// Hàm kiểm tra tự động
void assert(int condition, char *test_name) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    if (condition) {
   8:	c919                	beqz	a0,1e <assert+0x1e>
        printf("[PASS] %s\n", test_name);
   a:	00001517          	auipc	a0,0x1
   e:	92650513          	addi	a0,a0,-1754 # 930 <malloc+0x102>
  12:	768000ef          	jal	77a <printf>
    } else {
        printf("[FAIL] %s\n", test_name);
    }
}
  16:	60a2                	ld	ra,8(sp)
  18:	6402                	ld	s0,0(sp)
  1a:	0141                	addi	sp,sp,16
  1c:	8082                	ret
        printf("[FAIL] %s\n", test_name);
  1e:	00001517          	auipc	a0,0x1
  22:	92250513          	addi	a0,a0,-1758 # 940 <malloc+0x112>
  26:	754000ef          	jal	77a <printf>
}
  2a:	b7f5                	j	16 <assert+0x16>

000000000000002c <main>:

int main(int argc, char *argv[]) {
  2c:	1101                	addi	sp,sp,-32
  2e:	ec06                	sd	ra,24(sp)
  30:	e822                	sd	s0,16(sp)
  32:	e426                	sd	s1,8(sp)
  34:	1000                	addi	s0,sp,32
    printf("--- RUNNING KAN-28 AUTOMATED TESTS ---\n");
  36:	00001517          	auipc	a0,0x1
  3a:	91a50513          	addi	a0,a0,-1766 # 950 <malloc+0x122>
  3e:	73c000ef          	jal	77a <printf>

    // Test 1: Thử chặn syscall write (số 16)
    setfilter(1 << 16); 
  42:	6541                	lui	a0,0x10
  44:	396000ef          	jal	3da <setfilter>
    int ret = write(1, "x", 1); // Hành động này sẽ bị chặn
  48:	4605                	li	a2,1
  4a:	00001597          	auipc	a1,0x1
  4e:	92e58593          	addi	a1,a1,-1746 # 978 <malloc+0x14a>
  52:	4505                	li	a0,1
  54:	306000ef          	jal	35a <write>
  58:	84aa                	mv	s1,a0
    
    // TẮT BỘ LỌC ĐỂ IN KẾT QUẢ
    setfilter(0); 
  5a:	4501                	li	a0,0
  5c:	37e000ef          	jal	3da <setfilter>
    
    // Kiểm tra kết quả (ret phải bằng -1 vì bị chặn)
    assert(ret == -1, "Test #1: Block write() syscall");
  60:	00148513          	addi	a0,s1,1
  64:	00001597          	auipc	a1,0x1
  68:	91c58593          	addi	a1,a1,-1764 # 980 <malloc+0x152>
  6c:	00153513          	seqz	a0,a0
  70:	f91ff0ef          	jal	0 <assert>

    // Test 2: Kiểm tra chức năng getfilter()
    uint64 test_mask = 0x1234; 
    setfilter(test_mask);
  74:	6505                	lui	a0,0x1
  76:	23450513          	addi	a0,a0,564 # 1234 <base+0x224>
  7a:	360000ef          	jal	3da <setfilter>
    uint64 current_mask = getfilter();
  7e:	364000ef          	jal	3e2 <getfilter>
    
    assert(current_mask == test_mask, "Test #2: Check mask application");
  82:	77fd                	lui	a5,0xfffff
  84:	dcc78793          	addi	a5,a5,-564 # ffffffffffffedcc <base+0xffffffffffffddbc>
  88:	953e                	add	a0,a0,a5
  8a:	00001597          	auipc	a1,0x1
  8e:	91658593          	addi	a1,a1,-1770 # 9a0 <malloc+0x172>
  92:	00153513          	seqz	a0,a0
  96:	f6bff0ef          	jal	0 <assert>

    // Dọn dẹp
    setfilter(0);
  9a:	4501                	li	a0,0
  9c:	33e000ef          	jal	3da <setfilter>
    exit(0);
  a0:	4501                	li	a0,0
  a2:	298000ef          	jal	33a <exit>

00000000000000a6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e406                	sd	ra,8(sp)
  aa:	e022                	sd	s0,0(sp)
  ac:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ae:	f7fff0ef          	jal	2c <main>
  exit(r);
  b2:	288000ef          	jal	33a <exit>

00000000000000b6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  bc:	87aa                	mv	a5,a0
  be:	0585                	addi	a1,a1,1
  c0:	0785                	addi	a5,a5,1
  c2:	fff5c703          	lbu	a4,-1(a1)
  c6:	fee78fa3          	sb	a4,-1(a5)
  ca:	fb75                	bnez	a4,be <strcpy+0x8>
    ;
  return os;
}
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret

00000000000000d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  d8:	00054783          	lbu	a5,0(a0)
  dc:	cb91                	beqz	a5,f0 <strcmp+0x1e>
  de:	0005c703          	lbu	a4,0(a1)
  e2:	00f71763          	bne	a4,a5,f0 <strcmp+0x1e>
    p++, q++;
  e6:	0505                	addi	a0,a0,1
  e8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ea:	00054783          	lbu	a5,0(a0)
  ee:	fbe5                	bnez	a5,de <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f0:	0005c503          	lbu	a0,0(a1)
}
  f4:	40a7853b          	subw	a0,a5,a0
  f8:	6422                	ld	s0,8(sp)
  fa:	0141                	addi	sp,sp,16
  fc:	8082                	ret

00000000000000fe <strlen>:

uint
strlen(const char *s)
{
  fe:	1141                	addi	sp,sp,-16
 100:	e422                	sd	s0,8(sp)
 102:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 104:	00054783          	lbu	a5,0(a0)
 108:	cf91                	beqz	a5,124 <strlen+0x26>
 10a:	0505                	addi	a0,a0,1
 10c:	87aa                	mv	a5,a0
 10e:	86be                	mv	a3,a5
 110:	0785                	addi	a5,a5,1
 112:	fff7c703          	lbu	a4,-1(a5)
 116:	ff65                	bnez	a4,10e <strlen+0x10>
 118:	40a6853b          	subw	a0,a3,a0
 11c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 11e:	6422                	ld	s0,8(sp)
 120:	0141                	addi	sp,sp,16
 122:	8082                	ret
  for(n = 0; s[n]; n++)
 124:	4501                	li	a0,0
 126:	bfe5                	j	11e <strlen+0x20>

0000000000000128 <memset>:

void*
memset(void *dst, int c, uint n)
{
 128:	1141                	addi	sp,sp,-16
 12a:	e422                	sd	s0,8(sp)
 12c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 12e:	ca19                	beqz	a2,144 <memset+0x1c>
 130:	87aa                	mv	a5,a0
 132:	1602                	slli	a2,a2,0x20
 134:	9201                	srli	a2,a2,0x20
 136:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 13a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 13e:	0785                	addi	a5,a5,1
 140:	fee79de3          	bne	a5,a4,13a <memset+0x12>
  }
  return dst;
}
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret

000000000000014a <strchr>:

char*
strchr(const char *s, char c)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 150:	00054783          	lbu	a5,0(a0)
 154:	cb99                	beqz	a5,16a <strchr+0x20>
    if(*s == c)
 156:	00f58763          	beq	a1,a5,164 <strchr+0x1a>
  for(; *s; s++)
 15a:	0505                	addi	a0,a0,1
 15c:	00054783          	lbu	a5,0(a0)
 160:	fbfd                	bnez	a5,156 <strchr+0xc>
      return (char*)s;
  return 0;
 162:	4501                	li	a0,0
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret
  return 0;
 16a:	4501                	li	a0,0
 16c:	bfe5                	j	164 <strchr+0x1a>

000000000000016e <gets>:

char*
gets(char *buf, int max)
{
 16e:	711d                	addi	sp,sp,-96
 170:	ec86                	sd	ra,88(sp)
 172:	e8a2                	sd	s0,80(sp)
 174:	e4a6                	sd	s1,72(sp)
 176:	e0ca                	sd	s2,64(sp)
 178:	fc4e                	sd	s3,56(sp)
 17a:	f852                	sd	s4,48(sp)
 17c:	f456                	sd	s5,40(sp)
 17e:	f05a                	sd	s6,32(sp)
 180:	ec5e                	sd	s7,24(sp)
 182:	1080                	addi	s0,sp,96
 184:	8baa                	mv	s7,a0
 186:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 188:	892a                	mv	s2,a0
 18a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 18c:	4aa9                	li	s5,10
 18e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 190:	89a6                	mv	s3,s1
 192:	2485                	addiw	s1,s1,1
 194:	0344d663          	bge	s1,s4,1c0 <gets+0x52>
    cc = read(0, &c, 1);
 198:	4605                	li	a2,1
 19a:	faf40593          	addi	a1,s0,-81
 19e:	4501                	li	a0,0
 1a0:	1b2000ef          	jal	352 <read>
    if(cc < 1)
 1a4:	00a05e63          	blez	a0,1c0 <gets+0x52>
    buf[i++] = c;
 1a8:	faf44783          	lbu	a5,-81(s0)
 1ac:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b0:	01578763          	beq	a5,s5,1be <gets+0x50>
 1b4:	0905                	addi	s2,s2,1
 1b6:	fd679de3          	bne	a5,s6,190 <gets+0x22>
    buf[i++] = c;
 1ba:	89a6                	mv	s3,s1
 1bc:	a011                	j	1c0 <gets+0x52>
 1be:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c0:	99de                	add	s3,s3,s7
 1c2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1c6:	855e                	mv	a0,s7
 1c8:	60e6                	ld	ra,88(sp)
 1ca:	6446                	ld	s0,80(sp)
 1cc:	64a6                	ld	s1,72(sp)
 1ce:	6906                	ld	s2,64(sp)
 1d0:	79e2                	ld	s3,56(sp)
 1d2:	7a42                	ld	s4,48(sp)
 1d4:	7aa2                	ld	s5,40(sp)
 1d6:	7b02                	ld	s6,32(sp)
 1d8:	6be2                	ld	s7,24(sp)
 1da:	6125                	addi	sp,sp,96
 1dc:	8082                	ret

00000000000001de <stat>:

int
stat(const char *n, struct stat *st)
{
 1de:	1101                	addi	sp,sp,-32
 1e0:	ec06                	sd	ra,24(sp)
 1e2:	e822                	sd	s0,16(sp)
 1e4:	e04a                	sd	s2,0(sp)
 1e6:	1000                	addi	s0,sp,32
 1e8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ea:	4581                	li	a1,0
 1ec:	18e000ef          	jal	37a <open>
  if(fd < 0)
 1f0:	02054263          	bltz	a0,214 <stat+0x36>
 1f4:	e426                	sd	s1,8(sp)
 1f6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f8:	85ca                	mv	a1,s2
 1fa:	198000ef          	jal	392 <fstat>
 1fe:	892a                	mv	s2,a0
  close(fd);
 200:	8526                	mv	a0,s1
 202:	160000ef          	jal	362 <close>
  return r;
 206:	64a2                	ld	s1,8(sp)
}
 208:	854a                	mv	a0,s2
 20a:	60e2                	ld	ra,24(sp)
 20c:	6442                	ld	s0,16(sp)
 20e:	6902                	ld	s2,0(sp)
 210:	6105                	addi	sp,sp,32
 212:	8082                	ret
    return -1;
 214:	597d                	li	s2,-1
 216:	bfcd                	j	208 <stat+0x2a>

0000000000000218 <atoi>:

int
atoi(const char *s)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e422                	sd	s0,8(sp)
 21c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21e:	00054683          	lbu	a3,0(a0)
 222:	fd06879b          	addiw	a5,a3,-48
 226:	0ff7f793          	zext.b	a5,a5
 22a:	4625                	li	a2,9
 22c:	02f66863          	bltu	a2,a5,25c <atoi+0x44>
 230:	872a                	mv	a4,a0
  n = 0;
 232:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 234:	0705                	addi	a4,a4,1
 236:	0025179b          	slliw	a5,a0,0x2
 23a:	9fa9                	addw	a5,a5,a0
 23c:	0017979b          	slliw	a5,a5,0x1
 240:	9fb5                	addw	a5,a5,a3
 242:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 246:	00074683          	lbu	a3,0(a4)
 24a:	fd06879b          	addiw	a5,a3,-48
 24e:	0ff7f793          	zext.b	a5,a5
 252:	fef671e3          	bgeu	a2,a5,234 <atoi+0x1c>
  return n;
}
 256:	6422                	ld	s0,8(sp)
 258:	0141                	addi	sp,sp,16
 25a:	8082                	ret
  n = 0;
 25c:	4501                	li	a0,0
 25e:	bfe5                	j	256 <atoi+0x3e>

0000000000000260 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 266:	02b57463          	bgeu	a0,a1,28e <memmove+0x2e>
    while(n-- > 0)
 26a:	00c05f63          	blez	a2,288 <memmove+0x28>
 26e:	1602                	slli	a2,a2,0x20
 270:	9201                	srli	a2,a2,0x20
 272:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 276:	872a                	mv	a4,a0
      *dst++ = *src++;
 278:	0585                	addi	a1,a1,1
 27a:	0705                	addi	a4,a4,1
 27c:	fff5c683          	lbu	a3,-1(a1)
 280:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 284:	fef71ae3          	bne	a4,a5,278 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
    dst += n;
 28e:	00c50733          	add	a4,a0,a2
    src += n;
 292:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 294:	fec05ae3          	blez	a2,288 <memmove+0x28>
 298:	fff6079b          	addiw	a5,a2,-1
 29c:	1782                	slli	a5,a5,0x20
 29e:	9381                	srli	a5,a5,0x20
 2a0:	fff7c793          	not	a5,a5
 2a4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a6:	15fd                	addi	a1,a1,-1
 2a8:	177d                	addi	a4,a4,-1
 2aa:	0005c683          	lbu	a3,0(a1)
 2ae:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b2:	fee79ae3          	bne	a5,a4,2a6 <memmove+0x46>
 2b6:	bfc9                	j	288 <memmove+0x28>

00000000000002b8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2be:	ca05                	beqz	a2,2ee <memcmp+0x36>
 2c0:	fff6069b          	addiw	a3,a2,-1
 2c4:	1682                	slli	a3,a3,0x20
 2c6:	9281                	srli	a3,a3,0x20
 2c8:	0685                	addi	a3,a3,1
 2ca:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2cc:	00054783          	lbu	a5,0(a0)
 2d0:	0005c703          	lbu	a4,0(a1)
 2d4:	00e79863          	bne	a5,a4,2e4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2d8:	0505                	addi	a0,a0,1
    p2++;
 2da:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2dc:	fed518e3          	bne	a0,a3,2cc <memcmp+0x14>
  }
  return 0;
 2e0:	4501                	li	a0,0
 2e2:	a019                	j	2e8 <memcmp+0x30>
      return *p1 - *p2;
 2e4:	40e7853b          	subw	a0,a5,a4
}
 2e8:	6422                	ld	s0,8(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret
  return 0;
 2ee:	4501                	li	a0,0
 2f0:	bfe5                	j	2e8 <memcmp+0x30>

00000000000002f2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e406                	sd	ra,8(sp)
 2f6:	e022                	sd	s0,0(sp)
 2f8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2fa:	f67ff0ef          	jal	260 <memmove>
}
 2fe:	60a2                	ld	ra,8(sp)
 300:	6402                	ld	s0,0(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret

0000000000000306 <sbrk>:

char *
sbrk(int n) {
 306:	1141                	addi	sp,sp,-16
 308:	e406                	sd	ra,8(sp)
 30a:	e022                	sd	s0,0(sp)
 30c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 30e:	4585                	li	a1,1
 310:	0b2000ef          	jal	3c2 <sys_sbrk>
}
 314:	60a2                	ld	ra,8(sp)
 316:	6402                	ld	s0,0(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <sbrklazy>:

char *
sbrklazy(int n) {
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 324:	4589                	li	a1,2
 326:	09c000ef          	jal	3c2 <sys_sbrk>
}
 32a:	60a2                	ld	ra,8(sp)
 32c:	6402                	ld	s0,0(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret

0000000000000332 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 332:	4885                	li	a7,1
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <exit>:
.global exit
exit:
 li a7, SYS_exit
 33a:	4889                	li	a7,2
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <wait>:
.global wait
wait:
 li a7, SYS_wait
 342:	488d                	li	a7,3
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 34a:	4891                	li	a7,4
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <read>:
.global read
read:
 li a7, SYS_read
 352:	4895                	li	a7,5
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <write>:
.global write
write:
 li a7, SYS_write
 35a:	48c1                	li	a7,16
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <close>:
.global close
close:
 li a7, SYS_close
 362:	48d5                	li	a7,21
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <kill>:
.global kill
kill:
 li a7, SYS_kill
 36a:	4899                	li	a7,6
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <exec>:
.global exec
exec:
 li a7, SYS_exec
 372:	489d                	li	a7,7
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <open>:
.global open
open:
 li a7, SYS_open
 37a:	48bd                	li	a7,15
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 382:	48c5                	li	a7,17
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 38a:	48c9                	li	a7,18
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 392:	48a1                	li	a7,8
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <link>:
.global link
link:
 li a7, SYS_link
 39a:	48cd                	li	a7,19
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a2:	48d1                	li	a7,20
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3aa:	48a5                	li	a7,9
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b2:	48a9                	li	a7,10
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ba:	48ad                	li	a7,11
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3c2:	48b1                	li	a7,12
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ca:	48b5                	li	a7,13
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d2:	48b9                	li	a7,14
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <setfilter>:
.global setfilter
setfilter:
 li a7, SYS_setfilter
 3da:	48dd                	li	a7,23
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <getfilter>:
.global getfilter
getfilter:
 li a7, SYS_getfilter
 3e2:	48e1                	li	a7,24
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <setfilter_child>:
.global setfilter_child
setfilter_child:
 li a7, SYS_setfilter_child
 3ea:	48e5                	li	a7,25
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f2:	1101                	addi	sp,sp,-32
 3f4:	ec06                	sd	ra,24(sp)
 3f6:	e822                	sd	s0,16(sp)
 3f8:	1000                	addi	s0,sp,32
 3fa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3fe:	4605                	li	a2,1
 400:	fef40593          	addi	a1,s0,-17
 404:	f57ff0ef          	jal	35a <write>
}
 408:	60e2                	ld	ra,24(sp)
 40a:	6442                	ld	s0,16(sp)
 40c:	6105                	addi	sp,sp,32
 40e:	8082                	ret

0000000000000410 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 410:	715d                	addi	sp,sp,-80
 412:	e486                	sd	ra,72(sp)
 414:	e0a2                	sd	s0,64(sp)
 416:	f84a                	sd	s2,48(sp)
 418:	0880                	addi	s0,sp,80
 41a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 41c:	c299                	beqz	a3,422 <printint+0x12>
 41e:	0805c363          	bltz	a1,4a4 <printint+0x94>
  neg = 0;
 422:	4881                	li	a7,0
 424:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 428:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 42a:	00000517          	auipc	a0,0x0
 42e:	59e50513          	addi	a0,a0,1438 # 9c8 <digits>
 432:	883e                	mv	a6,a5
 434:	2785                	addiw	a5,a5,1
 436:	02c5f733          	remu	a4,a1,a2
 43a:	972a                	add	a4,a4,a0
 43c:	00074703          	lbu	a4,0(a4)
 440:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 444:	872e                	mv	a4,a1
 446:	02c5d5b3          	divu	a1,a1,a2
 44a:	0685                	addi	a3,a3,1
 44c:	fec773e3          	bgeu	a4,a2,432 <printint+0x22>
  if(neg)
 450:	00088b63          	beqz	a7,466 <printint+0x56>
    buf[i++] = '-';
 454:	fd078793          	addi	a5,a5,-48
 458:	97a2                	add	a5,a5,s0
 45a:	02d00713          	li	a4,45
 45e:	fee78423          	sb	a4,-24(a5)
 462:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 466:	02f05a63          	blez	a5,49a <printint+0x8a>
 46a:	fc26                	sd	s1,56(sp)
 46c:	f44e                	sd	s3,40(sp)
 46e:	fb840713          	addi	a4,s0,-72
 472:	00f704b3          	add	s1,a4,a5
 476:	fff70993          	addi	s3,a4,-1
 47a:	99be                	add	s3,s3,a5
 47c:	37fd                	addiw	a5,a5,-1
 47e:	1782                	slli	a5,a5,0x20
 480:	9381                	srli	a5,a5,0x20
 482:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 486:	fff4c583          	lbu	a1,-1(s1)
 48a:	854a                	mv	a0,s2
 48c:	f67ff0ef          	jal	3f2 <putc>
  while(--i >= 0)
 490:	14fd                	addi	s1,s1,-1
 492:	ff349ae3          	bne	s1,s3,486 <printint+0x76>
 496:	74e2                	ld	s1,56(sp)
 498:	79a2                	ld	s3,40(sp)
}
 49a:	60a6                	ld	ra,72(sp)
 49c:	6406                	ld	s0,64(sp)
 49e:	7942                	ld	s2,48(sp)
 4a0:	6161                	addi	sp,sp,80
 4a2:	8082                	ret
    x = -xx;
 4a4:	40b005b3          	neg	a1,a1
    neg = 1;
 4a8:	4885                	li	a7,1
    x = -xx;
 4aa:	bfad                	j	424 <printint+0x14>

00000000000004ac <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ac:	711d                	addi	sp,sp,-96
 4ae:	ec86                	sd	ra,88(sp)
 4b0:	e8a2                	sd	s0,80(sp)
 4b2:	e0ca                	sd	s2,64(sp)
 4b4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b6:	0005c903          	lbu	s2,0(a1)
 4ba:	28090663          	beqz	s2,746 <vprintf+0x29a>
 4be:	e4a6                	sd	s1,72(sp)
 4c0:	fc4e                	sd	s3,56(sp)
 4c2:	f852                	sd	s4,48(sp)
 4c4:	f456                	sd	s5,40(sp)
 4c6:	f05a                	sd	s6,32(sp)
 4c8:	ec5e                	sd	s7,24(sp)
 4ca:	e862                	sd	s8,16(sp)
 4cc:	e466                	sd	s9,8(sp)
 4ce:	8b2a                	mv	s6,a0
 4d0:	8a2e                	mv	s4,a1
 4d2:	8bb2                	mv	s7,a2
  state = 0;
 4d4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4d6:	4481                	li	s1,0
 4d8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4da:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4de:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4e2:	06c00c93          	li	s9,108
 4e6:	a005                	j	506 <vprintf+0x5a>
        putc(fd, c0);
 4e8:	85ca                	mv	a1,s2
 4ea:	855a                	mv	a0,s6
 4ec:	f07ff0ef          	jal	3f2 <putc>
 4f0:	a019                	j	4f6 <vprintf+0x4a>
    } else if(state == '%'){
 4f2:	03598263          	beq	s3,s5,516 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4f6:	2485                	addiw	s1,s1,1
 4f8:	8726                	mv	a4,s1
 4fa:	009a07b3          	add	a5,s4,s1
 4fe:	0007c903          	lbu	s2,0(a5)
 502:	22090a63          	beqz	s2,736 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 506:	0009079b          	sext.w	a5,s2
    if(state == 0){
 50a:	fe0994e3          	bnez	s3,4f2 <vprintf+0x46>
      if(c0 == '%'){
 50e:	fd579de3          	bne	a5,s5,4e8 <vprintf+0x3c>
        state = '%';
 512:	89be                	mv	s3,a5
 514:	b7cd                	j	4f6 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 516:	00ea06b3          	add	a3,s4,a4
 51a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 51e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 520:	c681                	beqz	a3,528 <vprintf+0x7c>
 522:	9752                	add	a4,a4,s4
 524:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 528:	05878363          	beq	a5,s8,56e <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 52c:	05978d63          	beq	a5,s9,586 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 530:	07500713          	li	a4,117
 534:	0ee78763          	beq	a5,a4,622 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 538:	07800713          	li	a4,120
 53c:	12e78963          	beq	a5,a4,66e <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 540:	07000713          	li	a4,112
 544:	14e78e63          	beq	a5,a4,6a0 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 548:	06300713          	li	a4,99
 54c:	18e78e63          	beq	a5,a4,6e8 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 550:	07300713          	li	a4,115
 554:	1ae78463          	beq	a5,a4,6fc <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 558:	02500713          	li	a4,37
 55c:	04e79563          	bne	a5,a4,5a6 <vprintf+0xfa>
        putc(fd, '%');
 560:	02500593          	li	a1,37
 564:	855a                	mv	a0,s6
 566:	e8dff0ef          	jal	3f2 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 56a:	4981                	li	s3,0
 56c:	b769                	j	4f6 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 56e:	008b8913          	addi	s2,s7,8
 572:	4685                	li	a3,1
 574:	4629                	li	a2,10
 576:	000ba583          	lw	a1,0(s7)
 57a:	855a                	mv	a0,s6
 57c:	e95ff0ef          	jal	410 <printint>
 580:	8bca                	mv	s7,s2
      state = 0;
 582:	4981                	li	s3,0
 584:	bf8d                	j	4f6 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 586:	06400793          	li	a5,100
 58a:	02f68963          	beq	a3,a5,5bc <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 58e:	06c00793          	li	a5,108
 592:	04f68263          	beq	a3,a5,5d6 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 596:	07500793          	li	a5,117
 59a:	0af68063          	beq	a3,a5,63a <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 59e:	07800793          	li	a5,120
 5a2:	0ef68263          	beq	a3,a5,686 <vprintf+0x1da>
        putc(fd, '%');
 5a6:	02500593          	li	a1,37
 5aa:	855a                	mv	a0,s6
 5ac:	e47ff0ef          	jal	3f2 <putc>
        putc(fd, c0);
 5b0:	85ca                	mv	a1,s2
 5b2:	855a                	mv	a0,s6
 5b4:	e3fff0ef          	jal	3f2 <putc>
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	bf35                	j	4f6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5bc:	008b8913          	addi	s2,s7,8
 5c0:	4685                	li	a3,1
 5c2:	4629                	li	a2,10
 5c4:	000bb583          	ld	a1,0(s7)
 5c8:	855a                	mv	a0,s6
 5ca:	e47ff0ef          	jal	410 <printint>
        i += 1;
 5ce:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d0:	8bca                	mv	s7,s2
      state = 0;
 5d2:	4981                	li	s3,0
        i += 1;
 5d4:	b70d                	j	4f6 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5d6:	06400793          	li	a5,100
 5da:	02f60763          	beq	a2,a5,608 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5de:	07500793          	li	a5,117
 5e2:	06f60963          	beq	a2,a5,654 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5e6:	07800793          	li	a5,120
 5ea:	faf61ee3          	bne	a2,a5,5a6 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ee:	008b8913          	addi	s2,s7,8
 5f2:	4681                	li	a3,0
 5f4:	4641                	li	a2,16
 5f6:	000bb583          	ld	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	e15ff0ef          	jal	410 <printint>
        i += 2;
 600:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
        i += 2;
 606:	bdc5                	j	4f6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 608:	008b8913          	addi	s2,s7,8
 60c:	4685                	li	a3,1
 60e:	4629                	li	a2,10
 610:	000bb583          	ld	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	dfbff0ef          	jal	410 <printint>
        i += 2;
 61a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
        i += 2;
 620:	bdd9                	j	4f6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 622:	008b8913          	addi	s2,s7,8
 626:	4681                	li	a3,0
 628:	4629                	li	a2,10
 62a:	000be583          	lwu	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	de1ff0ef          	jal	410 <printint>
 634:	8bca                	mv	s7,s2
      state = 0;
 636:	4981                	li	s3,0
 638:	bd7d                	j	4f6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 63a:	008b8913          	addi	s2,s7,8
 63e:	4681                	li	a3,0
 640:	4629                	li	a2,10
 642:	000bb583          	ld	a1,0(s7)
 646:	855a                	mv	a0,s6
 648:	dc9ff0ef          	jal	410 <printint>
        i += 1;
 64c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 64e:	8bca                	mv	s7,s2
      state = 0;
 650:	4981                	li	s3,0
        i += 1;
 652:	b555                	j	4f6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 654:	008b8913          	addi	s2,s7,8
 658:	4681                	li	a3,0
 65a:	4629                	li	a2,10
 65c:	000bb583          	ld	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	dafff0ef          	jal	410 <printint>
        i += 2;
 666:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 668:	8bca                	mv	s7,s2
      state = 0;
 66a:	4981                	li	s3,0
        i += 2;
 66c:	b569                	j	4f6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 66e:	008b8913          	addi	s2,s7,8
 672:	4681                	li	a3,0
 674:	4641                	li	a2,16
 676:	000be583          	lwu	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	d95ff0ef          	jal	410 <printint>
 680:	8bca                	mv	s7,s2
      state = 0;
 682:	4981                	li	s3,0
 684:	bd8d                	j	4f6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 686:	008b8913          	addi	s2,s7,8
 68a:	4681                	li	a3,0
 68c:	4641                	li	a2,16
 68e:	000bb583          	ld	a1,0(s7)
 692:	855a                	mv	a0,s6
 694:	d7dff0ef          	jal	410 <printint>
        i += 1;
 698:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 69a:	8bca                	mv	s7,s2
      state = 0;
 69c:	4981                	li	s3,0
        i += 1;
 69e:	bda1                	j	4f6 <vprintf+0x4a>
 6a0:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6a2:	008b8d13          	addi	s10,s7,8
 6a6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6aa:	03000593          	li	a1,48
 6ae:	855a                	mv	a0,s6
 6b0:	d43ff0ef          	jal	3f2 <putc>
  putc(fd, 'x');
 6b4:	07800593          	li	a1,120
 6b8:	855a                	mv	a0,s6
 6ba:	d39ff0ef          	jal	3f2 <putc>
 6be:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c0:	00000b97          	auipc	s7,0x0
 6c4:	308b8b93          	addi	s7,s7,776 # 9c8 <digits>
 6c8:	03c9d793          	srli	a5,s3,0x3c
 6cc:	97de                	add	a5,a5,s7
 6ce:	0007c583          	lbu	a1,0(a5)
 6d2:	855a                	mv	a0,s6
 6d4:	d1fff0ef          	jal	3f2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6d8:	0992                	slli	s3,s3,0x4
 6da:	397d                	addiw	s2,s2,-1
 6dc:	fe0916e3          	bnez	s2,6c8 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6e0:	8bea                	mv	s7,s10
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	6d02                	ld	s10,0(sp)
 6e6:	bd01                	j	4f6 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6e8:	008b8913          	addi	s2,s7,8
 6ec:	000bc583          	lbu	a1,0(s7)
 6f0:	855a                	mv	a0,s6
 6f2:	d01ff0ef          	jal	3f2 <putc>
 6f6:	8bca                	mv	s7,s2
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bbf5                	j	4f6 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6fc:	008b8993          	addi	s3,s7,8
 700:	000bb903          	ld	s2,0(s7)
 704:	00090f63          	beqz	s2,722 <vprintf+0x276>
        for(; *s; s++)
 708:	00094583          	lbu	a1,0(s2)
 70c:	c195                	beqz	a1,730 <vprintf+0x284>
          putc(fd, *s);
 70e:	855a                	mv	a0,s6
 710:	ce3ff0ef          	jal	3f2 <putc>
        for(; *s; s++)
 714:	0905                	addi	s2,s2,1
 716:	00094583          	lbu	a1,0(s2)
 71a:	f9f5                	bnez	a1,70e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 71c:	8bce                	mv	s7,s3
      state = 0;
 71e:	4981                	li	s3,0
 720:	bbd9                	j	4f6 <vprintf+0x4a>
          s = "(null)";
 722:	00000917          	auipc	s2,0x0
 726:	29e90913          	addi	s2,s2,670 # 9c0 <malloc+0x192>
        for(; *s; s++)
 72a:	02800593          	li	a1,40
 72e:	b7c5                	j	70e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 730:	8bce                	mv	s7,s3
      state = 0;
 732:	4981                	li	s3,0
 734:	b3c9                	j	4f6 <vprintf+0x4a>
 736:	64a6                	ld	s1,72(sp)
 738:	79e2                	ld	s3,56(sp)
 73a:	7a42                	ld	s4,48(sp)
 73c:	7aa2                	ld	s5,40(sp)
 73e:	7b02                	ld	s6,32(sp)
 740:	6be2                	ld	s7,24(sp)
 742:	6c42                	ld	s8,16(sp)
 744:	6ca2                	ld	s9,8(sp)
    }
  }
}
 746:	60e6                	ld	ra,88(sp)
 748:	6446                	ld	s0,80(sp)
 74a:	6906                	ld	s2,64(sp)
 74c:	6125                	addi	sp,sp,96
 74e:	8082                	ret

0000000000000750 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 750:	715d                	addi	sp,sp,-80
 752:	ec06                	sd	ra,24(sp)
 754:	e822                	sd	s0,16(sp)
 756:	1000                	addi	s0,sp,32
 758:	e010                	sd	a2,0(s0)
 75a:	e414                	sd	a3,8(s0)
 75c:	e818                	sd	a4,16(s0)
 75e:	ec1c                	sd	a5,24(s0)
 760:	03043023          	sd	a6,32(s0)
 764:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 768:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 76c:	8622                	mv	a2,s0
 76e:	d3fff0ef          	jal	4ac <vprintf>
}
 772:	60e2                	ld	ra,24(sp)
 774:	6442                	ld	s0,16(sp)
 776:	6161                	addi	sp,sp,80
 778:	8082                	ret

000000000000077a <printf>:

void
printf(const char *fmt, ...)
{
 77a:	711d                	addi	sp,sp,-96
 77c:	ec06                	sd	ra,24(sp)
 77e:	e822                	sd	s0,16(sp)
 780:	1000                	addi	s0,sp,32
 782:	e40c                	sd	a1,8(s0)
 784:	e810                	sd	a2,16(s0)
 786:	ec14                	sd	a3,24(s0)
 788:	f018                	sd	a4,32(s0)
 78a:	f41c                	sd	a5,40(s0)
 78c:	03043823          	sd	a6,48(s0)
 790:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 794:	00840613          	addi	a2,s0,8
 798:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 79c:	85aa                	mv	a1,a0
 79e:	4505                	li	a0,1
 7a0:	d0dff0ef          	jal	4ac <vprintf>
}
 7a4:	60e2                	ld	ra,24(sp)
 7a6:	6442                	ld	s0,16(sp)
 7a8:	6125                	addi	sp,sp,96
 7aa:	8082                	ret

00000000000007ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ac:	1141                	addi	sp,sp,-16
 7ae:	e422                	sd	s0,8(sp)
 7b0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b6:	00001797          	auipc	a5,0x1
 7ba:	84a7b783          	ld	a5,-1974(a5) # 1000 <freep>
 7be:	a02d                	j	7e8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c0:	4618                	lw	a4,8(a2)
 7c2:	9f2d                	addw	a4,a4,a1
 7c4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c8:	6398                	ld	a4,0(a5)
 7ca:	6310                	ld	a2,0(a4)
 7cc:	a83d                	j	80a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ce:	ff852703          	lw	a4,-8(a0)
 7d2:	9f31                	addw	a4,a4,a2
 7d4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7d6:	ff053683          	ld	a3,-16(a0)
 7da:	a091                	j	81e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7dc:	6398                	ld	a4,0(a5)
 7de:	00e7e463          	bltu	a5,a4,7e6 <free+0x3a>
 7e2:	00e6ea63          	bltu	a3,a4,7f6 <free+0x4a>
{
 7e6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e8:	fed7fae3          	bgeu	a5,a3,7dc <free+0x30>
 7ec:	6398                	ld	a4,0(a5)
 7ee:	00e6e463          	bltu	a3,a4,7f6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f2:	fee7eae3          	bltu	a5,a4,7e6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7f6:	ff852583          	lw	a1,-8(a0)
 7fa:	6390                	ld	a2,0(a5)
 7fc:	02059813          	slli	a6,a1,0x20
 800:	01c85713          	srli	a4,a6,0x1c
 804:	9736                	add	a4,a4,a3
 806:	fae60de3          	beq	a2,a4,7c0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 80a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 80e:	4790                	lw	a2,8(a5)
 810:	02061593          	slli	a1,a2,0x20
 814:	01c5d713          	srli	a4,a1,0x1c
 818:	973e                	add	a4,a4,a5
 81a:	fae68ae3          	beq	a3,a4,7ce <free+0x22>
    p->s.ptr = bp->s.ptr;
 81e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 820:	00000717          	auipc	a4,0x0
 824:	7ef73023          	sd	a5,2016(a4) # 1000 <freep>
}
 828:	6422                	ld	s0,8(sp)
 82a:	0141                	addi	sp,sp,16
 82c:	8082                	ret

000000000000082e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 82e:	7139                	addi	sp,sp,-64
 830:	fc06                	sd	ra,56(sp)
 832:	f822                	sd	s0,48(sp)
 834:	f426                	sd	s1,40(sp)
 836:	ec4e                	sd	s3,24(sp)
 838:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 83a:	02051493          	slli	s1,a0,0x20
 83e:	9081                	srli	s1,s1,0x20
 840:	04bd                	addi	s1,s1,15
 842:	8091                	srli	s1,s1,0x4
 844:	0014899b          	addiw	s3,s1,1
 848:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 84a:	00000517          	auipc	a0,0x0
 84e:	7b653503          	ld	a0,1974(a0) # 1000 <freep>
 852:	c915                	beqz	a0,886 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 854:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 856:	4798                	lw	a4,8(a5)
 858:	08977a63          	bgeu	a4,s1,8ec <malloc+0xbe>
 85c:	f04a                	sd	s2,32(sp)
 85e:	e852                	sd	s4,16(sp)
 860:	e456                	sd	s5,8(sp)
 862:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 864:	8a4e                	mv	s4,s3
 866:	0009871b          	sext.w	a4,s3
 86a:	6685                	lui	a3,0x1
 86c:	00d77363          	bgeu	a4,a3,872 <malloc+0x44>
 870:	6a05                	lui	s4,0x1
 872:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 876:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 87a:	00000917          	auipc	s2,0x0
 87e:	78690913          	addi	s2,s2,1926 # 1000 <freep>
  if(p == SBRK_ERROR)
 882:	5afd                	li	s5,-1
 884:	a081                	j	8c4 <malloc+0x96>
 886:	f04a                	sd	s2,32(sp)
 888:	e852                	sd	s4,16(sp)
 88a:	e456                	sd	s5,8(sp)
 88c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 88e:	00000797          	auipc	a5,0x0
 892:	78278793          	addi	a5,a5,1922 # 1010 <base>
 896:	00000717          	auipc	a4,0x0
 89a:	76f73523          	sd	a5,1898(a4) # 1000 <freep>
 89e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a4:	b7c1                	j	864 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8a6:	6398                	ld	a4,0(a5)
 8a8:	e118                	sd	a4,0(a0)
 8aa:	a8a9                	j	904 <malloc+0xd6>
  hp->s.size = nu;
 8ac:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b0:	0541                	addi	a0,a0,16
 8b2:	efbff0ef          	jal	7ac <free>
  return freep;
 8b6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ba:	c12d                	beqz	a0,91c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8be:	4798                	lw	a4,8(a5)
 8c0:	02977263          	bgeu	a4,s1,8e4 <malloc+0xb6>
    if(p == freep)
 8c4:	00093703          	ld	a4,0(s2)
 8c8:	853e                	mv	a0,a5
 8ca:	fef719e3          	bne	a4,a5,8bc <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8ce:	8552                	mv	a0,s4
 8d0:	a37ff0ef          	jal	306 <sbrk>
  if(p == SBRK_ERROR)
 8d4:	fd551ce3          	bne	a0,s5,8ac <malloc+0x7e>
        return 0;
 8d8:	4501                	li	a0,0
 8da:	7902                	ld	s2,32(sp)
 8dc:	6a42                	ld	s4,16(sp)
 8de:	6aa2                	ld	s5,8(sp)
 8e0:	6b02                	ld	s6,0(sp)
 8e2:	a03d                	j	910 <malloc+0xe2>
 8e4:	7902                	ld	s2,32(sp)
 8e6:	6a42                	ld	s4,16(sp)
 8e8:	6aa2                	ld	s5,8(sp)
 8ea:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8ec:	fae48de3          	beq	s1,a4,8a6 <malloc+0x78>
        p->s.size -= nunits;
 8f0:	4137073b          	subw	a4,a4,s3
 8f4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8f6:	02071693          	slli	a3,a4,0x20
 8fa:	01c6d713          	srli	a4,a3,0x1c
 8fe:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 900:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 904:	00000717          	auipc	a4,0x0
 908:	6ea73e23          	sd	a0,1788(a4) # 1000 <freep>
      return (void*)(p + 1);
 90c:	01078513          	addi	a0,a5,16
  }
}
 910:	70e2                	ld	ra,56(sp)
 912:	7442                	ld	s0,48(sp)
 914:	74a2                	ld	s1,40(sp)
 916:	69e2                	ld	s3,24(sp)
 918:	6121                	addi	sp,sp,64
 91a:	8082                	ret
 91c:	7902                	ld	s2,32(sp)
 91e:	6a42                	ld	s4,16(sp)
 920:	6aa2                	ld	s5,8(sp)
 922:	6b02                	ld	s6,0(sp)
 924:	b7f5                	j	910 <malloc+0xe2>
