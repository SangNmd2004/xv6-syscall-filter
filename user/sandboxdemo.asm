
user/_sandboxdemo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_sandbox>:
// Ví dụ: SYS_read là 5, SYS_write là 16, SYS_open là 15, v.v.
// Ở đây ta sử dụng một mask mô phỏng: 
// 1 << 5 (read), 1 << 16 (write), 1 << 2 (exit), 1 << 1 (fork)
#define MASK_SAFE ((1 << 2) | (1 << 16) | (1 << 5)) 

void test_sandbox() {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
    int pid = fork();
   8:	378000ef          	jal	380 <fork>

    if (pid < 0) {
   c:	06054563          	bltz	a0,76 <test_sandbox+0x76>
        printf("Sandbox: Fork failed\n");
        exit(1);
    }

    if (pid == 0) {
  10:	e549                	bnez	a0,9a <test_sandbox+0x9a>
        // --- Tiến trình con (Target Sandbox) ---
        printf("\n[Child] Start setting up the Sandbox...\n");
  12:	00001517          	auipc	a0,0x1
  16:	a8e50513          	addi	a0,a0,-1394 # aa0 <filter_debug_status+0xb0>
  1a:	7ae000ef          	jal	7c8 <printf>

        // Áp dụng bộ lọc: chỉ cho phép read, write và exit
        if (setfilter(MASK_SAFE) < 0) {
  1e:	6541                	lui	a0,0x10
  20:	02450513          	addi	a0,a0,36 # 10024 <base+0xe014>
  24:	404000ef          	jal	428 <setfilter>
  28:	06054063          	bltz	a0,88 <test_sandbox+0x88>
            printf("[Child] Error: Unable to set the filter!\n");
            exit(1);
        }

        printf("[Child] Sandbox is active. Testing write operation (Allowed)...\n");
  2c:	00001517          	auipc	a0,0x1
  30:	ad450513          	addi	a0,a0,-1324 # b00 <filter_debug_status+0x110>
  34:	794000ef          	jal	7c8 <printf>
        write(1, "[Child] Write operation succeeded!\n", 34);
  38:	02200613          	li	a2,34
  3c:	00001597          	auipc	a1,0x1
  40:	b0c58593          	addi	a1,a1,-1268 # b48 <filter_debug_status+0x158>
  44:	4505                	li	a0,1
  46:	362000ef          	jal	3a8 <write>

        printf("[Child] Testing open operation (Forbidden)...\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	b2650513          	addi	a0,a0,-1242 # b70 <filter_debug_status+0x180>
  52:	776000ef          	jal	7c8 <printf>
        // Hệ thống sẽ gửi SIGKILL hoặc trả về lỗi tùy vào cách bạn xử lý trong kernel
        open("secret.txt", 0); 
  56:	4581                	li	a1,0
  58:	00001517          	auipc	a0,0x1
  5c:	b4850513          	addi	a0,a0,-1208 # ba0 <filter_debug_status+0x1b0>
  60:	368000ef          	jal	3c8 <open>

        printf("[Child] Error: You should not see this line if the sandbox is working!\n");
  64:	00001517          	auipc	a0,0x1
  68:	b4c50513          	addi	a0,a0,-1204 # bb0 <filter_debug_status+0x1c0>
  6c:	75c000ef          	jal	7c8 <printf>
        exit(0);
  70:	4501                	li	a0,0
  72:	316000ef          	jal	388 <exit>
        printf("Sandbox: Fork failed\n");
  76:	00001517          	auipc	a0,0x1
  7a:	a0a50513          	addi	a0,a0,-1526 # a80 <filter_debug_status+0x90>
  7e:	74a000ef          	jal	7c8 <printf>
        exit(1);
  82:	4505                	li	a0,1
  84:	304000ef          	jal	388 <exit>
            printf("[Child] Error: Unable to set the filter!\n");
  88:	00001517          	auipc	a0,0x1
  8c:	a4850513          	addi	a0,a0,-1464 # ad0 <filter_debug_status+0xe0>
  90:	738000ef          	jal	7c8 <printf>
            exit(1);
  94:	4505                	li	a0,1
  96:	2f2000ef          	jal	388 <exit>
    } else {
        // --- Tiến trình cha ---
        int status;
        wait(&status);
  9a:	fec40513          	addi	a0,s0,-20
  9e:	2f2000ef          	jal	390 <wait>
        printf("\n[Parent] Target process has finished.\n");
  a2:	00001517          	auipc	a0,0x1
  a6:	b5650513          	addi	a0,a0,-1194 # bf8 <filter_debug_status+0x208>
  aa:	71e000ef          	jal	7c8 <printf>
        if (status != 0) {
  ae:	fec42783          	lw	a5,-20(s0)
  b2:	cb99                	beqz	a5,c8 <test_sandbox+0xc8>
            printf("[Parent] Identification: Child process was killed for violating the Sandbox.\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	b6c50513          	addi	a0,a0,-1172 # c20 <filter_debug_status+0x230>
  bc:	70c000ef          	jal	7c8 <printf>
        } else {
            printf("[Parent] Child process completed safely.\n");
        }
    }
}
  c0:	60e2                	ld	ra,24(sp)
  c2:	6442                	ld	s0,16(sp)
  c4:	6105                	addi	sp,sp,32
  c6:	8082                	ret
            printf("[Parent] Child process completed safely.\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	ba850513          	addi	a0,a0,-1112 # c70 <filter_debug_status+0x280>
  d0:	6f8000ef          	jal	7c8 <printf>
}
  d4:	b7f5                	j	c0 <test_sandbox+0xc0>

00000000000000d6 <main>:

int main(int argc, char *argv[]) {
  d6:	1141                	addi	sp,sp,-16
  d8:	e406                	sd	ra,8(sp)
  da:	e022                	sd	s0,0(sp)
  dc:	0800                	addi	s0,sp,16
    printf("--- SANDBOX DEMO ON XV6 ---\n");
  de:	00001517          	auipc	a0,0x1
  e2:	bc250513          	addi	a0,a0,-1086 # ca0 <filter_debug_status+0x2b0>
  e6:	6e2000ef          	jal	7c8 <printf>
    test_sandbox();
  ea:	f17ff0ef          	jal	0 <test_sandbox>
    exit(0);
  ee:	4501                	li	a0,0
  f0:	298000ef          	jal	388 <exit>

00000000000000f4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e406                	sd	ra,8(sp)
  f8:	e022                	sd	s0,0(sp)
  fa:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  fc:	fdbff0ef          	jal	d6 <main>
  exit(r);
 100:	288000ef          	jal	388 <exit>

0000000000000104 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10a:	87aa                	mv	a5,a0
 10c:	0585                	addi	a1,a1,1
 10e:	0785                	addi	a5,a5,1
 110:	fff5c703          	lbu	a4,-1(a1)
 114:	fee78fa3          	sb	a4,-1(a5)
 118:	fb75                	bnez	a4,10c <strcpy+0x8>
    ;
  return os;
}
 11a:	6422                	ld	s0,8(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret

0000000000000120 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 120:	1141                	addi	sp,sp,-16
 122:	e422                	sd	s0,8(sp)
 124:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 126:	00054783          	lbu	a5,0(a0)
 12a:	cb91                	beqz	a5,13e <strcmp+0x1e>
 12c:	0005c703          	lbu	a4,0(a1)
 130:	00f71763          	bne	a4,a5,13e <strcmp+0x1e>
    p++, q++;
 134:	0505                	addi	a0,a0,1
 136:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 138:	00054783          	lbu	a5,0(a0)
 13c:	fbe5                	bnez	a5,12c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 13e:	0005c503          	lbu	a0,0(a1)
}
 142:	40a7853b          	subw	a0,a5,a0
 146:	6422                	ld	s0,8(sp)
 148:	0141                	addi	sp,sp,16
 14a:	8082                	ret

000000000000014c <strlen>:

uint
strlen(const char *s)
{
 14c:	1141                	addi	sp,sp,-16
 14e:	e422                	sd	s0,8(sp)
 150:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 152:	00054783          	lbu	a5,0(a0)
 156:	cf91                	beqz	a5,172 <strlen+0x26>
 158:	0505                	addi	a0,a0,1
 15a:	87aa                	mv	a5,a0
 15c:	86be                	mv	a3,a5
 15e:	0785                	addi	a5,a5,1
 160:	fff7c703          	lbu	a4,-1(a5)
 164:	ff65                	bnez	a4,15c <strlen+0x10>
 166:	40a6853b          	subw	a0,a3,a0
 16a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 16c:	6422                	ld	s0,8(sp)
 16e:	0141                	addi	sp,sp,16
 170:	8082                	ret
  for(n = 0; s[n]; n++)
 172:	4501                	li	a0,0
 174:	bfe5                	j	16c <strlen+0x20>

0000000000000176 <memset>:

void*
memset(void *dst, int c, uint n)
{
 176:	1141                	addi	sp,sp,-16
 178:	e422                	sd	s0,8(sp)
 17a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 17c:	ca19                	beqz	a2,192 <memset+0x1c>
 17e:	87aa                	mv	a5,a0
 180:	1602                	slli	a2,a2,0x20
 182:	9201                	srli	a2,a2,0x20
 184:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 188:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 18c:	0785                	addi	a5,a5,1
 18e:	fee79de3          	bne	a5,a4,188 <memset+0x12>
  }
  return dst;
}
 192:	6422                	ld	s0,8(sp)
 194:	0141                	addi	sp,sp,16
 196:	8082                	ret

0000000000000198 <strchr>:

char*
strchr(const char *s, char c)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	cb99                	beqz	a5,1b8 <strchr+0x20>
    if(*s == c)
 1a4:	00f58763          	beq	a1,a5,1b2 <strchr+0x1a>
  for(; *s; s++)
 1a8:	0505                	addi	a0,a0,1
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	fbfd                	bnez	a5,1a4 <strchr+0xc>
      return (char*)s;
  return 0;
 1b0:	4501                	li	a0,0
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret
  return 0;
 1b8:	4501                	li	a0,0
 1ba:	bfe5                	j	1b2 <strchr+0x1a>

00000000000001bc <gets>:

char*
gets(char *buf, int max)
{
 1bc:	711d                	addi	sp,sp,-96
 1be:	ec86                	sd	ra,88(sp)
 1c0:	e8a2                	sd	s0,80(sp)
 1c2:	e4a6                	sd	s1,72(sp)
 1c4:	e0ca                	sd	s2,64(sp)
 1c6:	fc4e                	sd	s3,56(sp)
 1c8:	f852                	sd	s4,48(sp)
 1ca:	f456                	sd	s5,40(sp)
 1cc:	f05a                	sd	s6,32(sp)
 1ce:	ec5e                	sd	s7,24(sp)
 1d0:	1080                	addi	s0,sp,96
 1d2:	8baa                	mv	s7,a0
 1d4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d6:	892a                	mv	s2,a0
 1d8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1da:	4aa9                	li	s5,10
 1dc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1de:	89a6                	mv	s3,s1
 1e0:	2485                	addiw	s1,s1,1
 1e2:	0344d663          	bge	s1,s4,20e <gets+0x52>
    cc = read(0, &c, 1);
 1e6:	4605                	li	a2,1
 1e8:	faf40593          	addi	a1,s0,-81
 1ec:	4501                	li	a0,0
 1ee:	1b2000ef          	jal	3a0 <read>
    if(cc < 1)
 1f2:	00a05e63          	blez	a0,20e <gets+0x52>
    buf[i++] = c;
 1f6:	faf44783          	lbu	a5,-81(s0)
 1fa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fe:	01578763          	beq	a5,s5,20c <gets+0x50>
 202:	0905                	addi	s2,s2,1
 204:	fd679de3          	bne	a5,s6,1de <gets+0x22>
    buf[i++] = c;
 208:	89a6                	mv	s3,s1
 20a:	a011                	j	20e <gets+0x52>
 20c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 20e:	99de                	add	s3,s3,s7
 210:	00098023          	sb	zero,0(s3)
  return buf;
}
 214:	855e                	mv	a0,s7
 216:	60e6                	ld	ra,88(sp)
 218:	6446                	ld	s0,80(sp)
 21a:	64a6                	ld	s1,72(sp)
 21c:	6906                	ld	s2,64(sp)
 21e:	79e2                	ld	s3,56(sp)
 220:	7a42                	ld	s4,48(sp)
 222:	7aa2                	ld	s5,40(sp)
 224:	7b02                	ld	s6,32(sp)
 226:	6be2                	ld	s7,24(sp)
 228:	6125                	addi	sp,sp,96
 22a:	8082                	ret

000000000000022c <stat>:

int
stat(const char *n, struct stat *st)
{
 22c:	1101                	addi	sp,sp,-32
 22e:	ec06                	sd	ra,24(sp)
 230:	e822                	sd	s0,16(sp)
 232:	e04a                	sd	s2,0(sp)
 234:	1000                	addi	s0,sp,32
 236:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 238:	4581                	li	a1,0
 23a:	18e000ef          	jal	3c8 <open>
  if(fd < 0)
 23e:	02054263          	bltz	a0,262 <stat+0x36>
 242:	e426                	sd	s1,8(sp)
 244:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 246:	85ca                	mv	a1,s2
 248:	198000ef          	jal	3e0 <fstat>
 24c:	892a                	mv	s2,a0
  close(fd);
 24e:	8526                	mv	a0,s1
 250:	160000ef          	jal	3b0 <close>
  return r;
 254:	64a2                	ld	s1,8(sp)
}
 256:	854a                	mv	a0,s2
 258:	60e2                	ld	ra,24(sp)
 25a:	6442                	ld	s0,16(sp)
 25c:	6902                	ld	s2,0(sp)
 25e:	6105                	addi	sp,sp,32
 260:	8082                	ret
    return -1;
 262:	597d                	li	s2,-1
 264:	bfcd                	j	256 <stat+0x2a>

0000000000000266 <atoi>:

int
atoi(const char *s)
{
 266:	1141                	addi	sp,sp,-16
 268:	e422                	sd	s0,8(sp)
 26a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 26c:	00054683          	lbu	a3,0(a0)
 270:	fd06879b          	addiw	a5,a3,-48
 274:	0ff7f793          	zext.b	a5,a5
 278:	4625                	li	a2,9
 27a:	02f66863          	bltu	a2,a5,2aa <atoi+0x44>
 27e:	872a                	mv	a4,a0
  n = 0;
 280:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 282:	0705                	addi	a4,a4,1
 284:	0025179b          	slliw	a5,a0,0x2
 288:	9fa9                	addw	a5,a5,a0
 28a:	0017979b          	slliw	a5,a5,0x1
 28e:	9fb5                	addw	a5,a5,a3
 290:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 294:	00074683          	lbu	a3,0(a4)
 298:	fd06879b          	addiw	a5,a3,-48
 29c:	0ff7f793          	zext.b	a5,a5
 2a0:	fef671e3          	bgeu	a2,a5,282 <atoi+0x1c>
  return n;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret
  n = 0;
 2aa:	4501                	li	a0,0
 2ac:	bfe5                	j	2a4 <atoi+0x3e>

00000000000002ae <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e422                	sd	s0,8(sp)
 2b2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b4:	02b57463          	bgeu	a0,a1,2dc <memmove+0x2e>
    while(n-- > 0)
 2b8:	00c05f63          	blez	a2,2d6 <memmove+0x28>
 2bc:	1602                	slli	a2,a2,0x20
 2be:	9201                	srli	a2,a2,0x20
 2c0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c6:	0585                	addi	a1,a1,1
 2c8:	0705                	addi	a4,a4,1
 2ca:	fff5c683          	lbu	a3,-1(a1)
 2ce:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d2:	fef71ae3          	bne	a4,a5,2c6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret
    dst += n;
 2dc:	00c50733          	add	a4,a0,a2
    src += n;
 2e0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e2:	fec05ae3          	blez	a2,2d6 <memmove+0x28>
 2e6:	fff6079b          	addiw	a5,a2,-1
 2ea:	1782                	slli	a5,a5,0x20
 2ec:	9381                	srli	a5,a5,0x20
 2ee:	fff7c793          	not	a5,a5
 2f2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f4:	15fd                	addi	a1,a1,-1
 2f6:	177d                	addi	a4,a4,-1
 2f8:	0005c683          	lbu	a3,0(a1)
 2fc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 300:	fee79ae3          	bne	a5,a4,2f4 <memmove+0x46>
 304:	bfc9                	j	2d6 <memmove+0x28>

0000000000000306 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 306:	1141                	addi	sp,sp,-16
 308:	e422                	sd	s0,8(sp)
 30a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 30c:	ca05                	beqz	a2,33c <memcmp+0x36>
 30e:	fff6069b          	addiw	a3,a2,-1
 312:	1682                	slli	a3,a3,0x20
 314:	9281                	srli	a3,a3,0x20
 316:	0685                	addi	a3,a3,1
 318:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 31a:	00054783          	lbu	a5,0(a0)
 31e:	0005c703          	lbu	a4,0(a1)
 322:	00e79863          	bne	a5,a4,332 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 326:	0505                	addi	a0,a0,1
    p2++;
 328:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 32a:	fed518e3          	bne	a0,a3,31a <memcmp+0x14>
  }
  return 0;
 32e:	4501                	li	a0,0
 330:	a019                	j	336 <memcmp+0x30>
      return *p1 - *p2;
 332:	40e7853b          	subw	a0,a5,a4
}
 336:	6422                	ld	s0,8(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret
  return 0;
 33c:	4501                	li	a0,0
 33e:	bfe5                	j	336 <memcmp+0x30>

0000000000000340 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 340:	1141                	addi	sp,sp,-16
 342:	e406                	sd	ra,8(sp)
 344:	e022                	sd	s0,0(sp)
 346:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 348:	f67ff0ef          	jal	2ae <memmove>
}
 34c:	60a2                	ld	ra,8(sp)
 34e:	6402                	ld	s0,0(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <sbrk>:

char *
sbrk(int n) {
 354:	1141                	addi	sp,sp,-16
 356:	e406                	sd	ra,8(sp)
 358:	e022                	sd	s0,0(sp)
 35a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 35c:	4585                	li	a1,1
 35e:	0b2000ef          	jal	410 <sys_sbrk>
}
 362:	60a2                	ld	ra,8(sp)
 364:	6402                	ld	s0,0(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret

000000000000036a <sbrklazy>:

char *
sbrklazy(int n) {
 36a:	1141                	addi	sp,sp,-16
 36c:	e406                	sd	ra,8(sp)
 36e:	e022                	sd	s0,0(sp)
 370:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 372:	4589                	li	a1,2
 374:	09c000ef          	jal	410 <sys_sbrk>
}
 378:	60a2                	ld	ra,8(sp)
 37a:	6402                	ld	s0,0(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret

0000000000000380 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 380:	4885                	li	a7,1
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <exit>:
.global exit
exit:
 li a7, SYS_exit
 388:	4889                	li	a7,2
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <wait>:
.global wait
wait:
 li a7, SYS_wait
 390:	488d                	li	a7,3
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 398:	4891                	li	a7,4
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <read>:
.global read
read:
 li a7, SYS_read
 3a0:	4895                	li	a7,5
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <write>:
.global write
write:
 li a7, SYS_write
 3a8:	48c1                	li	a7,16
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <close>:
.global close
close:
 li a7, SYS_close
 3b0:	48d5                	li	a7,21
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b8:	4899                	li	a7,6
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c0:	489d                	li	a7,7
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <open>:
.global open
open:
 li a7, SYS_open
 3c8:	48bd                	li	a7,15
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d0:	48c5                	li	a7,17
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d8:	48c9                	li	a7,18
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e0:	48a1                	li	a7,8
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <link>:
.global link
link:
 li a7, SYS_link
 3e8:	48cd                	li	a7,19
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f0:	48d1                	li	a7,20
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f8:	48a5                	li	a7,9
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <dup>:
.global dup
dup:
 li a7, SYS_dup
 400:	48a9                	li	a7,10
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 408:	48ad                	li	a7,11
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 410:	48b1                	li	a7,12
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <pause>:
.global pause
pause:
 li a7, SYS_pause
 418:	48b5                	li	a7,13
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 420:	48b9                	li	a7,14
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <setfilter>:
.global setfilter
setfilter:
 li a7, SYS_setfilter
 428:	48dd                	li	a7,23
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <getfilter>:
.global getfilter
getfilter:
 li a7, SYS_getfilter
 430:	48e1                	li	a7,24
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <setfilter_child>:
.global setfilter_child
setfilter_child:
 li a7, SYS_setfilter_child
 438:	48e5                	li	a7,25
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 440:	1101                	addi	sp,sp,-32
 442:	ec06                	sd	ra,24(sp)
 444:	e822                	sd	s0,16(sp)
 446:	1000                	addi	s0,sp,32
 448:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 44c:	4605                	li	a2,1
 44e:	fef40593          	addi	a1,s0,-17
 452:	f57ff0ef          	jal	3a8 <write>
}
 456:	60e2                	ld	ra,24(sp)
 458:	6442                	ld	s0,16(sp)
 45a:	6105                	addi	sp,sp,32
 45c:	8082                	ret

000000000000045e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 45e:	715d                	addi	sp,sp,-80
 460:	e486                	sd	ra,72(sp)
 462:	e0a2                	sd	s0,64(sp)
 464:	f84a                	sd	s2,48(sp)
 466:	0880                	addi	s0,sp,80
 468:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 46a:	c299                	beqz	a3,470 <printint+0x12>
 46c:	0805c363          	bltz	a1,4f2 <printint+0x94>
  neg = 0;
 470:	4881                	li	a7,0
 472:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 476:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 478:	00001517          	auipc	a0,0x1
 47c:	91850513          	addi	a0,a0,-1768 # d90 <digits>
 480:	883e                	mv	a6,a5
 482:	2785                	addiw	a5,a5,1
 484:	02c5f733          	remu	a4,a1,a2
 488:	972a                	add	a4,a4,a0
 48a:	00074703          	lbu	a4,0(a4)
 48e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 492:	872e                	mv	a4,a1
 494:	02c5d5b3          	divu	a1,a1,a2
 498:	0685                	addi	a3,a3,1
 49a:	fec773e3          	bgeu	a4,a2,480 <printint+0x22>
  if(neg)
 49e:	00088b63          	beqz	a7,4b4 <printint+0x56>
    buf[i++] = '-';
 4a2:	fd078793          	addi	a5,a5,-48
 4a6:	97a2                	add	a5,a5,s0
 4a8:	02d00713          	li	a4,45
 4ac:	fee78423          	sb	a4,-24(a5)
 4b0:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4b4:	02f05a63          	blez	a5,4e8 <printint+0x8a>
 4b8:	fc26                	sd	s1,56(sp)
 4ba:	f44e                	sd	s3,40(sp)
 4bc:	fb840713          	addi	a4,s0,-72
 4c0:	00f704b3          	add	s1,a4,a5
 4c4:	fff70993          	addi	s3,a4,-1
 4c8:	99be                	add	s3,s3,a5
 4ca:	37fd                	addiw	a5,a5,-1
 4cc:	1782                	slli	a5,a5,0x20
 4ce:	9381                	srli	a5,a5,0x20
 4d0:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4d4:	fff4c583          	lbu	a1,-1(s1)
 4d8:	854a                	mv	a0,s2
 4da:	f67ff0ef          	jal	440 <putc>
  while(--i >= 0)
 4de:	14fd                	addi	s1,s1,-1
 4e0:	ff349ae3          	bne	s1,s3,4d4 <printint+0x76>
 4e4:	74e2                	ld	s1,56(sp)
 4e6:	79a2                	ld	s3,40(sp)
}
 4e8:	60a6                	ld	ra,72(sp)
 4ea:	6406                	ld	s0,64(sp)
 4ec:	7942                	ld	s2,48(sp)
 4ee:	6161                	addi	sp,sp,80
 4f0:	8082                	ret
    x = -xx;
 4f2:	40b005b3          	neg	a1,a1
    neg = 1;
 4f6:	4885                	li	a7,1
    x = -xx;
 4f8:	bfad                	j	472 <printint+0x14>

00000000000004fa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4fa:	711d                	addi	sp,sp,-96
 4fc:	ec86                	sd	ra,88(sp)
 4fe:	e8a2                	sd	s0,80(sp)
 500:	e0ca                	sd	s2,64(sp)
 502:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 504:	0005c903          	lbu	s2,0(a1)
 508:	28090663          	beqz	s2,794 <vprintf+0x29a>
 50c:	e4a6                	sd	s1,72(sp)
 50e:	fc4e                	sd	s3,56(sp)
 510:	f852                	sd	s4,48(sp)
 512:	f456                	sd	s5,40(sp)
 514:	f05a                	sd	s6,32(sp)
 516:	ec5e                	sd	s7,24(sp)
 518:	e862                	sd	s8,16(sp)
 51a:	e466                	sd	s9,8(sp)
 51c:	8b2a                	mv	s6,a0
 51e:	8a2e                	mv	s4,a1
 520:	8bb2                	mv	s7,a2
  state = 0;
 522:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 524:	4481                	li	s1,0
 526:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 528:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 52c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 530:	06c00c93          	li	s9,108
 534:	a005                	j	554 <vprintf+0x5a>
        putc(fd, c0);
 536:	85ca                	mv	a1,s2
 538:	855a                	mv	a0,s6
 53a:	f07ff0ef          	jal	440 <putc>
 53e:	a019                	j	544 <vprintf+0x4a>
    } else if(state == '%'){
 540:	03598263          	beq	s3,s5,564 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 544:	2485                	addiw	s1,s1,1
 546:	8726                	mv	a4,s1
 548:	009a07b3          	add	a5,s4,s1
 54c:	0007c903          	lbu	s2,0(a5)
 550:	22090a63          	beqz	s2,784 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 554:	0009079b          	sext.w	a5,s2
    if(state == 0){
 558:	fe0994e3          	bnez	s3,540 <vprintf+0x46>
      if(c0 == '%'){
 55c:	fd579de3          	bne	a5,s5,536 <vprintf+0x3c>
        state = '%';
 560:	89be                	mv	s3,a5
 562:	b7cd                	j	544 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 564:	00ea06b3          	add	a3,s4,a4
 568:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 56c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 56e:	c681                	beqz	a3,576 <vprintf+0x7c>
 570:	9752                	add	a4,a4,s4
 572:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 576:	05878363          	beq	a5,s8,5bc <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 57a:	05978d63          	beq	a5,s9,5d4 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 57e:	07500713          	li	a4,117
 582:	0ee78763          	beq	a5,a4,670 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 586:	07800713          	li	a4,120
 58a:	12e78963          	beq	a5,a4,6bc <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 58e:	07000713          	li	a4,112
 592:	14e78e63          	beq	a5,a4,6ee <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 596:	06300713          	li	a4,99
 59a:	18e78e63          	beq	a5,a4,736 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 59e:	07300713          	li	a4,115
 5a2:	1ae78463          	beq	a5,a4,74a <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5a6:	02500713          	li	a4,37
 5aa:	04e79563          	bne	a5,a4,5f4 <vprintf+0xfa>
        putc(fd, '%');
 5ae:	02500593          	li	a1,37
 5b2:	855a                	mv	a0,s6
 5b4:	e8dff0ef          	jal	440 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	b769                	j	544 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5bc:	008b8913          	addi	s2,s7,8
 5c0:	4685                	li	a3,1
 5c2:	4629                	li	a2,10
 5c4:	000ba583          	lw	a1,0(s7)
 5c8:	855a                	mv	a0,s6
 5ca:	e95ff0ef          	jal	45e <printint>
 5ce:	8bca                	mv	s7,s2
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	bf8d                	j	544 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5d4:	06400793          	li	a5,100
 5d8:	02f68963          	beq	a3,a5,60a <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5dc:	06c00793          	li	a5,108
 5e0:	04f68263          	beq	a3,a5,624 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5e4:	07500793          	li	a5,117
 5e8:	0af68063          	beq	a3,a5,688 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5ec:	07800793          	li	a5,120
 5f0:	0ef68263          	beq	a3,a5,6d4 <vprintf+0x1da>
        putc(fd, '%');
 5f4:	02500593          	li	a1,37
 5f8:	855a                	mv	a0,s6
 5fa:	e47ff0ef          	jal	440 <putc>
        putc(fd, c0);
 5fe:	85ca                	mv	a1,s2
 600:	855a                	mv	a0,s6
 602:	e3fff0ef          	jal	440 <putc>
      state = 0;
 606:	4981                	li	s3,0
 608:	bf35                	j	544 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 60a:	008b8913          	addi	s2,s7,8
 60e:	4685                	li	a3,1
 610:	4629                	li	a2,10
 612:	000bb583          	ld	a1,0(s7)
 616:	855a                	mv	a0,s6
 618:	e47ff0ef          	jal	45e <printint>
        i += 1;
 61c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 61e:	8bca                	mv	s7,s2
      state = 0;
 620:	4981                	li	s3,0
        i += 1;
 622:	b70d                	j	544 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 624:	06400793          	li	a5,100
 628:	02f60763          	beq	a2,a5,656 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 62c:	07500793          	li	a5,117
 630:	06f60963          	beq	a2,a5,6a2 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 634:	07800793          	li	a5,120
 638:	faf61ee3          	bne	a2,a5,5f4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 63c:	008b8913          	addi	s2,s7,8
 640:	4681                	li	a3,0
 642:	4641                	li	a2,16
 644:	000bb583          	ld	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	e15ff0ef          	jal	45e <printint>
        i += 2;
 64e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 650:	8bca                	mv	s7,s2
      state = 0;
 652:	4981                	li	s3,0
        i += 2;
 654:	bdc5                	j	544 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 656:	008b8913          	addi	s2,s7,8
 65a:	4685                	li	a3,1
 65c:	4629                	li	a2,10
 65e:	000bb583          	ld	a1,0(s7)
 662:	855a                	mv	a0,s6
 664:	dfbff0ef          	jal	45e <printint>
        i += 2;
 668:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 66a:	8bca                	mv	s7,s2
      state = 0;
 66c:	4981                	li	s3,0
        i += 2;
 66e:	bdd9                	j	544 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 670:	008b8913          	addi	s2,s7,8
 674:	4681                	li	a3,0
 676:	4629                	li	a2,10
 678:	000be583          	lwu	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	de1ff0ef          	jal	45e <printint>
 682:	8bca                	mv	s7,s2
      state = 0;
 684:	4981                	li	s3,0
 686:	bd7d                	j	544 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 688:	008b8913          	addi	s2,s7,8
 68c:	4681                	li	a3,0
 68e:	4629                	li	a2,10
 690:	000bb583          	ld	a1,0(s7)
 694:	855a                	mv	a0,s6
 696:	dc9ff0ef          	jal	45e <printint>
        i += 1;
 69a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 69c:	8bca                	mv	s7,s2
      state = 0;
 69e:	4981                	li	s3,0
        i += 1;
 6a0:	b555                	j	544 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a2:	008b8913          	addi	s2,s7,8
 6a6:	4681                	li	a3,0
 6a8:	4629                	li	a2,10
 6aa:	000bb583          	ld	a1,0(s7)
 6ae:	855a                	mv	a0,s6
 6b0:	dafff0ef          	jal	45e <printint>
        i += 2;
 6b4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b6:	8bca                	mv	s7,s2
      state = 0;
 6b8:	4981                	li	s3,0
        i += 2;
 6ba:	b569                	j	544 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6bc:	008b8913          	addi	s2,s7,8
 6c0:	4681                	li	a3,0
 6c2:	4641                	li	a2,16
 6c4:	000be583          	lwu	a1,0(s7)
 6c8:	855a                	mv	a0,s6
 6ca:	d95ff0ef          	jal	45e <printint>
 6ce:	8bca                	mv	s7,s2
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	bd8d                	j	544 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d4:	008b8913          	addi	s2,s7,8
 6d8:	4681                	li	a3,0
 6da:	4641                	li	a2,16
 6dc:	000bb583          	ld	a1,0(s7)
 6e0:	855a                	mv	a0,s6
 6e2:	d7dff0ef          	jal	45e <printint>
        i += 1;
 6e6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e8:	8bca                	mv	s7,s2
      state = 0;
 6ea:	4981                	li	s3,0
        i += 1;
 6ec:	bda1                	j	544 <vprintf+0x4a>
 6ee:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6f0:	008b8d13          	addi	s10,s7,8
 6f4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6f8:	03000593          	li	a1,48
 6fc:	855a                	mv	a0,s6
 6fe:	d43ff0ef          	jal	440 <putc>
  putc(fd, 'x');
 702:	07800593          	li	a1,120
 706:	855a                	mv	a0,s6
 708:	d39ff0ef          	jal	440 <putc>
 70c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70e:	00000b97          	auipc	s7,0x0
 712:	682b8b93          	addi	s7,s7,1666 # d90 <digits>
 716:	03c9d793          	srli	a5,s3,0x3c
 71a:	97de                	add	a5,a5,s7
 71c:	0007c583          	lbu	a1,0(a5)
 720:	855a                	mv	a0,s6
 722:	d1fff0ef          	jal	440 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 726:	0992                	slli	s3,s3,0x4
 728:	397d                	addiw	s2,s2,-1
 72a:	fe0916e3          	bnez	s2,716 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 72e:	8bea                	mv	s7,s10
      state = 0;
 730:	4981                	li	s3,0
 732:	6d02                	ld	s10,0(sp)
 734:	bd01                	j	544 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 736:	008b8913          	addi	s2,s7,8
 73a:	000bc583          	lbu	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	d01ff0ef          	jal	440 <putc>
 744:	8bca                	mv	s7,s2
      state = 0;
 746:	4981                	li	s3,0
 748:	bbf5                	j	544 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 74a:	008b8993          	addi	s3,s7,8
 74e:	000bb903          	ld	s2,0(s7)
 752:	00090f63          	beqz	s2,770 <vprintf+0x276>
        for(; *s; s++)
 756:	00094583          	lbu	a1,0(s2)
 75a:	c195                	beqz	a1,77e <vprintf+0x284>
          putc(fd, *s);
 75c:	855a                	mv	a0,s6
 75e:	ce3ff0ef          	jal	440 <putc>
        for(; *s; s++)
 762:	0905                	addi	s2,s2,1
 764:	00094583          	lbu	a1,0(s2)
 768:	f9f5                	bnez	a1,75c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 76a:	8bce                	mv	s7,s3
      state = 0;
 76c:	4981                	li	s3,0
 76e:	bbd9                	j	544 <vprintf+0x4a>
          s = "(null)";
 770:	00000917          	auipc	s2,0x0
 774:	55090913          	addi	s2,s2,1360 # cc0 <filter_debug_status+0x2d0>
        for(; *s; s++)
 778:	02800593          	li	a1,40
 77c:	b7c5                	j	75c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 77e:	8bce                	mv	s7,s3
      state = 0;
 780:	4981                	li	s3,0
 782:	b3c9                	j	544 <vprintf+0x4a>
 784:	64a6                	ld	s1,72(sp)
 786:	79e2                	ld	s3,56(sp)
 788:	7a42                	ld	s4,48(sp)
 78a:	7aa2                	ld	s5,40(sp)
 78c:	7b02                	ld	s6,32(sp)
 78e:	6be2                	ld	s7,24(sp)
 790:	6c42                	ld	s8,16(sp)
 792:	6ca2                	ld	s9,8(sp)
    }
  }
}
 794:	60e6                	ld	ra,88(sp)
 796:	6446                	ld	s0,80(sp)
 798:	6906                	ld	s2,64(sp)
 79a:	6125                	addi	sp,sp,96
 79c:	8082                	ret

000000000000079e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 79e:	715d                	addi	sp,sp,-80
 7a0:	ec06                	sd	ra,24(sp)
 7a2:	e822                	sd	s0,16(sp)
 7a4:	1000                	addi	s0,sp,32
 7a6:	e010                	sd	a2,0(s0)
 7a8:	e414                	sd	a3,8(s0)
 7aa:	e818                	sd	a4,16(s0)
 7ac:	ec1c                	sd	a5,24(s0)
 7ae:	03043023          	sd	a6,32(s0)
 7b2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7b6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ba:	8622                	mv	a2,s0
 7bc:	d3fff0ef          	jal	4fa <vprintf>
}
 7c0:	60e2                	ld	ra,24(sp)
 7c2:	6442                	ld	s0,16(sp)
 7c4:	6161                	addi	sp,sp,80
 7c6:	8082                	ret

