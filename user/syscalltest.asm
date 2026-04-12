
user/_syscalltest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_line>:
#define N_READ    5
#define N_WRITE   16
#define N_GETPID  11

// Hàm in đơn giản để tránh lỗi định dạng và lỗi bảo mật trên xv6
void test_line(char *name, int num, int res) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  10:	892e                	mv	s2,a1
  12:	84b2                	mv	s1,a2
    printf("Syscall: ");
  14:	00001517          	auipc	a0,0x1
  18:	9ac50513          	addi	a0,a0,-1620 # 9c0 <malloc+0x106>
  1c:	7ea000ef          	jal	806 <printf>
    printf("%s", name);
  20:	85ce                	mv	a1,s3
  22:	00001517          	auipc	a0,0x1
  26:	9ae50513          	addi	a0,a0,-1618 # 9d0 <malloc+0x116>
  2a:	7dc000ef          	jal	806 <printf>
    printf(" | Num: %d", num);
  2e:	85ca                	mv	a1,s2
  30:	00001517          	auipc	a0,0x1
  34:	9a850513          	addi	a0,a0,-1624 # 9d8 <malloc+0x11e>
  38:	7ce000ef          	jal	806 <printf>
    printf(" | Res: %d", res);
  3c:	85a6                	mv	a1,s1
  3e:	00001517          	auipc	a0,0x1
  42:	9aa50513          	addi	a0,a0,-1622 # 9e8 <malloc+0x12e>
  46:	7c0000ef          	jal	806 <printf>
    printf(" | Status: ");
  4a:	00001517          	auipc	a0,0x1
  4e:	9ae50513          	addi	a0,a0,-1618 # 9f8 <malloc+0x13e>
  52:	7b4000ef          	jal	806 <printf>
    if (res >= 0) {
  56:	0004cf63          	bltz	s1,74 <test_line+0x74>
        printf("SUCCESS\n");
  5a:	00001517          	auipc	a0,0x1
  5e:	9ae50513          	addi	a0,a0,-1618 # a08 <malloc+0x14e>
  62:	7a4000ef          	jal	806 <printf>
    } else {
        printf("FAILED\n");
    }
}
  66:	70a2                	ld	ra,40(sp)
  68:	7402                	ld	s0,32(sp)
  6a:	64e2                	ld	s1,24(sp)
  6c:	6942                	ld	s2,16(sp)
  6e:	69a2                	ld	s3,8(sp)
  70:	6145                	addi	sp,sp,48
  72:	8082                	ret
        printf("FAILED\n");
  74:	00001517          	auipc	a0,0x1
  78:	9a450513          	addi	a0,a0,-1628 # a18 <malloc+0x15e>
  7c:	78a000ef          	jal	806 <printf>
}
  80:	b7dd                	j	66 <test_line+0x66>

0000000000000082 <main>:

int main(int argc, char *argv[]) {
  82:	7179                	addi	sp,sp,-48
  84:	f406                	sd	ra,40(sp)
  86:	f022                	sd	s0,32(sp)
  88:	1800                	addi	s0,sp,48
    int res;
    char buf[10];

    printf("--- START SYSCALL BASELINE TEST ---\n");
  8a:	00001517          	auipc	a0,0x1
  8e:	99650513          	addi	a0,a0,-1642 # a20 <malloc+0x166>
  92:	774000ef          	jal	806 <printf>

    // 1. Test getpid
    res = getpid();
  96:	3c0000ef          	jal	456 <getpid>
  9a:	862a                	mv	a2,a0
    test_line("getpid", N_GETPID, res);
  9c:	45ad                	li	a1,11
  9e:	00001517          	auipc	a0,0x1
  a2:	9aa50513          	addi	a0,a0,-1622 # a48 <malloc+0x18e>
  a6:	f5bff0ef          	jal	0 <test_line>

    // 2. Test write (ghi 0 byte vào stdout)
    res = write(1, "", 0);
  aa:	4601                	li	a2,0
  ac:	00001597          	auipc	a1,0x1
  b0:	96458593          	addi	a1,a1,-1692 # a10 <malloc+0x156>
  b4:	4505                	li	a0,1
  b6:	340000ef          	jal	3f6 <write>
  ba:	862a                	mv	a2,a0
    test_line("write", N_WRITE, res);
  bc:	45c1                	li	a1,16
  be:	00001517          	auipc	a0,0x1
  c2:	99250513          	addi	a0,a0,-1646 # a50 <malloc+0x196>
  c6:	f3bff0ef          	jal	0 <test_line>

    // 3. Test read (đọc thử từ fd 99 không tồn tại để lấy kết quả FAILED)
    res = read(99, buf, 0);
  ca:	4601                	li	a2,0
  cc:	fe040593          	addi	a1,s0,-32
  d0:	06300513          	li	a0,99
  d4:	31a000ef          	jal	3ee <read>
  d8:	862a                	mv	a2,a0
    test_line("read", N_READ, res);
  da:	4595                	li	a1,5
  dc:	00001517          	auipc	a0,0x1
  e0:	97c50513          	addi	a0,a0,-1668 # a58 <malloc+0x19e>
  e4:	f1dff0ef          	jal	0 <test_line>

    // 4. Test fork & wait
    int pid = fork();
  e8:	2e6000ef          	jal	3ce <fork>
    if(pid < 0){
  ec:	00054563          	bltz	a0,f6 <main+0x74>
        test_line("fork", N_FORK, -1);
    } else if(pid == 0){
  f0:	ed01                	bnez	a0,108 <main+0x86>
        // Tiến trình con: thoát ngay
        exit(0);
  f2:	2e4000ef          	jal	3d6 <exit>
        test_line("fork", N_FORK, -1);
  f6:	567d                	li	a2,-1
  f8:	4585                	li	a1,1
  fa:	00001517          	auipc	a0,0x1
  fe:	96650513          	addi	a0,a0,-1690 # a60 <malloc+0x1a6>
 102:	effff0ef          	jal	0 <test_line>
 106:	a02d                	j	130 <main+0xae>
    } else {
        // Tiến trình cha: in kết quả fork và chờ con
        test_line("fork", N_FORK, pid);
 108:	862a                	mv	a2,a0
 10a:	4585                	li	a1,1
 10c:	00001517          	auipc	a0,0x1
 110:	95450513          	addi	a0,a0,-1708 # a60 <malloc+0x1a6>
 114:	eedff0ef          	jal	0 <test_line>
        int status;
        int wait_res = wait(&status);
 118:	fdc40513          	addi	a0,s0,-36
 11c:	2c2000ef          	jal	3de <wait>
 120:	862a                	mv	a2,a0
        test_line("wait", N_WAIT, wait_res);
 122:	458d                	li	a1,3
 124:	00001517          	auipc	a0,0x1
 128:	94450513          	addi	a0,a0,-1724 # a68 <malloc+0x1ae>
 12c:	ed5ff0ef          	jal	0 <test_line>
    }

    printf("--- END SYSCALL BASELINE TEST ---\n");
 130:	00001517          	auipc	a0,0x1
 134:	94050513          	addi	a0,a0,-1728 # a70 <malloc+0x1b6>
 138:	6ce000ef          	jal	806 <printf>
    exit(0);
 13c:	4501                	li	a0,0
 13e:	298000ef          	jal	3d6 <exit>

0000000000000142 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 142:	1141                	addi	sp,sp,-16
 144:	e406                	sd	ra,8(sp)
 146:	e022                	sd	s0,0(sp)
 148:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 14a:	f39ff0ef          	jal	82 <main>
  exit(r);
 14e:	288000ef          	jal	3d6 <exit>

0000000000000152 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 152:	1141                	addi	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 158:	87aa                	mv	a5,a0
 15a:	0585                	addi	a1,a1,1
 15c:	0785                	addi	a5,a5,1
 15e:	fff5c703          	lbu	a4,-1(a1)
 162:	fee78fa3          	sb	a4,-1(a5)
 166:	fb75                	bnez	a4,15a <strcpy+0x8>
    ;
  return os;
}
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret

