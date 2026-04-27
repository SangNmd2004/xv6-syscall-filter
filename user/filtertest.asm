
user/_filtertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <result>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/filter.h"

static void result(const char *name, int ok) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if (ok)
   8:	cd81                	beqz	a1,20 <result+0x20>
    printf("[PASS] %s\n", name);
   a:	85aa                	mv	a1,a0
   c:	00001517          	auipc	a0,0x1
  10:	ab450513          	addi	a0,a0,-1356 # ac0 <malloc+0xfa>
  14:	0ff000ef          	jal	912 <printf>
  else
    printf("[FAIL] %s\n", name);
}
  18:	60a2                	ld	ra,8(sp)
  1a:	6402                	ld	s0,0(sp)
  1c:	0141                	addi	sp,sp,16
  1e:	8082                	ret
    printf("[FAIL] %s\n", name);
  20:	85aa                	mv	a1,a0
  22:	00001517          	auipc	a0,0x1
  26:	aae50513          	addi	a0,a0,-1362 # ad0 <malloc+0x10a>
  2a:	0e9000ef          	jal	912 <printf>
}
  2e:	b7ed                	j	18 <result+0x18>

0000000000000030 <test1_initial_mask_zero>:

// TC1: Default Mask - New process starts with syscall_mask == 0
void test1_initial_mask_zero(void) {
  30:	1101                	addi	sp,sp,-32
  32:	ec06                	sd	ra,24(sp)
  34:	e822                	sd	s0,16(sp)
  36:	1000                	addi	s0,sp,32
  int pid = fork();
  38:	492000ef          	jal	4ca <fork>
  if (pid == 0) {
  3c:	c505                	beqz	a0,64 <test1_initial_mask_zero+0x34>
    uint64 mask = getfilter();
    exit(mask == 0 ? 1 : 0);
  } else {
    int status;
    wait(&status);
  3e:	fec40513          	addi	a0,s0,-20
  42:	498000ef          	jal	4da <wait>
    result("TC1: Default mask == 0", status == 1);
  46:	fec42583          	lw	a1,-20(s0)
  4a:	15fd                	addi	a1,a1,-1
  4c:	0015b593          	seqz	a1,a1
  50:	00001517          	auipc	a0,0x1
  54:	a9050513          	addi	a0,a0,-1392 # ae0 <malloc+0x11a>
  58:	fa9ff0ef          	jal	0 <result>
  }
}
  5c:	60e2                	ld	ra,24(sp)
  5e:	6442                	ld	s0,16(sp)
  60:	6105                	addi	sp,sp,32
  62:	8082                	ret
    uint64 mask = getfilter();
  64:	516000ef          	jal	57a <getfilter>
    exit(mask == 0 ? 1 : 0);
  68:	00153513          	seqz	a0,a0
  6c:	466000ef          	jal	4d2 <exit>

0000000000000070 <test2_set_get_mask>:

// TC2: Set and Get
void test2_set_get_mask(void) {
  70:	1101                	addi	sp,sp,-32
  72:	ec06                	sd	ra,24(sp)
  74:	e822                	sd	s0,16(sp)
  76:	1000                	addi	s0,sp,32
  int pid = fork();
  78:	452000ef          	jal	4ca <fork>
  if (pid == 0) {
  7c:	c505                	beqz	a0,a4 <test2_set_get_mask+0x34>
    setfilter(want);
    uint64 got = getfilter();
    exit(got == want ? 1 : 0);
  } else {
    int status;
    wait(&status);
  7e:	fec40513          	addi	a0,s0,-20
  82:	458000ef          	jal	4da <wait>
    result("TC2: Set and Get filter mask", status == 1);
  86:	fec42583          	lw	a1,-20(s0)
  8a:	15fd                	addi	a1,a1,-1
  8c:	0015b593          	seqz	a1,a1
  90:	00001517          	auipc	a0,0x1
  94:	a6850513          	addi	a0,a0,-1432 # af8 <malloc+0x132>
  98:	f69ff0ef          	jal	0 <result>
  }
}
  9c:	60e2                	ld	ra,24(sp)
  9e:	6442                	ld	s0,16(sp)
  a0:	6105                	addi	sp,sp,32
  a2:	8082                	ret
    setfilter(want);
  a4:	6511                	lui	a0,0x4
  a6:	4cc000ef          	jal	572 <setfilter>
    uint64 got = getfilter();
  aa:	4d0000ef          	jal	57a <getfilter>
    exit(got == want ? 1 : 0);
  ae:	77f1                	lui	a5,0xffffc
  b0:	953e                	add	a0,a0,a5
  b2:	00153513          	seqz	a0,a0
  b6:	41c000ef          	jal	4d2 <exit>

00000000000000ba <test3_fork_inheritance>:

// TC3: Fork Inheritance
void test3_fork_inheritance(void) {
  ba:	1101                	addi	sp,sp,-32
  bc:	ec06                	sd	ra,24(sp)
  be:	e822                	sd	s0,16(sp)
  c0:	1000                	addi	s0,sp,32
  int pid1 = fork();
  c2:	408000ef          	jal	4ca <fork>
  if (pid1 == 0) {
  c6:	e51d                	bnez	a0,f4 <test3_fork_inheritance+0x3a>
    uint64 parent_mask = FILTER_UPTIME;
    setfilter(parent_mask);
  c8:	6511                	lui	a0,0x4
  ca:	4a8000ef          	jal	572 <setfilter>

    int pid2 = fork();
  ce:	3fc000ef          	jal	4ca <fork>
    if (pid2 == 0) {
  d2:	e909                	bnez	a0,e4 <test3_fork_inheritance+0x2a>
      uint64 child_mask = getfilter();
  d4:	4a6000ef          	jal	57a <getfilter>
      exit(child_mask == parent_mask ? 1 : 0);
  d8:	77f1                	lui	a5,0xffffc
  da:	953e                	add	a0,a0,a5
  dc:	00153513          	seqz	a0,a0
  e0:	3f2000ef          	jal	4d2 <exit>
    } else {
      int status;
      wait(&status);
  e4:	fec40513          	addi	a0,s0,-20
  e8:	3f2000ef          	jal	4da <wait>
      exit(status);
  ec:	fec42503          	lw	a0,-20(s0)
  f0:	3e2000ef          	jal	4d2 <exit>
    }
  } else {
    int status;
    wait(&status);
  f4:	fec40513          	addi	a0,s0,-20
  f8:	3e2000ef          	jal	4da <wait>
    result("TC3: Fork inheritance", status == 1);
  fc:	fec42583          	lw	a1,-20(s0)
 100:	15fd                	addi	a1,a1,-1
 102:	0015b593          	seqz	a1,a1
 106:	00001517          	auipc	a0,0x1
 10a:	a1250513          	addi	a0,a0,-1518 # b18 <malloc+0x152>
 10e:	ef3ff0ef          	jal	0 <result>
  }
}
 112:	60e2                	ld	ra,24(sp)
 114:	6442                	ld	s0,16(sp)
 116:	6105                	addi	sp,sp,32
 118:	8082                	ret

