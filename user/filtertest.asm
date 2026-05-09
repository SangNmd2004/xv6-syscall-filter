
user/_filtertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <result>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/filter.h"

static void result(const char *name, int ok) {
0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
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
  uint64 mask_test = 0x12345;
  uint64 result;

  printf("FILTERTEST: Bat dau kiem tra...\n");
   8:	00001517          	auipc	a0,0x1
   c:	92850513          	addi	a0,a0,-1752 # 930 <malloc+0x102>
   c:	a3850513          	addi	a0,a0,-1480 # a40 <filter_debug_status+0x9e>
  10:	76a000ef          	jal	77a <printf>

  // 1. Kiem tra setfilter
  if(setfilter(mask_test) < 0){
  14:	6549                	lui	a0,0x12
  16:	34550513          	addi	a0,a0,837 # 12345 <base+0x11335>
  16:	34550513          	addi	a0,a0,837 # 12345 <base+0x10335>
  1a:	3c0000ef          	jal	3da <setfilter>
  1e:	02054a63          	bltz	a0,52 <main+0x52>
    printf("FILTERTEST: Loi khi goi setfilter\n");
    exit(1);
  }
  printf("FILTERTEST: Da set mask = 0x12345\n");
  22:	00001517          	auipc	a0,0x1
  26:	95e50513          	addi	a0,a0,-1698 # 980 <malloc+0x152>
  26:	a6e50513          	addi	a0,a0,-1426 # a90 <filter_debug_status+0xee>
  2a:	750000ef          	jal	77a <printf>

  // 2. Kiem tra getfilter
  result = getfilter();
  2e:	3b4000ef          	jal	3e2 <getfilter>
  
  if(result == mask_test){
  32:	67c9                	lui	a5,0x12
  34:	34578793          	addi	a5,a5,837 # 12345 <base+0x11335>
  34:	34578793          	addi	a5,a5,837 # 12345 <base+0x10335>
  38:	02f50663          	beq	a0,a5,64 <main+0x64>
    printf("FILTERTEST: Get dung gia tri! (Ket qua: 0x%x)\n", (int)result);
  } else {
    printf("FILTERTEST: SAI! Mong doi 0x12345, nhan duoc 0x%x\n", (int)result);
  3c:	0005059b          	sext.w	a1,a0
  40:	00001517          	auipc	a0,0x1
  44:	99850513          	addi	a0,a0,-1640 # 9d8 <malloc+0x1aa>
  44:	aa850513          	addi	a0,a0,-1368 # ae8 <filter_debug_status+0x146>
  48:	732000ef          	jal	77a <printf>
    exit(1);
  4c:	4505                	li	a0,1
  4e:	2ec000ef          	jal	33a <exit>
    printf("FILTERTEST: Loi khi goi setfilter\n");
  52:	00001517          	auipc	a0,0x1
  56:	90650513          	addi	a0,a0,-1786 # 958 <malloc+0x12a>
  56:	a1650513          	addi	a0,a0,-1514 # a68 <filter_debug_status+0xc6>
  5a:	720000ef          	jal	77a <printf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	2da000ef          	jal	33a <exit>
    printf("FILTERTEST: Get dung gia tri! (Ket qua: 0x%x)\n", (int)result);
  64:	85be                	mv	a1,a5
  66:	00001517          	auipc	a0,0x1
  6a:	94250513          	addi	a0,a0,-1726 # 9a8 <malloc+0x17a>
  6a:	a5250513          	addi	a0,a0,-1454 # ab8 <filter_debug_status+0x116>
  6e:	70c000ef          	jal	77a <printf>
  }

  // 3. Kiem tra voi gia tri khac
  setfilter(88);
  72:	05800513          	li	a0,88
  76:	364000ef          	jal	3da <setfilter>
  if(getfilter() == 88){
  7a:	368000ef          	jal	3e2 <getfilter>
  7e:	05800793          	li	a5,88
  82:	00f50b63          	beq	a0,a5,98 <main+0x98>
    printf("FILTERTEST: Test voi gia tri 88: SUCCESS\n");
  }

  printf("FILTERTEST: Hoan thanh tat ca kiem tra.\n");
  86:	00001517          	auipc	a0,0x1
  8a:	9ba50513          	addi	a0,a0,-1606 # a40 <malloc+0x212>
  8a:	aca50513          	addi	a0,a0,-1334 # b50 <filter_debug_status+0x1ae>
  8e:	6ec000ef          	jal	77a <printf>

  // Lenh nay cuc ky quan trong de dung process
  exit(0);
  92:	4501                	li	a0,0
  94:	2a6000ef          	jal	33a <exit>
    printf("FILTERTEST: Test voi gia tri 88: SUCCESS\n");
  98:	00001517          	auipc	a0,0x1
  9c:	97850513          	addi	a0,a0,-1672 # a10 <malloc+0x1e2>
  9c:	a8850513          	addi	a0,a0,-1400 # b20 <filter_debug_status+0x17e>
  a0:	6da000ef          	jal	77a <printf>
  a4:	b7cd                	j	86 <main+0x86>

00000000000000a6 <start>:
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
  a6:	1141                	addi	sp,sp,-16
  a8:	e406                	sd	ra,8(sp)
  aa:	e022                	sd	s0,0(sp)
  ac:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ae:	f53ff0ef          	jal	0 <main>
  exit(r);
  b2:	288000ef          	jal	33a <exit>

00000000000000b6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
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
 320:	892a                	mv	s2,a0
 322:	4481                	li	s1,0
 188:	892a                	mv	s2,a0
 18a:	4481                	li	s1,0
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
 376:	1101                	addi	sp,sp,-32
 378:	ec06                	sd	ra,24(sp)
 37a:	e822                	sd	s0,16(sp)
 37c:	e04a                	sd	s2,0(sp)
 37e:	1000                	addi	s0,sp,32
 380:	892e                	mv	s2,a1
 1de:	1101                	addi	sp,sp,-32
 1e0:	ec06                	sd	ra,24(sp)
 1e2:	e822                	sd	s0,16(sp)
 1e4:	e04a                	sd	s2,0(sp)
 1e6:	1000                	addi	s0,sp,32
 1e8:	892e                	mv	s2,a1
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
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e422                	sd	s0,8(sp)
 3b4:	0800                	addi	s0,sp,16
 218:	1141                	addi	sp,sp,-16
 21a:	e422                	sd	s0,8(sp)
 21c:	0800                	addi	s0,sp,16
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
 3f8:	1141                	addi	sp,sp,-16
 3fa:	e422                	sd	s0,8(sp)
 3fc:	0800                	addi	s0,sp,16
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
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
 5a8:	715d                	addi	sp,sp,-80
 5aa:	e486                	sd	ra,72(sp)
 5ac:	e0a2                	sd	s0,64(sp)
 5ae:	f84a                	sd	s2,48(sp)
 5b0:	0880                	addi	s0,sp,80
 5b2:	892a                	mv	s2,a0
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
 5b4:	c299                	beqz	a3,5ba <printint+0x12>
 5b6:	0805c363          	bltz	a1,63c <printint+0x94>
  neg = 0;
 5ba:	4881                	li	a7,0
 5bc:	fb840693          	addi	a3,s0,-72
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
 428:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 42a:	00000517          	auipc	a0,0x0
 42e:	64e50513          	addi	a0,a0,1614 # a78 <digits>
 428:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 42a:	00001517          	auipc	a0,0x1
 42e:	82650513          	addi	a0,a0,-2010 # c50 <digits>
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
 644:	711d                	addi	sp,sp,-96
 646:	ec86                	sd	ra,88(sp)
 648:	e8a2                	sd	s0,80(sp)
 64a:	e0ca                	sd	s2,64(sp)
 64c:	1080                	addi	s0,sp,96
 4ac:	711d                	addi	sp,sp,-96
 4ae:	ec86                	sd	ra,88(sp)
 4b0:	e8a2                	sd	s0,80(sp)
 4b2:	e0ca                	sd	s2,64(sp)
 4b4:	1080                	addi	s0,sp,96
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
 672:	02500a93          	li	s5,37
 4da:	02500a93          	li	s5,37
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
 6c8:	07500713          	li	a4,117
 6cc:	0ee78763          	beq	a5,a4,7ba <vprintf+0x176>
 530:	07500713          	li	a4,117
 534:	0ee78763          	beq	a5,a4,622 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6d0:	07800713          	li	a4,120
 6d4:	12e78963          	beq	a5,a4,806 <vprintf+0x1c2>
 538:	07800713          	li	a4,120
 53c:	12e78963          	beq	a5,a4,66e <vprintf+0x1c2>
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
 6f0:	02500713          	li	a4,37
 6f4:	04e79563          	bne	a5,a4,73e <vprintf+0xfa>
        putc(fd, '%');
 6f8:	02500593          	li	a1,37
 6fc:	855a                	mv	a0,s6
 6fe:	e8dff0ef          	jal	58a <putc>
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
 6c4:	3b8b8b93          	addi	s7,s7,952 # a78 <digits>
 6c4:	590b8b93          	addi	s7,s7,1424 # c50 <digits>
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
 726:	34e90913          	addi	s2,s2,846 # a70 <malloc+0x242>
 726:	45e90913          	addi	s2,s2,1118 # b80 <filter_debug_status+0x1de>
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
 7ac:	1141                	addi	sp,sp,-16
 7ae:	e422                	sd	s0,8(sp)
 7b0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b6:	00001797          	auipc	a5,0x1
 7ba:	84a7b783          	ld	a5,-1974(a5) # 1000 <freep>
 7b6:	00002797          	auipc	a5,0x2
 7ba:	84a7b783          	ld	a5,-1974(a5) # 2000 <freep>
 7be:	a02d                	j	7e8 <free+0x3c>
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
 820:	00001717          	auipc	a4,0x1
 824:	7ef73023          	sd	a5,2016(a4) # 2000 <freep>
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
 9c6:	7139                	addi	sp,sp,-64
 9c8:	fc06                	sd	ra,56(sp)
 9ca:	f822                	sd	s0,48(sp)
 9cc:	f426                	sd	s1,40(sp)
 9ce:	ec4e                	sd	s3,24(sp)
 9d0:	0080                	addi	s0,sp,64
 82e:	7139                	addi	sp,sp,-64
 830:	fc06                	sd	ra,56(sp)
 832:	f822                	sd	s0,48(sp)
 834:	f426                	sd	s1,40(sp)
 836:	ec4e                	sd	s3,24(sp)
 838:	0080                	addi	s0,sp,64
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
 83a:	02051493          	slli	s1,a0,0x20
 83e:	9081                	srli	s1,s1,0x20
 840:	04bd                	addi	s1,s1,15
 842:	8091                	srli	s1,s1,0x4
 844:	0014899b          	addiw	s3,s1,1
 848:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 84a:	00000517          	auipc	a0,0x0
 84e:	7b653503          	ld	a0,1974(a0) # 1000 <freep>
 84a:	00001517          	auipc	a0,0x1
 84e:	7b653503          	ld	a0,1974(a0) # 2000 <freep>
 852:	c915                	beqz	a0,886 <malloc+0x58>
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
 87a:	00000917          	auipc	s2,0x0
 87e:	78690913          	addi	s2,s2,1926 # 1000 <freep>
 87a:	00001917          	auipc	s2,0x1
 87e:	78690913          	addi	s2,s2,1926 # 2000 <freep>
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
 88e:	00001797          	auipc	a5,0x1
 892:	78278793          	addi	a5,a5,1922 # 2010 <base>
 896:	00001717          	auipc	a4,0x1
 89a:	76f73523          	sd	a5,1898(a4) # 2000 <freep>
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
 904:	00001717          	auipc	a4,0x1
 908:	6ea73e23          	sd	a0,1788(a4) # 2000 <freep>
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

0000000000000926 <filter_apply>:
#include "kernel/types.h"
#include "user/user.h"
#include "user/filter.h"

int filter_apply(long blacklist_mask) {
 926:	1141                	addi	sp,sp,-16
 928:	e406                	sd	ra,8(sp)
 92a:	e022                	sd	s0,0(sp)
 92c:	0800                	addi	s0,sp,16
    // Vì kernel của bạn đang dùng Whitelist (1 là cho phép), 
    // nhưng API này dùng Blacklist (1 là chặn), chúng ta cần đảo bit.
    return setfilter(~blacklist_mask);
 92e:	fff54513          	not	a0,a0
 932:	aa9ff0ef          	jal	3da <setfilter>
}
 936:	60a2                	ld	ra,8(sp)
 938:	6402                	ld	s0,0(sp)
 93a:	0141                	addi	sp,sp,16
 93c:	8082                	ret

000000000000093e <filter_block_syscall>:

int filter_block_syscall(int sys_num) {
 93e:	1101                	addi	sp,sp,-32
 940:	ec06                	sd	ra,24(sp)
 942:	e822                	sd	s0,16(sp)
 944:	e426                	sd	s1,8(sp)
 946:	1000                	addi	s0,sp,32
 948:	84aa                	mv	s1,a0
    long current_mask = getfilter();
 94a:	a99ff0ef          	jal	3e2 <getfilter>
    // Tắt bit tương ứng với syscall đó trong whitelist
    return setfilter(current_mask & ~BLOCK(sys_num));
 94e:	4785                	li	a5,1
 950:	009797b3          	sll	a5,a5,s1
 954:	fff7c793          	not	a5,a5
 958:	8d7d                	and	a0,a0,a5
 95a:	a81ff0ef          	jal	3da <setfilter>
}
 95e:	60e2                	ld	ra,24(sp)
 960:	6442                	ld	s0,16(sp)
 962:	64a2                	ld	s1,8(sp)
 964:	6105                	addi	sp,sp,32
 966:	8082                	ret

0000000000000968 <filter_reset>:

int filter_reset(void) {
 968:	1141                	addi	sp,sp,-16
 96a:	e406                	sd	ra,8(sp)
 96c:	e022                	sd	s0,0(sp)
 96e:	0800                	addi	s0,sp,16
    return setfilter(0xFFFFFFFFFFFFFFFFL); // Cho phép tất cả
 970:	557d                	li	a0,-1
 972:	a69ff0ef          	jal	3da <setfilter>
}
 976:	60a2                	ld	ra,8(sp)
 978:	6402                	ld	s0,0(sp)
 97a:	0141                	addi	sp,sp,16
 97c:	8082                	ret

000000000000097e <filter_is_blocked>:

int filter_is_blocked(int sys_num) {
 97e:	1101                	addi	sp,sp,-32
 980:	ec06                	sd	ra,24(sp)
 982:	e822                	sd	s0,16(sp)
 984:	e426                	sd	s1,8(sp)
 986:	1000                	addi	s0,sp,32
 988:	84aa                	mv	s1,a0
    long current_mask = getfilter();
 98a:	a59ff0ef          	jal	3e2 <getfilter>
    return !(current_mask & BLOCK(sys_num));
 98e:	40955533          	sra	a0,a0,s1
 992:	00154513          	xori	a0,a0,1
}
 996:	8905                	andi	a0,a0,1
 998:	60e2                	ld	ra,24(sp)
 99a:	6442                	ld	s0,16(sp)
 99c:	64a2                	ld	s1,8(sp)
 99e:	6105                	addi	sp,sp,32
 9a0:	8082                	ret

00000000000009a2 <filter_debug_status>:

void filter_debug_status(void) {
 9a2:	1101                	addi	sp,sp,-32
 9a4:	ec06                	sd	ra,24(sp)
 9a6:	e822                	sd	s0,16(sp)
 9a8:	e426                	sd	s1,8(sp)
 9aa:	1000                	addi	s0,sp,32
    long m = getfilter();
 9ac:	a37ff0ef          	jal	3e2 <getfilter>
 9b0:	84aa                	mv	s1,a0
    printf("\n[Sandbox Monitor]\n");
 9b2:	00000517          	auipc	a0,0x0
 9b6:	20650513          	addi	a0,a0,518 # bb8 <filter_debug_status+0x216>
 9ba:	dc1ff0ef          	jal	77a <printf>
    printf("Whitelist Mask: %ld\n", m);
 9be:	85a6                	mv	a1,s1
 9c0:	00000517          	auipc	a0,0x0
 9c4:	21050513          	addi	a0,a0,528 # bd0 <filter_debug_status+0x22e>
 9c8:	db3ff0ef          	jal	77a <printf>
    printf("Security Level: %s\n", (m == 0xFFFFFFFFFFFFFFFFL) ? "LOW (Permissive)" : "HIGH (Restricted)");
 9cc:	57fd                	li	a5,-1
 9ce:	00000597          	auipc	a1,0x0
 9d2:	1d258593          	addi	a1,a1,466 # ba0 <filter_debug_status+0x1fe>
 9d6:	02f48b63          	beq	s1,a5,a0c <filter_debug_status+0x6a>
 9da:	00000517          	auipc	a0,0x0
 9de:	20e50513          	addi	a0,a0,526 # be8 <filter_debug_status+0x246>
 9e2:	d99ff0ef          	jal	77a <printf>
    
    if(filter_is_blocked(SYS_open)) printf(" - File access: LOCKED\n");
 9e6:	453d                	li	a0,15
 9e8:	f97ff0ef          	jal	97e <filter_is_blocked>
 9ec:	e50d                	bnez	a0,a16 <filter_debug_status+0x74>
    if(filter_is_blocked(SYS_fork)) printf(" - Process creation: LOCKED\n");
 9ee:	4505                	li	a0,1
 9f0:	f8fff0ef          	jal	97e <filter_is_blocked>
 9f4:	e905                	bnez	a0,a24 <filter_debug_status+0x82>
    printf("------------------\n");
 9f6:	00000517          	auipc	a0,0x0
 9fa:	24250513          	addi	a0,a0,578 # c38 <filter_debug_status+0x296>
 9fe:	d7dff0ef          	jal	77a <printf>
 a02:	60e2                	ld	ra,24(sp)
 a04:	6442                	ld	s0,16(sp)
 a06:	64a2                	ld	s1,8(sp)
 a08:	6105                	addi	sp,sp,32
 a0a:	8082                	ret
    printf("Security Level: %s\n", (m == 0xFFFFFFFFFFFFFFFFL) ? "LOW (Permissive)" : "HIGH (Restricted)");
 a0c:	00000597          	auipc	a1,0x0
 a10:	17c58593          	addi	a1,a1,380 # b88 <filter_debug_status+0x1e6>
 a14:	b7d9                	j	9da <filter_debug_status+0x38>
    if(filter_is_blocked(SYS_open)) printf(" - File access: LOCKED\n");
 a16:	00000517          	auipc	a0,0x0
 a1a:	1ea50513          	addi	a0,a0,490 # c00 <filter_debug_status+0x25e>
 a1e:	d5dff0ef          	jal	77a <printf>
 a22:	b7f1                	j	9ee <filter_debug_status+0x4c>
    if(filter_is_blocked(SYS_fork)) printf(" - Process creation: LOCKED\n");
 a24:	00000517          	auipc	a0,0x0
 a28:	1f450513          	addi	a0,a0,500 # c18 <filter_debug_status+0x276>
 a2c:	d4fff0ef          	jal	77a <printf>
 a30:	b7d9                	j	9f6 <filter_debug_status+0x54>