000000000000016e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 174:	00054783          	lbu	a5,0(a0)
 178:	cb91                	beqz	a5,18c <strcmp+0x1e>
 17a:	0005c703          	lbu	a4,0(a1)
 17e:	00f71763          	bne	a4,a5,18c <strcmp+0x1e>
    p++, q++;
 182:	0505                	addi	a0,a0,1
 184:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 186:	00054783          	lbu	a5,0(a0)
 18a:	fbe5                	bnez	a5,17a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 18c:	0005c503          	lbu	a0,0(a1)
}
 190:	40a7853b          	subw	a0,a5,a0
 194:	6422                	ld	s0,8(sp)
 196:	0141                	addi	sp,sp,16
 198:	8082                	ret

000000000000019a <strlen>:

uint
strlen(const char *s)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e422                	sd	s0,8(sp)
 19e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	cf91                	beqz	a5,1c0 <strlen+0x26>
 1a6:	0505                	addi	a0,a0,1
 1a8:	87aa                	mv	a5,a0
 1aa:	86be                	mv	a3,a5
 1ac:	0785                	addi	a5,a5,1
 1ae:	fff7c703          	lbu	a4,-1(a5)
 1b2:	ff65                	bnez	a4,1aa <strlen+0x10>
 1b4:	40a6853b          	subw	a0,a3,a0
 1b8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1ba:	6422                	ld	s0,8(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret
  for(n = 0; s[n]; n++)
 1c0:	4501                	li	a0,0
 1c2:	bfe5                	j	1ba <strlen+0x20>

00000000000001c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e422                	sd	s0,8(sp)
 1c8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ca:	ca19                	beqz	a2,1e0 <memset+0x1c>
 1cc:	87aa                	mv	a5,a0
 1ce:	1602                	slli	a2,a2,0x20
 1d0:	9201                	srli	a2,a2,0x20
 1d2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1d6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1da:	0785                	addi	a5,a5,1
 1dc:	fee79de3          	bne	a5,a4,1d6 <memset+0x12>
  }
  return dst;
}
 1e0:	6422                	ld	s0,8(sp)
 1e2:	0141                	addi	sp,sp,16
 1e4:	8082                	ret

00000000000001e6 <strchr>:

char*
strchr(const char *s, char c)
{
 1e6:	1141                	addi	sp,sp,-16
 1e8:	e422                	sd	s0,8(sp)
 1ea:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ec:	00054783          	lbu	a5,0(a0)
 1f0:	cb99                	beqz	a5,206 <strchr+0x20>
    if(*s == c)
 1f2:	00f58763          	beq	a1,a5,200 <strchr+0x1a>
  for(; *s; s++)
 1f6:	0505                	addi	a0,a0,1
 1f8:	00054783          	lbu	a5,0(a0)
 1fc:	fbfd                	bnez	a5,1f2 <strchr+0xc>
      return (char*)s;
  return 0;
 1fe:	4501                	li	a0,0
}
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret
  return 0;
 206:	4501                	li	a0,0
 208:	bfe5                	j	200 <strchr+0x1a>

000000000000020a <gets>:

char*
gets(char *buf, int max)
{
 20a:	711d                	addi	sp,sp,-96
 20c:	ec86                	sd	ra,88(sp)
 20e:	e8a2                	sd	s0,80(sp)
 210:	e4a6                	sd	s1,72(sp)
 212:	e0ca                	sd	s2,64(sp)
 214:	fc4e                	sd	s3,56(sp)
 216:	f852                	sd	s4,48(sp)
 218:	f456                	sd	s5,40(sp)
 21a:	f05a                	sd	s6,32(sp)
 21c:	ec5e                	sd	s7,24(sp)
 21e:	1080                	addi	s0,sp,96
 220:	8baa                	mv	s7,a0
 222:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 224:	892a                	mv	s2,a0
 226:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 228:	4aa9                	li	s5,10
 22a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 22c:	89a6                	mv	s3,s1
 22e:	2485                	addiw	s1,s1,1
 230:	0344d663          	bge	s1,s4,25c <gets+0x52>
    cc = read(0, &c, 1);
 234:	4605                	li	a2,1
 236:	faf40593          	addi	a1,s0,-81
 23a:	4501                	li	a0,0
 23c:	1b2000ef          	jal	3ee <read>
    if(cc < 1)
 240:	00a05e63          	blez	a0,25c <gets+0x52>
    buf[i++] = c;
 244:	faf44783          	lbu	a5,-81(s0)
 248:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 24c:	01578763          	beq	a5,s5,25a <gets+0x50>
 250:	0905                	addi	s2,s2,1
 252:	fd679de3          	bne	a5,s6,22c <gets+0x22>
    buf[i++] = c;
 256:	89a6                	mv	s3,s1
 258:	a011                	j	25c <gets+0x52>
 25a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 25c:	99de                	add	s3,s3,s7
 25e:	00098023          	sb	zero,0(s3)
  return buf;
}
 262:	855e                	mv	a0,s7
 264:	60e6                	ld	ra,88(sp)
 266:	6446                	ld	s0,80(sp)
 268:	64a6                	ld	s1,72(sp)
 26a:	6906                	ld	s2,64(sp)
 26c:	79e2                	ld	s3,56(sp)
 26e:	7a42                	ld	s4,48(sp)
 270:	7aa2                	ld	s5,40(sp)
 272:	7b02                	ld	s6,32(sp)
 274:	6be2                	ld	s7,24(sp)
 276:	6125                	addi	sp,sp,96
 278:	8082                	ret

000000000000027a <stat>:

int
stat(const char *n, struct stat *st)
{
 27a:	1101                	addi	sp,sp,-32
 27c:	ec06                	sd	ra,24(sp)
 27e:	e822                	sd	s0,16(sp)
 280:	e04a                	sd	s2,0(sp)
 282:	1000                	addi	s0,sp,32
 284:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 286:	4581                	li	a1,0
 288:	18e000ef          	jal	416 <open>
  if(fd < 0)
 28c:	02054263          	bltz	a0,2b0 <stat+0x36>
 290:	e426                	sd	s1,8(sp)
 292:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 294:	85ca                	mv	a1,s2
 296:	198000ef          	jal	42e <fstat>
 29a:	892a                	mv	s2,a0
  close(fd);
 29c:	8526                	mv	a0,s1
 29e:	160000ef          	jal	3fe <close>
  return r;
 2a2:	64a2                	ld	s1,8(sp)
}
 2a4:	854a                	mv	a0,s2
 2a6:	60e2                	ld	ra,24(sp)
 2a8:	6442                	ld	s0,16(sp)
 2aa:	6902                	ld	s2,0(sp)
 2ac:	6105                	addi	sp,sp,32
 2ae:	8082                	ret
    return -1;
 2b0:	597d                	li	s2,-1
 2b2:	bfcd                	j	2a4 <stat+0x2a>

00000000000002b4 <atoi>:

int
atoi(const char *s)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e422                	sd	s0,8(sp)
 2b8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ba:	00054683          	lbu	a3,0(a0)
 2be:	fd06879b          	addiw	a5,a3,-48
 2c2:	0ff7f793          	zext.b	a5,a5
 2c6:	4625                	li	a2,9
 2c8:	02f66863          	bltu	a2,a5,2f8 <atoi+0x44>
 2cc:	872a                	mv	a4,a0
  n = 0;
 2ce:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2d0:	0705                	addi	a4,a4,1
 2d2:	0025179b          	slliw	a5,a0,0x2
 2d6:	9fa9                	addw	a5,a5,a0
 2d8:	0017979b          	slliw	a5,a5,0x1
 2dc:	9fb5                	addw	a5,a5,a3
 2de:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2e2:	00074683          	lbu	a3,0(a4)
 2e6:	fd06879b          	addiw	a5,a3,-48
 2ea:	0ff7f793          	zext.b	a5,a5
 2ee:	fef671e3          	bgeu	a2,a5,2d0 <atoi+0x1c>
  return n;
}
 2f2:	6422                	ld	s0,8(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret
  n = 0;
 2f8:	4501                	li	a0,0
 2fa:	bfe5                	j	2f2 <atoi+0x3e>

00000000000002fc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2fc:	1141                	addi	sp,sp,-16
 2fe:	e422                	sd	s0,8(sp)
 300:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 302:	02b57463          	bgeu	a0,a1,32a <memmove+0x2e>
    while(n-- > 0)
 306:	00c05f63          	blez	a2,324 <memmove+0x28>
 30a:	1602                	slli	a2,a2,0x20
 30c:	9201                	srli	a2,a2,0x20
 30e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 312:	872a                	mv	a4,a0
      *dst++ = *src++;
 314:	0585                	addi	a1,a1,1
 316:	0705                	addi	a4,a4,1
 318:	fff5c683          	lbu	a3,-1(a1)
 31c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 320:	fef71ae3          	bne	a4,a5,314 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret
    dst += n;
 32a:	00c50733          	add	a4,a0,a2
    src += n;
 32e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 330:	fec05ae3          	blez	a2,324 <memmove+0x28>
 334:	fff6079b          	addiw	a5,a2,-1
 338:	1782                	slli	a5,a5,0x20
 33a:	9381                	srli	a5,a5,0x20
 33c:	fff7c793          	not	a5,a5
 340:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 342:	15fd                	addi	a1,a1,-1
 344:	177d                	addi	a4,a4,-1
 346:	0005c683          	lbu	a3,0(a1)
 34a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 34e:	fee79ae3          	bne	a5,a4,342 <memmove+0x46>
 352:	bfc9                	j	324 <memmove+0x28>

0000000000000354 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 354:	1141                	addi	sp,sp,-16
 356:	e422                	sd	s0,8(sp)
 358:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 35a:	ca05                	beqz	a2,38a <memcmp+0x36>
 35c:	fff6069b          	addiw	a3,a2,-1
 360:	1682                	slli	a3,a3,0x20
 362:	9281                	srli	a3,a3,0x20
 364:	0685                	addi	a3,a3,1
 366:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 368:	00054783          	lbu	a5,0(a0)
 36c:	0005c703          	lbu	a4,0(a1)
 370:	00e79863          	bne	a5,a4,380 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 374:	0505                	addi	a0,a0,1
    p2++;
 376:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 378:	fed518e3          	bne	a0,a3,368 <memcmp+0x14>
  }
  return 0;
 37c:	4501                	li	a0,0
 37e:	a019                	j	384 <memcmp+0x30>
      return *p1 - *p2;
 380:	40e7853b          	subw	a0,a5,a4
}
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret
  return 0;
 38a:	4501                	li	a0,0
 38c:	bfe5                	j	384 <memcmp+0x30>