00000000000007c8 <printf>:

void
printf(const char *fmt, ...)
{
 7c8:	711d                	addi	sp,sp,-96
 7ca:	ec06                	sd	ra,24(sp)
 7cc:	e822                	sd	s0,16(sp)
 7ce:	1000                	addi	s0,sp,32
 7d0:	e40c                	sd	a1,8(s0)
 7d2:	e810                	sd	a2,16(s0)
 7d4:	ec14                	sd	a3,24(s0)
 7d6:	f018                	sd	a4,32(s0)
 7d8:	f41c                	sd	a5,40(s0)
 7da:	03043823          	sd	a6,48(s0)
 7de:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7e2:	00840613          	addi	a2,s0,8
 7e6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ea:	85aa                	mv	a1,a0
 7ec:	4505                	li	a0,1
 7ee:	d0dff0ef          	jal	4fa <vprintf>
}
 7f2:	60e2                	ld	ra,24(sp)
 7f4:	6442                	ld	s0,16(sp)
 7f6:	6125                	addi	sp,sp,96
 7f8:	8082                	ret

00000000000007fa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7fa:	1141                	addi	sp,sp,-16
 7fc:	e422                	sd	s0,8(sp)
 7fe:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 800:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 804:	00001797          	auipc	a5,0x1
 808:	7fc7b783          	ld	a5,2044(a5) # 2000 <freep>
 80c:	a02d                	j	836 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 80e:	4618                	lw	a4,8(a2)
 810:	9f2d                	addw	a4,a4,a1
 812:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 816:	6398                	ld	a4,0(a5)
 818:	6310                	ld	a2,0(a4)
 81a:	a83d                	j	858 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 81c:	ff852703          	lw	a4,-8(a0)
 820:	9f31                	addw	a4,a4,a2
 822:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 824:	ff053683          	ld	a3,-16(a0)
 828:	a091                	j	86c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82a:	6398                	ld	a4,0(a5)
 82c:	00e7e463          	bltu	a5,a4,834 <free+0x3a>
 830:	00e6ea63          	bltu	a3,a4,844 <free+0x4a>
{
 834:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 836:	fed7fae3          	bgeu	a5,a3,82a <free+0x30>
 83a:	6398                	ld	a4,0(a5)
 83c:	00e6e463          	bltu	a3,a4,844 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 840:	fee7eae3          	bltu	a5,a4,834 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 844:	ff852583          	lw	a1,-8(a0)
 848:	6390                	ld	a2,0(a5)
 84a:	02059813          	slli	a6,a1,0x20
 84e:	01c85713          	srli	a4,a6,0x1c
 852:	9736                	add	a4,a4,a3
 854:	fae60de3          	beq	a2,a4,80e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 858:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 85c:	4790                	lw	a2,8(a5)
 85e:	02061593          	slli	a1,a2,0x20
 862:	01c5d713          	srli	a4,a1,0x1c
 866:	973e                	add	a4,a4,a5
 868:	fae68ae3          	beq	a3,a4,81c <free+0x22>
    p->s.ptr = bp->s.ptr;
 86c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 86e:	00001717          	auipc	a4,0x1
 872:	78f73923          	sd	a5,1938(a4) # 2000 <freep>
}
 876:	6422                	ld	s0,8(sp)
 878:	0141                	addi	sp,sp,16
 87a:	8082                	ret

