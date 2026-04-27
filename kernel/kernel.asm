
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	8a010113          	addi	sp,sp,-1888 # 800078a0 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda67>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dbc78793          	addi	a5,a5,-580 # 80000e3c <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	174020ef          	jal	80002286 <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	0000f517          	auipc	a0,0xf
    80000190:	71450513          	addi	a0,a0,1812 # 8000f8a0 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	0000f497          	auipc	s1,0xf
    8000019c:	70848493          	addi	s1,s1,1800 # 8000f8a0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	0000f917          	auipc	s2,0xf
    800001a4:	79890913          	addi	s2,s2,1944 # 8000f938 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	716010ef          	jal	800018ce <myproc>
    800001bc:	75d010ef          	jal	80002118 <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	51b010ef          	jal	80001ee0 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	0000f717          	auipc	a4,0xf
    800001dc:	6c870713          	addi	a4,a4,1736 # 8000f8a0 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	032020ef          	jal	8000223c <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	0000f517          	auipc	a0,0xf
    80000226:	67e50513          	addi	a0,a0,1662 # 8000f8a0 <cons>
    8000022a:	23d000ef          	jal	80000c66 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	0000f717          	auipc	a4,0xf
    80000250:	6ef72623          	sw	a5,1772(a4) # 8000f938 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	0000f517          	auipc	a0,0xf
    80000266:	63e50513          	addi	a0,a0,1598 # 8000f8a0 <cons>
    8000026a:	1fd000ef          	jal	80000c66 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	0000f517          	auipc	a0,0xf
    800002ba:	5ea50513          	addi	a0,a0,1514 # 8000f8a0 <cons>
    800002be:	111000ef          	jal	80000bce <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	7f9010ef          	jal	800022d0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	0000f517          	auipc	a0,0xf
    800002e0:	5c450513          	addi	a0,a0,1476 # 8000f8a0 <cons>
    800002e4:	183000ef          	jal	80000c66 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	0000f717          	auipc	a4,0xf
    800002fe:	5a670713          	addi	a4,a4,1446 # 8000f8a0 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	0000f797          	auipc	a5,0xf
    80000324:	58078793          	addi	a5,a5,1408 # 8000f8a0 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	0000f797          	auipc	a5,0xf
    80000352:	5ea7a783          	lw	a5,1514(a5) # 8000f938 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	0000f717          	auipc	a4,0xf
    80000368:	53c70713          	addi	a4,a4,1340 # 8000f8a0 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	0000f497          	auipc	s1,0xf
    80000378:	52c48493          	addi	s1,s1,1324 # 8000f8a0 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	0000f717          	auipc	a4,0xf
    800003ba:	4ea70713          	addi	a4,a4,1258 # 8000f8a0 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	0000f717          	auipc	a4,0xf
    800003d0:	56f72a23          	sw	a5,1396(a4) # 8000f940 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	0000f797          	auipc	a5,0xf
    800003ee:	4b678793          	addi	a5,a5,1206 # 8000f8a0 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	0000f797          	auipc	a5,0xf
    80000412:	52c7a723          	sw	a2,1326(a5) # 8000f93c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	0000f517          	auipc	a0,0xf
    8000041a:	51250513          	addi	a0,a0,1298 # 8000f928 <cons+0x98>
    8000041e:	30f010ef          	jal	80001f2c <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00007597          	auipc	a1,0x7
    80000430:	bd458593          	addi	a1,a1,-1068 # 80007000 <etext>
    80000434:	0000f517          	auipc	a0,0xf
    80000438:	46c50513          	addi	a0,a0,1132 # 8000f8a0 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	0001f797          	auipc	a5,0x1f
    80000448:	7bc78793          	addi	a5,a5,1980 # 8001fc00 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007617          	auipc	a2,0x7
    80000482:	2ba60613          	addi	a2,a2,698 # 80007738 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	35c7a783          	lw	a5,860(a5) # 80007874 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	0000f517          	auipc	a0,0xf
    80000564:	3e850513          	addi	a0,a0,1000 # 8000f948 <pr>
    80000568:	666000ef          	jal	80000bce <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00007b97          	auipc	s7,0x7
    8000072c:	010b8b93          	addi	s7,s7,16 # 80007738 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00007917          	auipc	s2,0x7
    8000078c:	88090913          	addi	s2,s2,-1920 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	00007797          	auipc	a5,0x7
    800007c0:	0b87a783          	lw	a5,184(a5) # 80007874 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	0000f517          	auipc	a0,0xf
    800007d6:	17650513          	addi	a0,a0,374 # 8000f948 <pr>
    800007da:	48c000ef          	jal	80000c66 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	00007797          	auipc	a5,0x7
    800007f4:	0927a223          	sw	s2,132(a5) # 80007874 <panicking>
  printf("panic: ");
    800007f8:	00007517          	auipc	a0,0x7
    800007fc:	82050513          	addi	a0,a0,-2016 # 80007018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00007517          	auipc	a0,0x7
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80007020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	00007797          	auipc	a5,0x7
    80000816:	0527af23          	sw	s2,94(a5) # 80007870 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00007597          	auipc	a1,0x7
    80000828:	80458593          	addi	a1,a1,-2044 # 80007028 <etext+0x28>
    8000082c:	0000f517          	auipc	a0,0xf
    80000830:	11c50513          	addi	a0,a0,284 # 8000f948 <pr>
    80000834:	31a000ef          	jal	80000b4e <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00006597          	auipc	a1,0x6
    80000880:	7b458593          	addi	a1,a1,1972 # 80007030 <etext+0x30>
    80000884:	0000f517          	auipc	a0,0xf
    80000888:	0dc50513          	addi	a0,a0,220 # 8000f960 <tx_lock>
    8000088c:	2c2000ef          	jal	80000b4e <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	0000f517          	auipc	a0,0xf
    800008ac:	0b850513          	addi	a0,a0,184 # 8000f960 <tx_lock>
    800008b0:	31e000ef          	jal	80000bce <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	00007497          	auipc	s1,0x7
    800008ca:	fb648493          	addi	s1,s1,-74 # 8000787c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	0000f997          	auipc	s3,0xf
    800008d2:	09298993          	addi	s3,s3,146 # 8000f960 <tx_lock>
    800008d6:	00007917          	auipc	s2,0x7
    800008da:	fa290913          	addi	s2,s2,-94 # 80007878 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	5f6010ef          	jal	80001ee0 <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	0000f517          	auipc	a0,0xf
    80000918:	04c50513          	addi	a0,a0,76 # 8000f960 <tx_lock>
    8000091c:	34a000ef          	jal	80000c66 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	00007797          	auipc	a5,0x7
    8000093c:	f3c7a783          	lw	a5,-196(a5) # 80007874 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	00007797          	auipc	a5,0x7
    80000946:	f2e7a783          	lw	a5,-210(a5) # 80007870 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	00007797          	auipc	a5,0x7
    8000096c:	f0c7a783          	lw	a5,-244(a5) # 80007874 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	212000ef          	jal	80000b8e <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	28e000ef          	jal	80000c12 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	0000f517          	auipc	a0,0xf
    800009c8:	f9c50513          	addi	a0,a0,-100 # 8000f960 <tx_lock>
    800009cc:	202000ef          	jal	80000bce <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	0000f517          	auipc	a0,0xf
    800009e4:	f8050513          	addi	a0,a0,-128 # 8000f960 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00007797          	auipc	a5,0x7
    800009f4:	e807a623          	sw	zero,-372(a5) # 8000787c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00007517          	auipc	a0,0x7
    800009fc:	e7050513          	addi	a0,a0,-400 # 80007868 <tx_chan>
    80000a00:	52c010ef          	jal	80001f2c <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	e04a                	sd	s2,0(sp)
    80000a26:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a28:	03451793          	slli	a5,a0,0x34
    80000a2c:	e7a9                	bnez	a5,80000a76 <kfree+0x5a>
    80000a2e:	84aa                	mv	s1,a0
    80000a30:	00020797          	auipc	a5,0x20
    80000a34:	36878793          	addi	a5,a5,872 # 80020d98 <end>
    80000a38:	02f56f63          	bltu	a0,a5,80000a76 <kfree+0x5a>
    80000a3c:	47c5                	li	a5,17
    80000a3e:	07ee                	slli	a5,a5,0x1b
    80000a40:	02f57b63          	bgeu	a0,a5,80000a76 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a44:	6605                	lui	a2,0x1
    80000a46:	4585                	li	a1,1
    80000a48:	25a000ef          	jal	80000ca2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a4c:	0000f917          	auipc	s2,0xf
    80000a50:	f2c90913          	addi	s2,s2,-212 # 8000f978 <kmem>
    80000a54:	854a                	mv	a0,s2
    80000a56:	178000ef          	jal	80000bce <acquire>
  r->next = kmem.freelist;
    80000a5a:	01893783          	ld	a5,24(s2)
    80000a5e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a60:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a64:	854a                	mv	a0,s2
    80000a66:	200000ef          	jal	80000c66 <release>
}
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret
    panic("kfree");
    80000a76:	00006517          	auipc	a0,0x6
    80000a7a:	5c250513          	addi	a0,a0,1474 # 80007038 <etext+0x38>
    80000a7e:	d63ff0ef          	jal	800007e0 <panic>

0000000080000a82 <freerange>:
{
    80000a82:	7179                	addi	sp,sp,-48
    80000a84:	f406                	sd	ra,40(sp)
    80000a86:	f022                	sd	s0,32(sp)
    80000a88:	ec26                	sd	s1,24(sp)
    80000a8a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a8c:	6785                	lui	a5,0x1
    80000a8e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a92:	00e504b3          	add	s1,a0,a4
    80000a96:	777d                	lui	a4,0xfffff
    80000a98:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	94be                	add	s1,s1,a5
    80000a9c:	0295e263          	bltu	a1,s1,80000ac0 <freerange+0x3e>
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	892e                	mv	s2,a1
    kfree(p);
    80000aa8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aaa:	6985                	lui	s3,0x1
    kfree(p);
    80000aac:	01448533          	add	a0,s1,s4
    80000ab0:	f6dff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab4:	94ce                	add	s1,s1,s3
    80000ab6:	fe997be3          	bgeu	s2,s1,80000aac <freerange+0x2a>
    80000aba:	6942                	ld	s2,16(sp)
    80000abc:	69a2                	ld	s3,8(sp)
    80000abe:	6a02                	ld	s4,0(sp)
}
    80000ac0:	70a2                	ld	ra,40(sp)
    80000ac2:	7402                	ld	s0,32(sp)
    80000ac4:	64e2                	ld	s1,24(sp)
    80000ac6:	6145                	addi	sp,sp,48
    80000ac8:	8082                	ret

0000000080000aca <kinit>:
{
    80000aca:	1141                	addi	sp,sp,-16
    80000acc:	e406                	sd	ra,8(sp)
    80000ace:	e022                	sd	s0,0(sp)
    80000ad0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ad2:	00006597          	auipc	a1,0x6
    80000ad6:	56e58593          	addi	a1,a1,1390 # 80007040 <etext+0x40>
    80000ada:	0000f517          	auipc	a0,0xf
    80000ade:	e9e50513          	addi	a0,a0,-354 # 8000f978 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00020517          	auipc	a0,0x20
    80000aee:	2ae50513          	addi	a0,a0,686 # 80020d98 <end>
    80000af2:	f91ff0ef          	jal	80000a82 <freerange>
}
    80000af6:	60a2                	ld	ra,8(sp)
    80000af8:	6402                	ld	s0,0(sp)
    80000afa:	0141                	addi	sp,sp,16
    80000afc:	8082                	ret

0000000080000afe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b08:	0000f497          	auipc	s1,0xf
    80000b0c:	e7048493          	addi	s1,s1,-400 # 8000f978 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	0000f517          	auipc	a0,0xf
    80000b20:	e5c50513          	addi	a0,a0,-420 # 8000f978 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	140000ef          	jal	80000c66 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2a:	6605                	lui	a2,0x1
    80000b2c:	4595                	li	a1,5
    80000b2e:	8526                	mv	a0,s1
    80000b30:	172000ef          	jal	80000ca2 <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	0000f517          	auipc	a0,0xf
    80000b44:	e3850513          	addi	a0,a0,-456 # 8000f978 <kmem>
    80000b48:	11e000ef          	jal	80000c66 <release>
  if(r)
    80000b4c:	b7e5                	j	80000b34 <kalloc+0x36>

0000000080000b4e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b4e:	1141                	addi	sp,sp,-16
    80000b50:	e422                	sd	s0,8(sp)
    80000b52:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b54:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b56:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5a:	00053823          	sd	zero,16(a0)
}
    80000b5e:	6422                	ld	s0,8(sp)
    80000b60:	0141                	addi	sp,sp,16
    80000b62:	8082                	ret

0000000080000b64 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b64:	411c                	lw	a5,0(a0)
    80000b66:	e399                	bnez	a5,80000b6c <holding+0x8>
    80000b68:	4501                	li	a0,0
  return r;
}
    80000b6a:	8082                	ret
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b76:	6904                	ld	s1,16(a0)
    80000b78:	53b000ef          	jal	800018b2 <mycpu>
    80000b7c:	40a48533          	sub	a0,s1,a0
    80000b80:	00153513          	seqz	a0,a0
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret

0000000080000b8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	ec06                	sd	ra,24(sp)
    80000b92:	e822                	sd	s0,16(sp)
    80000b94:	e426                	sd	s1,8(sp)
    80000b96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b98:	100024f3          	csrr	s1,sstatus
    80000b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba2:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba6:	50d000ef          	jal	800018b2 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	505000ef          	jal	800018b2 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	4f1000ef          	jal	800018b2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	b7cd                	j	80000bae <push_off+0x20>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	fb5ff0ef          	jal	80000b8e <push_off>
  if(holding(lk))
    80000bde:	8526                	mv	a0,s1
    80000be0:	f85ff0ef          	jal	80000b64 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk))
    80000be6:	e105                	bnez	a0,80000c06 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x1a>
  __sync_synchronize();
    80000bf2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf6:	4bd000ef          	jal	800018b2 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00006517          	auipc	a0,0x6
    80000c0a:	44250513          	addi	a0,a0,1090 # 80007048 <etext+0x48>
    80000c0e:	bd3ff0ef          	jal	800007e0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	499000ef          	jal	800018b2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c24:	e78d                	bnez	a5,80000c4e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05963          	blez	a5,80000c5a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c34:	eb09                	bnez	a4,80000c46 <pop_off+0x34>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c799                	beqz	a5,80000c46 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c42:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c46:	60a2                	ld	ra,8(sp)
    80000c48:	6402                	ld	s0,0(sp)
    80000c4a:	0141                	addi	sp,sp,16
    80000c4c:	8082                	ret
    panic("pop_off - interruptible");
    80000c4e:	00006517          	auipc	a0,0x6
    80000c52:	40250513          	addi	a0,a0,1026 # 80007050 <etext+0x50>
    80000c56:	b8bff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000c5a:	00006517          	auipc	a0,0x6
    80000c5e:	40e50513          	addi	a0,a0,1038 # 80007068 <etext+0x68>
    80000c62:	b7fff0ef          	jal	800007e0 <panic>

0000000080000c66 <release>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c72:	ef3ff0ef          	jal	80000b64 <holding>
    80000c76:	c105                	beqz	a0,80000c96 <release+0x30>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c80:	0f50000f          	fence	iorw,ow
    80000c84:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c88:	f8bff0ef          	jal	80000c12 <pop_off>
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("release");
    80000c96:	00006517          	auipc	a0,0x6
    80000c9a:	3da50513          	addi	a0,a0,986 # 80007070 <etext+0x70>
    80000c9e:	b43ff0ef          	jal	800007e0 <panic>

0000000080000ca2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca8:	ca19                	beqz	a2,80000cbe <memset+0x1c>
    80000caa:	87aa                	mv	a5,a0
    80000cac:	1602                	slli	a2,a2,0x20
    80000cae:	9201                	srli	a2,a2,0x20
    80000cb0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb8:	0785                	addi	a5,a5,1
    80000cba:	fee79de3          	bne	a5,a4,80000cb4 <memset+0x12>
  }
  return dst;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca05                	beqz	a2,80000cfa <memcmp+0x36>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x14>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x30>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
  return 0;
    80000cfa:	4501                	li	a0,0
    80000cfc:	bfe5                	j	80000cf4 <memcmp+0x30>

0000000080000cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e422                	sd	s0,8(sp)
    80000d02:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d04:	c205                	beqz	a2,80000d24 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d06:	02a5e263          	bltu	a1,a0,80000d2a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0a:	1602                	slli	a2,a2,0x20
    80000d0c:	9201                	srli	a2,a2,0x20
    80000d0e:	00c587b3          	add	a5,a1,a2
{
    80000d12:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d14:	0585                	addi	a1,a1,1
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde269>
    80000d18:	fff5c683          	lbu	a3,-1(a1)
    80000d1c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d20:	feb79ae3          	bne	a5,a1,80000d14 <memmove+0x16>

  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  if(s < d && s + n > d){
    80000d2a:	02061693          	slli	a3,a2,0x20
    80000d2e:	9281                	srli	a3,a3,0x20
    80000d30:	00d58733          	add	a4,a1,a3
    80000d34:	fce57be3          	bgeu	a0,a4,80000d0a <memmove+0xc>
    d += n;
    80000d38:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d3a:	fff6079b          	addiw	a5,a2,-1
    80000d3e:	1782                	slli	a5,a5,0x20
    80000d40:	9381                	srli	a5,a5,0x20
    80000d42:	fff7c793          	not	a5,a5
    80000d46:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d48:	177d                	addi	a4,a4,-1
    80000d4a:	16fd                	addi	a3,a3,-1
    80000d4c:	00074603          	lbu	a2,0(a4)
    80000d50:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d54:	fef71ae3          	bne	a4,a5,80000d48 <memmove+0x4a>
    80000d58:	b7f1                	j	80000d24 <memmove+0x26>

0000000080000d5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d62:	f9dff0ef          	jal	80000cfe <memmove>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d74:	ce11                	beqz	a2,80000d90 <strncmp+0x22>
    80000d76:	00054783          	lbu	a5,0(a0)
    80000d7a:	cf89                	beqz	a5,80000d94 <strncmp+0x26>
    80000d7c:	0005c703          	lbu	a4,0(a1)
    80000d80:	00f71a63          	bne	a4,a5,80000d94 <strncmp+0x26>
    n--, p++, q++;
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d8a:	f675                	bnez	a2,80000d76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	a801                	j	80000d9e <strncmp+0x30>
    80000d90:	4501                	li	a0,0
    80000d92:	a031                	j	80000d9e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d94:	00054503          	lbu	a0,0(a0)
    80000d98:	0005c783          	lbu	a5,0(a1)
    80000d9c:	9d1d                	subw	a0,a0,a5
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000daa:	87aa                	mv	a5,a0
    80000dac:	86b2                	mv	a3,a2
    80000dae:	367d                	addiw	a2,a2,-1
    80000db0:	02d05563          	blez	a3,80000dda <strncpy+0x36>
    80000db4:	0785                	addi	a5,a5,1
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	fee78fa3          	sb	a4,-1(a5)
    80000dbe:	0585                	addi	a1,a1,1
    80000dc0:	f775                	bnez	a4,80000dac <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dc2:	873e                	mv	a4,a5
    80000dc4:	9fb5                	addw	a5,a5,a3
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00c05963          	blez	a2,80000dda <strncpy+0x36>
    *s++ = 0;
    80000dcc:	0705                	addi	a4,a4,1
    80000dce:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dd2:	40e786bb          	subw	a3,a5,a4
    80000dd6:	fed04be3          	bgtz	a3,80000dcc <strncpy+0x28>
  return os;
}
    80000dda:	6422                	ld	s0,8(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000de6:	02c05363          	blez	a2,80000e0c <safestrcpy+0x2c>
    80000dea:	fff6069b          	addiw	a3,a2,-1
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000df6:	00d58963          	beq	a1,a3,80000e08 <safestrcpy+0x28>
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	0785                	addi	a5,a5,1
    80000dfe:	fff5c703          	lbu	a4,-1(a1)
    80000e02:	fee78fa3          	sb	a4,-1(a5)
    80000e06:	fb65                	bnez	a4,80000df6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e08:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strlen>:

int
strlen(const char *s)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf91                	beqz	a5,80000e38 <strlen+0x26>
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86be                	mv	a3,a5
    80000e24:	0785                	addi	a5,a5,1
    80000e26:	fff7c703          	lbu	a4,-1(a5)
    80000e2a:	ff65                	bnez	a4,80000e22 <strlen+0x10>
    80000e2c:	40a6853b          	subw	a0,a3,a0
    80000e30:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e38:	4501                	li	a0,0
    80000e3a:	bfe5                	j	80000e32 <strlen+0x20>

0000000080000e3c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e44:	25f000ef          	jal	800018a2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	00007717          	auipc	a4,0x7
    80000e4c:	a3870713          	addi	a4,a4,-1480 # 80007880 <started>
  if(cpuid() == 0){
    80000e50:	c51d                	beqz	a0,80000e7e <main+0x42>
    while(started == 0)
    80000e52:	431c                	lw	a5,0(a4)
    80000e54:	2781                	sext.w	a5,a5
    80000e56:	dff5                	beqz	a5,80000e52 <main+0x16>
      ;
    __sync_synchronize();
    80000e58:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e5c:	247000ef          	jal	800018a2 <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	23650513          	addi	a0,a0,566 # 80007098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	080000ef          	jal	80000eee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	590010ef          	jal	80002402 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	582040ef          	jal	800053f8 <plicinithart>
  }

  scheduler();        
    80000e7a:	6cf000ef          	jal	80001d48 <scheduler>
    consoleinit();
    80000e7e:	da6ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000e82:	99bff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000e86:	00006517          	auipc	a0,0x6
    80000e8a:	1f250513          	addi	a0,a0,498 # 80007078 <etext+0x78>
    80000e8e:	e6cff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000e92:	00006517          	auipc	a0,0x6
    80000e96:	1ee50513          	addi	a0,a0,494 # 80007080 <etext+0x80>
    80000e9a:	e60ff0ef          	jal	800004fa <printf>
    printf("\n");
    80000e9e:	00006517          	auipc	a0,0x6
    80000ea2:	1da50513          	addi	a0,a0,474 # 80007078 <etext+0x78>
    80000ea6:	e54ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000eaa:	c21ff0ef          	jal	80000aca <kinit>
    kvminit();       // create kernel page table
    80000eae:	2ca000ef          	jal	80001178 <kvminit>
    kvminithart();   // turn on paging
    80000eb2:	03c000ef          	jal	80000eee <kvminithart>
    procinit();      // process table
    80000eb6:	137000ef          	jal	800017ec <procinit>
    trapinit();      // trap vectors
    80000eba:	524010ef          	jal	800023de <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	544010ef          	jal	80002402 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	51c040ef          	jal	800053de <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	532040ef          	jal	800053f8 <plicinithart>
    binit();         // buffer cache
    80000eca:	3f3010ef          	jal	80002abc <binit>
    iinit();         // inode table
    80000ece:	178020ef          	jal	80003046 <iinit>
    fileinit();      // file table
    80000ed2:	06a030ef          	jal	80003f3c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	612040ef          	jal	800054e8 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	4c3000ef          	jal	80001b9c <userinit>
    __sync_synchronize();
    80000ede:	0ff0000f          	fence
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	00007717          	auipc	a4,0x7
    80000ee8:	98f72e23          	sw	a5,-1636(a4) # 80007880 <started>
    80000eec:	b779                	j	80000e7a <main+0x3e>

0000000080000eee <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000eee:	1141                	addi	sp,sp,-16
    80000ef0:	e422                	sd	s0,8(sp)
    80000ef2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ef4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ef8:	00007797          	auipc	a5,0x7
    80000efc:	9907b783          	ld	a5,-1648(a5) # 80007888 <kernel_pagetable>
    80000f00:	83b1                	srli	a5,a5,0xc
    80000f02:	577d                	li	a4,-1
    80000f04:	177e                	slli	a4,a4,0x3f
    80000f06:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f08:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f0c:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f16:	7139                	addi	sp,sp,-64
    80000f18:	fc06                	sd	ra,56(sp)
    80000f1a:	f822                	sd	s0,48(sp)
    80000f1c:	f426                	sd	s1,40(sp)
    80000f1e:	f04a                	sd	s2,32(sp)
    80000f20:	ec4e                	sd	s3,24(sp)
    80000f22:	e852                	sd	s4,16(sp)
    80000f24:	e456                	sd	s5,8(sp)
    80000f26:	e05a                	sd	s6,0(sp)
    80000f28:	0080                	addi	s0,sp,64
    80000f2a:	84aa                	mv	s1,a0
    80000f2c:	89ae                	mv	s3,a1
    80000f2e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f30:	57fd                	li	a5,-1
    80000f32:	83e9                	srli	a5,a5,0x1a
    80000f34:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f36:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f38:	02b7fc63          	bgeu	a5,a1,80000f70 <walk+0x5a>
    panic("walk");
    80000f3c:	00006517          	auipc	a0,0x6
    80000f40:	17450513          	addi	a0,a0,372 # 800070b0 <etext+0xb0>
    80000f44:	89dff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f48:	060a8263          	beqz	s5,80000fac <walk+0x96>
    80000f4c:	bb3ff0ef          	jal	80000afe <kalloc>
    80000f50:	84aa                	mv	s1,a0
    80000f52:	c139                	beqz	a0,80000f98 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f54:	6605                	lui	a2,0x1
    80000f56:	4581                	li	a1,0
    80000f58:	d4bff0ef          	jal	80000ca2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f5c:	00c4d793          	srli	a5,s1,0xc
    80000f60:	07aa                	slli	a5,a5,0xa
    80000f62:	0017e793          	ori	a5,a5,1
    80000f66:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde25f>
    80000f6c:	036a0063          	beq	s4,s6,80000f8c <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f70:	0149d933          	srl	s2,s3,s4
    80000f74:	1ff97913          	andi	s2,s2,511
    80000f78:	090e                	slli	s2,s2,0x3
    80000f7a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f7c:	00093483          	ld	s1,0(s2)
    80000f80:	0014f793          	andi	a5,s1,1
    80000f84:	d3f1                	beqz	a5,80000f48 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f86:	80a9                	srli	s1,s1,0xa
    80000f88:	04b2                	slli	s1,s1,0xc
    80000f8a:	b7c5                	j	80000f6a <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f8c:	00c9d513          	srli	a0,s3,0xc
    80000f90:	1ff57513          	andi	a0,a0,511
    80000f94:	050e                	slli	a0,a0,0x3
    80000f96:	9526                	add	a0,a0,s1
}
    80000f98:	70e2                	ld	ra,56(sp)
    80000f9a:	7442                	ld	s0,48(sp)
    80000f9c:	74a2                	ld	s1,40(sp)
    80000f9e:	7902                	ld	s2,32(sp)
    80000fa0:	69e2                	ld	s3,24(sp)
    80000fa2:	6a42                	ld	s4,16(sp)
    80000fa4:	6aa2                	ld	s5,8(sp)
    80000fa6:	6b02                	ld	s6,0(sp)
    80000fa8:	6121                	addi	sp,sp,64
    80000faa:	8082                	ret
        return 0;
    80000fac:	4501                	li	a0,0
    80000fae:	b7ed                	j	80000f98 <walk+0x82>

0000000080000fb0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fb0:	57fd                	li	a5,-1
    80000fb2:	83e9                	srli	a5,a5,0x1a
    80000fb4:	00b7f463          	bgeu	a5,a1,80000fbc <walkaddr+0xc>
    return 0;
    80000fb8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fba:	8082                	ret
{
    80000fbc:	1141                	addi	sp,sp,-16
    80000fbe:	e406                	sd	ra,8(sp)
    80000fc0:	e022                	sd	s0,0(sp)
    80000fc2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fc4:	4601                	li	a2,0
    80000fc6:	f51ff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    80000fca:	c105                	beqz	a0,80000fea <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fcc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fce:	0117f693          	andi	a3,a5,17
    80000fd2:	4745                	li	a4,17
    return 0;
    80000fd4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fd6:	00e68663          	beq	a3,a4,80000fe2 <walkaddr+0x32>
}
    80000fda:	60a2                	ld	ra,8(sp)
    80000fdc:	6402                	ld	s0,0(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret
  pa = PTE2PA(*pte);
    80000fe2:	83a9                	srli	a5,a5,0xa
    80000fe4:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fe8:	bfcd                	j	80000fda <walkaddr+0x2a>
    return 0;
    80000fea:	4501                	li	a0,0
    80000fec:	b7fd                	j	80000fda <walkaddr+0x2a>

0000000080000fee <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fee:	715d                	addi	sp,sp,-80
    80000ff0:	e486                	sd	ra,72(sp)
    80000ff2:	e0a2                	sd	s0,64(sp)
    80000ff4:	fc26                	sd	s1,56(sp)
    80000ff6:	f84a                	sd	s2,48(sp)
    80000ff8:	f44e                	sd	s3,40(sp)
    80000ffa:	f052                	sd	s4,32(sp)
    80000ffc:	ec56                	sd	s5,24(sp)
    80000ffe:	e85a                	sd	s6,16(sp)
    80001000:	e45e                	sd	s7,8(sp)
    80001002:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001004:	03459793          	slli	a5,a1,0x34
    80001008:	e7a9                	bnez	a5,80001052 <mappages+0x64>
    8000100a:	8aaa                	mv	s5,a0
    8000100c:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000100e:	03461793          	slli	a5,a2,0x34
    80001012:	e7b1                	bnez	a5,8000105e <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001014:	ca39                	beqz	a2,8000106a <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001016:	77fd                	lui	a5,0xfffff
    80001018:	963e                	add	a2,a2,a5
    8000101a:	00b609b3          	add	s3,a2,a1
  a = va;
    8000101e:	892e                	mv	s2,a1
    80001020:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001024:	6b85                	lui	s7,0x1
    80001026:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000102a:	4605                	li	a2,1
    8000102c:	85ca                	mv	a1,s2
    8000102e:	8556                	mv	a0,s5
    80001030:	ee7ff0ef          	jal	80000f16 <walk>
    80001034:	c539                	beqz	a0,80001082 <mappages+0x94>
    if(*pte & PTE_V)
    80001036:	611c                	ld	a5,0(a0)
    80001038:	8b85                	andi	a5,a5,1
    8000103a:	ef95                	bnez	a5,80001076 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000103c:	80b1                	srli	s1,s1,0xc
    8000103e:	04aa                	slli	s1,s1,0xa
    80001040:	0164e4b3          	or	s1,s1,s6
    80001044:	0014e493          	ori	s1,s1,1
    80001048:	e104                	sd	s1,0(a0)
    if(a == last)
    8000104a:	05390863          	beq	s2,s3,8000109a <mappages+0xac>
    a += PGSIZE;
    8000104e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	bfd9                	j	80001026 <mappages+0x38>
    panic("mappages: va not aligned");
    80001052:	00006517          	auipc	a0,0x6
    80001056:	06650513          	addi	a0,a0,102 # 800070b8 <etext+0xb8>
    8000105a:	f86ff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    8000105e:	00006517          	auipc	a0,0x6
    80001062:	07a50513          	addi	a0,a0,122 # 800070d8 <etext+0xd8>
    80001066:	f7aff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    8000106a:	00006517          	auipc	a0,0x6
    8000106e:	08e50513          	addi	a0,a0,142 # 800070f8 <etext+0xf8>
    80001072:	f6eff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    80001076:	00006517          	auipc	a0,0x6
    8000107a:	09250513          	addi	a0,a0,146 # 80007108 <etext+0x108>
    8000107e:	f62ff0ef          	jal	800007e0 <panic>
      return -1;
    80001082:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001084:	60a6                	ld	ra,72(sp)
    80001086:	6406                	ld	s0,64(sp)
    80001088:	74e2                	ld	s1,56(sp)
    8000108a:	7942                	ld	s2,48(sp)
    8000108c:	79a2                	ld	s3,40(sp)
    8000108e:	7a02                	ld	s4,32(sp)
    80001090:	6ae2                	ld	s5,24(sp)
    80001092:	6b42                	ld	s6,16(sp)
    80001094:	6ba2                	ld	s7,8(sp)
    80001096:	6161                	addi	sp,sp,80
    80001098:	8082                	ret
  return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7e5                	j	80001084 <mappages+0x96>

000000008000109e <kvmmap>:
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e406                	sd	ra,8(sp)
    800010a2:	e022                	sd	s0,0(sp)
    800010a4:	0800                	addi	s0,sp,16
    800010a6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010a8:	86b2                	mv	a3,a2
    800010aa:	863e                	mv	a2,a5
    800010ac:	f43ff0ef          	jal	80000fee <mappages>
    800010b0:	e509                	bnez	a0,800010ba <kvmmap+0x1c>
}
    800010b2:	60a2                	ld	ra,8(sp)
    800010b4:	6402                	ld	s0,0(sp)
    800010b6:	0141                	addi	sp,sp,16
    800010b8:	8082                	ret
    panic("kvmmap");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	05e50513          	addi	a0,a0,94 # 80007118 <etext+0x118>
    800010c2:	f1eff0ef          	jal	800007e0 <panic>

00000000800010c6 <kvmmake>:
{
    800010c6:	1101                	addi	sp,sp,-32
    800010c8:	ec06                	sd	ra,24(sp)
    800010ca:	e822                	sd	s0,16(sp)
    800010cc:	e426                	sd	s1,8(sp)
    800010ce:	e04a                	sd	s2,0(sp)
    800010d0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010d2:	a2dff0ef          	jal	80000afe <kalloc>
    800010d6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010d8:	6605                	lui	a2,0x1
    800010da:	4581                	li	a1,0
    800010dc:	bc7ff0ef          	jal	80000ca2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010e0:	4719                	li	a4,6
    800010e2:	6685                	lui	a3,0x1
    800010e4:	10000637          	lui	a2,0x10000
    800010e8:	100005b7          	lui	a1,0x10000
    800010ec:	8526                	mv	a0,s1
    800010ee:	fb1ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010f2:	4719                	li	a4,6
    800010f4:	6685                	lui	a3,0x1
    800010f6:	10001637          	lui	a2,0x10001
    800010fa:	100015b7          	lui	a1,0x10001
    800010fe:	8526                	mv	a0,s1
    80001100:	f9fff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001104:	4719                	li	a4,6
    80001106:	040006b7          	lui	a3,0x4000
    8000110a:	0c000637          	lui	a2,0xc000
    8000110e:	0c0005b7          	lui	a1,0xc000
    80001112:	8526                	mv	a0,s1
    80001114:	f8bff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001118:	00006917          	auipc	s2,0x6
    8000111c:	ee890913          	addi	s2,s2,-280 # 80007000 <etext>
    80001120:	4729                	li	a4,10
    80001122:	80006697          	auipc	a3,0x80006
    80001126:	ede68693          	addi	a3,a3,-290 # 7000 <_entry-0x7fff9000>
    8000112a:	4605                	li	a2,1
    8000112c:	067e                	slli	a2,a2,0x1f
    8000112e:	85b2                	mv	a1,a2
    80001130:	8526                	mv	a0,s1
    80001132:	f6dff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001136:	46c5                	li	a3,17
    80001138:	06ee                	slli	a3,a3,0x1b
    8000113a:	4719                	li	a4,6
    8000113c:	412686b3          	sub	a3,a3,s2
    80001140:	864a                	mv	a2,s2
    80001142:	85ca                	mv	a1,s2
    80001144:	8526                	mv	a0,s1
    80001146:	f59ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000114a:	4729                	li	a4,10
    8000114c:	6685                	lui	a3,0x1
    8000114e:	00005617          	auipc	a2,0x5
    80001152:	eb260613          	addi	a2,a2,-334 # 80006000 <_trampoline>
    80001156:	040005b7          	lui	a1,0x4000
    8000115a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000115c:	05b2                	slli	a1,a1,0xc
    8000115e:	8526                	mv	a0,s1
    80001160:	f3fff0ef          	jal	8000109e <kvmmap>
  proc_mapstacks(kpgtbl);
    80001164:	8526                	mv	a0,s1
    80001166:	5ee000ef          	jal	80001754 <proc_mapstacks>
}
    8000116a:	8526                	mv	a0,s1
    8000116c:	60e2                	ld	ra,24(sp)
    8000116e:	6442                	ld	s0,16(sp)
    80001170:	64a2                	ld	s1,8(sp)
    80001172:	6902                	ld	s2,0(sp)
    80001174:	6105                	addi	sp,sp,32
    80001176:	8082                	ret

0000000080001178 <kvminit>:
{
    80001178:	1141                	addi	sp,sp,-16
    8000117a:	e406                	sd	ra,8(sp)
    8000117c:	e022                	sd	s0,0(sp)
    8000117e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001180:	f47ff0ef          	jal	800010c6 <kvmmake>
    80001184:	00006797          	auipc	a5,0x6
    80001188:	70a7b223          	sd	a0,1796(a5) # 80007888 <kernel_pagetable>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret

0000000080001194 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001194:	1101                	addi	sp,sp,-32
    80001196:	ec06                	sd	ra,24(sp)
    80001198:	e822                	sd	s0,16(sp)
    8000119a:	e426                	sd	s1,8(sp)
    8000119c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000119e:	961ff0ef          	jal	80000afe <kalloc>
    800011a2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011a4:	c509                	beqz	a0,800011ae <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011a6:	6605                	lui	a2,0x1
    800011a8:	4581                	li	a1,0
    800011aa:	af9ff0ef          	jal	80000ca2 <memset>
  return pagetable;
}
    800011ae:	8526                	mv	a0,s1
    800011b0:	60e2                	ld	ra,24(sp)
    800011b2:	6442                	ld	s0,16(sp)
    800011b4:	64a2                	ld	s1,8(sp)
    800011b6:	6105                	addi	sp,sp,32
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	7139                	addi	sp,sp,-64
    800011bc:	fc06                	sd	ra,56(sp)
    800011be:	f822                	sd	s0,48(sp)
    800011c0:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e38d                	bnez	a5,800011e8 <uvmunmap+0x2e>
    800011c8:	f04a                	sd	s2,32(sp)
    800011ca:	ec4e                	sd	s3,24(sp)
    800011cc:	e852                	sd	s4,16(sp)
    800011ce:	e456                	sd	s5,8(sp)
    800011d0:	e05a                	sd	s6,0(sp)
    800011d2:	8a2a                	mv	s4,a0
    800011d4:	892e                	mv	s2,a1
    800011d6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011d8:	0632                	slli	a2,a2,0xc
    800011da:	00b609b3          	add	s3,a2,a1
    800011de:	6b05                	lui	s6,0x1
    800011e0:	0535f963          	bgeu	a1,s3,80001232 <uvmunmap+0x78>
    800011e4:	f426                	sd	s1,40(sp)
    800011e6:	a015                	j	8000120a <uvmunmap+0x50>
    800011e8:	f426                	sd	s1,40(sp)
    800011ea:	f04a                	sd	s2,32(sp)
    800011ec:	ec4e                	sd	s3,24(sp)
    800011ee:	e852                	sd	s4,16(sp)
    800011f0:	e456                	sd	s5,8(sp)
    800011f2:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011f4:	00006517          	auipc	a0,0x6
    800011f8:	f2c50513          	addi	a0,a0,-212 # 80007120 <etext+0x120>
    800011fc:	de4ff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001200:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001204:	995a                	add	s2,s2,s6
    80001206:	03397563          	bgeu	s2,s3,80001230 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000120a:	4601                	li	a2,0
    8000120c:	85ca                	mv	a1,s2
    8000120e:	8552                	mv	a0,s4
    80001210:	d07ff0ef          	jal	80000f16 <walk>
    80001214:	84aa                	mv	s1,a0
    80001216:	d57d                	beqz	a0,80001204 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001218:	611c                	ld	a5,0(a0)
    8000121a:	0017f713          	andi	a4,a5,1
    8000121e:	d37d                	beqz	a4,80001204 <uvmunmap+0x4a>
    if(do_free){
    80001220:	fe0a80e3          	beqz	s5,80001200 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001224:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001226:	00c79513          	slli	a0,a5,0xc
    8000122a:	ff2ff0ef          	jal	80000a1c <kfree>
    8000122e:	bfc9                	j	80001200 <uvmunmap+0x46>
    80001230:	74a2                	ld	s1,40(sp)
    80001232:	7902                	ld	s2,32(sp)
    80001234:	69e2                	ld	s3,24(sp)
    80001236:	6a42                	ld	s4,16(sp)
    80001238:	6aa2                	ld	s5,8(sp)
    8000123a:	6b02                	ld	s6,0(sp)
  }
}
    8000123c:	70e2                	ld	ra,56(sp)
    8000123e:	7442                	ld	s0,48(sp)
    80001240:	6121                	addi	sp,sp,64
    80001242:	8082                	ret

0000000080001244 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001244:	1101                	addi	sp,sp,-32
    80001246:	ec06                	sd	ra,24(sp)
    80001248:	e822                	sd	s0,16(sp)
    8000124a:	e426                	sd	s1,8(sp)
    8000124c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000124e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001250:	00b67d63          	bgeu	a2,a1,8000126a <uvmdealloc+0x26>
    80001254:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001256:	6785                	lui	a5,0x1
    80001258:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000125a:	00f60733          	add	a4,a2,a5
    8000125e:	76fd                	lui	a3,0xfffff
    80001260:	8f75                	and	a4,a4,a3
    80001262:	97ae                	add	a5,a5,a1
    80001264:	8ff5                	and	a5,a5,a3
    80001266:	00f76863          	bltu	a4,a5,80001276 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000126a:	8526                	mv	a0,s1
    8000126c:	60e2                	ld	ra,24(sp)
    8000126e:	6442                	ld	s0,16(sp)
    80001270:	64a2                	ld	s1,8(sp)
    80001272:	6105                	addi	sp,sp,32
    80001274:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001276:	8f99                	sub	a5,a5,a4
    80001278:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000127a:	4685                	li	a3,1
    8000127c:	0007861b          	sext.w	a2,a5
    80001280:	85ba                	mv	a1,a4
    80001282:	f39ff0ef          	jal	800011ba <uvmunmap>
    80001286:	b7d5                	j	8000126a <uvmdealloc+0x26>

0000000080001288 <uvmalloc>:
  if(newsz < oldsz)
    80001288:	08b66f63          	bltu	a2,a1,80001326 <uvmalloc+0x9e>
{
    8000128c:	7139                	addi	sp,sp,-64
    8000128e:	fc06                	sd	ra,56(sp)
    80001290:	f822                	sd	s0,48(sp)
    80001292:	ec4e                	sd	s3,24(sp)
    80001294:	e852                	sd	s4,16(sp)
    80001296:	e456                	sd	s5,8(sp)
    80001298:	0080                	addi	s0,sp,64
    8000129a:	8aaa                	mv	s5,a0
    8000129c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000129e:	6785                	lui	a5,0x1
    800012a0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012a2:	95be                	add	a1,a1,a5
    800012a4:	77fd                	lui	a5,0xfffff
    800012a6:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012aa:	08c9f063          	bgeu	s3,a2,8000132a <uvmalloc+0xa2>
    800012ae:	f426                	sd	s1,40(sp)
    800012b0:	f04a                	sd	s2,32(sp)
    800012b2:	e05a                	sd	s6,0(sp)
    800012b4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012b6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012ba:	845ff0ef          	jal	80000afe <kalloc>
    800012be:	84aa                	mv	s1,a0
    if(mem == 0){
    800012c0:	c515                	beqz	a0,800012ec <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012c2:	6605                	lui	a2,0x1
    800012c4:	4581                	li	a1,0
    800012c6:	9ddff0ef          	jal	80000ca2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012ca:	875a                	mv	a4,s6
    800012cc:	86a6                	mv	a3,s1
    800012ce:	6605                	lui	a2,0x1
    800012d0:	85ca                	mv	a1,s2
    800012d2:	8556                	mv	a0,s5
    800012d4:	d1bff0ef          	jal	80000fee <mappages>
    800012d8:	e915                	bnez	a0,8000130c <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012da:	6785                	lui	a5,0x1
    800012dc:	993e                	add	s2,s2,a5
    800012de:	fd496ee3          	bltu	s2,s4,800012ba <uvmalloc+0x32>
  return newsz;
    800012e2:	8552                	mv	a0,s4
    800012e4:	74a2                	ld	s1,40(sp)
    800012e6:	7902                	ld	s2,32(sp)
    800012e8:	6b02                	ld	s6,0(sp)
    800012ea:	a811                	j	800012fe <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012ec:	864e                	mv	a2,s3
    800012ee:	85ca                	mv	a1,s2
    800012f0:	8556                	mv	a0,s5
    800012f2:	f53ff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    800012f6:	4501                	li	a0,0
    800012f8:	74a2                	ld	s1,40(sp)
    800012fa:	7902                	ld	s2,32(sp)
    800012fc:	6b02                	ld	s6,0(sp)
}
    800012fe:	70e2                	ld	ra,56(sp)
    80001300:	7442                	ld	s0,48(sp)
    80001302:	69e2                	ld	s3,24(sp)
    80001304:	6a42                	ld	s4,16(sp)
    80001306:	6aa2                	ld	s5,8(sp)
    80001308:	6121                	addi	sp,sp,64
    8000130a:	8082                	ret
      kfree(mem);
    8000130c:	8526                	mv	a0,s1
    8000130e:	f0eff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001312:	864e                	mv	a2,s3
    80001314:	85ca                	mv	a1,s2
    80001316:	8556                	mv	a0,s5
    80001318:	f2dff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    8000131c:	4501                	li	a0,0
    8000131e:	74a2                	ld	s1,40(sp)
    80001320:	7902                	ld	s2,32(sp)
    80001322:	6b02                	ld	s6,0(sp)
    80001324:	bfe9                	j	800012fe <uvmalloc+0x76>
    return oldsz;
    80001326:	852e                	mv	a0,a1
}
    80001328:	8082                	ret
  return newsz;
    8000132a:	8532                	mv	a0,a2
    8000132c:	bfc9                	j	800012fe <uvmalloc+0x76>

000000008000132e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000132e:	7179                	addi	sp,sp,-48
    80001330:	f406                	sd	ra,40(sp)
    80001332:	f022                	sd	s0,32(sp)
    80001334:	ec26                	sd	s1,24(sp)
    80001336:	e84a                	sd	s2,16(sp)
    80001338:	e44e                	sd	s3,8(sp)
    8000133a:	e052                	sd	s4,0(sp)
    8000133c:	1800                	addi	s0,sp,48
    8000133e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001340:	84aa                	mv	s1,a0
    80001342:	6905                	lui	s2,0x1
    80001344:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001346:	4985                	li	s3,1
    80001348:	a819                	j	8000135e <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000134a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000134c:	00c79513          	slli	a0,a5,0xc
    80001350:	fdfff0ef          	jal	8000132e <freewalk>
      pagetable[i] = 0;
    80001354:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001358:	04a1                	addi	s1,s1,8
    8000135a:	01248f63          	beq	s1,s2,80001378 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000135e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001360:	00f7f713          	andi	a4,a5,15
    80001364:	ff3703e3          	beq	a4,s3,8000134a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001368:	8b85                	andi	a5,a5,1
    8000136a:	d7fd                	beqz	a5,80001358 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000136c:	00006517          	auipc	a0,0x6
    80001370:	dcc50513          	addi	a0,a0,-564 # 80007138 <etext+0x138>
    80001374:	c6cff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    80001378:	8552                	mv	a0,s4
    8000137a:	ea2ff0ef          	jal	80000a1c <kfree>
}
    8000137e:	70a2                	ld	ra,40(sp)
    80001380:	7402                	ld	s0,32(sp)
    80001382:	64e2                	ld	s1,24(sp)
    80001384:	6942                	ld	s2,16(sp)
    80001386:	69a2                	ld	s3,8(sp)
    80001388:	6a02                	ld	s4,0(sp)
    8000138a:	6145                	addi	sp,sp,48
    8000138c:	8082                	ret

000000008000138e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000138e:	1101                	addi	sp,sp,-32
    80001390:	ec06                	sd	ra,24(sp)
    80001392:	e822                	sd	s0,16(sp)
    80001394:	e426                	sd	s1,8(sp)
    80001396:	1000                	addi	s0,sp,32
    80001398:	84aa                	mv	s1,a0
  if(sz > 0)
    8000139a:	e989                	bnez	a1,800013ac <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000139c:	8526                	mv	a0,s1
    8000139e:	f91ff0ef          	jal	8000132e <freewalk>
}
    800013a2:	60e2                	ld	ra,24(sp)
    800013a4:	6442                	ld	s0,16(sp)
    800013a6:	64a2                	ld	s1,8(sp)
    800013a8:	6105                	addi	sp,sp,32
    800013aa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013ac:	6785                	lui	a5,0x1
    800013ae:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013b0:	95be                	add	a1,a1,a5
    800013b2:	4685                	li	a3,1
    800013b4:	00c5d613          	srli	a2,a1,0xc
    800013b8:	4581                	li	a1,0
    800013ba:	e01ff0ef          	jal	800011ba <uvmunmap>
    800013be:	bff9                	j	8000139c <uvmfree+0xe>

00000000800013c0 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013c0:	ce49                	beqz	a2,8000145a <uvmcopy+0x9a>
{
    800013c2:	715d                	addi	sp,sp,-80
    800013c4:	e486                	sd	ra,72(sp)
    800013c6:	e0a2                	sd	s0,64(sp)
    800013c8:	fc26                	sd	s1,56(sp)
    800013ca:	f84a                	sd	s2,48(sp)
    800013cc:	f44e                	sd	s3,40(sp)
    800013ce:	f052                	sd	s4,32(sp)
    800013d0:	ec56                	sd	s5,24(sp)
    800013d2:	e85a                	sd	s6,16(sp)
    800013d4:	e45e                	sd	s7,8(sp)
    800013d6:	0880                	addi	s0,sp,80
    800013d8:	8aaa                	mv	s5,a0
    800013da:	8b2e                	mv	s6,a1
    800013dc:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800013de:	4481                	li	s1,0
    800013e0:	a029                	j	800013ea <uvmcopy+0x2a>
    800013e2:	6785                	lui	a5,0x1
    800013e4:	94be                	add	s1,s1,a5
    800013e6:	0544fe63          	bgeu	s1,s4,80001442 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800013ea:	4601                	li	a2,0
    800013ec:	85a6                	mv	a1,s1
    800013ee:	8556                	mv	a0,s5
    800013f0:	b27ff0ef          	jal	80000f16 <walk>
    800013f4:	d57d                	beqz	a0,800013e2 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800013f6:	6118                	ld	a4,0(a0)
    800013f8:	00177793          	andi	a5,a4,1
    800013fc:	d3fd                	beqz	a5,800013e2 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013fe:	00a75593          	srli	a1,a4,0xa
    80001402:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001406:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    8000140a:	ef4ff0ef          	jal	80000afe <kalloc>
    8000140e:	89aa                	mv	s3,a0
    80001410:	c105                	beqz	a0,80001430 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001412:	6605                	lui	a2,0x1
    80001414:	85de                	mv	a1,s7
    80001416:	8e9ff0ef          	jal	80000cfe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000141a:	874a                	mv	a4,s2
    8000141c:	86ce                	mv	a3,s3
    8000141e:	6605                	lui	a2,0x1
    80001420:	85a6                	mv	a1,s1
    80001422:	855a                	mv	a0,s6
    80001424:	bcbff0ef          	jal	80000fee <mappages>
    80001428:	dd4d                	beqz	a0,800013e2 <uvmcopy+0x22>
      kfree(mem);
    8000142a:	854e                	mv	a0,s3
    8000142c:	df0ff0ef          	jal	80000a1c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001430:	4685                	li	a3,1
    80001432:	00c4d613          	srli	a2,s1,0xc
    80001436:	4581                	li	a1,0
    80001438:	855a                	mv	a0,s6
    8000143a:	d81ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000143e:	557d                	li	a0,-1
    80001440:	a011                	j	80001444 <uvmcopy+0x84>
  return 0;
    80001442:	4501                	li	a0,0
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
  return 0;
    8000145a:	4501                	li	a0,0
}
    8000145c:	8082                	ret

000000008000145e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000145e:	1141                	addi	sp,sp,-16
    80001460:	e406                	sd	ra,8(sp)
    80001462:	e022                	sd	s0,0(sp)
    80001464:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001466:	4601                	li	a2,0
    80001468:	aafff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    8000146c:	c901                	beqz	a0,8000147c <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000146e:	611c                	ld	a5,0(a0)
    80001470:	9bbd                	andi	a5,a5,-17
    80001472:	e11c                	sd	a5,0(a0)
}
    80001474:	60a2                	ld	ra,8(sp)
    80001476:	6402                	ld	s0,0(sp)
    80001478:	0141                	addi	sp,sp,16
    8000147a:	8082                	ret
    panic("uvmclear");
    8000147c:	00006517          	auipc	a0,0x6
    80001480:	ccc50513          	addi	a0,a0,-820 # 80007148 <etext+0x148>
    80001484:	b5cff0ef          	jal	800007e0 <panic>

0000000080001488 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001488:	c6dd                	beqz	a3,80001536 <copyinstr+0xae>
{
    8000148a:	715d                	addi	sp,sp,-80
    8000148c:	e486                	sd	ra,72(sp)
    8000148e:	e0a2                	sd	s0,64(sp)
    80001490:	fc26                	sd	s1,56(sp)
    80001492:	f84a                	sd	s2,48(sp)
    80001494:	f44e                	sd	s3,40(sp)
    80001496:	f052                	sd	s4,32(sp)
    80001498:	ec56                	sd	s5,24(sp)
    8000149a:	e85a                	sd	s6,16(sp)
    8000149c:	e45e                	sd	s7,8(sp)
    8000149e:	0880                	addi	s0,sp,80
    800014a0:	8a2a                	mv	s4,a0
    800014a2:	8b2e                	mv	s6,a1
    800014a4:	8bb2                	mv	s7,a2
    800014a6:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800014a8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014aa:	6985                	lui	s3,0x1
    800014ac:	a825                	j	800014e4 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014ae:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014b2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014b4:	37fd                	addiw	a5,a5,-1
    800014b6:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014ba:	60a6                	ld	ra,72(sp)
    800014bc:	6406                	ld	s0,64(sp)
    800014be:	74e2                	ld	s1,56(sp)
    800014c0:	7942                	ld	s2,48(sp)
    800014c2:	79a2                	ld	s3,40(sp)
    800014c4:	7a02                	ld	s4,32(sp)
    800014c6:	6ae2                	ld	s5,24(sp)
    800014c8:	6b42                	ld	s6,16(sp)
    800014ca:	6ba2                	ld	s7,8(sp)
    800014cc:	6161                	addi	sp,sp,80
    800014ce:	8082                	ret
    800014d0:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800014d4:	9742                	add	a4,a4,a6
      --max;
    800014d6:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800014da:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800014de:	04e58463          	beq	a1,a4,80001526 <copyinstr+0x9e>
{
    800014e2:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800014e4:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800014e8:	85a6                	mv	a1,s1
    800014ea:	8552                	mv	a0,s4
    800014ec:	ac5ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0)
    800014f0:	cd0d                	beqz	a0,8000152a <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800014f2:	417486b3          	sub	a3,s1,s7
    800014f6:	96ce                	add	a3,a3,s3
    if(n > max)
    800014f8:	00d97363          	bgeu	s2,a3,800014fe <copyinstr+0x76>
    800014fc:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800014fe:	955e                	add	a0,a0,s7
    80001500:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001502:	c695                	beqz	a3,8000152e <copyinstr+0xa6>
    80001504:	87da                	mv	a5,s6
    80001506:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001508:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000150c:	96da                	add	a3,a3,s6
    8000150e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001510:	00f60733          	add	a4,a2,a5
    80001514:	00074703          	lbu	a4,0(a4)
    80001518:	db59                	beqz	a4,800014ae <copyinstr+0x26>
        *dst = *p;
    8000151a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000151e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001520:	fed797e3          	bne	a5,a3,8000150e <copyinstr+0x86>
    80001524:	b775                	j	800014d0 <copyinstr+0x48>
    80001526:	4781                	li	a5,0
    80001528:	b771                	j	800014b4 <copyinstr+0x2c>
      return -1;
    8000152a:	557d                	li	a0,-1
    8000152c:	b779                	j	800014ba <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000152e:	6b85                	lui	s7,0x1
    80001530:	9ba6                	add	s7,s7,s1
    80001532:	87da                	mv	a5,s6
    80001534:	b77d                	j	800014e2 <copyinstr+0x5a>
  int got_null = 0;
    80001536:	4781                	li	a5,0
  if(got_null){
    80001538:	37fd                	addiw	a5,a5,-1
    8000153a:	0007851b          	sext.w	a0,a5
}
    8000153e:	8082                	ret

0000000080001540 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001540:	1141                	addi	sp,sp,-16
    80001542:	e406                	sd	ra,8(sp)
    80001544:	e022                	sd	s0,0(sp)
    80001546:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001548:	4601                	li	a2,0
    8000154a:	9cdff0ef          	jal	80000f16 <walk>
  if (pte == 0) {
    8000154e:	c519                	beqz	a0,8000155c <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001550:	6108                	ld	a0,0(a0)
    80001552:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001554:	60a2                	ld	ra,8(sp)
    80001556:	6402                	ld	s0,0(sp)
    80001558:	0141                	addi	sp,sp,16
    8000155a:	8082                	ret
    return 0;
    8000155c:	4501                	li	a0,0
    8000155e:	bfdd                	j	80001554 <ismapped+0x14>

0000000080001560 <vmfault>:
{
    80001560:	7179                	addi	sp,sp,-48
    80001562:	f406                	sd	ra,40(sp)
    80001564:	f022                	sd	s0,32(sp)
    80001566:	ec26                	sd	s1,24(sp)
    80001568:	e44e                	sd	s3,8(sp)
    8000156a:	1800                	addi	s0,sp,48
    8000156c:	89aa                	mv	s3,a0
    8000156e:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001570:	35e000ef          	jal	800018ce <myproc>
  if (va >= p->sz)
    80001574:	653c                	ld	a5,72(a0)
    80001576:	00f4ea63          	bltu	s1,a5,8000158a <vmfault+0x2a>
    return 0;
    8000157a:	4981                	li	s3,0
}
    8000157c:	854e                	mv	a0,s3
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	69a2                	ld	s3,8(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret
    8000158a:	e84a                	sd	s2,16(sp)
    8000158c:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000158e:	77fd                	lui	a5,0xfffff
    80001590:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001592:	85a6                	mv	a1,s1
    80001594:	854e                	mv	a0,s3
    80001596:	fabff0ef          	jal	80001540 <ismapped>
    return 0;
    8000159a:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000159c:	c119                	beqz	a0,800015a2 <vmfault+0x42>
    8000159e:	6942                	ld	s2,16(sp)
    800015a0:	bff1                	j	8000157c <vmfault+0x1c>
    800015a2:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015a4:	d5aff0ef          	jal	80000afe <kalloc>
    800015a8:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015aa:	c90d                	beqz	a0,800015dc <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015ac:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	4581                	li	a1,0
    800015b2:	ef0ff0ef          	jal	80000ca2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015b6:	4759                	li	a4,22
    800015b8:	86d2                	mv	a3,s4
    800015ba:	6605                	lui	a2,0x1
    800015bc:	85a6                	mv	a1,s1
    800015be:	05093503          	ld	a0,80(s2)
    800015c2:	a2dff0ef          	jal	80000fee <mappages>
    800015c6:	e501                	bnez	a0,800015ce <vmfault+0x6e>
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	6a02                	ld	s4,0(sp)
    800015cc:	bf45                	j	8000157c <vmfault+0x1c>
    kfree((void *)mem);
    800015ce:	8552                	mv	a0,s4
    800015d0:	c4cff0ef          	jal	80000a1c <kfree>
    return 0;
    800015d4:	4981                	li	s3,0
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	6a02                	ld	s4,0(sp)
    800015da:	b74d                	j	8000157c <vmfault+0x1c>
    800015dc:	6942                	ld	s2,16(sp)
    800015de:	6a02                	ld	s4,0(sp)
    800015e0:	bf71                	j	8000157c <vmfault+0x1c>

00000000800015e2 <copyout>:
  while(len > 0){
    800015e2:	c2cd                	beqz	a3,80001684 <copyout+0xa2>
{
    800015e4:	711d                	addi	sp,sp,-96
    800015e6:	ec86                	sd	ra,88(sp)
    800015e8:	e8a2                	sd	s0,80(sp)
    800015ea:	e4a6                	sd	s1,72(sp)
    800015ec:	f852                	sd	s4,48(sp)
    800015ee:	f05a                	sd	s6,32(sp)
    800015f0:	ec5e                	sd	s7,24(sp)
    800015f2:	e862                	sd	s8,16(sp)
    800015f4:	1080                	addi	s0,sp,96
    800015f6:	8c2a                	mv	s8,a0
    800015f8:	8b2e                	mv	s6,a1
    800015fa:	8bb2                	mv	s7,a2
    800015fc:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015fe:	74fd                	lui	s1,0xfffff
    80001600:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001602:	57fd                	li	a5,-1
    80001604:	83e9                	srli	a5,a5,0x1a
    80001606:	0897e163          	bltu	a5,s1,80001688 <copyout+0xa6>
    8000160a:	e0ca                	sd	s2,64(sp)
    8000160c:	fc4e                	sd	s3,56(sp)
    8000160e:	f456                	sd	s5,40(sp)
    80001610:	e466                	sd	s9,8(sp)
    80001612:	e06a                	sd	s10,0(sp)
    80001614:	6d05                	lui	s10,0x1
    80001616:	8cbe                	mv	s9,a5
    80001618:	a015                	j	8000163c <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000161a:	409b0533          	sub	a0,s6,s1
    8000161e:	0009861b          	sext.w	a2,s3
    80001622:	85de                	mv	a1,s7
    80001624:	954a                	add	a0,a0,s2
    80001626:	ed8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000162a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000162e:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001630:	040a0363          	beqz	s4,80001676 <copyout+0x94>
    if(va0 >= MAXVA)
    80001634:	055cec63          	bltu	s9,s5,8000168c <copyout+0xaa>
    80001638:	84d6                	mv	s1,s5
    8000163a:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    8000163c:	85a6                	mv	a1,s1
    8000163e:	8562                	mv	a0,s8
    80001640:	971ff0ef          	jal	80000fb0 <walkaddr>
    80001644:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001646:	e901                	bnez	a0,80001656 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001648:	4601                	li	a2,0
    8000164a:	85a6                	mv	a1,s1
    8000164c:	8562                	mv	a0,s8
    8000164e:	f13ff0ef          	jal	80001560 <vmfault>
    80001652:	892a                	mv	s2,a0
    80001654:	c139                	beqz	a0,8000169a <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001656:	4601                	li	a2,0
    80001658:	85a6                	mv	a1,s1
    8000165a:	8562                	mv	a0,s8
    8000165c:	8bbff0ef          	jal	80000f16 <walk>
    if((*pte & PTE_W) == 0)
    80001660:	611c                	ld	a5,0(a0)
    80001662:	8b91                	andi	a5,a5,4
    80001664:	c3b1                	beqz	a5,800016a8 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001666:	01a48ab3          	add	s5,s1,s10
    8000166a:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000166e:	fb3a76e3          	bgeu	s4,s3,8000161a <copyout+0x38>
    80001672:	89d2                	mv	s3,s4
    80001674:	b75d                	j	8000161a <copyout+0x38>
  return 0;
    80001676:	4501                	li	a0,0
    80001678:	6906                	ld	s2,64(sp)
    8000167a:	79e2                	ld	s3,56(sp)
    8000167c:	7aa2                	ld	s5,40(sp)
    8000167e:	6ca2                	ld	s9,8(sp)
    80001680:	6d02                	ld	s10,0(sp)
    80001682:	a80d                	j	800016b4 <copyout+0xd2>
    80001684:	4501                	li	a0,0
}
    80001686:	8082                	ret
      return -1;
    80001688:	557d                	li	a0,-1
    8000168a:	a02d                	j	800016b4 <copyout+0xd2>
    8000168c:	557d                	li	a0,-1
    8000168e:	6906                	ld	s2,64(sp)
    80001690:	79e2                	ld	s3,56(sp)
    80001692:	7aa2                	ld	s5,40(sp)
    80001694:	6ca2                	ld	s9,8(sp)
    80001696:	6d02                	ld	s10,0(sp)
    80001698:	a831                	j	800016b4 <copyout+0xd2>
        return -1;
    8000169a:	557d                	li	a0,-1
    8000169c:	6906                	ld	s2,64(sp)
    8000169e:	79e2                	ld	s3,56(sp)
    800016a0:	7aa2                	ld	s5,40(sp)
    800016a2:	6ca2                	ld	s9,8(sp)
    800016a4:	6d02                	ld	s10,0(sp)
    800016a6:	a039                	j	800016b4 <copyout+0xd2>
      return -1;
    800016a8:	557d                	li	a0,-1
    800016aa:	6906                	ld	s2,64(sp)
    800016ac:	79e2                	ld	s3,56(sp)
    800016ae:	7aa2                	ld	s5,40(sp)
    800016b0:	6ca2                	ld	s9,8(sp)
    800016b2:	6d02                	ld	s10,0(sp)
}
    800016b4:	60e6                	ld	ra,88(sp)
    800016b6:	6446                	ld	s0,80(sp)
    800016b8:	64a6                	ld	s1,72(sp)
    800016ba:	7a42                	ld	s4,48(sp)
    800016bc:	7b02                	ld	s6,32(sp)
    800016be:	6be2                	ld	s7,24(sp)
    800016c0:	6c42                	ld	s8,16(sp)
    800016c2:	6125                	addi	sp,sp,96
    800016c4:	8082                	ret

00000000800016c6 <copyin>:
  while(len > 0){
    800016c6:	c6c9                	beqz	a3,80001750 <copyin+0x8a>
{
    800016c8:	715d                	addi	sp,sp,-80
    800016ca:	e486                	sd	ra,72(sp)
    800016cc:	e0a2                	sd	s0,64(sp)
    800016ce:	fc26                	sd	s1,56(sp)
    800016d0:	f84a                	sd	s2,48(sp)
    800016d2:	f44e                	sd	s3,40(sp)
    800016d4:	f052                	sd	s4,32(sp)
    800016d6:	ec56                	sd	s5,24(sp)
    800016d8:	e85a                	sd	s6,16(sp)
    800016da:	e45e                	sd	s7,8(sp)
    800016dc:	e062                	sd	s8,0(sp)
    800016de:	0880                	addi	s0,sp,80
    800016e0:	8baa                	mv	s7,a0
    800016e2:	8aae                	mv	s5,a1
    800016e4:	8932                	mv	s2,a2
    800016e6:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800016e8:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016ea:	6b05                	lui	s6,0x1
    800016ec:	a035                	j	80001718 <copyin+0x52>
    800016ee:	412984b3          	sub	s1,s3,s2
    800016f2:	94da                	add	s1,s1,s6
    if(n > len)
    800016f4:	009a7363          	bgeu	s4,s1,800016fa <copyin+0x34>
    800016f8:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016fa:	413905b3          	sub	a1,s2,s3
    800016fe:	0004861b          	sext.w	a2,s1
    80001702:	95aa                	add	a1,a1,a0
    80001704:	8556                	mv	a0,s5
    80001706:	df8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000170a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000170e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001710:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001714:	020a0163          	beqz	s4,80001736 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001718:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000171c:	85ce                	mv	a1,s3
    8000171e:	855e                	mv	a0,s7
    80001720:	891ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0) {
    80001724:	f569                	bnez	a0,800016ee <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001726:	4601                	li	a2,0
    80001728:	85ce                	mv	a1,s3
    8000172a:	855e                	mv	a0,s7
    8000172c:	e35ff0ef          	jal	80001560 <vmfault>
    80001730:	fd5d                	bnez	a0,800016ee <copyin+0x28>
        return -1;
    80001732:	557d                	li	a0,-1
    80001734:	a011                	j	80001738 <copyin+0x72>
  return 0;
    80001736:	4501                	li	a0,0
}
    80001738:	60a6                	ld	ra,72(sp)
    8000173a:	6406                	ld	s0,64(sp)
    8000173c:	74e2                	ld	s1,56(sp)
    8000173e:	7942                	ld	s2,48(sp)
    80001740:	79a2                	ld	s3,40(sp)
    80001742:	7a02                	ld	s4,32(sp)
    80001744:	6ae2                	ld	s5,24(sp)
    80001746:	6b42                	ld	s6,16(sp)
    80001748:	6ba2                	ld	s7,8(sp)
    8000174a:	6c02                	ld	s8,0(sp)
    8000174c:	6161                	addi	sp,sp,80
    8000174e:	8082                	ret
  return 0;
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret

0000000080001754 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001754:	7139                	addi	sp,sp,-64
    80001756:	fc06                	sd	ra,56(sp)
    80001758:	f822                	sd	s0,48(sp)
    8000175a:	f426                	sd	s1,40(sp)
    8000175c:	f04a                	sd	s2,32(sp)
    8000175e:	ec4e                	sd	s3,24(sp)
    80001760:	e852                	sd	s4,16(sp)
    80001762:	e456                	sd	s5,8(sp)
    80001764:	e05a                	sd	s6,0(sp)
    80001766:	0080                	addi	s0,sp,64
    80001768:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176a:	0000e497          	auipc	s1,0xe
    8000176e:	65e48493          	addi	s1,s1,1630 # 8000fdc8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001772:	8b26                	mv	s6,s1
    80001774:	ff4df937          	lui	s2,0xff4df
    80001778:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdc25>
    8000177c:	0936                	slli	s2,s2,0xd
    8000177e:	6f590913          	addi	s2,s2,1781
    80001782:	0936                	slli	s2,s2,0xd
    80001784:	bd390913          	addi	s2,s2,-1069
    80001788:	0932                	slli	s2,s2,0xc
    8000178a:	7a790913          	addi	s2,s2,1959
    8000178e:	040009b7          	lui	s3,0x4000
    80001792:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001794:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001796:	00014a97          	auipc	s5,0x14
    8000179a:	222a8a93          	addi	s5,s5,546 # 800159b8 <tickslock>
    char *pa = kalloc();
    8000179e:	b60ff0ef          	jal	80000afe <kalloc>
    800017a2:	862a                	mv	a2,a0
    if(pa == 0)
    800017a4:	cd15                	beqz	a0,800017e0 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017a6:	416485b3          	sub	a1,s1,s6
    800017aa:	8591                	srai	a1,a1,0x4
    800017ac:	032585b3          	mul	a1,a1,s2
    800017b0:	2585                	addiw	a1,a1,1
    800017b2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017b6:	4719                	li	a4,6
    800017b8:	6685                	lui	a3,0x1
    800017ba:	40b985b3          	sub	a1,s3,a1
    800017be:	8552                	mv	a0,s4
    800017c0:	8dfff0ef          	jal	8000109e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c4:	17048493          	addi	s1,s1,368
    800017c8:	fd549be3          	bne	s1,s5,8000179e <proc_mapstacks+0x4a>
  }
}
    800017cc:	70e2                	ld	ra,56(sp)
    800017ce:	7442                	ld	s0,48(sp)
    800017d0:	74a2                	ld	s1,40(sp)
    800017d2:	7902                	ld	s2,32(sp)
    800017d4:	69e2                	ld	s3,24(sp)
    800017d6:	6a42                	ld	s4,16(sp)
    800017d8:	6aa2                	ld	s5,8(sp)
    800017da:	6b02                	ld	s6,0(sp)
    800017dc:	6121                	addi	sp,sp,64
    800017de:	8082                	ret
      panic("kalloc");
    800017e0:	00006517          	auipc	a0,0x6
    800017e4:	97850513          	addi	a0,a0,-1672 # 80007158 <etext+0x158>
    800017e8:	ff9fe0ef          	jal	800007e0 <panic>

00000000800017ec <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017ec:	7139                	addi	sp,sp,-64
    800017ee:	fc06                	sd	ra,56(sp)
    800017f0:	f822                	sd	s0,48(sp)
    800017f2:	f426                	sd	s1,40(sp)
    800017f4:	f04a                	sd	s2,32(sp)
    800017f6:	ec4e                	sd	s3,24(sp)
    800017f8:	e852                	sd	s4,16(sp)
    800017fa:	e456                	sd	s5,8(sp)
    800017fc:	e05a                	sd	s6,0(sp)
    800017fe:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001800:	00006597          	auipc	a1,0x6
    80001804:	96058593          	addi	a1,a1,-1696 # 80007160 <etext+0x160>
    80001808:	0000e517          	auipc	a0,0xe
    8000180c:	19050513          	addi	a0,a0,400 # 8000f998 <pid_lock>
    80001810:	b3eff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001814:	00006597          	auipc	a1,0x6
    80001818:	95458593          	addi	a1,a1,-1708 # 80007168 <etext+0x168>
    8000181c:	0000e517          	auipc	a0,0xe
    80001820:	19450513          	addi	a0,a0,404 # 8000f9b0 <wait_lock>
    80001824:	b2aff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001828:	0000e497          	auipc	s1,0xe
    8000182c:	5a048493          	addi	s1,s1,1440 # 8000fdc8 <proc>
      initlock(&p->lock, "proc");
    80001830:	00006b17          	auipc	s6,0x6
    80001834:	948b0b13          	addi	s6,s6,-1720 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001838:	8aa6                	mv	s5,s1
    8000183a:	ff4df937          	lui	s2,0xff4df
    8000183e:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdc25>
    80001842:	0936                	slli	s2,s2,0xd
    80001844:	6f590913          	addi	s2,s2,1781
    80001848:	0936                	slli	s2,s2,0xd
    8000184a:	bd390913          	addi	s2,s2,-1069
    8000184e:	0932                	slli	s2,s2,0xc
    80001850:	7a790913          	addi	s2,s2,1959
    80001854:	040009b7          	lui	s3,0x4000
    80001858:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000185a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	00014a17          	auipc	s4,0x14
    80001860:	15ca0a13          	addi	s4,s4,348 # 800159b8 <tickslock>
      initlock(&p->lock, "proc");
    80001864:	85da                	mv	a1,s6
    80001866:	8526                	mv	a0,s1
    80001868:	ae6ff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    8000186c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001870:	415487b3          	sub	a5,s1,s5
    80001874:	8791                	srai	a5,a5,0x4
    80001876:	032787b3          	mul	a5,a5,s2
    8000187a:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffde269>
    8000187c:	00d7979b          	slliw	a5,a5,0xd
    80001880:	40f987b3          	sub	a5,s3,a5
    80001884:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001886:	17048493          	addi	s1,s1,368
    8000188a:	fd449de3          	bne	s1,s4,80001864 <procinit+0x78>
  }
}
    8000188e:	70e2                	ld	ra,56(sp)
    80001890:	7442                	ld	s0,48(sp)
    80001892:	74a2                	ld	s1,40(sp)
    80001894:	7902                	ld	s2,32(sp)
    80001896:	69e2                	ld	s3,24(sp)
    80001898:	6a42                	ld	s4,16(sp)
    8000189a:	6aa2                	ld	s5,8(sp)
    8000189c:	6b02                	ld	s6,0(sp)
    8000189e:	6121                	addi	sp,sp,64
    800018a0:	8082                	ret

00000000800018a2 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018a2:	1141                	addi	sp,sp,-16
    800018a4:	e422                	sd	s0,8(sp)
    800018a6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018a8:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018aa:	2501                	sext.w	a0,a0
    800018ac:	6422                	ld	s0,8(sp)
    800018ae:	0141                	addi	sp,sp,16
    800018b0:	8082                	ret

00000000800018b2 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018b2:	1141                	addi	sp,sp,-16
    800018b4:	e422                	sd	s0,8(sp)
    800018b6:	0800                	addi	s0,sp,16
    800018b8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018ba:	2781                	sext.w	a5,a5
    800018bc:	079e                	slli	a5,a5,0x7
  return c;
}
    800018be:	0000e517          	auipc	a0,0xe
    800018c2:	10a50513          	addi	a0,a0,266 # 8000f9c8 <cpus>
    800018c6:	953e                	add	a0,a0,a5
    800018c8:	6422                	ld	s0,8(sp)
    800018ca:	0141                	addi	sp,sp,16
    800018cc:	8082                	ret

00000000800018ce <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018ce:	1101                	addi	sp,sp,-32
    800018d0:	ec06                	sd	ra,24(sp)
    800018d2:	e822                	sd	s0,16(sp)
    800018d4:	e426                	sd	s1,8(sp)
    800018d6:	1000                	addi	s0,sp,32
  push_off();
    800018d8:	ab6ff0ef          	jal	80000b8e <push_off>
    800018dc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018de:	2781                	sext.w	a5,a5
    800018e0:	079e                	slli	a5,a5,0x7
    800018e2:	0000e717          	auipc	a4,0xe
    800018e6:	0b670713          	addi	a4,a4,182 # 8000f998 <pid_lock>
    800018ea:	97ba                	add	a5,a5,a4
    800018ec:	7b84                	ld	s1,48(a5)
  pop_off();
    800018ee:	b24ff0ef          	jal	80000c12 <pop_off>
  return p;
}
    800018f2:	8526                	mv	a0,s1
    800018f4:	60e2                	ld	ra,24(sp)
    800018f6:	6442                	ld	s0,16(sp)
    800018f8:	64a2                	ld	s1,8(sp)
    800018fa:	6105                	addi	sp,sp,32
    800018fc:	8082                	ret

00000000800018fe <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800018fe:	7179                	addi	sp,sp,-48
    80001900:	f406                	sd	ra,40(sp)
    80001902:	f022                	sd	s0,32(sp)
    80001904:	ec26                	sd	s1,24(sp)
    80001906:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001908:	fc7ff0ef          	jal	800018ce <myproc>
    8000190c:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000190e:	b58ff0ef          	jal	80000c66 <release>

  if (first) {
    80001912:	00006797          	auipc	a5,0x6
    80001916:	f4e7a783          	lw	a5,-178(a5) # 80007860 <first.1>
    8000191a:	cf8d                	beqz	a5,80001954 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000191c:	4505                	li	a0,1
    8000191e:	3e5010ef          	jal	80003502 <fsinit>

    first = 0;
    80001922:	00006797          	auipc	a5,0x6
    80001926:	f207af23          	sw	zero,-194(a5) # 80007860 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000192a:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    8000192e:	00006517          	auipc	a0,0x6
    80001932:	85250513          	addi	a0,a0,-1966 # 80007180 <etext+0x180>
    80001936:	fca43823          	sd	a0,-48(s0)
    8000193a:	fc043c23          	sd	zero,-40(s0)
    8000193e:	fd040593          	addi	a1,s0,-48
    80001942:	4cb020ef          	jal	8000460c <kexec>
    80001946:	6cbc                	ld	a5,88(s1)
    80001948:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000194a:	6cbc                	ld	a5,88(s1)
    8000194c:	7bb8                	ld	a4,112(a5)
    8000194e:	57fd                	li	a5,-1
    80001950:	02f70d63          	beq	a4,a5,8000198a <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001954:	2c7000ef          	jal	8000241a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001958:	68a8                	ld	a0,80(s1)
    8000195a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000195c:	04000737          	lui	a4,0x4000
    80001960:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001962:	0732                	slli	a4,a4,0xc
    80001964:	00004797          	auipc	a5,0x4
    80001968:	73878793          	addi	a5,a5,1848 # 8000609c <userret>
    8000196c:	00004697          	auipc	a3,0x4
    80001970:	69468693          	addi	a3,a3,1684 # 80006000 <_trampoline>
    80001974:	8f95                	sub	a5,a5,a3
    80001976:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001978:	577d                	li	a4,-1
    8000197a:	177e                	slli	a4,a4,0x3f
    8000197c:	8d59                	or	a0,a0,a4
    8000197e:	9782                	jalr	a5
}
    80001980:	70a2                	ld	ra,40(sp)
    80001982:	7402                	ld	s0,32(sp)
    80001984:	64e2                	ld	s1,24(sp)
    80001986:	6145                	addi	sp,sp,48
    80001988:	8082                	ret
      panic("exec");
    8000198a:	00005517          	auipc	a0,0x5
    8000198e:	7fe50513          	addi	a0,a0,2046 # 80007188 <etext+0x188>
    80001992:	e4ffe0ef          	jal	800007e0 <panic>

0000000080001996 <allocpid>:
{
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	e04a                	sd	s2,0(sp)
    800019a0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019a2:	0000e917          	auipc	s2,0xe
    800019a6:	ff690913          	addi	s2,s2,-10 # 8000f998 <pid_lock>
    800019aa:	854a                	mv	a0,s2
    800019ac:	a22ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    800019b0:	00006797          	auipc	a5,0x6
    800019b4:	eb478793          	addi	a5,a5,-332 # 80007864 <nextpid>
    800019b8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019ba:	0014871b          	addiw	a4,s1,1
    800019be:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019c0:	854a                	mv	a0,s2
    800019c2:	aa4ff0ef          	jal	80000c66 <release>
}
    800019c6:	8526                	mv	a0,s1
    800019c8:	60e2                	ld	ra,24(sp)
    800019ca:	6442                	ld	s0,16(sp)
    800019cc:	64a2                	ld	s1,8(sp)
    800019ce:	6902                	ld	s2,0(sp)
    800019d0:	6105                	addi	sp,sp,32
    800019d2:	8082                	ret

00000000800019d4 <proc_pagetable>:
{
    800019d4:	1101                	addi	sp,sp,-32
    800019d6:	ec06                	sd	ra,24(sp)
    800019d8:	e822                	sd	s0,16(sp)
    800019da:	e426                	sd	s1,8(sp)
    800019dc:	e04a                	sd	s2,0(sp)
    800019de:	1000                	addi	s0,sp,32
    800019e0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019e2:	fb2ff0ef          	jal	80001194 <uvmcreate>
    800019e6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019e8:	cd05                	beqz	a0,80001a20 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019ea:	4729                	li	a4,10
    800019ec:	00004697          	auipc	a3,0x4
    800019f0:	61468693          	addi	a3,a3,1556 # 80006000 <_trampoline>
    800019f4:	6605                	lui	a2,0x1
    800019f6:	040005b7          	lui	a1,0x4000
    800019fa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019fc:	05b2                	slli	a1,a1,0xc
    800019fe:	df0ff0ef          	jal	80000fee <mappages>
    80001a02:	02054663          	bltz	a0,80001a2e <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a06:	4719                	li	a4,6
    80001a08:	05893683          	ld	a3,88(s2)
    80001a0c:	6605                	lui	a2,0x1
    80001a0e:	020005b7          	lui	a1,0x2000
    80001a12:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a14:	05b6                	slli	a1,a1,0xd
    80001a16:	8526                	mv	a0,s1
    80001a18:	dd6ff0ef          	jal	80000fee <mappages>
    80001a1c:	00054f63          	bltz	a0,80001a3a <proc_pagetable+0x66>
}
    80001a20:	8526                	mv	a0,s1
    80001a22:	60e2                	ld	ra,24(sp)
    80001a24:	6442                	ld	s0,16(sp)
    80001a26:	64a2                	ld	s1,8(sp)
    80001a28:	6902                	ld	s2,0(sp)
    80001a2a:	6105                	addi	sp,sp,32
    80001a2c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a2e:	4581                	li	a1,0
    80001a30:	8526                	mv	a0,s1
    80001a32:	95dff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a36:	4481                	li	s1,0
    80001a38:	b7e5                	j	80001a20 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a3a:	4681                	li	a3,0
    80001a3c:	4605                	li	a2,1
    80001a3e:	040005b7          	lui	a1,0x4000
    80001a42:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a44:	05b2                	slli	a1,a1,0xc
    80001a46:	8526                	mv	a0,s1
    80001a48:	f72ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a4c:	4581                	li	a1,0
    80001a4e:	8526                	mv	a0,s1
    80001a50:	93fff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a54:	4481                	li	s1,0
    80001a56:	b7e9                	j	80001a20 <proc_pagetable+0x4c>

0000000080001a58 <proc_freepagetable>:
{
    80001a58:	1101                	addi	sp,sp,-32
    80001a5a:	ec06                	sd	ra,24(sp)
    80001a5c:	e822                	sd	s0,16(sp)
    80001a5e:	e426                	sd	s1,8(sp)
    80001a60:	e04a                	sd	s2,0(sp)
    80001a62:	1000                	addi	s0,sp,32
    80001a64:	84aa                	mv	s1,a0
    80001a66:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a68:	4681                	li	a3,0
    80001a6a:	4605                	li	a2,1
    80001a6c:	040005b7          	lui	a1,0x4000
    80001a70:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a72:	05b2                	slli	a1,a1,0xc
    80001a74:	f46ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a78:	4681                	li	a3,0
    80001a7a:	4605                	li	a2,1
    80001a7c:	020005b7          	lui	a1,0x2000
    80001a80:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a82:	05b6                	slli	a1,a1,0xd
    80001a84:	8526                	mv	a0,s1
    80001a86:	f34ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a8a:	85ca                	mv	a1,s2
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	901ff0ef          	jal	8000138e <uvmfree>
}
    80001a92:	60e2                	ld	ra,24(sp)
    80001a94:	6442                	ld	s0,16(sp)
    80001a96:	64a2                	ld	s1,8(sp)
    80001a98:	6902                	ld	s2,0(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret

0000000080001a9e <freeproc>:
{
    80001a9e:	1101                	addi	sp,sp,-32
    80001aa0:	ec06                	sd	ra,24(sp)
    80001aa2:	e822                	sd	s0,16(sp)
    80001aa4:	e426                	sd	s1,8(sp)
    80001aa6:	1000                	addi	s0,sp,32
    80001aa8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001aaa:	6d28                	ld	a0,88(a0)
    80001aac:	c119                	beqz	a0,80001ab2 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001aae:	f6ffe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001ab2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ab6:	68a8                	ld	a0,80(s1)
    80001ab8:	c501                	beqz	a0,80001ac0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001aba:	64ac                	ld	a1,72(s1)
    80001abc:	f9dff0ef          	jal	80001a58 <proc_freepagetable>
  p->pagetable = 0;
    80001ac0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ac4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ac8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001acc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ad0:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001ad4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ad8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001adc:	0204a623          	sw	zero,44(s1)
  p->syscall_mask = 0;
    80001ae0:	1404bc23          	sd	zero,344(s1)
  p->state = UNUSED;
    80001ae4:	0004ac23          	sw	zero,24(s1)
}
    80001ae8:	60e2                	ld	ra,24(sp)
    80001aea:	6442                	ld	s0,16(sp)
    80001aec:	64a2                	ld	s1,8(sp)
    80001aee:	6105                	addi	sp,sp,32
    80001af0:	8082                	ret

0000000080001af2 <allocproc>:
{
    80001af2:	1101                	addi	sp,sp,-32
    80001af4:	ec06                	sd	ra,24(sp)
    80001af6:	e822                	sd	s0,16(sp)
    80001af8:	e426                	sd	s1,8(sp)
    80001afa:	e04a                	sd	s2,0(sp)
    80001afc:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001afe:	0000e497          	auipc	s1,0xe
    80001b02:	2ba48493          	addi	s1,s1,698 # 8000fdb8 <proc>
    80001b06:	00014917          	auipc	s2,0x14
    80001b0a:	eb290913          	addi	s2,s2,-334 # 800159b8 <tickslock>
    acquire(&p->lock);
    80001b0e:	8526                	mv	a0,s1
    80001b10:	8beff0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001b14:	4c9c                	lw	a5,24(s1)
    80001b16:	cb91                	beqz	a5,80001b2a <allocproc+0x38>
      release(&p->lock);
    80001b18:	8526                	mv	a0,s1
    80001b1a:	94cff0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b1e:	17048493          	addi	s1,s1,368
    80001b22:	ff2496e3          	bne	s1,s2,80001b0e <allocproc+0x1c>
  return 0;
    80001b26:	4481                	li	s1,0
    80001b28:	a099                	j	80001b6e <allocproc+0x7c>
  p->pid = allocpid();
    80001b2a:	e6dff0ef          	jal	80001996 <allocpid>
    80001b2e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b30:	4785                	li	a5,1
    80001b32:	cc9c                	sw	a5,24(s1)
  p->syscall_mask = 0;
    80001b34:	1404bc23          	sd	zero,344(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b38:	fc7fe0ef          	jal	80000afe <kalloc>
    80001b3c:	892a                	mv	s2,a0
    80001b3e:	eca8                	sd	a0,88(s1)
    80001b40:	cd15                	beqz	a0,80001b7c <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80001b42:	8526                	mv	a0,s1
    80001b44:	e91ff0ef          	jal	800019d4 <proc_pagetable>
    80001b48:	892a                	mv	s2,a0
    80001b4a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b4c:	c121                	beqz	a0,80001b8c <allocproc+0x9a>
  memset(&p->context, 0, sizeof(p->context));
    80001b4e:	07000613          	li	a2,112
    80001b52:	4581                	li	a1,0
    80001b54:	06048513          	addi	a0,s1,96
    80001b58:	94aff0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001b5c:	00000797          	auipc	a5,0x0
    80001b60:	da278793          	addi	a5,a5,-606 # 800018fe <forkret>
    80001b64:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b66:	60bc                	ld	a5,64(s1)
    80001b68:	6705                	lui	a4,0x1
    80001b6a:	97ba                	add	a5,a5,a4
    80001b6c:	f4bc                	sd	a5,104(s1)
}
    80001b6e:	8526                	mv	a0,s1
    80001b70:	60e2                	ld	ra,24(sp)
    80001b72:	6442                	ld	s0,16(sp)
    80001b74:	64a2                	ld	s1,8(sp)
    80001b76:	6902                	ld	s2,0(sp)
    80001b78:	6105                	addi	sp,sp,32
    80001b7a:	8082                	ret
    freeproc(p);
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	f21ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b82:	8526                	mv	a0,s1
    80001b84:	8e2ff0ef          	jal	80000c66 <release>
    return 0;
    80001b88:	84ca                	mv	s1,s2
    80001b8a:	b7d5                	j	80001b6e <allocproc+0x7c>
    freeproc(p);
    80001b8c:	8526                	mv	a0,s1
    80001b8e:	f11ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b92:	8526                	mv	a0,s1
    80001b94:	8d2ff0ef          	jal	80000c66 <release>
    return 0;
    80001b98:	84ca                	mv	s1,s2
    80001b9a:	bfd1                	j	80001b6e <allocproc+0x7c>

0000000080001b9c <userinit>:
{
    80001b9c:	1101                	addi	sp,sp,-32
    80001b9e:	ec06                	sd	ra,24(sp)
    80001ba0:	e822                	sd	s0,16(sp)
    80001ba2:	e426                	sd	s1,8(sp)
    80001ba4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ba6:	f4dff0ef          	jal	80001af2 <allocproc>
    80001baa:	84aa                	mv	s1,a0
  initproc = p;
    80001bac:	00006797          	auipc	a5,0x6
    80001bb0:	cca7ba23          	sd	a0,-812(a5) # 80007880 <initproc>
  p->cwd = namei("/");
    80001bb4:	00005517          	auipc	a0,0x5
    80001bb8:	5d450513          	addi	a0,a0,1492 # 80007188 <etext+0x188>
    80001bbc:	669010ef          	jal	80003a24 <namei>
    80001bc0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bc4:	478d                	li	a5,3
    80001bc6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bc8:	8526                	mv	a0,s1
    80001bca:	89cff0ef          	jal	80000c66 <release>
}
    80001bce:	60e2                	ld	ra,24(sp)
    80001bd0:	6442                	ld	s0,16(sp)
    80001bd2:	64a2                	ld	s1,8(sp)
    80001bd4:	6105                	addi	sp,sp,32
    80001bd6:	8082                	ret

0000000080001bd8 <growproc>:
{
    80001bd8:	1101                	addi	sp,sp,-32
    80001bda:	ec06                	sd	ra,24(sp)
    80001bdc:	e822                	sd	s0,16(sp)
    80001bde:	e426                	sd	s1,8(sp)
    80001be0:	e04a                	sd	s2,0(sp)
    80001be2:	1000                	addi	s0,sp,32
    80001be4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001be6:	ce9ff0ef          	jal	800018ce <myproc>
    80001bea:	892a                	mv	s2,a0
  sz = p->sz;
    80001bec:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bee:	02905963          	blez	s1,80001c20 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001bf2:	00b48633          	add	a2,s1,a1
    80001bf6:	020007b7          	lui	a5,0x2000
    80001bfa:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001bfc:	07b6                	slli	a5,a5,0xd
    80001bfe:	02c7ea63          	bltu	a5,a2,80001c32 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c02:	4691                	li	a3,4
    80001c04:	6928                	ld	a0,80(a0)
    80001c06:	e82ff0ef          	jal	80001288 <uvmalloc>
    80001c0a:	85aa                	mv	a1,a0
    80001c0c:	c50d                	beqz	a0,80001c36 <growproc+0x5e>
  p->sz = sz;
    80001c0e:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c12:	4501                	li	a0,0
}
    80001c14:	60e2                	ld	ra,24(sp)
    80001c16:	6442                	ld	s0,16(sp)
    80001c18:	64a2                	ld	s1,8(sp)
    80001c1a:	6902                	ld	s2,0(sp)
    80001c1c:	6105                	addi	sp,sp,32
    80001c1e:	8082                	ret
  } else if(n < 0){
    80001c20:	fe04d7e3          	bgez	s1,80001c0e <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c24:	00b48633          	add	a2,s1,a1
    80001c28:	6928                	ld	a0,80(a0)
    80001c2a:	e1aff0ef          	jal	80001244 <uvmdealloc>
    80001c2e:	85aa                	mv	a1,a0
    80001c30:	bff9                	j	80001c0e <growproc+0x36>
      return -1;
    80001c32:	557d                	li	a0,-1
    80001c34:	b7c5                	j	80001c14 <growproc+0x3c>
      return -1;
    80001c36:	557d                	li	a0,-1
    80001c38:	bff1                	j	80001c14 <growproc+0x3c>

0000000080001c3a <kfork>:
{
    80001c3a:	7139                	addi	sp,sp,-64
    80001c3c:	fc06                	sd	ra,56(sp)
    80001c3e:	f822                	sd	s0,48(sp)
    80001c40:	f04a                	sd	s2,32(sp)
    80001c42:	e456                	sd	s5,8(sp)
    80001c44:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c46:	c89ff0ef          	jal	800018ce <myproc>
    80001c4a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c4c:	ea7ff0ef          	jal	80001af2 <allocproc>
    80001c50:	0e050a63          	beqz	a0,80001d44 <kfork+0x10a>
    80001c54:	e852                	sd	s4,16(sp)
    80001c56:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c58:	048ab603          	ld	a2,72(s5)
    80001c5c:	692c                	ld	a1,80(a0)
    80001c5e:	050ab503          	ld	a0,80(s5)
    80001c62:	f5eff0ef          	jal	800013c0 <uvmcopy>
    80001c66:	04054a63          	bltz	a0,80001cba <kfork+0x80>
    80001c6a:	f426                	sd	s1,40(sp)
    80001c6c:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c6e:	048ab783          	ld	a5,72(s5)
    80001c72:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c76:	058ab683          	ld	a3,88(s5)
    80001c7a:	87b6                	mv	a5,a3
    80001c7c:	058a3703          	ld	a4,88(s4)
    80001c80:	12068693          	addi	a3,a3,288
    80001c84:	0007b803          	ld	a6,0(a5)
    80001c88:	6788                	ld	a0,8(a5)
    80001c8a:	6b8c                	ld	a1,16(a5)
    80001c8c:	6f90                	ld	a2,24(a5)
    80001c8e:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c92:	e708                	sd	a0,8(a4)
    80001c94:	eb0c                	sd	a1,16(a4)
    80001c96:	ef10                	sd	a2,24(a4)
    80001c98:	02078793          	addi	a5,a5,32
    80001c9c:	02070713          	addi	a4,a4,32
    80001ca0:	fed792e3          	bne	a5,a3,80001c84 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001ca4:	058a3783          	ld	a5,88(s4)
    80001ca8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001cac:	0d0a8493          	addi	s1,s5,208
    80001cb0:	0d0a0913          	addi	s2,s4,208
    80001cb4:	150a8993          	addi	s3,s5,336
    80001cb8:	a831                	j	80001cd4 <kfork+0x9a>
    freeproc(np);
    80001cba:	8552                	mv	a0,s4
    80001cbc:	de3ff0ef          	jal	80001a9e <freeproc>
    release(&np->lock);
    80001cc0:	8552                	mv	a0,s4
    80001cc2:	fa5fe0ef          	jal	80000c66 <release>
    return -1;
    80001cc6:	597d                	li	s2,-1
    80001cc8:	6a42                	ld	s4,16(sp)
    80001cca:	a0b5                	j	80001d36 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001ccc:	04a1                	addi	s1,s1,8
    80001cce:	0921                	addi	s2,s2,8
    80001cd0:	01348963          	beq	s1,s3,80001ce2 <kfork+0xa8>
    if(p->ofile[i])
    80001cd4:	6088                	ld	a0,0(s1)
    80001cd6:	d97d                	beqz	a0,80001ccc <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cd8:	2e6020ef          	jal	80003fbe <filedup>
    80001cdc:	00a93023          	sd	a0,0(s2)
    80001ce0:	b7f5                	j	80001ccc <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001ce2:	150ab503          	ld	a0,336(s5)
    80001ce6:	4f2010ef          	jal	800031d8 <idup>
    80001cea:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cee:	4641                	li	a2,16
    80001cf0:	160a8593          	addi	a1,s5,352
    80001cf4:	160a0513          	addi	a0,s4,352
    80001cf8:	8e8ff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001cfc:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d00:	8552                	mv	a0,s4
    80001d02:	f65fe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001d06:	0000e497          	auipc	s1,0xe
    80001d0a:	c9a48493          	addi	s1,s1,-870 # 8000f9a0 <wait_lock>
    80001d0e:	8526                	mv	a0,s1
    80001d10:	ebffe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001d14:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d18:	8526                	mv	a0,s1
    80001d1a:	f4dfe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001d1e:	8552                	mv	a0,s4
    80001d20:	eaffe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001d24:	478d                	li	a5,3
    80001d26:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d2a:	8552                	mv	a0,s4
    80001d2c:	f3bfe0ef          	jal	80000c66 <release>
  return pid;
    80001d30:	74a2                	ld	s1,40(sp)
    80001d32:	69e2                	ld	s3,24(sp)
    80001d34:	6a42                	ld	s4,16(sp)
}
    80001d36:	854a                	mv	a0,s2
    80001d38:	70e2                	ld	ra,56(sp)
    80001d3a:	7442                	ld	s0,48(sp)
    80001d3c:	7902                	ld	s2,32(sp)
    80001d3e:	6aa2                	ld	s5,8(sp)
    80001d40:	6121                	addi	sp,sp,64
    80001d42:	8082                	ret
    return -1;
    80001d44:	597d                	li	s2,-1
    80001d46:	bfc5                	j	80001d36 <kfork+0xfc>

0000000080001d48 <scheduler>:
{
    80001d48:	715d                	addi	sp,sp,-80
    80001d4a:	e486                	sd	ra,72(sp)
    80001d4c:	e0a2                	sd	s0,64(sp)
    80001d4e:	fc26                	sd	s1,56(sp)
    80001d50:	f84a                	sd	s2,48(sp)
    80001d52:	f44e                	sd	s3,40(sp)
    80001d54:	f052                	sd	s4,32(sp)
    80001d56:	ec56                	sd	s5,24(sp)
    80001d58:	e85a                	sd	s6,16(sp)
    80001d5a:	e45e                	sd	s7,8(sp)
    80001d5c:	e062                	sd	s8,0(sp)
    80001d5e:	0880                	addi	s0,sp,80
    80001d60:	8792                	mv	a5,tp
  int id = r_tp();
    80001d62:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d64:	00779b13          	slli	s6,a5,0x7
    80001d68:	0000e717          	auipc	a4,0xe
    80001d6c:	c2070713          	addi	a4,a4,-992 # 8000f988 <pid_lock>
    80001d70:	975a                	add	a4,a4,s6
    80001d72:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d76:	0000e717          	auipc	a4,0xe
    80001d7a:	c4a70713          	addi	a4,a4,-950 # 8000f9c0 <cpus+0x8>
    80001d7e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d80:	4c11                	li	s8,4
        c->proc = p;
    80001d82:	079e                	slli	a5,a5,0x7
    80001d84:	0000ea17          	auipc	s4,0xe
    80001d88:	c04a0a13          	addi	s4,s4,-1020 # 8000f988 <pid_lock>
    80001d8c:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d8e:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d90:	00014997          	auipc	s3,0x14
    80001d94:	c2898993          	addi	s3,s3,-984 # 800159b8 <tickslock>
    80001d98:	a83d                	j	80001dd6 <scheduler+0x8e>
      release(&p->lock);
    80001d9a:	8526                	mv	a0,s1
    80001d9c:	ecbfe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001da0:	17048493          	addi	s1,s1,368
    80001da4:	03348563          	beq	s1,s3,80001dce <scheduler+0x86>
      acquire(&p->lock);
    80001da8:	8526                	mv	a0,s1
    80001daa:	e25fe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001dae:	4c9c                	lw	a5,24(s1)
    80001db0:	ff2795e3          	bne	a5,s2,80001d9a <scheduler+0x52>
        p->state = RUNNING;
    80001db4:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001db8:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001dbc:	06048593          	addi	a1,s1,96
    80001dc0:	855a                	mv	a0,s6
    80001dc2:	5b2000ef          	jal	80002374 <swtch>
        c->proc = 0;
    80001dc6:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dca:	8ade                	mv	s5,s7
    80001dcc:	b7f9                	j	80001d9a <scheduler+0x52>
    if(found == 0) {
    80001dce:	000a9463          	bnez	s5,80001dd6 <scheduler+0x8e>
      asm volatile("wfi");
    80001dd2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dd6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dda:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dde:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001de2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001de6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001de8:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dec:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dee:	0000e497          	auipc	s1,0xe
    80001df2:	fca48493          	addi	s1,s1,-54 # 8000fdb8 <proc>
      if(p->state == RUNNABLE) {
    80001df6:	490d                	li	s2,3
    80001df8:	bf45                	j	80001da8 <scheduler+0x60>

0000000080001dfa <sched>:
{
    80001dfa:	7179                	addi	sp,sp,-48
    80001dfc:	f406                	sd	ra,40(sp)
    80001dfe:	f022                	sd	s0,32(sp)
    80001e00:	ec26                	sd	s1,24(sp)
    80001e02:	e84a                	sd	s2,16(sp)
    80001e04:	e44e                	sd	s3,8(sp)
    80001e06:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e08:	ac7ff0ef          	jal	800018ce <myproc>
    80001e0c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e0e:	d57fe0ef          	jal	80000b64 <holding>
    80001e12:	c92d                	beqz	a0,80001e84 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e14:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e16:	2781                	sext.w	a5,a5
    80001e18:	079e                	slli	a5,a5,0x7
    80001e1a:	0000e717          	auipc	a4,0xe
    80001e1e:	b6e70713          	addi	a4,a4,-1170 # 8000f988 <pid_lock>
    80001e22:	97ba                	add	a5,a5,a4
    80001e24:	0a87a703          	lw	a4,168(a5)
    80001e28:	4785                	li	a5,1
    80001e2a:	06f71363          	bne	a4,a5,80001e90 <sched+0x96>
  if(p->state == RUNNING)
    80001e2e:	4c98                	lw	a4,24(s1)
    80001e30:	4791                	li	a5,4
    80001e32:	06f70563          	beq	a4,a5,80001e9c <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e3a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e3c:	e7b5                	bnez	a5,80001ea8 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e3e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e40:	0000e917          	auipc	s2,0xe
    80001e44:	b4890913          	addi	s2,s2,-1208 # 8000f988 <pid_lock>
    80001e48:	2781                	sext.w	a5,a5
    80001e4a:	079e                	slli	a5,a5,0x7
    80001e4c:	97ca                	add	a5,a5,s2
    80001e4e:	0ac7a983          	lw	s3,172(a5)
    80001e52:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e54:	2781                	sext.w	a5,a5
    80001e56:	079e                	slli	a5,a5,0x7
    80001e58:	0000e597          	auipc	a1,0xe
    80001e5c:	b6858593          	addi	a1,a1,-1176 # 8000f9c0 <cpus+0x8>
    80001e60:	95be                	add	a1,a1,a5
    80001e62:	06048513          	addi	a0,s1,96
    80001e66:	50e000ef          	jal	80002374 <swtch>
    80001e6a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e6c:	2781                	sext.w	a5,a5
    80001e6e:	079e                	slli	a5,a5,0x7
    80001e70:	993e                	add	s2,s2,a5
    80001e72:	0b392623          	sw	s3,172(s2)
}
    80001e76:	70a2                	ld	ra,40(sp)
    80001e78:	7402                	ld	s0,32(sp)
    80001e7a:	64e2                	ld	s1,24(sp)
    80001e7c:	6942                	ld	s2,16(sp)
    80001e7e:	69a2                	ld	s3,8(sp)
    80001e80:	6145                	addi	sp,sp,48
    80001e82:	8082                	ret
    panic("sched p->lock");
    80001e84:	00005517          	auipc	a0,0x5
    80001e88:	30c50513          	addi	a0,a0,780 # 80007190 <etext+0x190>
    80001e8c:	955fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80001e90:	00005517          	auipc	a0,0x5
    80001e94:	31050513          	addi	a0,a0,784 # 800071a0 <etext+0x1a0>
    80001e98:	949fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80001e9c:	00005517          	auipc	a0,0x5
    80001ea0:	31450513          	addi	a0,a0,788 # 800071b0 <etext+0x1b0>
    80001ea4:	93dfe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80001ea8:	00005517          	auipc	a0,0x5
    80001eac:	31850513          	addi	a0,a0,792 # 800071c0 <etext+0x1c0>
    80001eb0:	931fe0ef          	jal	800007e0 <panic>

0000000080001eb4 <yield>:
{
    80001eb4:	1101                	addi	sp,sp,-32
    80001eb6:	ec06                	sd	ra,24(sp)
    80001eb8:	e822                	sd	s0,16(sp)
    80001eba:	e426                	sd	s1,8(sp)
    80001ebc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ebe:	a11ff0ef          	jal	800018ce <myproc>
    80001ec2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ec4:	d0bfe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    80001ec8:	478d                	li	a5,3
    80001eca:	cc9c                	sw	a5,24(s1)
  sched();
    80001ecc:	f2fff0ef          	jal	80001dfa <sched>
  release(&p->lock);
    80001ed0:	8526                	mv	a0,s1
    80001ed2:	d95fe0ef          	jal	80000c66 <release>
}
    80001ed6:	60e2                	ld	ra,24(sp)
    80001ed8:	6442                	ld	s0,16(sp)
    80001eda:	64a2                	ld	s1,8(sp)
    80001edc:	6105                	addi	sp,sp,32
    80001ede:	8082                	ret

0000000080001ee0 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ee0:	7179                	addi	sp,sp,-48
    80001ee2:	f406                	sd	ra,40(sp)
    80001ee4:	f022                	sd	s0,32(sp)
    80001ee6:	ec26                	sd	s1,24(sp)
    80001ee8:	e84a                	sd	s2,16(sp)
    80001eea:	e44e                	sd	s3,8(sp)
    80001eec:	1800                	addi	s0,sp,48
    80001eee:	89aa                	mv	s3,a0
    80001ef0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ef2:	9ddff0ef          	jal	800018ce <myproc>
    80001ef6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ef8:	cd7fe0ef          	jal	80000bce <acquire>
  release(lk);
    80001efc:	854a                	mv	a0,s2
    80001efe:	d69fe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80001f02:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f06:	4789                	li	a5,2
    80001f08:	cc9c                	sw	a5,24(s1)

  sched();
    80001f0a:	ef1ff0ef          	jal	80001dfa <sched>

  // Tidy up.
  p->chan = 0;
    80001f0e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f12:	8526                	mv	a0,s1
    80001f14:	d53fe0ef          	jal	80000c66 <release>
  acquire(lk);
    80001f18:	854a                	mv	a0,s2
    80001f1a:	cb5fe0ef          	jal	80000bce <acquire>
}
    80001f1e:	70a2                	ld	ra,40(sp)
    80001f20:	7402                	ld	s0,32(sp)
    80001f22:	64e2                	ld	s1,24(sp)
    80001f24:	6942                	ld	s2,16(sp)
    80001f26:	69a2                	ld	s3,8(sp)
    80001f28:	6145                	addi	sp,sp,48
    80001f2a:	8082                	ret

0000000080001f2c <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f2c:	7139                	addi	sp,sp,-64
    80001f2e:	fc06                	sd	ra,56(sp)
    80001f30:	f822                	sd	s0,48(sp)
    80001f32:	f426                	sd	s1,40(sp)
    80001f34:	f04a                	sd	s2,32(sp)
    80001f36:	ec4e                	sd	s3,24(sp)
    80001f38:	e852                	sd	s4,16(sp)
    80001f3a:	e456                	sd	s5,8(sp)
    80001f3c:	0080                	addi	s0,sp,64
    80001f3e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f40:	0000e497          	auipc	s1,0xe
    80001f44:	e7848493          	addi	s1,s1,-392 # 8000fdb8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f48:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f4a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f4c:	00014917          	auipc	s2,0x14
    80001f50:	a6c90913          	addi	s2,s2,-1428 # 800159b8 <tickslock>
    80001f54:	a801                	j	80001f64 <wakeup+0x38>
      }
      release(&p->lock);
    80001f56:	8526                	mv	a0,s1
    80001f58:	d0ffe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f5c:	17048493          	addi	s1,s1,368
    80001f60:	03248263          	beq	s1,s2,80001f84 <wakeup+0x58>
    if(p != myproc()){
    80001f64:	96bff0ef          	jal	800018ce <myproc>
    80001f68:	fea48ae3          	beq	s1,a0,80001f5c <wakeup+0x30>
      acquire(&p->lock);
    80001f6c:	8526                	mv	a0,s1
    80001f6e:	c61fe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f72:	4c9c                	lw	a5,24(s1)
    80001f74:	ff3791e3          	bne	a5,s3,80001f56 <wakeup+0x2a>
    80001f78:	709c                	ld	a5,32(s1)
    80001f7a:	fd479ee3          	bne	a5,s4,80001f56 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f7e:	0154ac23          	sw	s5,24(s1)
    80001f82:	bfd1                	j	80001f56 <wakeup+0x2a>
    }
  }
}
    80001f84:	70e2                	ld	ra,56(sp)
    80001f86:	7442                	ld	s0,48(sp)
    80001f88:	74a2                	ld	s1,40(sp)
    80001f8a:	7902                	ld	s2,32(sp)
    80001f8c:	69e2                	ld	s3,24(sp)
    80001f8e:	6a42                	ld	s4,16(sp)
    80001f90:	6aa2                	ld	s5,8(sp)
    80001f92:	6121                	addi	sp,sp,64
    80001f94:	8082                	ret

0000000080001f96 <reparent>:
{
    80001f96:	7179                	addi	sp,sp,-48
    80001f98:	f406                	sd	ra,40(sp)
    80001f9a:	f022                	sd	s0,32(sp)
    80001f9c:	ec26                	sd	s1,24(sp)
    80001f9e:	e84a                	sd	s2,16(sp)
    80001fa0:	e44e                	sd	s3,8(sp)
    80001fa2:	e052                	sd	s4,0(sp)
    80001fa4:	1800                	addi	s0,sp,48
    80001fa6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fa8:	0000e497          	auipc	s1,0xe
    80001fac:	e1048493          	addi	s1,s1,-496 # 8000fdb8 <proc>
      pp->parent = initproc;
    80001fb0:	00006a17          	auipc	s4,0x6
    80001fb4:	8d0a0a13          	addi	s4,s4,-1840 # 80007880 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fb8:	00014997          	auipc	s3,0x14
    80001fbc:	a0098993          	addi	s3,s3,-1536 # 800159b8 <tickslock>
    80001fc0:	a029                	j	80001fca <reparent+0x34>
    80001fc2:	17048493          	addi	s1,s1,368
    80001fc6:	01348b63          	beq	s1,s3,80001fdc <reparent+0x46>
    if(pp->parent == p){
    80001fca:	7c9c                	ld	a5,56(s1)
    80001fcc:	ff279be3          	bne	a5,s2,80001fc2 <reparent+0x2c>
      pp->parent = initproc;
    80001fd0:	000a3503          	ld	a0,0(s4)
    80001fd4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fd6:	f57ff0ef          	jal	80001f2c <wakeup>
    80001fda:	b7e5                	j	80001fc2 <reparent+0x2c>
}
    80001fdc:	70a2                	ld	ra,40(sp)
    80001fde:	7402                	ld	s0,32(sp)
    80001fe0:	64e2                	ld	s1,24(sp)
    80001fe2:	6942                	ld	s2,16(sp)
    80001fe4:	69a2                	ld	s3,8(sp)
    80001fe6:	6a02                	ld	s4,0(sp)
    80001fe8:	6145                	addi	sp,sp,48
    80001fea:	8082                	ret

0000000080001fec <kexit>:
{
    80001fec:	7179                	addi	sp,sp,-48
    80001fee:	f406                	sd	ra,40(sp)
    80001ff0:	f022                	sd	s0,32(sp)
    80001ff2:	ec26                	sd	s1,24(sp)
    80001ff4:	e84a                	sd	s2,16(sp)
    80001ff6:	e44e                	sd	s3,8(sp)
    80001ff8:	e052                	sd	s4,0(sp)
    80001ffa:	1800                	addi	s0,sp,48
    80001ffc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001ffe:	8d1ff0ef          	jal	800018ce <myproc>
    80002002:	89aa                	mv	s3,a0
  if(p == initproc)
    80002004:	00006797          	auipc	a5,0x6
    80002008:	87c7b783          	ld	a5,-1924(a5) # 80007880 <initproc>
    8000200c:	0d050493          	addi	s1,a0,208
    80002010:	15050913          	addi	s2,a0,336
    80002014:	00a79f63          	bne	a5,a0,80002032 <kexit+0x46>
    panic("init exiting");
    80002018:	00005517          	auipc	a0,0x5
    8000201c:	1c050513          	addi	a0,a0,448 # 800071d8 <etext+0x1d8>
    80002020:	fc0fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002024:	7e1010ef          	jal	80004004 <fileclose>
      p->ofile[fd] = 0;
    80002028:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000202c:	04a1                	addi	s1,s1,8
    8000202e:	01248563          	beq	s1,s2,80002038 <kexit+0x4c>
    if(p->ofile[fd]){
    80002032:	6088                	ld	a0,0(s1)
    80002034:	f965                	bnez	a0,80002024 <kexit+0x38>
    80002036:	bfdd                	j	8000202c <kexit+0x40>
  begin_op();
    80002038:	3c1010ef          	jal	80003bf8 <begin_op>
  iput(p->cwd);
    8000203c:	1509b503          	ld	a0,336(s3)
    80002040:	350010ef          	jal	80003390 <iput>
  end_op();
    80002044:	41f010ef          	jal	80003c62 <end_op>
  p->cwd = 0;
    80002048:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000204c:	0000e497          	auipc	s1,0xe
    80002050:	95448493          	addi	s1,s1,-1708 # 8000f9a0 <wait_lock>
    80002054:	8526                	mv	a0,s1
    80002056:	b79fe0ef          	jal	80000bce <acquire>
  reparent(p);
    8000205a:	854e                	mv	a0,s3
    8000205c:	f3bff0ef          	jal	80001f96 <reparent>
  wakeup(p->parent);
    80002060:	0389b503          	ld	a0,56(s3)
    80002064:	ec9ff0ef          	jal	80001f2c <wakeup>
  acquire(&p->lock);
    80002068:	854e                	mv	a0,s3
    8000206a:	b65fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    8000206e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002072:	4795                	li	a5,5
    80002074:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002078:	8526                	mv	a0,s1
    8000207a:	bedfe0ef          	jal	80000c66 <release>
  sched();
    8000207e:	d7dff0ef          	jal	80001dfa <sched>
  panic("zombie exit");
    80002082:	00005517          	auipc	a0,0x5
    80002086:	16650513          	addi	a0,a0,358 # 800071e8 <etext+0x1e8>
    8000208a:	f56fe0ef          	jal	800007e0 <panic>

000000008000208e <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    8000208e:	7179                	addi	sp,sp,-48
    80002090:	f406                	sd	ra,40(sp)
    80002092:	f022                	sd	s0,32(sp)
    80002094:	ec26                	sd	s1,24(sp)
    80002096:	e84a                	sd	s2,16(sp)
    80002098:	e44e                	sd	s3,8(sp)
    8000209a:	1800                	addi	s0,sp,48
    8000209c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000209e:	0000e497          	auipc	s1,0xe
    800020a2:	d1a48493          	addi	s1,s1,-742 # 8000fdb8 <proc>
    800020a6:	00014997          	auipc	s3,0x14
    800020aa:	91298993          	addi	s3,s3,-1774 # 800159b8 <tickslock>
    acquire(&p->lock);
    800020ae:	8526                	mv	a0,s1
    800020b0:	b1ffe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    800020b4:	589c                	lw	a5,48(s1)
    800020b6:	01278b63          	beq	a5,s2,800020cc <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020ba:	8526                	mv	a0,s1
    800020bc:	babfe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020c0:	17048493          	addi	s1,s1,368
    800020c4:	ff3495e3          	bne	s1,s3,800020ae <kkill+0x20>
  }
  return -1;
    800020c8:	557d                	li	a0,-1
    800020ca:	a819                	j	800020e0 <kkill+0x52>
      p->killed = 1;
    800020cc:	4785                	li	a5,1
    800020ce:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020d0:	4c98                	lw	a4,24(s1)
    800020d2:	4789                	li	a5,2
    800020d4:	00f70d63          	beq	a4,a5,800020ee <kkill+0x60>
      release(&p->lock);
    800020d8:	8526                	mv	a0,s1
    800020da:	b8dfe0ef          	jal	80000c66 <release>
      return 0;
    800020de:	4501                	li	a0,0
}
    800020e0:	70a2                	ld	ra,40(sp)
    800020e2:	7402                	ld	s0,32(sp)
    800020e4:	64e2                	ld	s1,24(sp)
    800020e6:	6942                	ld	s2,16(sp)
    800020e8:	69a2                	ld	s3,8(sp)
    800020ea:	6145                	addi	sp,sp,48
    800020ec:	8082                	ret
        p->state = RUNNABLE;
    800020ee:	478d                	li	a5,3
    800020f0:	cc9c                	sw	a5,24(s1)
    800020f2:	b7dd                	j	800020d8 <kkill+0x4a>

00000000800020f4 <setkilled>:

void
setkilled(struct proc *p)
{
    800020f4:	1101                	addi	sp,sp,-32
    800020f6:	ec06                	sd	ra,24(sp)
    800020f8:	e822                	sd	s0,16(sp)
    800020fa:	e426                	sd	s1,8(sp)
    800020fc:	1000                	addi	s0,sp,32
    800020fe:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002100:	acffe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    80002104:	4785                	li	a5,1
    80002106:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002108:	8526                	mv	a0,s1
    8000210a:	b5dfe0ef          	jal	80000c66 <release>
}
    8000210e:	60e2                	ld	ra,24(sp)
    80002110:	6442                	ld	s0,16(sp)
    80002112:	64a2                	ld	s1,8(sp)
    80002114:	6105                	addi	sp,sp,32
    80002116:	8082                	ret

0000000080002118 <killed>:

int
killed(struct proc *p)
{
    80002118:	1101                	addi	sp,sp,-32
    8000211a:	ec06                	sd	ra,24(sp)
    8000211c:	e822                	sd	s0,16(sp)
    8000211e:	e426                	sd	s1,8(sp)
    80002120:	e04a                	sd	s2,0(sp)
    80002122:	1000                	addi	s0,sp,32
    80002124:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002126:	aa9fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    8000212a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000212e:	8526                	mv	a0,s1
    80002130:	b37fe0ef          	jal	80000c66 <release>
  return k;
}
    80002134:	854a                	mv	a0,s2
    80002136:	60e2                	ld	ra,24(sp)
    80002138:	6442                	ld	s0,16(sp)
    8000213a:	64a2                	ld	s1,8(sp)
    8000213c:	6902                	ld	s2,0(sp)
    8000213e:	6105                	addi	sp,sp,32
    80002140:	8082                	ret

0000000080002142 <kwait>:
{
    80002142:	715d                	addi	sp,sp,-80
    80002144:	e486                	sd	ra,72(sp)
    80002146:	e0a2                	sd	s0,64(sp)
    80002148:	fc26                	sd	s1,56(sp)
    8000214a:	f84a                	sd	s2,48(sp)
    8000214c:	f44e                	sd	s3,40(sp)
    8000214e:	f052                	sd	s4,32(sp)
    80002150:	ec56                	sd	s5,24(sp)
    80002152:	e85a                	sd	s6,16(sp)
    80002154:	e45e                	sd	s7,8(sp)
    80002156:	e062                	sd	s8,0(sp)
    80002158:	0880                	addi	s0,sp,80
    8000215a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000215c:	f72ff0ef          	jal	800018ce <myproc>
    80002160:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002162:	0000e517          	auipc	a0,0xe
    80002166:	83e50513          	addi	a0,a0,-1986 # 8000f9a0 <wait_lock>
    8000216a:	a65fe0ef          	jal	80000bce <acquire>
    havekids = 0;
    8000216e:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002170:	4a15                	li	s4,5
        havekids = 1;
    80002172:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002174:	00014997          	auipc	s3,0x14
    80002178:	84498993          	addi	s3,s3,-1980 # 800159b8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000217c:	0000ec17          	auipc	s8,0xe
    80002180:	824c0c13          	addi	s8,s8,-2012 # 8000f9a0 <wait_lock>
    80002184:	a871                	j	80002220 <kwait+0xde>
          pid = pp->pid;
    80002186:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000218a:	000b0c63          	beqz	s6,800021a2 <kwait+0x60>
    8000218e:	4691                	li	a3,4
    80002190:	02c48613          	addi	a2,s1,44
    80002194:	85da                	mv	a1,s6
    80002196:	05093503          	ld	a0,80(s2)
    8000219a:	c48ff0ef          	jal	800015e2 <copyout>
    8000219e:	02054b63          	bltz	a0,800021d4 <kwait+0x92>
          freeproc(pp);
    800021a2:	8526                	mv	a0,s1
    800021a4:	8fbff0ef          	jal	80001a9e <freeproc>
          release(&pp->lock);
    800021a8:	8526                	mv	a0,s1
    800021aa:	abdfe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    800021ae:	0000d517          	auipc	a0,0xd
    800021b2:	7f250513          	addi	a0,a0,2034 # 8000f9a0 <wait_lock>
    800021b6:	ab1fe0ef          	jal	80000c66 <release>
}
    800021ba:	854e                	mv	a0,s3
    800021bc:	60a6                	ld	ra,72(sp)
    800021be:	6406                	ld	s0,64(sp)
    800021c0:	74e2                	ld	s1,56(sp)
    800021c2:	7942                	ld	s2,48(sp)
    800021c4:	79a2                	ld	s3,40(sp)
    800021c6:	7a02                	ld	s4,32(sp)
    800021c8:	6ae2                	ld	s5,24(sp)
    800021ca:	6b42                	ld	s6,16(sp)
    800021cc:	6ba2                	ld	s7,8(sp)
    800021ce:	6c02                	ld	s8,0(sp)
    800021d0:	6161                	addi	sp,sp,80
    800021d2:	8082                	ret
            release(&pp->lock);
    800021d4:	8526                	mv	a0,s1
    800021d6:	a91fe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800021da:	0000d517          	auipc	a0,0xd
    800021de:	7c650513          	addi	a0,a0,1990 # 8000f9a0 <wait_lock>
    800021e2:	a85fe0ef          	jal	80000c66 <release>
            return -1;
    800021e6:	59fd                	li	s3,-1
    800021e8:	bfc9                	j	800021ba <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ea:	17048493          	addi	s1,s1,368
    800021ee:	03348063          	beq	s1,s3,8000220e <kwait+0xcc>
      if(pp->parent == p){
    800021f2:	7c9c                	ld	a5,56(s1)
    800021f4:	ff279be3          	bne	a5,s2,800021ea <kwait+0xa8>
        acquire(&pp->lock);
    800021f8:	8526                	mv	a0,s1
    800021fa:	9d5fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    800021fe:	4c9c                	lw	a5,24(s1)
    80002200:	f94783e3          	beq	a5,s4,80002186 <kwait+0x44>
        release(&pp->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	a61fe0ef          	jal	80000c66 <release>
        havekids = 1;
    8000220a:	8756                	mv	a4,s5
    8000220c:	bff9                	j	800021ea <kwait+0xa8>
    if(!havekids || killed(p)){
    8000220e:	cf19                	beqz	a4,8000222c <kwait+0xea>
    80002210:	854a                	mv	a0,s2
    80002212:	f07ff0ef          	jal	80002118 <killed>
    80002216:	e919                	bnez	a0,8000222c <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002218:	85e2                	mv	a1,s8
    8000221a:	854a                	mv	a0,s2
    8000221c:	cc5ff0ef          	jal	80001ee0 <sleep>
    havekids = 0;
    80002220:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002222:	0000e497          	auipc	s1,0xe
    80002226:	b9648493          	addi	s1,s1,-1130 # 8000fdb8 <proc>
    8000222a:	b7e1                	j	800021f2 <kwait+0xb0>
      release(&wait_lock);
    8000222c:	0000d517          	auipc	a0,0xd
    80002230:	77450513          	addi	a0,a0,1908 # 8000f9a0 <wait_lock>
    80002234:	a33fe0ef          	jal	80000c66 <release>
      return -1;
    80002238:	59fd                	li	s3,-1
    8000223a:	b741                	j	800021ba <kwait+0x78>

000000008000223c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000223c:	7179                	addi	sp,sp,-48
    8000223e:	f406                	sd	ra,40(sp)
    80002240:	f022                	sd	s0,32(sp)
    80002242:	ec26                	sd	s1,24(sp)
    80002244:	e84a                	sd	s2,16(sp)
    80002246:	e44e                	sd	s3,8(sp)
    80002248:	e052                	sd	s4,0(sp)
    8000224a:	1800                	addi	s0,sp,48
    8000224c:	84aa                	mv	s1,a0
    8000224e:	892e                	mv	s2,a1
    80002250:	89b2                	mv	s3,a2
    80002252:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002254:	e7aff0ef          	jal	800018ce <myproc>
  if(user_dst){
    80002258:	cc99                	beqz	s1,80002276 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000225a:	86d2                	mv	a3,s4
    8000225c:	864e                	mv	a2,s3
    8000225e:	85ca                	mv	a1,s2
    80002260:	6928                	ld	a0,80(a0)
    80002262:	b80ff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002266:	70a2                	ld	ra,40(sp)
    80002268:	7402                	ld	s0,32(sp)
    8000226a:	64e2                	ld	s1,24(sp)
    8000226c:	6942                	ld	s2,16(sp)
    8000226e:	69a2                	ld	s3,8(sp)
    80002270:	6a02                	ld	s4,0(sp)
    80002272:	6145                	addi	sp,sp,48
    80002274:	8082                	ret
    memmove((char *)dst, src, len);
    80002276:	000a061b          	sext.w	a2,s4
    8000227a:	85ce                	mv	a1,s3
    8000227c:	854a                	mv	a0,s2
    8000227e:	a81fe0ef          	jal	80000cfe <memmove>
    return 0;
    80002282:	8526                	mv	a0,s1
    80002284:	b7cd                	j	80002266 <either_copyout+0x2a>

0000000080002286 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002286:	7179                	addi	sp,sp,-48
    80002288:	f406                	sd	ra,40(sp)
    8000228a:	f022                	sd	s0,32(sp)
    8000228c:	ec26                	sd	s1,24(sp)
    8000228e:	e84a                	sd	s2,16(sp)
    80002290:	e44e                	sd	s3,8(sp)
    80002292:	e052                	sd	s4,0(sp)
    80002294:	1800                	addi	s0,sp,48
    80002296:	892a                	mv	s2,a0
    80002298:	84ae                	mv	s1,a1
    8000229a:	89b2                	mv	s3,a2
    8000229c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000229e:	e30ff0ef          	jal	800018ce <myproc>
  if(user_src){
    800022a2:	cc99                	beqz	s1,800022c0 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022a4:	86d2                	mv	a3,s4
    800022a6:	864e                	mv	a2,s3
    800022a8:	85ca                	mv	a1,s2
    800022aa:	6928                	ld	a0,80(a0)
    800022ac:	c1aff0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022b0:	70a2                	ld	ra,40(sp)
    800022b2:	7402                	ld	s0,32(sp)
    800022b4:	64e2                	ld	s1,24(sp)
    800022b6:	6942                	ld	s2,16(sp)
    800022b8:	69a2                	ld	s3,8(sp)
    800022ba:	6a02                	ld	s4,0(sp)
    800022bc:	6145                	addi	sp,sp,48
    800022be:	8082                	ret
    memmove(dst, (char*)src, len);
    800022c0:	000a061b          	sext.w	a2,s4
    800022c4:	85ce                	mv	a1,s3
    800022c6:	854a                	mv	a0,s2
    800022c8:	a37fe0ef          	jal	80000cfe <memmove>
    return 0;
    800022cc:	8526                	mv	a0,s1
    800022ce:	b7cd                	j	800022b0 <either_copyin+0x2a>

00000000800022d0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022d0:	715d                	addi	sp,sp,-80
    800022d2:	e486                	sd	ra,72(sp)
    800022d4:	e0a2                	sd	s0,64(sp)
    800022d6:	fc26                	sd	s1,56(sp)
    800022d8:	f84a                	sd	s2,48(sp)
    800022da:	f44e                	sd	s3,40(sp)
    800022dc:	f052                	sd	s4,32(sp)
    800022de:	ec56                	sd	s5,24(sp)
    800022e0:	e85a                	sd	s6,16(sp)
    800022e2:	e45e                	sd	s7,8(sp)
    800022e4:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022e6:	00005517          	auipc	a0,0x5
    800022ea:	0c250513          	addi	a0,a0,194 # 800073a8 <etext+0x3a8>
    800022ee:	a0cfe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022f2:	0000e497          	auipc	s1,0xe
    800022f6:	c2648493          	addi	s1,s1,-986 # 8000ff18 <proc+0x160>
    800022fa:	00014917          	auipc	s2,0x14
    800022fe:	81e90913          	addi	s2,s2,-2018 # 80015b18 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002302:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002304:	00005997          	auipc	s3,0x5
    80002308:	ef498993          	addi	s3,s3,-268 # 800071f8 <etext+0x1f8>
    printf("%d %s %s", p->pid, state, p->name);
    8000230c:	00005a97          	auipc	s5,0x5
    80002310:	ef4a8a93          	addi	s5,s5,-268 # 80007200 <etext+0x200>
    printf("\n");
    80002314:	00005a17          	auipc	s4,0x5
    80002318:	094a0a13          	addi	s4,s4,148 # 800073a8 <etext+0x3a8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000231c:	00005b97          	auipc	s7,0x5
    80002320:	42cb8b93          	addi	s7,s7,1068 # 80007748 <states.0>
    80002324:	a829                	j	8000233e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002326:	ed06a583          	lw	a1,-304(a3)
    8000232a:	8556                	mv	a0,s5
    8000232c:	9cefe0ef          	jal	800004fa <printf>
    printf("\n");
    80002330:	8552                	mv	a0,s4
    80002332:	9c8fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002336:	17048493          	addi	s1,s1,368
    8000233a:	03248263          	beq	s1,s2,8000235e <procdump+0x8e>
    if(p->state == UNUSED)
    8000233e:	86a6                	mv	a3,s1
    80002340:	eb84a783          	lw	a5,-328(s1)
    80002344:	dbed                	beqz	a5,80002336 <procdump+0x66>
      state = "???";
    80002346:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002348:	fcfb6fe3          	bltu	s6,a5,80002326 <procdump+0x56>
    8000234c:	02079713          	slli	a4,a5,0x20
    80002350:	01d75793          	srli	a5,a4,0x1d
    80002354:	97de                	add	a5,a5,s7
    80002356:	6390                	ld	a2,0(a5)
    80002358:	f679                	bnez	a2,80002326 <procdump+0x56>
      state = "???";
    8000235a:	864e                	mv	a2,s3
    8000235c:	b7e9                	j	80002326 <procdump+0x56>
  }
}
    8000235e:	60a6                	ld	ra,72(sp)
    80002360:	6406                	ld	s0,64(sp)
    80002362:	74e2                	ld	s1,56(sp)
    80002364:	7942                	ld	s2,48(sp)
    80002366:	79a2                	ld	s3,40(sp)
    80002368:	7a02                	ld	s4,32(sp)
    8000236a:	6ae2                	ld	s5,24(sp)
    8000236c:	6b42                	ld	s6,16(sp)
    8000236e:	6ba2                	ld	s7,8(sp)
    80002370:	6161                	addi	sp,sp,80
    80002372:	8082                	ret

0000000080002374 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002374:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002378:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000237c:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000237e:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002380:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002384:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002388:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000238c:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002390:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002394:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002398:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000239c:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023a0:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800023a4:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023a8:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023ac:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023b0:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800023b2:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023b4:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023b8:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023bc:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023c0:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023c4:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023c8:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023cc:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023d0:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800023d4:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023d8:	0685bd83          	ld	s11,104(a1)
        
        ret
    800023dc:	8082                	ret

00000000800023de <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023de:	1141                	addi	sp,sp,-16
    800023e0:	e406                	sd	ra,8(sp)
    800023e2:	e022                	sd	s0,0(sp)
    800023e4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023e6:	00005597          	auipc	a1,0x5
    800023ea:	e5a58593          	addi	a1,a1,-422 # 80007240 <etext+0x240>
    800023ee:	00013517          	auipc	a0,0x13
    800023f2:	5ca50513          	addi	a0,a0,1482 # 800159b8 <tickslock>
    800023f6:	f58fe0ef          	jal	80000b4e <initlock>
}
    800023fa:	60a2                	ld	ra,8(sp)
    800023fc:	6402                	ld	s0,0(sp)
    800023fe:	0141                	addi	sp,sp,16
    80002400:	8082                	ret

0000000080002402 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002402:	1141                	addi	sp,sp,-16
    80002404:	e422                	sd	s0,8(sp)
    80002406:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002408:	00003797          	auipc	a5,0x3
    8000240c:	f7878793          	addi	a5,a5,-136 # 80005380 <kernelvec>
    80002410:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002414:	6422                	ld	s0,8(sp)
    80002416:	0141                	addi	sp,sp,16
    80002418:	8082                	ret

000000008000241a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000241a:	1141                	addi	sp,sp,-16
    8000241c:	e406                	sd	ra,8(sp)
    8000241e:	e022                	sd	s0,0(sp)
    80002420:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002422:	cacff0ef          	jal	800018ce <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002426:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000242a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000242c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002430:	04000737          	lui	a4,0x4000
    80002434:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002436:	0732                	slli	a4,a4,0xc
    80002438:	00004797          	auipc	a5,0x4
    8000243c:	bc878793          	addi	a5,a5,-1080 # 80006000 <_trampoline>
    80002440:	00004697          	auipc	a3,0x4
    80002444:	bc068693          	addi	a3,a3,-1088 # 80006000 <_trampoline>
    80002448:	8f95                	sub	a5,a5,a3
    8000244a:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000244c:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002450:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002452:	18002773          	csrr	a4,satp
    80002456:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002458:	6d38                	ld	a4,88(a0)
    8000245a:	613c                	ld	a5,64(a0)
    8000245c:	6685                	lui	a3,0x1
    8000245e:	97b6                	add	a5,a5,a3
    80002460:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002462:	6d3c                	ld	a5,88(a0)
    80002464:	00000717          	auipc	a4,0x0
    80002468:	0f870713          	addi	a4,a4,248 # 8000255c <usertrap>
    8000246c:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000246e:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002470:	8712                	mv	a4,tp
    80002472:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002474:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002478:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000247c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002480:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002484:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002486:	6f9c                	ld	a5,24(a5)
    80002488:	14179073          	csrw	sepc,a5
}
    8000248c:	60a2                	ld	ra,8(sp)
    8000248e:	6402                	ld	s0,0(sp)
    80002490:	0141                	addi	sp,sp,16
    80002492:	8082                	ret

0000000080002494 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002494:	1101                	addi	sp,sp,-32
    80002496:	ec06                	sd	ra,24(sp)
    80002498:	e822                	sd	s0,16(sp)
    8000249a:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000249c:	c06ff0ef          	jal	800018a2 <cpuid>
    800024a0:	cd11                	beqz	a0,800024bc <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024a2:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024a6:	000f4737          	lui	a4,0xf4
    800024aa:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024ae:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024b0:	14d79073          	csrw	stimecmp,a5
}
    800024b4:	60e2                	ld	ra,24(sp)
    800024b6:	6442                	ld	s0,16(sp)
    800024b8:	6105                	addi	sp,sp,32
    800024ba:	8082                	ret
    800024bc:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024be:	00013497          	auipc	s1,0x13
    800024c2:	4fa48493          	addi	s1,s1,1274 # 800159b8 <tickslock>
    800024c6:	8526                	mv	a0,s1
    800024c8:	f06fe0ef          	jal	80000bce <acquire>
    ticks++;
    800024cc:	00005517          	auipc	a0,0x5
    800024d0:	3bc50513          	addi	a0,a0,956 # 80007888 <ticks>
    800024d4:	411c                	lw	a5,0(a0)
    800024d6:	2785                	addiw	a5,a5,1
    800024d8:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024da:	a53ff0ef          	jal	80001f2c <wakeup>
    release(&tickslock);
    800024de:	8526                	mv	a0,s1
    800024e0:	f86fe0ef          	jal	80000c66 <release>
    800024e4:	64a2                	ld	s1,8(sp)
    800024e6:	bf75                	j	800024a2 <clockintr+0xe>

00000000800024e8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024e8:	1101                	addi	sp,sp,-32
    800024ea:	ec06                	sd	ra,24(sp)
    800024ec:	e822                	sd	s0,16(sp)
    800024ee:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024f0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024f4:	57fd                	li	a5,-1
    800024f6:	17fe                	slli	a5,a5,0x3f
    800024f8:	07a5                	addi	a5,a5,9
    800024fa:	00f70c63          	beq	a4,a5,80002512 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024fe:	57fd                	li	a5,-1
    80002500:	17fe                	slli	a5,a5,0x3f
    80002502:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002504:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002506:	04f70763          	beq	a4,a5,80002554 <devintr+0x6c>
  }
}
    8000250a:	60e2                	ld	ra,24(sp)
    8000250c:	6442                	ld	s0,16(sp)
    8000250e:	6105                	addi	sp,sp,32
    80002510:	8082                	ret
    80002512:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002514:	719020ef          	jal	8000542c <plic_claim>
    80002518:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000251a:	47a9                	li	a5,10
    8000251c:	00f50963          	beq	a0,a5,8000252e <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002520:	4785                	li	a5,1
    80002522:	00f50963          	beq	a0,a5,80002534 <devintr+0x4c>
    return 1;
    80002526:	4505                	li	a0,1
    } else if(irq){
    80002528:	e889                	bnez	s1,8000253a <devintr+0x52>
    8000252a:	64a2                	ld	s1,8(sp)
    8000252c:	bff9                	j	8000250a <devintr+0x22>
      uartintr();
    8000252e:	c82fe0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002532:	a819                	j	80002548 <devintr+0x60>
      virtio_disk_intr();
    80002534:	3be030ef          	jal	800058f2 <virtio_disk_intr>
    if(irq)
    80002538:	a801                	j	80002548 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000253a:	85a6                	mv	a1,s1
    8000253c:	00005517          	auipc	a0,0x5
    80002540:	d0c50513          	addi	a0,a0,-756 # 80007248 <etext+0x248>
    80002544:	fb7fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002548:	8526                	mv	a0,s1
    8000254a:	703020ef          	jal	8000544c <plic_complete>
    return 1;
    8000254e:	4505                	li	a0,1
    80002550:	64a2                	ld	s1,8(sp)
    80002552:	bf65                	j	8000250a <devintr+0x22>
    clockintr();
    80002554:	f41ff0ef          	jal	80002494 <clockintr>
    return 2;
    80002558:	4509                	li	a0,2
    8000255a:	bf45                	j	8000250a <devintr+0x22>

000000008000255c <usertrap>:
{
    8000255c:	1101                	addi	sp,sp,-32
    8000255e:	ec06                	sd	ra,24(sp)
    80002560:	e822                	sd	s0,16(sp)
    80002562:	e426                	sd	s1,8(sp)
    80002564:	e04a                	sd	s2,0(sp)
    80002566:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002568:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000256c:	1007f793          	andi	a5,a5,256
    80002570:	eba5                	bnez	a5,800025e0 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002572:	00003797          	auipc	a5,0x3
    80002576:	e0e78793          	addi	a5,a5,-498 # 80005380 <kernelvec>
    8000257a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000257e:	b50ff0ef          	jal	800018ce <myproc>
    80002582:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002584:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002586:	14102773          	csrr	a4,sepc
    8000258a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000258c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002590:	47a1                	li	a5,8
    80002592:	04f70d63          	beq	a4,a5,800025ec <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002596:	f53ff0ef          	jal	800024e8 <devintr>
    8000259a:	892a                	mv	s2,a0
    8000259c:	e945                	bnez	a0,8000264c <usertrap+0xf0>
    8000259e:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800025a2:	47bd                	li	a5,15
    800025a4:	08f70863          	beq	a4,a5,80002634 <usertrap+0xd8>
    800025a8:	14202773          	csrr	a4,scause
    800025ac:	47b5                	li	a5,13
    800025ae:	08f70363          	beq	a4,a5,80002634 <usertrap+0xd8>
    800025b2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025b6:	5890                	lw	a2,48(s1)
    800025b8:	00005517          	auipc	a0,0x5
    800025bc:	cd050513          	addi	a0,a0,-816 # 80007288 <etext+0x288>
    800025c0:	f3bfd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025c4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025c8:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025cc:	00005517          	auipc	a0,0x5
    800025d0:	cec50513          	addi	a0,a0,-788 # 800072b8 <etext+0x2b8>
    800025d4:	f27fd0ef          	jal	800004fa <printf>
    setkilled(p);
    800025d8:	8526                	mv	a0,s1
    800025da:	b1bff0ef          	jal	800020f4 <setkilled>
    800025de:	a035                	j	8000260a <usertrap+0xae>
    panic("usertrap: not from user mode");
    800025e0:	00005517          	auipc	a0,0x5
    800025e4:	c8850513          	addi	a0,a0,-888 # 80007268 <etext+0x268>
    800025e8:	9f8fe0ef          	jal	800007e0 <panic>
    if(killed(p))
    800025ec:	b2dff0ef          	jal	80002118 <killed>
    800025f0:	ed15                	bnez	a0,8000262c <usertrap+0xd0>
    p->trapframe->epc += 4;
    800025f2:	6cb8                	ld	a4,88(s1)
    800025f4:	6f1c                	ld	a5,24(a4)
    800025f6:	0791                	addi	a5,a5,4
    800025f8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025fe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002602:	10079073          	csrw	sstatus,a5
    syscall();
    80002606:	246000ef          	jal	8000284c <syscall>
  if(killed(p))
    8000260a:	8526                	mv	a0,s1
    8000260c:	b0dff0ef          	jal	80002118 <killed>
    80002610:	e139                	bnez	a0,80002656 <usertrap+0xfa>
  prepare_return();
    80002612:	e09ff0ef          	jal	8000241a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002616:	68a8                	ld	a0,80(s1)
    80002618:	8131                	srli	a0,a0,0xc
    8000261a:	57fd                	li	a5,-1
    8000261c:	17fe                	slli	a5,a5,0x3f
    8000261e:	8d5d                	or	a0,a0,a5
}
    80002620:	60e2                	ld	ra,24(sp)
    80002622:	6442                	ld	s0,16(sp)
    80002624:	64a2                	ld	s1,8(sp)
    80002626:	6902                	ld	s2,0(sp)
    80002628:	6105                	addi	sp,sp,32
    8000262a:	8082                	ret
      kexit(-1);
    8000262c:	557d                	li	a0,-1
    8000262e:	9bfff0ef          	jal	80001fec <kexit>
    80002632:	b7c1                	j	800025f2 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002634:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002638:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    8000263c:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    8000263e:	00163613          	seqz	a2,a2
    80002642:	68a8                	ld	a0,80(s1)
    80002644:	f1dfe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002648:	f169                	bnez	a0,8000260a <usertrap+0xae>
    8000264a:	b7a5                	j	800025b2 <usertrap+0x56>
  if(killed(p))
    8000264c:	8526                	mv	a0,s1
    8000264e:	acbff0ef          	jal	80002118 <killed>
    80002652:	c511                	beqz	a0,8000265e <usertrap+0x102>
    80002654:	a011                	j	80002658 <usertrap+0xfc>
    80002656:	4901                	li	s2,0
    kexit(-1);
    80002658:	557d                	li	a0,-1
    8000265a:	993ff0ef          	jal	80001fec <kexit>
  if(which_dev == 2)
    8000265e:	4789                	li	a5,2
    80002660:	faf919e3          	bne	s2,a5,80002612 <usertrap+0xb6>
    yield();
    80002664:	851ff0ef          	jal	80001eb4 <yield>
    80002668:	b76d                	j	80002612 <usertrap+0xb6>

000000008000266a <kerneltrap>:
{
    8000266a:	7179                	addi	sp,sp,-48
    8000266c:	f406                	sd	ra,40(sp)
    8000266e:	f022                	sd	s0,32(sp)
    80002670:	ec26                	sd	s1,24(sp)
    80002672:	e84a                	sd	s2,16(sp)
    80002674:	e44e                	sd	s3,8(sp)
    80002676:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002678:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000267c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002680:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002684:	1004f793          	andi	a5,s1,256
    80002688:	c795                	beqz	a5,800026b4 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000268a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000268e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002690:	eb85                	bnez	a5,800026c0 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002692:	e57ff0ef          	jal	800024e8 <devintr>
    80002696:	c91d                	beqz	a0,800026cc <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002698:	4789                	li	a5,2
    8000269a:	04f50a63          	beq	a0,a5,800026ee <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000269e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026a2:	10049073          	csrw	sstatus,s1
}
    800026a6:	70a2                	ld	ra,40(sp)
    800026a8:	7402                	ld	s0,32(sp)
    800026aa:	64e2                	ld	s1,24(sp)
    800026ac:	6942                	ld	s2,16(sp)
    800026ae:	69a2                	ld	s3,8(sp)
    800026b0:	6145                	addi	sp,sp,48
    800026b2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026b4:	00005517          	auipc	a0,0x5
    800026b8:	c2c50513          	addi	a0,a0,-980 # 800072e0 <etext+0x2e0>
    800026bc:	924fe0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    800026c0:	00005517          	auipc	a0,0x5
    800026c4:	c4850513          	addi	a0,a0,-952 # 80007308 <etext+0x308>
    800026c8:	918fe0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026cc:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026d0:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026d4:	85ce                	mv	a1,s3
    800026d6:	00005517          	auipc	a0,0x5
    800026da:	c5250513          	addi	a0,a0,-942 # 80007328 <etext+0x328>
    800026de:	e1dfd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800026e2:	00005517          	auipc	a0,0x5
    800026e6:	c6e50513          	addi	a0,a0,-914 # 80007350 <etext+0x350>
    800026ea:	8f6fe0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    800026ee:	9e0ff0ef          	jal	800018ce <myproc>
    800026f2:	d555                	beqz	a0,8000269e <kerneltrap+0x34>
    yield();
    800026f4:	fc0ff0ef          	jal	80001eb4 <yield>
    800026f8:	b75d                	j	8000269e <kerneltrap+0x34>

00000000800026fa <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026fa:	1101                	addi	sp,sp,-32
    800026fc:	ec06                	sd	ra,24(sp)
    800026fe:	e822                	sd	s0,16(sp)
    80002700:	e426                	sd	s1,8(sp)
    80002702:	1000                	addi	s0,sp,32
    80002704:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002706:	9c8ff0ef          	jal	800018ce <myproc>
  switch (n) {
    8000270a:	4795                	li	a5,5
    8000270c:	0497e163          	bltu	a5,s1,8000274e <argraw+0x54>
    80002710:	048a                	slli	s1,s1,0x2
    80002712:	00005717          	auipc	a4,0x5
    80002716:	06670713          	addi	a4,a4,102 # 80007778 <states.0+0x30>
    8000271a:	94ba                	add	s1,s1,a4
    8000271c:	409c                	lw	a5,0(s1)
    8000271e:	97ba                	add	a5,a5,a4
    80002720:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002722:	6d3c                	ld	a5,88(a0)
    80002724:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002726:	60e2                	ld	ra,24(sp)
    80002728:	6442                	ld	s0,16(sp)
    8000272a:	64a2                	ld	s1,8(sp)
    8000272c:	6105                	addi	sp,sp,32
    8000272e:	8082                	ret
    return p->trapframe->a1;
    80002730:	6d3c                	ld	a5,88(a0)
    80002732:	7fa8                	ld	a0,120(a5)
    80002734:	bfcd                	j	80002726 <argraw+0x2c>
    return p->trapframe->a2;
    80002736:	6d3c                	ld	a5,88(a0)
    80002738:	63c8                	ld	a0,128(a5)
    8000273a:	b7f5                	j	80002726 <argraw+0x2c>
    return p->trapframe->a3;
    8000273c:	6d3c                	ld	a5,88(a0)
    8000273e:	67c8                	ld	a0,136(a5)
    80002740:	b7dd                	j	80002726 <argraw+0x2c>
    return p->trapframe->a4;
    80002742:	6d3c                	ld	a5,88(a0)
    80002744:	6bc8                	ld	a0,144(a5)
    80002746:	b7c5                	j	80002726 <argraw+0x2c>
    return p->trapframe->a5;
    80002748:	6d3c                	ld	a5,88(a0)
    8000274a:	6fc8                	ld	a0,152(a5)
    8000274c:	bfe9                	j	80002726 <argraw+0x2c>
  panic("argraw");
    8000274e:	00005517          	auipc	a0,0x5
    80002752:	c1250513          	addi	a0,a0,-1006 # 80007360 <etext+0x360>
    80002756:	88afe0ef          	jal	800007e0 <panic>

000000008000275a <fetchaddr>:
{
    8000275a:	1101                	addi	sp,sp,-32
    8000275c:	ec06                	sd	ra,24(sp)
    8000275e:	e822                	sd	s0,16(sp)
    80002760:	e426                	sd	s1,8(sp)
    80002762:	e04a                	sd	s2,0(sp)
    80002764:	1000                	addi	s0,sp,32
    80002766:	84aa                	mv	s1,a0
    80002768:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000276a:	964ff0ef          	jal	800018ce <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000276e:	653c                	ld	a5,72(a0)
    80002770:	02f4f663          	bgeu	s1,a5,8000279c <fetchaddr+0x42>
    80002774:	00848713          	addi	a4,s1,8
    80002778:	02e7e463          	bltu	a5,a4,800027a0 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000277c:	46a1                	li	a3,8
    8000277e:	8626                	mv	a2,s1
    80002780:	85ca                	mv	a1,s2
    80002782:	6928                	ld	a0,80(a0)
    80002784:	f43fe0ef          	jal	800016c6 <copyin>
    80002788:	00a03533          	snez	a0,a0
    8000278c:	40a00533          	neg	a0,a0
}
    80002790:	60e2                	ld	ra,24(sp)
    80002792:	6442                	ld	s0,16(sp)
    80002794:	64a2                	ld	s1,8(sp)
    80002796:	6902                	ld	s2,0(sp)
    80002798:	6105                	addi	sp,sp,32
    8000279a:	8082                	ret
    return -1;
    8000279c:	557d                	li	a0,-1
    8000279e:	bfcd                	j	80002790 <fetchaddr+0x36>
    800027a0:	557d                	li	a0,-1
    800027a2:	b7fd                	j	80002790 <fetchaddr+0x36>

00000000800027a4 <fetchstr>:
{
    800027a4:	7179                	addi	sp,sp,-48
    800027a6:	f406                	sd	ra,40(sp)
    800027a8:	f022                	sd	s0,32(sp)
    800027aa:	ec26                	sd	s1,24(sp)
    800027ac:	e84a                	sd	s2,16(sp)
    800027ae:	e44e                	sd	s3,8(sp)
    800027b0:	1800                	addi	s0,sp,48
    800027b2:	892a                	mv	s2,a0
    800027b4:	84ae                	mv	s1,a1
    800027b6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027b8:	916ff0ef          	jal	800018ce <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027bc:	86ce                	mv	a3,s3
    800027be:	864a                	mv	a2,s2
    800027c0:	85a6                	mv	a1,s1
    800027c2:	6928                	ld	a0,80(a0)
    800027c4:	cc5fe0ef          	jal	80001488 <copyinstr>
    800027c8:	00054c63          	bltz	a0,800027e0 <fetchstr+0x3c>
  return strlen(buf);
    800027cc:	8526                	mv	a0,s1
    800027ce:	e44fe0ef          	jal	80000e12 <strlen>
}
    800027d2:	70a2                	ld	ra,40(sp)
    800027d4:	7402                	ld	s0,32(sp)
    800027d6:	64e2                	ld	s1,24(sp)
    800027d8:	6942                	ld	s2,16(sp)
    800027da:	69a2                	ld	s3,8(sp)
    800027dc:	6145                	addi	sp,sp,48
    800027de:	8082                	ret
    return -1;
    800027e0:	557d                	li	a0,-1
    800027e2:	bfc5                	j	800027d2 <fetchstr+0x2e>

00000000800027e4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027e4:	1101                	addi	sp,sp,-32
    800027e6:	ec06                	sd	ra,24(sp)
    800027e8:	e822                	sd	s0,16(sp)
    800027ea:	e426                	sd	s1,8(sp)
    800027ec:	1000                	addi	s0,sp,32
    800027ee:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027f0:	f0bff0ef          	jal	800026fa <argraw>
    800027f4:	c088                	sw	a0,0(s1)
}
    800027f6:	60e2                	ld	ra,24(sp)
    800027f8:	6442                	ld	s0,16(sp)
    800027fa:	64a2                	ld	s1,8(sp)
    800027fc:	6105                	addi	sp,sp,32
    800027fe:	8082                	ret

0000000080002800 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002800:	1101                	addi	sp,sp,-32
    80002802:	ec06                	sd	ra,24(sp)
    80002804:	e822                	sd	s0,16(sp)
    80002806:	e426                	sd	s1,8(sp)
    80002808:	1000                	addi	s0,sp,32
    8000280a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000280c:	eefff0ef          	jal	800026fa <argraw>
    80002810:	e088                	sd	a0,0(s1)
}
    80002812:	60e2                	ld	ra,24(sp)
    80002814:	6442                	ld	s0,16(sp)
    80002816:	64a2                	ld	s1,8(sp)
    80002818:	6105                	addi	sp,sp,32
    8000281a:	8082                	ret

000000008000281c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000281c:	7179                	addi	sp,sp,-48
    8000281e:	f406                	sd	ra,40(sp)
    80002820:	f022                	sd	s0,32(sp)
    80002822:	ec26                	sd	s1,24(sp)
    80002824:	e84a                	sd	s2,16(sp)
    80002826:	1800                	addi	s0,sp,48
    80002828:	84ae                	mv	s1,a1
    8000282a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000282c:	fd840593          	addi	a1,s0,-40
    80002830:	fd1ff0ef          	jal	80002800 <argaddr>
  return fetchstr(addr, buf, max);
    80002834:	864a                	mv	a2,s2
    80002836:	85a6                	mv	a1,s1
    80002838:	fd843503          	ld	a0,-40(s0)
    8000283c:	f69ff0ef          	jal	800027a4 <fetchstr>
}
    80002840:	70a2                	ld	ra,40(sp)
    80002842:	7402                	ld	s0,32(sp)
    80002844:	64e2                	ld	s1,24(sp)
    80002846:	6942                	ld	s2,16(sp)
    80002848:	6145                	addi	sp,sp,48
    8000284a:	8082                	ret

000000008000284c <syscall>:
[SYS_hello]   sys_hello,
};

// Trong kernel/syscall.c
void
syscall(void)
{
    8000284c:	1101                	addi	sp,sp,-32
    8000284e:	ec06                	sd	ra,24(sp)
    80002850:	e822                	sd	s0,16(sp)
    80002852:	e426                	sd	s1,8(sp)
    80002854:	e04a                	sd	s2,0(sp)
    80002856:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002858:	876ff0ef          	jal	800018ce <myproc>
    8000285c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000285e:	05853903          	ld	s2,88(a0)
    80002862:	0a893783          	ld	a5,168(s2)
    80002866:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000286a:	37fd                	addiw	a5,a5,-1
    8000286c:	4755                	li	a4,21
    8000286e:	00f76f63          	bltu	a4,a5,8000288c <syscall+0x40>
    80002872:	00369713          	slli	a4,a3,0x3
    80002876:	00005797          	auipc	a5,0x5
    8000287a:	f1a78793          	addi	a5,a5,-230 # 80007790 <syscalls>
    8000287e:	97ba                	add	a5,a5,a4
    80002880:	639c                	ld	a5,0(a5)
    80002882:	c789                	beqz	a5,8000288c <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002884:	9782                	jalr	a5
    80002886:	06a93823          	sd	a0,112(s2)
    8000288a:	a829                	j	800028a4 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000288c:	16048613          	addi	a2,s1,352
    80002890:	588c                	lw	a1,48(s1)
    80002892:	00005517          	auipc	a0,0x5
    80002896:	ad650513          	addi	a0,a0,-1322 # 80007368 <etext+0x368>
    8000289a:	c61fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000289e:	6cbc                	ld	a5,88(s1)
    800028a0:	577d                	li	a4,-1
    800028a2:	fbb8                	sd	a4,112(a5)
  }
}
    800028a4:	60e2                	ld	ra,24(sp)
    800028a6:	6442                	ld	s0,16(sp)
    800028a8:	64a2                	ld	s1,8(sp)
    800028aa:	6902                	ld	s2,0(sp)
    800028ac:	6105                	addi	sp,sp,32
    800028ae:	8082                	ret

00000000800028b0 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800028b0:	1101                	addi	sp,sp,-32
    800028b2:	ec06                	sd	ra,24(sp)
    800028b4:	e822                	sd	s0,16(sp)
    800028b6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028b8:	fec40593          	addi	a1,s0,-20
    800028bc:	4501                	li	a0,0
    800028be:	f27ff0ef          	jal	800027e4 <argint>
  kexit(n);
    800028c2:	fec42503          	lw	a0,-20(s0)
    800028c6:	f26ff0ef          	jal	80001fec <kexit>
  return 0;  // not reached
}
    800028ca:	4501                	li	a0,0
    800028cc:	60e2                	ld	ra,24(sp)
    800028ce:	6442                	ld	s0,16(sp)
    800028d0:	6105                	addi	sp,sp,32
    800028d2:	8082                	ret

00000000800028d4 <sys_getpid>:

uint64
sys_getpid(void)
{
    800028d4:	1141                	addi	sp,sp,-16
    800028d6:	e406                	sd	ra,8(sp)
    800028d8:	e022                	sd	s0,0(sp)
    800028da:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028dc:	ff3fe0ef          	jal	800018ce <myproc>
}
    800028e0:	5908                	lw	a0,48(a0)
    800028e2:	60a2                	ld	ra,8(sp)
    800028e4:	6402                	ld	s0,0(sp)
    800028e6:	0141                	addi	sp,sp,16
    800028e8:	8082                	ret

00000000800028ea <sys_fork>:

uint64
sys_fork(void)
{
    800028ea:	1141                	addi	sp,sp,-16
    800028ec:	e406                	sd	ra,8(sp)
    800028ee:	e022                	sd	s0,0(sp)
    800028f0:	0800                	addi	s0,sp,16
  return kfork();
    800028f2:	b48ff0ef          	jal	80001c3a <kfork>
}
    800028f6:	60a2                	ld	ra,8(sp)
    800028f8:	6402                	ld	s0,0(sp)
    800028fa:	0141                	addi	sp,sp,16
    800028fc:	8082                	ret

00000000800028fe <sys_wait>:

uint64
sys_wait(void)
{
    800028fe:	1101                	addi	sp,sp,-32
    80002900:	ec06                	sd	ra,24(sp)
    80002902:	e822                	sd	s0,16(sp)
    80002904:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002906:	fe840593          	addi	a1,s0,-24
    8000290a:	4501                	li	a0,0
    8000290c:	ef5ff0ef          	jal	80002800 <argaddr>
  return kwait(p);
    80002910:	fe843503          	ld	a0,-24(s0)
    80002914:	82fff0ef          	jal	80002142 <kwait>
}
    80002918:	60e2                	ld	ra,24(sp)
    8000291a:	6442                	ld	s0,16(sp)
    8000291c:	6105                	addi	sp,sp,32
    8000291e:	8082                	ret

0000000080002920 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002920:	7179                	addi	sp,sp,-48
    80002922:	f406                	sd	ra,40(sp)
    80002924:	f022                	sd	s0,32(sp)
    80002926:	ec26                	sd	s1,24(sp)
    80002928:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    8000292a:	fd840593          	addi	a1,s0,-40
    8000292e:	4501                	li	a0,0
    80002930:	eb5ff0ef          	jal	800027e4 <argint>
  argint(1, &t);
    80002934:	fdc40593          	addi	a1,s0,-36
    80002938:	4505                	li	a0,1
    8000293a:	eabff0ef          	jal	800027e4 <argint>
  addr = myproc()->sz;
    8000293e:	f91fe0ef          	jal	800018ce <myproc>
    80002942:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002944:	fdc42703          	lw	a4,-36(s0)
    80002948:	4785                	li	a5,1
    8000294a:	02f70763          	beq	a4,a5,80002978 <sys_sbrk+0x58>
    8000294e:	fd842783          	lw	a5,-40(s0)
    80002952:	0207c363          	bltz	a5,80002978 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002956:	97a6                	add	a5,a5,s1
    80002958:	0297ee63          	bltu	a5,s1,80002994 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    8000295c:	02000737          	lui	a4,0x2000
    80002960:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002962:	0736                	slli	a4,a4,0xd
    80002964:	02f76a63          	bltu	a4,a5,80002998 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002968:	f67fe0ef          	jal	800018ce <myproc>
    8000296c:	fd842703          	lw	a4,-40(s0)
    80002970:	653c                	ld	a5,72(a0)
    80002972:	97ba                	add	a5,a5,a4
    80002974:	e53c                	sd	a5,72(a0)
    80002976:	a039                	j	80002984 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002978:	fd842503          	lw	a0,-40(s0)
    8000297c:	a5cff0ef          	jal	80001bd8 <growproc>
    80002980:	00054863          	bltz	a0,80002990 <sys_sbrk+0x70>
  }
  return addr;
}
    80002984:	8526                	mv	a0,s1
    80002986:	70a2                	ld	ra,40(sp)
    80002988:	7402                	ld	s0,32(sp)
    8000298a:	64e2                	ld	s1,24(sp)
    8000298c:	6145                	addi	sp,sp,48
    8000298e:	8082                	ret
      return -1;
    80002990:	54fd                	li	s1,-1
    80002992:	bfcd                	j	80002984 <sys_sbrk+0x64>
      return -1;
    80002994:	54fd                	li	s1,-1
    80002996:	b7fd                	j	80002984 <sys_sbrk+0x64>
      return -1;
    80002998:	54fd                	li	s1,-1
    8000299a:	b7ed                	j	80002984 <sys_sbrk+0x64>

000000008000299c <sys_pause>:

uint64
sys_pause(void)
{
    8000299c:	7139                	addi	sp,sp,-64
    8000299e:	fc06                	sd	ra,56(sp)
    800029a0:	f822                	sd	s0,48(sp)
    800029a2:	f04a                	sd	s2,32(sp)
    800029a4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029a6:	fcc40593          	addi	a1,s0,-52
    800029aa:	4501                	li	a0,0
    800029ac:	e39ff0ef          	jal	800027e4 <argint>
  if(n < 0)
    800029b0:	fcc42783          	lw	a5,-52(s0)
    800029b4:	0607c763          	bltz	a5,80002a22 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029b8:	00013517          	auipc	a0,0x13
    800029bc:	00050513          	mv	a0,a0
    800029c0:	a0efe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    800029c4:	00005917          	auipc	s2,0x5
    800029c8:	ec492903          	lw	s2,-316(s2) # 80007888 <ticks>
  while(ticks - ticks0 < n){
    800029cc:	fcc42783          	lw	a5,-52(s0)
    800029d0:	cf8d                	beqz	a5,80002a0a <sys_pause+0x6e>
    800029d2:	f426                	sd	s1,40(sp)
    800029d4:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029d6:	00013997          	auipc	s3,0x13
    800029da:	fe298993          	addi	s3,s3,-30 # 800159b8 <tickslock>
    800029de:	00005497          	auipc	s1,0x5
    800029e2:	eaa48493          	addi	s1,s1,-342 # 80007888 <ticks>
    if(killed(myproc())){
    800029e6:	ee9fe0ef          	jal	800018ce <myproc>
    800029ea:	f2eff0ef          	jal	80002118 <killed>
    800029ee:	ed0d                	bnez	a0,80002a28 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800029f0:	85ce                	mv	a1,s3
    800029f2:	8526                	mv	a0,s1
    800029f4:	cecff0ef          	jal	80001ee0 <sleep>
  while(ticks - ticks0 < n){
    800029f8:	409c                	lw	a5,0(s1)
    800029fa:	412787bb          	subw	a5,a5,s2
    800029fe:	fcc42703          	lw	a4,-52(s0)
    80002a02:	fee7e2e3          	bltu	a5,a4,800029e6 <sys_pause+0x4a>
    80002a06:	74a2                	ld	s1,40(sp)
    80002a08:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a0a:	00013517          	auipc	a0,0x13
    80002a0e:	fae50513          	addi	a0,a0,-82 # 800159b8 <tickslock>
    80002a12:	a54fe0ef          	jal	80000c66 <release>
  return 0;
    80002a16:	4501                	li	a0,0
}
    80002a18:	70e2                	ld	ra,56(sp)
    80002a1a:	7442                	ld	s0,48(sp)
    80002a1c:	7902                	ld	s2,32(sp)
    80002a1e:	6121                	addi	sp,sp,64
    80002a20:	8082                	ret
    n = 0;
    80002a22:	fc042623          	sw	zero,-52(s0)
    80002a26:	bf49                	j	800029b8 <sys_pause+0x1c>
      release(&tickslock);
    80002a28:	00013517          	auipc	a0,0x13
    80002a2c:	f9050513          	addi	a0,a0,-112 # 800159b8 <tickslock>
    80002a30:	a36fe0ef          	jal	80000c66 <release>
      return -1;
    80002a34:	557d                	li	a0,-1
    80002a36:	74a2                	ld	s1,40(sp)
    80002a38:	69e2                	ld	s3,24(sp)
    80002a3a:	bff9                	j	80002a18 <sys_pause+0x7c>

0000000080002a3c <sys_kill>:

uint64
sys_kill(void)
{
    80002a3c:	1101                	addi	sp,sp,-32
    80002a3e:	ec06                	sd	ra,24(sp)
    80002a40:	e822                	sd	s0,16(sp)
    80002a42:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a44:	fec40593          	addi	a1,s0,-20
    80002a48:	4501                	li	a0,0
    80002a4a:	d9bff0ef          	jal	800027e4 <argint>
  return kkill(pid);
    80002a4e:	fec42503          	lw	a0,-20(s0)
    80002a52:	e3cff0ef          	jal	8000208e <kkill>
}
    80002a56:	60e2                	ld	ra,24(sp)
    80002a58:	6442                	ld	s0,16(sp)
    80002a5a:	6105                	addi	sp,sp,32
    80002a5c:	8082                	ret

0000000080002a5e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a5e:	1101                	addi	sp,sp,-32
    80002a60:	ec06                	sd	ra,24(sp)
    80002a62:	e822                	sd	s0,16(sp)
    80002a64:	e426                	sd	s1,8(sp)
    80002a66:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a68:	00013517          	auipc	a0,0x13
    80002a6c:	f5050513          	addi	a0,a0,-176 # 800159b8 <tickslock>
    80002a70:	95efe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002a74:	00005497          	auipc	s1,0x5
    80002a78:	e144a483          	lw	s1,-492(s1) # 80007888 <ticks>
  release(&tickslock);
    80002a7c:	00013517          	auipc	a0,0x13
    80002a80:	f3c50513          	addi	a0,a0,-196 # 800159b8 <tickslock>
    80002a84:	9e2fe0ef          	jal	80000c66 <release>
  return xticks;
}
    80002a88:	02049513          	slli	a0,s1,0x20
    80002a8c:	9101                	srli	a0,a0,0x20
    80002a8e:	60e2                	ld	ra,24(sp)
    80002a90:	6442                	ld	s0,16(sp)
    80002a92:	64a2                	ld	s1,8(sp)
    80002a94:	6105                	addi	sp,sp,32
    80002a96:	8082                	ret

0000000080002a98 <sys_hello>:
uint64
sys_hello(void)
{
    80002a98:	1141                	addi	sp,sp,-16
    80002a9a:	e406                	sd	ra,8(sp)
    80002a9c:	e022                	sd	s0,0(sp)
    80002a9e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002aa0:	e2ffe0ef          	jal	800018ce <myproc>
  printf("kernel: hello() called by pid %d\n", p->pid);
    80002aa4:	590c                	lw	a1,48(a0)
    80002aa6:	00005517          	auipc	a0,0x5
    80002aaa:	8e250513          	addi	a0,a0,-1822 # 80007388 <etext+0x388>
    80002aae:	a4dfd0ef          	jal	800004fa <printf>
  return 0;
}
    80002ab2:	4501                	li	a0,0
    80002ab4:	60a2                	ld	ra,8(sp)
    80002ab6:	6402                	ld	s0,0(sp)
    80002ab8:	0141                	addi	sp,sp,16
    80002aba:	8082                	ret

0000000080002abc <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002abc:	7179                	addi	sp,sp,-48
    80002abe:	f406                	sd	ra,40(sp)
    80002ac0:	f022                	sd	s0,32(sp)
    80002ac2:	ec26                	sd	s1,24(sp)
    80002ac4:	e84a                	sd	s2,16(sp)
    80002ac6:	e44e                	sd	s3,8(sp)
    80002ac8:	e052                	sd	s4,0(sp)
    80002aca:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002acc:	00005597          	auipc	a1,0x5
    80002ad0:	8e458593          	addi	a1,a1,-1820 # 800073b0 <etext+0x3b0>
    80002ad4:	00013517          	auipc	a0,0x13
    80002ad8:	efc50513          	addi	a0,a0,-260 # 800159d0 <bcache>
    80002adc:	872fe0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ae0:	0001b797          	auipc	a5,0x1b
    80002ae4:	ef078793          	addi	a5,a5,-272 # 8001d9d0 <bcache+0x8000>
    80002ae8:	0001b717          	auipc	a4,0x1b
    80002aec:	15070713          	addi	a4,a4,336 # 8001dc38 <bcache+0x8268>
    80002af0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002af4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002af8:	00013497          	auipc	s1,0x13
    80002afc:	ef048493          	addi	s1,s1,-272 # 800159e8 <bcache+0x18>
    b->next = bcache.head.next;
    80002b00:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b02:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b04:	00005a17          	auipc	s4,0x5
    80002b08:	8b4a0a13          	addi	s4,s4,-1868 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002b0c:	2b893783          	ld	a5,696(s2)
    80002b10:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b12:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b16:	85d2                	mv	a1,s4
    80002b18:	01048513          	addi	a0,s1,16
    80002b1c:	322010ef          	jal	80003e3e <initsleeplock>
    bcache.head.next->prev = b;
    80002b20:	2b893783          	ld	a5,696(s2)
    80002b24:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b26:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b2a:	45848493          	addi	s1,s1,1112
    80002b2e:	fd349fe3          	bne	s1,s3,80002b0c <binit+0x50>
  }
}
    80002b32:	70a2                	ld	ra,40(sp)
    80002b34:	7402                	ld	s0,32(sp)
    80002b36:	64e2                	ld	s1,24(sp)
    80002b38:	6942                	ld	s2,16(sp)
    80002b3a:	69a2                	ld	s3,8(sp)
    80002b3c:	6a02                	ld	s4,0(sp)
    80002b3e:	6145                	addi	sp,sp,48
    80002b40:	8082                	ret

0000000080002b42 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b42:	7179                	addi	sp,sp,-48
    80002b44:	f406                	sd	ra,40(sp)
    80002b46:	f022                	sd	s0,32(sp)
    80002b48:	ec26                	sd	s1,24(sp)
    80002b4a:	e84a                	sd	s2,16(sp)
    80002b4c:	e44e                	sd	s3,8(sp)
    80002b4e:	1800                	addi	s0,sp,48
    80002b50:	892a                	mv	s2,a0
    80002b52:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b54:	00013517          	auipc	a0,0x13
    80002b58:	e7c50513          	addi	a0,a0,-388 # 800159d0 <bcache>
    80002b5c:	872fe0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b60:	0001b497          	auipc	s1,0x1b
    80002b64:	1284b483          	ld	s1,296(s1) # 8001dc88 <bcache+0x82b8>
    80002b68:	0001b797          	auipc	a5,0x1b
    80002b6c:	0d078793          	addi	a5,a5,208 # 8001dc38 <bcache+0x8268>
    80002b70:	02f48b63          	beq	s1,a5,80002ba6 <bread+0x64>
    80002b74:	873e                	mv	a4,a5
    80002b76:	a021                	j	80002b7e <bread+0x3c>
    80002b78:	68a4                	ld	s1,80(s1)
    80002b7a:	02e48663          	beq	s1,a4,80002ba6 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002b7e:	449c                	lw	a5,8(s1)
    80002b80:	ff279ce3          	bne	a5,s2,80002b78 <bread+0x36>
    80002b84:	44dc                	lw	a5,12(s1)
    80002b86:	ff3799e3          	bne	a5,s3,80002b78 <bread+0x36>
      b->refcnt++;
    80002b8a:	40bc                	lw	a5,64(s1)
    80002b8c:	2785                	addiw	a5,a5,1
    80002b8e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b90:	00013517          	auipc	a0,0x13
    80002b94:	e4050513          	addi	a0,a0,-448 # 800159d0 <bcache>
    80002b98:	8cefe0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002b9c:	01048513          	addi	a0,s1,16
    80002ba0:	2d4010ef          	jal	80003e74 <acquiresleep>
      return b;
    80002ba4:	a889                	j	80002bf6 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ba6:	0001b497          	auipc	s1,0x1b
    80002baa:	0da4b483          	ld	s1,218(s1) # 8001dc80 <bcache+0x82b0>
    80002bae:	0001b797          	auipc	a5,0x1b
    80002bb2:	08a78793          	addi	a5,a5,138 # 8001dc38 <bcache+0x8268>
    80002bb6:	00f48863          	beq	s1,a5,80002bc6 <bread+0x84>
    80002bba:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002bbc:	40bc                	lw	a5,64(s1)
    80002bbe:	cb91                	beqz	a5,80002bd2 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bc0:	64a4                	ld	s1,72(s1)
    80002bc2:	fee49de3          	bne	s1,a4,80002bbc <bread+0x7a>
  panic("bget: no buffers");
    80002bc6:	00004517          	auipc	a0,0x4
    80002bca:	7fa50513          	addi	a0,a0,2042 # 800073c0 <etext+0x3c0>
    80002bce:	c13fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002bd2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002bd6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002bda:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002bde:	4785                	li	a5,1
    80002be0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002be2:	00013517          	auipc	a0,0x13
    80002be6:	dee50513          	addi	a0,a0,-530 # 800159d0 <bcache>
    80002bea:	87cfe0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002bee:	01048513          	addi	a0,s1,16
    80002bf2:	282010ef          	jal	80003e74 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002bf6:	409c                	lw	a5,0(s1)
    80002bf8:	cb89                	beqz	a5,80002c0a <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002bfa:	8526                	mv	a0,s1
    80002bfc:	70a2                	ld	ra,40(sp)
    80002bfe:	7402                	ld	s0,32(sp)
    80002c00:	64e2                	ld	s1,24(sp)
    80002c02:	6942                	ld	s2,16(sp)
    80002c04:	69a2                	ld	s3,8(sp)
    80002c06:	6145                	addi	sp,sp,48
    80002c08:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c0a:	4581                	li	a1,0
    80002c0c:	8526                	mv	a0,s1
    80002c0e:	2d3020ef          	jal	800056e0 <virtio_disk_rw>
    b->valid = 1;
    80002c12:	4785                	li	a5,1
    80002c14:	c09c                	sw	a5,0(s1)
  return b;
    80002c16:	b7d5                	j	80002bfa <bread+0xb8>

0000000080002c18 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c18:	1101                	addi	sp,sp,-32
    80002c1a:	ec06                	sd	ra,24(sp)
    80002c1c:	e822                	sd	s0,16(sp)
    80002c1e:	e426                	sd	s1,8(sp)
    80002c20:	1000                	addi	s0,sp,32
    80002c22:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c24:	0541                	addi	a0,a0,16
    80002c26:	2cc010ef          	jal	80003ef2 <holdingsleep>
    80002c2a:	c911                	beqz	a0,80002c3e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c2c:	4585                	li	a1,1
    80002c2e:	8526                	mv	a0,s1
    80002c30:	2b1020ef          	jal	800056e0 <virtio_disk_rw>
}
    80002c34:	60e2                	ld	ra,24(sp)
    80002c36:	6442                	ld	s0,16(sp)
    80002c38:	64a2                	ld	s1,8(sp)
    80002c3a:	6105                	addi	sp,sp,32
    80002c3c:	8082                	ret
    panic("bwrite");
    80002c3e:	00004517          	auipc	a0,0x4
    80002c42:	79a50513          	addi	a0,a0,1946 # 800073d8 <etext+0x3d8>
    80002c46:	b9bfd0ef          	jal	800007e0 <panic>

0000000080002c4a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c4a:	1101                	addi	sp,sp,-32
    80002c4c:	ec06                	sd	ra,24(sp)
    80002c4e:	e822                	sd	s0,16(sp)
    80002c50:	e426                	sd	s1,8(sp)
    80002c52:	e04a                	sd	s2,0(sp)
    80002c54:	1000                	addi	s0,sp,32
    80002c56:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c58:	01050913          	addi	s2,a0,16
    80002c5c:	854a                	mv	a0,s2
    80002c5e:	294010ef          	jal	80003ef2 <holdingsleep>
    80002c62:	c135                	beqz	a0,80002cc6 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002c64:	854a                	mv	a0,s2
    80002c66:	254010ef          	jal	80003eba <releasesleep>

  acquire(&bcache.lock);
    80002c6a:	00013517          	auipc	a0,0x13
    80002c6e:	d6650513          	addi	a0,a0,-666 # 800159d0 <bcache>
    80002c72:	f5dfd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002c76:	40bc                	lw	a5,64(s1)
    80002c78:	37fd                	addiw	a5,a5,-1
    80002c7a:	0007871b          	sext.w	a4,a5
    80002c7e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c80:	e71d                	bnez	a4,80002cae <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c82:	68b8                	ld	a4,80(s1)
    80002c84:	64bc                	ld	a5,72(s1)
    80002c86:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c88:	68b8                	ld	a4,80(s1)
    80002c8a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c8c:	0001b797          	auipc	a5,0x1b
    80002c90:	d4478793          	addi	a5,a5,-700 # 8001d9d0 <bcache+0x8000>
    80002c94:	2b87b703          	ld	a4,696(a5)
    80002c98:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c9a:	0001b717          	auipc	a4,0x1b
    80002c9e:	f9e70713          	addi	a4,a4,-98 # 8001dc38 <bcache+0x8268>
    80002ca2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ca4:	2b87b703          	ld	a4,696(a5)
    80002ca8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002caa:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002cae:	00013517          	auipc	a0,0x13
    80002cb2:	d2250513          	addi	a0,a0,-734 # 800159d0 <bcache>
    80002cb6:	fb1fd0ef          	jal	80000c66 <release>
}
    80002cba:	60e2                	ld	ra,24(sp)
    80002cbc:	6442                	ld	s0,16(sp)
    80002cbe:	64a2                	ld	s1,8(sp)
    80002cc0:	6902                	ld	s2,0(sp)
    80002cc2:	6105                	addi	sp,sp,32
    80002cc4:	8082                	ret
    panic("brelse");
    80002cc6:	00004517          	auipc	a0,0x4
    80002cca:	71a50513          	addi	a0,a0,1818 # 800073e0 <etext+0x3e0>
    80002cce:	b13fd0ef          	jal	800007e0 <panic>

0000000080002cd2 <bpin>:

void
bpin(struct buf *b) {
    80002cd2:	1101                	addi	sp,sp,-32
    80002cd4:	ec06                	sd	ra,24(sp)
    80002cd6:	e822                	sd	s0,16(sp)
    80002cd8:	e426                	sd	s1,8(sp)
    80002cda:	1000                	addi	s0,sp,32
    80002cdc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cde:	00013517          	auipc	a0,0x13
    80002ce2:	cf250513          	addi	a0,a0,-782 # 800159d0 <bcache>
    80002ce6:	ee9fd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002cea:	40bc                	lw	a5,64(s1)
    80002cec:	2785                	addiw	a5,a5,1
    80002cee:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cf0:	00013517          	auipc	a0,0x13
    80002cf4:	ce050513          	addi	a0,a0,-800 # 800159d0 <bcache>
    80002cf8:	f6ffd0ef          	jal	80000c66 <release>
}
    80002cfc:	60e2                	ld	ra,24(sp)
    80002cfe:	6442                	ld	s0,16(sp)
    80002d00:	64a2                	ld	s1,8(sp)
    80002d02:	6105                	addi	sp,sp,32
    80002d04:	8082                	ret

0000000080002d06 <bunpin>:

void
bunpin(struct buf *b) {
    80002d06:	1101                	addi	sp,sp,-32
    80002d08:	ec06                	sd	ra,24(sp)
    80002d0a:	e822                	sd	s0,16(sp)
    80002d0c:	e426                	sd	s1,8(sp)
    80002d0e:	1000                	addi	s0,sp,32
    80002d10:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d12:	00013517          	auipc	a0,0x13
    80002d16:	cbe50513          	addi	a0,a0,-834 # 800159d0 <bcache>
    80002d1a:	eb5fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002d1e:	40bc                	lw	a5,64(s1)
    80002d20:	37fd                	addiw	a5,a5,-1
    80002d22:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d24:	00013517          	auipc	a0,0x13
    80002d28:	cac50513          	addi	a0,a0,-852 # 800159d0 <bcache>
    80002d2c:	f3bfd0ef          	jal	80000c66 <release>
}
    80002d30:	60e2                	ld	ra,24(sp)
    80002d32:	6442                	ld	s0,16(sp)
    80002d34:	64a2                	ld	s1,8(sp)
    80002d36:	6105                	addi	sp,sp,32
    80002d38:	8082                	ret

0000000080002d3a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d3a:	1101                	addi	sp,sp,-32
    80002d3c:	ec06                	sd	ra,24(sp)
    80002d3e:	e822                	sd	s0,16(sp)
    80002d40:	e426                	sd	s1,8(sp)
    80002d42:	e04a                	sd	s2,0(sp)
    80002d44:	1000                	addi	s0,sp,32
    80002d46:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d48:	00d5d59b          	srliw	a1,a1,0xd
    80002d4c:	0001b797          	auipc	a5,0x1b
    80002d50:	3607a783          	lw	a5,864(a5) # 8001e0ac <sb+0x1c>
    80002d54:	9dbd                	addw	a1,a1,a5
    80002d56:	dedff0ef          	jal	80002b42 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d5a:	0074f713          	andi	a4,s1,7
    80002d5e:	4785                	li	a5,1
    80002d60:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002d64:	14ce                	slli	s1,s1,0x33
    80002d66:	90d9                	srli	s1,s1,0x36
    80002d68:	00950733          	add	a4,a0,s1
    80002d6c:	05874703          	lbu	a4,88(a4)
    80002d70:	00e7f6b3          	and	a3,a5,a4
    80002d74:	c29d                	beqz	a3,80002d9a <bfree+0x60>
    80002d76:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002d78:	94aa                	add	s1,s1,a0
    80002d7a:	fff7c793          	not	a5,a5
    80002d7e:	8f7d                	and	a4,a4,a5
    80002d80:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d84:	7f9000ef          	jal	80003d7c <log_write>
  brelse(bp);
    80002d88:	854a                	mv	a0,s2
    80002d8a:	ec1ff0ef          	jal	80002c4a <brelse>
}
    80002d8e:	60e2                	ld	ra,24(sp)
    80002d90:	6442                	ld	s0,16(sp)
    80002d92:	64a2                	ld	s1,8(sp)
    80002d94:	6902                	ld	s2,0(sp)
    80002d96:	6105                	addi	sp,sp,32
    80002d98:	8082                	ret
    panic("freeing free block");
    80002d9a:	00004517          	auipc	a0,0x4
    80002d9e:	64e50513          	addi	a0,a0,1614 # 800073e8 <etext+0x3e8>
    80002da2:	a3ffd0ef          	jal	800007e0 <panic>

0000000080002da6 <balloc>:
{
    80002da6:	711d                	addi	sp,sp,-96
    80002da8:	ec86                	sd	ra,88(sp)
    80002daa:	e8a2                	sd	s0,80(sp)
    80002dac:	e4a6                	sd	s1,72(sp)
    80002dae:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002db0:	0001b797          	auipc	a5,0x1b
    80002db4:	2e47a783          	lw	a5,740(a5) # 8001e094 <sb+0x4>
    80002db8:	0e078f63          	beqz	a5,80002eb6 <balloc+0x110>
    80002dbc:	e0ca                	sd	s2,64(sp)
    80002dbe:	fc4e                	sd	s3,56(sp)
    80002dc0:	f852                	sd	s4,48(sp)
    80002dc2:	f456                	sd	s5,40(sp)
    80002dc4:	f05a                	sd	s6,32(sp)
    80002dc6:	ec5e                	sd	s7,24(sp)
    80002dc8:	e862                	sd	s8,16(sp)
    80002dca:	e466                	sd	s9,8(sp)
    80002dcc:	8baa                	mv	s7,a0
    80002dce:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002dd0:	0001bb17          	auipc	s6,0x1b
    80002dd4:	2c0b0b13          	addi	s6,s6,704 # 8001e090 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002dd8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002dda:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ddc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002dde:	6c89                	lui	s9,0x2
    80002de0:	a0b5                	j	80002e4c <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002de2:	97ca                	add	a5,a5,s2
    80002de4:	8e55                	or	a2,a2,a3
    80002de6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002dea:	854a                	mv	a0,s2
    80002dec:	791000ef          	jal	80003d7c <log_write>
        brelse(bp);
    80002df0:	854a                	mv	a0,s2
    80002df2:	e59ff0ef          	jal	80002c4a <brelse>
  bp = bread(dev, bno);
    80002df6:	85a6                	mv	a1,s1
    80002df8:	855e                	mv	a0,s7
    80002dfa:	d49ff0ef          	jal	80002b42 <bread>
    80002dfe:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e00:	40000613          	li	a2,1024
    80002e04:	4581                	li	a1,0
    80002e06:	05850513          	addi	a0,a0,88
    80002e0a:	e99fd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80002e0e:	854a                	mv	a0,s2
    80002e10:	76d000ef          	jal	80003d7c <log_write>
  brelse(bp);
    80002e14:	854a                	mv	a0,s2
    80002e16:	e35ff0ef          	jal	80002c4a <brelse>
}
    80002e1a:	6906                	ld	s2,64(sp)
    80002e1c:	79e2                	ld	s3,56(sp)
    80002e1e:	7a42                	ld	s4,48(sp)
    80002e20:	7aa2                	ld	s5,40(sp)
    80002e22:	7b02                	ld	s6,32(sp)
    80002e24:	6be2                	ld	s7,24(sp)
    80002e26:	6c42                	ld	s8,16(sp)
    80002e28:	6ca2                	ld	s9,8(sp)
}
    80002e2a:	8526                	mv	a0,s1
    80002e2c:	60e6                	ld	ra,88(sp)
    80002e2e:	6446                	ld	s0,80(sp)
    80002e30:	64a6                	ld	s1,72(sp)
    80002e32:	6125                	addi	sp,sp,96
    80002e34:	8082                	ret
    brelse(bp);
    80002e36:	854a                	mv	a0,s2
    80002e38:	e13ff0ef          	jal	80002c4a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e3c:	015c87bb          	addw	a5,s9,s5
    80002e40:	00078a9b          	sext.w	s5,a5
    80002e44:	004b2703          	lw	a4,4(s6)
    80002e48:	04eaff63          	bgeu	s5,a4,80002ea6 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002e4c:	41fad79b          	sraiw	a5,s5,0x1f
    80002e50:	0137d79b          	srliw	a5,a5,0x13
    80002e54:	015787bb          	addw	a5,a5,s5
    80002e58:	40d7d79b          	sraiw	a5,a5,0xd
    80002e5c:	01cb2583          	lw	a1,28(s6)
    80002e60:	9dbd                	addw	a1,a1,a5
    80002e62:	855e                	mv	a0,s7
    80002e64:	cdfff0ef          	jal	80002b42 <bread>
    80002e68:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e6a:	004b2503          	lw	a0,4(s6)
    80002e6e:	000a849b          	sext.w	s1,s5
    80002e72:	8762                	mv	a4,s8
    80002e74:	fca4f1e3          	bgeu	s1,a0,80002e36 <balloc+0x90>
      m = 1 << (bi % 8);
    80002e78:	00777693          	andi	a3,a4,7
    80002e7c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002e80:	41f7579b          	sraiw	a5,a4,0x1f
    80002e84:	01d7d79b          	srliw	a5,a5,0x1d
    80002e88:	9fb9                	addw	a5,a5,a4
    80002e8a:	4037d79b          	sraiw	a5,a5,0x3
    80002e8e:	00f90633          	add	a2,s2,a5
    80002e92:	05864603          	lbu	a2,88(a2)
    80002e96:	00c6f5b3          	and	a1,a3,a2
    80002e9a:	d5a1                	beqz	a1,80002de2 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e9c:	2705                	addiw	a4,a4,1
    80002e9e:	2485                	addiw	s1,s1,1
    80002ea0:	fd471ae3          	bne	a4,s4,80002e74 <balloc+0xce>
    80002ea4:	bf49                	j	80002e36 <balloc+0x90>
    80002ea6:	6906                	ld	s2,64(sp)
    80002ea8:	79e2                	ld	s3,56(sp)
    80002eaa:	7a42                	ld	s4,48(sp)
    80002eac:	7aa2                	ld	s5,40(sp)
    80002eae:	7b02                	ld	s6,32(sp)
    80002eb0:	6be2                	ld	s7,24(sp)
    80002eb2:	6c42                	ld	s8,16(sp)
    80002eb4:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002eb6:	00004517          	auipc	a0,0x4
    80002eba:	54a50513          	addi	a0,a0,1354 # 80007400 <etext+0x400>
    80002ebe:	e3cfd0ef          	jal	800004fa <printf>
  return 0;
    80002ec2:	4481                	li	s1,0
    80002ec4:	b79d                	j	80002e2a <balloc+0x84>

0000000080002ec6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002ec6:	7179                	addi	sp,sp,-48
    80002ec8:	f406                	sd	ra,40(sp)
    80002eca:	f022                	sd	s0,32(sp)
    80002ecc:	ec26                	sd	s1,24(sp)
    80002ece:	e84a                	sd	s2,16(sp)
    80002ed0:	e44e                	sd	s3,8(sp)
    80002ed2:	1800                	addi	s0,sp,48
    80002ed4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002ed6:	47ad                	li	a5,11
    80002ed8:	02b7e663          	bltu	a5,a1,80002f04 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002edc:	02059793          	slli	a5,a1,0x20
    80002ee0:	01e7d593          	srli	a1,a5,0x1e
    80002ee4:	00b504b3          	add	s1,a0,a1
    80002ee8:	0504a903          	lw	s2,80(s1)
    80002eec:	06091a63          	bnez	s2,80002f60 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002ef0:	4108                	lw	a0,0(a0)
    80002ef2:	eb5ff0ef          	jal	80002da6 <balloc>
    80002ef6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002efa:	06090363          	beqz	s2,80002f60 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002efe:	0524a823          	sw	s2,80(s1)
    80002f02:	a8b9                	j	80002f60 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f04:	ff45849b          	addiw	s1,a1,-12
    80002f08:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002f0c:	0ff00793          	li	a5,255
    80002f10:	06e7ee63          	bltu	a5,a4,80002f8c <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f14:	08052903          	lw	s2,128(a0)
    80002f18:	00091d63          	bnez	s2,80002f32 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002f1c:	4108                	lw	a0,0(a0)
    80002f1e:	e89ff0ef          	jal	80002da6 <balloc>
    80002f22:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f26:	02090d63          	beqz	s2,80002f60 <bmap+0x9a>
    80002f2a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f2c:	0929a023          	sw	s2,128(s3)
    80002f30:	a011                	j	80002f34 <bmap+0x6e>
    80002f32:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f34:	85ca                	mv	a1,s2
    80002f36:	0009a503          	lw	a0,0(s3)
    80002f3a:	c09ff0ef          	jal	80002b42 <bread>
    80002f3e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f40:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f44:	02049713          	slli	a4,s1,0x20
    80002f48:	01e75593          	srli	a1,a4,0x1e
    80002f4c:	00b784b3          	add	s1,a5,a1
    80002f50:	0004a903          	lw	s2,0(s1)
    80002f54:	00090e63          	beqz	s2,80002f70 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f58:	8552                	mv	a0,s4
    80002f5a:	cf1ff0ef          	jal	80002c4a <brelse>
    return addr;
    80002f5e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f60:	854a                	mv	a0,s2
    80002f62:	70a2                	ld	ra,40(sp)
    80002f64:	7402                	ld	s0,32(sp)
    80002f66:	64e2                	ld	s1,24(sp)
    80002f68:	6942                	ld	s2,16(sp)
    80002f6a:	69a2                	ld	s3,8(sp)
    80002f6c:	6145                	addi	sp,sp,48
    80002f6e:	8082                	ret
      addr = balloc(ip->dev);
    80002f70:	0009a503          	lw	a0,0(s3)
    80002f74:	e33ff0ef          	jal	80002da6 <balloc>
    80002f78:	0005091b          	sext.w	s2,a0
      if(addr){
    80002f7c:	fc090ee3          	beqz	s2,80002f58 <bmap+0x92>
        a[bn] = addr;
    80002f80:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002f84:	8552                	mv	a0,s4
    80002f86:	5f7000ef          	jal	80003d7c <log_write>
    80002f8a:	b7f9                	j	80002f58 <bmap+0x92>
    80002f8c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f8e:	00004517          	auipc	a0,0x4
    80002f92:	48a50513          	addi	a0,a0,1162 # 80007418 <etext+0x418>
    80002f96:	84bfd0ef          	jal	800007e0 <panic>

0000000080002f9a <iget>:
{
    80002f9a:	7179                	addi	sp,sp,-48
    80002f9c:	f406                	sd	ra,40(sp)
    80002f9e:	f022                	sd	s0,32(sp)
    80002fa0:	ec26                	sd	s1,24(sp)
    80002fa2:	e84a                	sd	s2,16(sp)
    80002fa4:	e44e                	sd	s3,8(sp)
    80002fa6:	e052                	sd	s4,0(sp)
    80002fa8:	1800                	addi	s0,sp,48
    80002faa:	89aa                	mv	s3,a0
    80002fac:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002fae:	0001b517          	auipc	a0,0x1b
    80002fb2:	10250513          	addi	a0,a0,258 # 8001e0b0 <itable>
    80002fb6:	c19fd0ef          	jal	80000bce <acquire>
  empty = 0;
    80002fba:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fbc:	0001b497          	auipc	s1,0x1b
    80002fc0:	10c48493          	addi	s1,s1,268 # 8001e0c8 <itable+0x18>
    80002fc4:	0001d697          	auipc	a3,0x1d
    80002fc8:	b9468693          	addi	a3,a3,-1132 # 8001fb58 <log>
    80002fcc:	a039                	j	80002fda <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002fce:	02090963          	beqz	s2,80003000 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fd2:	08848493          	addi	s1,s1,136
    80002fd6:	02d48863          	beq	s1,a3,80003006 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002fda:	449c                	lw	a5,8(s1)
    80002fdc:	fef059e3          	blez	a5,80002fce <iget+0x34>
    80002fe0:	4098                	lw	a4,0(s1)
    80002fe2:	ff3716e3          	bne	a4,s3,80002fce <iget+0x34>
    80002fe6:	40d8                	lw	a4,4(s1)
    80002fe8:	ff4713e3          	bne	a4,s4,80002fce <iget+0x34>
      ip->ref++;
    80002fec:	2785                	addiw	a5,a5,1
    80002fee:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002ff0:	0001b517          	auipc	a0,0x1b
    80002ff4:	0c050513          	addi	a0,a0,192 # 8001e0b0 <itable>
    80002ff8:	c6ffd0ef          	jal	80000c66 <release>
      return ip;
    80002ffc:	8926                	mv	s2,s1
    80002ffe:	a02d                	j	80003028 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003000:	fbe9                	bnez	a5,80002fd2 <iget+0x38>
      empty = ip;
    80003002:	8926                	mv	s2,s1
    80003004:	b7f9                	j	80002fd2 <iget+0x38>
  if(empty == 0)
    80003006:	02090a63          	beqz	s2,8000303a <iget+0xa0>
  ip->dev = dev;
    8000300a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000300e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003012:	4785                	li	a5,1
    80003014:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003018:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000301c:	0001b517          	auipc	a0,0x1b
    80003020:	09450513          	addi	a0,a0,148 # 8001e0b0 <itable>
    80003024:	c43fd0ef          	jal	80000c66 <release>
}
    80003028:	854a                	mv	a0,s2
    8000302a:	70a2                	ld	ra,40(sp)
    8000302c:	7402                	ld	s0,32(sp)
    8000302e:	64e2                	ld	s1,24(sp)
    80003030:	6942                	ld	s2,16(sp)
    80003032:	69a2                	ld	s3,8(sp)
    80003034:	6a02                	ld	s4,0(sp)
    80003036:	6145                	addi	sp,sp,48
    80003038:	8082                	ret
    panic("iget: no inodes");
    8000303a:	00004517          	auipc	a0,0x4
    8000303e:	3f650513          	addi	a0,a0,1014 # 80007430 <etext+0x430>
    80003042:	f9efd0ef          	jal	800007e0 <panic>

0000000080003046 <iinit>:
{
    80003046:	7179                	addi	sp,sp,-48
    80003048:	f406                	sd	ra,40(sp)
    8000304a:	f022                	sd	s0,32(sp)
    8000304c:	ec26                	sd	s1,24(sp)
    8000304e:	e84a                	sd	s2,16(sp)
    80003050:	e44e                	sd	s3,8(sp)
    80003052:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003054:	00004597          	auipc	a1,0x4
    80003058:	3ec58593          	addi	a1,a1,1004 # 80007440 <etext+0x440>
    8000305c:	0001b517          	auipc	a0,0x1b
    80003060:	05450513          	addi	a0,a0,84 # 8001e0b0 <itable>
    80003064:	aebfd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003068:	0001b497          	auipc	s1,0x1b
    8000306c:	07048493          	addi	s1,s1,112 # 8001e0d8 <itable+0x28>
    80003070:	0001d997          	auipc	s3,0x1d
    80003074:	af898993          	addi	s3,s3,-1288 # 8001fb68 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003078:	00004917          	auipc	s2,0x4
    8000307c:	3d090913          	addi	s2,s2,976 # 80007448 <etext+0x448>
    80003080:	85ca                	mv	a1,s2
    80003082:	8526                	mv	a0,s1
    80003084:	5bb000ef          	jal	80003e3e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003088:	08848493          	addi	s1,s1,136
    8000308c:	ff349ae3          	bne	s1,s3,80003080 <iinit+0x3a>
}
    80003090:	70a2                	ld	ra,40(sp)
    80003092:	7402                	ld	s0,32(sp)
    80003094:	64e2                	ld	s1,24(sp)
    80003096:	6942                	ld	s2,16(sp)
    80003098:	69a2                	ld	s3,8(sp)
    8000309a:	6145                	addi	sp,sp,48
    8000309c:	8082                	ret

000000008000309e <ialloc>:
{
    8000309e:	7139                	addi	sp,sp,-64
    800030a0:	fc06                	sd	ra,56(sp)
    800030a2:	f822                	sd	s0,48(sp)
    800030a4:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800030a6:	0001b717          	auipc	a4,0x1b
    800030aa:	ff672703          	lw	a4,-10(a4) # 8001e09c <sb+0xc>
    800030ae:	4785                	li	a5,1
    800030b0:	06e7f063          	bgeu	a5,a4,80003110 <ialloc+0x72>
    800030b4:	f426                	sd	s1,40(sp)
    800030b6:	f04a                	sd	s2,32(sp)
    800030b8:	ec4e                	sd	s3,24(sp)
    800030ba:	e852                	sd	s4,16(sp)
    800030bc:	e456                	sd	s5,8(sp)
    800030be:	e05a                	sd	s6,0(sp)
    800030c0:	8aaa                	mv	s5,a0
    800030c2:	8b2e                	mv	s6,a1
    800030c4:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800030c6:	0001ba17          	auipc	s4,0x1b
    800030ca:	fcaa0a13          	addi	s4,s4,-54 # 8001e090 <sb>
    800030ce:	00495593          	srli	a1,s2,0x4
    800030d2:	018a2783          	lw	a5,24(s4)
    800030d6:	9dbd                	addw	a1,a1,a5
    800030d8:	8556                	mv	a0,s5
    800030da:	a69ff0ef          	jal	80002b42 <bread>
    800030de:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800030e0:	05850993          	addi	s3,a0,88
    800030e4:	00f97793          	andi	a5,s2,15
    800030e8:	079a                	slli	a5,a5,0x6
    800030ea:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800030ec:	00099783          	lh	a5,0(s3)
    800030f0:	cb9d                	beqz	a5,80003126 <ialloc+0x88>
    brelse(bp);
    800030f2:	b59ff0ef          	jal	80002c4a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800030f6:	0905                	addi	s2,s2,1
    800030f8:	00ca2703          	lw	a4,12(s4)
    800030fc:	0009079b          	sext.w	a5,s2
    80003100:	fce7e7e3          	bltu	a5,a4,800030ce <ialloc+0x30>
    80003104:	74a2                	ld	s1,40(sp)
    80003106:	7902                	ld	s2,32(sp)
    80003108:	69e2                	ld	s3,24(sp)
    8000310a:	6a42                	ld	s4,16(sp)
    8000310c:	6aa2                	ld	s5,8(sp)
    8000310e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003110:	00004517          	auipc	a0,0x4
    80003114:	34050513          	addi	a0,a0,832 # 80007450 <etext+0x450>
    80003118:	be2fd0ef          	jal	800004fa <printf>
  return 0;
    8000311c:	4501                	li	a0,0
}
    8000311e:	70e2                	ld	ra,56(sp)
    80003120:	7442                	ld	s0,48(sp)
    80003122:	6121                	addi	sp,sp,64
    80003124:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003126:	04000613          	li	a2,64
    8000312a:	4581                	li	a1,0
    8000312c:	854e                	mv	a0,s3
    8000312e:	b75fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    80003132:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003136:	8526                	mv	a0,s1
    80003138:	445000ef          	jal	80003d7c <log_write>
      brelse(bp);
    8000313c:	8526                	mv	a0,s1
    8000313e:	b0dff0ef          	jal	80002c4a <brelse>
      return iget(dev, inum);
    80003142:	0009059b          	sext.w	a1,s2
    80003146:	8556                	mv	a0,s5
    80003148:	e53ff0ef          	jal	80002f9a <iget>
    8000314c:	74a2                	ld	s1,40(sp)
    8000314e:	7902                	ld	s2,32(sp)
    80003150:	69e2                	ld	s3,24(sp)
    80003152:	6a42                	ld	s4,16(sp)
    80003154:	6aa2                	ld	s5,8(sp)
    80003156:	6b02                	ld	s6,0(sp)
    80003158:	b7d9                	j	8000311e <ialloc+0x80>

000000008000315a <iupdate>:
{
    8000315a:	1101                	addi	sp,sp,-32
    8000315c:	ec06                	sd	ra,24(sp)
    8000315e:	e822                	sd	s0,16(sp)
    80003160:	e426                	sd	s1,8(sp)
    80003162:	e04a                	sd	s2,0(sp)
    80003164:	1000                	addi	s0,sp,32
    80003166:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003168:	415c                	lw	a5,4(a0)
    8000316a:	0047d79b          	srliw	a5,a5,0x4
    8000316e:	0001b597          	auipc	a1,0x1b
    80003172:	f3a5a583          	lw	a1,-198(a1) # 8001e0a8 <sb+0x18>
    80003176:	9dbd                	addw	a1,a1,a5
    80003178:	4108                	lw	a0,0(a0)
    8000317a:	9c9ff0ef          	jal	80002b42 <bread>
    8000317e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003180:	05850793          	addi	a5,a0,88
    80003184:	40d8                	lw	a4,4(s1)
    80003186:	8b3d                	andi	a4,a4,15
    80003188:	071a                	slli	a4,a4,0x6
    8000318a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000318c:	04449703          	lh	a4,68(s1)
    80003190:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003194:	04649703          	lh	a4,70(s1)
    80003198:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000319c:	04849703          	lh	a4,72(s1)
    800031a0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800031a4:	04a49703          	lh	a4,74(s1)
    800031a8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031ac:	44f8                	lw	a4,76(s1)
    800031ae:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800031b0:	03400613          	li	a2,52
    800031b4:	05048593          	addi	a1,s1,80
    800031b8:	00c78513          	addi	a0,a5,12
    800031bc:	b43fd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    800031c0:	854a                	mv	a0,s2
    800031c2:	3bb000ef          	jal	80003d7c <log_write>
  brelse(bp);
    800031c6:	854a                	mv	a0,s2
    800031c8:	a83ff0ef          	jal	80002c4a <brelse>
}
    800031cc:	60e2                	ld	ra,24(sp)
    800031ce:	6442                	ld	s0,16(sp)
    800031d0:	64a2                	ld	s1,8(sp)
    800031d2:	6902                	ld	s2,0(sp)
    800031d4:	6105                	addi	sp,sp,32
    800031d6:	8082                	ret

00000000800031d8 <idup>:
{
    800031d8:	1101                	addi	sp,sp,-32
    800031da:	ec06                	sd	ra,24(sp)
    800031dc:	e822                	sd	s0,16(sp)
    800031de:	e426                	sd	s1,8(sp)
    800031e0:	1000                	addi	s0,sp,32
    800031e2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800031e4:	0001b517          	auipc	a0,0x1b
    800031e8:	ecc50513          	addi	a0,a0,-308 # 8001e0b0 <itable>
    800031ec:	9e3fd0ef          	jal	80000bce <acquire>
  ip->ref++;
    800031f0:	449c                	lw	a5,8(s1)
    800031f2:	2785                	addiw	a5,a5,1
    800031f4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800031f6:	0001b517          	auipc	a0,0x1b
    800031fa:	eba50513          	addi	a0,a0,-326 # 8001e0b0 <itable>
    800031fe:	a69fd0ef          	jal	80000c66 <release>
}
    80003202:	8526                	mv	a0,s1
    80003204:	60e2                	ld	ra,24(sp)
    80003206:	6442                	ld	s0,16(sp)
    80003208:	64a2                	ld	s1,8(sp)
    8000320a:	6105                	addi	sp,sp,32
    8000320c:	8082                	ret

000000008000320e <ilock>:
{
    8000320e:	1101                	addi	sp,sp,-32
    80003210:	ec06                	sd	ra,24(sp)
    80003212:	e822                	sd	s0,16(sp)
    80003214:	e426                	sd	s1,8(sp)
    80003216:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003218:	cd19                	beqz	a0,80003236 <ilock+0x28>
    8000321a:	84aa                	mv	s1,a0
    8000321c:	451c                	lw	a5,8(a0)
    8000321e:	00f05c63          	blez	a5,80003236 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003222:	0541                	addi	a0,a0,16
    80003224:	451000ef          	jal	80003e74 <acquiresleep>
  if(ip->valid == 0){
    80003228:	40bc                	lw	a5,64(s1)
    8000322a:	cf89                	beqz	a5,80003244 <ilock+0x36>
}
    8000322c:	60e2                	ld	ra,24(sp)
    8000322e:	6442                	ld	s0,16(sp)
    80003230:	64a2                	ld	s1,8(sp)
    80003232:	6105                	addi	sp,sp,32
    80003234:	8082                	ret
    80003236:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003238:	00004517          	auipc	a0,0x4
    8000323c:	23050513          	addi	a0,a0,560 # 80007468 <etext+0x468>
    80003240:	da0fd0ef          	jal	800007e0 <panic>
    80003244:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003246:	40dc                	lw	a5,4(s1)
    80003248:	0047d79b          	srliw	a5,a5,0x4
    8000324c:	0001b597          	auipc	a1,0x1b
    80003250:	e5c5a583          	lw	a1,-420(a1) # 8001e0a8 <sb+0x18>
    80003254:	9dbd                	addw	a1,a1,a5
    80003256:	4088                	lw	a0,0(s1)
    80003258:	8ebff0ef          	jal	80002b42 <bread>
    8000325c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000325e:	05850593          	addi	a1,a0,88
    80003262:	40dc                	lw	a5,4(s1)
    80003264:	8bbd                	andi	a5,a5,15
    80003266:	079a                	slli	a5,a5,0x6
    80003268:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000326a:	00059783          	lh	a5,0(a1)
    8000326e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003272:	00259783          	lh	a5,2(a1)
    80003276:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000327a:	00459783          	lh	a5,4(a1)
    8000327e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003282:	00659783          	lh	a5,6(a1)
    80003286:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000328a:	459c                	lw	a5,8(a1)
    8000328c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000328e:	03400613          	li	a2,52
    80003292:	05b1                	addi	a1,a1,12
    80003294:	05048513          	addi	a0,s1,80
    80003298:	a67fd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    8000329c:	854a                	mv	a0,s2
    8000329e:	9adff0ef          	jal	80002c4a <brelse>
    ip->valid = 1;
    800032a2:	4785                	li	a5,1
    800032a4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800032a6:	04449783          	lh	a5,68(s1)
    800032aa:	c399                	beqz	a5,800032b0 <ilock+0xa2>
    800032ac:	6902                	ld	s2,0(sp)
    800032ae:	bfbd                	j	8000322c <ilock+0x1e>
      panic("ilock: no type");
    800032b0:	00004517          	auipc	a0,0x4
    800032b4:	1c050513          	addi	a0,a0,448 # 80007470 <etext+0x470>
    800032b8:	d28fd0ef          	jal	800007e0 <panic>

00000000800032bc <iunlock>:
{
    800032bc:	1101                	addi	sp,sp,-32
    800032be:	ec06                	sd	ra,24(sp)
    800032c0:	e822                	sd	s0,16(sp)
    800032c2:	e426                	sd	s1,8(sp)
    800032c4:	e04a                	sd	s2,0(sp)
    800032c6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800032c8:	c505                	beqz	a0,800032f0 <iunlock+0x34>
    800032ca:	84aa                	mv	s1,a0
    800032cc:	01050913          	addi	s2,a0,16
    800032d0:	854a                	mv	a0,s2
    800032d2:	421000ef          	jal	80003ef2 <holdingsleep>
    800032d6:	cd09                	beqz	a0,800032f0 <iunlock+0x34>
    800032d8:	449c                	lw	a5,8(s1)
    800032da:	00f05b63          	blez	a5,800032f0 <iunlock+0x34>
  releasesleep(&ip->lock);
    800032de:	854a                	mv	a0,s2
    800032e0:	3db000ef          	jal	80003eba <releasesleep>
}
    800032e4:	60e2                	ld	ra,24(sp)
    800032e6:	6442                	ld	s0,16(sp)
    800032e8:	64a2                	ld	s1,8(sp)
    800032ea:	6902                	ld	s2,0(sp)
    800032ec:	6105                	addi	sp,sp,32
    800032ee:	8082                	ret
    panic("iunlock");
    800032f0:	00004517          	auipc	a0,0x4
    800032f4:	19050513          	addi	a0,a0,400 # 80007480 <etext+0x480>
    800032f8:	ce8fd0ef          	jal	800007e0 <panic>

00000000800032fc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800032fc:	7179                	addi	sp,sp,-48
    800032fe:	f406                	sd	ra,40(sp)
    80003300:	f022                	sd	s0,32(sp)
    80003302:	ec26                	sd	s1,24(sp)
    80003304:	e84a                	sd	s2,16(sp)
    80003306:	e44e                	sd	s3,8(sp)
    80003308:	1800                	addi	s0,sp,48
    8000330a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000330c:	05050493          	addi	s1,a0,80
    80003310:	08050913          	addi	s2,a0,128
    80003314:	a021                	j	8000331c <itrunc+0x20>
    80003316:	0491                	addi	s1,s1,4
    80003318:	01248b63          	beq	s1,s2,8000332e <itrunc+0x32>
    if(ip->addrs[i]){
    8000331c:	408c                	lw	a1,0(s1)
    8000331e:	dde5                	beqz	a1,80003316 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003320:	0009a503          	lw	a0,0(s3)
    80003324:	a17ff0ef          	jal	80002d3a <bfree>
      ip->addrs[i] = 0;
    80003328:	0004a023          	sw	zero,0(s1)
    8000332c:	b7ed                	j	80003316 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000332e:	0809a583          	lw	a1,128(s3)
    80003332:	ed89                	bnez	a1,8000334c <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003334:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003338:	854e                	mv	a0,s3
    8000333a:	e21ff0ef          	jal	8000315a <iupdate>
}
    8000333e:	70a2                	ld	ra,40(sp)
    80003340:	7402                	ld	s0,32(sp)
    80003342:	64e2                	ld	s1,24(sp)
    80003344:	6942                	ld	s2,16(sp)
    80003346:	69a2                	ld	s3,8(sp)
    80003348:	6145                	addi	sp,sp,48
    8000334a:	8082                	ret
    8000334c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000334e:	0009a503          	lw	a0,0(s3)
    80003352:	ff0ff0ef          	jal	80002b42 <bread>
    80003356:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003358:	05850493          	addi	s1,a0,88
    8000335c:	45850913          	addi	s2,a0,1112
    80003360:	a021                	j	80003368 <itrunc+0x6c>
    80003362:	0491                	addi	s1,s1,4
    80003364:	01248963          	beq	s1,s2,80003376 <itrunc+0x7a>
      if(a[j])
    80003368:	408c                	lw	a1,0(s1)
    8000336a:	dde5                	beqz	a1,80003362 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000336c:	0009a503          	lw	a0,0(s3)
    80003370:	9cbff0ef          	jal	80002d3a <bfree>
    80003374:	b7fd                	j	80003362 <itrunc+0x66>
    brelse(bp);
    80003376:	8552                	mv	a0,s4
    80003378:	8d3ff0ef          	jal	80002c4a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000337c:	0809a583          	lw	a1,128(s3)
    80003380:	0009a503          	lw	a0,0(s3)
    80003384:	9b7ff0ef          	jal	80002d3a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003388:	0809a023          	sw	zero,128(s3)
    8000338c:	6a02                	ld	s4,0(sp)
    8000338e:	b75d                	j	80003334 <itrunc+0x38>

0000000080003390 <iput>:
{
    80003390:	1101                	addi	sp,sp,-32
    80003392:	ec06                	sd	ra,24(sp)
    80003394:	e822                	sd	s0,16(sp)
    80003396:	e426                	sd	s1,8(sp)
    80003398:	1000                	addi	s0,sp,32
    8000339a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000339c:	0001b517          	auipc	a0,0x1b
    800033a0:	d1450513          	addi	a0,a0,-748 # 8001e0b0 <itable>
    800033a4:	82bfd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033a8:	4498                	lw	a4,8(s1)
    800033aa:	4785                	li	a5,1
    800033ac:	02f70063          	beq	a4,a5,800033cc <iput+0x3c>
  ip->ref--;
    800033b0:	449c                	lw	a5,8(s1)
    800033b2:	37fd                	addiw	a5,a5,-1
    800033b4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033b6:	0001b517          	auipc	a0,0x1b
    800033ba:	cfa50513          	addi	a0,a0,-774 # 8001e0b0 <itable>
    800033be:	8a9fd0ef          	jal	80000c66 <release>
}
    800033c2:	60e2                	ld	ra,24(sp)
    800033c4:	6442                	ld	s0,16(sp)
    800033c6:	64a2                	ld	s1,8(sp)
    800033c8:	6105                	addi	sp,sp,32
    800033ca:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033cc:	40bc                	lw	a5,64(s1)
    800033ce:	d3ed                	beqz	a5,800033b0 <iput+0x20>
    800033d0:	04a49783          	lh	a5,74(s1)
    800033d4:	fff1                	bnez	a5,800033b0 <iput+0x20>
    800033d6:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800033d8:	01048913          	addi	s2,s1,16
    800033dc:	854a                	mv	a0,s2
    800033de:	297000ef          	jal	80003e74 <acquiresleep>
    release(&itable.lock);
    800033e2:	0001b517          	auipc	a0,0x1b
    800033e6:	cce50513          	addi	a0,a0,-818 # 8001e0b0 <itable>
    800033ea:	87dfd0ef          	jal	80000c66 <release>
    itrunc(ip);
    800033ee:	8526                	mv	a0,s1
    800033f0:	f0dff0ef          	jal	800032fc <itrunc>
    ip->type = 0;
    800033f4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800033f8:	8526                	mv	a0,s1
    800033fa:	d61ff0ef          	jal	8000315a <iupdate>
    ip->valid = 0;
    800033fe:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003402:	854a                	mv	a0,s2
    80003404:	2b7000ef          	jal	80003eba <releasesleep>
    acquire(&itable.lock);
    80003408:	0001b517          	auipc	a0,0x1b
    8000340c:	ca850513          	addi	a0,a0,-856 # 8001e0b0 <itable>
    80003410:	fbefd0ef          	jal	80000bce <acquire>
    80003414:	6902                	ld	s2,0(sp)
    80003416:	bf69                	j	800033b0 <iput+0x20>

0000000080003418 <iunlockput>:
{
    80003418:	1101                	addi	sp,sp,-32
    8000341a:	ec06                	sd	ra,24(sp)
    8000341c:	e822                	sd	s0,16(sp)
    8000341e:	e426                	sd	s1,8(sp)
    80003420:	1000                	addi	s0,sp,32
    80003422:	84aa                	mv	s1,a0
  iunlock(ip);
    80003424:	e99ff0ef          	jal	800032bc <iunlock>
  iput(ip);
    80003428:	8526                	mv	a0,s1
    8000342a:	f67ff0ef          	jal	80003390 <iput>
}
    8000342e:	60e2                	ld	ra,24(sp)
    80003430:	6442                	ld	s0,16(sp)
    80003432:	64a2                	ld	s1,8(sp)
    80003434:	6105                	addi	sp,sp,32
    80003436:	8082                	ret

0000000080003438 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003438:	0001b717          	auipc	a4,0x1b
    8000343c:	c6472703          	lw	a4,-924(a4) # 8001e09c <sb+0xc>
    80003440:	4785                	li	a5,1
    80003442:	0ae7ff63          	bgeu	a5,a4,80003500 <ireclaim+0xc8>
{
    80003446:	7139                	addi	sp,sp,-64
    80003448:	fc06                	sd	ra,56(sp)
    8000344a:	f822                	sd	s0,48(sp)
    8000344c:	f426                	sd	s1,40(sp)
    8000344e:	f04a                	sd	s2,32(sp)
    80003450:	ec4e                	sd	s3,24(sp)
    80003452:	e852                	sd	s4,16(sp)
    80003454:	e456                	sd	s5,8(sp)
    80003456:	e05a                	sd	s6,0(sp)
    80003458:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000345a:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000345c:	00050a1b          	sext.w	s4,a0
    80003460:	0001ba97          	auipc	s5,0x1b
    80003464:	c30a8a93          	addi	s5,s5,-976 # 8001e090 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003468:	00004b17          	auipc	s6,0x4
    8000346c:	020b0b13          	addi	s6,s6,32 # 80007488 <etext+0x488>
    80003470:	a099                	j	800034b6 <ireclaim+0x7e>
    80003472:	85ce                	mv	a1,s3
    80003474:	855a                	mv	a0,s6
    80003476:	884fd0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    8000347a:	85ce                	mv	a1,s3
    8000347c:	8552                	mv	a0,s4
    8000347e:	b1dff0ef          	jal	80002f9a <iget>
    80003482:	89aa                	mv	s3,a0
    brelse(bp);
    80003484:	854a                	mv	a0,s2
    80003486:	fc4ff0ef          	jal	80002c4a <brelse>
    if (ip) {
    8000348a:	00098f63          	beqz	s3,800034a8 <ireclaim+0x70>
      begin_op();
    8000348e:	76a000ef          	jal	80003bf8 <begin_op>
      ilock(ip);
    80003492:	854e                	mv	a0,s3
    80003494:	d7bff0ef          	jal	8000320e <ilock>
      iunlock(ip);
    80003498:	854e                	mv	a0,s3
    8000349a:	e23ff0ef          	jal	800032bc <iunlock>
      iput(ip);
    8000349e:	854e                	mv	a0,s3
    800034a0:	ef1ff0ef          	jal	80003390 <iput>
      end_op();
    800034a4:	7be000ef          	jal	80003c62 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034a8:	0485                	addi	s1,s1,1
    800034aa:	00caa703          	lw	a4,12(s5)
    800034ae:	0004879b          	sext.w	a5,s1
    800034b2:	02e7fd63          	bgeu	a5,a4,800034ec <ireclaim+0xb4>
    800034b6:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034ba:	0044d593          	srli	a1,s1,0x4
    800034be:	018aa783          	lw	a5,24(s5)
    800034c2:	9dbd                	addw	a1,a1,a5
    800034c4:	8552                	mv	a0,s4
    800034c6:	e7cff0ef          	jal	80002b42 <bread>
    800034ca:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800034cc:	05850793          	addi	a5,a0,88
    800034d0:	00f9f713          	andi	a4,s3,15
    800034d4:	071a                	slli	a4,a4,0x6
    800034d6:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800034d8:	00079703          	lh	a4,0(a5)
    800034dc:	c701                	beqz	a4,800034e4 <ireclaim+0xac>
    800034de:	00679783          	lh	a5,6(a5)
    800034e2:	dbc1                	beqz	a5,80003472 <ireclaim+0x3a>
    brelse(bp);
    800034e4:	854a                	mv	a0,s2
    800034e6:	f64ff0ef          	jal	80002c4a <brelse>
    if (ip) {
    800034ea:	bf7d                	j	800034a8 <ireclaim+0x70>
}
    800034ec:	70e2                	ld	ra,56(sp)
    800034ee:	7442                	ld	s0,48(sp)
    800034f0:	74a2                	ld	s1,40(sp)
    800034f2:	7902                	ld	s2,32(sp)
    800034f4:	69e2                	ld	s3,24(sp)
    800034f6:	6a42                	ld	s4,16(sp)
    800034f8:	6aa2                	ld	s5,8(sp)
    800034fa:	6b02                	ld	s6,0(sp)
    800034fc:	6121                	addi	sp,sp,64
    800034fe:	8082                	ret
    80003500:	8082                	ret

0000000080003502 <fsinit>:
fsinit(int dev) {
    80003502:	7179                	addi	sp,sp,-48
    80003504:	f406                	sd	ra,40(sp)
    80003506:	f022                	sd	s0,32(sp)
    80003508:	ec26                	sd	s1,24(sp)
    8000350a:	e84a                	sd	s2,16(sp)
    8000350c:	e44e                	sd	s3,8(sp)
    8000350e:	1800                	addi	s0,sp,48
    80003510:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003512:	4585                	li	a1,1
    80003514:	e2eff0ef          	jal	80002b42 <bread>
    80003518:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000351a:	0001b997          	auipc	s3,0x1b
    8000351e:	b7698993          	addi	s3,s3,-1162 # 8001e090 <sb>
    80003522:	02000613          	li	a2,32
    80003526:	05850593          	addi	a1,a0,88
    8000352a:	854e                	mv	a0,s3
    8000352c:	fd2fd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    80003530:	854a                	mv	a0,s2
    80003532:	f18ff0ef          	jal	80002c4a <brelse>
  if(sb.magic != FSMAGIC)
    80003536:	0009a703          	lw	a4,0(s3)
    8000353a:	102037b7          	lui	a5,0x10203
    8000353e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003542:	02f71363          	bne	a4,a5,80003568 <fsinit+0x66>
  initlog(dev, &sb);
    80003546:	0001b597          	auipc	a1,0x1b
    8000354a:	b4a58593          	addi	a1,a1,-1206 # 8001e090 <sb>
    8000354e:	8526                	mv	a0,s1
    80003550:	62a000ef          	jal	80003b7a <initlog>
  ireclaim(dev);
    80003554:	8526                	mv	a0,s1
    80003556:	ee3ff0ef          	jal	80003438 <ireclaim>
}
    8000355a:	70a2                	ld	ra,40(sp)
    8000355c:	7402                	ld	s0,32(sp)
    8000355e:	64e2                	ld	s1,24(sp)
    80003560:	6942                	ld	s2,16(sp)
    80003562:	69a2                	ld	s3,8(sp)
    80003564:	6145                	addi	sp,sp,48
    80003566:	8082                	ret
    panic("invalid file system");
    80003568:	00004517          	auipc	a0,0x4
    8000356c:	f4050513          	addi	a0,a0,-192 # 800074a8 <etext+0x4a8>
    80003570:	a70fd0ef          	jal	800007e0 <panic>

0000000080003574 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003574:	1141                	addi	sp,sp,-16
    80003576:	e422                	sd	s0,8(sp)
    80003578:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000357a:	411c                	lw	a5,0(a0)
    8000357c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000357e:	415c                	lw	a5,4(a0)
    80003580:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003582:	04451783          	lh	a5,68(a0)
    80003586:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000358a:	04a51783          	lh	a5,74(a0)
    8000358e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003592:	04c56783          	lwu	a5,76(a0)
    80003596:	e99c                	sd	a5,16(a1)
}
    80003598:	6422                	ld	s0,8(sp)
    8000359a:	0141                	addi	sp,sp,16
    8000359c:	8082                	ret

000000008000359e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000359e:	457c                	lw	a5,76(a0)
    800035a0:	0ed7eb63          	bltu	a5,a3,80003696 <readi+0xf8>
{
    800035a4:	7159                	addi	sp,sp,-112
    800035a6:	f486                	sd	ra,104(sp)
    800035a8:	f0a2                	sd	s0,96(sp)
    800035aa:	eca6                	sd	s1,88(sp)
    800035ac:	e0d2                	sd	s4,64(sp)
    800035ae:	fc56                	sd	s5,56(sp)
    800035b0:	f85a                	sd	s6,48(sp)
    800035b2:	f45e                	sd	s7,40(sp)
    800035b4:	1880                	addi	s0,sp,112
    800035b6:	8b2a                	mv	s6,a0
    800035b8:	8bae                	mv	s7,a1
    800035ba:	8a32                	mv	s4,a2
    800035bc:	84b6                	mv	s1,a3
    800035be:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800035c0:	9f35                	addw	a4,a4,a3
    return 0;
    800035c2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800035c4:	0cd76063          	bltu	a4,a3,80003684 <readi+0xe6>
    800035c8:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800035ca:	00e7f463          	bgeu	a5,a4,800035d2 <readi+0x34>
    n = ip->size - off;
    800035ce:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035d2:	080a8f63          	beqz	s5,80003670 <readi+0xd2>
    800035d6:	e8ca                	sd	s2,80(sp)
    800035d8:	f062                	sd	s8,32(sp)
    800035da:	ec66                	sd	s9,24(sp)
    800035dc:	e86a                	sd	s10,16(sp)
    800035de:	e46e                	sd	s11,8(sp)
    800035e0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800035e2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800035e6:	5c7d                	li	s8,-1
    800035e8:	a80d                	j	8000361a <readi+0x7c>
    800035ea:	020d1d93          	slli	s11,s10,0x20
    800035ee:	020ddd93          	srli	s11,s11,0x20
    800035f2:	05890613          	addi	a2,s2,88
    800035f6:	86ee                	mv	a3,s11
    800035f8:	963a                	add	a2,a2,a4
    800035fa:	85d2                	mv	a1,s4
    800035fc:	855e                	mv	a0,s7
    800035fe:	c3ffe0ef          	jal	8000223c <either_copyout>
    80003602:	05850763          	beq	a0,s8,80003650 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003606:	854a                	mv	a0,s2
    80003608:	e42ff0ef          	jal	80002c4a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000360c:	013d09bb          	addw	s3,s10,s3
    80003610:	009d04bb          	addw	s1,s10,s1
    80003614:	9a6e                	add	s4,s4,s11
    80003616:	0559f763          	bgeu	s3,s5,80003664 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    8000361a:	00a4d59b          	srliw	a1,s1,0xa
    8000361e:	855a                	mv	a0,s6
    80003620:	8a7ff0ef          	jal	80002ec6 <bmap>
    80003624:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003628:	c5b1                	beqz	a1,80003674 <readi+0xd6>
    bp = bread(ip->dev, addr);
    8000362a:	000b2503          	lw	a0,0(s6)
    8000362e:	d14ff0ef          	jal	80002b42 <bread>
    80003632:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003634:	3ff4f713          	andi	a4,s1,1023
    80003638:	40ec87bb          	subw	a5,s9,a4
    8000363c:	413a86bb          	subw	a3,s5,s3
    80003640:	8d3e                	mv	s10,a5
    80003642:	2781                	sext.w	a5,a5
    80003644:	0006861b          	sext.w	a2,a3
    80003648:	faf671e3          	bgeu	a2,a5,800035ea <readi+0x4c>
    8000364c:	8d36                	mv	s10,a3
    8000364e:	bf71                	j	800035ea <readi+0x4c>
      brelse(bp);
    80003650:	854a                	mv	a0,s2
    80003652:	df8ff0ef          	jal	80002c4a <brelse>
      tot = -1;
    80003656:	59fd                	li	s3,-1
      break;
    80003658:	6946                	ld	s2,80(sp)
    8000365a:	7c02                	ld	s8,32(sp)
    8000365c:	6ce2                	ld	s9,24(sp)
    8000365e:	6d42                	ld	s10,16(sp)
    80003660:	6da2                	ld	s11,8(sp)
    80003662:	a831                	j	8000367e <readi+0xe0>
    80003664:	6946                	ld	s2,80(sp)
    80003666:	7c02                	ld	s8,32(sp)
    80003668:	6ce2                	ld	s9,24(sp)
    8000366a:	6d42                	ld	s10,16(sp)
    8000366c:	6da2                	ld	s11,8(sp)
    8000366e:	a801                	j	8000367e <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003670:	89d6                	mv	s3,s5
    80003672:	a031                	j	8000367e <readi+0xe0>
    80003674:	6946                	ld	s2,80(sp)
    80003676:	7c02                	ld	s8,32(sp)
    80003678:	6ce2                	ld	s9,24(sp)
    8000367a:	6d42                	ld	s10,16(sp)
    8000367c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000367e:	0009851b          	sext.w	a0,s3
    80003682:	69a6                	ld	s3,72(sp)
}
    80003684:	70a6                	ld	ra,104(sp)
    80003686:	7406                	ld	s0,96(sp)
    80003688:	64e6                	ld	s1,88(sp)
    8000368a:	6a06                	ld	s4,64(sp)
    8000368c:	7ae2                	ld	s5,56(sp)
    8000368e:	7b42                	ld	s6,48(sp)
    80003690:	7ba2                	ld	s7,40(sp)
    80003692:	6165                	addi	sp,sp,112
    80003694:	8082                	ret
    return 0;
    80003696:	4501                	li	a0,0
}
    80003698:	8082                	ret

000000008000369a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000369a:	457c                	lw	a5,76(a0)
    8000369c:	10d7e063          	bltu	a5,a3,8000379c <writei+0x102>
{
    800036a0:	7159                	addi	sp,sp,-112
    800036a2:	f486                	sd	ra,104(sp)
    800036a4:	f0a2                	sd	s0,96(sp)
    800036a6:	e8ca                	sd	s2,80(sp)
    800036a8:	e0d2                	sd	s4,64(sp)
    800036aa:	fc56                	sd	s5,56(sp)
    800036ac:	f85a                	sd	s6,48(sp)
    800036ae:	f45e                	sd	s7,40(sp)
    800036b0:	1880                	addi	s0,sp,112
    800036b2:	8aaa                	mv	s5,a0
    800036b4:	8bae                	mv	s7,a1
    800036b6:	8a32                	mv	s4,a2
    800036b8:	8936                	mv	s2,a3
    800036ba:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800036bc:	00e687bb          	addw	a5,a3,a4
    800036c0:	0ed7e063          	bltu	a5,a3,800037a0 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800036c4:	00043737          	lui	a4,0x43
    800036c8:	0cf76e63          	bltu	a4,a5,800037a4 <writei+0x10a>
    800036cc:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036ce:	0a0b0f63          	beqz	s6,8000378c <writei+0xf2>
    800036d2:	eca6                	sd	s1,88(sp)
    800036d4:	f062                	sd	s8,32(sp)
    800036d6:	ec66                	sd	s9,24(sp)
    800036d8:	e86a                	sd	s10,16(sp)
    800036da:	e46e                	sd	s11,8(sp)
    800036dc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800036de:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800036e2:	5c7d                	li	s8,-1
    800036e4:	a825                	j	8000371c <writei+0x82>
    800036e6:	020d1d93          	slli	s11,s10,0x20
    800036ea:	020ddd93          	srli	s11,s11,0x20
    800036ee:	05848513          	addi	a0,s1,88
    800036f2:	86ee                	mv	a3,s11
    800036f4:	8652                	mv	a2,s4
    800036f6:	85de                	mv	a1,s7
    800036f8:	953a                	add	a0,a0,a4
    800036fa:	b8dfe0ef          	jal	80002286 <either_copyin>
    800036fe:	05850a63          	beq	a0,s8,80003752 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003702:	8526                	mv	a0,s1
    80003704:	678000ef          	jal	80003d7c <log_write>
    brelse(bp);
    80003708:	8526                	mv	a0,s1
    8000370a:	d40ff0ef          	jal	80002c4a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000370e:	013d09bb          	addw	s3,s10,s3
    80003712:	012d093b          	addw	s2,s10,s2
    80003716:	9a6e                	add	s4,s4,s11
    80003718:	0569f063          	bgeu	s3,s6,80003758 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000371c:	00a9559b          	srliw	a1,s2,0xa
    80003720:	8556                	mv	a0,s5
    80003722:	fa4ff0ef          	jal	80002ec6 <bmap>
    80003726:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000372a:	c59d                	beqz	a1,80003758 <writei+0xbe>
    bp = bread(ip->dev, addr);
    8000372c:	000aa503          	lw	a0,0(s5)
    80003730:	c12ff0ef          	jal	80002b42 <bread>
    80003734:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003736:	3ff97713          	andi	a4,s2,1023
    8000373a:	40ec87bb          	subw	a5,s9,a4
    8000373e:	413b06bb          	subw	a3,s6,s3
    80003742:	8d3e                	mv	s10,a5
    80003744:	2781                	sext.w	a5,a5
    80003746:	0006861b          	sext.w	a2,a3
    8000374a:	f8f67ee3          	bgeu	a2,a5,800036e6 <writei+0x4c>
    8000374e:	8d36                	mv	s10,a3
    80003750:	bf59                	j	800036e6 <writei+0x4c>
      brelse(bp);
    80003752:	8526                	mv	a0,s1
    80003754:	cf6ff0ef          	jal	80002c4a <brelse>
  }

  if(off > ip->size)
    80003758:	04caa783          	lw	a5,76(s5)
    8000375c:	0327fa63          	bgeu	a5,s2,80003790 <writei+0xf6>
    ip->size = off;
    80003760:	052aa623          	sw	s2,76(s5)
    80003764:	64e6                	ld	s1,88(sp)
    80003766:	7c02                	ld	s8,32(sp)
    80003768:	6ce2                	ld	s9,24(sp)
    8000376a:	6d42                	ld	s10,16(sp)
    8000376c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000376e:	8556                	mv	a0,s5
    80003770:	9ebff0ef          	jal	8000315a <iupdate>

  return tot;
    80003774:	0009851b          	sext.w	a0,s3
    80003778:	69a6                	ld	s3,72(sp)
}
    8000377a:	70a6                	ld	ra,104(sp)
    8000377c:	7406                	ld	s0,96(sp)
    8000377e:	6946                	ld	s2,80(sp)
    80003780:	6a06                	ld	s4,64(sp)
    80003782:	7ae2                	ld	s5,56(sp)
    80003784:	7b42                	ld	s6,48(sp)
    80003786:	7ba2                	ld	s7,40(sp)
    80003788:	6165                	addi	sp,sp,112
    8000378a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000378c:	89da                	mv	s3,s6
    8000378e:	b7c5                	j	8000376e <writei+0xd4>
    80003790:	64e6                	ld	s1,88(sp)
    80003792:	7c02                	ld	s8,32(sp)
    80003794:	6ce2                	ld	s9,24(sp)
    80003796:	6d42                	ld	s10,16(sp)
    80003798:	6da2                	ld	s11,8(sp)
    8000379a:	bfd1                	j	8000376e <writei+0xd4>
    return -1;
    8000379c:	557d                	li	a0,-1
}
    8000379e:	8082                	ret
    return -1;
    800037a0:	557d                	li	a0,-1
    800037a2:	bfe1                	j	8000377a <writei+0xe0>
    return -1;
    800037a4:	557d                	li	a0,-1
    800037a6:	bfd1                	j	8000377a <writei+0xe0>

00000000800037a8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800037a8:	1141                	addi	sp,sp,-16
    800037aa:	e406                	sd	ra,8(sp)
    800037ac:	e022                	sd	s0,0(sp)
    800037ae:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800037b0:	4639                	li	a2,14
    800037b2:	dbcfd0ef          	jal	80000d6e <strncmp>
}
    800037b6:	60a2                	ld	ra,8(sp)
    800037b8:	6402                	ld	s0,0(sp)
    800037ba:	0141                	addi	sp,sp,16
    800037bc:	8082                	ret

00000000800037be <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800037be:	7139                	addi	sp,sp,-64
    800037c0:	fc06                	sd	ra,56(sp)
    800037c2:	f822                	sd	s0,48(sp)
    800037c4:	f426                	sd	s1,40(sp)
    800037c6:	f04a                	sd	s2,32(sp)
    800037c8:	ec4e                	sd	s3,24(sp)
    800037ca:	e852                	sd	s4,16(sp)
    800037cc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800037ce:	04451703          	lh	a4,68(a0)
    800037d2:	4785                	li	a5,1
    800037d4:	00f71a63          	bne	a4,a5,800037e8 <dirlookup+0x2a>
    800037d8:	892a                	mv	s2,a0
    800037da:	89ae                	mv	s3,a1
    800037dc:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800037de:	457c                	lw	a5,76(a0)
    800037e0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800037e2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037e4:	e39d                	bnez	a5,8000380a <dirlookup+0x4c>
    800037e6:	a095                	j	8000384a <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800037e8:	00004517          	auipc	a0,0x4
    800037ec:	cd850513          	addi	a0,a0,-808 # 800074c0 <etext+0x4c0>
    800037f0:	ff1fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    800037f4:	00004517          	auipc	a0,0x4
    800037f8:	ce450513          	addi	a0,a0,-796 # 800074d8 <etext+0x4d8>
    800037fc:	fe5fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003800:	24c1                	addiw	s1,s1,16
    80003802:	04c92783          	lw	a5,76(s2)
    80003806:	04f4f163          	bgeu	s1,a5,80003848 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000380a:	4741                	li	a4,16
    8000380c:	86a6                	mv	a3,s1
    8000380e:	fc040613          	addi	a2,s0,-64
    80003812:	4581                	li	a1,0
    80003814:	854a                	mv	a0,s2
    80003816:	d89ff0ef          	jal	8000359e <readi>
    8000381a:	47c1                	li	a5,16
    8000381c:	fcf51ce3          	bne	a0,a5,800037f4 <dirlookup+0x36>
    if(de.inum == 0)
    80003820:	fc045783          	lhu	a5,-64(s0)
    80003824:	dff1                	beqz	a5,80003800 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003826:	fc240593          	addi	a1,s0,-62
    8000382a:	854e                	mv	a0,s3
    8000382c:	f7dff0ef          	jal	800037a8 <namecmp>
    80003830:	f961                	bnez	a0,80003800 <dirlookup+0x42>
      if(poff)
    80003832:	000a0463          	beqz	s4,8000383a <dirlookup+0x7c>
        *poff = off;
    80003836:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000383a:	fc045583          	lhu	a1,-64(s0)
    8000383e:	00092503          	lw	a0,0(s2)
    80003842:	f58ff0ef          	jal	80002f9a <iget>
    80003846:	a011                	j	8000384a <dirlookup+0x8c>
  return 0;
    80003848:	4501                	li	a0,0
}
    8000384a:	70e2                	ld	ra,56(sp)
    8000384c:	7442                	ld	s0,48(sp)
    8000384e:	74a2                	ld	s1,40(sp)
    80003850:	7902                	ld	s2,32(sp)
    80003852:	69e2                	ld	s3,24(sp)
    80003854:	6a42                	ld	s4,16(sp)
    80003856:	6121                	addi	sp,sp,64
    80003858:	8082                	ret

000000008000385a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000385a:	711d                	addi	sp,sp,-96
    8000385c:	ec86                	sd	ra,88(sp)
    8000385e:	e8a2                	sd	s0,80(sp)
    80003860:	e4a6                	sd	s1,72(sp)
    80003862:	e0ca                	sd	s2,64(sp)
    80003864:	fc4e                	sd	s3,56(sp)
    80003866:	f852                	sd	s4,48(sp)
    80003868:	f456                	sd	s5,40(sp)
    8000386a:	f05a                	sd	s6,32(sp)
    8000386c:	ec5e                	sd	s7,24(sp)
    8000386e:	e862                	sd	s8,16(sp)
    80003870:	e466                	sd	s9,8(sp)
    80003872:	1080                	addi	s0,sp,96
    80003874:	84aa                	mv	s1,a0
    80003876:	8b2e                	mv	s6,a1
    80003878:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000387a:	00054703          	lbu	a4,0(a0)
    8000387e:	02f00793          	li	a5,47
    80003882:	00f70e63          	beq	a4,a5,8000389e <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003886:	848fe0ef          	jal	800018ce <myproc>
    8000388a:	15053503          	ld	a0,336(a0)
    8000388e:	94bff0ef          	jal	800031d8 <idup>
    80003892:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003894:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003898:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000389a:	4b85                	li	s7,1
    8000389c:	a871                	j	80003938 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    8000389e:	4585                	li	a1,1
    800038a0:	4505                	li	a0,1
    800038a2:	ef8ff0ef          	jal	80002f9a <iget>
    800038a6:	8a2a                	mv	s4,a0
    800038a8:	b7f5                	j	80003894 <namex+0x3a>
      iunlockput(ip);
    800038aa:	8552                	mv	a0,s4
    800038ac:	b6dff0ef          	jal	80003418 <iunlockput>
      return 0;
    800038b0:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800038b2:	8552                	mv	a0,s4
    800038b4:	60e6                	ld	ra,88(sp)
    800038b6:	6446                	ld	s0,80(sp)
    800038b8:	64a6                	ld	s1,72(sp)
    800038ba:	6906                	ld	s2,64(sp)
    800038bc:	79e2                	ld	s3,56(sp)
    800038be:	7a42                	ld	s4,48(sp)
    800038c0:	7aa2                	ld	s5,40(sp)
    800038c2:	7b02                	ld	s6,32(sp)
    800038c4:	6be2                	ld	s7,24(sp)
    800038c6:	6c42                	ld	s8,16(sp)
    800038c8:	6ca2                	ld	s9,8(sp)
    800038ca:	6125                	addi	sp,sp,96
    800038cc:	8082                	ret
      iunlock(ip);
    800038ce:	8552                	mv	a0,s4
    800038d0:	9edff0ef          	jal	800032bc <iunlock>
      return ip;
    800038d4:	bff9                	j	800038b2 <namex+0x58>
      iunlockput(ip);
    800038d6:	8552                	mv	a0,s4
    800038d8:	b41ff0ef          	jal	80003418 <iunlockput>
      return 0;
    800038dc:	8a4e                	mv	s4,s3
    800038de:	bfd1                	j	800038b2 <namex+0x58>
  len = path - s;
    800038e0:	40998633          	sub	a2,s3,s1
    800038e4:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800038e8:	099c5063          	bge	s8,s9,80003968 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800038ec:	4639                	li	a2,14
    800038ee:	85a6                	mv	a1,s1
    800038f0:	8556                	mv	a0,s5
    800038f2:	c0cfd0ef          	jal	80000cfe <memmove>
    800038f6:	84ce                	mv	s1,s3
  while(*path == '/')
    800038f8:	0004c783          	lbu	a5,0(s1)
    800038fc:	01279763          	bne	a5,s2,8000390a <namex+0xb0>
    path++;
    80003900:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003902:	0004c783          	lbu	a5,0(s1)
    80003906:	ff278de3          	beq	a5,s2,80003900 <namex+0xa6>
    ilock(ip);
    8000390a:	8552                	mv	a0,s4
    8000390c:	903ff0ef          	jal	8000320e <ilock>
    if(ip->type != T_DIR){
    80003910:	044a1783          	lh	a5,68(s4)
    80003914:	f9779be3          	bne	a5,s7,800038aa <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003918:	000b0563          	beqz	s6,80003922 <namex+0xc8>
    8000391c:	0004c783          	lbu	a5,0(s1)
    80003920:	d7dd                	beqz	a5,800038ce <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003922:	4601                	li	a2,0
    80003924:	85d6                	mv	a1,s5
    80003926:	8552                	mv	a0,s4
    80003928:	e97ff0ef          	jal	800037be <dirlookup>
    8000392c:	89aa                	mv	s3,a0
    8000392e:	d545                	beqz	a0,800038d6 <namex+0x7c>
    iunlockput(ip);
    80003930:	8552                	mv	a0,s4
    80003932:	ae7ff0ef          	jal	80003418 <iunlockput>
    ip = next;
    80003936:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003938:	0004c783          	lbu	a5,0(s1)
    8000393c:	01279763          	bne	a5,s2,8000394a <namex+0xf0>
    path++;
    80003940:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003942:	0004c783          	lbu	a5,0(s1)
    80003946:	ff278de3          	beq	a5,s2,80003940 <namex+0xe6>
  if(*path == 0)
    8000394a:	cb8d                	beqz	a5,8000397c <namex+0x122>
  while(*path != '/' && *path != 0)
    8000394c:	0004c783          	lbu	a5,0(s1)
    80003950:	89a6                	mv	s3,s1
  len = path - s;
    80003952:	4c81                	li	s9,0
    80003954:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003956:	01278963          	beq	a5,s2,80003968 <namex+0x10e>
    8000395a:	d3d9                	beqz	a5,800038e0 <namex+0x86>
    path++;
    8000395c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000395e:	0009c783          	lbu	a5,0(s3)
    80003962:	ff279ce3          	bne	a5,s2,8000395a <namex+0x100>
    80003966:	bfad                	j	800038e0 <namex+0x86>
    memmove(name, s, len);
    80003968:	2601                	sext.w	a2,a2
    8000396a:	85a6                	mv	a1,s1
    8000396c:	8556                	mv	a0,s5
    8000396e:	b90fd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003972:	9cd6                	add	s9,s9,s5
    80003974:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003978:	84ce                	mv	s1,s3
    8000397a:	bfbd                	j	800038f8 <namex+0x9e>
  if(nameiparent){
    8000397c:	f20b0be3          	beqz	s6,800038b2 <namex+0x58>
    iput(ip);
    80003980:	8552                	mv	a0,s4
    80003982:	a0fff0ef          	jal	80003390 <iput>
    return 0;
    80003986:	4a01                	li	s4,0
    80003988:	b72d                	j	800038b2 <namex+0x58>

000000008000398a <dirlink>:
{
    8000398a:	7139                	addi	sp,sp,-64
    8000398c:	fc06                	sd	ra,56(sp)
    8000398e:	f822                	sd	s0,48(sp)
    80003990:	f04a                	sd	s2,32(sp)
    80003992:	ec4e                	sd	s3,24(sp)
    80003994:	e852                	sd	s4,16(sp)
    80003996:	0080                	addi	s0,sp,64
    80003998:	892a                	mv	s2,a0
    8000399a:	8a2e                	mv	s4,a1
    8000399c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000399e:	4601                	li	a2,0
    800039a0:	e1fff0ef          	jal	800037be <dirlookup>
    800039a4:	e535                	bnez	a0,80003a10 <dirlink+0x86>
    800039a6:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039a8:	04c92483          	lw	s1,76(s2)
    800039ac:	c48d                	beqz	s1,800039d6 <dirlink+0x4c>
    800039ae:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039b0:	4741                	li	a4,16
    800039b2:	86a6                	mv	a3,s1
    800039b4:	fc040613          	addi	a2,s0,-64
    800039b8:	4581                	li	a1,0
    800039ba:	854a                	mv	a0,s2
    800039bc:	be3ff0ef          	jal	8000359e <readi>
    800039c0:	47c1                	li	a5,16
    800039c2:	04f51b63          	bne	a0,a5,80003a18 <dirlink+0x8e>
    if(de.inum == 0)
    800039c6:	fc045783          	lhu	a5,-64(s0)
    800039ca:	c791                	beqz	a5,800039d6 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039cc:	24c1                	addiw	s1,s1,16
    800039ce:	04c92783          	lw	a5,76(s2)
    800039d2:	fcf4efe3          	bltu	s1,a5,800039b0 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800039d6:	4639                	li	a2,14
    800039d8:	85d2                	mv	a1,s4
    800039da:	fc240513          	addi	a0,s0,-62
    800039de:	bc6fd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    800039e2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039e6:	4741                	li	a4,16
    800039e8:	86a6                	mv	a3,s1
    800039ea:	fc040613          	addi	a2,s0,-64
    800039ee:	4581                	li	a1,0
    800039f0:	854a                	mv	a0,s2
    800039f2:	ca9ff0ef          	jal	8000369a <writei>
    800039f6:	1541                	addi	a0,a0,-16
    800039f8:	00a03533          	snez	a0,a0
    800039fc:	40a00533          	neg	a0,a0
    80003a00:	74a2                	ld	s1,40(sp)
}
    80003a02:	70e2                	ld	ra,56(sp)
    80003a04:	7442                	ld	s0,48(sp)
    80003a06:	7902                	ld	s2,32(sp)
    80003a08:	69e2                	ld	s3,24(sp)
    80003a0a:	6a42                	ld	s4,16(sp)
    80003a0c:	6121                	addi	sp,sp,64
    80003a0e:	8082                	ret
    iput(ip);
    80003a10:	981ff0ef          	jal	80003390 <iput>
    return -1;
    80003a14:	557d                	li	a0,-1
    80003a16:	b7f5                	j	80003a02 <dirlink+0x78>
      panic("dirlink read");
    80003a18:	00004517          	auipc	a0,0x4
    80003a1c:	ad050513          	addi	a0,a0,-1328 # 800074e8 <etext+0x4e8>
    80003a20:	dc1fc0ef          	jal	800007e0 <panic>

0000000080003a24 <namei>:

struct inode*
namei(char *path)
{
    80003a24:	1101                	addi	sp,sp,-32
    80003a26:	ec06                	sd	ra,24(sp)
    80003a28:	e822                	sd	s0,16(sp)
    80003a2a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003a2c:	fe040613          	addi	a2,s0,-32
    80003a30:	4581                	li	a1,0
    80003a32:	e29ff0ef          	jal	8000385a <namex>
}
    80003a36:	60e2                	ld	ra,24(sp)
    80003a38:	6442                	ld	s0,16(sp)
    80003a3a:	6105                	addi	sp,sp,32
    80003a3c:	8082                	ret

0000000080003a3e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003a3e:	1141                	addi	sp,sp,-16
    80003a40:	e406                	sd	ra,8(sp)
    80003a42:	e022                	sd	s0,0(sp)
    80003a44:	0800                	addi	s0,sp,16
    80003a46:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003a48:	4585                	li	a1,1
    80003a4a:	e11ff0ef          	jal	8000385a <namex>
}
    80003a4e:	60a2                	ld	ra,8(sp)
    80003a50:	6402                	ld	s0,0(sp)
    80003a52:	0141                	addi	sp,sp,16
    80003a54:	8082                	ret

0000000080003a56 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003a56:	1101                	addi	sp,sp,-32
    80003a58:	ec06                	sd	ra,24(sp)
    80003a5a:	e822                	sd	s0,16(sp)
    80003a5c:	e426                	sd	s1,8(sp)
    80003a5e:	e04a                	sd	s2,0(sp)
    80003a60:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a62:	0001c917          	auipc	s2,0x1c
    80003a66:	0f690913          	addi	s2,s2,246 # 8001fb58 <log>
    80003a6a:	01892583          	lw	a1,24(s2)
    80003a6e:	02492503          	lw	a0,36(s2)
    80003a72:	8d0ff0ef          	jal	80002b42 <bread>
    80003a76:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003a78:	02892603          	lw	a2,40(s2)
    80003a7c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a7e:	00c05f63          	blez	a2,80003a9c <write_head+0x46>
    80003a82:	0001c717          	auipc	a4,0x1c
    80003a86:	10270713          	addi	a4,a4,258 # 8001fb84 <log+0x2c>
    80003a8a:	87aa                	mv	a5,a0
    80003a8c:	060a                	slli	a2,a2,0x2
    80003a8e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a90:	4314                	lw	a3,0(a4)
    80003a92:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a94:	0711                	addi	a4,a4,4
    80003a96:	0791                	addi	a5,a5,4
    80003a98:	fec79ce3          	bne	a5,a2,80003a90 <write_head+0x3a>
  }
  bwrite(buf);
    80003a9c:	8526                	mv	a0,s1
    80003a9e:	97aff0ef          	jal	80002c18 <bwrite>
  brelse(buf);
    80003aa2:	8526                	mv	a0,s1
    80003aa4:	9a6ff0ef          	jal	80002c4a <brelse>
}
    80003aa8:	60e2                	ld	ra,24(sp)
    80003aaa:	6442                	ld	s0,16(sp)
    80003aac:	64a2                	ld	s1,8(sp)
    80003aae:	6902                	ld	s2,0(sp)
    80003ab0:	6105                	addi	sp,sp,32
    80003ab2:	8082                	ret

0000000080003ab4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ab4:	0001c797          	auipc	a5,0x1c
    80003ab8:	0cc7a783          	lw	a5,204(a5) # 8001fb80 <log+0x28>
    80003abc:	0af05e63          	blez	a5,80003b78 <install_trans+0xc4>
{
    80003ac0:	715d                	addi	sp,sp,-80
    80003ac2:	e486                	sd	ra,72(sp)
    80003ac4:	e0a2                	sd	s0,64(sp)
    80003ac6:	fc26                	sd	s1,56(sp)
    80003ac8:	f84a                	sd	s2,48(sp)
    80003aca:	f44e                	sd	s3,40(sp)
    80003acc:	f052                	sd	s4,32(sp)
    80003ace:	ec56                	sd	s5,24(sp)
    80003ad0:	e85a                	sd	s6,16(sp)
    80003ad2:	e45e                	sd	s7,8(sp)
    80003ad4:	0880                	addi	s0,sp,80
    80003ad6:	8b2a                	mv	s6,a0
    80003ad8:	0001ca97          	auipc	s5,0x1c
    80003adc:	0aca8a93          	addi	s5,s5,172 # 8001fb84 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ae0:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ae2:	00004b97          	auipc	s7,0x4
    80003ae6:	a16b8b93          	addi	s7,s7,-1514 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003aea:	0001ca17          	auipc	s4,0x1c
    80003aee:	06ea0a13          	addi	s4,s4,110 # 8001fb58 <log>
    80003af2:	a025                	j	80003b1a <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003af4:	000aa603          	lw	a2,0(s5)
    80003af8:	85ce                	mv	a1,s3
    80003afa:	855e                	mv	a0,s7
    80003afc:	9fffc0ef          	jal	800004fa <printf>
    80003b00:	a839                	j	80003b1e <install_trans+0x6a>
    brelse(lbuf);
    80003b02:	854a                	mv	a0,s2
    80003b04:	946ff0ef          	jal	80002c4a <brelse>
    brelse(dbuf);
    80003b08:	8526                	mv	a0,s1
    80003b0a:	940ff0ef          	jal	80002c4a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b0e:	2985                	addiw	s3,s3,1
    80003b10:	0a91                	addi	s5,s5,4
    80003b12:	028a2783          	lw	a5,40(s4)
    80003b16:	04f9d663          	bge	s3,a5,80003b62 <install_trans+0xae>
    if(recovering) {
    80003b1a:	fc0b1de3          	bnez	s6,80003af4 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b1e:	018a2583          	lw	a1,24(s4)
    80003b22:	013585bb          	addw	a1,a1,s3
    80003b26:	2585                	addiw	a1,a1,1
    80003b28:	024a2503          	lw	a0,36(s4)
    80003b2c:	816ff0ef          	jal	80002b42 <bread>
    80003b30:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003b32:	000aa583          	lw	a1,0(s5)
    80003b36:	024a2503          	lw	a0,36(s4)
    80003b3a:	808ff0ef          	jal	80002b42 <bread>
    80003b3e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003b40:	40000613          	li	a2,1024
    80003b44:	05890593          	addi	a1,s2,88
    80003b48:	05850513          	addi	a0,a0,88
    80003b4c:	9b2fd0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003b50:	8526                	mv	a0,s1
    80003b52:	8c6ff0ef          	jal	80002c18 <bwrite>
    if(recovering == 0)
    80003b56:	fa0b16e3          	bnez	s6,80003b02 <install_trans+0x4e>
      bunpin(dbuf);
    80003b5a:	8526                	mv	a0,s1
    80003b5c:	9aaff0ef          	jal	80002d06 <bunpin>
    80003b60:	b74d                	j	80003b02 <install_trans+0x4e>
}
    80003b62:	60a6                	ld	ra,72(sp)
    80003b64:	6406                	ld	s0,64(sp)
    80003b66:	74e2                	ld	s1,56(sp)
    80003b68:	7942                	ld	s2,48(sp)
    80003b6a:	79a2                	ld	s3,40(sp)
    80003b6c:	7a02                	ld	s4,32(sp)
    80003b6e:	6ae2                	ld	s5,24(sp)
    80003b70:	6b42                	ld	s6,16(sp)
    80003b72:	6ba2                	ld	s7,8(sp)
    80003b74:	6161                	addi	sp,sp,80
    80003b76:	8082                	ret
    80003b78:	8082                	ret

0000000080003b7a <initlog>:
{
    80003b7a:	7179                	addi	sp,sp,-48
    80003b7c:	f406                	sd	ra,40(sp)
    80003b7e:	f022                	sd	s0,32(sp)
    80003b80:	ec26                	sd	s1,24(sp)
    80003b82:	e84a                	sd	s2,16(sp)
    80003b84:	e44e                	sd	s3,8(sp)
    80003b86:	1800                	addi	s0,sp,48
    80003b88:	892a                	mv	s2,a0
    80003b8a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b8c:	0001c497          	auipc	s1,0x1c
    80003b90:	fcc48493          	addi	s1,s1,-52 # 8001fb58 <log>
    80003b94:	00004597          	auipc	a1,0x4
    80003b98:	98458593          	addi	a1,a1,-1660 # 80007518 <etext+0x518>
    80003b9c:	8526                	mv	a0,s1
    80003b9e:	fb1fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003ba2:	0149a583          	lw	a1,20(s3)
    80003ba6:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003ba8:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003bac:	854a                	mv	a0,s2
    80003bae:	f95fe0ef          	jal	80002b42 <bread>
  log.lh.n = lh->n;
    80003bb2:	4d30                	lw	a2,88(a0)
    80003bb4:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003bb6:	00c05f63          	blez	a2,80003bd4 <initlog+0x5a>
    80003bba:	87aa                	mv	a5,a0
    80003bbc:	0001c717          	auipc	a4,0x1c
    80003bc0:	fc870713          	addi	a4,a4,-56 # 8001fb84 <log+0x2c>
    80003bc4:	060a                	slli	a2,a2,0x2
    80003bc6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003bc8:	4ff4                	lw	a3,92(a5)
    80003bca:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003bcc:	0791                	addi	a5,a5,4
    80003bce:	0711                	addi	a4,a4,4
    80003bd0:	fec79ce3          	bne	a5,a2,80003bc8 <initlog+0x4e>
  brelse(buf);
    80003bd4:	876ff0ef          	jal	80002c4a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003bd8:	4505                	li	a0,1
    80003bda:	edbff0ef          	jal	80003ab4 <install_trans>
  log.lh.n = 0;
    80003bde:	0001c797          	auipc	a5,0x1c
    80003be2:	fa07a123          	sw	zero,-94(a5) # 8001fb80 <log+0x28>
  write_head(); // clear the log
    80003be6:	e71ff0ef          	jal	80003a56 <write_head>
}
    80003bea:	70a2                	ld	ra,40(sp)
    80003bec:	7402                	ld	s0,32(sp)
    80003bee:	64e2                	ld	s1,24(sp)
    80003bf0:	6942                	ld	s2,16(sp)
    80003bf2:	69a2                	ld	s3,8(sp)
    80003bf4:	6145                	addi	sp,sp,48
    80003bf6:	8082                	ret

0000000080003bf8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003bf8:	1101                	addi	sp,sp,-32
    80003bfa:	ec06                	sd	ra,24(sp)
    80003bfc:	e822                	sd	s0,16(sp)
    80003bfe:	e426                	sd	s1,8(sp)
    80003c00:	e04a                	sd	s2,0(sp)
    80003c02:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003c04:	0001c517          	auipc	a0,0x1c
    80003c08:	f5450513          	addi	a0,a0,-172 # 8001fb58 <log>
    80003c0c:	fc3fc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003c10:	0001c497          	auipc	s1,0x1c
    80003c14:	f4848493          	addi	s1,s1,-184 # 8001fb58 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003c18:	4979                	li	s2,30
    80003c1a:	a029                	j	80003c24 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003c1c:	85a6                	mv	a1,s1
    80003c1e:	8526                	mv	a0,s1
    80003c20:	ac0fe0ef          	jal	80001ee0 <sleep>
    if(log.committing){
    80003c24:	509c                	lw	a5,32(s1)
    80003c26:	fbfd                	bnez	a5,80003c1c <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003c28:	4cd8                	lw	a4,28(s1)
    80003c2a:	2705                	addiw	a4,a4,1
    80003c2c:	0027179b          	slliw	a5,a4,0x2
    80003c30:	9fb9                	addw	a5,a5,a4
    80003c32:	0017979b          	slliw	a5,a5,0x1
    80003c36:	5494                	lw	a3,40(s1)
    80003c38:	9fb5                	addw	a5,a5,a3
    80003c3a:	00f95763          	bge	s2,a5,80003c48 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003c3e:	85a6                	mv	a1,s1
    80003c40:	8526                	mv	a0,s1
    80003c42:	a9efe0ef          	jal	80001ee0 <sleep>
    80003c46:	bff9                	j	80003c24 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003c48:	0001c517          	auipc	a0,0x1c
    80003c4c:	f1050513          	addi	a0,a0,-240 # 8001fb58 <log>
    80003c50:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003c52:	814fd0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003c56:	60e2                	ld	ra,24(sp)
    80003c58:	6442                	ld	s0,16(sp)
    80003c5a:	64a2                	ld	s1,8(sp)
    80003c5c:	6902                	ld	s2,0(sp)
    80003c5e:	6105                	addi	sp,sp,32
    80003c60:	8082                	ret

0000000080003c62 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003c62:	7139                	addi	sp,sp,-64
    80003c64:	fc06                	sd	ra,56(sp)
    80003c66:	f822                	sd	s0,48(sp)
    80003c68:	f426                	sd	s1,40(sp)
    80003c6a:	f04a                	sd	s2,32(sp)
    80003c6c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003c6e:	0001c497          	auipc	s1,0x1c
    80003c72:	eea48493          	addi	s1,s1,-278 # 8001fb58 <log>
    80003c76:	8526                	mv	a0,s1
    80003c78:	f57fc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003c7c:	4cdc                	lw	a5,28(s1)
    80003c7e:	37fd                	addiw	a5,a5,-1
    80003c80:	0007891b          	sext.w	s2,a5
    80003c84:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003c86:	509c                	lw	a5,32(s1)
    80003c88:	ef9d                	bnez	a5,80003cc6 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003c8a:	04091763          	bnez	s2,80003cd8 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003c8e:	0001c497          	auipc	s1,0x1c
    80003c92:	eca48493          	addi	s1,s1,-310 # 8001fb58 <log>
    80003c96:	4785                	li	a5,1
    80003c98:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c9a:	8526                	mv	a0,s1
    80003c9c:	fcbfc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ca0:	549c                	lw	a5,40(s1)
    80003ca2:	04f04b63          	bgtz	a5,80003cf8 <end_op+0x96>
    acquire(&log.lock);
    80003ca6:	0001c497          	auipc	s1,0x1c
    80003caa:	eb248493          	addi	s1,s1,-334 # 8001fb58 <log>
    80003cae:	8526                	mv	a0,s1
    80003cb0:	f1ffc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003cb4:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003cb8:	8526                	mv	a0,s1
    80003cba:	a72fe0ef          	jal	80001f2c <wakeup>
    release(&log.lock);
    80003cbe:	8526                	mv	a0,s1
    80003cc0:	fa7fc0ef          	jal	80000c66 <release>
}
    80003cc4:	a025                	j	80003cec <end_op+0x8a>
    80003cc6:	ec4e                	sd	s3,24(sp)
    80003cc8:	e852                	sd	s4,16(sp)
    80003cca:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003ccc:	00004517          	auipc	a0,0x4
    80003cd0:	85450513          	addi	a0,a0,-1964 # 80007520 <etext+0x520>
    80003cd4:	b0dfc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003cd8:	0001c497          	auipc	s1,0x1c
    80003cdc:	e8048493          	addi	s1,s1,-384 # 8001fb58 <log>
    80003ce0:	8526                	mv	a0,s1
    80003ce2:	a4afe0ef          	jal	80001f2c <wakeup>
  release(&log.lock);
    80003ce6:	8526                	mv	a0,s1
    80003ce8:	f7ffc0ef          	jal	80000c66 <release>
}
    80003cec:	70e2                	ld	ra,56(sp)
    80003cee:	7442                	ld	s0,48(sp)
    80003cf0:	74a2                	ld	s1,40(sp)
    80003cf2:	7902                	ld	s2,32(sp)
    80003cf4:	6121                	addi	sp,sp,64
    80003cf6:	8082                	ret
    80003cf8:	ec4e                	sd	s3,24(sp)
    80003cfa:	e852                	sd	s4,16(sp)
    80003cfc:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cfe:	0001ca97          	auipc	s5,0x1c
    80003d02:	e86a8a93          	addi	s5,s5,-378 # 8001fb84 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003d06:	0001ca17          	auipc	s4,0x1c
    80003d0a:	e52a0a13          	addi	s4,s4,-430 # 8001fb58 <log>
    80003d0e:	018a2583          	lw	a1,24(s4)
    80003d12:	012585bb          	addw	a1,a1,s2
    80003d16:	2585                	addiw	a1,a1,1
    80003d18:	024a2503          	lw	a0,36(s4)
    80003d1c:	e27fe0ef          	jal	80002b42 <bread>
    80003d20:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003d22:	000aa583          	lw	a1,0(s5)
    80003d26:	024a2503          	lw	a0,36(s4)
    80003d2a:	e19fe0ef          	jal	80002b42 <bread>
    80003d2e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003d30:	40000613          	li	a2,1024
    80003d34:	05850593          	addi	a1,a0,88
    80003d38:	05848513          	addi	a0,s1,88
    80003d3c:	fc3fc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003d40:	8526                	mv	a0,s1
    80003d42:	ed7fe0ef          	jal	80002c18 <bwrite>
    brelse(from);
    80003d46:	854e                	mv	a0,s3
    80003d48:	f03fe0ef          	jal	80002c4a <brelse>
    brelse(to);
    80003d4c:	8526                	mv	a0,s1
    80003d4e:	efdfe0ef          	jal	80002c4a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d52:	2905                	addiw	s2,s2,1
    80003d54:	0a91                	addi	s5,s5,4
    80003d56:	028a2783          	lw	a5,40(s4)
    80003d5a:	faf94ae3          	blt	s2,a5,80003d0e <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003d5e:	cf9ff0ef          	jal	80003a56 <write_head>
    install_trans(0); // Now install writes to home locations
    80003d62:	4501                	li	a0,0
    80003d64:	d51ff0ef          	jal	80003ab4 <install_trans>
    log.lh.n = 0;
    80003d68:	0001c797          	auipc	a5,0x1c
    80003d6c:	e007ac23          	sw	zero,-488(a5) # 8001fb80 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003d70:	ce7ff0ef          	jal	80003a56 <write_head>
    80003d74:	69e2                	ld	s3,24(sp)
    80003d76:	6a42                	ld	s4,16(sp)
    80003d78:	6aa2                	ld	s5,8(sp)
    80003d7a:	b735                	j	80003ca6 <end_op+0x44>

0000000080003d7c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003d7c:	1101                	addi	sp,sp,-32
    80003d7e:	ec06                	sd	ra,24(sp)
    80003d80:	e822                	sd	s0,16(sp)
    80003d82:	e426                	sd	s1,8(sp)
    80003d84:	e04a                	sd	s2,0(sp)
    80003d86:	1000                	addi	s0,sp,32
    80003d88:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d8a:	0001c917          	auipc	s2,0x1c
    80003d8e:	dce90913          	addi	s2,s2,-562 # 8001fb58 <log>
    80003d92:	854a                	mv	a0,s2
    80003d94:	e3bfc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003d98:	02892603          	lw	a2,40(s2)
    80003d9c:	47f5                	li	a5,29
    80003d9e:	04c7cc63          	blt	a5,a2,80003df6 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003da2:	0001c797          	auipc	a5,0x1c
    80003da6:	dd27a783          	lw	a5,-558(a5) # 8001fb74 <log+0x1c>
    80003daa:	04f05c63          	blez	a5,80003e02 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003dae:	4781                	li	a5,0
    80003db0:	04c05f63          	blez	a2,80003e0e <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003db4:	44cc                	lw	a1,12(s1)
    80003db6:	0001c717          	auipc	a4,0x1c
    80003dba:	dce70713          	addi	a4,a4,-562 # 8001fb84 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003dbe:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003dc0:	4314                	lw	a3,0(a4)
    80003dc2:	04b68663          	beq	a3,a1,80003e0e <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003dc6:	2785                	addiw	a5,a5,1
    80003dc8:	0711                	addi	a4,a4,4
    80003dca:	fef61be3          	bne	a2,a5,80003dc0 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003dce:	0621                	addi	a2,a2,8
    80003dd0:	060a                	slli	a2,a2,0x2
    80003dd2:	0001c797          	auipc	a5,0x1c
    80003dd6:	d8678793          	addi	a5,a5,-634 # 8001fb58 <log>
    80003dda:	97b2                	add	a5,a5,a2
    80003ddc:	44d8                	lw	a4,12(s1)
    80003dde:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003de0:	8526                	mv	a0,s1
    80003de2:	ef1fe0ef          	jal	80002cd2 <bpin>
    log.lh.n++;
    80003de6:	0001c717          	auipc	a4,0x1c
    80003dea:	d7270713          	addi	a4,a4,-654 # 8001fb58 <log>
    80003dee:	571c                	lw	a5,40(a4)
    80003df0:	2785                	addiw	a5,a5,1
    80003df2:	d71c                	sw	a5,40(a4)
    80003df4:	a80d                	j	80003e26 <log_write+0xaa>
    panic("too big a transaction");
    80003df6:	00003517          	auipc	a0,0x3
    80003dfa:	73a50513          	addi	a0,a0,1850 # 80007530 <etext+0x530>
    80003dfe:	9e3fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80003e02:	00003517          	auipc	a0,0x3
    80003e06:	74650513          	addi	a0,a0,1862 # 80007548 <etext+0x548>
    80003e0a:	9d7fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80003e0e:	00878693          	addi	a3,a5,8
    80003e12:	068a                	slli	a3,a3,0x2
    80003e14:	0001c717          	auipc	a4,0x1c
    80003e18:	d4470713          	addi	a4,a4,-700 # 8001fb58 <log>
    80003e1c:	9736                	add	a4,a4,a3
    80003e1e:	44d4                	lw	a3,12(s1)
    80003e20:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003e22:	faf60fe3          	beq	a2,a5,80003de0 <log_write+0x64>
  }
  release(&log.lock);
    80003e26:	0001c517          	auipc	a0,0x1c
    80003e2a:	d3250513          	addi	a0,a0,-718 # 8001fb58 <log>
    80003e2e:	e39fc0ef          	jal	80000c66 <release>
}
    80003e32:	60e2                	ld	ra,24(sp)
    80003e34:	6442                	ld	s0,16(sp)
    80003e36:	64a2                	ld	s1,8(sp)
    80003e38:	6902                	ld	s2,0(sp)
    80003e3a:	6105                	addi	sp,sp,32
    80003e3c:	8082                	ret

0000000080003e3e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003e3e:	1101                	addi	sp,sp,-32
    80003e40:	ec06                	sd	ra,24(sp)
    80003e42:	e822                	sd	s0,16(sp)
    80003e44:	e426                	sd	s1,8(sp)
    80003e46:	e04a                	sd	s2,0(sp)
    80003e48:	1000                	addi	s0,sp,32
    80003e4a:	84aa                	mv	s1,a0
    80003e4c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003e4e:	00003597          	auipc	a1,0x3
    80003e52:	71a58593          	addi	a1,a1,1818 # 80007568 <etext+0x568>
    80003e56:	0521                	addi	a0,a0,8
    80003e58:	cf7fc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80003e5c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003e60:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e64:	0204a423          	sw	zero,40(s1)
}
    80003e68:	60e2                	ld	ra,24(sp)
    80003e6a:	6442                	ld	s0,16(sp)
    80003e6c:	64a2                	ld	s1,8(sp)
    80003e6e:	6902                	ld	s2,0(sp)
    80003e70:	6105                	addi	sp,sp,32
    80003e72:	8082                	ret

0000000080003e74 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003e74:	1101                	addi	sp,sp,-32
    80003e76:	ec06                	sd	ra,24(sp)
    80003e78:	e822                	sd	s0,16(sp)
    80003e7a:	e426                	sd	s1,8(sp)
    80003e7c:	e04a                	sd	s2,0(sp)
    80003e7e:	1000                	addi	s0,sp,32
    80003e80:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e82:	00850913          	addi	s2,a0,8
    80003e86:	854a                	mv	a0,s2
    80003e88:	d47fc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80003e8c:	409c                	lw	a5,0(s1)
    80003e8e:	c799                	beqz	a5,80003e9c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003e90:	85ca                	mv	a1,s2
    80003e92:	8526                	mv	a0,s1
    80003e94:	84cfe0ef          	jal	80001ee0 <sleep>
  while (lk->locked) {
    80003e98:	409c                	lw	a5,0(s1)
    80003e9a:	fbfd                	bnez	a5,80003e90 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003e9c:	4785                	li	a5,1
    80003e9e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003ea0:	a2ffd0ef          	jal	800018ce <myproc>
    80003ea4:	591c                	lw	a5,48(a0)
    80003ea6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003ea8:	854a                	mv	a0,s2
    80003eaa:	dbdfc0ef          	jal	80000c66 <release>
}
    80003eae:	60e2                	ld	ra,24(sp)
    80003eb0:	6442                	ld	s0,16(sp)
    80003eb2:	64a2                	ld	s1,8(sp)
    80003eb4:	6902                	ld	s2,0(sp)
    80003eb6:	6105                	addi	sp,sp,32
    80003eb8:	8082                	ret

0000000080003eba <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003eba:	1101                	addi	sp,sp,-32
    80003ebc:	ec06                	sd	ra,24(sp)
    80003ebe:	e822                	sd	s0,16(sp)
    80003ec0:	e426                	sd	s1,8(sp)
    80003ec2:	e04a                	sd	s2,0(sp)
    80003ec4:	1000                	addi	s0,sp,32
    80003ec6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003ec8:	00850913          	addi	s2,a0,8
    80003ecc:	854a                	mv	a0,s2
    80003ece:	d01fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80003ed2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003ed6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003eda:	8526                	mv	a0,s1
    80003edc:	850fe0ef          	jal	80001f2c <wakeup>
  release(&lk->lk);
    80003ee0:	854a                	mv	a0,s2
    80003ee2:	d85fc0ef          	jal	80000c66 <release>
}
    80003ee6:	60e2                	ld	ra,24(sp)
    80003ee8:	6442                	ld	s0,16(sp)
    80003eea:	64a2                	ld	s1,8(sp)
    80003eec:	6902                	ld	s2,0(sp)
    80003eee:	6105                	addi	sp,sp,32
    80003ef0:	8082                	ret

0000000080003ef2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003ef2:	7179                	addi	sp,sp,-48
    80003ef4:	f406                	sd	ra,40(sp)
    80003ef6:	f022                	sd	s0,32(sp)
    80003ef8:	ec26                	sd	s1,24(sp)
    80003efa:	e84a                	sd	s2,16(sp)
    80003efc:	1800                	addi	s0,sp,48
    80003efe:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003f00:	00850913          	addi	s2,a0,8
    80003f04:	854a                	mv	a0,s2
    80003f06:	cc9fc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f0a:	409c                	lw	a5,0(s1)
    80003f0c:	ef81                	bnez	a5,80003f24 <holdingsleep+0x32>
    80003f0e:	4481                	li	s1,0
  release(&lk->lk);
    80003f10:	854a                	mv	a0,s2
    80003f12:	d55fc0ef          	jal	80000c66 <release>
  return r;
}
    80003f16:	8526                	mv	a0,s1
    80003f18:	70a2                	ld	ra,40(sp)
    80003f1a:	7402                	ld	s0,32(sp)
    80003f1c:	64e2                	ld	s1,24(sp)
    80003f1e:	6942                	ld	s2,16(sp)
    80003f20:	6145                	addi	sp,sp,48
    80003f22:	8082                	ret
    80003f24:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f26:	0284a983          	lw	s3,40(s1)
    80003f2a:	9a5fd0ef          	jal	800018ce <myproc>
    80003f2e:	5904                	lw	s1,48(a0)
    80003f30:	413484b3          	sub	s1,s1,s3
    80003f34:	0014b493          	seqz	s1,s1
    80003f38:	69a2                	ld	s3,8(sp)
    80003f3a:	bfd9                	j	80003f10 <holdingsleep+0x1e>

0000000080003f3c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003f3c:	1141                	addi	sp,sp,-16
    80003f3e:	e406                	sd	ra,8(sp)
    80003f40:	e022                	sd	s0,0(sp)
    80003f42:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003f44:	00003597          	auipc	a1,0x3
    80003f48:	63458593          	addi	a1,a1,1588 # 80007578 <etext+0x578>
    80003f4c:	0001c517          	auipc	a0,0x1c
    80003f50:	d5450513          	addi	a0,a0,-684 # 8001fca0 <ftable>
    80003f54:	bfbfc0ef          	jal	80000b4e <initlock>
}
    80003f58:	60a2                	ld	ra,8(sp)
    80003f5a:	6402                	ld	s0,0(sp)
    80003f5c:	0141                	addi	sp,sp,16
    80003f5e:	8082                	ret

0000000080003f60 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003f60:	1101                	addi	sp,sp,-32
    80003f62:	ec06                	sd	ra,24(sp)
    80003f64:	e822                	sd	s0,16(sp)
    80003f66:	e426                	sd	s1,8(sp)
    80003f68:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f6a:	0001c517          	auipc	a0,0x1c
    80003f6e:	d3650513          	addi	a0,a0,-714 # 8001fca0 <ftable>
    80003f72:	c5dfc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f76:	0001c497          	auipc	s1,0x1c
    80003f7a:	d4248493          	addi	s1,s1,-702 # 8001fcb8 <ftable+0x18>
    80003f7e:	0001d717          	auipc	a4,0x1d
    80003f82:	cda70713          	addi	a4,a4,-806 # 80020c58 <disk>
    if(f->ref == 0){
    80003f86:	40dc                	lw	a5,4(s1)
    80003f88:	cf89                	beqz	a5,80003fa2 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f8a:	02848493          	addi	s1,s1,40
    80003f8e:	fee49ce3          	bne	s1,a4,80003f86 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003f92:	0001c517          	auipc	a0,0x1c
    80003f96:	d0e50513          	addi	a0,a0,-754 # 8001fca0 <ftable>
    80003f9a:	ccdfc0ef          	jal	80000c66 <release>
  return 0;
    80003f9e:	4481                	li	s1,0
    80003fa0:	a809                	j	80003fb2 <filealloc+0x52>
      f->ref = 1;
    80003fa2:	4785                	li	a5,1
    80003fa4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003fa6:	0001c517          	auipc	a0,0x1c
    80003faa:	cfa50513          	addi	a0,a0,-774 # 8001fca0 <ftable>
    80003fae:	cb9fc0ef          	jal	80000c66 <release>
}
    80003fb2:	8526                	mv	a0,s1
    80003fb4:	60e2                	ld	ra,24(sp)
    80003fb6:	6442                	ld	s0,16(sp)
    80003fb8:	64a2                	ld	s1,8(sp)
    80003fba:	6105                	addi	sp,sp,32
    80003fbc:	8082                	ret

0000000080003fbe <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003fbe:	1101                	addi	sp,sp,-32
    80003fc0:	ec06                	sd	ra,24(sp)
    80003fc2:	e822                	sd	s0,16(sp)
    80003fc4:	e426                	sd	s1,8(sp)
    80003fc6:	1000                	addi	s0,sp,32
    80003fc8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003fca:	0001c517          	auipc	a0,0x1c
    80003fce:	cd650513          	addi	a0,a0,-810 # 8001fca0 <ftable>
    80003fd2:	bfdfc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80003fd6:	40dc                	lw	a5,4(s1)
    80003fd8:	02f05063          	blez	a5,80003ff8 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003fdc:	2785                	addiw	a5,a5,1
    80003fde:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003fe0:	0001c517          	auipc	a0,0x1c
    80003fe4:	cc050513          	addi	a0,a0,-832 # 8001fca0 <ftable>
    80003fe8:	c7ffc0ef          	jal	80000c66 <release>
  return f;
}
    80003fec:	8526                	mv	a0,s1
    80003fee:	60e2                	ld	ra,24(sp)
    80003ff0:	6442                	ld	s0,16(sp)
    80003ff2:	64a2                	ld	s1,8(sp)
    80003ff4:	6105                	addi	sp,sp,32
    80003ff6:	8082                	ret
    panic("filedup");
    80003ff8:	00003517          	auipc	a0,0x3
    80003ffc:	58850513          	addi	a0,a0,1416 # 80007580 <etext+0x580>
    80004000:	fe0fc0ef          	jal	800007e0 <panic>

0000000080004004 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004004:	7139                	addi	sp,sp,-64
    80004006:	fc06                	sd	ra,56(sp)
    80004008:	f822                	sd	s0,48(sp)
    8000400a:	f426                	sd	s1,40(sp)
    8000400c:	0080                	addi	s0,sp,64
    8000400e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004010:	0001c517          	auipc	a0,0x1c
    80004014:	c9050513          	addi	a0,a0,-880 # 8001fca0 <ftable>
    80004018:	bb7fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    8000401c:	40dc                	lw	a5,4(s1)
    8000401e:	04f05a63          	blez	a5,80004072 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004022:	37fd                	addiw	a5,a5,-1
    80004024:	0007871b          	sext.w	a4,a5
    80004028:	c0dc                	sw	a5,4(s1)
    8000402a:	04e04e63          	bgtz	a4,80004086 <fileclose+0x82>
    8000402e:	f04a                	sd	s2,32(sp)
    80004030:	ec4e                	sd	s3,24(sp)
    80004032:	e852                	sd	s4,16(sp)
    80004034:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004036:	0004a903          	lw	s2,0(s1)
    8000403a:	0094ca83          	lbu	s5,9(s1)
    8000403e:	0104ba03          	ld	s4,16(s1)
    80004042:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004046:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000404a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000404e:	0001c517          	auipc	a0,0x1c
    80004052:	c5250513          	addi	a0,a0,-942 # 8001fca0 <ftable>
    80004056:	c11fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    8000405a:	4785                	li	a5,1
    8000405c:	04f90063          	beq	s2,a5,8000409c <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004060:	3979                	addiw	s2,s2,-2
    80004062:	4785                	li	a5,1
    80004064:	0527f563          	bgeu	a5,s2,800040ae <fileclose+0xaa>
    80004068:	7902                	ld	s2,32(sp)
    8000406a:	69e2                	ld	s3,24(sp)
    8000406c:	6a42                	ld	s4,16(sp)
    8000406e:	6aa2                	ld	s5,8(sp)
    80004070:	a00d                	j	80004092 <fileclose+0x8e>
    80004072:	f04a                	sd	s2,32(sp)
    80004074:	ec4e                	sd	s3,24(sp)
    80004076:	e852                	sd	s4,16(sp)
    80004078:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000407a:	00003517          	auipc	a0,0x3
    8000407e:	50e50513          	addi	a0,a0,1294 # 80007588 <etext+0x588>
    80004082:	f5efc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    80004086:	0001c517          	auipc	a0,0x1c
    8000408a:	c1a50513          	addi	a0,a0,-998 # 8001fca0 <ftable>
    8000408e:	bd9fc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004092:	70e2                	ld	ra,56(sp)
    80004094:	7442                	ld	s0,48(sp)
    80004096:	74a2                	ld	s1,40(sp)
    80004098:	6121                	addi	sp,sp,64
    8000409a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000409c:	85d6                	mv	a1,s5
    8000409e:	8552                	mv	a0,s4
    800040a0:	336000ef          	jal	800043d6 <pipeclose>
    800040a4:	7902                	ld	s2,32(sp)
    800040a6:	69e2                	ld	s3,24(sp)
    800040a8:	6a42                	ld	s4,16(sp)
    800040aa:	6aa2                	ld	s5,8(sp)
    800040ac:	b7dd                	j	80004092 <fileclose+0x8e>
    begin_op();
    800040ae:	b4bff0ef          	jal	80003bf8 <begin_op>
    iput(ff.ip);
    800040b2:	854e                	mv	a0,s3
    800040b4:	adcff0ef          	jal	80003390 <iput>
    end_op();
    800040b8:	babff0ef          	jal	80003c62 <end_op>
    800040bc:	7902                	ld	s2,32(sp)
    800040be:	69e2                	ld	s3,24(sp)
    800040c0:	6a42                	ld	s4,16(sp)
    800040c2:	6aa2                	ld	s5,8(sp)
    800040c4:	b7f9                	j	80004092 <fileclose+0x8e>

00000000800040c6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800040c6:	715d                	addi	sp,sp,-80
    800040c8:	e486                	sd	ra,72(sp)
    800040ca:	e0a2                	sd	s0,64(sp)
    800040cc:	fc26                	sd	s1,56(sp)
    800040ce:	f44e                	sd	s3,40(sp)
    800040d0:	0880                	addi	s0,sp,80
    800040d2:	84aa                	mv	s1,a0
    800040d4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800040d6:	ff8fd0ef          	jal	800018ce <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800040da:	409c                	lw	a5,0(s1)
    800040dc:	37f9                	addiw	a5,a5,-2
    800040de:	4705                	li	a4,1
    800040e0:	04f76063          	bltu	a4,a5,80004120 <filestat+0x5a>
    800040e4:	f84a                	sd	s2,48(sp)
    800040e6:	892a                	mv	s2,a0
    ilock(f->ip);
    800040e8:	6c88                	ld	a0,24(s1)
    800040ea:	924ff0ef          	jal	8000320e <ilock>
    stati(f->ip, &st);
    800040ee:	fb840593          	addi	a1,s0,-72
    800040f2:	6c88                	ld	a0,24(s1)
    800040f4:	c80ff0ef          	jal	80003574 <stati>
    iunlock(f->ip);
    800040f8:	6c88                	ld	a0,24(s1)
    800040fa:	9c2ff0ef          	jal	800032bc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800040fe:	46e1                	li	a3,24
    80004100:	fb840613          	addi	a2,s0,-72
    80004104:	85ce                	mv	a1,s3
    80004106:	05093503          	ld	a0,80(s2)
    8000410a:	cd8fd0ef          	jal	800015e2 <copyout>
    8000410e:	41f5551b          	sraiw	a0,a0,0x1f
    80004112:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004114:	60a6                	ld	ra,72(sp)
    80004116:	6406                	ld	s0,64(sp)
    80004118:	74e2                	ld	s1,56(sp)
    8000411a:	79a2                	ld	s3,40(sp)
    8000411c:	6161                	addi	sp,sp,80
    8000411e:	8082                	ret
  return -1;
    80004120:	557d                	li	a0,-1
    80004122:	bfcd                	j	80004114 <filestat+0x4e>

0000000080004124 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004124:	7179                	addi	sp,sp,-48
    80004126:	f406                	sd	ra,40(sp)
    80004128:	f022                	sd	s0,32(sp)
    8000412a:	e84a                	sd	s2,16(sp)
    8000412c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000412e:	00854783          	lbu	a5,8(a0)
    80004132:	cfd1                	beqz	a5,800041ce <fileread+0xaa>
    80004134:	ec26                	sd	s1,24(sp)
    80004136:	e44e                	sd	s3,8(sp)
    80004138:	84aa                	mv	s1,a0
    8000413a:	89ae                	mv	s3,a1
    8000413c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000413e:	411c                	lw	a5,0(a0)
    80004140:	4705                	li	a4,1
    80004142:	04e78363          	beq	a5,a4,80004188 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004146:	470d                	li	a4,3
    80004148:	04e78763          	beq	a5,a4,80004196 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000414c:	4709                	li	a4,2
    8000414e:	06e79a63          	bne	a5,a4,800041c2 <fileread+0x9e>
    ilock(f->ip);
    80004152:	6d08                	ld	a0,24(a0)
    80004154:	8baff0ef          	jal	8000320e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004158:	874a                	mv	a4,s2
    8000415a:	5094                	lw	a3,32(s1)
    8000415c:	864e                	mv	a2,s3
    8000415e:	4585                	li	a1,1
    80004160:	6c88                	ld	a0,24(s1)
    80004162:	c3cff0ef          	jal	8000359e <readi>
    80004166:	892a                	mv	s2,a0
    80004168:	00a05563          	blez	a0,80004172 <fileread+0x4e>
      f->off += r;
    8000416c:	509c                	lw	a5,32(s1)
    8000416e:	9fa9                	addw	a5,a5,a0
    80004170:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004172:	6c88                	ld	a0,24(s1)
    80004174:	948ff0ef          	jal	800032bc <iunlock>
    80004178:	64e2                	ld	s1,24(sp)
    8000417a:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000417c:	854a                	mv	a0,s2
    8000417e:	70a2                	ld	ra,40(sp)
    80004180:	7402                	ld	s0,32(sp)
    80004182:	6942                	ld	s2,16(sp)
    80004184:	6145                	addi	sp,sp,48
    80004186:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004188:	6908                	ld	a0,16(a0)
    8000418a:	388000ef          	jal	80004512 <piperead>
    8000418e:	892a                	mv	s2,a0
    80004190:	64e2                	ld	s1,24(sp)
    80004192:	69a2                	ld	s3,8(sp)
    80004194:	b7e5                	j	8000417c <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004196:	02451783          	lh	a5,36(a0)
    8000419a:	03079693          	slli	a3,a5,0x30
    8000419e:	92c1                	srli	a3,a3,0x30
    800041a0:	4725                	li	a4,9
    800041a2:	02d76863          	bltu	a4,a3,800041d2 <fileread+0xae>
    800041a6:	0792                	slli	a5,a5,0x4
    800041a8:	0001c717          	auipc	a4,0x1c
    800041ac:	a5870713          	addi	a4,a4,-1448 # 8001fc00 <devsw>
    800041b0:	97ba                	add	a5,a5,a4
    800041b2:	639c                	ld	a5,0(a5)
    800041b4:	c39d                	beqz	a5,800041da <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800041b6:	4505                	li	a0,1
    800041b8:	9782                	jalr	a5
    800041ba:	892a                	mv	s2,a0
    800041bc:	64e2                	ld	s1,24(sp)
    800041be:	69a2                	ld	s3,8(sp)
    800041c0:	bf75                	j	8000417c <fileread+0x58>
    panic("fileread");
    800041c2:	00003517          	auipc	a0,0x3
    800041c6:	3d650513          	addi	a0,a0,982 # 80007598 <etext+0x598>
    800041ca:	e16fc0ef          	jal	800007e0 <panic>
    return -1;
    800041ce:	597d                	li	s2,-1
    800041d0:	b775                	j	8000417c <fileread+0x58>
      return -1;
    800041d2:	597d                	li	s2,-1
    800041d4:	64e2                	ld	s1,24(sp)
    800041d6:	69a2                	ld	s3,8(sp)
    800041d8:	b755                	j	8000417c <fileread+0x58>
    800041da:	597d                	li	s2,-1
    800041dc:	64e2                	ld	s1,24(sp)
    800041de:	69a2                	ld	s3,8(sp)
    800041e0:	bf71                	j	8000417c <fileread+0x58>

00000000800041e2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800041e2:	00954783          	lbu	a5,9(a0)
    800041e6:	10078b63          	beqz	a5,800042fc <filewrite+0x11a>
{
    800041ea:	715d                	addi	sp,sp,-80
    800041ec:	e486                	sd	ra,72(sp)
    800041ee:	e0a2                	sd	s0,64(sp)
    800041f0:	f84a                	sd	s2,48(sp)
    800041f2:	f052                	sd	s4,32(sp)
    800041f4:	e85a                	sd	s6,16(sp)
    800041f6:	0880                	addi	s0,sp,80
    800041f8:	892a                	mv	s2,a0
    800041fa:	8b2e                	mv	s6,a1
    800041fc:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800041fe:	411c                	lw	a5,0(a0)
    80004200:	4705                	li	a4,1
    80004202:	02e78763          	beq	a5,a4,80004230 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004206:	470d                	li	a4,3
    80004208:	02e78863          	beq	a5,a4,80004238 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000420c:	4709                	li	a4,2
    8000420e:	0ce79c63          	bne	a5,a4,800042e6 <filewrite+0x104>
    80004212:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004214:	0ac05863          	blez	a2,800042c4 <filewrite+0xe2>
    80004218:	fc26                	sd	s1,56(sp)
    8000421a:	ec56                	sd	s5,24(sp)
    8000421c:	e45e                	sd	s7,8(sp)
    8000421e:	e062                	sd	s8,0(sp)
    int i = 0;
    80004220:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004222:	6b85                	lui	s7,0x1
    80004224:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004228:	6c05                	lui	s8,0x1
    8000422a:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000422e:	a8b5                	j	800042aa <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004230:	6908                	ld	a0,16(a0)
    80004232:	1fc000ef          	jal	8000442e <pipewrite>
    80004236:	a04d                	j	800042d8 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004238:	02451783          	lh	a5,36(a0)
    8000423c:	03079693          	slli	a3,a5,0x30
    80004240:	92c1                	srli	a3,a3,0x30
    80004242:	4725                	li	a4,9
    80004244:	0ad76e63          	bltu	a4,a3,80004300 <filewrite+0x11e>
    80004248:	0792                	slli	a5,a5,0x4
    8000424a:	0001c717          	auipc	a4,0x1c
    8000424e:	9b670713          	addi	a4,a4,-1610 # 8001fc00 <devsw>
    80004252:	97ba                	add	a5,a5,a4
    80004254:	679c                	ld	a5,8(a5)
    80004256:	c7dd                	beqz	a5,80004304 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004258:	4505                	li	a0,1
    8000425a:	9782                	jalr	a5
    8000425c:	a8b5                	j	800042d8 <filewrite+0xf6>
      if(n1 > max)
    8000425e:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004262:	997ff0ef          	jal	80003bf8 <begin_op>
      ilock(f->ip);
    80004266:	01893503          	ld	a0,24(s2)
    8000426a:	fa5fe0ef          	jal	8000320e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000426e:	8756                	mv	a4,s5
    80004270:	02092683          	lw	a3,32(s2)
    80004274:	01698633          	add	a2,s3,s6
    80004278:	4585                	li	a1,1
    8000427a:	01893503          	ld	a0,24(s2)
    8000427e:	c1cff0ef          	jal	8000369a <writei>
    80004282:	84aa                	mv	s1,a0
    80004284:	00a05763          	blez	a0,80004292 <filewrite+0xb0>
        f->off += r;
    80004288:	02092783          	lw	a5,32(s2)
    8000428c:	9fa9                	addw	a5,a5,a0
    8000428e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004292:	01893503          	ld	a0,24(s2)
    80004296:	826ff0ef          	jal	800032bc <iunlock>
      end_op();
    8000429a:	9c9ff0ef          	jal	80003c62 <end_op>

      if(r != n1){
    8000429e:	029a9563          	bne	s5,s1,800042c8 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800042a2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800042a6:	0149da63          	bge	s3,s4,800042ba <filewrite+0xd8>
      int n1 = n - i;
    800042aa:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800042ae:	0004879b          	sext.w	a5,s1
    800042b2:	fafbd6e3          	bge	s7,a5,8000425e <filewrite+0x7c>
    800042b6:	84e2                	mv	s1,s8
    800042b8:	b75d                	j	8000425e <filewrite+0x7c>
    800042ba:	74e2                	ld	s1,56(sp)
    800042bc:	6ae2                	ld	s5,24(sp)
    800042be:	6ba2                	ld	s7,8(sp)
    800042c0:	6c02                	ld	s8,0(sp)
    800042c2:	a039                	j	800042d0 <filewrite+0xee>
    int i = 0;
    800042c4:	4981                	li	s3,0
    800042c6:	a029                	j	800042d0 <filewrite+0xee>
    800042c8:	74e2                	ld	s1,56(sp)
    800042ca:	6ae2                	ld	s5,24(sp)
    800042cc:	6ba2                	ld	s7,8(sp)
    800042ce:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800042d0:	033a1c63          	bne	s4,s3,80004308 <filewrite+0x126>
    800042d4:	8552                	mv	a0,s4
    800042d6:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800042d8:	60a6                	ld	ra,72(sp)
    800042da:	6406                	ld	s0,64(sp)
    800042dc:	7942                	ld	s2,48(sp)
    800042de:	7a02                	ld	s4,32(sp)
    800042e0:	6b42                	ld	s6,16(sp)
    800042e2:	6161                	addi	sp,sp,80
    800042e4:	8082                	ret
    800042e6:	fc26                	sd	s1,56(sp)
    800042e8:	f44e                	sd	s3,40(sp)
    800042ea:	ec56                	sd	s5,24(sp)
    800042ec:	e45e                	sd	s7,8(sp)
    800042ee:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800042f0:	00003517          	auipc	a0,0x3
    800042f4:	2b850513          	addi	a0,a0,696 # 800075a8 <etext+0x5a8>
    800042f8:	ce8fc0ef          	jal	800007e0 <panic>
    return -1;
    800042fc:	557d                	li	a0,-1
}
    800042fe:	8082                	ret
      return -1;
    80004300:	557d                	li	a0,-1
    80004302:	bfd9                	j	800042d8 <filewrite+0xf6>
    80004304:	557d                	li	a0,-1
    80004306:	bfc9                	j	800042d8 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004308:	557d                	li	a0,-1
    8000430a:	79a2                	ld	s3,40(sp)
    8000430c:	b7f1                	j	800042d8 <filewrite+0xf6>

000000008000430e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000430e:	7179                	addi	sp,sp,-48
    80004310:	f406                	sd	ra,40(sp)
    80004312:	f022                	sd	s0,32(sp)
    80004314:	ec26                	sd	s1,24(sp)
    80004316:	e052                	sd	s4,0(sp)
    80004318:	1800                	addi	s0,sp,48
    8000431a:	84aa                	mv	s1,a0
    8000431c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000431e:	0005b023          	sd	zero,0(a1)
    80004322:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004326:	c3bff0ef          	jal	80003f60 <filealloc>
    8000432a:	e088                	sd	a0,0(s1)
    8000432c:	c549                	beqz	a0,800043b6 <pipealloc+0xa8>
    8000432e:	c33ff0ef          	jal	80003f60 <filealloc>
    80004332:	00aa3023          	sd	a0,0(s4)
    80004336:	cd25                	beqz	a0,800043ae <pipealloc+0xa0>
    80004338:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000433a:	fc4fc0ef          	jal	80000afe <kalloc>
    8000433e:	892a                	mv	s2,a0
    80004340:	c12d                	beqz	a0,800043a2 <pipealloc+0x94>
    80004342:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004344:	4985                	li	s3,1
    80004346:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000434a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000434e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004352:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004356:	00003597          	auipc	a1,0x3
    8000435a:	26258593          	addi	a1,a1,610 # 800075b8 <etext+0x5b8>
    8000435e:	ff0fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    80004362:	609c                	ld	a5,0(s1)
    80004364:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004368:	609c                	ld	a5,0(s1)
    8000436a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000436e:	609c                	ld	a5,0(s1)
    80004370:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004374:	609c                	ld	a5,0(s1)
    80004376:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000437a:	000a3783          	ld	a5,0(s4)
    8000437e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004382:	000a3783          	ld	a5,0(s4)
    80004386:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000438a:	000a3783          	ld	a5,0(s4)
    8000438e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004392:	000a3783          	ld	a5,0(s4)
    80004396:	0127b823          	sd	s2,16(a5)
  return 0;
    8000439a:	4501                	li	a0,0
    8000439c:	6942                	ld	s2,16(sp)
    8000439e:	69a2                	ld	s3,8(sp)
    800043a0:	a01d                	j	800043c6 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800043a2:	6088                	ld	a0,0(s1)
    800043a4:	c119                	beqz	a0,800043aa <pipealloc+0x9c>
    800043a6:	6942                	ld	s2,16(sp)
    800043a8:	a029                	j	800043b2 <pipealloc+0xa4>
    800043aa:	6942                	ld	s2,16(sp)
    800043ac:	a029                	j	800043b6 <pipealloc+0xa8>
    800043ae:	6088                	ld	a0,0(s1)
    800043b0:	c10d                	beqz	a0,800043d2 <pipealloc+0xc4>
    fileclose(*f0);
    800043b2:	c53ff0ef          	jal	80004004 <fileclose>
  if(*f1)
    800043b6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800043ba:	557d                	li	a0,-1
  if(*f1)
    800043bc:	c789                	beqz	a5,800043c6 <pipealloc+0xb8>
    fileclose(*f1);
    800043be:	853e                	mv	a0,a5
    800043c0:	c45ff0ef          	jal	80004004 <fileclose>
  return -1;
    800043c4:	557d                	li	a0,-1
}
    800043c6:	70a2                	ld	ra,40(sp)
    800043c8:	7402                	ld	s0,32(sp)
    800043ca:	64e2                	ld	s1,24(sp)
    800043cc:	6a02                	ld	s4,0(sp)
    800043ce:	6145                	addi	sp,sp,48
    800043d0:	8082                	ret
  return -1;
    800043d2:	557d                	li	a0,-1
    800043d4:	bfcd                	j	800043c6 <pipealloc+0xb8>

00000000800043d6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800043d6:	1101                	addi	sp,sp,-32
    800043d8:	ec06                	sd	ra,24(sp)
    800043da:	e822                	sd	s0,16(sp)
    800043dc:	e426                	sd	s1,8(sp)
    800043de:	e04a                	sd	s2,0(sp)
    800043e0:	1000                	addi	s0,sp,32
    800043e2:	84aa                	mv	s1,a0
    800043e4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800043e6:	fe8fc0ef          	jal	80000bce <acquire>
  if(writable){
    800043ea:	02090763          	beqz	s2,80004418 <pipeclose+0x42>
    pi->writeopen = 0;
    800043ee:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800043f2:	21848513          	addi	a0,s1,536
    800043f6:	b37fd0ef          	jal	80001f2c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800043fa:	2204b783          	ld	a5,544(s1)
    800043fe:	e785                	bnez	a5,80004426 <pipeclose+0x50>
    release(&pi->lock);
    80004400:	8526                	mv	a0,s1
    80004402:	865fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    80004406:	8526                	mv	a0,s1
    80004408:	e14fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    8000440c:	60e2                	ld	ra,24(sp)
    8000440e:	6442                	ld	s0,16(sp)
    80004410:	64a2                	ld	s1,8(sp)
    80004412:	6902                	ld	s2,0(sp)
    80004414:	6105                	addi	sp,sp,32
    80004416:	8082                	ret
    pi->readopen = 0;
    80004418:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000441c:	21c48513          	addi	a0,s1,540
    80004420:	b0dfd0ef          	jal	80001f2c <wakeup>
    80004424:	bfd9                	j	800043fa <pipeclose+0x24>
    release(&pi->lock);
    80004426:	8526                	mv	a0,s1
    80004428:	83ffc0ef          	jal	80000c66 <release>
}
    8000442c:	b7c5                	j	8000440c <pipeclose+0x36>

000000008000442e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000442e:	711d                	addi	sp,sp,-96
    80004430:	ec86                	sd	ra,88(sp)
    80004432:	e8a2                	sd	s0,80(sp)
    80004434:	e4a6                	sd	s1,72(sp)
    80004436:	e0ca                	sd	s2,64(sp)
    80004438:	fc4e                	sd	s3,56(sp)
    8000443a:	f852                	sd	s4,48(sp)
    8000443c:	f456                	sd	s5,40(sp)
    8000443e:	1080                	addi	s0,sp,96
    80004440:	84aa                	mv	s1,a0
    80004442:	8aae                	mv	s5,a1
    80004444:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004446:	c88fd0ef          	jal	800018ce <myproc>
    8000444a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000444c:	8526                	mv	a0,s1
    8000444e:	f80fc0ef          	jal	80000bce <acquire>
  while(i < n){
    80004452:	0b405a63          	blez	s4,80004506 <pipewrite+0xd8>
    80004456:	f05a                	sd	s6,32(sp)
    80004458:	ec5e                	sd	s7,24(sp)
    8000445a:	e862                	sd	s8,16(sp)
  int i = 0;
    8000445c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000445e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004460:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004464:	21c48b93          	addi	s7,s1,540
    80004468:	a81d                	j	8000449e <pipewrite+0x70>
      release(&pi->lock);
    8000446a:	8526                	mv	a0,s1
    8000446c:	ffafc0ef          	jal	80000c66 <release>
      return -1;
    80004470:	597d                	li	s2,-1
    80004472:	7b02                	ld	s6,32(sp)
    80004474:	6be2                	ld	s7,24(sp)
    80004476:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004478:	854a                	mv	a0,s2
    8000447a:	60e6                	ld	ra,88(sp)
    8000447c:	6446                	ld	s0,80(sp)
    8000447e:	64a6                	ld	s1,72(sp)
    80004480:	6906                	ld	s2,64(sp)
    80004482:	79e2                	ld	s3,56(sp)
    80004484:	7a42                	ld	s4,48(sp)
    80004486:	7aa2                	ld	s5,40(sp)
    80004488:	6125                	addi	sp,sp,96
    8000448a:	8082                	ret
      wakeup(&pi->nread);
    8000448c:	8562                	mv	a0,s8
    8000448e:	a9ffd0ef          	jal	80001f2c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004492:	85a6                	mv	a1,s1
    80004494:	855e                	mv	a0,s7
    80004496:	a4bfd0ef          	jal	80001ee0 <sleep>
  while(i < n){
    8000449a:	05495b63          	bge	s2,s4,800044f0 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000449e:	2204a783          	lw	a5,544(s1)
    800044a2:	d7e1                	beqz	a5,8000446a <pipewrite+0x3c>
    800044a4:	854e                	mv	a0,s3
    800044a6:	c73fd0ef          	jal	80002118 <killed>
    800044aa:	f161                	bnez	a0,8000446a <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800044ac:	2184a783          	lw	a5,536(s1)
    800044b0:	21c4a703          	lw	a4,540(s1)
    800044b4:	2007879b          	addiw	a5,a5,512
    800044b8:	fcf70ae3          	beq	a4,a5,8000448c <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800044bc:	4685                	li	a3,1
    800044be:	01590633          	add	a2,s2,s5
    800044c2:	faf40593          	addi	a1,s0,-81
    800044c6:	0509b503          	ld	a0,80(s3)
    800044ca:	9fcfd0ef          	jal	800016c6 <copyin>
    800044ce:	03650e63          	beq	a0,s6,8000450a <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800044d2:	21c4a783          	lw	a5,540(s1)
    800044d6:	0017871b          	addiw	a4,a5,1
    800044da:	20e4ae23          	sw	a4,540(s1)
    800044de:	1ff7f793          	andi	a5,a5,511
    800044e2:	97a6                	add	a5,a5,s1
    800044e4:	faf44703          	lbu	a4,-81(s0)
    800044e8:	00e78c23          	sb	a4,24(a5)
      i++;
    800044ec:	2905                	addiw	s2,s2,1
    800044ee:	b775                	j	8000449a <pipewrite+0x6c>
    800044f0:	7b02                	ld	s6,32(sp)
    800044f2:	6be2                	ld	s7,24(sp)
    800044f4:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800044f6:	21848513          	addi	a0,s1,536
    800044fa:	a33fd0ef          	jal	80001f2c <wakeup>
  release(&pi->lock);
    800044fe:	8526                	mv	a0,s1
    80004500:	f66fc0ef          	jal	80000c66 <release>
  return i;
    80004504:	bf95                	j	80004478 <pipewrite+0x4a>
  int i = 0;
    80004506:	4901                	li	s2,0
    80004508:	b7fd                	j	800044f6 <pipewrite+0xc8>
    8000450a:	7b02                	ld	s6,32(sp)
    8000450c:	6be2                	ld	s7,24(sp)
    8000450e:	6c42                	ld	s8,16(sp)
    80004510:	b7dd                	j	800044f6 <pipewrite+0xc8>

0000000080004512 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004512:	715d                	addi	sp,sp,-80
    80004514:	e486                	sd	ra,72(sp)
    80004516:	e0a2                	sd	s0,64(sp)
    80004518:	fc26                	sd	s1,56(sp)
    8000451a:	f84a                	sd	s2,48(sp)
    8000451c:	f44e                	sd	s3,40(sp)
    8000451e:	f052                	sd	s4,32(sp)
    80004520:	ec56                	sd	s5,24(sp)
    80004522:	0880                	addi	s0,sp,80
    80004524:	84aa                	mv	s1,a0
    80004526:	892e                	mv	s2,a1
    80004528:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000452a:	ba4fd0ef          	jal	800018ce <myproc>
    8000452e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004530:	8526                	mv	a0,s1
    80004532:	e9cfc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004536:	2184a703          	lw	a4,536(s1)
    8000453a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000453e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004542:	02f71563          	bne	a4,a5,8000456c <piperead+0x5a>
    80004546:	2244a783          	lw	a5,548(s1)
    8000454a:	cb85                	beqz	a5,8000457a <piperead+0x68>
    if(killed(pr)){
    8000454c:	8552                	mv	a0,s4
    8000454e:	bcbfd0ef          	jal	80002118 <killed>
    80004552:	ed19                	bnez	a0,80004570 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004554:	85a6                	mv	a1,s1
    80004556:	854e                	mv	a0,s3
    80004558:	989fd0ef          	jal	80001ee0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000455c:	2184a703          	lw	a4,536(s1)
    80004560:	21c4a783          	lw	a5,540(s1)
    80004564:	fef701e3          	beq	a4,a5,80004546 <piperead+0x34>
    80004568:	e85a                	sd	s6,16(sp)
    8000456a:	a809                	j	8000457c <piperead+0x6a>
    8000456c:	e85a                	sd	s6,16(sp)
    8000456e:	a039                	j	8000457c <piperead+0x6a>
      release(&pi->lock);
    80004570:	8526                	mv	a0,s1
    80004572:	ef4fc0ef          	jal	80000c66 <release>
      return -1;
    80004576:	59fd                	li	s3,-1
    80004578:	a8b9                	j	800045d6 <piperead+0xc4>
    8000457a:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000457c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000457e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004580:	05505363          	blez	s5,800045c6 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004584:	2184a783          	lw	a5,536(s1)
    80004588:	21c4a703          	lw	a4,540(s1)
    8000458c:	02f70d63          	beq	a4,a5,800045c6 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004590:	1ff7f793          	andi	a5,a5,511
    80004594:	97a6                	add	a5,a5,s1
    80004596:	0187c783          	lbu	a5,24(a5)
    8000459a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000459e:	4685                	li	a3,1
    800045a0:	fbf40613          	addi	a2,s0,-65
    800045a4:	85ca                	mv	a1,s2
    800045a6:	050a3503          	ld	a0,80(s4)
    800045aa:	838fd0ef          	jal	800015e2 <copyout>
    800045ae:	03650e63          	beq	a0,s6,800045ea <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800045b2:	2184a783          	lw	a5,536(s1)
    800045b6:	2785                	addiw	a5,a5,1
    800045b8:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045bc:	2985                	addiw	s3,s3,1
    800045be:	0905                	addi	s2,s2,1
    800045c0:	fd3a92e3          	bne	s5,s3,80004584 <piperead+0x72>
    800045c4:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800045c6:	21c48513          	addi	a0,s1,540
    800045ca:	963fd0ef          	jal	80001f2c <wakeup>
  release(&pi->lock);
    800045ce:	8526                	mv	a0,s1
    800045d0:	e96fc0ef          	jal	80000c66 <release>
    800045d4:	6b42                	ld	s6,16(sp)
  return i;
}
    800045d6:	854e                	mv	a0,s3
    800045d8:	60a6                	ld	ra,72(sp)
    800045da:	6406                	ld	s0,64(sp)
    800045dc:	74e2                	ld	s1,56(sp)
    800045de:	7942                	ld	s2,48(sp)
    800045e0:	79a2                	ld	s3,40(sp)
    800045e2:	7a02                	ld	s4,32(sp)
    800045e4:	6ae2                	ld	s5,24(sp)
    800045e6:	6161                	addi	sp,sp,80
    800045e8:	8082                	ret
      if(i == 0)
    800045ea:	fc099ee3          	bnez	s3,800045c6 <piperead+0xb4>
        i = -1;
    800045ee:	89aa                	mv	s3,a0
    800045f0:	bfd9                	j	800045c6 <piperead+0xb4>

00000000800045f2 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800045f2:	1141                	addi	sp,sp,-16
    800045f4:	e422                	sd	s0,8(sp)
    800045f6:	0800                	addi	s0,sp,16
    800045f8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800045fa:	8905                	andi	a0,a0,1
    800045fc:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800045fe:	8b89                	andi	a5,a5,2
    80004600:	c399                	beqz	a5,80004606 <flags2perm+0x14>
      perm |= PTE_W;
    80004602:	00456513          	ori	a0,a0,4
    return perm;
}
    80004606:	6422                	ld	s0,8(sp)
    80004608:	0141                	addi	sp,sp,16
    8000460a:	8082                	ret

000000008000460c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000460c:	df010113          	addi	sp,sp,-528
    80004610:	20113423          	sd	ra,520(sp)
    80004614:	20813023          	sd	s0,512(sp)
    80004618:	ffa6                	sd	s1,504(sp)
    8000461a:	fbca                	sd	s2,496(sp)
    8000461c:	0c00                	addi	s0,sp,528
    8000461e:	892a                	mv	s2,a0
    80004620:	dea43c23          	sd	a0,-520(s0)
    80004624:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004628:	aa6fd0ef          	jal	800018ce <myproc>
    8000462c:	84aa                	mv	s1,a0

  begin_op();
    8000462e:	dcaff0ef          	jal	80003bf8 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004632:	854a                	mv	a0,s2
    80004634:	bf0ff0ef          	jal	80003a24 <namei>
    80004638:	c931                	beqz	a0,8000468c <kexec+0x80>
    8000463a:	f3d2                	sd	s4,480(sp)
    8000463c:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000463e:	bd1fe0ef          	jal	8000320e <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004642:	04000713          	li	a4,64
    80004646:	4681                	li	a3,0
    80004648:	e5040613          	addi	a2,s0,-432
    8000464c:	4581                	li	a1,0
    8000464e:	8552                	mv	a0,s4
    80004650:	f4ffe0ef          	jal	8000359e <readi>
    80004654:	04000793          	li	a5,64
    80004658:	00f51a63          	bne	a0,a5,8000466c <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000465c:	e5042703          	lw	a4,-432(s0)
    80004660:	464c47b7          	lui	a5,0x464c4
    80004664:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004668:	02f70663          	beq	a4,a5,80004694 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000466c:	8552                	mv	a0,s4
    8000466e:	dabfe0ef          	jal	80003418 <iunlockput>
    end_op();
    80004672:	df0ff0ef          	jal	80003c62 <end_op>
  }
  return -1;
    80004676:	557d                	li	a0,-1
    80004678:	7a1e                	ld	s4,480(sp)
}
    8000467a:	20813083          	ld	ra,520(sp)
    8000467e:	20013403          	ld	s0,512(sp)
    80004682:	74fe                	ld	s1,504(sp)
    80004684:	795e                	ld	s2,496(sp)
    80004686:	21010113          	addi	sp,sp,528
    8000468a:	8082                	ret
    end_op();
    8000468c:	dd6ff0ef          	jal	80003c62 <end_op>
    return -1;
    80004690:	557d                	li	a0,-1
    80004692:	b7e5                	j	8000467a <kexec+0x6e>
    80004694:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004696:	8526                	mv	a0,s1
    80004698:	b3cfd0ef          	jal	800019d4 <proc_pagetable>
    8000469c:	8b2a                	mv	s6,a0
    8000469e:	2c050b63          	beqz	a0,80004974 <kexec+0x368>
    800046a2:	f7ce                	sd	s3,488(sp)
    800046a4:	efd6                	sd	s5,472(sp)
    800046a6:	e7de                	sd	s7,456(sp)
    800046a8:	e3e2                	sd	s8,448(sp)
    800046aa:	ff66                	sd	s9,440(sp)
    800046ac:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046ae:	e7042d03          	lw	s10,-400(s0)
    800046b2:	e8845783          	lhu	a5,-376(s0)
    800046b6:	12078963          	beqz	a5,800047e8 <kexec+0x1dc>
    800046ba:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800046bc:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046be:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800046c0:	6c85                	lui	s9,0x1
    800046c2:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800046c6:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800046ca:	6a85                	lui	s5,0x1
    800046cc:	a085                	j	8000472c <kexec+0x120>
      panic("loadseg: address should exist");
    800046ce:	00003517          	auipc	a0,0x3
    800046d2:	ef250513          	addi	a0,a0,-270 # 800075c0 <etext+0x5c0>
    800046d6:	90afc0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    800046da:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800046dc:	8726                	mv	a4,s1
    800046de:	012c06bb          	addw	a3,s8,s2
    800046e2:	4581                	li	a1,0
    800046e4:	8552                	mv	a0,s4
    800046e6:	eb9fe0ef          	jal	8000359e <readi>
    800046ea:	2501                	sext.w	a0,a0
    800046ec:	24a49a63          	bne	s1,a0,80004940 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800046f0:	012a893b          	addw	s2,s5,s2
    800046f4:	03397363          	bgeu	s2,s3,8000471a <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800046f8:	02091593          	slli	a1,s2,0x20
    800046fc:	9181                	srli	a1,a1,0x20
    800046fe:	95de                	add	a1,a1,s7
    80004700:	855a                	mv	a0,s6
    80004702:	8affc0ef          	jal	80000fb0 <walkaddr>
    80004706:	862a                	mv	a2,a0
    if(pa == 0)
    80004708:	d179                	beqz	a0,800046ce <kexec+0xc2>
    if(sz - i < PGSIZE)
    8000470a:	412984bb          	subw	s1,s3,s2
    8000470e:	0004879b          	sext.w	a5,s1
    80004712:	fcfcf4e3          	bgeu	s9,a5,800046da <kexec+0xce>
    80004716:	84d6                	mv	s1,s5
    80004718:	b7c9                	j	800046da <kexec+0xce>
    sz = sz1;
    8000471a:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000471e:	2d85                	addiw	s11,s11,1
    80004720:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004724:	e8845783          	lhu	a5,-376(s0)
    80004728:	08fdd063          	bge	s11,a5,800047a8 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000472c:	2d01                	sext.w	s10,s10
    8000472e:	03800713          	li	a4,56
    80004732:	86ea                	mv	a3,s10
    80004734:	e1840613          	addi	a2,s0,-488
    80004738:	4581                	li	a1,0
    8000473a:	8552                	mv	a0,s4
    8000473c:	e63fe0ef          	jal	8000359e <readi>
    80004740:	03800793          	li	a5,56
    80004744:	1cf51663          	bne	a0,a5,80004910 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004748:	e1842783          	lw	a5,-488(s0)
    8000474c:	4705                	li	a4,1
    8000474e:	fce798e3          	bne	a5,a4,8000471e <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004752:	e4043483          	ld	s1,-448(s0)
    80004756:	e3843783          	ld	a5,-456(s0)
    8000475a:	1af4ef63          	bltu	s1,a5,80004918 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000475e:	e2843783          	ld	a5,-472(s0)
    80004762:	94be                	add	s1,s1,a5
    80004764:	1af4ee63          	bltu	s1,a5,80004920 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004768:	df043703          	ld	a4,-528(s0)
    8000476c:	8ff9                	and	a5,a5,a4
    8000476e:	1a079d63          	bnez	a5,80004928 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004772:	e1c42503          	lw	a0,-484(s0)
    80004776:	e7dff0ef          	jal	800045f2 <flags2perm>
    8000477a:	86aa                	mv	a3,a0
    8000477c:	8626                	mv	a2,s1
    8000477e:	85ca                	mv	a1,s2
    80004780:	855a                	mv	a0,s6
    80004782:	b07fc0ef          	jal	80001288 <uvmalloc>
    80004786:	e0a43423          	sd	a0,-504(s0)
    8000478a:	1a050363          	beqz	a0,80004930 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000478e:	e2843b83          	ld	s7,-472(s0)
    80004792:	e2042c03          	lw	s8,-480(s0)
    80004796:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000479a:	00098463          	beqz	s3,800047a2 <kexec+0x196>
    8000479e:	4901                	li	s2,0
    800047a0:	bfa1                	j	800046f8 <kexec+0xec>
    sz = sz1;
    800047a2:	e0843903          	ld	s2,-504(s0)
    800047a6:	bfa5                	j	8000471e <kexec+0x112>
    800047a8:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800047aa:	8552                	mv	a0,s4
    800047ac:	c6dfe0ef          	jal	80003418 <iunlockput>
  end_op();
    800047b0:	cb2ff0ef          	jal	80003c62 <end_op>
  p = myproc();
    800047b4:	91afd0ef          	jal	800018ce <myproc>
    800047b8:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800047ba:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800047be:	6985                	lui	s3,0x1
    800047c0:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800047c2:	99ca                	add	s3,s3,s2
    800047c4:	77fd                	lui	a5,0xfffff
    800047c6:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800047ca:	4691                	li	a3,4
    800047cc:	6609                	lui	a2,0x2
    800047ce:	964e                	add	a2,a2,s3
    800047d0:	85ce                	mv	a1,s3
    800047d2:	855a                	mv	a0,s6
    800047d4:	ab5fc0ef          	jal	80001288 <uvmalloc>
    800047d8:	892a                	mv	s2,a0
    800047da:	e0a43423          	sd	a0,-504(s0)
    800047de:	e519                	bnez	a0,800047ec <kexec+0x1e0>
  if(pagetable)
    800047e0:	e1343423          	sd	s3,-504(s0)
    800047e4:	4a01                	li	s4,0
    800047e6:	aab1                	j	80004942 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047e8:	4901                	li	s2,0
    800047ea:	b7c1                	j	800047aa <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800047ec:	75f9                	lui	a1,0xffffe
    800047ee:	95aa                	add	a1,a1,a0
    800047f0:	855a                	mv	a0,s6
    800047f2:	c6dfc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800047f6:	7bfd                	lui	s7,0xfffff
    800047f8:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800047fa:	e0043783          	ld	a5,-512(s0)
    800047fe:	6388                	ld	a0,0(a5)
    80004800:	cd39                	beqz	a0,8000485e <kexec+0x252>
    80004802:	e9040993          	addi	s3,s0,-368
    80004806:	f9040c13          	addi	s8,s0,-112
    8000480a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000480c:	e06fc0ef          	jal	80000e12 <strlen>
    80004810:	0015079b          	addiw	a5,a0,1
    80004814:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004818:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000481c:	11796e63          	bltu	s2,s7,80004938 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004820:	e0043d03          	ld	s10,-512(s0)
    80004824:	000d3a03          	ld	s4,0(s10)
    80004828:	8552                	mv	a0,s4
    8000482a:	de8fc0ef          	jal	80000e12 <strlen>
    8000482e:	0015069b          	addiw	a3,a0,1
    80004832:	8652                	mv	a2,s4
    80004834:	85ca                	mv	a1,s2
    80004836:	855a                	mv	a0,s6
    80004838:	dabfc0ef          	jal	800015e2 <copyout>
    8000483c:	10054063          	bltz	a0,8000493c <kexec+0x330>
    ustack[argc] = sp;
    80004840:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004844:	0485                	addi	s1,s1,1
    80004846:	008d0793          	addi	a5,s10,8
    8000484a:	e0f43023          	sd	a5,-512(s0)
    8000484e:	008d3503          	ld	a0,8(s10)
    80004852:	c909                	beqz	a0,80004864 <kexec+0x258>
    if(argc >= MAXARG)
    80004854:	09a1                	addi	s3,s3,8
    80004856:	fb899be3          	bne	s3,s8,8000480c <kexec+0x200>
  ip = 0;
    8000485a:	4a01                	li	s4,0
    8000485c:	a0dd                	j	80004942 <kexec+0x336>
  sp = sz;
    8000485e:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004862:	4481                	li	s1,0
  ustack[argc] = 0;
    80004864:	00349793          	slli	a5,s1,0x3
    80004868:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde1f8>
    8000486c:	97a2                	add	a5,a5,s0
    8000486e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004872:	00148693          	addi	a3,s1,1
    80004876:	068e                	slli	a3,a3,0x3
    80004878:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000487c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004880:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004884:	f5796ee3          	bltu	s2,s7,800047e0 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004888:	e9040613          	addi	a2,s0,-368
    8000488c:	85ca                	mv	a1,s2
    8000488e:	855a                	mv	a0,s6
    80004890:	d53fc0ef          	jal	800015e2 <copyout>
    80004894:	0e054263          	bltz	a0,80004978 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004898:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000489c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800048a0:	df843783          	ld	a5,-520(s0)
    800048a4:	0007c703          	lbu	a4,0(a5)
    800048a8:	cf11                	beqz	a4,800048c4 <kexec+0x2b8>
    800048aa:	0785                	addi	a5,a5,1
    if(*s == '/')
    800048ac:	02f00693          	li	a3,47
    800048b0:	a039                	j	800048be <kexec+0x2b2>
      last = s+1;
    800048b2:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800048b6:	0785                	addi	a5,a5,1
    800048b8:	fff7c703          	lbu	a4,-1(a5)
    800048bc:	c701                	beqz	a4,800048c4 <kexec+0x2b8>
    if(*s == '/')
    800048be:	fed71ce3          	bne	a4,a3,800048b6 <kexec+0x2aa>
    800048c2:	bfc5                	j	800048b2 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800048c4:	4641                	li	a2,16
    800048c6:	df843583          	ld	a1,-520(s0)
    800048ca:	160a8513          	addi	a0,s5,352
    800048ce:	d12fc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    800048d2:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800048d6:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800048da:	e0843783          	ld	a5,-504(s0)
    800048de:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800048e2:	058ab783          	ld	a5,88(s5)
    800048e6:	e6843703          	ld	a4,-408(s0)
    800048ea:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800048ec:	058ab783          	ld	a5,88(s5)
    800048f0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800048f4:	85e6                	mv	a1,s9
    800048f6:	962fd0ef          	jal	80001a58 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800048fa:	0004851b          	sext.w	a0,s1
    800048fe:	79be                	ld	s3,488(sp)
    80004900:	7a1e                	ld	s4,480(sp)
    80004902:	6afe                	ld	s5,472(sp)
    80004904:	6b5e                	ld	s6,464(sp)
    80004906:	6bbe                	ld	s7,456(sp)
    80004908:	6c1e                	ld	s8,448(sp)
    8000490a:	7cfa                	ld	s9,440(sp)
    8000490c:	7d5a                	ld	s10,432(sp)
    8000490e:	b3b5                	j	8000467a <kexec+0x6e>
    80004910:	e1243423          	sd	s2,-504(s0)
    80004914:	7dba                	ld	s11,424(sp)
    80004916:	a035                	j	80004942 <kexec+0x336>
    80004918:	e1243423          	sd	s2,-504(s0)
    8000491c:	7dba                	ld	s11,424(sp)
    8000491e:	a015                	j	80004942 <kexec+0x336>
    80004920:	e1243423          	sd	s2,-504(s0)
    80004924:	7dba                	ld	s11,424(sp)
    80004926:	a831                	j	80004942 <kexec+0x336>
    80004928:	e1243423          	sd	s2,-504(s0)
    8000492c:	7dba                	ld	s11,424(sp)
    8000492e:	a811                	j	80004942 <kexec+0x336>
    80004930:	e1243423          	sd	s2,-504(s0)
    80004934:	7dba                	ld	s11,424(sp)
    80004936:	a031                	j	80004942 <kexec+0x336>
  ip = 0;
    80004938:	4a01                	li	s4,0
    8000493a:	a021                	j	80004942 <kexec+0x336>
    8000493c:	4a01                	li	s4,0
  if(pagetable)
    8000493e:	a011                	j	80004942 <kexec+0x336>
    80004940:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004942:	e0843583          	ld	a1,-504(s0)
    80004946:	855a                	mv	a0,s6
    80004948:	910fd0ef          	jal	80001a58 <proc_freepagetable>
  return -1;
    8000494c:	557d                	li	a0,-1
  if(ip){
    8000494e:	000a1b63          	bnez	s4,80004964 <kexec+0x358>
    80004952:	79be                	ld	s3,488(sp)
    80004954:	7a1e                	ld	s4,480(sp)
    80004956:	6afe                	ld	s5,472(sp)
    80004958:	6b5e                	ld	s6,464(sp)
    8000495a:	6bbe                	ld	s7,456(sp)
    8000495c:	6c1e                	ld	s8,448(sp)
    8000495e:	7cfa                	ld	s9,440(sp)
    80004960:	7d5a                	ld	s10,432(sp)
    80004962:	bb21                	j	8000467a <kexec+0x6e>
    80004964:	79be                	ld	s3,488(sp)
    80004966:	6afe                	ld	s5,472(sp)
    80004968:	6b5e                	ld	s6,464(sp)
    8000496a:	6bbe                	ld	s7,456(sp)
    8000496c:	6c1e                	ld	s8,448(sp)
    8000496e:	7cfa                	ld	s9,440(sp)
    80004970:	7d5a                	ld	s10,432(sp)
    80004972:	b9ed                	j	8000466c <kexec+0x60>
    80004974:	6b5e                	ld	s6,464(sp)
    80004976:	b9dd                	j	8000466c <kexec+0x60>
  sz = sz1;
    80004978:	e0843983          	ld	s3,-504(s0)
    8000497c:	b595                	j	800047e0 <kexec+0x1d4>

000000008000497e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000497e:	7179                	addi	sp,sp,-48
    80004980:	f406                	sd	ra,40(sp)
    80004982:	f022                	sd	s0,32(sp)
    80004984:	ec26                	sd	s1,24(sp)
    80004986:	e84a                	sd	s2,16(sp)
    80004988:	1800                	addi	s0,sp,48
    8000498a:	892e                	mv	s2,a1
    8000498c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000498e:	fdc40593          	addi	a1,s0,-36
    80004992:	e53fd0ef          	jal	800027e4 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004996:	fdc42703          	lw	a4,-36(s0)
    8000499a:	47bd                	li	a5,15
    8000499c:	02e7e963          	bltu	a5,a4,800049ce <argfd+0x50>
    800049a0:	f2ffc0ef          	jal	800018ce <myproc>
    800049a4:	fdc42703          	lw	a4,-36(s0)
    800049a8:	01a70793          	addi	a5,a4,26
    800049ac:	078e                	slli	a5,a5,0x3
    800049ae:	953e                	add	a0,a0,a5
    800049b0:	611c                	ld	a5,0(a0)
    800049b2:	c385                	beqz	a5,800049d2 <argfd+0x54>
    return -1;
  if(pfd)
    800049b4:	00090463          	beqz	s2,800049bc <argfd+0x3e>
    *pfd = fd;
    800049b8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800049bc:	4501                	li	a0,0
  if(pf)
    800049be:	c091                	beqz	s1,800049c2 <argfd+0x44>
    *pf = f;
    800049c0:	e09c                	sd	a5,0(s1)
}
    800049c2:	70a2                	ld	ra,40(sp)
    800049c4:	7402                	ld	s0,32(sp)
    800049c6:	64e2                	ld	s1,24(sp)
    800049c8:	6942                	ld	s2,16(sp)
    800049ca:	6145                	addi	sp,sp,48
    800049cc:	8082                	ret
    return -1;
    800049ce:	557d                	li	a0,-1
    800049d0:	bfcd                	j	800049c2 <argfd+0x44>
    800049d2:	557d                	li	a0,-1
    800049d4:	b7fd                	j	800049c2 <argfd+0x44>

00000000800049d6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800049d6:	1101                	addi	sp,sp,-32
    800049d8:	ec06                	sd	ra,24(sp)
    800049da:	e822                	sd	s0,16(sp)
    800049dc:	e426                	sd	s1,8(sp)
    800049de:	1000                	addi	s0,sp,32
    800049e0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800049e2:	eedfc0ef          	jal	800018ce <myproc>
    800049e6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800049e8:	0d050793          	addi	a5,a0,208
    800049ec:	4501                	li	a0,0
    800049ee:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800049f0:	6398                	ld	a4,0(a5)
    800049f2:	cb19                	beqz	a4,80004a08 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800049f4:	2505                	addiw	a0,a0,1
    800049f6:	07a1                	addi	a5,a5,8
    800049f8:	fed51ce3          	bne	a0,a3,800049f0 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800049fc:	557d                	li	a0,-1
}
    800049fe:	60e2                	ld	ra,24(sp)
    80004a00:	6442                	ld	s0,16(sp)
    80004a02:	64a2                	ld	s1,8(sp)
    80004a04:	6105                	addi	sp,sp,32
    80004a06:	8082                	ret
      p->ofile[fd] = f;
    80004a08:	01a50793          	addi	a5,a0,26
    80004a0c:	078e                	slli	a5,a5,0x3
    80004a0e:	963e                	add	a2,a2,a5
    80004a10:	e204                	sd	s1,0(a2)
      return fd;
    80004a12:	b7f5                	j	800049fe <fdalloc+0x28>

0000000080004a14 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004a14:	715d                	addi	sp,sp,-80
    80004a16:	e486                	sd	ra,72(sp)
    80004a18:	e0a2                	sd	s0,64(sp)
    80004a1a:	fc26                	sd	s1,56(sp)
    80004a1c:	f84a                	sd	s2,48(sp)
    80004a1e:	f44e                	sd	s3,40(sp)
    80004a20:	ec56                	sd	s5,24(sp)
    80004a22:	e85a                	sd	s6,16(sp)
    80004a24:	0880                	addi	s0,sp,80
    80004a26:	8b2e                	mv	s6,a1
    80004a28:	89b2                	mv	s3,a2
    80004a2a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004a2c:	fb040593          	addi	a1,s0,-80
    80004a30:	80eff0ef          	jal	80003a3e <nameiparent>
    80004a34:	84aa                	mv	s1,a0
    80004a36:	10050a63          	beqz	a0,80004b4a <create+0x136>
    return 0;

  ilock(dp);
    80004a3a:	fd4fe0ef          	jal	8000320e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a3e:	4601                	li	a2,0
    80004a40:	fb040593          	addi	a1,s0,-80
    80004a44:	8526                	mv	a0,s1
    80004a46:	d79fe0ef          	jal	800037be <dirlookup>
    80004a4a:	8aaa                	mv	s5,a0
    80004a4c:	c129                	beqz	a0,80004a8e <create+0x7a>
    iunlockput(dp);
    80004a4e:	8526                	mv	a0,s1
    80004a50:	9c9fe0ef          	jal	80003418 <iunlockput>
    ilock(ip);
    80004a54:	8556                	mv	a0,s5
    80004a56:	fb8fe0ef          	jal	8000320e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004a5a:	4789                	li	a5,2
    80004a5c:	02fb1463          	bne	s6,a5,80004a84 <create+0x70>
    80004a60:	044ad783          	lhu	a5,68(s5)
    80004a64:	37f9                	addiw	a5,a5,-2
    80004a66:	17c2                	slli	a5,a5,0x30
    80004a68:	93c1                	srli	a5,a5,0x30
    80004a6a:	4705                	li	a4,1
    80004a6c:	00f76c63          	bltu	a4,a5,80004a84 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004a70:	8556                	mv	a0,s5
    80004a72:	60a6                	ld	ra,72(sp)
    80004a74:	6406                	ld	s0,64(sp)
    80004a76:	74e2                	ld	s1,56(sp)
    80004a78:	7942                	ld	s2,48(sp)
    80004a7a:	79a2                	ld	s3,40(sp)
    80004a7c:	6ae2                	ld	s5,24(sp)
    80004a7e:	6b42                	ld	s6,16(sp)
    80004a80:	6161                	addi	sp,sp,80
    80004a82:	8082                	ret
    iunlockput(ip);
    80004a84:	8556                	mv	a0,s5
    80004a86:	993fe0ef          	jal	80003418 <iunlockput>
    return 0;
    80004a8a:	4a81                	li	s5,0
    80004a8c:	b7d5                	j	80004a70 <create+0x5c>
    80004a8e:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004a90:	85da                	mv	a1,s6
    80004a92:	4088                	lw	a0,0(s1)
    80004a94:	e0afe0ef          	jal	8000309e <ialloc>
    80004a98:	8a2a                	mv	s4,a0
    80004a9a:	cd15                	beqz	a0,80004ad6 <create+0xc2>
  ilock(ip);
    80004a9c:	f72fe0ef          	jal	8000320e <ilock>
  ip->major = major;
    80004aa0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004aa4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004aa8:	4905                	li	s2,1
    80004aaa:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004aae:	8552                	mv	a0,s4
    80004ab0:	eaafe0ef          	jal	8000315a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004ab4:	032b0763          	beq	s6,s2,80004ae2 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ab8:	004a2603          	lw	a2,4(s4)
    80004abc:	fb040593          	addi	a1,s0,-80
    80004ac0:	8526                	mv	a0,s1
    80004ac2:	ec9fe0ef          	jal	8000398a <dirlink>
    80004ac6:	06054563          	bltz	a0,80004b30 <create+0x11c>
  iunlockput(dp);
    80004aca:	8526                	mv	a0,s1
    80004acc:	94dfe0ef          	jal	80003418 <iunlockput>
  return ip;
    80004ad0:	8ad2                	mv	s5,s4
    80004ad2:	7a02                	ld	s4,32(sp)
    80004ad4:	bf71                	j	80004a70 <create+0x5c>
    iunlockput(dp);
    80004ad6:	8526                	mv	a0,s1
    80004ad8:	941fe0ef          	jal	80003418 <iunlockput>
    return 0;
    80004adc:	8ad2                	mv	s5,s4
    80004ade:	7a02                	ld	s4,32(sp)
    80004ae0:	bf41                	j	80004a70 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ae2:	004a2603          	lw	a2,4(s4)
    80004ae6:	00003597          	auipc	a1,0x3
    80004aea:	afa58593          	addi	a1,a1,-1286 # 800075e0 <etext+0x5e0>
    80004aee:	8552                	mv	a0,s4
    80004af0:	e9bfe0ef          	jal	8000398a <dirlink>
    80004af4:	02054e63          	bltz	a0,80004b30 <create+0x11c>
    80004af8:	40d0                	lw	a2,4(s1)
    80004afa:	00003597          	auipc	a1,0x3
    80004afe:	aee58593          	addi	a1,a1,-1298 # 800075e8 <etext+0x5e8>
    80004b02:	8552                	mv	a0,s4
    80004b04:	e87fe0ef          	jal	8000398a <dirlink>
    80004b08:	02054463          	bltz	a0,80004b30 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b0c:	004a2603          	lw	a2,4(s4)
    80004b10:	fb040593          	addi	a1,s0,-80
    80004b14:	8526                	mv	a0,s1
    80004b16:	e75fe0ef          	jal	8000398a <dirlink>
    80004b1a:	00054b63          	bltz	a0,80004b30 <create+0x11c>
    dp->nlink++;  // for ".."
    80004b1e:	04a4d783          	lhu	a5,74(s1)
    80004b22:	2785                	addiw	a5,a5,1
    80004b24:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004b28:	8526                	mv	a0,s1
    80004b2a:	e30fe0ef          	jal	8000315a <iupdate>
    80004b2e:	bf71                	j	80004aca <create+0xb6>
  ip->nlink = 0;
    80004b30:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004b34:	8552                	mv	a0,s4
    80004b36:	e24fe0ef          	jal	8000315a <iupdate>
  iunlockput(ip);
    80004b3a:	8552                	mv	a0,s4
    80004b3c:	8ddfe0ef          	jal	80003418 <iunlockput>
  iunlockput(dp);
    80004b40:	8526                	mv	a0,s1
    80004b42:	8d7fe0ef          	jal	80003418 <iunlockput>
  return 0;
    80004b46:	7a02                	ld	s4,32(sp)
    80004b48:	b725                	j	80004a70 <create+0x5c>
    return 0;
    80004b4a:	8aaa                	mv	s5,a0
    80004b4c:	b715                	j	80004a70 <create+0x5c>

0000000080004b4e <sys_dup>:
{
    80004b4e:	7179                	addi	sp,sp,-48
    80004b50:	f406                	sd	ra,40(sp)
    80004b52:	f022                	sd	s0,32(sp)
    80004b54:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004b56:	fd840613          	addi	a2,s0,-40
    80004b5a:	4581                	li	a1,0
    80004b5c:	4501                	li	a0,0
    80004b5e:	e21ff0ef          	jal	8000497e <argfd>
    return -1;
    80004b62:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004b64:	02054363          	bltz	a0,80004b8a <sys_dup+0x3c>
    80004b68:	ec26                	sd	s1,24(sp)
    80004b6a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004b6c:	fd843903          	ld	s2,-40(s0)
    80004b70:	854a                	mv	a0,s2
    80004b72:	e65ff0ef          	jal	800049d6 <fdalloc>
    80004b76:	84aa                	mv	s1,a0
    return -1;
    80004b78:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004b7a:	00054d63          	bltz	a0,80004b94 <sys_dup+0x46>
  filedup(f);
    80004b7e:	854a                	mv	a0,s2
    80004b80:	c3eff0ef          	jal	80003fbe <filedup>
  return fd;
    80004b84:	87a6                	mv	a5,s1
    80004b86:	64e2                	ld	s1,24(sp)
    80004b88:	6942                	ld	s2,16(sp)
}
    80004b8a:	853e                	mv	a0,a5
    80004b8c:	70a2                	ld	ra,40(sp)
    80004b8e:	7402                	ld	s0,32(sp)
    80004b90:	6145                	addi	sp,sp,48
    80004b92:	8082                	ret
    80004b94:	64e2                	ld	s1,24(sp)
    80004b96:	6942                	ld	s2,16(sp)
    80004b98:	bfcd                	j	80004b8a <sys_dup+0x3c>

0000000080004b9a <sys_read>:
{
    80004b9a:	7179                	addi	sp,sp,-48
    80004b9c:	f406                	sd	ra,40(sp)
    80004b9e:	f022                	sd	s0,32(sp)
    80004ba0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ba2:	fd840593          	addi	a1,s0,-40
    80004ba6:	4505                	li	a0,1
    80004ba8:	c59fd0ef          	jal	80002800 <argaddr>
  argint(2, &n);
    80004bac:	fe440593          	addi	a1,s0,-28
    80004bb0:	4509                	li	a0,2
    80004bb2:	c33fd0ef          	jal	800027e4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004bb6:	fe840613          	addi	a2,s0,-24
    80004bba:	4581                	li	a1,0
    80004bbc:	4501                	li	a0,0
    80004bbe:	dc1ff0ef          	jal	8000497e <argfd>
    80004bc2:	87aa                	mv	a5,a0
    return -1;
    80004bc4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004bc6:	0007ca63          	bltz	a5,80004bda <sys_read+0x40>
  return fileread(f, p, n);
    80004bca:	fe442603          	lw	a2,-28(s0)
    80004bce:	fd843583          	ld	a1,-40(s0)
    80004bd2:	fe843503          	ld	a0,-24(s0)
    80004bd6:	d4eff0ef          	jal	80004124 <fileread>
}
    80004bda:	70a2                	ld	ra,40(sp)
    80004bdc:	7402                	ld	s0,32(sp)
    80004bde:	6145                	addi	sp,sp,48
    80004be0:	8082                	ret

0000000080004be2 <sys_write>:
{
    80004be2:	7179                	addi	sp,sp,-48
    80004be4:	f406                	sd	ra,40(sp)
    80004be6:	f022                	sd	s0,32(sp)
    80004be8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bea:	fd840593          	addi	a1,s0,-40
    80004bee:	4505                	li	a0,1
    80004bf0:	c11fd0ef          	jal	80002800 <argaddr>
  argint(2, &n);
    80004bf4:	fe440593          	addi	a1,s0,-28
    80004bf8:	4509                	li	a0,2
    80004bfa:	bebfd0ef          	jal	800027e4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004bfe:	fe840613          	addi	a2,s0,-24
    80004c02:	4581                	li	a1,0
    80004c04:	4501                	li	a0,0
    80004c06:	d79ff0ef          	jal	8000497e <argfd>
    80004c0a:	87aa                	mv	a5,a0
    return -1;
    80004c0c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c0e:	0007ca63          	bltz	a5,80004c22 <sys_write+0x40>
  return filewrite(f, p, n);
    80004c12:	fe442603          	lw	a2,-28(s0)
    80004c16:	fd843583          	ld	a1,-40(s0)
    80004c1a:	fe843503          	ld	a0,-24(s0)
    80004c1e:	dc4ff0ef          	jal	800041e2 <filewrite>
}
    80004c22:	70a2                	ld	ra,40(sp)
    80004c24:	7402                	ld	s0,32(sp)
    80004c26:	6145                	addi	sp,sp,48
    80004c28:	8082                	ret

0000000080004c2a <sys_close>:
{
    80004c2a:	1101                	addi	sp,sp,-32
    80004c2c:	ec06                	sd	ra,24(sp)
    80004c2e:	e822                	sd	s0,16(sp)
    80004c30:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004c32:	fe040613          	addi	a2,s0,-32
    80004c36:	fec40593          	addi	a1,s0,-20
    80004c3a:	4501                	li	a0,0
    80004c3c:	d43ff0ef          	jal	8000497e <argfd>
    return -1;
    80004c40:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004c42:	02054063          	bltz	a0,80004c62 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c46:	c89fc0ef          	jal	800018ce <myproc>
    80004c4a:	fec42783          	lw	a5,-20(s0)
    80004c4e:	07e9                	addi	a5,a5,26
    80004c50:	078e                	slli	a5,a5,0x3
    80004c52:	953e                	add	a0,a0,a5
    80004c54:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004c58:	fe043503          	ld	a0,-32(s0)
    80004c5c:	ba8ff0ef          	jal	80004004 <fileclose>
  return 0;
    80004c60:	4781                	li	a5,0
}
    80004c62:	853e                	mv	a0,a5
    80004c64:	60e2                	ld	ra,24(sp)
    80004c66:	6442                	ld	s0,16(sp)
    80004c68:	6105                	addi	sp,sp,32
    80004c6a:	8082                	ret

0000000080004c6c <sys_fstat>:
{
    80004c6c:	1101                	addi	sp,sp,-32
    80004c6e:	ec06                	sd	ra,24(sp)
    80004c70:	e822                	sd	s0,16(sp)
    80004c72:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004c74:	fe040593          	addi	a1,s0,-32
    80004c78:	4505                	li	a0,1
    80004c7a:	b87fd0ef          	jal	80002800 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004c7e:	fe840613          	addi	a2,s0,-24
    80004c82:	4581                	li	a1,0
    80004c84:	4501                	li	a0,0
    80004c86:	cf9ff0ef          	jal	8000497e <argfd>
    80004c8a:	87aa                	mv	a5,a0
    return -1;
    80004c8c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c8e:	0007c863          	bltz	a5,80004c9e <sys_fstat+0x32>
  return filestat(f, st);
    80004c92:	fe043583          	ld	a1,-32(s0)
    80004c96:	fe843503          	ld	a0,-24(s0)
    80004c9a:	c2cff0ef          	jal	800040c6 <filestat>
}
    80004c9e:	60e2                	ld	ra,24(sp)
    80004ca0:	6442                	ld	s0,16(sp)
    80004ca2:	6105                	addi	sp,sp,32
    80004ca4:	8082                	ret

0000000080004ca6 <sys_link>:
{
    80004ca6:	7169                	addi	sp,sp,-304
    80004ca8:	f606                	sd	ra,296(sp)
    80004caa:	f222                	sd	s0,288(sp)
    80004cac:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cae:	08000613          	li	a2,128
    80004cb2:	ed040593          	addi	a1,s0,-304
    80004cb6:	4501                	li	a0,0
    80004cb8:	b65fd0ef          	jal	8000281c <argstr>
    return -1;
    80004cbc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cbe:	0c054e63          	bltz	a0,80004d9a <sys_link+0xf4>
    80004cc2:	08000613          	li	a2,128
    80004cc6:	f5040593          	addi	a1,s0,-176
    80004cca:	4505                	li	a0,1
    80004ccc:	b51fd0ef          	jal	8000281c <argstr>
    return -1;
    80004cd0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cd2:	0c054463          	bltz	a0,80004d9a <sys_link+0xf4>
    80004cd6:	ee26                	sd	s1,280(sp)
  begin_op();
    80004cd8:	f21fe0ef          	jal	80003bf8 <begin_op>
  if((ip = namei(old)) == 0){
    80004cdc:	ed040513          	addi	a0,s0,-304
    80004ce0:	d45fe0ef          	jal	80003a24 <namei>
    80004ce4:	84aa                	mv	s1,a0
    80004ce6:	c53d                	beqz	a0,80004d54 <sys_link+0xae>
  ilock(ip);
    80004ce8:	d26fe0ef          	jal	8000320e <ilock>
  if(ip->type == T_DIR){
    80004cec:	04449703          	lh	a4,68(s1)
    80004cf0:	4785                	li	a5,1
    80004cf2:	06f70663          	beq	a4,a5,80004d5e <sys_link+0xb8>
    80004cf6:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004cf8:	04a4d783          	lhu	a5,74(s1)
    80004cfc:	2785                	addiw	a5,a5,1
    80004cfe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d02:	8526                	mv	a0,s1
    80004d04:	c56fe0ef          	jal	8000315a <iupdate>
  iunlock(ip);
    80004d08:	8526                	mv	a0,s1
    80004d0a:	db2fe0ef          	jal	800032bc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004d0e:	fd040593          	addi	a1,s0,-48
    80004d12:	f5040513          	addi	a0,s0,-176
    80004d16:	d29fe0ef          	jal	80003a3e <nameiparent>
    80004d1a:	892a                	mv	s2,a0
    80004d1c:	cd21                	beqz	a0,80004d74 <sys_link+0xce>
  ilock(dp);
    80004d1e:	cf0fe0ef          	jal	8000320e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004d22:	00092703          	lw	a4,0(s2)
    80004d26:	409c                	lw	a5,0(s1)
    80004d28:	04f71363          	bne	a4,a5,80004d6e <sys_link+0xc8>
    80004d2c:	40d0                	lw	a2,4(s1)
    80004d2e:	fd040593          	addi	a1,s0,-48
    80004d32:	854a                	mv	a0,s2
    80004d34:	c57fe0ef          	jal	8000398a <dirlink>
    80004d38:	02054b63          	bltz	a0,80004d6e <sys_link+0xc8>
  iunlockput(dp);
    80004d3c:	854a                	mv	a0,s2
    80004d3e:	edafe0ef          	jal	80003418 <iunlockput>
  iput(ip);
    80004d42:	8526                	mv	a0,s1
    80004d44:	e4cfe0ef          	jal	80003390 <iput>
  end_op();
    80004d48:	f1bfe0ef          	jal	80003c62 <end_op>
  return 0;
    80004d4c:	4781                	li	a5,0
    80004d4e:	64f2                	ld	s1,280(sp)
    80004d50:	6952                	ld	s2,272(sp)
    80004d52:	a0a1                	j	80004d9a <sys_link+0xf4>
    end_op();
    80004d54:	f0ffe0ef          	jal	80003c62 <end_op>
    return -1;
    80004d58:	57fd                	li	a5,-1
    80004d5a:	64f2                	ld	s1,280(sp)
    80004d5c:	a83d                	j	80004d9a <sys_link+0xf4>
    iunlockput(ip);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	eb8fe0ef          	jal	80003418 <iunlockput>
    end_op();
    80004d64:	efffe0ef          	jal	80003c62 <end_op>
    return -1;
    80004d68:	57fd                	li	a5,-1
    80004d6a:	64f2                	ld	s1,280(sp)
    80004d6c:	a03d                	j	80004d9a <sys_link+0xf4>
    iunlockput(dp);
    80004d6e:	854a                	mv	a0,s2
    80004d70:	ea8fe0ef          	jal	80003418 <iunlockput>
  ilock(ip);
    80004d74:	8526                	mv	a0,s1
    80004d76:	c98fe0ef          	jal	8000320e <ilock>
  ip->nlink--;
    80004d7a:	04a4d783          	lhu	a5,74(s1)
    80004d7e:	37fd                	addiw	a5,a5,-1
    80004d80:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d84:	8526                	mv	a0,s1
    80004d86:	bd4fe0ef          	jal	8000315a <iupdate>
  iunlockput(ip);
    80004d8a:	8526                	mv	a0,s1
    80004d8c:	e8cfe0ef          	jal	80003418 <iunlockput>
  end_op();
    80004d90:	ed3fe0ef          	jal	80003c62 <end_op>
  return -1;
    80004d94:	57fd                	li	a5,-1
    80004d96:	64f2                	ld	s1,280(sp)
    80004d98:	6952                	ld	s2,272(sp)
}
    80004d9a:	853e                	mv	a0,a5
    80004d9c:	70b2                	ld	ra,296(sp)
    80004d9e:	7412                	ld	s0,288(sp)
    80004da0:	6155                	addi	sp,sp,304
    80004da2:	8082                	ret

0000000080004da4 <sys_unlink>:
{
    80004da4:	7151                	addi	sp,sp,-240
    80004da6:	f586                	sd	ra,232(sp)
    80004da8:	f1a2                	sd	s0,224(sp)
    80004daa:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004dac:	08000613          	li	a2,128
    80004db0:	f3040593          	addi	a1,s0,-208
    80004db4:	4501                	li	a0,0
    80004db6:	a67fd0ef          	jal	8000281c <argstr>
    80004dba:	16054063          	bltz	a0,80004f1a <sys_unlink+0x176>
    80004dbe:	eda6                	sd	s1,216(sp)
  begin_op();
    80004dc0:	e39fe0ef          	jal	80003bf8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004dc4:	fb040593          	addi	a1,s0,-80
    80004dc8:	f3040513          	addi	a0,s0,-208
    80004dcc:	c73fe0ef          	jal	80003a3e <nameiparent>
    80004dd0:	84aa                	mv	s1,a0
    80004dd2:	c945                	beqz	a0,80004e82 <sys_unlink+0xde>
  ilock(dp);
    80004dd4:	c3afe0ef          	jal	8000320e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004dd8:	00003597          	auipc	a1,0x3
    80004ddc:	80858593          	addi	a1,a1,-2040 # 800075e0 <etext+0x5e0>
    80004de0:	fb040513          	addi	a0,s0,-80
    80004de4:	9c5fe0ef          	jal	800037a8 <namecmp>
    80004de8:	10050e63          	beqz	a0,80004f04 <sys_unlink+0x160>
    80004dec:	00002597          	auipc	a1,0x2
    80004df0:	7fc58593          	addi	a1,a1,2044 # 800075e8 <etext+0x5e8>
    80004df4:	fb040513          	addi	a0,s0,-80
    80004df8:	9b1fe0ef          	jal	800037a8 <namecmp>
    80004dfc:	10050463          	beqz	a0,80004f04 <sys_unlink+0x160>
    80004e00:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004e02:	f2c40613          	addi	a2,s0,-212
    80004e06:	fb040593          	addi	a1,s0,-80
    80004e0a:	8526                	mv	a0,s1
    80004e0c:	9b3fe0ef          	jal	800037be <dirlookup>
    80004e10:	892a                	mv	s2,a0
    80004e12:	0e050863          	beqz	a0,80004f02 <sys_unlink+0x15e>
  ilock(ip);
    80004e16:	bf8fe0ef          	jal	8000320e <ilock>
  if(ip->nlink < 1)
    80004e1a:	04a91783          	lh	a5,74(s2)
    80004e1e:	06f05763          	blez	a5,80004e8c <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004e22:	04491703          	lh	a4,68(s2)
    80004e26:	4785                	li	a5,1
    80004e28:	06f70963          	beq	a4,a5,80004e9a <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004e2c:	4641                	li	a2,16
    80004e2e:	4581                	li	a1,0
    80004e30:	fc040513          	addi	a0,s0,-64
    80004e34:	e6ffb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e38:	4741                	li	a4,16
    80004e3a:	f2c42683          	lw	a3,-212(s0)
    80004e3e:	fc040613          	addi	a2,s0,-64
    80004e42:	4581                	li	a1,0
    80004e44:	8526                	mv	a0,s1
    80004e46:	855fe0ef          	jal	8000369a <writei>
    80004e4a:	47c1                	li	a5,16
    80004e4c:	08f51b63          	bne	a0,a5,80004ee2 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004e50:	04491703          	lh	a4,68(s2)
    80004e54:	4785                	li	a5,1
    80004e56:	08f70d63          	beq	a4,a5,80004ef0 <sys_unlink+0x14c>
  iunlockput(dp);
    80004e5a:	8526                	mv	a0,s1
    80004e5c:	dbcfe0ef          	jal	80003418 <iunlockput>
  ip->nlink--;
    80004e60:	04a95783          	lhu	a5,74(s2)
    80004e64:	37fd                	addiw	a5,a5,-1
    80004e66:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e6a:	854a                	mv	a0,s2
    80004e6c:	aeefe0ef          	jal	8000315a <iupdate>
  iunlockput(ip);
    80004e70:	854a                	mv	a0,s2
    80004e72:	da6fe0ef          	jal	80003418 <iunlockput>
  end_op();
    80004e76:	dedfe0ef          	jal	80003c62 <end_op>
  return 0;
    80004e7a:	4501                	li	a0,0
    80004e7c:	64ee                	ld	s1,216(sp)
    80004e7e:	694e                	ld	s2,208(sp)
    80004e80:	a849                	j	80004f12 <sys_unlink+0x16e>
    end_op();
    80004e82:	de1fe0ef          	jal	80003c62 <end_op>
    return -1;
    80004e86:	557d                	li	a0,-1
    80004e88:	64ee                	ld	s1,216(sp)
    80004e8a:	a061                	j	80004f12 <sys_unlink+0x16e>
    80004e8c:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004e8e:	00002517          	auipc	a0,0x2
    80004e92:	76250513          	addi	a0,a0,1890 # 800075f0 <etext+0x5f0>
    80004e96:	94bfb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e9a:	04c92703          	lw	a4,76(s2)
    80004e9e:	02000793          	li	a5,32
    80004ea2:	f8e7f5e3          	bgeu	a5,a4,80004e2c <sys_unlink+0x88>
    80004ea6:	e5ce                	sd	s3,200(sp)
    80004ea8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004eac:	4741                	li	a4,16
    80004eae:	86ce                	mv	a3,s3
    80004eb0:	f1840613          	addi	a2,s0,-232
    80004eb4:	4581                	li	a1,0
    80004eb6:	854a                	mv	a0,s2
    80004eb8:	ee6fe0ef          	jal	8000359e <readi>
    80004ebc:	47c1                	li	a5,16
    80004ebe:	00f51c63          	bne	a0,a5,80004ed6 <sys_unlink+0x132>
    if(de.inum != 0)
    80004ec2:	f1845783          	lhu	a5,-232(s0)
    80004ec6:	efa1                	bnez	a5,80004f1e <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ec8:	29c1                	addiw	s3,s3,16
    80004eca:	04c92783          	lw	a5,76(s2)
    80004ece:	fcf9efe3          	bltu	s3,a5,80004eac <sys_unlink+0x108>
    80004ed2:	69ae                	ld	s3,200(sp)
    80004ed4:	bfa1                	j	80004e2c <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004ed6:	00002517          	auipc	a0,0x2
    80004eda:	73250513          	addi	a0,a0,1842 # 80007608 <etext+0x608>
    80004ede:	903fb0ef          	jal	800007e0 <panic>
    80004ee2:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004ee4:	00002517          	auipc	a0,0x2
    80004ee8:	73c50513          	addi	a0,a0,1852 # 80007620 <etext+0x620>
    80004eec:	8f5fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80004ef0:	04a4d783          	lhu	a5,74(s1)
    80004ef4:	37fd                	addiw	a5,a5,-1
    80004ef6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004efa:	8526                	mv	a0,s1
    80004efc:	a5efe0ef          	jal	8000315a <iupdate>
    80004f00:	bfa9                	j	80004e5a <sys_unlink+0xb6>
    80004f02:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004f04:	8526                	mv	a0,s1
    80004f06:	d12fe0ef          	jal	80003418 <iunlockput>
  end_op();
    80004f0a:	d59fe0ef          	jal	80003c62 <end_op>
  return -1;
    80004f0e:	557d                	li	a0,-1
    80004f10:	64ee                	ld	s1,216(sp)
}
    80004f12:	70ae                	ld	ra,232(sp)
    80004f14:	740e                	ld	s0,224(sp)
    80004f16:	616d                	addi	sp,sp,240
    80004f18:	8082                	ret
    return -1;
    80004f1a:	557d                	li	a0,-1
    80004f1c:	bfdd                	j	80004f12 <sys_unlink+0x16e>
    iunlockput(ip);
    80004f1e:	854a                	mv	a0,s2
    80004f20:	cf8fe0ef          	jal	80003418 <iunlockput>
    goto bad;
    80004f24:	694e                	ld	s2,208(sp)
    80004f26:	69ae                	ld	s3,200(sp)
    80004f28:	bff1                	j	80004f04 <sys_unlink+0x160>

0000000080004f2a <sys_open>:

uint64
sys_open(void)
{
    80004f2a:	7131                	addi	sp,sp,-192
    80004f2c:	fd06                	sd	ra,184(sp)
    80004f2e:	f922                	sd	s0,176(sp)
    80004f30:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004f32:	f4c40593          	addi	a1,s0,-180
    80004f36:	4505                	li	a0,1
    80004f38:	8adfd0ef          	jal	800027e4 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f3c:	08000613          	li	a2,128
    80004f40:	f5040593          	addi	a1,s0,-176
    80004f44:	4501                	li	a0,0
    80004f46:	8d7fd0ef          	jal	8000281c <argstr>
    80004f4a:	87aa                	mv	a5,a0
    return -1;
    80004f4c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f4e:	0a07c263          	bltz	a5,80004ff2 <sys_open+0xc8>
    80004f52:	f526                	sd	s1,168(sp)

  begin_op();
    80004f54:	ca5fe0ef          	jal	80003bf8 <begin_op>

  if(omode & O_CREATE){
    80004f58:	f4c42783          	lw	a5,-180(s0)
    80004f5c:	2007f793          	andi	a5,a5,512
    80004f60:	c3d5                	beqz	a5,80005004 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004f62:	4681                	li	a3,0
    80004f64:	4601                	li	a2,0
    80004f66:	4589                	li	a1,2
    80004f68:	f5040513          	addi	a0,s0,-176
    80004f6c:	aa9ff0ef          	jal	80004a14 <create>
    80004f70:	84aa                	mv	s1,a0
    if(ip == 0){
    80004f72:	c541                	beqz	a0,80004ffa <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004f74:	04449703          	lh	a4,68(s1)
    80004f78:	478d                	li	a5,3
    80004f7a:	00f71763          	bne	a4,a5,80004f88 <sys_open+0x5e>
    80004f7e:	0464d703          	lhu	a4,70(s1)
    80004f82:	47a5                	li	a5,9
    80004f84:	0ae7ed63          	bltu	a5,a4,8000503e <sys_open+0x114>
    80004f88:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004f8a:	fd7fe0ef          	jal	80003f60 <filealloc>
    80004f8e:	892a                	mv	s2,a0
    80004f90:	c179                	beqz	a0,80005056 <sys_open+0x12c>
    80004f92:	ed4e                	sd	s3,152(sp)
    80004f94:	a43ff0ef          	jal	800049d6 <fdalloc>
    80004f98:	89aa                	mv	s3,a0
    80004f9a:	0a054a63          	bltz	a0,8000504e <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004f9e:	04449703          	lh	a4,68(s1)
    80004fa2:	478d                	li	a5,3
    80004fa4:	0cf70263          	beq	a4,a5,80005068 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004fa8:	4789                	li	a5,2
    80004faa:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004fae:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004fb2:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004fb6:	f4c42783          	lw	a5,-180(s0)
    80004fba:	0017c713          	xori	a4,a5,1
    80004fbe:	8b05                	andi	a4,a4,1
    80004fc0:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004fc4:	0037f713          	andi	a4,a5,3
    80004fc8:	00e03733          	snez	a4,a4
    80004fcc:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004fd0:	4007f793          	andi	a5,a5,1024
    80004fd4:	c791                	beqz	a5,80004fe0 <sys_open+0xb6>
    80004fd6:	04449703          	lh	a4,68(s1)
    80004fda:	4789                	li	a5,2
    80004fdc:	08f70d63          	beq	a4,a5,80005076 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	adafe0ef          	jal	800032bc <iunlock>
  end_op();
    80004fe6:	c7dfe0ef          	jal	80003c62 <end_op>

  return fd;
    80004fea:	854e                	mv	a0,s3
    80004fec:	74aa                	ld	s1,168(sp)
    80004fee:	790a                	ld	s2,160(sp)
    80004ff0:	69ea                	ld	s3,152(sp)
}
    80004ff2:	70ea                	ld	ra,184(sp)
    80004ff4:	744a                	ld	s0,176(sp)
    80004ff6:	6129                	addi	sp,sp,192
    80004ff8:	8082                	ret
      end_op();
    80004ffa:	c69fe0ef          	jal	80003c62 <end_op>
      return -1;
    80004ffe:	557d                	li	a0,-1
    80005000:	74aa                	ld	s1,168(sp)
    80005002:	bfc5                	j	80004ff2 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005004:	f5040513          	addi	a0,s0,-176
    80005008:	a1dfe0ef          	jal	80003a24 <namei>
    8000500c:	84aa                	mv	s1,a0
    8000500e:	c11d                	beqz	a0,80005034 <sys_open+0x10a>
    ilock(ip);
    80005010:	9fefe0ef          	jal	8000320e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005014:	04449703          	lh	a4,68(s1)
    80005018:	4785                	li	a5,1
    8000501a:	f4f71de3          	bne	a4,a5,80004f74 <sys_open+0x4a>
    8000501e:	f4c42783          	lw	a5,-180(s0)
    80005022:	d3bd                	beqz	a5,80004f88 <sys_open+0x5e>
      iunlockput(ip);
    80005024:	8526                	mv	a0,s1
    80005026:	bf2fe0ef          	jal	80003418 <iunlockput>
      end_op();
    8000502a:	c39fe0ef          	jal	80003c62 <end_op>
      return -1;
    8000502e:	557d                	li	a0,-1
    80005030:	74aa                	ld	s1,168(sp)
    80005032:	b7c1                	j	80004ff2 <sys_open+0xc8>
      end_op();
    80005034:	c2ffe0ef          	jal	80003c62 <end_op>
      return -1;
    80005038:	557d                	li	a0,-1
    8000503a:	74aa                	ld	s1,168(sp)
    8000503c:	bf5d                	j	80004ff2 <sys_open+0xc8>
    iunlockput(ip);
    8000503e:	8526                	mv	a0,s1
    80005040:	bd8fe0ef          	jal	80003418 <iunlockput>
    end_op();
    80005044:	c1ffe0ef          	jal	80003c62 <end_op>
    return -1;
    80005048:	557d                	li	a0,-1
    8000504a:	74aa                	ld	s1,168(sp)
    8000504c:	b75d                	j	80004ff2 <sys_open+0xc8>
      fileclose(f);
    8000504e:	854a                	mv	a0,s2
    80005050:	fb5fe0ef          	jal	80004004 <fileclose>
    80005054:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005056:	8526                	mv	a0,s1
    80005058:	bc0fe0ef          	jal	80003418 <iunlockput>
    end_op();
    8000505c:	c07fe0ef          	jal	80003c62 <end_op>
    return -1;
    80005060:	557d                	li	a0,-1
    80005062:	74aa                	ld	s1,168(sp)
    80005064:	790a                	ld	s2,160(sp)
    80005066:	b771                	j	80004ff2 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005068:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000506c:	04649783          	lh	a5,70(s1)
    80005070:	02f91223          	sh	a5,36(s2)
    80005074:	bf3d                	j	80004fb2 <sys_open+0x88>
    itrunc(ip);
    80005076:	8526                	mv	a0,s1
    80005078:	a84fe0ef          	jal	800032fc <itrunc>
    8000507c:	b795                	j	80004fe0 <sys_open+0xb6>

000000008000507e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000507e:	7175                	addi	sp,sp,-144
    80005080:	e506                	sd	ra,136(sp)
    80005082:	e122                	sd	s0,128(sp)
    80005084:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005086:	b73fe0ef          	jal	80003bf8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000508a:	08000613          	li	a2,128
    8000508e:	f7040593          	addi	a1,s0,-144
    80005092:	4501                	li	a0,0
    80005094:	f88fd0ef          	jal	8000281c <argstr>
    80005098:	02054363          	bltz	a0,800050be <sys_mkdir+0x40>
    8000509c:	4681                	li	a3,0
    8000509e:	4601                	li	a2,0
    800050a0:	4585                	li	a1,1
    800050a2:	f7040513          	addi	a0,s0,-144
    800050a6:	96fff0ef          	jal	80004a14 <create>
    800050aa:	c911                	beqz	a0,800050be <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050ac:	b6cfe0ef          	jal	80003418 <iunlockput>
  end_op();
    800050b0:	bb3fe0ef          	jal	80003c62 <end_op>
  return 0;
    800050b4:	4501                	li	a0,0
}
    800050b6:	60aa                	ld	ra,136(sp)
    800050b8:	640a                	ld	s0,128(sp)
    800050ba:	6149                	addi	sp,sp,144
    800050bc:	8082                	ret
    end_op();
    800050be:	ba5fe0ef          	jal	80003c62 <end_op>
    return -1;
    800050c2:	557d                	li	a0,-1
    800050c4:	bfcd                	j	800050b6 <sys_mkdir+0x38>

00000000800050c6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800050c6:	7135                	addi	sp,sp,-160
    800050c8:	ed06                	sd	ra,152(sp)
    800050ca:	e922                	sd	s0,144(sp)
    800050cc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800050ce:	b2bfe0ef          	jal	80003bf8 <begin_op>
  argint(1, &major);
    800050d2:	f6c40593          	addi	a1,s0,-148
    800050d6:	4505                	li	a0,1
    800050d8:	f0cfd0ef          	jal	800027e4 <argint>
  argint(2, &minor);
    800050dc:	f6840593          	addi	a1,s0,-152
    800050e0:	4509                	li	a0,2
    800050e2:	f02fd0ef          	jal	800027e4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050e6:	08000613          	li	a2,128
    800050ea:	f7040593          	addi	a1,s0,-144
    800050ee:	4501                	li	a0,0
    800050f0:	f2cfd0ef          	jal	8000281c <argstr>
    800050f4:	02054563          	bltz	a0,8000511e <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800050f8:	f6841683          	lh	a3,-152(s0)
    800050fc:	f6c41603          	lh	a2,-148(s0)
    80005100:	458d                	li	a1,3
    80005102:	f7040513          	addi	a0,s0,-144
    80005106:	90fff0ef          	jal	80004a14 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000510a:	c911                	beqz	a0,8000511e <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000510c:	b0cfe0ef          	jal	80003418 <iunlockput>
  end_op();
    80005110:	b53fe0ef          	jal	80003c62 <end_op>
  return 0;
    80005114:	4501                	li	a0,0
}
    80005116:	60ea                	ld	ra,152(sp)
    80005118:	644a                	ld	s0,144(sp)
    8000511a:	610d                	addi	sp,sp,160
    8000511c:	8082                	ret
    end_op();
    8000511e:	b45fe0ef          	jal	80003c62 <end_op>
    return -1;
    80005122:	557d                	li	a0,-1
    80005124:	bfcd                	j	80005116 <sys_mknod+0x50>

0000000080005126 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005126:	7135                	addi	sp,sp,-160
    80005128:	ed06                	sd	ra,152(sp)
    8000512a:	e922                	sd	s0,144(sp)
    8000512c:	e14a                	sd	s2,128(sp)
    8000512e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005130:	f9efc0ef          	jal	800018ce <myproc>
    80005134:	892a                	mv	s2,a0
  
  begin_op();
    80005136:	ac3fe0ef          	jal	80003bf8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000513a:	08000613          	li	a2,128
    8000513e:	f6040593          	addi	a1,s0,-160
    80005142:	4501                	li	a0,0
    80005144:	ed8fd0ef          	jal	8000281c <argstr>
    80005148:	04054363          	bltz	a0,8000518e <sys_chdir+0x68>
    8000514c:	e526                	sd	s1,136(sp)
    8000514e:	f6040513          	addi	a0,s0,-160
    80005152:	8d3fe0ef          	jal	80003a24 <namei>
    80005156:	84aa                	mv	s1,a0
    80005158:	c915                	beqz	a0,8000518c <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000515a:	8b4fe0ef          	jal	8000320e <ilock>
  if(ip->type != T_DIR){
    8000515e:	04449703          	lh	a4,68(s1)
    80005162:	4785                	li	a5,1
    80005164:	02f71963          	bne	a4,a5,80005196 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005168:	8526                	mv	a0,s1
    8000516a:	952fe0ef          	jal	800032bc <iunlock>
  iput(p->cwd);
    8000516e:	15093503          	ld	a0,336(s2)
    80005172:	a1efe0ef          	jal	80003390 <iput>
  end_op();
    80005176:	aedfe0ef          	jal	80003c62 <end_op>
  p->cwd = ip;
    8000517a:	14993823          	sd	s1,336(s2)
  return 0;
    8000517e:	4501                	li	a0,0
    80005180:	64aa                	ld	s1,136(sp)
}
    80005182:	60ea                	ld	ra,152(sp)
    80005184:	644a                	ld	s0,144(sp)
    80005186:	690a                	ld	s2,128(sp)
    80005188:	610d                	addi	sp,sp,160
    8000518a:	8082                	ret
    8000518c:	64aa                	ld	s1,136(sp)
    end_op();
    8000518e:	ad5fe0ef          	jal	80003c62 <end_op>
    return -1;
    80005192:	557d                	li	a0,-1
    80005194:	b7fd                	j	80005182 <sys_chdir+0x5c>
    iunlockput(ip);
    80005196:	8526                	mv	a0,s1
    80005198:	a80fe0ef          	jal	80003418 <iunlockput>
    end_op();
    8000519c:	ac7fe0ef          	jal	80003c62 <end_op>
    return -1;
    800051a0:	557d                	li	a0,-1
    800051a2:	64aa                	ld	s1,136(sp)
    800051a4:	bff9                	j	80005182 <sys_chdir+0x5c>

00000000800051a6 <sys_exec>:

uint64
sys_exec(void)
{
    800051a6:	7121                	addi	sp,sp,-448
    800051a8:	ff06                	sd	ra,440(sp)
    800051aa:	fb22                	sd	s0,432(sp)
    800051ac:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800051ae:	e4840593          	addi	a1,s0,-440
    800051b2:	4505                	li	a0,1
    800051b4:	e4cfd0ef          	jal	80002800 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800051b8:	08000613          	li	a2,128
    800051bc:	f5040593          	addi	a1,s0,-176
    800051c0:	4501                	li	a0,0
    800051c2:	e5afd0ef          	jal	8000281c <argstr>
    800051c6:	87aa                	mv	a5,a0
    return -1;
    800051c8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800051ca:	0c07c463          	bltz	a5,80005292 <sys_exec+0xec>
    800051ce:	f726                	sd	s1,424(sp)
    800051d0:	f34a                	sd	s2,416(sp)
    800051d2:	ef4e                	sd	s3,408(sp)
    800051d4:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800051d6:	10000613          	li	a2,256
    800051da:	4581                	li	a1,0
    800051dc:	e5040513          	addi	a0,s0,-432
    800051e0:	ac3fb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800051e4:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800051e8:	89a6                	mv	s3,s1
    800051ea:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800051ec:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051f0:	00391513          	slli	a0,s2,0x3
    800051f4:	e4040593          	addi	a1,s0,-448
    800051f8:	e4843783          	ld	a5,-440(s0)
    800051fc:	953e                	add	a0,a0,a5
    800051fe:	d5cfd0ef          	jal	8000275a <fetchaddr>
    80005202:	02054663          	bltz	a0,8000522e <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005206:	e4043783          	ld	a5,-448(s0)
    8000520a:	c3a9                	beqz	a5,8000524c <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000520c:	8f3fb0ef          	jal	80000afe <kalloc>
    80005210:	85aa                	mv	a1,a0
    80005212:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005216:	cd01                	beqz	a0,8000522e <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005218:	6605                	lui	a2,0x1
    8000521a:	e4043503          	ld	a0,-448(s0)
    8000521e:	d86fd0ef          	jal	800027a4 <fetchstr>
    80005222:	00054663          	bltz	a0,8000522e <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005226:	0905                	addi	s2,s2,1
    80005228:	09a1                	addi	s3,s3,8
    8000522a:	fd4913e3          	bne	s2,s4,800051f0 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000522e:	f5040913          	addi	s2,s0,-176
    80005232:	6088                	ld	a0,0(s1)
    80005234:	c931                	beqz	a0,80005288 <sys_exec+0xe2>
    kfree(argv[i]);
    80005236:	fe6fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000523a:	04a1                	addi	s1,s1,8
    8000523c:	ff249be3          	bne	s1,s2,80005232 <sys_exec+0x8c>
  return -1;
    80005240:	557d                	li	a0,-1
    80005242:	74ba                	ld	s1,424(sp)
    80005244:	791a                	ld	s2,416(sp)
    80005246:	69fa                	ld	s3,408(sp)
    80005248:	6a5a                	ld	s4,400(sp)
    8000524a:	a0a1                	j	80005292 <sys_exec+0xec>
      argv[i] = 0;
    8000524c:	0009079b          	sext.w	a5,s2
    80005250:	078e                	slli	a5,a5,0x3
    80005252:	fd078793          	addi	a5,a5,-48
    80005256:	97a2                	add	a5,a5,s0
    80005258:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    8000525c:	e5040593          	addi	a1,s0,-432
    80005260:	f5040513          	addi	a0,s0,-176
    80005264:	ba8ff0ef          	jal	8000460c <kexec>
    80005268:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000526a:	f5040993          	addi	s3,s0,-176
    8000526e:	6088                	ld	a0,0(s1)
    80005270:	c511                	beqz	a0,8000527c <sys_exec+0xd6>
    kfree(argv[i]);
    80005272:	faafb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005276:	04a1                	addi	s1,s1,8
    80005278:	ff349be3          	bne	s1,s3,8000526e <sys_exec+0xc8>
  return ret;
    8000527c:	854a                	mv	a0,s2
    8000527e:	74ba                	ld	s1,424(sp)
    80005280:	791a                	ld	s2,416(sp)
    80005282:	69fa                	ld	s3,408(sp)
    80005284:	6a5a                	ld	s4,400(sp)
    80005286:	a031                	j	80005292 <sys_exec+0xec>
  return -1;
    80005288:	557d                	li	a0,-1
    8000528a:	74ba                	ld	s1,424(sp)
    8000528c:	791a                	ld	s2,416(sp)
    8000528e:	69fa                	ld	s3,408(sp)
    80005290:	6a5a                	ld	s4,400(sp)
}
    80005292:	70fa                	ld	ra,440(sp)
    80005294:	745a                	ld	s0,432(sp)
    80005296:	6139                	addi	sp,sp,448
    80005298:	8082                	ret

000000008000529a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000529a:	7139                	addi	sp,sp,-64
    8000529c:	fc06                	sd	ra,56(sp)
    8000529e:	f822                	sd	s0,48(sp)
    800052a0:	f426                	sd	s1,40(sp)
    800052a2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800052a4:	e2afc0ef          	jal	800018ce <myproc>
    800052a8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800052aa:	fd840593          	addi	a1,s0,-40
    800052ae:	4501                	li	a0,0
    800052b0:	d50fd0ef          	jal	80002800 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800052b4:	fc840593          	addi	a1,s0,-56
    800052b8:	fd040513          	addi	a0,s0,-48
    800052bc:	852ff0ef          	jal	8000430e <pipealloc>
    return -1;
    800052c0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800052c2:	0a054463          	bltz	a0,8000536a <sys_pipe+0xd0>
  fd0 = -1;
    800052c6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800052ca:	fd043503          	ld	a0,-48(s0)
    800052ce:	f08ff0ef          	jal	800049d6 <fdalloc>
    800052d2:	fca42223          	sw	a0,-60(s0)
    800052d6:	08054163          	bltz	a0,80005358 <sys_pipe+0xbe>
    800052da:	fc843503          	ld	a0,-56(s0)
    800052de:	ef8ff0ef          	jal	800049d6 <fdalloc>
    800052e2:	fca42023          	sw	a0,-64(s0)
    800052e6:	06054063          	bltz	a0,80005346 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052ea:	4691                	li	a3,4
    800052ec:	fc440613          	addi	a2,s0,-60
    800052f0:	fd843583          	ld	a1,-40(s0)
    800052f4:	68a8                	ld	a0,80(s1)
    800052f6:	aecfc0ef          	jal	800015e2 <copyout>
    800052fa:	00054e63          	bltz	a0,80005316 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800052fe:	4691                	li	a3,4
    80005300:	fc040613          	addi	a2,s0,-64
    80005304:	fd843583          	ld	a1,-40(s0)
    80005308:	0591                	addi	a1,a1,4
    8000530a:	68a8                	ld	a0,80(s1)
    8000530c:	ad6fc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005310:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005312:	04055c63          	bgez	a0,8000536a <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005316:	fc442783          	lw	a5,-60(s0)
    8000531a:	07e9                	addi	a5,a5,26
    8000531c:	078e                	slli	a5,a5,0x3
    8000531e:	97a6                	add	a5,a5,s1
    80005320:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005324:	fc042783          	lw	a5,-64(s0)
    80005328:	07e9                	addi	a5,a5,26
    8000532a:	078e                	slli	a5,a5,0x3
    8000532c:	94be                	add	s1,s1,a5
    8000532e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005332:	fd043503          	ld	a0,-48(s0)
    80005336:	ccffe0ef          	jal	80004004 <fileclose>
    fileclose(wf);
    8000533a:	fc843503          	ld	a0,-56(s0)
    8000533e:	cc7fe0ef          	jal	80004004 <fileclose>
    return -1;
    80005342:	57fd                	li	a5,-1
    80005344:	a01d                	j	8000536a <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005346:	fc442783          	lw	a5,-60(s0)
    8000534a:	0007c763          	bltz	a5,80005358 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000534e:	07e9                	addi	a5,a5,26
    80005350:	078e                	slli	a5,a5,0x3
    80005352:	97a6                	add	a5,a5,s1
    80005354:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005358:	fd043503          	ld	a0,-48(s0)
    8000535c:	ca9fe0ef          	jal	80004004 <fileclose>
    fileclose(wf);
    80005360:	fc843503          	ld	a0,-56(s0)
    80005364:	ca1fe0ef          	jal	80004004 <fileclose>
    return -1;
    80005368:	57fd                	li	a5,-1
}
    8000536a:	853e                	mv	a0,a5
    8000536c:	70e2                	ld	ra,56(sp)
    8000536e:	7442                	ld	s0,48(sp)
    80005370:	74a2                	ld	s1,40(sp)
    80005372:	6121                	addi	sp,sp,64
    80005374:	8082                	ret
	...

0000000080005380 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005380:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005382:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005384:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005386:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005388:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000538a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000538c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000538e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005390:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005392:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005394:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005396:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005398:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000539a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000539c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000539e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800053a0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800053a2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800053a4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800053a6:	ac4fd0ef          	jal	8000266a <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800053aa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800053ac:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800053ae:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800053b0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800053b2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800053b4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800053b6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800053b8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800053ba:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800053bc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800053be:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800053c0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800053c2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800053c4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800053c6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800053c8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800053ca:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800053cc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800053ce:	10200073          	sret
	...

00000000800053de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800053de:	1141                	addi	sp,sp,-16
    800053e0:	e422                	sd	s0,8(sp)
    800053e2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800053e4:	0c0007b7          	lui	a5,0xc000
    800053e8:	4705                	li	a4,1
    800053ea:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800053ec:	0c0007b7          	lui	a5,0xc000
    800053f0:	c3d8                	sw	a4,4(a5)
}
    800053f2:	6422                	ld	s0,8(sp)
    800053f4:	0141                	addi	sp,sp,16
    800053f6:	8082                	ret

00000000800053f8 <plicinithart>:

void
plicinithart(void)
{
    800053f8:	1141                	addi	sp,sp,-16
    800053fa:	e406                	sd	ra,8(sp)
    800053fc:	e022                	sd	s0,0(sp)
    800053fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005400:	ca2fc0ef          	jal	800018a2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005404:	0085171b          	slliw	a4,a0,0x8
    80005408:	0c0027b7          	lui	a5,0xc002
    8000540c:	97ba                	add	a5,a5,a4
    8000540e:	40200713          	li	a4,1026
    80005412:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005416:	00d5151b          	slliw	a0,a0,0xd
    8000541a:	0c2017b7          	lui	a5,0xc201
    8000541e:	97aa                	add	a5,a5,a0
    80005420:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005424:	60a2                	ld	ra,8(sp)
    80005426:	6402                	ld	s0,0(sp)
    80005428:	0141                	addi	sp,sp,16
    8000542a:	8082                	ret

000000008000542c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000542c:	1141                	addi	sp,sp,-16
    8000542e:	e406                	sd	ra,8(sp)
    80005430:	e022                	sd	s0,0(sp)
    80005432:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005434:	c6efc0ef          	jal	800018a2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005438:	00d5151b          	slliw	a0,a0,0xd
    8000543c:	0c2017b7          	lui	a5,0xc201
    80005440:	97aa                	add	a5,a5,a0
  return irq;
}
    80005442:	43c8                	lw	a0,4(a5)
    80005444:	60a2                	ld	ra,8(sp)
    80005446:	6402                	ld	s0,0(sp)
    80005448:	0141                	addi	sp,sp,16
    8000544a:	8082                	ret

000000008000544c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000544c:	1101                	addi	sp,sp,-32
    8000544e:	ec06                	sd	ra,24(sp)
    80005450:	e822                	sd	s0,16(sp)
    80005452:	e426                	sd	s1,8(sp)
    80005454:	1000                	addi	s0,sp,32
    80005456:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005458:	c4afc0ef          	jal	800018a2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000545c:	00d5151b          	slliw	a0,a0,0xd
    80005460:	0c2017b7          	lui	a5,0xc201
    80005464:	97aa                	add	a5,a5,a0
    80005466:	c3c4                	sw	s1,4(a5)
}
    80005468:	60e2                	ld	ra,24(sp)
    8000546a:	6442                	ld	s0,16(sp)
    8000546c:	64a2                	ld	s1,8(sp)
    8000546e:	6105                	addi	sp,sp,32
    80005470:	8082                	ret

0000000080005472 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005472:	1141                	addi	sp,sp,-16
    80005474:	e406                	sd	ra,8(sp)
    80005476:	e022                	sd	s0,0(sp)
    80005478:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000547a:	479d                	li	a5,7
    8000547c:	04a7ca63          	blt	a5,a0,800054d0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005480:	0001b797          	auipc	a5,0x1b
    80005484:	7d878793          	addi	a5,a5,2008 # 80020c58 <disk>
    80005488:	97aa                	add	a5,a5,a0
    8000548a:	0187c783          	lbu	a5,24(a5)
    8000548e:	e7b9                	bnez	a5,800054dc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005490:	00451693          	slli	a3,a0,0x4
    80005494:	0001b797          	auipc	a5,0x1b
    80005498:	7c478793          	addi	a5,a5,1988 # 80020c58 <disk>
    8000549c:	6398                	ld	a4,0(a5)
    8000549e:	9736                	add	a4,a4,a3
    800054a0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800054a4:	6398                	ld	a4,0(a5)
    800054a6:	9736                	add	a4,a4,a3
    800054a8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800054ac:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800054b0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800054b4:	97aa                	add	a5,a5,a0
    800054b6:	4705                	li	a4,1
    800054b8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800054bc:	0001b517          	auipc	a0,0x1b
    800054c0:	7b450513          	addi	a0,a0,1972 # 80020c70 <disk+0x18>
    800054c4:	a69fc0ef          	jal	80001f2c <wakeup>
}
    800054c8:	60a2                	ld	ra,8(sp)
    800054ca:	6402                	ld	s0,0(sp)
    800054cc:	0141                	addi	sp,sp,16
    800054ce:	8082                	ret
    panic("free_desc 1");
    800054d0:	00002517          	auipc	a0,0x2
    800054d4:	16050513          	addi	a0,a0,352 # 80007630 <etext+0x630>
    800054d8:	b08fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    800054dc:	00002517          	auipc	a0,0x2
    800054e0:	16450513          	addi	a0,a0,356 # 80007640 <etext+0x640>
    800054e4:	afcfb0ef          	jal	800007e0 <panic>

00000000800054e8 <virtio_disk_init>:
{
    800054e8:	1101                	addi	sp,sp,-32
    800054ea:	ec06                	sd	ra,24(sp)
    800054ec:	e822                	sd	s0,16(sp)
    800054ee:	e426                	sd	s1,8(sp)
    800054f0:	e04a                	sd	s2,0(sp)
    800054f2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800054f4:	00002597          	auipc	a1,0x2
    800054f8:	15c58593          	addi	a1,a1,348 # 80007650 <etext+0x650>
    800054fc:	0001c517          	auipc	a0,0x1c
    80005500:	88450513          	addi	a0,a0,-1916 # 80020d80 <disk+0x128>
    80005504:	e4afb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005508:	100017b7          	lui	a5,0x10001
    8000550c:	4398                	lw	a4,0(a5)
    8000550e:	2701                	sext.w	a4,a4
    80005510:	747277b7          	lui	a5,0x74727
    80005514:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005518:	18f71063          	bne	a4,a5,80005698 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000551c:	100017b7          	lui	a5,0x10001
    80005520:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005522:	439c                	lw	a5,0(a5)
    80005524:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005526:	4709                	li	a4,2
    80005528:	16e79863          	bne	a5,a4,80005698 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000552c:	100017b7          	lui	a5,0x10001
    80005530:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005532:	439c                	lw	a5,0(a5)
    80005534:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005536:	16e79163          	bne	a5,a4,80005698 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000553a:	100017b7          	lui	a5,0x10001
    8000553e:	47d8                	lw	a4,12(a5)
    80005540:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005542:	554d47b7          	lui	a5,0x554d4
    80005546:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000554a:	14f71763          	bne	a4,a5,80005698 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000554e:	100017b7          	lui	a5,0x10001
    80005552:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005556:	4705                	li	a4,1
    80005558:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000555a:	470d                	li	a4,3
    8000555c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000555e:	10001737          	lui	a4,0x10001
    80005562:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005564:	c7ffe737          	lui	a4,0xc7ffe
    80005568:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd9c7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000556c:	8ef9                	and	a3,a3,a4
    8000556e:	10001737          	lui	a4,0x10001
    80005572:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005574:	472d                	li	a4,11
    80005576:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005578:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000557c:	439c                	lw	a5,0(a5)
    8000557e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005582:	8ba1                	andi	a5,a5,8
    80005584:	12078063          	beqz	a5,800056a4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005588:	100017b7          	lui	a5,0x10001
    8000558c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005590:	100017b7          	lui	a5,0x10001
    80005594:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005598:	439c                	lw	a5,0(a5)
    8000559a:	2781                	sext.w	a5,a5
    8000559c:	10079a63          	bnez	a5,800056b0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800055a0:	100017b7          	lui	a5,0x10001
    800055a4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800055a8:	439c                	lw	a5,0(a5)
    800055aa:	2781                	sext.w	a5,a5
  if(max == 0)
    800055ac:	10078863          	beqz	a5,800056bc <virtio_disk_init+0x1d4>
  if(max < NUM)
    800055b0:	471d                	li	a4,7
    800055b2:	10f77b63          	bgeu	a4,a5,800056c8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800055b6:	d48fb0ef          	jal	80000afe <kalloc>
    800055ba:	0001b497          	auipc	s1,0x1b
    800055be:	69e48493          	addi	s1,s1,1694 # 80020c58 <disk>
    800055c2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800055c4:	d3afb0ef          	jal	80000afe <kalloc>
    800055c8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800055ca:	d34fb0ef          	jal	80000afe <kalloc>
    800055ce:	87aa                	mv	a5,a0
    800055d0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800055d2:	6088                	ld	a0,0(s1)
    800055d4:	10050063          	beqz	a0,800056d4 <virtio_disk_init+0x1ec>
    800055d8:	0001b717          	auipc	a4,0x1b
    800055dc:	68873703          	ld	a4,1672(a4) # 80020c60 <disk+0x8>
    800055e0:	0e070a63          	beqz	a4,800056d4 <virtio_disk_init+0x1ec>
    800055e4:	0e078863          	beqz	a5,800056d4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800055e8:	6605                	lui	a2,0x1
    800055ea:	4581                	li	a1,0
    800055ec:	eb6fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800055f0:	0001b497          	auipc	s1,0x1b
    800055f4:	66848493          	addi	s1,s1,1640 # 80020c58 <disk>
    800055f8:	6605                	lui	a2,0x1
    800055fa:	4581                	li	a1,0
    800055fc:	6488                	ld	a0,8(s1)
    800055fe:	ea4fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005602:	6605                	lui	a2,0x1
    80005604:	4581                	li	a1,0
    80005606:	6888                	ld	a0,16(s1)
    80005608:	e9afb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000560c:	100017b7          	lui	a5,0x10001
    80005610:	4721                	li	a4,8
    80005612:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005614:	4098                	lw	a4,0(s1)
    80005616:	100017b7          	lui	a5,0x10001
    8000561a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000561e:	40d8                	lw	a4,4(s1)
    80005620:	100017b7          	lui	a5,0x10001
    80005624:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005628:	649c                	ld	a5,8(s1)
    8000562a:	0007869b          	sext.w	a3,a5
    8000562e:	10001737          	lui	a4,0x10001
    80005632:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005636:	9781                	srai	a5,a5,0x20
    80005638:	10001737          	lui	a4,0x10001
    8000563c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005640:	689c                	ld	a5,16(s1)
    80005642:	0007869b          	sext.w	a3,a5
    80005646:	10001737          	lui	a4,0x10001
    8000564a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000564e:	9781                	srai	a5,a5,0x20
    80005650:	10001737          	lui	a4,0x10001
    80005654:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005658:	10001737          	lui	a4,0x10001
    8000565c:	4785                	li	a5,1
    8000565e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005660:	00f48c23          	sb	a5,24(s1)
    80005664:	00f48ca3          	sb	a5,25(s1)
    80005668:	00f48d23          	sb	a5,26(s1)
    8000566c:	00f48da3          	sb	a5,27(s1)
    80005670:	00f48e23          	sb	a5,28(s1)
    80005674:	00f48ea3          	sb	a5,29(s1)
    80005678:	00f48f23          	sb	a5,30(s1)
    8000567c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005680:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005684:	100017b7          	lui	a5,0x10001
    80005688:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000568c:	60e2                	ld	ra,24(sp)
    8000568e:	6442                	ld	s0,16(sp)
    80005690:	64a2                	ld	s1,8(sp)
    80005692:	6902                	ld	s2,0(sp)
    80005694:	6105                	addi	sp,sp,32
    80005696:	8082                	ret
    panic("could not find virtio disk");
    80005698:	00002517          	auipc	a0,0x2
    8000569c:	fc850513          	addi	a0,a0,-56 # 80007660 <etext+0x660>
    800056a0:	940fb0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    800056a4:	00002517          	auipc	a0,0x2
    800056a8:	fdc50513          	addi	a0,a0,-36 # 80007680 <etext+0x680>
    800056ac:	934fb0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    800056b0:	00002517          	auipc	a0,0x2
    800056b4:	ff050513          	addi	a0,a0,-16 # 800076a0 <etext+0x6a0>
    800056b8:	928fb0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    800056bc:	00002517          	auipc	a0,0x2
    800056c0:	00450513          	addi	a0,a0,4 # 800076c0 <etext+0x6c0>
    800056c4:	91cfb0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    800056c8:	00002517          	auipc	a0,0x2
    800056cc:	01850513          	addi	a0,a0,24 # 800076e0 <etext+0x6e0>
    800056d0:	910fb0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    800056d4:	00002517          	auipc	a0,0x2
    800056d8:	02c50513          	addi	a0,a0,44 # 80007700 <etext+0x700>
    800056dc:	904fb0ef          	jal	800007e0 <panic>

00000000800056e0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800056e0:	7159                	addi	sp,sp,-112
    800056e2:	f486                	sd	ra,104(sp)
    800056e4:	f0a2                	sd	s0,96(sp)
    800056e6:	eca6                	sd	s1,88(sp)
    800056e8:	e8ca                	sd	s2,80(sp)
    800056ea:	e4ce                	sd	s3,72(sp)
    800056ec:	e0d2                	sd	s4,64(sp)
    800056ee:	fc56                	sd	s5,56(sp)
    800056f0:	f85a                	sd	s6,48(sp)
    800056f2:	f45e                	sd	s7,40(sp)
    800056f4:	f062                	sd	s8,32(sp)
    800056f6:	ec66                	sd	s9,24(sp)
    800056f8:	1880                	addi	s0,sp,112
    800056fa:	8a2a                	mv	s4,a0
    800056fc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800056fe:	00c52c83          	lw	s9,12(a0)
    80005702:	001c9c9b          	slliw	s9,s9,0x1
    80005706:	1c82                	slli	s9,s9,0x20
    80005708:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000570c:	0001b517          	auipc	a0,0x1b
    80005710:	67450513          	addi	a0,a0,1652 # 80020d80 <disk+0x128>
    80005714:	cbafb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    80005718:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000571a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000571c:	0001bb17          	auipc	s6,0x1b
    80005720:	53cb0b13          	addi	s6,s6,1340 # 80020c58 <disk>
  for(int i = 0; i < 3; i++){
    80005724:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005726:	0001bc17          	auipc	s8,0x1b
    8000572a:	65ac0c13          	addi	s8,s8,1626 # 80020d80 <disk+0x128>
    8000572e:	a8b9                	j	8000578c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005730:	00fb0733          	add	a4,s6,a5
    80005734:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005738:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000573a:	0207c563          	bltz	a5,80005764 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000573e:	2905                	addiw	s2,s2,1
    80005740:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005742:	05590963          	beq	s2,s5,80005794 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005746:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005748:	0001b717          	auipc	a4,0x1b
    8000574c:	51070713          	addi	a4,a4,1296 # 80020c58 <disk>
    80005750:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005752:	01874683          	lbu	a3,24(a4)
    80005756:	fee9                	bnez	a3,80005730 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005758:	2785                	addiw	a5,a5,1
    8000575a:	0705                	addi	a4,a4,1
    8000575c:	fe979be3          	bne	a5,s1,80005752 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005760:	57fd                	li	a5,-1
    80005762:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005764:	01205d63          	blez	s2,8000577e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005768:	f9042503          	lw	a0,-112(s0)
    8000576c:	d07ff0ef          	jal	80005472 <free_desc>
      for(int j = 0; j < i; j++)
    80005770:	4785                	li	a5,1
    80005772:	0127d663          	bge	a5,s2,8000577e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005776:	f9442503          	lw	a0,-108(s0)
    8000577a:	cf9ff0ef          	jal	80005472 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000577e:	85e2                	mv	a1,s8
    80005780:	0001b517          	auipc	a0,0x1b
    80005784:	4f050513          	addi	a0,a0,1264 # 80020c70 <disk+0x18>
    80005788:	f58fc0ef          	jal	80001ee0 <sleep>
  for(int i = 0; i < 3; i++){
    8000578c:	f9040613          	addi	a2,s0,-112
    80005790:	894e                	mv	s2,s3
    80005792:	bf55                	j	80005746 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005794:	f9042503          	lw	a0,-112(s0)
    80005798:	00451693          	slli	a3,a0,0x4

  if(write)
    8000579c:	0001b797          	auipc	a5,0x1b
    800057a0:	4bc78793          	addi	a5,a5,1212 # 80020c58 <disk>
    800057a4:	00a50713          	addi	a4,a0,10
    800057a8:	0712                	slli	a4,a4,0x4
    800057aa:	973e                	add	a4,a4,a5
    800057ac:	01703633          	snez	a2,s7
    800057b0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800057b2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800057b6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800057ba:	6398                	ld	a4,0(a5)
    800057bc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057be:	0a868613          	addi	a2,a3,168
    800057c2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800057c4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800057c6:	6390                	ld	a2,0(a5)
    800057c8:	00d605b3          	add	a1,a2,a3
    800057cc:	4741                	li	a4,16
    800057ce:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800057d0:	4805                	li	a6,1
    800057d2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800057d6:	f9442703          	lw	a4,-108(s0)
    800057da:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800057de:	0712                	slli	a4,a4,0x4
    800057e0:	963a                	add	a2,a2,a4
    800057e2:	058a0593          	addi	a1,s4,88
    800057e6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800057e8:	0007b883          	ld	a7,0(a5)
    800057ec:	9746                	add	a4,a4,a7
    800057ee:	40000613          	li	a2,1024
    800057f2:	c710                	sw	a2,8(a4)
  if(write)
    800057f4:	001bb613          	seqz	a2,s7
    800057f8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800057fc:	00166613          	ori	a2,a2,1
    80005800:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005804:	f9842583          	lw	a1,-104(s0)
    80005808:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000580c:	00250613          	addi	a2,a0,2
    80005810:	0612                	slli	a2,a2,0x4
    80005812:	963e                	add	a2,a2,a5
    80005814:	577d                	li	a4,-1
    80005816:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000581a:	0592                	slli	a1,a1,0x4
    8000581c:	98ae                	add	a7,a7,a1
    8000581e:	03068713          	addi	a4,a3,48
    80005822:	973e                	add	a4,a4,a5
    80005824:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005828:	6398                	ld	a4,0(a5)
    8000582a:	972e                	add	a4,a4,a1
    8000582c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005830:	4689                	li	a3,2
    80005832:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005836:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000583a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000583e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005842:	6794                	ld	a3,8(a5)
    80005844:	0026d703          	lhu	a4,2(a3)
    80005848:	8b1d                	andi	a4,a4,7
    8000584a:	0706                	slli	a4,a4,0x1
    8000584c:	96ba                	add	a3,a3,a4
    8000584e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800058b2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005856:	6798                	ld	a4,8(a5)
    80005858:	00275783          	lhu	a5,2(a4)
    8000585c:	2785                	addiw	a5,a5,1
    8000585e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005862:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005866:	100017b7          	lui	a5,0x10001
    8000586a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000586e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005872:	0001b917          	auipc	s2,0x1b
    80005876:	50e90913          	addi	s2,s2,1294 # 80020d80 <disk+0x128>
  while(b->disk == 1) {
    8000587a:	4485                	li	s1,1
    8000587c:	01079a63          	bne	a5,a6,80005890 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005880:	85ca                	mv	a1,s2
    80005882:	8552                	mv	a0,s4
    80005884:	e5cfc0ef          	jal	80001ee0 <sleep>
  while(b->disk == 1) {
    80005888:	004a2783          	lw	a5,4(s4)
    8000588c:	fe978ae3          	beq	a5,s1,80005880 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005890:	f9042903          	lw	s2,-112(s0)
    80005894:	00290713          	addi	a4,s2,2
    80005898:	0712                	slli	a4,a4,0x4
    8000589a:	0001b797          	auipc	a5,0x1b
    8000589e:	3be78793          	addi	a5,a5,958 # 80020c58 <disk>
    800058a2:	97ba                	add	a5,a5,a4
    800058a4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800058a8:	0001b997          	auipc	s3,0x1b
    800058ac:	3b098993          	addi	s3,s3,944 # 80020c58 <disk>
    800058b0:	00491713          	slli	a4,s2,0x4
    800058b4:	0009b783          	ld	a5,0(s3)
    800058b8:	97ba                	add	a5,a5,a4
    800058ba:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800058be:	854a                	mv	a0,s2
    800058c0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800058c4:	bafff0ef          	jal	80005472 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800058c8:	8885                	andi	s1,s1,1
    800058ca:	f0fd                	bnez	s1,800058b0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800058cc:	0001b517          	auipc	a0,0x1b
    800058d0:	4b450513          	addi	a0,a0,1204 # 80020d80 <disk+0x128>
    800058d4:	b92fb0ef          	jal	80000c66 <release>
}
    800058d8:	70a6                	ld	ra,104(sp)
    800058da:	7406                	ld	s0,96(sp)
    800058dc:	64e6                	ld	s1,88(sp)
    800058de:	6946                	ld	s2,80(sp)
    800058e0:	69a6                	ld	s3,72(sp)
    800058e2:	6a06                	ld	s4,64(sp)
    800058e4:	7ae2                	ld	s5,56(sp)
    800058e6:	7b42                	ld	s6,48(sp)
    800058e8:	7ba2                	ld	s7,40(sp)
    800058ea:	7c02                	ld	s8,32(sp)
    800058ec:	6ce2                	ld	s9,24(sp)
    800058ee:	6165                	addi	sp,sp,112
    800058f0:	8082                	ret

00000000800058f2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800058f2:	1101                	addi	sp,sp,-32
    800058f4:	ec06                	sd	ra,24(sp)
    800058f6:	e822                	sd	s0,16(sp)
    800058f8:	e426                	sd	s1,8(sp)
    800058fa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800058fc:	0001b497          	auipc	s1,0x1b
    80005900:	35c48493          	addi	s1,s1,860 # 80020c58 <disk>
    80005904:	0001b517          	auipc	a0,0x1b
    80005908:	47c50513          	addi	a0,a0,1148 # 80020d80 <disk+0x128>
    8000590c:	ac2fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005910:	100017b7          	lui	a5,0x10001
    80005914:	53b8                	lw	a4,96(a5)
    80005916:	8b0d                	andi	a4,a4,3
    80005918:	100017b7          	lui	a5,0x10001
    8000591c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000591e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005922:	689c                	ld	a5,16(s1)
    80005924:	0204d703          	lhu	a4,32(s1)
    80005928:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000592c:	04f70663          	beq	a4,a5,80005978 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005930:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005934:	6898                	ld	a4,16(s1)
    80005936:	0204d783          	lhu	a5,32(s1)
    8000593a:	8b9d                	andi	a5,a5,7
    8000593c:	078e                	slli	a5,a5,0x3
    8000593e:	97ba                	add	a5,a5,a4
    80005940:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005942:	00278713          	addi	a4,a5,2
    80005946:	0712                	slli	a4,a4,0x4
    80005948:	9726                	add	a4,a4,s1
    8000594a:	01074703          	lbu	a4,16(a4)
    8000594e:	e321                	bnez	a4,8000598e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005950:	0789                	addi	a5,a5,2
    80005952:	0792                	slli	a5,a5,0x4
    80005954:	97a6                	add	a5,a5,s1
    80005956:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005958:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000595c:	dd0fc0ef          	jal	80001f2c <wakeup>

    disk.used_idx += 1;
    80005960:	0204d783          	lhu	a5,32(s1)
    80005964:	2785                	addiw	a5,a5,1
    80005966:	17c2                	slli	a5,a5,0x30
    80005968:	93c1                	srli	a5,a5,0x30
    8000596a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000596e:	6898                	ld	a4,16(s1)
    80005970:	00275703          	lhu	a4,2(a4)
    80005974:	faf71ee3          	bne	a4,a5,80005930 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005978:	0001b517          	auipc	a0,0x1b
    8000597c:	40850513          	addi	a0,a0,1032 # 80020d80 <disk+0x128>
    80005980:	ae6fb0ef          	jal	80000c66 <release>
}
    80005984:	60e2                	ld	ra,24(sp)
    80005986:	6442                	ld	s0,16(sp)
    80005988:	64a2                	ld	s1,8(sp)
    8000598a:	6105                	addi	sp,sp,32
    8000598c:	8082                	ret
      panic("virtio_disk_intr status");
    8000598e:	00002517          	auipc	a0,0x2
    80005992:	d8a50513          	addi	a0,a0,-630 # 80007718 <etext+0x718>
    80005996:	e4bfa0ef          	jal	800007e0 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