000000000000038e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e406                	sd	ra,8(sp)
 392:	e022                	sd	s0,0(sp)
 394:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 396:	f67ff0ef          	jal	2fc <memmove>
}
 39a:	60a2                	ld	ra,8(sp)
 39c:	6402                	ld	s0,0(sp)
 39e:	0141                	addi	sp,sp,16
 3a0:	8082                	ret

00000000000003a2 <sbrk>:

char *
sbrk(int n) {
 3a2:	1141                	addi	sp,sp,-16
 3a4:	e406                	sd	ra,8(sp)
 3a6:	e022                	sd	s0,0(sp)
 3a8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3aa:	4585                	li	a1,1
 3ac:	0b2000ef          	jal	45e <sys_sbrk>
}
 3b0:	60a2                	ld	ra,8(sp)
 3b2:	6402                	ld	s0,0(sp)
 3b4:	0141                	addi	sp,sp,16
 3b6:	8082                	ret

00000000000003b8 <sbrklazy>:

char *
sbrklazy(int n) {
 3b8:	1141                	addi	sp,sp,-16
 3ba:	e406                	sd	ra,8(sp)
 3bc:	e022                	sd	s0,0(sp)
 3be:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3c0:	4589                	li	a1,2
 3c2:	09c000ef          	jal	45e <sys_sbrk>
}
 3c6:	60a2                	ld	ra,8(sp)
 3c8:	6402                	ld	s0,0(sp)
 3ca:	0141                	addi	sp,sp,16
 3cc:	8082                	ret

00000000000003ce <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ce:	4885                	li	a7,1
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d6:	4889                	li	a7,2
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <wait>:
.global wait
wait:
 li a7, SYS_wait
 3de:	488d                	li	a7,3
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e6:	4891                	li	a7,4
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <read>:
.global read
read:
 li a7, SYS_read
 3ee:	4895                	li	a7,5
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <write>:
.global write
write:
 li a7, SYS_write
 3f6:	48c1                	li	a7,16
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <close>:
.global close
close:
 li a7, SYS_close
 3fe:	48d5                	li	a7,21
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <kill>:
.global kill
kill:
 li a7, SYS_kill
 406:	4899                	li	a7,6
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <exec>:
.global exec
exec:
 li a7, SYS_exec
 40e:	489d                	li	a7,7
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <open>:
.global open
open:
 li a7, SYS_open
 416:	48bd                	li	a7,15
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 41e:	48c5                	li	a7,17
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 426:	48c9                	li	a7,18
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 42e:	48a1                	li	a7,8
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <link>:
.global link
link:
 li a7, SYS_link
 436:	48cd                	li	a7,19
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 43e:	48d1                	li	a7,20
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 446:	48a5                	li	a7,9
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <dup>:
.global dup
dup:
 li a7, SYS_dup
 44e:	48a9                	li	a7,10
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 456:	48ad                	li	a7,11
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 45e:	48b1                	li	a7,12
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <pause>:
.global pause
pause:
 li a7, SYS_pause
 466:	48b5                	li	a7,13
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 46e:	48b9                	li	a7,14
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <hello>:
.global hello
hello:
 li a7, SYS_hello
 476:	48d9                	li	a7,22
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 47e:	1101                	addi	sp,sp,-32
 480:	ec06                	sd	ra,24(sp)
 482:	e822                	sd	s0,16(sp)
 484:	1000                	addi	s0,sp,32
 486:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48a:	4605                	li	a2,1
 48c:	fef40593          	addi	a1,s0,-17
 490:	f67ff0ef          	jal	3f6 <write>
}
 494:	60e2                	ld	ra,24(sp)
 496:	6442                	ld	s0,16(sp)
 498:	6105                	addi	sp,sp,32
 49a:	8082                	ret