000000000000087c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 87c:	7139                	addi	sp,sp,-64
 87e:	fc06                	sd	ra,56(sp)
 880:	f822                	sd	s0,48(sp)
 882:	f426                	sd	s1,40(sp)
 884:	ec4e                	sd	s3,24(sp)
 886:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 888:	02051493          	slli	s1,a0,0x20
 88c:	9081                	srli	s1,s1,0x20
 88e:	04bd                	addi	s1,s1,15
 890:	8091                	srli	s1,s1,0x4
 892:	0014899b          	addiw	s3,s1,1
 896:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 898:	00001517          	auipc	a0,0x1
 89c:	76853503          	ld	a0,1896(a0) # 2000 <freep>
 8a0:	c915                	beqz	a0,8d4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a4:	4798                	lw	a4,8(a5)
 8a6:	08977a63          	bgeu	a4,s1,93a <malloc+0xbe>
 8aa:	f04a                	sd	s2,32(sp)
 8ac:	e852                	sd	s4,16(sp)
 8ae:	e456                	sd	s5,8(sp)
 8b0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8b2:	8a4e                	mv	s4,s3
 8b4:	0009871b          	sext.w	a4,s3
 8b8:	6685                	lui	a3,0x1
 8ba:	00d77363          	bgeu	a4,a3,8c0 <malloc+0x44>
 8be:	6a05                	lui	s4,0x1
 8c0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8c4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c8:	00001917          	auipc	s2,0x1
 8cc:	73890913          	addi	s2,s2,1848 # 2000 <freep>
  if(p == SBRK_ERROR)
 8d0:	5afd                	li	s5,-1
 8d2:	a081                	j	912 <malloc+0x96>
 8d4:	f04a                	sd	s2,32(sp)
 8d6:	e852                	sd	s4,16(sp)
 8d8:	e456                	sd	s5,8(sp)
 8da:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8dc:	00001797          	auipc	a5,0x1
 8e0:	73478793          	addi	a5,a5,1844 # 2010 <base>
 8e4:	00001717          	auipc	a4,0x1
 8e8:	70f73e23          	sd	a5,1820(a4) # 2000 <freep>
 8ec:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ee:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f2:	b7c1                	j	8b2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8f4:	6398                	ld	a4,0(a5)
 8f6:	e118                	sd	a4,0(a0)
 8f8:	a8a9                	j	952 <malloc+0xd6>
  hp->s.size = nu;
 8fa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8fe:	0541                	addi	a0,a0,16
 900:	efbff0ef          	jal	7fa <free>
  return freep;
 904:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 908:	c12d                	beqz	a0,96a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90c:	4798                	lw	a4,8(a5)
 90e:	02977263          	bgeu	a4,s1,932 <malloc+0xb6>
    if(p == freep)
 912:	00093703          	ld	a4,0(s2)
 916:	853e                	mv	a0,a5
 918:	fef719e3          	bne	a4,a5,90a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 91c:	8552                	mv	a0,s4
 91e:	a37ff0ef          	jal	354 <sbrk>
  if(p == SBRK_ERROR)
 922:	fd551ce3          	bne	a0,s5,8fa <malloc+0x7e>
        return 0;
 926:	4501                	li	a0,0
 928:	7902                	ld	s2,32(sp)
 92a:	6a42                	ld	s4,16(sp)
 92c:	6aa2                	ld	s5,8(sp)
 92e:	6b02                	ld	s6,0(sp)
 930:	a03d                	j	95e <malloc+0xe2>
 932:	7902                	ld	s2,32(sp)
 934:	6a42                	ld	s4,16(sp)
 936:	6aa2                	ld	s5,8(sp)
 938:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 93a:	fae48de3          	beq	s1,a4,8f4 <malloc+0x78>
        p->s.size -= nunits;
 93e:	4137073b          	subw	a4,a4,s3
 942:	c798                	sw	a4,8(a5)
        p += p->s.size;
 944:	02071693          	slli	a3,a4,0x20
 948:	01c6d713          	srli	a4,a3,0x1c
 94c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 94e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 952:	00001717          	auipc	a4,0x1
 956:	6aa73723          	sd	a0,1710(a4) # 2000 <freep>
      return (void*)(p + 1);
 95a:	01078513          	addi	a0,a5,16
  }
}
 95e:	70e2                	ld	ra,56(sp)
 960:	7442                	ld	s0,48(sp)
 962:	74a2                	ld	s1,40(sp)
 964:	69e2                	ld	s3,24(sp)
 966:	6121                	addi	sp,sp,64
 968:	8082                	ret
 96a:	7902                	ld	s2,32(sp)
 96c:	6a42                	ld	s4,16(sp)
 96e:	6aa2                	ld	s5,8(sp)
 970:	6b02                	ld	s6,0(sp)
 972:	b7f5                	j	95e <malloc+0xe2>