000000000000011a <test4_policy_weaken>:

// TC4: Policy C: Weaken -> Deny
void test4_policy_weaken(void) {
 11a:	1101                	addi	sp,sp,-32
 11c:	ec06                	sd	ra,24(sp)
 11e:	e822                	sd	s0,16(sp)
 120:	1000                	addi	s0,sp,32
  int pid = fork();
 122:	3a8000ef          	jal	4ca <fork>
  if (pid == 0) {
 126:	c505                	beqz	a0,14e <test4_policy_weaken+0x34>
    setfilter(FILTER_UPTIME); 
    int r = setfilter(0);    // Attempt to weaken
    exit(r == -1 ? 1 : 0);
  } else {
    int status;
    wait(&status);
 128:	fec40513          	addi	a0,s0,-20
 12c:	3ae000ef          	jal	4da <wait>
    result("TC4: Policy C (Deny weaken)", status == 1);
 130:	fec42583          	lw	a1,-20(s0)
 134:	15fd                	addi	a1,a1,-1
 136:	0015b593          	seqz	a1,a1
 13a:	00001517          	auipc	a0,0x1
 13e:	9f650513          	addi	a0,a0,-1546 # b30 <malloc+0x16a>
 142:	ebfff0ef          	jal	0 <result>
  }
}
 146:	60e2                	ld	ra,24(sp)
 148:	6442                	ld	s0,16(sp)
 14a:	6105                	addi	sp,sp,32
 14c:	8082                	ret
    setfilter(FILTER_UPTIME); 
 14e:	6511                	lui	a0,0x4
 150:	422000ef          	jal	572 <setfilter>
    int r = setfilter(0);    // Attempt to weaken
 154:	4501                	li	a0,0
 156:	41c000ef          	jal	572 <setfilter>
    exit(r == -1 ? 1 : 0);
 15a:	0505                	addi	a0,a0,1 # 4001 <base+0x2ff1>
 15c:	00153513          	seqz	a0,a0
 160:	372000ef          	jal	4d2 <exit>

0000000000000164 <test5_policy_tighten>:

// TC5: Policy C: Tighten -> Allow
void test5_policy_tighten(void) {
 164:	1101                	addi	sp,sp,-32
 166:	ec06                	sd	ra,24(sp)
 168:	e822                	sd	s0,16(sp)
 16a:	1000                	addi	s0,sp,32
  int pid = fork();
 16c:	35e000ef          	jal	4ca <fork>
  if (pid == 0) {
 170:	c505                	beqz	a0,198 <test5_policy_tighten+0x34>
    setfilter(FILTER_UPTIME);
    int r = setfilter(FILTER_UPTIME | FILTER_SBRK); // tighter mask
    exit(r == 0 ? 1 : 0);
  } else {
    int status;
    wait(&status);
 172:	fec40513          	addi	a0,s0,-20
 176:	364000ef          	jal	4da <wait>
    result("TC5: Policy C (Allow tighten)", status == 1);
 17a:	fec42583          	lw	a1,-20(s0)
 17e:	15fd                	addi	a1,a1,-1
 180:	0015b593          	seqz	a1,a1
 184:	00001517          	auipc	a0,0x1
 188:	9cc50513          	addi	a0,a0,-1588 # b50 <malloc+0x18a>
 18c:	e75ff0ef          	jal	0 <result>
  }
}
 190:	60e2                	ld	ra,24(sp)
 192:	6442                	ld	s0,16(sp)
 194:	6105                	addi	sp,sp,32
 196:	8082                	ret
    setfilter(FILTER_UPTIME);
 198:	6511                	lui	a0,0x4
 19a:	3d8000ef          	jal	572 <setfilter>
    int r = setfilter(FILTER_UPTIME | FILTER_SBRK); // tighter mask
 19e:	6515                	lui	a0,0x5
 1a0:	3d2000ef          	jal	572 <setfilter>
    exit(r == 0 ? 1 : 0);
 1a4:	00153513          	seqz	a0,a0
 1a8:	32a000ef          	jal	4d2 <exit>

00000000000001ac <test6_write_blocked>:

// TC6: Write Blocked
void test6_write_blocked(void) {
 1ac:	1101                	addi	sp,sp,-32
 1ae:	ec06                	sd	ra,24(sp)
 1b0:	e822                	sd	s0,16(sp)
 1b2:	1000                	addi	s0,sp,32
  int pid = fork();
 1b4:	316000ef          	jal	4ca <fork>
  if (pid == 0) {
 1b8:	c505                	beqz	a0,1e0 <test6_write_blocked+0x34>
    int r = write(1, "should fail\n", 12);
    // write MUST return -1
    exit(r == -1 ? 1 : 0);
  } else {
    int status;
    wait(&status);
 1ba:	fec40513          	addi	a0,s0,-20
 1be:	31c000ef          	jal	4da <wait>
    result("TC6: write() is properly blocked", status == 1);
 1c2:	fec42583          	lw	a1,-20(s0)
 1c6:	15fd                	addi	a1,a1,-1
 1c8:	0015b593          	seqz	a1,a1
 1cc:	00001517          	auipc	a0,0x1
 1d0:	9b450513          	addi	a0,a0,-1612 # b80 <malloc+0x1ba>
 1d4:	e2dff0ef          	jal	0 <result>
  }
}
 1d8:	60e2                	ld	ra,24(sp)
 1da:	6442                	ld	s0,16(sp)
 1dc:	6105                	addi	sp,sp,32
 1de:	8082                	ret
    setfilter(FILTER_WRITE);
 1e0:	6541                	lui	a0,0x10
 1e2:	390000ef          	jal	572 <setfilter>
    int r = write(1, "should fail\n", 12);
 1e6:	4631                	li	a2,12
 1e8:	00001597          	auipc	a1,0x1
 1ec:	98858593          	addi	a1,a1,-1656 # b70 <malloc+0x1aa>
 1f0:	4505                	li	a0,1
 1f2:	300000ef          	jal	4f2 <write>
    exit(r == -1 ? 1 : 0);
 1f6:	0505                	addi	a0,a0,1 # 10001 <base+0xeff1>
 1f8:	00153513          	seqz	a0,a0
 1fc:	2d6000ef          	jal	4d2 <exit>

0000000000000200 <main>:

int main(void) {
 200:	1141                	addi	sp,sp,-16
 202:	e406                	sd	ra,8(sp)
 204:	e022                	sd	s0,0(sp)
 206:	0800                	addi	s0,sp,16
  printf("\n--- BO TEST FILTER (NGHIEM THU TUAN 3,4) ---\n");
 208:	00001517          	auipc	a0,0x1
 20c:	9a050513          	addi	a0,a0,-1632 # ba8 <malloc+0x1e2>
 210:	702000ef          	jal	912 <printf>
  test1_initial_mask_zero();
 214:	e1dff0ef          	jal	30 <test1_initial_mask_zero>
  test2_set_get_mask();
 218:	e59ff0ef          	jal	70 <test2_set_get_mask>
  test3_fork_inheritance();
 21c:	e9fff0ef          	jal	ba <test3_fork_inheritance>
  test4_policy_weaken();
 220:	efbff0ef          	jal	11a <test4_policy_weaken>
  test5_policy_tighten();
 224:	f41ff0ef          	jal	164 <test5_policy_tighten>
  test6_write_blocked();
 228:	f85ff0ef          	jal	1ac <test6_write_blocked>
  printf("------------------------------------------\n\n");
 22c:	00001517          	auipc	a0,0x1
 230:	9ac50513          	addi	a0,a0,-1620 # bd8 <malloc+0x212>
 234:	6de000ef          	jal	912 <printf>
  exit(0);
 238:	4501                	li	a0,0
 23a:	298000ef          	jal	4d2 <exit>

000000000000023e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e406                	sd	ra,8(sp)
 242:	e022                	sd	s0,0(sp)
 244:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 246:	fbbff0ef          	jal	200 <main>
  exit(r);
 24a:	288000ef          	jal	4d2 <exit>

000000000000024e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 254:	87aa                	mv	a5,a0
 256:	0585                	addi	a1,a1,1
 258:	0785                	addi	a5,a5,1 # ffffffffffffc001 <base+0xffffffffffffaff1>
 25a:	fff5c703          	lbu	a4,-1(a1)
 25e:	fee78fa3          	sb	a4,-1(a5)
 262:	fb75                	bnez	a4,256 <strcpy+0x8>
    ;
  return os;
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret

000000000000026a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 270:	00054783          	lbu	a5,0(a0)
 274:	cb91                	beqz	a5,288 <strcmp+0x1e>
 276:	0005c703          	lbu	a4,0(a1)
 27a:	00f71763          	bne	a4,a5,288 <strcmp+0x1e>
    p++, q++;
 27e:	0505                	addi	a0,a0,1
 280:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 282:	00054783          	lbu	a5,0(a0)
 286:	fbe5                	bnez	a5,276 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 288:	0005c503          	lbu	a0,0(a1)
}
 28c:	40a7853b          	subw	a0,a5,a0
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret

0000000000000296 <strlen>:

uint
strlen(const char *s)
{
 296:	1141                	addi	sp,sp,-16
 298:	e422                	sd	s0,8(sp)
 29a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 29c:	00054783          	lbu	a5,0(a0)
 2a0:	cf91                	beqz	a5,2bc <strlen+0x26>
 2a2:	0505                	addi	a0,a0,1
 2a4:	87aa                	mv	a5,a0
 2a6:	86be                	mv	a3,a5
 2a8:	0785                	addi	a5,a5,1
 2aa:	fff7c703          	lbu	a4,-1(a5)
 2ae:	ff65                	bnez	a4,2a6 <strlen+0x10>
 2b0:	40a6853b          	subw	a0,a3,a0
 2b4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2b6:	6422                	ld	s0,8(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret
  for(n = 0; s[n]; n++)
 2bc:	4501                	li	a0,0
 2be:	bfe5                	j	2b6 <strlen+0x20>

00000000000002c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2c6:	ca19                	beqz	a2,2dc <memset+0x1c>
 2c8:	87aa                	mv	a5,a0
 2ca:	1602                	slli	a2,a2,0x20
 2cc:	9201                	srli	a2,a2,0x20
 2ce:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2d2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2d6:	0785                	addi	a5,a5,1
 2d8:	fee79de3          	bne	a5,a4,2d2 <memset+0x12>
  }
  return dst;
}
 2dc:	6422                	ld	s0,8(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret

00000000000002e2 <strchr>:

char*
strchr(const char *s, char c)
{
 2e2:	1141                	addi	sp,sp,-16
 2e4:	e422                	sd	s0,8(sp)
 2e6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2e8:	00054783          	lbu	a5,0(a0)
 2ec:	cb99                	beqz	a5,302 <strchr+0x20>
    if(*s == c)
 2ee:	00f58763          	beq	a1,a5,2fc <strchr+0x1a>
  for(; *s; s++)
 2f2:	0505                	addi	a0,a0,1
 2f4:	00054783          	lbu	a5,0(a0)
 2f8:	fbfd                	bnez	a5,2ee <strchr+0xc>
      return (char*)s;
  return 0;
 2fa:	4501                	li	a0,0
}
 2fc:	6422                	ld	s0,8(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret
  return 0;
 302:	4501                	li	a0,0
 304:	bfe5                	j	2fc <strchr+0x1a>

0000000000000306 <gets>:

char*
gets(char *buf, int max)
{
 306:	711d                	addi	sp,sp,-96
 308:	ec86                	sd	ra,88(sp)
 30a:	e8a2                	sd	s0,80(sp)
 30c:	e4a6                	sd	s1,72(sp)
 30e:	e0ca                	sd	s2,64(sp)
 310:	fc4e                	sd	s3,56(sp)
 312:	f852                	sd	s4,48(sp)
 314:	f456                	sd	s5,40(sp)
 316:	f05a                	sd	s6,32(sp)
 318:	ec5e                	sd	s7,24(sp)
 31a:	1080                	addi	s0,sp,96
 31c:	8baa                	mv	s7,a0
 31e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 320:	892a                	mv	s2,a0
 322:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 324:	4aa9                	li	s5,10
 326:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 328:	89a6                	mv	s3,s1
 32a:	2485                	addiw	s1,s1,1
 32c:	0344d663          	bge	s1,s4,358 <gets+0x52>
    cc = read(0, &c, 1);
 330:	4605                	li	a2,1
 332:	faf40593          	addi	a1,s0,-81
 336:	4501                	li	a0,0
 338:	1b2000ef          	jal	4ea <read>
    if(cc < 1)
 33c:	00a05e63          	blez	a0,358 <gets+0x52>
    buf[i++] = c;
 340:	faf44783          	lbu	a5,-81(s0)
 344:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 348:	01578763          	beq	a5,s5,356 <gets+0x50>
 34c:	0905                	addi	s2,s2,1
 34e:	fd679de3          	bne	a5,s6,328 <gets+0x22>
    buf[i++] = c;
 352:	89a6                	mv	s3,s1
 354:	a011                	j	358 <gets+0x52>
 356:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 358:	99de                	add	s3,s3,s7
 35a:	00098023          	sb	zero,0(s3)
  return buf;
}
 35e:	855e                	mv	a0,s7
 360:	60e6                	ld	ra,88(sp)
 362:	6446                	ld	s0,80(sp)
 364:	64a6                	ld	s1,72(sp)
 366:	6906                	ld	s2,64(sp)
 368:	79e2                	ld	s3,56(sp)
 36a:	7a42                	ld	s4,48(sp)
 36c:	7aa2                	ld	s5,40(sp)
 36e:	7b02                	ld	s6,32(sp)
 370:	6be2                	ld	s7,24(sp)
 372:	6125                	addi	sp,sp,96
 374:	8082                	ret

0000000000000376 <stat>:

int
stat(const char *n, struct stat *st)
{
 376:	1101                	addi	sp,sp,-32
 378:	ec06                	sd	ra,24(sp)
 37a:	e822                	sd	s0,16(sp)
 37c:	e04a                	sd	s2,0(sp)
 37e:	1000                	addi	s0,sp,32
 380:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 382:	4581                	li	a1,0
 384:	18e000ef          	jal	512 <open>
  if(fd < 0)
 388:	02054263          	bltz	a0,3ac <stat+0x36>
 38c:	e426                	sd	s1,8(sp)
 38e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 390:	85ca                	mv	a1,s2
 392:	198000ef          	jal	52a <fstat>
 396:	892a                	mv	s2,a0
  close(fd);
 398:	8526                	mv	a0,s1
 39a:	160000ef          	jal	4fa <close>
  return r;
 39e:	64a2                	ld	s1,8(sp)
}
 3a0:	854a                	mv	a0,s2
 3a2:	60e2                	ld	ra,24(sp)
 3a4:	6442                	ld	s0,16(sp)
 3a6:	6902                	ld	s2,0(sp)
 3a8:	6105                	addi	sp,sp,32
 3aa:	8082                	ret
    return -1;
 3ac:	597d                	li	s2,-1
 3ae:	bfcd                	j	3a0 <stat+0x2a>

00000000000003b0 <atoi>:

int
atoi(const char *s)
{
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e422                	sd	s0,8(sp)
 3b4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b6:	00054683          	lbu	a3,0(a0)
 3ba:	fd06879b          	addiw	a5,a3,-48
 3be:	0ff7f793          	zext.b	a5,a5
 3c2:	4625                	li	a2,9
 3c4:	02f66863          	bltu	a2,a5,3f4 <atoi+0x44>
 3c8:	872a                	mv	a4,a0
  n = 0;
 3ca:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3cc:	0705                	addi	a4,a4,1
 3ce:	0025179b          	slliw	a5,a0,0x2
 3d2:	9fa9                	addw	a5,a5,a0
 3d4:	0017979b          	slliw	a5,a5,0x1
 3d8:	9fb5                	addw	a5,a5,a3
 3da:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3de:	00074683          	lbu	a3,0(a4)
 3e2:	fd06879b          	addiw	a5,a3,-48
 3e6:	0ff7f793          	zext.b	a5,a5
 3ea:	fef671e3          	bgeu	a2,a5,3cc <atoi+0x1c>
  return n;
}
 3ee:	6422                	ld	s0,8(sp)
 3f0:	0141                	addi	sp,sp,16
 3f2:	8082                	ret
  n = 0;
 3f4:	4501                	li	a0,0
 3f6:	bfe5                	j	3ee <atoi+0x3e>

00000000000003f8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3f8:	1141                	addi	sp,sp,-16
 3fa:	e422                	sd	s0,8(sp)
 3fc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3fe:	02b57463          	bgeu	a0,a1,426 <memmove+0x2e>
    while(n-- > 0)
 402:	00c05f63          	blez	a2,420 <memmove+0x28>
 406:	1602                	slli	a2,a2,0x20
 408:	9201                	srli	a2,a2,0x20
 40a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 40e:	872a                	mv	a4,a0
      *dst++ = *src++;
 410:	0585                	addi	a1,a1,1
 412:	0705                	addi	a4,a4,1
 414:	fff5c683          	lbu	a3,-1(a1)
 418:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 41c:	fef71ae3          	bne	a4,a5,410 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 420:	6422                	ld	s0,8(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret
    dst += n;
 426:	00c50733          	add	a4,a0,a2
    src += n;
 42a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 42c:	fec05ae3          	blez	a2,420 <memmove+0x28>
 430:	fff6079b          	addiw	a5,a2,-1
 434:	1782                	slli	a5,a5,0x20
 436:	9381                	srli	a5,a5,0x20
 438:	fff7c793          	not	a5,a5
 43c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 43e:	15fd                	addi	a1,a1,-1
 440:	177d                	addi	a4,a4,-1
 442:	0005c683          	lbu	a3,0(a1)
 446:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 44a:	fee79ae3          	bne	a5,a4,43e <memmove+0x46>
 44e:	bfc9                	j	420 <memmove+0x28>

0000000000000450 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 450:	1141                	addi	sp,sp,-16
 452:	e422                	sd	s0,8(sp)
 454:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 456:	ca05                	beqz	a2,486 <memcmp+0x36>
 458:	fff6069b          	addiw	a3,a2,-1
 45c:	1682                	slli	a3,a3,0x20
 45e:	9281                	srli	a3,a3,0x20
 460:	0685                	addi	a3,a3,1
 462:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 464:	00054783          	lbu	a5,0(a0)
 468:	0005c703          	lbu	a4,0(a1)
 46c:	00e79863          	bne	a5,a4,47c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 470:	0505                	addi	a0,a0,1
    p2++;
 472:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 474:	fed518e3          	bne	a0,a3,464 <memcmp+0x14>
  }
  return 0;
 478:	4501                	li	a0,0
 47a:	a019                	j	480 <memcmp+0x30>
      return *p1 - *p2;
 47c:	40e7853b          	subw	a0,a5,a4
}
 480:	6422                	ld	s0,8(sp)
 482:	0141                	addi	sp,sp,16
 484:	8082                	ret
  return 0;
 486:	4501                	li	a0,0
 488:	bfe5                	j	480 <memcmp+0x30>

000000000000048a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 48a:	1141                	addi	sp,sp,-16
 48c:	e406                	sd	ra,8(sp)
 48e:	e022                	sd	s0,0(sp)
 490:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 492:	f67ff0ef          	jal	3f8 <memmove>
}
 496:	60a2                	ld	ra,8(sp)
 498:	6402                	ld	s0,0(sp)
 49a:	0141                	addi	sp,sp,16
 49c:	8082                	ret

000000000000049e <sbrk>:

char *
sbrk(int n) {
 49e:	1141                	addi	sp,sp,-16
 4a0:	e406                	sd	ra,8(sp)
 4a2:	e022                	sd	s0,0(sp)
 4a4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4a6:	4585                	li	a1,1
 4a8:	0b2000ef          	jal	55a <sys_sbrk>
}
 4ac:	60a2                	ld	ra,8(sp)
 4ae:	6402                	ld	s0,0(sp)
 4b0:	0141                	addi	sp,sp,16
 4b2:	8082                	ret