000000000000049c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 49c:	715d                	addi	sp,sp,-80
 49e:	e486                	sd	ra,72(sp)
 4a0:	e0a2                	sd	s0,64(sp)
 4a2:	f84a                	sd	s2,48(sp)
 4a4:	0880                	addi	s0,sp,80
 4a6:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4a8:	c299                	beqz	a3,4ae <printint+0x12>
 4aa:	0805c363          	bltz	a1,530 <printint+0x94>
  neg = 0;
 4ae:	4881                	li	a7,0
 4b0:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4b4:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4b6:	00000517          	auipc	a0,0x0
 4ba:	5ea50513          	addi	a0,a0,1514 # aa0 <digits>
 4be:	883e                	mv	a6,a5
 4c0:	2785                	addiw	a5,a5,1
 4c2:	02c5f733          	remu	a4,a1,a2
 4c6:	972a                	add	a4,a4,a0
 4c8:	00074703          	lbu	a4,0(a4)
 4cc:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4d0:	872e                	mv	a4,a1
 4d2:	02c5d5b3          	divu	a1,a1,a2
 4d6:	0685                	addi	a3,a3,1
 4d8:	fec773e3          	bgeu	a4,a2,4be <printint+0x22>
  if(neg)
 4dc:	00088b63          	beqz	a7,4f2 <printint+0x56>
    buf[i++] = '-';
 4e0:	fd078793          	addi	a5,a5,-48
 4e4:	97a2                	add	a5,a5,s0
 4e6:	02d00713          	li	a4,45
 4ea:	fee78423          	sb	a4,-24(a5)
 4ee:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4f2:	02f05a63          	blez	a5,526 <printint+0x8a>
 4f6:	fc26                	sd	s1,56(sp)
 4f8:	f44e                	sd	s3,40(sp)
 4fa:	fb840713          	addi	a4,s0,-72
 4fe:	00f704b3          	add	s1,a4,a5
 502:	fff70993          	addi	s3,a4,-1
 506:	99be                	add	s3,s3,a5
 508:	37fd                	addiw	a5,a5,-1
 50a:	1782                	slli	a5,a5,0x20
 50c:	9381                	srli	a5,a5,0x20
 50e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 512:	fff4c583          	lbu	a1,-1(s1)
 516:	854a                	mv	a0,s2
 518:	f67ff0ef          	jal	47e <putc>
  while(--i >= 0)
 51c:	14fd                	addi	s1,s1,-1
 51e:	ff349ae3          	bne	s1,s3,512 <printint+0x76>
 522:	74e2                	ld	s1,56(sp)
 524:	79a2                	ld	s3,40(sp)
}
 526:	60a6                	ld	ra,72(sp)
 528:	6406                	ld	s0,64(sp)
 52a:	7942                	ld	s2,48(sp)
 52c:	6161                	addi	sp,sp,80
 52e:	8082                	ret
    x = -xx;
 530:	40b005b3          	neg	a1,a1
    neg = 1;
 534:	4885                	li	a7,1
    x = -xx;
 536:	bfad                	j	4b0 <printint+0x14>