0000000000000974 <filter_apply>:
#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int filter_apply(long blacklist_mask) {
 974:	1141                	addi	sp,sp,-16
 976:	e406                	sd	ra,8(sp)
 978:	e022                	sd	s0,0(sp)
 97a:	0800                	addi	s0,sp,16
    // Vì kernel của bạn đang dùng Whitelist (1 là cho phép), 
    // nhưng API này dùng Blacklist (1 là chặn), chúng ta cần đảo bit.
    return setfilter(~blacklist_mask);
 97c:	fff54513          	not	a0,a0
 980:	aa9ff0ef          	jal	428 <setfilter>
}
 984:	60a2                	ld	ra,8(sp)
 986:	6402                	ld	s0,0(sp)
 988:	0141                	addi	sp,sp,16
 98a:	8082                	ret

000000000000098c <filter_block_syscall>:

int filter_block_syscall(int sys_num) {
 98c:	1101                	addi	sp,sp,-32
 98e:	ec06                	sd	ra,24(sp)
 990:	e822                	sd	s0,16(sp)
 992:	e426                	sd	s1,8(sp)
 994:	1000                	addi	s0,sp,32
 996:	84aa                	mv	s1,a0
    long current_mask = getfilter();
 998:	a99ff0ef          	jal	430 <getfilter>
    // Tắt bit tương ứng với syscall đó trong whitelist
    return setfilter(current_mask & ~BLOCK(sys_num));
 99c:	4785                	li	a5,1
 99e:	009797b3          	sll	a5,a5,s1
 9a2:	fff7c793          	not	a5,a5
 9a6:	8d7d                	and	a0,a0,a5
 9a8:	a81ff0ef          	jal	428 <setfilter>
}
 9ac:	60e2                	ld	ra,24(sp)
 9ae:	6442                	ld	s0,16(sp)
 9b0:	64a2                	ld	s1,8(sp)
 9b2:	6105                	addi	sp,sp,32
 9b4:	8082                	ret