00000000000004b4 <sbrklazy>:

char *
sbrklazy(int n) {
 4b4:	1141                	addi	sp,sp,-16
 4b6:	e406                	sd	ra,8(sp)
 4b8:	e022                	sd	s0,0(sp)
 4ba:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4bc:	4589                	li	a1,2
 4be:	09c000ef          	jal	55a <sys_sbrk>
}
 4c2:	60a2                	ld	ra,8(sp)
 4c4:	6402                	ld	s0,0(sp)
 4c6:	0141                	addi	sp,sp,16
 4c8:	8082                	ret

00000000000004ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4ca:	4885                	li	a7,1
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4d2:	4889                	li	a7,2
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <wait>:
.global wait
wait:
 li a7, SYS_wait
 4da:	488d                	li	a7,3
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4e2:	4891                	li	a7,4
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <read>:
.global read
read:
 li a7, SYS_read
 4ea:	4895                	li	a7,5
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <write>:
.global write
write:
 li a7, SYS_write
 4f2:	48c1                	li	a7,16
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <close>:
.global close
close:
 li a7, SYS_close
 4fa:	48d5                	li	a7,21
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <kill>:
.global kill
kill:
 li a7, SYS_kill
 502:	4899                	li	a7,6
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <exec>:
.global exec
exec:
 li a7, SYS_exec
 50a:	489d                	li	a7,7
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <open>:
.global open
open:
 li a7, SYS_open
 512:	48bd                	li	a7,15
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 51a:	48c5                	li	a7,17
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 522:	48c9                	li	a7,18
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 52a:	48a1                	li	a7,8
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <link>:
.global link
link:
 li a7, SYS_link
 532:	48cd                	li	a7,19
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 53a:	48d1                	li	a7,20
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 542:	48a5                	li	a7,9
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <dup>:
.global dup
dup:
 li a7, SYS_dup
 54a:	48a9                	li	a7,10
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 552:	48ad                	li	a7,11
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 55a:	48b1                	li	a7,12
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <pause>:
.global pause
pause:
 li a7, SYS_pause
 562:	48b5                	li	a7,13
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 56a:	48b9                	li	a7,14
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <setfilter>:
.global setfilter
setfilter:
 li a7, SYS_setfilter
 572:	48dd                	li	a7,23
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <getfilter>:
.global getfilter
getfilter:
 li a7, SYS_getfilter
 57a:	48e1                	li	a7,24
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <setfilter_child>:
.global setfilter_child
setfilter_child:
 li a7, SYS_setfilter_child
 582:	48e5                	li	a7,25
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 58a:	1101                	addi	sp,sp,-32
 58c:	ec06                	sd	ra,24(sp)
 58e:	e822                	sd	s0,16(sp)
 590:	1000                	addi	s0,sp,32
 592:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 596:	4605                	li	a2,1
 598:	fef40593          	addi	a1,s0,-17
 59c:	f57ff0ef          	jal	4f2 <write>
}
 5a0:	60e2                	ld	ra,24(sp)
 5a2:	6442                	ld	s0,16(sp)
 5a4:	6105                	addi	sp,sp,32
 5a6:	8082                	ret

00000000000005a8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5a8:	715d                	addi	sp,sp,-80
 5aa:	e486                	sd	ra,72(sp)
 5ac:	e0a2                	sd	s0,64(sp)
 5ae:	f84a                	sd	s2,48(sp)
 5b0:	0880                	addi	s0,sp,80
 5b2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5b4:	c299                	beqz	a3,5ba <printint+0x12>
 5b6:	0805c363          	bltz	a1,63c <printint+0x94>
  neg = 0;
 5ba:	4881                	li	a7,0
 5bc:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5c0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5c2:	00000517          	auipc	a0,0x0
 5c6:	64e50513          	addi	a0,a0,1614 # c10 <digits>
 5ca:	883e                	mv	a6,a5
 5cc:	2785                	addiw	a5,a5,1
 5ce:	02c5f733          	remu	a4,a1,a2
 5d2:	972a                	add	a4,a4,a0
 5d4:	00074703          	lbu	a4,0(a4)
 5d8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5dc:	872e                	mv	a4,a1
 5de:	02c5d5b3          	divu	a1,a1,a2
 5e2:	0685                	addi	a3,a3,1
 5e4:	fec773e3          	bgeu	a4,a2,5ca <printint+0x22>
  if(neg)
 5e8:	00088b63          	beqz	a7,5fe <printint+0x56>
    buf[i++] = '-';
 5ec:	fd078793          	addi	a5,a5,-48
 5f0:	97a2                	add	a5,a5,s0
 5f2:	02d00713          	li	a4,45
 5f6:	fee78423          	sb	a4,-24(a5)
 5fa:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 5fe:	02f05a63          	blez	a5,632 <printint+0x8a>
 602:	fc26                	sd	s1,56(sp)
 604:	f44e                	sd	s3,40(sp)
 606:	fb840713          	addi	a4,s0,-72
 60a:	00f704b3          	add	s1,a4,a5
 60e:	fff70993          	addi	s3,a4,-1
 612:	99be                	add	s3,s3,a5
 614:	37fd                	addiw	a5,a5,-1
 616:	1782                	slli	a5,a5,0x20
 618:	9381                	srli	a5,a5,0x20
 61a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 61e:	fff4c583          	lbu	a1,-1(s1)
 622:	854a                	mv	a0,s2
 624:	f67ff0ef          	jal	58a <putc>
  while(--i >= 0)
 628:	14fd                	addi	s1,s1,-1
 62a:	ff349ae3          	bne	s1,s3,61e <printint+0x76>
 62e:	74e2                	ld	s1,56(sp)
 630:	79a2                	ld	s3,40(sp)
}
 632:	60a6                	ld	ra,72(sp)
 634:	6406                	ld	s0,64(sp)
 636:	7942                	ld	s2,48(sp)
 638:	6161                	addi	sp,sp,80
 63a:	8082                	ret
    x = -xx;
 63c:	40b005b3          	neg	a1,a1
    neg = 1;
 640:	4885                	li	a7,1
    x = -xx;
 642:	bfad                	j	5bc <printint+0x14>