0000000000000538 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 538:	711d                	addi	sp,sp,-96
 53a:	ec86                	sd	ra,88(sp)
 53c:	e8a2                	sd	s0,80(sp)
 53e:	e0ca                	sd	s2,64(sp)
 540:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 542:	0005c903          	lbu	s2,0(a1)
 546:	28090663          	beqz	s2,7d2 <vprintf+0x29a>
 54a:	e4a6                	sd	s1,72(sp)
 54c:	fc4e                	sd	s3,56(sp)
 54e:	f852                	sd	s4,48(sp)
 550:	f456                	sd	s5,40(sp)
 552:	f05a                	sd	s6,32(sp)
 554:	ec5e                	sd	s7,24(sp)
 556:	e862                	sd	s8,16(sp)
 558:	e466                	sd	s9,8(sp)
 55a:	8b2a                	mv	s6,a0
 55c:	8a2e                	mv	s4,a1
 55e:	8bb2                	mv	s7,a2
  state = 0;
 560:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 562:	4481                	li	s1,0
 564:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 566:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 56a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 56e:	06c00c93          	li	s9,108
 572:	a005                	j	592 <vprintf+0x5a>
        putc(fd, c0);
 574:	85ca                	mv	a1,s2
 576:	855a                	mv	a0,s6
 578:	f07ff0ef          	jal	47e <putc>
 57c:	a019                	j	582 <vprintf+0x4a>
    } else if(state == '%'){
 57e:	03598263          	beq	s3,s5,5a2 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 582:	2485                	addiw	s1,s1,1
 584:	8726                	mv	a4,s1
 586:	009a07b3          	add	a5,s4,s1
 58a:	0007c903          	lbu	s2,0(a5)
 58e:	22090a63          	beqz	s2,7c2 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 592:	0009079b          	sext.w	a5,s2
    if(state == 0){
 596:	fe0994e3          	bnez	s3,57e <vprintf+0x46>
      if(c0 == '%'){
 59a:	fd579de3          	bne	a5,s5,574 <vprintf+0x3c>
        state = '%';
 59e:	89be                	mv	s3,a5
 5a0:	b7cd                	j	582 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5a2:	00ea06b3          	add	a3,s4,a4
 5a6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5aa:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5ac:	c681                	beqz	a3,5b4 <vprintf+0x7c>
 5ae:	9752                	add	a4,a4,s4
 5b0:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5b4:	05878363          	beq	a5,s8,5fa <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5b8:	05978d63          	beq	a5,s9,612 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5bc:	07500713          	li	a4,117
 5c0:	0ee78763          	beq	a5,a4,6ae <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5c4:	07800713          	li	a4,120
 5c8:	12e78963          	beq	a5,a4,6fa <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5cc:	07000713          	li	a4,112
 5d0:	14e78e63          	beq	a5,a4,72c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5d4:	06300713          	li	a4,99
 5d8:	18e78e63          	beq	a5,a4,774 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5dc:	07300713          	li	a4,115
 5e0:	1ae78463          	beq	a5,a4,788 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5e4:	02500713          	li	a4,37
 5e8:	04e79563          	bne	a5,a4,632 <vprintf+0xfa>
        putc(fd, '%');
 5ec:	02500593          	li	a1,37
 5f0:	855a                	mv	a0,s6
 5f2:	e8dff0ef          	jal	47e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	b769                	j	582 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5fa:	008b8913          	addi	s2,s7,8
 5fe:	4685                	li	a3,1
 600:	4629                	li	a2,10
 602:	000ba583          	lw	a1,0(s7)
 606:	855a                	mv	a0,s6
 608:	e95ff0ef          	jal	49c <printint>
 60c:	8bca                	mv	s7,s2
      state = 0;
 60e:	4981                	li	s3,0
 610:	bf8d                	j	582 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 612:	06400793          	li	a5,100
 616:	02f68963          	beq	a3,a5,648 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 61a:	06c00793          	li	a5,108
 61e:	04f68263          	beq	a3,a5,662 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 622:	07500793          	li	a5,117
 626:	0af68063          	beq	a3,a5,6c6 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 62a:	07800793          	li	a5,120
 62e:	0ef68263          	beq	a3,a5,712 <vprintf+0x1da>
        putc(fd, '%');
 632:	02500593          	li	a1,37
 636:	855a                	mv	a0,s6
 638:	e47ff0ef          	jal	47e <putc>
        putc(fd, c0);
 63c:	85ca                	mv	a1,s2
 63e:	855a                	mv	a0,s6
 640:	e3fff0ef          	jal	47e <putc>
      state = 0;
 644:	4981                	li	s3,0
 646:	bf35                	j	582 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 648:	008b8913          	addi	s2,s7,8
 64c:	4685                	li	a3,1
 64e:	4629                	li	a2,10
 650:	000bb583          	ld	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	e47ff0ef          	jal	49c <printint>
        i += 1;
 65a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 65c:	8bca                	mv	s7,s2
      state = 0;
 65e:	4981                	li	s3,0
        i += 1;
 660:	b70d                	j	582 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 662:	06400793          	li	a5,100
 666:	02f60763          	beq	a2,a5,694 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 66a:	07500793          	li	a5,117
 66e:	06f60963          	beq	a2,a5,6e0 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 672:	07800793          	li	a5,120
 676:	faf61ee3          	bne	a2,a5,632 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4681                	li	a3,0
 680:	4641                	li	a2,16
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	e15ff0ef          	jal	49c <printint>
        i += 2;
 68c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 2;
 692:	bdc5                	j	582 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 694:	008b8913          	addi	s2,s7,8
 698:	4685                	li	a3,1
 69a:	4629                	li	a2,10
 69c:	000bb583          	ld	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	dfbff0ef          	jal	49c <printint>
        i += 2;
 6a6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
        i += 2;
 6ac:	bdd9                	j	582 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4629                	li	a2,10
 6b6:	000be583          	lwu	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	de1ff0ef          	jal	49c <printint>
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	bd7d                	j	582 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c6:	008b8913          	addi	s2,s7,8
 6ca:	4681                	li	a3,0
 6cc:	4629                	li	a2,10
 6ce:	000bb583          	ld	a1,0(s7)
 6d2:	855a                	mv	a0,s6
 6d4:	dc9ff0ef          	jal	49c <printint>
        i += 1;
 6d8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
        i += 1;
 6de:	b555                	j	582 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e0:	008b8913          	addi	s2,s7,8
 6e4:	4681                	li	a3,0
 6e6:	4629                	li	a2,10
 6e8:	000bb583          	ld	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	dafff0ef          	jal	49c <printint>
        i += 2;
 6f2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
        i += 2;
 6f8:	b569                	j	582 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6fa:	008b8913          	addi	s2,s7,8
 6fe:	4681                	li	a3,0
 700:	4641                	li	a2,16
 702:	000be583          	lwu	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	d95ff0ef          	jal	49c <printint>
 70c:	8bca                	mv	s7,s2
      state = 0;
 70e:	4981                	li	s3,0
 710:	bd8d                	j	582 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 712:	008b8913          	addi	s2,s7,8
 716:	4681                	li	a3,0
 718:	4641                	li	a2,16
 71a:	000bb583          	ld	a1,0(s7)
 71e:	855a                	mv	a0,s6
 720:	d7dff0ef          	jal	49c <printint>
        i += 1;
 724:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 726:	8bca                	mv	s7,s2
      state = 0;
 728:	4981                	li	s3,0
        i += 1;
 72a:	bda1                	j	582 <vprintf+0x4a>
 72c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 72e:	008b8d13          	addi	s10,s7,8
 732:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 736:	03000593          	li	a1,48
 73a:	855a                	mv	a0,s6
 73c:	d43ff0ef          	jal	47e <putc>
  putc(fd, 'x');
 740:	07800593          	li	a1,120
 744:	855a                	mv	a0,s6
 746:	d39ff0ef          	jal	47e <putc>
 74a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 74c:	00000b97          	auipc	s7,0x0
 750:	354b8b93          	addi	s7,s7,852 # aa0 <digits>
 754:	03c9d793          	srli	a5,s3,0x3c
 758:	97de                	add	a5,a5,s7
 75a:	0007c583          	lbu	a1,0(a5)
 75e:	855a                	mv	a0,s6
 760:	d1fff0ef          	jal	47e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 764:	0992                	slli	s3,s3,0x4
 766:	397d                	addiw	s2,s2,-1
 768:	fe0916e3          	bnez	s2,754 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 76c:	8bea                	mv	s7,s10
      state = 0;
 76e:	4981                	li	s3,0
 770:	6d02                	ld	s10,0(sp)
 772:	bd01                	j	582 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 774:	008b8913          	addi	s2,s7,8
 778:	000bc583          	lbu	a1,0(s7)
 77c:	855a                	mv	a0,s6
 77e:	d01ff0ef          	jal	47e <putc>
 782:	8bca                	mv	s7,s2
      state = 0;
 784:	4981                	li	s3,0
 786:	bbf5                	j	582 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 788:	008b8993          	addi	s3,s7,8
 78c:	000bb903          	ld	s2,0(s7)
 790:	00090f63          	beqz	s2,7ae <vprintf+0x276>
        for(; *s; s++)
 794:	00094583          	lbu	a1,0(s2)
 798:	c195                	beqz	a1,7bc <vprintf+0x284>
          putc(fd, *s);
 79a:	855a                	mv	a0,s6
 79c:	ce3ff0ef          	jal	47e <putc>
        for(; *s; s++)
 7a0:	0905                	addi	s2,s2,1
 7a2:	00094583          	lbu	a1,0(s2)
 7a6:	f9f5                	bnez	a1,79a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7a8:	8bce                	mv	s7,s3
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	bbd9                	j	582 <vprintf+0x4a>
          s = "(null)";
 7ae:	00000917          	auipc	s2,0x0
 7b2:	2ea90913          	addi	s2,s2,746 # a98 <malloc+0x1de>
        for(; *s; s++)
 7b6:	02800593          	li	a1,40
 7ba:	b7c5                	j	79a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7bc:	8bce                	mv	s7,s3
      state = 0;
 7be:	4981                	li	s3,0
 7c0:	b3c9                	j	582 <vprintf+0x4a>
 7c2:	64a6                	ld	s1,72(sp)
 7c4:	79e2                	ld	s3,56(sp)
 7c6:	7a42                	ld	s4,48(sp)
 7c8:	7aa2                	ld	s5,40(sp)
 7ca:	7b02                	ld	s6,32(sp)
 7cc:	6be2                	ld	s7,24(sp)
 7ce:	6c42                	ld	s8,16(sp)
 7d0:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7d2:	60e6                	ld	ra,88(sp)
 7d4:	6446                	ld	s0,80(sp)
 7d6:	6906                	ld	s2,64(sp)
 7d8:	6125                	addi	sp,sp,96
 7da:	8082                	ret

00000000000007dc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7dc:	715d                	addi	sp,sp,-80
 7de:	ec06                	sd	ra,24(sp)
 7e0:	e822                	sd	s0,16(sp)
 7e2:	1000                	addi	s0,sp,32
 7e4:	e010                	sd	a2,0(s0)
 7e6:	e414                	sd	a3,8(s0)
 7e8:	e818                	sd	a4,16(s0)
 7ea:	ec1c                	sd	a5,24(s0)
 7ec:	03043023          	sd	a6,32(s0)
 7f0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7f4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f8:	8622                	mv	a2,s0
 7fa:	d3fff0ef          	jal	538 <vprintf>
}
 7fe:	60e2                	ld	ra,24(sp)
 800:	6442                	ld	s0,16(sp)
 802:	6161                	addi	sp,sp,80
 804:	8082                	ret

0000000000000806 <printf>:

void
printf(const char *fmt, ...)
{
 806:	711d                	addi	sp,sp,-96
 808:	ec06                	sd	ra,24(sp)
 80a:	e822                	sd	s0,16(sp)
 80c:	1000                	addi	s0,sp,32
 80e:	e40c                	sd	a1,8(s0)
 810:	e810                	sd	a2,16(s0)
 812:	ec14                	sd	a3,24(s0)
 814:	f018                	sd	a4,32(s0)
 816:	f41c                	sd	a5,40(s0)
 818:	03043823          	sd	a6,48(s0)
 81c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 820:	00840613          	addi	a2,s0,8
 824:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 828:	85aa                	mv	a1,a0
 82a:	4505                	li	a0,1
 82c:	d0dff0ef          	jal	538 <vprintf>
}
 830:	60e2                	ld	ra,24(sp)
 832:	6442                	ld	s0,16(sp)
 834:	6125                	addi	sp,sp,96
 836:	8082                	ret

0000000000000838 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 838:	1141                	addi	sp,sp,-16
 83a:	e422                	sd	s0,8(sp)
 83c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 83e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 842:	00000797          	auipc	a5,0x0
 846:	7be7b783          	ld	a5,1982(a5) # 1000 <freep>
 84a:	a02d                	j	874 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 84c:	4618                	lw	a4,8(a2)
 84e:	9f2d                	addw	a4,a4,a1
 850:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 854:	6398                	ld	a4,0(a5)
 856:	6310                	ld	a2,0(a4)
 858:	a83d                	j	896 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 85a:	ff852703          	lw	a4,-8(a0)
 85e:	9f31                	addw	a4,a4,a2
 860:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 862:	ff053683          	ld	a3,-16(a0)
 866:	a091                	j	8aa <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 868:	6398                	ld	a4,0(a5)
 86a:	00e7e463          	bltu	a5,a4,872 <free+0x3a>
 86e:	00e6ea63          	bltu	a3,a4,882 <free+0x4a>
{
 872:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 874:	fed7fae3          	bgeu	a5,a3,868 <free+0x30>
 878:	6398                	ld	a4,0(a5)
 87a:	00e6e463          	bltu	a3,a4,882 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87e:	fee7eae3          	bltu	a5,a4,872 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 882:	ff852583          	lw	a1,-8(a0)
 886:	6390                	ld	a2,0(a5)
 888:	02059813          	slli	a6,a1,0x20
 88c:	01c85713          	srli	a4,a6,0x1c
 890:	9736                	add	a4,a4,a3
 892:	fae60de3          	beq	a2,a4,84c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 896:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 89a:	4790                	lw	a2,8(a5)
 89c:	02061593          	slli	a1,a2,0x20
 8a0:	01c5d713          	srli	a4,a1,0x1c
 8a4:	973e                	add	a4,a4,a5
 8a6:	fae68ae3          	beq	a3,a4,85a <free+0x22>
    p->s.ptr = bp->s.ptr;
 8aa:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8ac:	00000717          	auipc	a4,0x0
 8b0:	74f73a23          	sd	a5,1876(a4) # 1000 <freep>
}
 8b4:	6422                	ld	s0,8(sp)
 8b6:	0141                	addi	sp,sp,16
 8b8:	8082                	ret

00000000000008ba <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ba:	7139                	addi	sp,sp,-64
 8bc:	fc06                	sd	ra,56(sp)
 8be:	f822                	sd	s0,48(sp)
 8c0:	f426                	sd	s1,40(sp)
 8c2:	ec4e                	sd	s3,24(sp)
 8c4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c6:	02051493          	slli	s1,a0,0x20
 8ca:	9081                	srli	s1,s1,0x20
 8cc:	04bd                	addi	s1,s1,15
 8ce:	8091                	srli	s1,s1,0x4
 8d0:	0014899b          	addiw	s3,s1,1
 8d4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d6:	00000517          	auipc	a0,0x0
 8da:	72a53503          	ld	a0,1834(a0) # 1000 <freep>
 8de:	c915                	beqz	a0,912 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e2:	4798                	lw	a4,8(a5)
 8e4:	08977a63          	bgeu	a4,s1,978 <malloc+0xbe>
 8e8:	f04a                	sd	s2,32(sp)
 8ea:	e852                	sd	s4,16(sp)
 8ec:	e456                	sd	s5,8(sp)
 8ee:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8f0:	8a4e                	mv	s4,s3
 8f2:	0009871b          	sext.w	a4,s3
 8f6:	6685                	lui	a3,0x1
 8f8:	00d77363          	bgeu	a4,a3,8fe <malloc+0x44>
 8fc:	6a05                	lui	s4,0x1
 8fe:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 902:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 906:	00000917          	auipc	s2,0x0
 90a:	6fa90913          	addi	s2,s2,1786 # 1000 <freep>
  if(p == SBRK_ERROR)
 90e:	5afd                	li	s5,-1
 910:	a081                	j	950 <malloc+0x96>
 912:	f04a                	sd	s2,32(sp)
 914:	e852                	sd	s4,16(sp)
 916:	e456                	sd	s5,8(sp)
 918:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 91a:	00000797          	auipc	a5,0x0
 91e:	6f678793          	addi	a5,a5,1782 # 1010 <base>
 922:	00000717          	auipc	a4,0x0
 926:	6cf73f23          	sd	a5,1758(a4) # 1000 <freep>
 92a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 92c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 930:	b7c1                	j	8f0 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 932:	6398                	ld	a4,0(a5)
 934:	e118                	sd	a4,0(a0)
 936:	a8a9                	j	990 <malloc+0xd6>
  hp->s.size = nu;
 938:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 93c:	0541                	addi	a0,a0,16
 93e:	efbff0ef          	jal	838 <free>
  return freep;
 942:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 946:	c12d                	beqz	a0,9a8 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 948:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 94a:	4798                	lw	a4,8(a5)
 94c:	02977263          	bgeu	a4,s1,970 <malloc+0xb6>
    if(p == freep)
 950:	00093703          	ld	a4,0(s2)
 954:	853e                	mv	a0,a5
 956:	fef719e3          	bne	a4,a5,948 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 95a:	8552                	mv	a0,s4
 95c:	a47ff0ef          	jal	3a2 <sbrk>
  if(p == SBRK_ERROR)
 960:	fd551ce3          	bne	a0,s5,938 <malloc+0x7e>
        return 0;
 964:	4501                	li	a0,0
 966:	7902                	ld	s2,32(sp)
 968:	6a42                	ld	s4,16(sp)
 96a:	6aa2                	ld	s5,8(sp)
 96c:	6b02                	ld	s6,0(sp)
 96e:	a03d                	j	99c <malloc+0xe2>
 970:	7902                	ld	s2,32(sp)
 972:	6a42                	ld	s4,16(sp)
 974:	6aa2                	ld	s5,8(sp)
 976:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 978:	fae48de3          	beq	s1,a4,932 <malloc+0x78>
        p->s.size -= nunits;
 97c:	4137073b          	subw	a4,a4,s3
 980:	c798                	sw	a4,8(a5)
        p += p->s.size;
 982:	02071693          	slli	a3,a4,0x20
 986:	01c6d713          	srli	a4,a3,0x1c
 98a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 98c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 990:	00000717          	auipc	a4,0x0
 994:	66a73823          	sd	a0,1648(a4) # 1000 <freep>
      return (void*)(p + 1);
 998:	01078513          	addi	a0,a5,16
  }
}
 99c:	70e2                	ld	ra,56(sp)
 99e:	7442                	ld	s0,48(sp)
 9a0:	74a2                	ld	s1,40(sp)
 9a2:	69e2                	ld	s3,24(sp)
 9a4:	6121                	addi	sp,sp,64
 9a6:	8082                	ret
 9a8:	7902                	ld	s2,32(sp)
 9aa:	6a42                	ld	s4,16(sp)
 9ac:	6aa2                	ld	s5,8(sp)
 9ae:	6b02                	ld	s6,0(sp)
 9b0:	b7f5                	j	99c <malloc+0xe2>