00000000000009b6 <filter_reset>:

int filter_reset(void) {
 9b6:	1141                	addi	sp,sp,-16
 9b8:	e406                	sd	ra,8(sp)
 9ba:	e022                	sd	s0,0(sp)
 9bc:	0800                	addi	s0,sp,16
    return setfilter(0xFFFFFFFFFFFFFFFFL); // Cho phép tất cả
 9be:	557d                	li	a0,-1
 9c0:	a69ff0ef          	jal	428 <setfilter>
}
 9c4:	60a2                	ld	ra,8(sp)
 9c6:	6402                	ld	s0,0(sp)
 9c8:	0141                	addi	sp,sp,16
 9ca:	8082                	ret

00000000000009cc <filter_is_blocked>:

int filter_is_blocked(int sys_num) {
 9cc:	1101                	addi	sp,sp,-32
 9ce:	ec06                	sd	ra,24(sp)
 9d0:	e822                	sd	s0,16(sp)
 9d2:	e426                	sd	s1,8(sp)
 9d4:	1000                	addi	s0,sp,32
 9d6:	84aa                	mv	s1,a0
    long current_mask = getfilter();
 9d8:	a59ff0ef          	jal	430 <getfilter>
    return !(current_mask & BLOCK(sys_num));
 9dc:	40955533          	sra	a0,a0,s1
 9e0:	00154513          	xori	a0,a0,1
}
 9e4:	8905                	andi	a0,a0,1
 9e6:	60e2                	ld	ra,24(sp)
 9e8:	6442                	ld	s0,16(sp)
 9ea:	64a2                	ld	s1,8(sp)
 9ec:	6105                	addi	sp,sp,32
 9ee:	8082                	ret