0000000000000644 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 644:	711d                	addi	sp,sp,-96
 646:	ec86                	sd	ra,88(sp)
 648:	e8a2                	sd	s0,80(sp)
 64a:	e0ca                	sd	s2,64(sp)
 64c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 64e:	0005c903          	lbu	s2,0(a1)
 652:	28090663          	beqz	s2,8de <vprintf+0x29a>
 656:	e4a6                	sd	s1,72(sp)
 658:	fc4e                	sd	s3,56(sp)
 65a:	f852                	sd	s4,48(sp)
 65c:	f456                	sd	s5,40(sp)
 65e:	f05a                	sd	s6,32(sp)
 660:	ec5e                	sd	s7,24(sp)
 662:	e862                	sd	s8,16(sp)
 664:	e466                	sd	s9,8(sp)
 666:	8b2a                	mv	s6,a0
 668:	8a2e                	mv	s4,a1
 66a:	8bb2                	mv	s7,a2
  state = 0;
 66c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 66e:	4481                	li	s1,0
 670:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 672:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 676:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 67a:	06c00c93          	li	s9,108
 67e:	a005                	j	69e <vprintf+0x5a>
        putc(fd, c0);
 680:	85ca                	mv	a1,s2
 682:	855a                	mv	a0,s6
 684:	f07ff0ef          	jal	58a <putc>
 688:	a019                	j	68e <vprintf+0x4a>
    } else if(state == '%'){
 68a:	03598263          	beq	s3,s5,6ae <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 68e:	2485                	addiw	s1,s1,1
 690:	8726                	mv	a4,s1
 692:	009a07b3          	add	a5,s4,s1
 696:	0007c903          	lbu	s2,0(a5)
 69a:	22090a63          	beqz	s2,8ce <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 69e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6a2:	fe0994e3          	bnez	s3,68a <vprintf+0x46>
      if(c0 == '%'){
 6a6:	fd579de3          	bne	a5,s5,680 <vprintf+0x3c>
        state = '%';
 6aa:	89be                	mv	s3,a5
 6ac:	b7cd                	j	68e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6ae:	00ea06b3          	add	a3,s4,a4
 6b2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6b6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6b8:	c681                	beqz	a3,6c0 <vprintf+0x7c>
 6ba:	9752                	add	a4,a4,s4
 6bc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6c0:	05878363          	beq	a5,s8,706 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 6c4:	05978d63          	beq	a5,s9,71e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6c8:	07500713          	li	a4,117
 6cc:	0ee78763          	beq	a5,a4,7ba <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6d0:	07800713          	li	a4,120
 6d4:	12e78963          	beq	a5,a4,806 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6d8:	07000713          	li	a4,112
 6dc:	14e78e63          	beq	a5,a4,838 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 6e0:	06300713          	li	a4,99
 6e4:	18e78e63          	beq	a5,a4,880 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 6e8:	07300713          	li	a4,115
 6ec:	1ae78463          	beq	a5,a4,894 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6f0:	02500713          	li	a4,37
 6f4:	04e79563          	bne	a5,a4,73e <vprintf+0xfa>
        putc(fd, '%');
 6f8:	02500593          	li	a1,37
 6fc:	855a                	mv	a0,s6
 6fe:	e8dff0ef          	jal	58a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 702:	4981                	li	s3,0
 704:	b769                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 706:	008b8913          	addi	s2,s7,8
 70a:	4685                	li	a3,1
 70c:	4629                	li	a2,10
 70e:	000ba583          	lw	a1,0(s7)
 712:	855a                	mv	a0,s6
 714:	e95ff0ef          	jal	5a8 <printint>
 718:	8bca                	mv	s7,s2
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bf8d                	j	68e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 71e:	06400793          	li	a5,100
 722:	02f68963          	beq	a3,a5,754 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 726:	06c00793          	li	a5,108
 72a:	04f68263          	beq	a3,a5,76e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 72e:	07500793          	li	a5,117
 732:	0af68063          	beq	a3,a5,7d2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 736:	07800793          	li	a5,120
 73a:	0ef68263          	beq	a3,a5,81e <vprintf+0x1da>
        putc(fd, '%');
 73e:	02500593          	li	a1,37
 742:	855a                	mv	a0,s6
 744:	e47ff0ef          	jal	58a <putc>
        putc(fd, c0);
 748:	85ca                	mv	a1,s2
 74a:	855a                	mv	a0,s6
 74c:	e3fff0ef          	jal	58a <putc>
      state = 0;
 750:	4981                	li	s3,0
 752:	bf35                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 754:	008b8913          	addi	s2,s7,8
 758:	4685                	li	a3,1
 75a:	4629                	li	a2,10
 75c:	000bb583          	ld	a1,0(s7)
 760:	855a                	mv	a0,s6
 762:	e47ff0ef          	jal	5a8 <printint>
        i += 1;
 766:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 768:	8bca                	mv	s7,s2
      state = 0;
 76a:	4981                	li	s3,0
        i += 1;
 76c:	b70d                	j	68e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 76e:	06400793          	li	a5,100
 772:	02f60763          	beq	a2,a5,7a0 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 776:	07500793          	li	a5,117
 77a:	06f60963          	beq	a2,a5,7ec <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 77e:	07800793          	li	a5,120
 782:	faf61ee3          	bne	a2,a5,73e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 786:	008b8913          	addi	s2,s7,8
 78a:	4681                	li	a3,0
 78c:	4641                	li	a2,16
 78e:	000bb583          	ld	a1,0(s7)
 792:	855a                	mv	a0,s6
 794:	e15ff0ef          	jal	5a8 <printint>
        i += 2;
 798:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 79a:	8bca                	mv	s7,s2
      state = 0;
 79c:	4981                	li	s3,0
        i += 2;
 79e:	bdc5                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7a0:	008b8913          	addi	s2,s7,8
 7a4:	4685                	li	a3,1
 7a6:	4629                	li	a2,10
 7a8:	000bb583          	ld	a1,0(s7)
 7ac:	855a                	mv	a0,s6
 7ae:	dfbff0ef          	jal	5a8 <printint>
        i += 2;
 7b2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7b4:	8bca                	mv	s7,s2
      state = 0;
 7b6:	4981                	li	s3,0
        i += 2;
 7b8:	bdd9                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7ba:	008b8913          	addi	s2,s7,8
 7be:	4681                	li	a3,0
 7c0:	4629                	li	a2,10
 7c2:	000be583          	lwu	a1,0(s7)
 7c6:	855a                	mv	a0,s6
 7c8:	de1ff0ef          	jal	5a8 <printint>
 7cc:	8bca                	mv	s7,s2
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	bd7d                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d2:	008b8913          	addi	s2,s7,8
 7d6:	4681                	li	a3,0
 7d8:	4629                	li	a2,10
 7da:	000bb583          	ld	a1,0(s7)
 7de:	855a                	mv	a0,s6
 7e0:	dc9ff0ef          	jal	5a8 <printint>
        i += 1;
 7e4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e6:	8bca                	mv	s7,s2
      state = 0;
 7e8:	4981                	li	s3,0
        i += 1;
 7ea:	b555                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ec:	008b8913          	addi	s2,s7,8
 7f0:	4681                	li	a3,0
 7f2:	4629                	li	a2,10
 7f4:	000bb583          	ld	a1,0(s7)
 7f8:	855a                	mv	a0,s6
 7fa:	dafff0ef          	jal	5a8 <printint>
        i += 2;
 7fe:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 800:	8bca                	mv	s7,s2
      state = 0;
 802:	4981                	li	s3,0
        i += 2;
 804:	b569                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 806:	008b8913          	addi	s2,s7,8
 80a:	4681                	li	a3,0
 80c:	4641                	li	a2,16
 80e:	000be583          	lwu	a1,0(s7)
 812:	855a                	mv	a0,s6
 814:	d95ff0ef          	jal	5a8 <printint>
 818:	8bca                	mv	s7,s2
      state = 0;
 81a:	4981                	li	s3,0
 81c:	bd8d                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 81e:	008b8913          	addi	s2,s7,8
 822:	4681                	li	a3,0
 824:	4641                	li	a2,16
 826:	000bb583          	ld	a1,0(s7)
 82a:	855a                	mv	a0,s6
 82c:	d7dff0ef          	jal	5a8 <printint>
        i += 1;
 830:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 832:	8bca                	mv	s7,s2
      state = 0;
 834:	4981                	li	s3,0
        i += 1;
 836:	bda1                	j	68e <vprintf+0x4a>
 838:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 83a:	008b8d13          	addi	s10,s7,8
 83e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 842:	03000593          	li	a1,48
 846:	855a                	mv	a0,s6
 848:	d43ff0ef          	jal	58a <putc>
  putc(fd, 'x');
 84c:	07800593          	li	a1,120
 850:	855a                	mv	a0,s6
 852:	d39ff0ef          	jal	58a <putc>
 856:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 858:	00000b97          	auipc	s7,0x0
 85c:	3b8b8b93          	addi	s7,s7,952 # c10 <digits>
 860:	03c9d793          	srli	a5,s3,0x3c
 864:	97de                	add	a5,a5,s7
 866:	0007c583          	lbu	a1,0(a5)
 86a:	855a                	mv	a0,s6
 86c:	d1fff0ef          	jal	58a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 870:	0992                	slli	s3,s3,0x4
 872:	397d                	addiw	s2,s2,-1
 874:	fe0916e3          	bnez	s2,860 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 878:	8bea                	mv	s7,s10
      state = 0;
 87a:	4981                	li	s3,0
 87c:	6d02                	ld	s10,0(sp)
 87e:	bd01                	j	68e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 880:	008b8913          	addi	s2,s7,8
 884:	000bc583          	lbu	a1,0(s7)
 888:	855a                	mv	a0,s6
 88a:	d01ff0ef          	jal	58a <putc>
 88e:	8bca                	mv	s7,s2
      state = 0;
 890:	4981                	li	s3,0
 892:	bbf5                	j	68e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 894:	008b8993          	addi	s3,s7,8
 898:	000bb903          	ld	s2,0(s7)
 89c:	00090f63          	beqz	s2,8ba <vprintf+0x276>
        for(; *s; s++)
 8a0:	00094583          	lbu	a1,0(s2)
 8a4:	c195                	beqz	a1,8c8 <vprintf+0x284>
          putc(fd, *s);
 8a6:	855a                	mv	a0,s6
 8a8:	ce3ff0ef          	jal	58a <putc>
        for(; *s; s++)
 8ac:	0905                	addi	s2,s2,1
 8ae:	00094583          	lbu	a1,0(s2)
 8b2:	f9f5                	bnez	a1,8a6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8b4:	8bce                	mv	s7,s3
      state = 0;
 8b6:	4981                	li	s3,0
 8b8:	bbd9                	j	68e <vprintf+0x4a>
          s = "(null)";
 8ba:	00000917          	auipc	s2,0x0
 8be:	34e90913          	addi	s2,s2,846 # c08 <malloc+0x242>
        for(; *s; s++)
 8c2:	02800593          	li	a1,40
 8c6:	b7c5                	j	8a6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8c8:	8bce                	mv	s7,s3
      state = 0;
 8ca:	4981                	li	s3,0
 8cc:	b3c9                	j	68e <vprintf+0x4a>
 8ce:	64a6                	ld	s1,72(sp)
 8d0:	79e2                	ld	s3,56(sp)
 8d2:	7a42                	ld	s4,48(sp)
 8d4:	7aa2                	ld	s5,40(sp)
 8d6:	7b02                	ld	s6,32(sp)
 8d8:	6be2                	ld	s7,24(sp)
 8da:	6c42                	ld	s8,16(sp)
 8dc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 8de:	60e6                	ld	ra,88(sp)
 8e0:	6446                	ld	s0,80(sp)
 8e2:	6906                	ld	s2,64(sp)
 8e4:	6125                	addi	sp,sp,96
 8e6:	8082                	ret

00000000000008e8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8e8:	715d                	addi	sp,sp,-80
 8ea:	ec06                	sd	ra,24(sp)
 8ec:	e822                	sd	s0,16(sp)
 8ee:	1000                	addi	s0,sp,32
 8f0:	e010                	sd	a2,0(s0)
 8f2:	e414                	sd	a3,8(s0)
 8f4:	e818                	sd	a4,16(s0)
 8f6:	ec1c                	sd	a5,24(s0)
 8f8:	03043023          	sd	a6,32(s0)
 8fc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 900:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 904:	8622                	mv	a2,s0
 906:	d3fff0ef          	jal	644 <vprintf>
}
 90a:	60e2                	ld	ra,24(sp)
 90c:	6442                	ld	s0,16(sp)
 90e:	6161                	addi	sp,sp,80
 910:	8082                	ret

0000000000000912 <printf>:

void
printf(const char *fmt, ...)
{
 912:	711d                	addi	sp,sp,-96
 914:	ec06                	sd	ra,24(sp)
 916:	e822                	sd	s0,16(sp)
 918:	1000                	addi	s0,sp,32
 91a:	e40c                	sd	a1,8(s0)
 91c:	e810                	sd	a2,16(s0)
 91e:	ec14                	sd	a3,24(s0)
 920:	f018                	sd	a4,32(s0)
 922:	f41c                	sd	a5,40(s0)
 924:	03043823          	sd	a6,48(s0)
 928:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 92c:	00840613          	addi	a2,s0,8
 930:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 934:	85aa                	mv	a1,a0
 936:	4505                	li	a0,1
 938:	d0dff0ef          	jal	644 <vprintf>
}
 93c:	60e2                	ld	ra,24(sp)
 93e:	6442                	ld	s0,16(sp)
 940:	6125                	addi	sp,sp,96
 942:	8082                	ret

0000000000000944 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 944:	1141                	addi	sp,sp,-16
 946:	e422                	sd	s0,8(sp)
 948:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 94a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 94e:	00000797          	auipc	a5,0x0
 952:	6b27b783          	ld	a5,1714(a5) # 1000 <freep>
 956:	a02d                	j	980 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 958:	4618                	lw	a4,8(a2)
 95a:	9f2d                	addw	a4,a4,a1
 95c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 960:	6398                	ld	a4,0(a5)
 962:	6310                	ld	a2,0(a4)
 964:	a83d                	j	9a2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 966:	ff852703          	lw	a4,-8(a0)
 96a:	9f31                	addw	a4,a4,a2
 96c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 96e:	ff053683          	ld	a3,-16(a0)
 972:	a091                	j	9b6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 974:	6398                	ld	a4,0(a5)
 976:	00e7e463          	bltu	a5,a4,97e <free+0x3a>
 97a:	00e6ea63          	bltu	a3,a4,98e <free+0x4a>
{
 97e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 980:	fed7fae3          	bgeu	a5,a3,974 <free+0x30>
 984:	6398                	ld	a4,0(a5)
 986:	00e6e463          	bltu	a3,a4,98e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 98a:	fee7eae3          	bltu	a5,a4,97e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 98e:	ff852583          	lw	a1,-8(a0)
 992:	6390                	ld	a2,0(a5)
 994:	02059813          	slli	a6,a1,0x20
 998:	01c85713          	srli	a4,a6,0x1c
 99c:	9736                	add	a4,a4,a3
 99e:	fae60de3          	beq	a2,a4,958 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9a2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9a6:	4790                	lw	a2,8(a5)
 9a8:	02061593          	slli	a1,a2,0x20
 9ac:	01c5d713          	srli	a4,a1,0x1c
 9b0:	973e                	add	a4,a4,a5
 9b2:	fae68ae3          	beq	a3,a4,966 <free+0x22>
    p->s.ptr = bp->s.ptr;
 9b6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9b8:	00000717          	auipc	a4,0x0
 9bc:	64f73423          	sd	a5,1608(a4) # 1000 <freep>
}
 9c0:	6422                	ld	s0,8(sp)
 9c2:	0141                	addi	sp,sp,16
 9c4:	8082                	ret

00000000000009c6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9c6:	7139                	addi	sp,sp,-64
 9c8:	fc06                	sd	ra,56(sp)
 9ca:	f822                	sd	s0,48(sp)
 9cc:	f426                	sd	s1,40(sp)
 9ce:	ec4e                	sd	s3,24(sp)
 9d0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9d2:	02051493          	slli	s1,a0,0x20
 9d6:	9081                	srli	s1,s1,0x20
 9d8:	04bd                	addi	s1,s1,15
 9da:	8091                	srli	s1,s1,0x4
 9dc:	0014899b          	addiw	s3,s1,1
 9e0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9e2:	00000517          	auipc	a0,0x0
 9e6:	61e53503          	ld	a0,1566(a0) # 1000 <freep>
 9ea:	c915                	beqz	a0,a1e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ee:	4798                	lw	a4,8(a5)
 9f0:	08977a63          	bgeu	a4,s1,a84 <malloc+0xbe>
 9f4:	f04a                	sd	s2,32(sp)
 9f6:	e852                	sd	s4,16(sp)
 9f8:	e456                	sd	s5,8(sp)
 9fa:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9fc:	8a4e                	mv	s4,s3
 9fe:	0009871b          	sext.w	a4,s3
 a02:	6685                	lui	a3,0x1
 a04:	00d77363          	bgeu	a4,a3,a0a <malloc+0x44>
 a08:	6a05                	lui	s4,0x1
 a0a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a0e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a12:	00000917          	auipc	s2,0x0
 a16:	5ee90913          	addi	s2,s2,1518 # 1000 <freep>
  if(p == SBRK_ERROR)
 a1a:	5afd                	li	s5,-1
 a1c:	a081                	j	a5c <malloc+0x96>
 a1e:	f04a                	sd	s2,32(sp)
 a20:	e852                	sd	s4,16(sp)
 a22:	e456                	sd	s5,8(sp)
 a24:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a26:	00000797          	auipc	a5,0x0
 a2a:	5ea78793          	addi	a5,a5,1514 # 1010 <base>
 a2e:	00000717          	auipc	a4,0x0
 a32:	5cf73923          	sd	a5,1490(a4) # 1000 <freep>
 a36:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a38:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a3c:	b7c1                	j	9fc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a3e:	6398                	ld	a4,0(a5)
 a40:	e118                	sd	a4,0(a0)
 a42:	a8a9                	j	a9c <malloc+0xd6>
  hp->s.size = nu;
 a44:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a48:	0541                	addi	a0,a0,16
 a4a:	efbff0ef          	jal	944 <free>
  return freep;
 a4e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a52:	c12d                	beqz	a0,ab4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a54:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a56:	4798                	lw	a4,8(a5)
 a58:	02977263          	bgeu	a4,s1,a7c <malloc+0xb6>
    if(p == freep)
 a5c:	00093703          	ld	a4,0(s2)
 a60:	853e                	mv	a0,a5
 a62:	fef719e3          	bne	a4,a5,a54 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a66:	8552                	mv	a0,s4
 a68:	a37ff0ef          	jal	49e <sbrk>
  if(p == SBRK_ERROR)
 a6c:	fd551ce3          	bne	a0,s5,a44 <malloc+0x7e>
        return 0;
 a70:	4501                	li	a0,0
 a72:	7902                	ld	s2,32(sp)
 a74:	6a42                	ld	s4,16(sp)
 a76:	6aa2                	ld	s5,8(sp)
 a78:	6b02                	ld	s6,0(sp)
 a7a:	a03d                	j	aa8 <malloc+0xe2>
 a7c:	7902                	ld	s2,32(sp)
 a7e:	6a42                	ld	s4,16(sp)
 a80:	6aa2                	ld	s5,8(sp)
 a82:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a84:	fae48de3          	beq	s1,a4,a3e <malloc+0x78>
        p->s.size -= nunits;
 a88:	4137073b          	subw	a4,a4,s3
 a8c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a8e:	02071693          	slli	a3,a4,0x20
 a92:	01c6d713          	srli	a4,a3,0x1c
 a96:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a98:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a9c:	00000717          	auipc	a4,0x0
 aa0:	56a73223          	sd	a0,1380(a4) # 1000 <freep>
      return (void*)(p + 1);
 aa4:	01078513          	addi	a0,a5,16
  }
}
 aa8:	70e2                	ld	ra,56(sp)
 aaa:	7442                	ld	s0,48(sp)
 aac:	74a2                	ld	s1,40(sp)
 aae:	69e2                	ld	s3,24(sp)
 ab0:	6121                	addi	sp,sp,64
 ab2:	8082                	ret
 ab4:	7902                	ld	s2,32(sp)
 ab6:	6a42                	ld	s4,16(sp)
 ab8:	6aa2                	ld	s5,8(sp)
 aba:	6b02                	ld	s6,0(sp)
 abc:	b7f5                	j	aa8 <malloc+0xe2>