00000000000009f0 <filter_debug_status>:

void filter_debug_status(void) {
 9f0:	1101                	addi	sp,sp,-32
 9f2:	ec06                	sd	ra,24(sp)
 9f4:	e822                	sd	s0,16(sp)
 9f6:	e426                	sd	s1,8(sp)
 9f8:	1000                	addi	s0,sp,32
    long m = getfilter();
 9fa:	a37ff0ef          	jal	430 <getfilter>
 9fe:	84aa                	mv	s1,a0
    printf("\n[Sandbox Monitor]\n");
 a00:	00000517          	auipc	a0,0x0
 a04:	2f850513          	addi	a0,a0,760 # cf8 <filter_debug_status+0x308>
 a08:	dc1ff0ef          	jal	7c8 <printf>
    printf("Whitelist Mask: %ld\n", m);
 a0c:	85a6                	mv	a1,s1
 a0e:	00000517          	auipc	a0,0x0
 a12:	30250513          	addi	a0,a0,770 # d10 <filter_debug_status+0x320>
 a16:	db3ff0ef          	jal	7c8 <printf>
    printf("Security Level: %s\n", (m == 0xFFFFFFFFFFFFFFFFL) ? "LOW (Permissive)" : "HIGH (Restricted)");
 a1a:	57fd                	li	a5,-1
 a1c:	00000597          	auipc	a1,0x0
 a20:	2c458593          	addi	a1,a1,708 # ce0 <filter_debug_status+0x2f0>
 a24:	02f48b63          	beq	s1,a5,a5a <filter_debug_status+0x6a>
 a28:	00000517          	auipc	a0,0x0
 a2c:	30050513          	addi	a0,a0,768 # d28 <filter_debug_status+0x338>
 a30:	d99ff0ef          	jal	7c8 <printf>
    
    if(filter_is_blocked(SYS_open)) printf(" - File access: LOCKED\n");
 a34:	453d                	li	a0,15
 a36:	f97ff0ef          	jal	9cc <filter_is_blocked>
 a3a:	e50d                	bnez	a0,a64 <filter_debug_status+0x74>
    if(filter_is_blocked(SYS_fork)) printf(" - Process creation: LOCKED\n");
 a3c:	4505                	li	a0,1
 a3e:	f8fff0ef          	jal	9cc <filter_is_blocked>
 a42:	e905                	bnez	a0,a72 <filter_debug_status+0x82>
    printf("------------------\n");
 a44:	00000517          	auipc	a0,0x0
 a48:	33450513          	addi	a0,a0,820 # d78 <filter_debug_status+0x388>
 a4c:	d7dff0ef          	jal	7c8 <printf>
 a50:	60e2                	ld	ra,24(sp)
 a52:	6442                	ld	s0,16(sp)
 a54:	64a2                	ld	s1,8(sp)
 a56:	6105                	addi	sp,sp,32
 a58:	8082                	ret
    printf("Security Level: %s\n", (m == 0xFFFFFFFFFFFFFFFFL) ? "LOW (Permissive)" : "HIGH (Restricted)");
 a5a:	00000597          	auipc	a1,0x0
 a5e:	26e58593          	addi	a1,a1,622 # cc8 <filter_debug_status+0x2d8>
 a62:	b7d9                	j	a28 <filter_debug_status+0x38>
    if(filter_is_blocked(SYS_open)) printf(" - File access: LOCKED\n");
 a64:	00000517          	auipc	a0,0x0
 a68:	2dc50513          	addi	a0,a0,732 # d40 <filter_debug_status+0x350>
 a6c:	d5dff0ef          	jal	7c8 <printf>
 a70:	b7f1                	j	a3c <filter_debug_status+0x4c>
    if(filter_is_blocked(SYS_fork)) printf(" - Process creation: LOCKED\n");
 a72:	00000517          	auipc	a0,0x0
 a76:	2e650513          	addi	a0,a0,742 # d58 <filter_debug_status+0x368>
 a7a:	d4fff0ef          	jal	7c8 <printf>
 a7e:	b7d9                	j	a44 <filter_debug_status+0x54>
