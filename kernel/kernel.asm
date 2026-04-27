
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
    80000004:	89010113          	addi	sp,sp,-1904 # 80007890 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd867>
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
    80000112:	18c020ef          	jal	8000229e <either_copyin>
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
    80000190:	70450513          	addi	a0,a0,1796 # 8000f890 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	0000f497          	auipc	s1,0xf
    8000019c:	6f848493          	addi	s1,s1,1784 # 8000f890 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	0000f917          	auipc	s2,0xf
    800001a4:	78890913          	addi	s2,s2,1928 # 8000f928 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	716010ef          	jal	800018ce <myproc>
    800001bc:	775010ef          	jal	80002130 <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	533010ef          	jal	80001ef8 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	0000f717          	auipc	a4,0xf
    800001dc:	6b870713          	addi	a4,a4,1720 # 8000f890 <cons>
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
    8000020a:	04a020ef          	jal	80002254 <either_copyout>
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
    80000226:	66e50513          	addi	a0,a0,1646 # 8000f890 <cons>
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
    80000250:	6cf72e23          	sw	a5,1756(a4) # 8000f928 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	0000f517          	auipc	a0,0xf
    80000266:	62e50513          	addi	a0,a0,1582 # 8000f890 <cons>
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
    800002ba:	5da50513          	addi	a0,a0,1498 # 8000f890 <cons>
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
    800002d8:	010020ef          	jal	800022e8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	0000f517          	auipc	a0,0xf
    800002e0:	5b450513          	addi	a0,a0,1460 # 8000f890 <cons>
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
    800002fe:	59670713          	addi	a4,a4,1430 # 8000f890 <cons>
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
    80000324:	57078793          	addi	a5,a5,1392 # 8000f890 <cons>
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
    80000352:	5da7a783          	lw	a5,1498(a5) # 8000f928 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	0000f717          	auipc	a4,0xf
    80000368:	52c70713          	addi	a4,a4,1324 # 8000f890 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	0000f497          	auipc	s1,0xf
    80000378:	51c48493          	addi	s1,s1,1308 # 8000f890 <cons>
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
    800003ba:	4da70713          	addi	a4,a4,1242 # 8000f890 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	0000f717          	auipc	a4,0xf
    800003d0:	56f72223          	sw	a5,1380(a4) # 8000f930 <cons+0xa0>
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
    800003ee:	4a678793          	addi	a5,a5,1190 # 8000f890 <cons>
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
    80000412:	50c7af23          	sw	a2,1310(a5) # 8000f92c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	0000f517          	auipc	a0,0xf
    8000041a:	51250513          	addi	a0,a0,1298 # 8000f928 <cons+0x98>
    8000041e:	327010ef          	jal	80001f44 <wakeup>
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
    80000438:	45c50513          	addi	a0,a0,1116 # 8000f890 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00020797          	auipc	a5,0x20
    80000448:	9bc78793          	addi	a5,a5,-1604 # 8001fe00 <devsw>
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
    80000482:	29a60613          	addi	a2,a2,666 # 80007718 <digits>
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
    8000051c:	34c7a783          	lw	a5,844(a5) # 80007864 <panicking>
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
    80000564:	3d850513          	addi	a0,a0,984 # 8000f938 <pr>
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
    8000072c:	ff0b8b93          	addi	s7,s7,-16 # 80007718 <digits>
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
    800007c0:	0a87a783          	lw	a5,168(a5) # 80007864 <panicking>
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
    800007d6:	16650513          	addi	a0,a0,358 # 8000f938 <pr>
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
    800007f4:	0727aa23          	sw	s2,116(a5) # 80007864 <panicking>
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
    80000816:	0527a723          	sw	s2,78(a5) # 80007860 <panicked>
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
    80000830:	10c50513          	addi	a0,a0,268 # 8000f938 <pr>
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
    80000888:	0cc50513          	addi	a0,a0,204 # 8000f950 <tx_lock>
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
    800008ac:	0a850513          	addi	a0,a0,168 # 8000f950 <tx_lock>
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
    800008ca:	fa648493          	addi	s1,s1,-90 # 8000786c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	0000f997          	auipc	s3,0xf
    800008d2:	08298993          	addi	s3,s3,130 # 8000f950 <tx_lock>
    800008d6:	00007917          	auipc	s2,0x7
    800008da:	f9290913          	addi	s2,s2,-110 # 80007868 <tx_chan>
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
    800008ea:	60e010ef          	jal	80001ef8 <sleep>
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
    80000918:	03c50513          	addi	a0,a0,60 # 8000f950 <tx_lock>
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
    8000093c:	f2c7a783          	lw	a5,-212(a5) # 80007864 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	00007797          	auipc	a5,0x7
    80000946:	f1e7a783          	lw	a5,-226(a5) # 80007860 <panicked>
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
    8000096c:	efc7a783          	lw	a5,-260(a5) # 80007864 <panicking>
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
    800009c8:	f8c50513          	addi	a0,a0,-116 # 8000f950 <tx_lock>
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
    800009e4:	f7050513          	addi	a0,a0,-144 # 8000f950 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00007797          	auipc	a5,0x7
    800009f4:	e607ae23          	sw	zero,-388(a5) # 8000786c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00007517          	auipc	a0,0x7
    800009fc:	e7050513          	addi	a0,a0,-400 # 80007868 <tx_chan>
    80000a00:	544010ef          	jal	80001f44 <wakeup>
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
    80000a34:	56878793          	addi	a5,a5,1384 # 80020f98 <end>
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
    80000a50:	f1c90913          	addi	s2,s2,-228 # 8000f968 <kmem>
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
    80000ade:	e8e50513          	addi	a0,a0,-370 # 8000f968 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00020517          	auipc	a0,0x20
    80000aee:	4ae50513          	addi	a0,a0,1198 # 80020f98 <end>
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
    80000b0c:	e6048493          	addi	s1,s1,-416 # 8000f968 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	0000f517          	auipc	a0,0xf
    80000b20:	e4c50513          	addi	a0,a0,-436 # 8000f968 <kmem>
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
    80000b44:	e2850513          	addi	a0,a0,-472 # 8000f968 <kmem>
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
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde069>
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
    80000e4c:	a2870713          	addi	a4,a4,-1496 # 80007870 <started>
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
    80000e72:	5a8010ef          	jal	8000241a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	612040ef          	jal	80005488 <plicinithart>
  }

  scheduler();        
    80000e7a:	6e7000ef          	jal	80001d60 <scheduler>
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
    80000eba:	53c010ef          	jal	800023f6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	55c010ef          	jal	8000241a <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	5ac040ef          	jal	8000546e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	5c2040ef          	jal	80005488 <plicinithart>
    binit();         // buffer cache
    80000eca:	48d010ef          	jal	80002b56 <binit>
    iinit();         // inode table
    80000ece:	212020ef          	jal	800030e0 <iinit>
    fileinit();      // file table
    80000ed2:	104030ef          	jal	80003fd6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	6a2040ef          	jal	80005578 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	4c7000ef          	jal	80001ba0 <userinit>
    __sync_synchronize();
    80000ede:	0ff0000f          	fence
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	00007717          	auipc	a4,0x7
    80000ee8:	98f72623          	sw	a5,-1652(a4) # 80007870 <started>
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
    80000efc:	9807b783          	ld	a5,-1664(a5) # 80007878 <kernel_pagetable>
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
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde05f>
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
    80001188:	6ea7ba23          	sd	a0,1780(a5) # 80007878 <kernel_pagetable>
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
    8000176e:	64e48493          	addi	s1,s1,1614 # 8000fdb8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001772:	8b26                	mv	s6,s1
    80001774:	00a36937          	lui	s2,0xa36
    80001778:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    8000177c:	0932                	slli	s2,s2,0xc
    8000177e:	46d90913          	addi	s2,s2,1133
    80001782:	0936                	slli	s2,s2,0xd
    80001784:	df590913          	addi	s2,s2,-523
    80001788:	093a                	slli	s2,s2,0xe
    8000178a:	6cf90913          	addi	s2,s2,1743
    8000178e:	040009b7          	lui	s3,0x4000
    80001792:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001794:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001796:	00014a97          	auipc	s5,0x14
    8000179a:	422a8a93          	addi	s5,s5,1058 # 80015bb8 <tickslock>
    char *pa = kalloc();
    8000179e:	b60ff0ef          	jal	80000afe <kalloc>
    800017a2:	862a                	mv	a2,a0
    if(pa == 0)
    800017a4:	cd15                	beqz	a0,800017e0 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017a6:	416485b3          	sub	a1,s1,s6
    800017aa:	858d                	srai	a1,a1,0x3
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
    800017c4:	17848493          	addi	s1,s1,376
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
    8000180c:	18050513          	addi	a0,a0,384 # 8000f988 <pid_lock>
    80001810:	b3eff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001814:	00006597          	auipc	a1,0x6
    80001818:	95458593          	addi	a1,a1,-1708 # 80007168 <etext+0x168>
    8000181c:	0000e517          	auipc	a0,0xe
    80001820:	18450513          	addi	a0,a0,388 # 8000f9a0 <wait_lock>
    80001824:	b2aff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001828:	0000e497          	auipc	s1,0xe
    8000182c:	59048493          	addi	s1,s1,1424 # 8000fdb8 <proc>
      initlock(&p->lock, "proc");
    80001830:	00006b17          	auipc	s6,0x6
    80001834:	948b0b13          	addi	s6,s6,-1720 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001838:	8aa6                	mv	s5,s1
    8000183a:	00a36937          	lui	s2,0xa36
    8000183e:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    80001842:	0932                	slli	s2,s2,0xc
    80001844:	46d90913          	addi	s2,s2,1133
    80001848:	0936                	slli	s2,s2,0xd
    8000184a:	df590913          	addi	s2,s2,-523
    8000184e:	093a                	slli	s2,s2,0xe
    80001850:	6cf90913          	addi	s2,s2,1743
    80001854:	040009b7          	lui	s3,0x4000
    80001858:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000185a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	00014a17          	auipc	s4,0x14
    80001860:	35ca0a13          	addi	s4,s4,860 # 80015bb8 <tickslock>
      initlock(&p->lock, "proc");
    80001864:	85da                	mv	a1,s6
    80001866:	8526                	mv	a0,s1
    80001868:	ae6ff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    8000186c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001870:	415487b3          	sub	a5,s1,s5
    80001874:	878d                	srai	a5,a5,0x3
    80001876:	032787b3          	mul	a5,a5,s2
    8000187a:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffde069>
    8000187c:	00d7979b          	slliw	a5,a5,0xd
    80001880:	40f987b3          	sub	a5,s3,a5
    80001884:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001886:	17848493          	addi	s1,s1,376
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
    800018c2:	0fa50513          	addi	a0,a0,250 # 8000f9b8 <cpus>
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
    800018e6:	0a670713          	addi	a4,a4,166 # 8000f988 <pid_lock>
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
    80001916:	f3e7a783          	lw	a5,-194(a5) # 80007850 <first.1>
    8000191a:	cf8d                	beqz	a5,80001954 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000191c:	4505                	li	a0,1
    8000191e:	47f010ef          	jal	8000359c <fsinit>

    first = 0;
    80001922:	00006797          	auipc	a5,0x6
    80001926:	f207a723          	sw	zero,-210(a5) # 80007850 <first.1>
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
    80001942:	565020ef          	jal	800046a6 <kexec>
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
    80001954:	2df000ef          	jal	80002432 <prepare_return>
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
    800019a6:	fe690913          	addi	s2,s2,-26 # 8000f988 <pid_lock>
    800019aa:	854a                	mv	a0,s2
    800019ac:	a22ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    800019b0:	00006797          	auipc	a5,0x6
    800019b4:	ea478793          	addi	a5,a5,-348 # 80007854 <nextpid>
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
    80001b0a:	0b290913          	addi	s2,s2,178 # 80015bb8 <tickslock>
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
    80001b1e:	17848493          	addi	s1,s1,376
    80001b22:	ff2496e3          	bne	s1,s2,80001b0e <allocproc+0x1c>
  return 0;
    80001b26:	4481                	li	s1,0
    80001b28:	a0a9                	j	80001b72 <allocproc+0x80>
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
    80001b40:	c121                	beqz	a0,80001b80 <allocproc+0x8e>
  p->pagetable = proc_pagetable(p);
    80001b42:	8526                	mv	a0,s1
    80001b44:	e91ff0ef          	jal	800019d4 <proc_pagetable>
    80001b48:	892a                	mv	s2,a0
    80001b4a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b4c:	c131                	beqz	a0,80001b90 <allocproc+0x9e>
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
  p->syscall_mask = 0; // Đặt khiên mặc định về 0
    80001b6e:	1404bc23          	sd	zero,344(s1)
}
    80001b72:	8526                	mv	a0,s1
    80001b74:	60e2                	ld	ra,24(sp)
    80001b76:	6442                	ld	s0,16(sp)
    80001b78:	64a2                	ld	s1,8(sp)
    80001b7a:	6902                	ld	s2,0(sp)
    80001b7c:	6105                	addi	sp,sp,32
    80001b7e:	8082                	ret
    freeproc(p);
    80001b80:	8526                	mv	a0,s1
    80001b82:	f1dff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b86:	8526                	mv	a0,s1
    80001b88:	8deff0ef          	jal	80000c66 <release>
    return 0;
    80001b8c:	84ca                	mv	s1,s2
    80001b8e:	b7d5                	j	80001b72 <allocproc+0x80>
    freeproc(p);
    80001b90:	8526                	mv	a0,s1
    80001b92:	f0dff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b96:	8526                	mv	a0,s1
    80001b98:	8ceff0ef          	jal	80000c66 <release>
    return 0;
    80001b9c:	84ca                	mv	s1,s2
    80001b9e:	bfd1                	j	80001b72 <allocproc+0x80>

0000000080001ba0 <userinit>:
{
    80001ba0:	1101                	addi	sp,sp,-32
    80001ba2:	ec06                	sd	ra,24(sp)
    80001ba4:	e822                	sd	s0,16(sp)
    80001ba6:	e426                	sd	s1,8(sp)
    80001ba8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001baa:	f49ff0ef          	jal	80001af2 <allocproc>
    80001bae:	84aa                	mv	s1,a0
  initproc = p;
    80001bb0:	00006797          	auipc	a5,0x6
    80001bb4:	cca7b823          	sd	a0,-816(a5) # 80007880 <initproc>
  p->cwd = namei("/");
    80001bb8:	00005517          	auipc	a0,0x5
    80001bbc:	5d850513          	addi	a0,a0,1496 # 80007190 <etext+0x190>
    80001bc0:	6ff010ef          	jal	80003abe <namei>
    80001bc4:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bc8:	478d                	li	a5,3
    80001bca:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bcc:	8526                	mv	a0,s1
    80001bce:	898ff0ef          	jal	80000c66 <release>
}
    80001bd2:	60e2                	ld	ra,24(sp)
    80001bd4:	6442                	ld	s0,16(sp)
    80001bd6:	64a2                	ld	s1,8(sp)
    80001bd8:	6105                	addi	sp,sp,32
    80001bda:	8082                	ret

0000000080001bdc <growproc>:
{
    80001bdc:	1101                	addi	sp,sp,-32
    80001bde:	ec06                	sd	ra,24(sp)
    80001be0:	e822                	sd	s0,16(sp)
    80001be2:	e426                	sd	s1,8(sp)
    80001be4:	e04a                	sd	s2,0(sp)
    80001be6:	1000                	addi	s0,sp,32
    80001be8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bea:	ce5ff0ef          	jal	800018ce <myproc>
    80001bee:	892a                	mv	s2,a0
  sz = p->sz;
    80001bf0:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bf2:	02905963          	blez	s1,80001c24 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001bf6:	00b48633          	add	a2,s1,a1
    80001bfa:	020007b7          	lui	a5,0x2000
    80001bfe:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c00:	07b6                	slli	a5,a5,0xd
    80001c02:	02c7ea63          	bltu	a5,a2,80001c36 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c06:	4691                	li	a3,4
    80001c08:	6928                	ld	a0,80(a0)
    80001c0a:	e7eff0ef          	jal	80001288 <uvmalloc>
    80001c0e:	85aa                	mv	a1,a0
    80001c10:	c50d                	beqz	a0,80001c3a <growproc+0x5e>
  p->sz = sz;
    80001c12:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c16:	4501                	li	a0,0
}
    80001c18:	60e2                	ld	ra,24(sp)
    80001c1a:	6442                	ld	s0,16(sp)
    80001c1c:	64a2                	ld	s1,8(sp)
    80001c1e:	6902                	ld	s2,0(sp)
    80001c20:	6105                	addi	sp,sp,32
    80001c22:	8082                	ret
  } else if(n < 0){
    80001c24:	fe04d7e3          	bgez	s1,80001c12 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c28:	00b48633          	add	a2,s1,a1
    80001c2c:	6928                	ld	a0,80(a0)
    80001c2e:	e16ff0ef          	jal	80001244 <uvmdealloc>
    80001c32:	85aa                	mv	a1,a0
    80001c34:	bff9                	j	80001c12 <growproc+0x36>
      return -1;
    80001c36:	557d                	li	a0,-1
    80001c38:	b7c5                	j	80001c18 <growproc+0x3c>
      return -1;
    80001c3a:	557d                	li	a0,-1
    80001c3c:	bff1                	j	80001c18 <growproc+0x3c>

0000000080001c3e <kfork>:
{
    80001c3e:	7139                	addi	sp,sp,-64
    80001c40:	fc06                	sd	ra,56(sp)
    80001c42:	f822                	sd	s0,48(sp)
    80001c44:	f04a                	sd	s2,32(sp)
    80001c46:	e456                	sd	s5,8(sp)
    80001c48:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c4a:	c85ff0ef          	jal	800018ce <myproc>
    80001c4e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c50:	ea3ff0ef          	jal	80001af2 <allocproc>
    80001c54:	10050463          	beqz	a0,80001d5c <kfork+0x11e>
    80001c58:	ec4e                	sd	s3,24(sp)
    80001c5a:	89aa                	mv	s3,a0
  if (p->child_syscall_mask != 0) {
    80001c5c:	170ab783          	ld	a5,368(s5)
    80001c60:	e399                	bnez	a5,80001c66 <kfork+0x28>
    np->syscall_mask = p->syscall_mask;
    80001c62:	158ab783          	ld	a5,344(s5)
    80001c66:	14f9bc23          	sd	a5,344(s3)
  p->child_syscall_mask = 0;
    80001c6a:	160ab823          	sd	zero,368(s5)
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c6e:	048ab603          	ld	a2,72(s5)
    80001c72:	0509b583          	ld	a1,80(s3)
    80001c76:	050ab503          	ld	a0,80(s5)
    80001c7a:	f46ff0ef          	jal	800013c0 <uvmcopy>
    80001c7e:	04054a63          	bltz	a0,80001cd2 <kfork+0x94>
    80001c82:	f426                	sd	s1,40(sp)
    80001c84:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001c86:	048ab783          	ld	a5,72(s5)
    80001c8a:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001c8e:	058ab683          	ld	a3,88(s5)
    80001c92:	87b6                	mv	a5,a3
    80001c94:	0589b703          	ld	a4,88(s3)
    80001c98:	12068693          	addi	a3,a3,288
    80001c9c:	0007b803          	ld	a6,0(a5)
    80001ca0:	6788                	ld	a0,8(a5)
    80001ca2:	6b8c                	ld	a1,16(a5)
    80001ca4:	6f90                	ld	a2,24(a5)
    80001ca6:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001caa:	e708                	sd	a0,8(a4)
    80001cac:	eb0c                	sd	a1,16(a4)
    80001cae:	ef10                	sd	a2,24(a4)
    80001cb0:	02078793          	addi	a5,a5,32
    80001cb4:	02070713          	addi	a4,a4,32
    80001cb8:	fed792e3          	bne	a5,a3,80001c9c <kfork+0x5e>
  np->trapframe->a0 = 0;
    80001cbc:	0589b783          	ld	a5,88(s3)
    80001cc0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001cc4:	0d0a8493          	addi	s1,s5,208
    80001cc8:	0d098913          	addi	s2,s3,208
    80001ccc:	150a8a13          	addi	s4,s5,336
    80001cd0:	a015                	j	80001cf4 <kfork+0xb6>
    freeproc(np);
    80001cd2:	854e                	mv	a0,s3
    80001cd4:	dcbff0ef          	jal	80001a9e <freeproc>
    release(&np->lock);
    80001cd8:	854e                	mv	a0,s3
    80001cda:	f8dfe0ef          	jal	80000c66 <release>
    return -1;
    80001cde:	597d                	li	s2,-1
    80001ce0:	69e2                	ld	s3,24(sp)
    80001ce2:	a0b5                	j	80001d4e <kfork+0x110>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ce4:	374020ef          	jal	80004058 <filedup>
    80001ce8:	00a93023          	sd	a0,0(s2)
  for(i = 0; i < NOFILE; i++)
    80001cec:	04a1                	addi	s1,s1,8
    80001cee:	0921                	addi	s2,s2,8
    80001cf0:	01448563          	beq	s1,s4,80001cfa <kfork+0xbc>
    if(p->ofile[i])
    80001cf4:	6088                	ld	a0,0(s1)
    80001cf6:	f57d                	bnez	a0,80001ce4 <kfork+0xa6>
    80001cf8:	bfd5                	j	80001cec <kfork+0xae>
  np->cwd = idup(p->cwd);
    80001cfa:	150ab503          	ld	a0,336(s5)
    80001cfe:	574010ef          	jal	80003272 <idup>
    80001d02:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d06:	4641                	li	a2,16
    80001d08:	160a8593          	addi	a1,s5,352
    80001d0c:	16098513          	addi	a0,s3,352
    80001d10:	8d0ff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001d14:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001d18:	854e                	mv	a0,s3
    80001d1a:	f4dfe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001d1e:	0000e497          	auipc	s1,0xe
    80001d22:	c8248493          	addi	s1,s1,-894 # 8000f9a0 <wait_lock>
    80001d26:	8526                	mv	a0,s1
    80001d28:	ea7fe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001d2c:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001d30:	8526                	mv	a0,s1
    80001d32:	f35fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001d36:	854e                	mv	a0,s3
    80001d38:	e97fe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001d3c:	478d                	li	a5,3
    80001d3e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d42:	854e                	mv	a0,s3
    80001d44:	f23fe0ef          	jal	80000c66 <release>
  return pid;
    80001d48:	74a2                	ld	s1,40(sp)
    80001d4a:	69e2                	ld	s3,24(sp)
    80001d4c:	6a42                	ld	s4,16(sp)
}
    80001d4e:	854a                	mv	a0,s2
    80001d50:	70e2                	ld	ra,56(sp)
    80001d52:	7442                	ld	s0,48(sp)
    80001d54:	7902                	ld	s2,32(sp)
    80001d56:	6aa2                	ld	s5,8(sp)
    80001d58:	6121                	addi	sp,sp,64
    80001d5a:	8082                	ret
    return -1;
    80001d5c:	597d                	li	s2,-1
    80001d5e:	bfc5                	j	80001d4e <kfork+0x110>

0000000080001d60 <scheduler>:
{
    80001d60:	715d                	addi	sp,sp,-80
    80001d62:	e486                	sd	ra,72(sp)
    80001d64:	e0a2                	sd	s0,64(sp)
    80001d66:	fc26                	sd	s1,56(sp)
    80001d68:	f84a                	sd	s2,48(sp)
    80001d6a:	f44e                	sd	s3,40(sp)
    80001d6c:	f052                	sd	s4,32(sp)
    80001d6e:	ec56                	sd	s5,24(sp)
    80001d70:	e85a                	sd	s6,16(sp)
    80001d72:	e45e                	sd	s7,8(sp)
    80001d74:	e062                	sd	s8,0(sp)
    80001d76:	0880                	addi	s0,sp,80
    80001d78:	8792                	mv	a5,tp
  int id = r_tp();
    80001d7a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d7c:	00779b13          	slli	s6,a5,0x7
    80001d80:	0000e717          	auipc	a4,0xe
    80001d84:	c0870713          	addi	a4,a4,-1016 # 8000f988 <pid_lock>
    80001d88:	975a                	add	a4,a4,s6
    80001d8a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d8e:	0000e717          	auipc	a4,0xe
    80001d92:	c3270713          	addi	a4,a4,-974 # 8000f9c0 <cpus+0x8>
    80001d96:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d98:	4c11                	li	s8,4
        c->proc = p;
    80001d9a:	079e                	slli	a5,a5,0x7
    80001d9c:	0000ea17          	auipc	s4,0xe
    80001da0:	beca0a13          	addi	s4,s4,-1044 # 8000f988 <pid_lock>
    80001da4:	9a3e                	add	s4,s4,a5
        found = 1;
    80001da6:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001da8:	00014997          	auipc	s3,0x14
    80001dac:	e1098993          	addi	s3,s3,-496 # 80015bb8 <tickslock>
    80001db0:	a83d                	j	80001dee <scheduler+0x8e>
      release(&p->lock);
    80001db2:	8526                	mv	a0,s1
    80001db4:	eb3fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001db8:	17848493          	addi	s1,s1,376
    80001dbc:	03348563          	beq	s1,s3,80001de6 <scheduler+0x86>
      acquire(&p->lock);
    80001dc0:	8526                	mv	a0,s1
    80001dc2:	e0dfe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001dc6:	4c9c                	lw	a5,24(s1)
    80001dc8:	ff2795e3          	bne	a5,s2,80001db2 <scheduler+0x52>
        p->state = RUNNING;
    80001dcc:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001dd0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001dd4:	06048593          	addi	a1,s1,96
    80001dd8:	855a                	mv	a0,s6
    80001dda:	5b2000ef          	jal	8000238c <swtch>
        c->proc = 0;
    80001dde:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001de2:	8ade                	mv	s5,s7
    80001de4:	b7f9                	j	80001db2 <scheduler+0x52>
    if(found == 0) {
    80001de6:	000a9463          	bnez	s5,80001dee <scheduler+0x8e>
      asm volatile("wfi");
    80001dea:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001df2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001df6:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001dfe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e00:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e04:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e06:	0000e497          	auipc	s1,0xe
    80001e0a:	fb248493          	addi	s1,s1,-78 # 8000fdb8 <proc>
      if(p->state == RUNNABLE) {
    80001e0e:	490d                	li	s2,3
    80001e10:	bf45                	j	80001dc0 <scheduler+0x60>

0000000080001e12 <sched>:
{
    80001e12:	7179                	addi	sp,sp,-48
    80001e14:	f406                	sd	ra,40(sp)
    80001e16:	f022                	sd	s0,32(sp)
    80001e18:	ec26                	sd	s1,24(sp)
    80001e1a:	e84a                	sd	s2,16(sp)
    80001e1c:	e44e                	sd	s3,8(sp)
    80001e1e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e20:	aafff0ef          	jal	800018ce <myproc>
    80001e24:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e26:	d3ffe0ef          	jal	80000b64 <holding>
    80001e2a:	c92d                	beqz	a0,80001e9c <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e2c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e2e:	2781                	sext.w	a5,a5
    80001e30:	079e                	slli	a5,a5,0x7
    80001e32:	0000e717          	auipc	a4,0xe
    80001e36:	b5670713          	addi	a4,a4,-1194 # 8000f988 <pid_lock>
    80001e3a:	97ba                	add	a5,a5,a4
    80001e3c:	0a87a703          	lw	a4,168(a5)
    80001e40:	4785                	li	a5,1
    80001e42:	06f71363          	bne	a4,a5,80001ea8 <sched+0x96>
  if(p->state == RUNNING)
    80001e46:	4c98                	lw	a4,24(s1)
    80001e48:	4791                	li	a5,4
    80001e4a:	06f70563          	beq	a4,a5,80001eb4 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e54:	e7b5                	bnez	a5,80001ec0 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e56:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e58:	0000e917          	auipc	s2,0xe
    80001e5c:	b3090913          	addi	s2,s2,-1232 # 8000f988 <pid_lock>
    80001e60:	2781                	sext.w	a5,a5
    80001e62:	079e                	slli	a5,a5,0x7
    80001e64:	97ca                	add	a5,a5,s2
    80001e66:	0ac7a983          	lw	s3,172(a5)
    80001e6a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e6c:	2781                	sext.w	a5,a5
    80001e6e:	079e                	slli	a5,a5,0x7
    80001e70:	0000e597          	auipc	a1,0xe
    80001e74:	b5058593          	addi	a1,a1,-1200 # 8000f9c0 <cpus+0x8>
    80001e78:	95be                	add	a1,a1,a5
    80001e7a:	06048513          	addi	a0,s1,96
    80001e7e:	50e000ef          	jal	8000238c <swtch>
    80001e82:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e84:	2781                	sext.w	a5,a5
    80001e86:	079e                	slli	a5,a5,0x7
    80001e88:	993e                	add	s2,s2,a5
    80001e8a:	0b392623          	sw	s3,172(s2)
}
    80001e8e:	70a2                	ld	ra,40(sp)
    80001e90:	7402                	ld	s0,32(sp)
    80001e92:	64e2                	ld	s1,24(sp)
    80001e94:	6942                	ld	s2,16(sp)
    80001e96:	69a2                	ld	s3,8(sp)
    80001e98:	6145                	addi	sp,sp,48
    80001e9a:	8082                	ret
    panic("sched p->lock");
    80001e9c:	00005517          	auipc	a0,0x5
    80001ea0:	2fc50513          	addi	a0,a0,764 # 80007198 <etext+0x198>
    80001ea4:	93dfe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80001ea8:	00005517          	auipc	a0,0x5
    80001eac:	30050513          	addi	a0,a0,768 # 800071a8 <etext+0x1a8>
    80001eb0:	931fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80001eb4:	00005517          	auipc	a0,0x5
    80001eb8:	30450513          	addi	a0,a0,772 # 800071b8 <etext+0x1b8>
    80001ebc:	925fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80001ec0:	00005517          	auipc	a0,0x5
    80001ec4:	30850513          	addi	a0,a0,776 # 800071c8 <etext+0x1c8>
    80001ec8:	919fe0ef          	jal	800007e0 <panic>

0000000080001ecc <yield>:
{
    80001ecc:	1101                	addi	sp,sp,-32
    80001ece:	ec06                	sd	ra,24(sp)
    80001ed0:	e822                	sd	s0,16(sp)
    80001ed2:	e426                	sd	s1,8(sp)
    80001ed4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ed6:	9f9ff0ef          	jal	800018ce <myproc>
    80001eda:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001edc:	cf3fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    80001ee0:	478d                	li	a5,3
    80001ee2:	cc9c                	sw	a5,24(s1)
  sched();
    80001ee4:	f2fff0ef          	jal	80001e12 <sched>
  release(&p->lock);
    80001ee8:	8526                	mv	a0,s1
    80001eea:	d7dfe0ef          	jal	80000c66 <release>
}
    80001eee:	60e2                	ld	ra,24(sp)
    80001ef0:	6442                	ld	s0,16(sp)
    80001ef2:	64a2                	ld	s1,8(sp)
    80001ef4:	6105                	addi	sp,sp,32
    80001ef6:	8082                	ret

0000000080001ef8 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ef8:	7179                	addi	sp,sp,-48
    80001efa:	f406                	sd	ra,40(sp)
    80001efc:	f022                	sd	s0,32(sp)
    80001efe:	ec26                	sd	s1,24(sp)
    80001f00:	e84a                	sd	s2,16(sp)
    80001f02:	e44e                	sd	s3,8(sp)
    80001f04:	1800                	addi	s0,sp,48
    80001f06:	89aa                	mv	s3,a0
    80001f08:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f0a:	9c5ff0ef          	jal	800018ce <myproc>
    80001f0e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f10:	cbffe0ef          	jal	80000bce <acquire>
  release(lk);
    80001f14:	854a                	mv	a0,s2
    80001f16:	d51fe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80001f1a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f1e:	4789                	li	a5,2
    80001f20:	cc9c                	sw	a5,24(s1)

  sched();
    80001f22:	ef1ff0ef          	jal	80001e12 <sched>

  // Tidy up.
  p->chan = 0;
    80001f26:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f2a:	8526                	mv	a0,s1
    80001f2c:	d3bfe0ef          	jal	80000c66 <release>
  acquire(lk);
    80001f30:	854a                	mv	a0,s2
    80001f32:	c9dfe0ef          	jal	80000bce <acquire>
}
    80001f36:	70a2                	ld	ra,40(sp)
    80001f38:	7402                	ld	s0,32(sp)
    80001f3a:	64e2                	ld	s1,24(sp)
    80001f3c:	6942                	ld	s2,16(sp)
    80001f3e:	69a2                	ld	s3,8(sp)
    80001f40:	6145                	addi	sp,sp,48
    80001f42:	8082                	ret

0000000080001f44 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f44:	7139                	addi	sp,sp,-64
    80001f46:	fc06                	sd	ra,56(sp)
    80001f48:	f822                	sd	s0,48(sp)
    80001f4a:	f426                	sd	s1,40(sp)
    80001f4c:	f04a                	sd	s2,32(sp)
    80001f4e:	ec4e                	sd	s3,24(sp)
    80001f50:	e852                	sd	s4,16(sp)
    80001f52:	e456                	sd	s5,8(sp)
    80001f54:	0080                	addi	s0,sp,64
    80001f56:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f58:	0000e497          	auipc	s1,0xe
    80001f5c:	e6048493          	addi	s1,s1,-416 # 8000fdb8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f60:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f62:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f64:	00014917          	auipc	s2,0x14
    80001f68:	c5490913          	addi	s2,s2,-940 # 80015bb8 <tickslock>
    80001f6c:	a801                	j	80001f7c <wakeup+0x38>
      }
      release(&p->lock);
    80001f6e:	8526                	mv	a0,s1
    80001f70:	cf7fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f74:	17848493          	addi	s1,s1,376
    80001f78:	03248263          	beq	s1,s2,80001f9c <wakeup+0x58>
    if(p != myproc()){
    80001f7c:	953ff0ef          	jal	800018ce <myproc>
    80001f80:	fea48ae3          	beq	s1,a0,80001f74 <wakeup+0x30>
      acquire(&p->lock);
    80001f84:	8526                	mv	a0,s1
    80001f86:	c49fe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f8a:	4c9c                	lw	a5,24(s1)
    80001f8c:	ff3791e3          	bne	a5,s3,80001f6e <wakeup+0x2a>
    80001f90:	709c                	ld	a5,32(s1)
    80001f92:	fd479ee3          	bne	a5,s4,80001f6e <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f96:	0154ac23          	sw	s5,24(s1)
    80001f9a:	bfd1                	j	80001f6e <wakeup+0x2a>
    }
  }
}
    80001f9c:	70e2                	ld	ra,56(sp)
    80001f9e:	7442                	ld	s0,48(sp)
    80001fa0:	74a2                	ld	s1,40(sp)
    80001fa2:	7902                	ld	s2,32(sp)
    80001fa4:	69e2                	ld	s3,24(sp)
    80001fa6:	6a42                	ld	s4,16(sp)
    80001fa8:	6aa2                	ld	s5,8(sp)
    80001faa:	6121                	addi	sp,sp,64
    80001fac:	8082                	ret

0000000080001fae <reparent>:
{
    80001fae:	7179                	addi	sp,sp,-48
    80001fb0:	f406                	sd	ra,40(sp)
    80001fb2:	f022                	sd	s0,32(sp)
    80001fb4:	ec26                	sd	s1,24(sp)
    80001fb6:	e84a                	sd	s2,16(sp)
    80001fb8:	e44e                	sd	s3,8(sp)
    80001fba:	e052                	sd	s4,0(sp)
    80001fbc:	1800                	addi	s0,sp,48
    80001fbe:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fc0:	0000e497          	auipc	s1,0xe
    80001fc4:	df848493          	addi	s1,s1,-520 # 8000fdb8 <proc>
      pp->parent = initproc;
    80001fc8:	00006a17          	auipc	s4,0x6
    80001fcc:	8b8a0a13          	addi	s4,s4,-1864 # 80007880 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fd0:	00014997          	auipc	s3,0x14
    80001fd4:	be898993          	addi	s3,s3,-1048 # 80015bb8 <tickslock>
    80001fd8:	a029                	j	80001fe2 <reparent+0x34>
    80001fda:	17848493          	addi	s1,s1,376
    80001fde:	01348b63          	beq	s1,s3,80001ff4 <reparent+0x46>
    if(pp->parent == p){
    80001fe2:	7c9c                	ld	a5,56(s1)
    80001fe4:	ff279be3          	bne	a5,s2,80001fda <reparent+0x2c>
      pp->parent = initproc;
    80001fe8:	000a3503          	ld	a0,0(s4)
    80001fec:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fee:	f57ff0ef          	jal	80001f44 <wakeup>
    80001ff2:	b7e5                	j	80001fda <reparent+0x2c>
}
    80001ff4:	70a2                	ld	ra,40(sp)
    80001ff6:	7402                	ld	s0,32(sp)
    80001ff8:	64e2                	ld	s1,24(sp)
    80001ffa:	6942                	ld	s2,16(sp)
    80001ffc:	69a2                	ld	s3,8(sp)
    80001ffe:	6a02                	ld	s4,0(sp)
    80002000:	6145                	addi	sp,sp,48
    80002002:	8082                	ret

0000000080002004 <kexit>:
{
    80002004:	7179                	addi	sp,sp,-48
    80002006:	f406                	sd	ra,40(sp)
    80002008:	f022                	sd	s0,32(sp)
    8000200a:	ec26                	sd	s1,24(sp)
    8000200c:	e84a                	sd	s2,16(sp)
    8000200e:	e44e                	sd	s3,8(sp)
    80002010:	e052                	sd	s4,0(sp)
    80002012:	1800                	addi	s0,sp,48
    80002014:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002016:	8b9ff0ef          	jal	800018ce <myproc>
    8000201a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000201c:	00006797          	auipc	a5,0x6
    80002020:	8647b783          	ld	a5,-1948(a5) # 80007880 <initproc>
    80002024:	0d050493          	addi	s1,a0,208
    80002028:	15050913          	addi	s2,a0,336
    8000202c:	00a79f63          	bne	a5,a0,8000204a <kexit+0x46>
    panic("init exiting");
    80002030:	00005517          	auipc	a0,0x5
    80002034:	1b050513          	addi	a0,a0,432 # 800071e0 <etext+0x1e0>
    80002038:	fa8fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    8000203c:	062020ef          	jal	8000409e <fileclose>
      p->ofile[fd] = 0;
    80002040:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002044:	04a1                	addi	s1,s1,8
    80002046:	01248563          	beq	s1,s2,80002050 <kexit+0x4c>
    if(p->ofile[fd]){
    8000204a:	6088                	ld	a0,0(s1)
    8000204c:	f965                	bnez	a0,8000203c <kexit+0x38>
    8000204e:	bfdd                	j	80002044 <kexit+0x40>
  begin_op();
    80002050:	443010ef          	jal	80003c92 <begin_op>
  iput(p->cwd);
    80002054:	1509b503          	ld	a0,336(s3)
    80002058:	3d2010ef          	jal	8000342a <iput>
  end_op();
    8000205c:	4a1010ef          	jal	80003cfc <end_op>
  p->cwd = 0;
    80002060:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002064:	0000e497          	auipc	s1,0xe
    80002068:	93c48493          	addi	s1,s1,-1732 # 8000f9a0 <wait_lock>
    8000206c:	8526                	mv	a0,s1
    8000206e:	b61fe0ef          	jal	80000bce <acquire>
  reparent(p);
    80002072:	854e                	mv	a0,s3
    80002074:	f3bff0ef          	jal	80001fae <reparent>
  wakeup(p->parent);
    80002078:	0389b503          	ld	a0,56(s3)
    8000207c:	ec9ff0ef          	jal	80001f44 <wakeup>
  acquire(&p->lock);
    80002080:	854e                	mv	a0,s3
    80002082:	b4dfe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002086:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000208a:	4795                	li	a5,5
    8000208c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002090:	8526                	mv	a0,s1
    80002092:	bd5fe0ef          	jal	80000c66 <release>
  sched();
    80002096:	d7dff0ef          	jal	80001e12 <sched>
  panic("zombie exit");
    8000209a:	00005517          	auipc	a0,0x5
    8000209e:	15650513          	addi	a0,a0,342 # 800071f0 <etext+0x1f0>
    800020a2:	f3efe0ef          	jal	800007e0 <panic>

00000000800020a6 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800020a6:	7179                	addi	sp,sp,-48
    800020a8:	f406                	sd	ra,40(sp)
    800020aa:	f022                	sd	s0,32(sp)
    800020ac:	ec26                	sd	s1,24(sp)
    800020ae:	e84a                	sd	s2,16(sp)
    800020b0:	e44e                	sd	s3,8(sp)
    800020b2:	1800                	addi	s0,sp,48
    800020b4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020b6:	0000e497          	auipc	s1,0xe
    800020ba:	d0248493          	addi	s1,s1,-766 # 8000fdb8 <proc>
    800020be:	00014997          	auipc	s3,0x14
    800020c2:	afa98993          	addi	s3,s3,-1286 # 80015bb8 <tickslock>
    acquire(&p->lock);
    800020c6:	8526                	mv	a0,s1
    800020c8:	b07fe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    800020cc:	589c                	lw	a5,48(s1)
    800020ce:	01278b63          	beq	a5,s2,800020e4 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020d2:	8526                	mv	a0,s1
    800020d4:	b93fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020d8:	17848493          	addi	s1,s1,376
    800020dc:	ff3495e3          	bne	s1,s3,800020c6 <kkill+0x20>
  }
  return -1;
    800020e0:	557d                	li	a0,-1
    800020e2:	a819                	j	800020f8 <kkill+0x52>
      p->killed = 1;
    800020e4:	4785                	li	a5,1
    800020e6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020e8:	4c98                	lw	a4,24(s1)
    800020ea:	4789                	li	a5,2
    800020ec:	00f70d63          	beq	a4,a5,80002106 <kkill+0x60>
      release(&p->lock);
    800020f0:	8526                	mv	a0,s1
    800020f2:	b75fe0ef          	jal	80000c66 <release>
      return 0;
    800020f6:	4501                	li	a0,0
}
    800020f8:	70a2                	ld	ra,40(sp)
    800020fa:	7402                	ld	s0,32(sp)
    800020fc:	64e2                	ld	s1,24(sp)
    800020fe:	6942                	ld	s2,16(sp)
    80002100:	69a2                	ld	s3,8(sp)
    80002102:	6145                	addi	sp,sp,48
    80002104:	8082                	ret
        p->state = RUNNABLE;
    80002106:	478d                	li	a5,3
    80002108:	cc9c                	sw	a5,24(s1)
    8000210a:	b7dd                	j	800020f0 <kkill+0x4a>

000000008000210c <setkilled>:

void
setkilled(struct proc *p)
{
    8000210c:	1101                	addi	sp,sp,-32
    8000210e:	ec06                	sd	ra,24(sp)
    80002110:	e822                	sd	s0,16(sp)
    80002112:	e426                	sd	s1,8(sp)
    80002114:	1000                	addi	s0,sp,32
    80002116:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002118:	ab7fe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    8000211c:	4785                	li	a5,1
    8000211e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002120:	8526                	mv	a0,s1
    80002122:	b45fe0ef          	jal	80000c66 <release>
}
    80002126:	60e2                	ld	ra,24(sp)
    80002128:	6442                	ld	s0,16(sp)
    8000212a:	64a2                	ld	s1,8(sp)
    8000212c:	6105                	addi	sp,sp,32
    8000212e:	8082                	ret

0000000080002130 <killed>:

int
killed(struct proc *p)
{
    80002130:	1101                	addi	sp,sp,-32
    80002132:	ec06                	sd	ra,24(sp)
    80002134:	e822                	sd	s0,16(sp)
    80002136:	e426                	sd	s1,8(sp)
    80002138:	e04a                	sd	s2,0(sp)
    8000213a:	1000                	addi	s0,sp,32
    8000213c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000213e:	a91fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    80002142:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002146:	8526                	mv	a0,s1
    80002148:	b1ffe0ef          	jal	80000c66 <release>
  return k;
}
    8000214c:	854a                	mv	a0,s2
    8000214e:	60e2                	ld	ra,24(sp)
    80002150:	6442                	ld	s0,16(sp)
    80002152:	64a2                	ld	s1,8(sp)
    80002154:	6902                	ld	s2,0(sp)
    80002156:	6105                	addi	sp,sp,32
    80002158:	8082                	ret

000000008000215a <kwait>:
{
    8000215a:	715d                	addi	sp,sp,-80
    8000215c:	e486                	sd	ra,72(sp)
    8000215e:	e0a2                	sd	s0,64(sp)
    80002160:	fc26                	sd	s1,56(sp)
    80002162:	f84a                	sd	s2,48(sp)
    80002164:	f44e                	sd	s3,40(sp)
    80002166:	f052                	sd	s4,32(sp)
    80002168:	ec56                	sd	s5,24(sp)
    8000216a:	e85a                	sd	s6,16(sp)
    8000216c:	e45e                	sd	s7,8(sp)
    8000216e:	e062                	sd	s8,0(sp)
    80002170:	0880                	addi	s0,sp,80
    80002172:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002174:	f5aff0ef          	jal	800018ce <myproc>
    80002178:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000217a:	0000e517          	auipc	a0,0xe
    8000217e:	82650513          	addi	a0,a0,-2010 # 8000f9a0 <wait_lock>
    80002182:	a4dfe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002186:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002188:	4a15                	li	s4,5
        havekids = 1;
    8000218a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000218c:	00014997          	auipc	s3,0x14
    80002190:	a2c98993          	addi	s3,s3,-1492 # 80015bb8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002194:	0000ec17          	auipc	s8,0xe
    80002198:	80cc0c13          	addi	s8,s8,-2036 # 8000f9a0 <wait_lock>
    8000219c:	a871                	j	80002238 <kwait+0xde>
          pid = pp->pid;
    8000219e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021a2:	000b0c63          	beqz	s6,800021ba <kwait+0x60>
    800021a6:	4691                	li	a3,4
    800021a8:	02c48613          	addi	a2,s1,44
    800021ac:	85da                	mv	a1,s6
    800021ae:	05093503          	ld	a0,80(s2)
    800021b2:	c30ff0ef          	jal	800015e2 <copyout>
    800021b6:	02054b63          	bltz	a0,800021ec <kwait+0x92>
          freeproc(pp);
    800021ba:	8526                	mv	a0,s1
    800021bc:	8e3ff0ef          	jal	80001a9e <freeproc>
          release(&pp->lock);
    800021c0:	8526                	mv	a0,s1
    800021c2:	aa5fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    800021c6:	0000d517          	auipc	a0,0xd
    800021ca:	7da50513          	addi	a0,a0,2010 # 8000f9a0 <wait_lock>
    800021ce:	a99fe0ef          	jal	80000c66 <release>
}
    800021d2:	854e                	mv	a0,s3
    800021d4:	60a6                	ld	ra,72(sp)
    800021d6:	6406                	ld	s0,64(sp)
    800021d8:	74e2                	ld	s1,56(sp)
    800021da:	7942                	ld	s2,48(sp)
    800021dc:	79a2                	ld	s3,40(sp)
    800021de:	7a02                	ld	s4,32(sp)
    800021e0:	6ae2                	ld	s5,24(sp)
    800021e2:	6b42                	ld	s6,16(sp)
    800021e4:	6ba2                	ld	s7,8(sp)
    800021e6:	6c02                	ld	s8,0(sp)
    800021e8:	6161                	addi	sp,sp,80
    800021ea:	8082                	ret
            release(&pp->lock);
    800021ec:	8526                	mv	a0,s1
    800021ee:	a79fe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800021f2:	0000d517          	auipc	a0,0xd
    800021f6:	7ae50513          	addi	a0,a0,1966 # 8000f9a0 <wait_lock>
    800021fa:	a6dfe0ef          	jal	80000c66 <release>
            return -1;
    800021fe:	59fd                	li	s3,-1
    80002200:	bfc9                	j	800021d2 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002202:	17848493          	addi	s1,s1,376
    80002206:	03348063          	beq	s1,s3,80002226 <kwait+0xcc>
      if(pp->parent == p){
    8000220a:	7c9c                	ld	a5,56(s1)
    8000220c:	ff279be3          	bne	a5,s2,80002202 <kwait+0xa8>
        acquire(&pp->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	9bdfe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    80002216:	4c9c                	lw	a5,24(s1)
    80002218:	f94783e3          	beq	a5,s4,8000219e <kwait+0x44>
        release(&pp->lock);
    8000221c:	8526                	mv	a0,s1
    8000221e:	a49fe0ef          	jal	80000c66 <release>
        havekids = 1;
    80002222:	8756                	mv	a4,s5
    80002224:	bff9                	j	80002202 <kwait+0xa8>
    if(!havekids || killed(p)){
    80002226:	cf19                	beqz	a4,80002244 <kwait+0xea>
    80002228:	854a                	mv	a0,s2
    8000222a:	f07ff0ef          	jal	80002130 <killed>
    8000222e:	e919                	bnez	a0,80002244 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002230:	85e2                	mv	a1,s8
    80002232:	854a                	mv	a0,s2
    80002234:	cc5ff0ef          	jal	80001ef8 <sleep>
    havekids = 0;
    80002238:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000223a:	0000e497          	auipc	s1,0xe
    8000223e:	b7e48493          	addi	s1,s1,-1154 # 8000fdb8 <proc>
    80002242:	b7e1                	j	8000220a <kwait+0xb0>
      release(&wait_lock);
    80002244:	0000d517          	auipc	a0,0xd
    80002248:	75c50513          	addi	a0,a0,1884 # 8000f9a0 <wait_lock>
    8000224c:	a1bfe0ef          	jal	80000c66 <release>
      return -1;
    80002250:	59fd                	li	s3,-1
    80002252:	b741                	j	800021d2 <kwait+0x78>

0000000080002254 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002254:	7179                	addi	sp,sp,-48
    80002256:	f406                	sd	ra,40(sp)
    80002258:	f022                	sd	s0,32(sp)
    8000225a:	ec26                	sd	s1,24(sp)
    8000225c:	e84a                	sd	s2,16(sp)
    8000225e:	e44e                	sd	s3,8(sp)
    80002260:	e052                	sd	s4,0(sp)
    80002262:	1800                	addi	s0,sp,48
    80002264:	84aa                	mv	s1,a0
    80002266:	892e                	mv	s2,a1
    80002268:	89b2                	mv	s3,a2
    8000226a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000226c:	e62ff0ef          	jal	800018ce <myproc>
  if(user_dst){
    80002270:	cc99                	beqz	s1,8000228e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002272:	86d2                	mv	a3,s4
    80002274:	864e                	mv	a2,s3
    80002276:	85ca                	mv	a1,s2
    80002278:	6928                	ld	a0,80(a0)
    8000227a:	b68ff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6a02                	ld	s4,0(sp)
    8000228a:	6145                	addi	sp,sp,48
    8000228c:	8082                	ret
    memmove((char *)dst, src, len);
    8000228e:	000a061b          	sext.w	a2,s4
    80002292:	85ce                	mv	a1,s3
    80002294:	854a                	mv	a0,s2
    80002296:	a69fe0ef          	jal	80000cfe <memmove>
    return 0;
    8000229a:	8526                	mv	a0,s1
    8000229c:	b7cd                	j	8000227e <either_copyout+0x2a>

000000008000229e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000229e:	7179                	addi	sp,sp,-48
    800022a0:	f406                	sd	ra,40(sp)
    800022a2:	f022                	sd	s0,32(sp)
    800022a4:	ec26                	sd	s1,24(sp)
    800022a6:	e84a                	sd	s2,16(sp)
    800022a8:	e44e                	sd	s3,8(sp)
    800022aa:	e052                	sd	s4,0(sp)
    800022ac:	1800                	addi	s0,sp,48
    800022ae:	892a                	mv	s2,a0
    800022b0:	84ae                	mv	s1,a1
    800022b2:	89b2                	mv	s3,a2
    800022b4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022b6:	e18ff0ef          	jal	800018ce <myproc>
  if(user_src){
    800022ba:	cc99                	beqz	s1,800022d8 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022bc:	86d2                	mv	a3,s4
    800022be:	864e                	mv	a2,s3
    800022c0:	85ca                	mv	a1,s2
    800022c2:	6928                	ld	a0,80(a0)
    800022c4:	c02ff0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022c8:	70a2                	ld	ra,40(sp)
    800022ca:	7402                	ld	s0,32(sp)
    800022cc:	64e2                	ld	s1,24(sp)
    800022ce:	6942                	ld	s2,16(sp)
    800022d0:	69a2                	ld	s3,8(sp)
    800022d2:	6a02                	ld	s4,0(sp)
    800022d4:	6145                	addi	sp,sp,48
    800022d6:	8082                	ret
    memmove(dst, (char*)src, len);
    800022d8:	000a061b          	sext.w	a2,s4
    800022dc:	85ce                	mv	a1,s3
    800022de:	854a                	mv	a0,s2
    800022e0:	a1ffe0ef          	jal	80000cfe <memmove>
    return 0;
    800022e4:	8526                	mv	a0,s1
    800022e6:	b7cd                	j	800022c8 <either_copyin+0x2a>

00000000800022e8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022e8:	715d                	addi	sp,sp,-80
    800022ea:	e486                	sd	ra,72(sp)
    800022ec:	e0a2                	sd	s0,64(sp)
    800022ee:	fc26                	sd	s1,56(sp)
    800022f0:	f84a                	sd	s2,48(sp)
    800022f2:	f44e                	sd	s3,40(sp)
    800022f4:	f052                	sd	s4,32(sp)
    800022f6:	ec56                	sd	s5,24(sp)
    800022f8:	e85a                	sd	s6,16(sp)
    800022fa:	e45e                	sd	s7,8(sp)
    800022fc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022fe:	00005517          	auipc	a0,0x5
    80002302:	d7a50513          	addi	a0,a0,-646 # 80007078 <etext+0x78>
    80002306:	9f4fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000230a:	0000e497          	auipc	s1,0xe
    8000230e:	c0e48493          	addi	s1,s1,-1010 # 8000ff18 <proc+0x160>
    80002312:	00014917          	auipc	s2,0x14
    80002316:	a0690913          	addi	s2,s2,-1530 # 80015d18 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000231a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000231c:	00005997          	auipc	s3,0x5
    80002320:	ee498993          	addi	s3,s3,-284 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80002324:	00005a97          	auipc	s5,0x5
    80002328:	ee4a8a93          	addi	s5,s5,-284 # 80007208 <etext+0x208>
    printf("\n");
    8000232c:	00005a17          	auipc	s4,0x5
    80002330:	d4ca0a13          	addi	s4,s4,-692 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002334:	00005b97          	auipc	s7,0x5
    80002338:	3fcb8b93          	addi	s7,s7,1020 # 80007730 <states.0>
    8000233c:	a829                	j	80002356 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000233e:	ed06a583          	lw	a1,-304(a3)
    80002342:	8556                	mv	a0,s5
    80002344:	9b6fe0ef          	jal	800004fa <printf>
    printf("\n");
    80002348:	8552                	mv	a0,s4
    8000234a:	9b0fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000234e:	17848493          	addi	s1,s1,376
    80002352:	03248263          	beq	s1,s2,80002376 <procdump+0x8e>
    if(p->state == UNUSED)
    80002356:	86a6                	mv	a3,s1
    80002358:	eb84a783          	lw	a5,-328(s1)
    8000235c:	dbed                	beqz	a5,8000234e <procdump+0x66>
      state = "???";
    8000235e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002360:	fcfb6fe3          	bltu	s6,a5,8000233e <procdump+0x56>
    80002364:	02079713          	slli	a4,a5,0x20
    80002368:	01d75793          	srli	a5,a4,0x1d
    8000236c:	97de                	add	a5,a5,s7
    8000236e:	6390                	ld	a2,0(a5)
    80002370:	f679                	bnez	a2,8000233e <procdump+0x56>
      state = "???";
    80002372:	864e                	mv	a2,s3
    80002374:	b7e9                	j	8000233e <procdump+0x56>
  }
}
    80002376:	60a6                	ld	ra,72(sp)
    80002378:	6406                	ld	s0,64(sp)
    8000237a:	74e2                	ld	s1,56(sp)
    8000237c:	7942                	ld	s2,48(sp)
    8000237e:	79a2                	ld	s3,40(sp)
    80002380:	7a02                	ld	s4,32(sp)
    80002382:	6ae2                	ld	s5,24(sp)
    80002384:	6b42                	ld	s6,16(sp)
    80002386:	6ba2                	ld	s7,8(sp)
    80002388:	6161                	addi	sp,sp,80
    8000238a:	8082                	ret

000000008000238c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000238c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002390:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002394:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002396:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002398:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000239c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800023a0:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800023a4:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800023a8:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800023ac:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800023b0:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800023b4:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023b8:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800023bc:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023c0:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023c4:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023c8:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800023ca:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023cc:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023d0:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023d4:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023d8:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023dc:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023e0:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023e4:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023e8:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800023ec:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023f0:	0685bd83          	ld	s11,104(a1)
        
        ret
    800023f4:	8082                	ret

00000000800023f6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023f6:	1141                	addi	sp,sp,-16
    800023f8:	e406                	sd	ra,8(sp)
    800023fa:	e022                	sd	s0,0(sp)
    800023fc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023fe:	00005597          	auipc	a1,0x5
    80002402:	e4a58593          	addi	a1,a1,-438 # 80007248 <etext+0x248>
    80002406:	00013517          	auipc	a0,0x13
    8000240a:	7b250513          	addi	a0,a0,1970 # 80015bb8 <tickslock>
    8000240e:	f40fe0ef          	jal	80000b4e <initlock>
}
    80002412:	60a2                	ld	ra,8(sp)
    80002414:	6402                	ld	s0,0(sp)
    80002416:	0141                	addi	sp,sp,16
    80002418:	8082                	ret

000000008000241a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000241a:	1141                	addi	sp,sp,-16
    8000241c:	e422                	sd	s0,8(sp)
    8000241e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002420:	00003797          	auipc	a5,0x3
    80002424:	ff078793          	addi	a5,a5,-16 # 80005410 <kernelvec>
    80002428:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000242c:	6422                	ld	s0,8(sp)
    8000242e:	0141                	addi	sp,sp,16
    80002430:	8082                	ret

0000000080002432 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002432:	1141                	addi	sp,sp,-16
    80002434:	e406                	sd	ra,8(sp)
    80002436:	e022                	sd	s0,0(sp)
    80002438:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000243a:	c94ff0ef          	jal	800018ce <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000243e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002442:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002444:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002448:	04000737          	lui	a4,0x4000
    8000244c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000244e:	0732                	slli	a4,a4,0xc
    80002450:	00004797          	auipc	a5,0x4
    80002454:	bb078793          	addi	a5,a5,-1104 # 80006000 <_trampoline>
    80002458:	00004697          	auipc	a3,0x4
    8000245c:	ba868693          	addi	a3,a3,-1112 # 80006000 <_trampoline>
    80002460:	8f95                	sub	a5,a5,a3
    80002462:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002464:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002468:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000246a:	18002773          	csrr	a4,satp
    8000246e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002470:	6d38                	ld	a4,88(a0)
    80002472:	613c                	ld	a5,64(a0)
    80002474:	6685                	lui	a3,0x1
    80002476:	97b6                	add	a5,a5,a3
    80002478:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000247a:	6d3c                	ld	a5,88(a0)
    8000247c:	00000717          	auipc	a4,0x0
    80002480:	0f870713          	addi	a4,a4,248 # 80002574 <usertrap>
    80002484:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002486:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002488:	8712                	mv	a4,tp
    8000248a:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000248c:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002490:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002494:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002498:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000249c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000249e:	6f9c                	ld	a5,24(a5)
    800024a0:	14179073          	csrw	sepc,a5
}
    800024a4:	60a2                	ld	ra,8(sp)
    800024a6:	6402                	ld	s0,0(sp)
    800024a8:	0141                	addi	sp,sp,16
    800024aa:	8082                	ret

00000000800024ac <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024ac:	1101                	addi	sp,sp,-32
    800024ae:	ec06                	sd	ra,24(sp)
    800024b0:	e822                	sd	s0,16(sp)
    800024b2:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800024b4:	beeff0ef          	jal	800018a2 <cpuid>
    800024b8:	cd11                	beqz	a0,800024d4 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024ba:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024be:	000f4737          	lui	a4,0xf4
    800024c2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024c6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024c8:	14d79073          	csrw	stimecmp,a5
}
    800024cc:	60e2                	ld	ra,24(sp)
    800024ce:	6442                	ld	s0,16(sp)
    800024d0:	6105                	addi	sp,sp,32
    800024d2:	8082                	ret
    800024d4:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024d6:	00013497          	auipc	s1,0x13
    800024da:	6e248493          	addi	s1,s1,1762 # 80015bb8 <tickslock>
    800024de:	8526                	mv	a0,s1
    800024e0:	eeefe0ef          	jal	80000bce <acquire>
    ticks++;
    800024e4:	00005517          	auipc	a0,0x5
    800024e8:	3a450513          	addi	a0,a0,932 # 80007888 <ticks>
    800024ec:	411c                	lw	a5,0(a0)
    800024ee:	2785                	addiw	a5,a5,1
    800024f0:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024f2:	a53ff0ef          	jal	80001f44 <wakeup>
    release(&tickslock);
    800024f6:	8526                	mv	a0,s1
    800024f8:	f6efe0ef          	jal	80000c66 <release>
    800024fc:	64a2                	ld	s1,8(sp)
    800024fe:	bf75                	j	800024ba <clockintr+0xe>

0000000080002500 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002500:	1101                	addi	sp,sp,-32
    80002502:	ec06                	sd	ra,24(sp)
    80002504:	e822                	sd	s0,16(sp)
    80002506:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002508:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000250c:	57fd                	li	a5,-1
    8000250e:	17fe                	slli	a5,a5,0x3f
    80002510:	07a5                	addi	a5,a5,9
    80002512:	00f70c63          	beq	a4,a5,8000252a <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002516:	57fd                	li	a5,-1
    80002518:	17fe                	slli	a5,a5,0x3f
    8000251a:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000251c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000251e:	04f70763          	beq	a4,a5,8000256c <devintr+0x6c>
  }
}
    80002522:	60e2                	ld	ra,24(sp)
    80002524:	6442                	ld	s0,16(sp)
    80002526:	6105                	addi	sp,sp,32
    80002528:	8082                	ret
    8000252a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000252c:	791020ef          	jal	800054bc <plic_claim>
    80002530:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002532:	47a9                	li	a5,10
    80002534:	00f50963          	beq	a0,a5,80002546 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002538:	4785                	li	a5,1
    8000253a:	00f50963          	beq	a0,a5,8000254c <devintr+0x4c>
    return 1;
    8000253e:	4505                	li	a0,1
    } else if(irq){
    80002540:	e889                	bnez	s1,80002552 <devintr+0x52>
    80002542:	64a2                	ld	s1,8(sp)
    80002544:	bff9                	j	80002522 <devintr+0x22>
      uartintr();
    80002546:	c6afe0ef          	jal	800009b0 <uartintr>
    if(irq)
    8000254a:	a819                	j	80002560 <devintr+0x60>
      virtio_disk_intr();
    8000254c:	436030ef          	jal	80005982 <virtio_disk_intr>
    if(irq)
    80002550:	a801                	j	80002560 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002552:	85a6                	mv	a1,s1
    80002554:	00005517          	auipc	a0,0x5
    80002558:	cfc50513          	addi	a0,a0,-772 # 80007250 <etext+0x250>
    8000255c:	f9ffd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002560:	8526                	mv	a0,s1
    80002562:	77b020ef          	jal	800054dc <plic_complete>
    return 1;
    80002566:	4505                	li	a0,1
    80002568:	64a2                	ld	s1,8(sp)
    8000256a:	bf65                	j	80002522 <devintr+0x22>
    clockintr();
    8000256c:	f41ff0ef          	jal	800024ac <clockintr>
    return 2;
    80002570:	4509                	li	a0,2
    80002572:	bf45                	j	80002522 <devintr+0x22>

0000000080002574 <usertrap>:
{
    80002574:	1101                	addi	sp,sp,-32
    80002576:	ec06                	sd	ra,24(sp)
    80002578:	e822                	sd	s0,16(sp)
    8000257a:	e426                	sd	s1,8(sp)
    8000257c:	e04a                	sd	s2,0(sp)
    8000257e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002580:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002584:	1007f793          	andi	a5,a5,256
    80002588:	eba5                	bnez	a5,800025f8 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000258a:	00003797          	auipc	a5,0x3
    8000258e:	e8678793          	addi	a5,a5,-378 # 80005410 <kernelvec>
    80002592:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002596:	b38ff0ef          	jal	800018ce <myproc>
    8000259a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000259c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000259e:	14102773          	csrr	a4,sepc
    800025a2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025a4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025a8:	47a1                	li	a5,8
    800025aa:	04f70d63          	beq	a4,a5,80002604 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800025ae:	f53ff0ef          	jal	80002500 <devintr>
    800025b2:	892a                	mv	s2,a0
    800025b4:	e945                	bnez	a0,80002664 <usertrap+0xf0>
    800025b6:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800025ba:	47bd                	li	a5,15
    800025bc:	08f70863          	beq	a4,a5,8000264c <usertrap+0xd8>
    800025c0:	14202773          	csrr	a4,scause
    800025c4:	47b5                	li	a5,13
    800025c6:	08f70363          	beq	a4,a5,8000264c <usertrap+0xd8>
    800025ca:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025ce:	5890                	lw	a2,48(s1)
    800025d0:	00005517          	auipc	a0,0x5
    800025d4:	cc050513          	addi	a0,a0,-832 # 80007290 <etext+0x290>
    800025d8:	f23fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025dc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025e0:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025e4:	00005517          	auipc	a0,0x5
    800025e8:	cdc50513          	addi	a0,a0,-804 # 800072c0 <etext+0x2c0>
    800025ec:	f0ffd0ef          	jal	800004fa <printf>
    setkilled(p);
    800025f0:	8526                	mv	a0,s1
    800025f2:	b1bff0ef          	jal	8000210c <setkilled>
    800025f6:	a035                	j	80002622 <usertrap+0xae>
    panic("usertrap: not from user mode");
    800025f8:	00005517          	auipc	a0,0x5
    800025fc:	c7850513          	addi	a0,a0,-904 # 80007270 <etext+0x270>
    80002600:	9e0fe0ef          	jal	800007e0 <panic>
    if(killed(p))
    80002604:	b2dff0ef          	jal	80002130 <killed>
    80002608:	ed15                	bnez	a0,80002644 <usertrap+0xd0>
    p->trapframe->epc += 4;
    8000260a:	6cb8                	ld	a4,88(s1)
    8000260c:	6f1c                	ld	a5,24(a4)
    8000260e:	0791                	addi	a5,a5,4
    80002610:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002612:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002616:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000261a:	10079073          	csrw	sstatus,a5
    syscall();
    8000261e:	24a000ef          	jal	80002868 <syscall>
  if(killed(p))
    80002622:	8526                	mv	a0,s1
    80002624:	b0dff0ef          	jal	80002130 <killed>
    80002628:	e139                	bnez	a0,8000266e <usertrap+0xfa>
  prepare_return();
    8000262a:	e09ff0ef          	jal	80002432 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000262e:	68a8                	ld	a0,80(s1)
    80002630:	8131                	srli	a0,a0,0xc
    80002632:	57fd                	li	a5,-1
    80002634:	17fe                	slli	a5,a5,0x3f
    80002636:	8d5d                	or	a0,a0,a5
}
    80002638:	60e2                	ld	ra,24(sp)
    8000263a:	6442                	ld	s0,16(sp)
    8000263c:	64a2                	ld	s1,8(sp)
    8000263e:	6902                	ld	s2,0(sp)
    80002640:	6105                	addi	sp,sp,32
    80002642:	8082                	ret
      kexit(-1);
    80002644:	557d                	li	a0,-1
    80002646:	9bfff0ef          	jal	80002004 <kexit>
    8000264a:	b7c1                	j	8000260a <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000264c:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002650:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002654:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002656:	00163613          	seqz	a2,a2
    8000265a:	68a8                	ld	a0,80(s1)
    8000265c:	f05fe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002660:	f169                	bnez	a0,80002622 <usertrap+0xae>
    80002662:	b7a5                	j	800025ca <usertrap+0x56>
  if(killed(p))
    80002664:	8526                	mv	a0,s1
    80002666:	acbff0ef          	jal	80002130 <killed>
    8000266a:	c511                	beqz	a0,80002676 <usertrap+0x102>
    8000266c:	a011                	j	80002670 <usertrap+0xfc>
    8000266e:	4901                	li	s2,0
    kexit(-1);
    80002670:	557d                	li	a0,-1
    80002672:	993ff0ef          	jal	80002004 <kexit>
  if(which_dev == 2)
    80002676:	4789                	li	a5,2
    80002678:	faf919e3          	bne	s2,a5,8000262a <usertrap+0xb6>
    yield();
    8000267c:	851ff0ef          	jal	80001ecc <yield>
    80002680:	b76d                	j	8000262a <usertrap+0xb6>

0000000080002682 <kerneltrap>:
{
    80002682:	7179                	addi	sp,sp,-48
    80002684:	f406                	sd	ra,40(sp)
    80002686:	f022                	sd	s0,32(sp)
    80002688:	ec26                	sd	s1,24(sp)
    8000268a:	e84a                	sd	s2,16(sp)
    8000268c:	e44e                	sd	s3,8(sp)
    8000268e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002690:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002694:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002698:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000269c:	1004f793          	andi	a5,s1,256
    800026a0:	c795                	beqz	a5,800026cc <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026a6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026a8:	eb85                	bnez	a5,800026d8 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800026aa:	e57ff0ef          	jal	80002500 <devintr>
    800026ae:	c91d                	beqz	a0,800026e4 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800026b0:	4789                	li	a5,2
    800026b2:	04f50a63          	beq	a0,a5,80002706 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026b6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ba:	10049073          	csrw	sstatus,s1
}
    800026be:	70a2                	ld	ra,40(sp)
    800026c0:	7402                	ld	s0,32(sp)
    800026c2:	64e2                	ld	s1,24(sp)
    800026c4:	6942                	ld	s2,16(sp)
    800026c6:	69a2                	ld	s3,8(sp)
    800026c8:	6145                	addi	sp,sp,48
    800026ca:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026cc:	00005517          	auipc	a0,0x5
    800026d0:	c1c50513          	addi	a0,a0,-996 # 800072e8 <etext+0x2e8>
    800026d4:	90cfe0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    800026d8:	00005517          	auipc	a0,0x5
    800026dc:	c3850513          	addi	a0,a0,-968 # 80007310 <etext+0x310>
    800026e0:	900fe0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026e4:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026e8:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026ec:	85ce                	mv	a1,s3
    800026ee:	00005517          	auipc	a0,0x5
    800026f2:	c4250513          	addi	a0,a0,-958 # 80007330 <etext+0x330>
    800026f6:	e05fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800026fa:	00005517          	auipc	a0,0x5
    800026fe:	c5e50513          	addi	a0,a0,-930 # 80007358 <etext+0x358>
    80002702:	8defe0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002706:	9c8ff0ef          	jal	800018ce <myproc>
    8000270a:	d555                	beqz	a0,800026b6 <kerneltrap+0x34>
    yield();
    8000270c:	fc0ff0ef          	jal	80001ecc <yield>
    80002710:	b75d                	j	800026b6 <kerneltrap+0x34>

0000000080002712 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002712:	1101                	addi	sp,sp,-32
    80002714:	ec06                	sd	ra,24(sp)
    80002716:	e822                	sd	s0,16(sp)
    80002718:	e426                	sd	s1,8(sp)
    8000271a:	1000                	addi	s0,sp,32
    8000271c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000271e:	9b0ff0ef          	jal	800018ce <myproc>
  switch (n) {
    80002722:	4795                	li	a5,5
    80002724:	0497e163          	bltu	a5,s1,80002766 <argraw+0x54>
    80002728:	048a                	slli	s1,s1,0x2
    8000272a:	00005717          	auipc	a4,0x5
    8000272e:	03670713          	addi	a4,a4,54 # 80007760 <states.0+0x30>
    80002732:	94ba                	add	s1,s1,a4
    80002734:	409c                	lw	a5,0(s1)
    80002736:	97ba                	add	a5,a5,a4
    80002738:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000273a:	6d3c                	ld	a5,88(a0)
    8000273c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000273e:	60e2                	ld	ra,24(sp)
    80002740:	6442                	ld	s0,16(sp)
    80002742:	64a2                	ld	s1,8(sp)
    80002744:	6105                	addi	sp,sp,32
    80002746:	8082                	ret
    return p->trapframe->a1;
    80002748:	6d3c                	ld	a5,88(a0)
    8000274a:	7fa8                	ld	a0,120(a5)
    8000274c:	bfcd                	j	8000273e <argraw+0x2c>
    return p->trapframe->a2;
    8000274e:	6d3c                	ld	a5,88(a0)
    80002750:	63c8                	ld	a0,128(a5)
    80002752:	b7f5                	j	8000273e <argraw+0x2c>
    return p->trapframe->a3;
    80002754:	6d3c                	ld	a5,88(a0)
    80002756:	67c8                	ld	a0,136(a5)
    80002758:	b7dd                	j	8000273e <argraw+0x2c>
    return p->trapframe->a4;
    8000275a:	6d3c                	ld	a5,88(a0)
    8000275c:	6bc8                	ld	a0,144(a5)
    8000275e:	b7c5                	j	8000273e <argraw+0x2c>
    return p->trapframe->a5;
    80002760:	6d3c                	ld	a5,88(a0)
    80002762:	6fc8                	ld	a0,152(a5)
    80002764:	bfe9                	j	8000273e <argraw+0x2c>
  panic("argraw");
    80002766:	00005517          	auipc	a0,0x5
    8000276a:	c0250513          	addi	a0,a0,-1022 # 80007368 <etext+0x368>
    8000276e:	872fe0ef          	jal	800007e0 <panic>

0000000080002772 <fetchaddr>:
{
    80002772:	1101                	addi	sp,sp,-32
    80002774:	ec06                	sd	ra,24(sp)
    80002776:	e822                	sd	s0,16(sp)
    80002778:	e426                	sd	s1,8(sp)
    8000277a:	e04a                	sd	s2,0(sp)
    8000277c:	1000                	addi	s0,sp,32
    8000277e:	84aa                	mv	s1,a0
    80002780:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002782:	94cff0ef          	jal	800018ce <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002786:	653c                	ld	a5,72(a0)
    80002788:	02f4f663          	bgeu	s1,a5,800027b4 <fetchaddr+0x42>
    8000278c:	00848713          	addi	a4,s1,8
    80002790:	02e7e463          	bltu	a5,a4,800027b8 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002794:	46a1                	li	a3,8
    80002796:	8626                	mv	a2,s1
    80002798:	85ca                	mv	a1,s2
    8000279a:	6928                	ld	a0,80(a0)
    8000279c:	f2bfe0ef          	jal	800016c6 <copyin>
    800027a0:	00a03533          	snez	a0,a0
    800027a4:	40a00533          	neg	a0,a0
}
    800027a8:	60e2                	ld	ra,24(sp)
    800027aa:	6442                	ld	s0,16(sp)
    800027ac:	64a2                	ld	s1,8(sp)
    800027ae:	6902                	ld	s2,0(sp)
    800027b0:	6105                	addi	sp,sp,32
    800027b2:	8082                	ret
    return -1;
    800027b4:	557d                	li	a0,-1
    800027b6:	bfcd                	j	800027a8 <fetchaddr+0x36>
    800027b8:	557d                	li	a0,-1
    800027ba:	b7fd                	j	800027a8 <fetchaddr+0x36>

00000000800027bc <fetchstr>:
{
    800027bc:	7179                	addi	sp,sp,-48
    800027be:	f406                	sd	ra,40(sp)
    800027c0:	f022                	sd	s0,32(sp)
    800027c2:	ec26                	sd	s1,24(sp)
    800027c4:	e84a                	sd	s2,16(sp)
    800027c6:	e44e                	sd	s3,8(sp)
    800027c8:	1800                	addi	s0,sp,48
    800027ca:	892a                	mv	s2,a0
    800027cc:	84ae                	mv	s1,a1
    800027ce:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027d0:	8feff0ef          	jal	800018ce <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027d4:	86ce                	mv	a3,s3
    800027d6:	864a                	mv	a2,s2
    800027d8:	85a6                	mv	a1,s1
    800027da:	6928                	ld	a0,80(a0)
    800027dc:	cadfe0ef          	jal	80001488 <copyinstr>
    800027e0:	00054c63          	bltz	a0,800027f8 <fetchstr+0x3c>
  return strlen(buf);
    800027e4:	8526                	mv	a0,s1
    800027e6:	e2cfe0ef          	jal	80000e12 <strlen>
}
    800027ea:	70a2                	ld	ra,40(sp)
    800027ec:	7402                	ld	s0,32(sp)
    800027ee:	64e2                	ld	s1,24(sp)
    800027f0:	6942                	ld	s2,16(sp)
    800027f2:	69a2                	ld	s3,8(sp)
    800027f4:	6145                	addi	sp,sp,48
    800027f6:	8082                	ret
    return -1;
    800027f8:	557d                	li	a0,-1
    800027fa:	bfc5                	j	800027ea <fetchstr+0x2e>

00000000800027fc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800027fc:	1101                	addi	sp,sp,-32
    800027fe:	ec06                	sd	ra,24(sp)
    80002800:	e822                	sd	s0,16(sp)
    80002802:	e426                	sd	s1,8(sp)
    80002804:	1000                	addi	s0,sp,32
    80002806:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002808:	f0bff0ef          	jal	80002712 <argraw>
    8000280c:	c088                	sw	a0,0(s1)
  return 0;
}
    8000280e:	4501                	li	a0,0
    80002810:	60e2                	ld	ra,24(sp)
    80002812:	6442                	ld	s0,16(sp)
    80002814:	64a2                	ld	s1,8(sp)
    80002816:	6105                	addi	sp,sp,32
    80002818:	8082                	ret

000000008000281a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000281a:	1101                	addi	sp,sp,-32
    8000281c:	ec06                	sd	ra,24(sp)
    8000281e:	e822                	sd	s0,16(sp)
    80002820:	e426                	sd	s1,8(sp)
    80002822:	1000                	addi	s0,sp,32
    80002824:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002826:	eedff0ef          	jal	80002712 <argraw>
    8000282a:	e088                	sd	a0,0(s1)
  return 0; // Hoặc logic kiểm tra lỗi của bạn
}
    8000282c:	4501                	li	a0,0
    8000282e:	60e2                	ld	ra,24(sp)
    80002830:	6442                	ld	s0,16(sp)
    80002832:	64a2                	ld	s1,8(sp)
    80002834:	6105                	addi	sp,sp,32
    80002836:	8082                	ret

0000000080002838 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002838:	7179                	addi	sp,sp,-48
    8000283a:	f406                	sd	ra,40(sp)
    8000283c:	f022                	sd	s0,32(sp)
    8000283e:	ec26                	sd	s1,24(sp)
    80002840:	e84a                	sd	s2,16(sp)
    80002842:	1800                	addi	s0,sp,48
    80002844:	84ae                	mv	s1,a1
    80002846:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002848:	fd840593          	addi	a1,s0,-40
    8000284c:	fcfff0ef          	jal	8000281a <argaddr>
  return fetchstr(addr, buf, max);
    80002850:	864a                	mv	a2,s2
    80002852:	85a6                	mv	a1,s1
    80002854:	fd843503          	ld	a0,-40(s0)
    80002858:	f65ff0ef          	jal	800027bc <fetchstr>
}
    8000285c:	70a2                	ld	ra,40(sp)
    8000285e:	7402                	ld	s0,32(sp)
    80002860:	64e2                	ld	s1,24(sp)
    80002862:	6942                	ld	s2,16(sp)
    80002864:	6145                	addi	sp,sp,48
    80002866:	8082                	ret

0000000080002868 <syscall>:
};


void 
syscall(void)
{
    80002868:	1101                	addi	sp,sp,-32
    8000286a:	ec06                	sd	ra,24(sp)
    8000286c:	e822                	sd	s0,16(sp)
    8000286e:	e426                	sd	s1,8(sp)
    80002870:	e04a                	sd	s2,0(sp)
    80002872:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002874:	85aff0ef          	jal	800018ce <myproc>
    80002878:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000287a:	05853903          	ld	s2,88(a0)
    8000287e:	0a893783          	ld	a5,168(s2)
    80002882:	0007869b          	sext.w	a3,a5
  
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002886:	37fd                	addiw	a5,a5,-1
    80002888:	4761                	li	a4,24
    8000288a:	02f76963          	bltu	a4,a5,800028bc <syscall+0x54>
    8000288e:	00369713          	slli	a4,a3,0x3
    80002892:	00005797          	auipc	a5,0x5
    80002896:	ee678793          	addi	a5,a5,-282 # 80007778 <syscalls>
    8000289a:	97ba                	add	a5,a5,a4
    8000289c:	6398                	ld	a4,0(a5)
    8000289e:	cf19                	beqz	a4,800028bc <syscall+0x54>
    
    // --- ĐÂY LÀ LOGIC CHẶN CỦA DEV 3 ---
    // Kiểm tra nếu bit tương ứng với syscall 'num' trong syscall_mask đang bật
    if((p->syscall_mask & ((uint64)1 << num)) != 0) {
    800028a0:	15853783          	ld	a5,344(a0)
    800028a4:	00d7d7b3          	srl	a5,a5,a3
    800028a8:	8b85                	andi	a5,a5,1
    800028aa:	e789                	bnez	a5,800028b4 <syscall+0x4c>
      return; 
    }
    // ----------------------------------

    // Nếu không bị chặn, mới cho phép thực thi syscall
    p->trapframe->a0 = syscalls[num]();
    800028ac:	9702                	jalr	a4
    800028ae:	06a93823          	sd	a0,112(s2)
    800028b2:	a00d                	j	800028d4 <syscall+0x6c>
      p->trapframe->a0 = -1;
    800028b4:	57fd                	li	a5,-1
    800028b6:	06f93823          	sd	a5,112(s2)
      return; 
    800028ba:	a829                	j	800028d4 <syscall+0x6c>
  } else {
    printf("%d %s: unknown syscall %d\n", p->pid, p->name, num);
    800028bc:	16048613          	addi	a2,s1,352
    800028c0:	588c                	lw	a1,48(s1)
    800028c2:	00005517          	auipc	a0,0x5
    800028c6:	aae50513          	addi	a0,a0,-1362 # 80007370 <etext+0x370>
    800028ca:	c31fd0ef          	jal	800004fa <printf>
    p->trapframe->a0 = -1;
    800028ce:	6cbc                	ld	a5,88(s1)
    800028d0:	577d                	li	a4,-1
    800028d2:	fbb8                	sd	a4,112(a5)
  }
}
    800028d4:	60e2                	ld	ra,24(sp)
    800028d6:	6442                	ld	s0,16(sp)
    800028d8:	64a2                	ld	s1,8(sp)
    800028da:	6902                	ld	s2,0(sp)
    800028dc:	6105                	addi	sp,sp,32
    800028de:	8082                	ret

00000000800028e0 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800028e0:	1101                	addi	sp,sp,-32
    800028e2:	ec06                	sd	ra,24(sp)
    800028e4:	e822                	sd	s0,16(sp)
    800028e6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028e8:	fec40593          	addi	a1,s0,-20
    800028ec:	4501                	li	a0,0
    800028ee:	f0fff0ef          	jal	800027fc <argint>
  kexit(n);
    800028f2:	fec42503          	lw	a0,-20(s0)
    800028f6:	f0eff0ef          	jal	80002004 <kexit>
  return 0;  // not reached
}
    800028fa:	4501                	li	a0,0
    800028fc:	60e2                	ld	ra,24(sp)
    800028fe:	6442                	ld	s0,16(sp)
    80002900:	6105                	addi	sp,sp,32
    80002902:	8082                	ret

0000000080002904 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002904:	1141                	addi	sp,sp,-16
    80002906:	e406                	sd	ra,8(sp)
    80002908:	e022                	sd	s0,0(sp)
    8000290a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000290c:	fc3fe0ef          	jal	800018ce <myproc>
}
    80002910:	5908                	lw	a0,48(a0)
    80002912:	60a2                	ld	ra,8(sp)
    80002914:	6402                	ld	s0,0(sp)
    80002916:	0141                	addi	sp,sp,16
    80002918:	8082                	ret

000000008000291a <sys_fork>:

uint64
sys_fork(void)
{
    8000291a:	1141                	addi	sp,sp,-16
    8000291c:	e406                	sd	ra,8(sp)
    8000291e:	e022                	sd	s0,0(sp)
    80002920:	0800                	addi	s0,sp,16
  return kfork();
    80002922:	b1cff0ef          	jal	80001c3e <kfork>
}
    80002926:	60a2                	ld	ra,8(sp)
    80002928:	6402                	ld	s0,0(sp)
    8000292a:	0141                	addi	sp,sp,16
    8000292c:	8082                	ret

000000008000292e <sys_wait>:

uint64
sys_wait(void)
{
    8000292e:	1101                	addi	sp,sp,-32
    80002930:	ec06                	sd	ra,24(sp)
    80002932:	e822                	sd	s0,16(sp)
    80002934:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002936:	fe840593          	addi	a1,s0,-24
    8000293a:	4501                	li	a0,0
    8000293c:	edfff0ef          	jal	8000281a <argaddr>
  return kwait(p);
    80002940:	fe843503          	ld	a0,-24(s0)
    80002944:	817ff0ef          	jal	8000215a <kwait>
}
    80002948:	60e2                	ld	ra,24(sp)
    8000294a:	6442                	ld	s0,16(sp)
    8000294c:	6105                	addi	sp,sp,32
    8000294e:	8082                	ret

0000000080002950 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002950:	7179                	addi	sp,sp,-48
    80002952:	f406                	sd	ra,40(sp)
    80002954:	f022                	sd	s0,32(sp)
    80002956:	ec26                	sd	s1,24(sp)
    80002958:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    8000295a:	fd840593          	addi	a1,s0,-40
    8000295e:	4501                	li	a0,0
    80002960:	e9dff0ef          	jal	800027fc <argint>
  argint(1, &t);
    80002964:	fdc40593          	addi	a1,s0,-36
    80002968:	4505                	li	a0,1
    8000296a:	e93ff0ef          	jal	800027fc <argint>
  addr = myproc()->sz;
    8000296e:	f61fe0ef          	jal	800018ce <myproc>
    80002972:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002974:	fdc42703          	lw	a4,-36(s0)
    80002978:	4785                	li	a5,1
    8000297a:	02f70763          	beq	a4,a5,800029a8 <sys_sbrk+0x58>
    8000297e:	fd842783          	lw	a5,-40(s0)
    80002982:	0207c363          	bltz	a5,800029a8 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002986:	97a6                	add	a5,a5,s1
    80002988:	0297ee63          	bltu	a5,s1,800029c4 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    8000298c:	02000737          	lui	a4,0x2000
    80002990:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002992:	0736                	slli	a4,a4,0xd
    80002994:	02f76a63          	bltu	a4,a5,800029c8 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002998:	f37fe0ef          	jal	800018ce <myproc>
    8000299c:	fd842703          	lw	a4,-40(s0)
    800029a0:	653c                	ld	a5,72(a0)
    800029a2:	97ba                	add	a5,a5,a4
    800029a4:	e53c                	sd	a5,72(a0)
    800029a6:	a039                	j	800029b4 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    800029a8:	fd842503          	lw	a0,-40(s0)
    800029ac:	a30ff0ef          	jal	80001bdc <growproc>
    800029b0:	00054863          	bltz	a0,800029c0 <sys_sbrk+0x70>
  }
  return addr;
}
    800029b4:	8526                	mv	a0,s1
    800029b6:	70a2                	ld	ra,40(sp)
    800029b8:	7402                	ld	s0,32(sp)
    800029ba:	64e2                	ld	s1,24(sp)
    800029bc:	6145                	addi	sp,sp,48
    800029be:	8082                	ret
      return -1;
    800029c0:	54fd                	li	s1,-1
    800029c2:	bfcd                	j	800029b4 <sys_sbrk+0x64>
      return -1;
    800029c4:	54fd                	li	s1,-1
    800029c6:	b7fd                	j	800029b4 <sys_sbrk+0x64>
      return -1;
    800029c8:	54fd                	li	s1,-1
    800029ca:	b7ed                	j	800029b4 <sys_sbrk+0x64>

00000000800029cc <sys_pause>:

uint64
sys_pause(void)
{
    800029cc:	7139                	addi	sp,sp,-64
    800029ce:	fc06                	sd	ra,56(sp)
    800029d0:	f822                	sd	s0,48(sp)
    800029d2:	f04a                	sd	s2,32(sp)
    800029d4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029d6:	fcc40593          	addi	a1,s0,-52
    800029da:	4501                	li	a0,0
    800029dc:	e21ff0ef          	jal	800027fc <argint>
  if(n < 0)
    800029e0:	fcc42783          	lw	a5,-52(s0)
    800029e4:	0607c763          	bltz	a5,80002a52 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029e8:	00013517          	auipc	a0,0x13
    800029ec:	1d050513          	addi	a0,a0,464 # 80015bb8 <tickslock>
    800029f0:	9defe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    800029f4:	00005917          	auipc	s2,0x5
    800029f8:	e9492903          	lw	s2,-364(s2) # 80007888 <ticks>
  while(ticks - ticks0 < n){
    800029fc:	fcc42783          	lw	a5,-52(s0)
    80002a00:	cf8d                	beqz	a5,80002a3a <sys_pause+0x6e>
    80002a02:	f426                	sd	s1,40(sp)
    80002a04:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a06:	00013997          	auipc	s3,0x13
    80002a0a:	1b298993          	addi	s3,s3,434 # 80015bb8 <tickslock>
    80002a0e:	00005497          	auipc	s1,0x5
    80002a12:	e7a48493          	addi	s1,s1,-390 # 80007888 <ticks>
    if(killed(myproc())){
    80002a16:	eb9fe0ef          	jal	800018ce <myproc>
    80002a1a:	f16ff0ef          	jal	80002130 <killed>
    80002a1e:	ed0d                	bnez	a0,80002a58 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a20:	85ce                	mv	a1,s3
    80002a22:	8526                	mv	a0,s1
    80002a24:	cd4ff0ef          	jal	80001ef8 <sleep>
  while(ticks - ticks0 < n){
    80002a28:	409c                	lw	a5,0(s1)
    80002a2a:	412787bb          	subw	a5,a5,s2
    80002a2e:	fcc42703          	lw	a4,-52(s0)
    80002a32:	fee7e2e3          	bltu	a5,a4,80002a16 <sys_pause+0x4a>
    80002a36:	74a2                	ld	s1,40(sp)
    80002a38:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a3a:	00013517          	auipc	a0,0x13
    80002a3e:	17e50513          	addi	a0,a0,382 # 80015bb8 <tickslock>
    80002a42:	a24fe0ef          	jal	80000c66 <release>
  return 0;
    80002a46:	4501                	li	a0,0
}
    80002a48:	70e2                	ld	ra,56(sp)
    80002a4a:	7442                	ld	s0,48(sp)
    80002a4c:	7902                	ld	s2,32(sp)
    80002a4e:	6121                	addi	sp,sp,64
    80002a50:	8082                	ret
    n = 0;
    80002a52:	fc042623          	sw	zero,-52(s0)
    80002a56:	bf49                	j	800029e8 <sys_pause+0x1c>
      release(&tickslock);
    80002a58:	00013517          	auipc	a0,0x13
    80002a5c:	16050513          	addi	a0,a0,352 # 80015bb8 <tickslock>
    80002a60:	a06fe0ef          	jal	80000c66 <release>
      return -1;
    80002a64:	557d                	li	a0,-1
    80002a66:	74a2                	ld	s1,40(sp)
    80002a68:	69e2                	ld	s3,24(sp)
    80002a6a:	bff9                	j	80002a48 <sys_pause+0x7c>

0000000080002a6c <sys_kill>:

uint64
sys_kill(void)
{
    80002a6c:	1101                	addi	sp,sp,-32
    80002a6e:	ec06                	sd	ra,24(sp)
    80002a70:	e822                	sd	s0,16(sp)
    80002a72:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a74:	fec40593          	addi	a1,s0,-20
    80002a78:	4501                	li	a0,0
    80002a7a:	d83ff0ef          	jal	800027fc <argint>
  return kkill(pid);
    80002a7e:	fec42503          	lw	a0,-20(s0)
    80002a82:	e24ff0ef          	jal	800020a6 <kkill>
}
    80002a86:	60e2                	ld	ra,24(sp)
    80002a88:	6442                	ld	s0,16(sp)
    80002a8a:	6105                	addi	sp,sp,32
    80002a8c:	8082                	ret

0000000080002a8e <sys_uptime>:

uint64
sys_uptime(void)
{
    80002a8e:	1101                	addi	sp,sp,-32
    80002a90:	ec06                	sd	ra,24(sp)
    80002a92:	e822                	sd	s0,16(sp)
    80002a94:	e426                	sd	s1,8(sp)
    80002a96:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a98:	00013517          	auipc	a0,0x13
    80002a9c:	12050513          	addi	a0,a0,288 # 80015bb8 <tickslock>
    80002aa0:	92efe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002aa4:	00005497          	auipc	s1,0x5
    80002aa8:	de44a483          	lw	s1,-540(s1) # 80007888 <ticks>
  release(&tickslock);
    80002aac:	00013517          	auipc	a0,0x13
    80002ab0:	10c50513          	addi	a0,a0,268 # 80015bb8 <tickslock>
    80002ab4:	9b2fe0ef          	jal	80000c66 <release>
  return xticks;
}
    80002ab8:	02049513          	slli	a0,s1,0x20
    80002abc:	9101                	srli	a0,a0,0x20
    80002abe:	60e2                	ld	ra,24(sp)
    80002ac0:	6442                	ld	s0,16(sp)
    80002ac2:	64a2                	ld	s1,8(sp)
    80002ac4:	6105                	addi	sp,sp,32
    80002ac6:	8082                	ret

0000000080002ac8 <sys_hello>:

uint64
sys_hello(void)
{
    80002ac8:	1141                	addi	sp,sp,-16
    80002aca:	e406                	sd	ra,8(sp)
    80002acc:	e022                	sd	s0,0(sp)
    80002ace:	0800                	addi	s0,sp,16
  printf("hello\n");
    80002ad0:	00005517          	auipc	a0,0x5
    80002ad4:	8c050513          	addi	a0,a0,-1856 # 80007390 <etext+0x390>
    80002ad8:	a23fd0ef          	jal	800004fa <printf>
  return 0;
}
    80002adc:	4501                	li	a0,0
    80002ade:	60a2                	ld	ra,8(sp)
    80002ae0:	6402                	ld	s0,0(sp)
    80002ae2:	0141                	addi	sp,sp,16
    80002ae4:	8082                	ret

0000000080002ae6 <sys_setfilter>:

uint64
sys_setfilter(void)
{
    80002ae6:	1101                	addi	sp,sp,-32
    80002ae8:	ec06                	sd	ra,24(sp)
    80002aea:	e822                	sd	s0,16(sp)
    80002aec:	1000                	addi	s0,sp,32
  uint64 mask;
  argaddr(0, &mask); 
    80002aee:	fe840593          	addi	a1,s0,-24
    80002af2:	4501                	li	a0,0
    80002af4:	d27ff0ef          	jal	8000281a <argaddr>
  
  struct proc *p = myproc();
    80002af8:	dd7fe0ef          	jal	800018ce <myproc>
  p->syscall_mask = mask;
    80002afc:	fe843783          	ld	a5,-24(s0)
    80002b00:	14f53c23          	sd	a5,344(a0)
  
  return 0;
}
    80002b04:	4501                	li	a0,0
    80002b06:	60e2                	ld	ra,24(sp)
    80002b08:	6442                	ld	s0,16(sp)
    80002b0a:	6105                	addi	sp,sp,32
    80002b0c:	8082                	ret

0000000080002b0e <sys_getfilter>:
//   This prevents a child from escaping a sandbox established by its parent.

// get syscall filter
uint64
sys_getfilter(void)
{
    80002b0e:	1141                	addi	sp,sp,-16
    80002b10:	e406                	sd	ra,8(sp)
    80002b12:	e022                	sd	s0,0(sp)
    80002b14:	0800                	addi	s0,sp,16
  return myproc()->syscall_mask;  // return mask for current process
    80002b16:	db9fe0ef          	jal	800018ce <myproc>
}
    80002b1a:	15853503          	ld	a0,344(a0)
    80002b1e:	60a2                	ld	ra,8(sp)
    80002b20:	6402                	ld	s0,0(sp)
    80002b22:	0141                	addi	sp,sp,16
    80002b24:	8082                	ret

0000000080002b26 <sys_setfilter_child>:

uint64
sys_setfilter_child(void)
{
    80002b26:	1101                	addi	sp,sp,-32
    80002b28:	ec06                	sd	ra,24(sp)
    80002b2a:	e822                	sd	s0,16(sp)
    80002b2c:	1000                	addi	s0,sp,32
  uint64 mask;
  // Lấy tham số đầu tiên (mask) từ thanh ghi a0
  if(argaddr(0, &mask) < 0)
    80002b2e:	fe840593          	addi	a1,s0,-24
    80002b32:	4501                	li	a0,0
    80002b34:	ce7ff0ef          	jal	8000281a <argaddr>
    return -1;
    80002b38:	57fd                	li	a5,-1
  if(argaddr(0, &mask) < 0)
    80002b3a:	00054963          	bltz	a0,80002b4c <sys_setfilter_child+0x26>

  myproc()->child_syscall_mask = mask;
    80002b3e:	d91fe0ef          	jal	800018ce <myproc>
    80002b42:	fe843783          	ld	a5,-24(s0)
    80002b46:	16f53823          	sd	a5,368(a0)
  return 0;
    80002b4a:	4781                	li	a5,0
    80002b4c:	853e                	mv	a0,a5
    80002b4e:	60e2                	ld	ra,24(sp)
    80002b50:	6442                	ld	s0,16(sp)
    80002b52:	6105                	addi	sp,sp,32
    80002b54:	8082                	ret

0000000080002b56 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b56:	7179                	addi	sp,sp,-48
    80002b58:	f406                	sd	ra,40(sp)
    80002b5a:	f022                	sd	s0,32(sp)
    80002b5c:	ec26                	sd	s1,24(sp)
    80002b5e:	e84a                	sd	s2,16(sp)
    80002b60:	e44e                	sd	s3,8(sp)
    80002b62:	e052                	sd	s4,0(sp)
    80002b64:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b66:	00005597          	auipc	a1,0x5
    80002b6a:	83258593          	addi	a1,a1,-1998 # 80007398 <etext+0x398>
    80002b6e:	00013517          	auipc	a0,0x13
    80002b72:	06250513          	addi	a0,a0,98 # 80015bd0 <bcache>
    80002b76:	fd9fd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b7a:	0001b797          	auipc	a5,0x1b
    80002b7e:	05678793          	addi	a5,a5,86 # 8001dbd0 <bcache+0x8000>
    80002b82:	0001b717          	auipc	a4,0x1b
    80002b86:	2b670713          	addi	a4,a4,694 # 8001de38 <bcache+0x8268>
    80002b8a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b8e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b92:	00013497          	auipc	s1,0x13
    80002b96:	05648493          	addi	s1,s1,86 # 80015be8 <bcache+0x18>
    b->next = bcache.head.next;
    80002b9a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b9c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b9e:	00005a17          	auipc	s4,0x5
    80002ba2:	802a0a13          	addi	s4,s4,-2046 # 800073a0 <etext+0x3a0>
    b->next = bcache.head.next;
    80002ba6:	2b893783          	ld	a5,696(s2)
    80002baa:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bac:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bb0:	85d2                	mv	a1,s4
    80002bb2:	01048513          	addi	a0,s1,16
    80002bb6:	322010ef          	jal	80003ed8 <initsleeplock>
    bcache.head.next->prev = b;
    80002bba:	2b893783          	ld	a5,696(s2)
    80002bbe:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bc0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bc4:	45848493          	addi	s1,s1,1112
    80002bc8:	fd349fe3          	bne	s1,s3,80002ba6 <binit+0x50>
  }
}
    80002bcc:	70a2                	ld	ra,40(sp)
    80002bce:	7402                	ld	s0,32(sp)
    80002bd0:	64e2                	ld	s1,24(sp)
    80002bd2:	6942                	ld	s2,16(sp)
    80002bd4:	69a2                	ld	s3,8(sp)
    80002bd6:	6a02                	ld	s4,0(sp)
    80002bd8:	6145                	addi	sp,sp,48
    80002bda:	8082                	ret

0000000080002bdc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002bdc:	7179                	addi	sp,sp,-48
    80002bde:	f406                	sd	ra,40(sp)
    80002be0:	f022                	sd	s0,32(sp)
    80002be2:	ec26                	sd	s1,24(sp)
    80002be4:	e84a                	sd	s2,16(sp)
    80002be6:	e44e                	sd	s3,8(sp)
    80002be8:	1800                	addi	s0,sp,48
    80002bea:	892a                	mv	s2,a0
    80002bec:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002bee:	00013517          	auipc	a0,0x13
    80002bf2:	fe250513          	addi	a0,a0,-30 # 80015bd0 <bcache>
    80002bf6:	fd9fd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002bfa:	0001b497          	auipc	s1,0x1b
    80002bfe:	28e4b483          	ld	s1,654(s1) # 8001de88 <bcache+0x82b8>
    80002c02:	0001b797          	auipc	a5,0x1b
    80002c06:	23678793          	addi	a5,a5,566 # 8001de38 <bcache+0x8268>
    80002c0a:	02f48b63          	beq	s1,a5,80002c40 <bread+0x64>
    80002c0e:	873e                	mv	a4,a5
    80002c10:	a021                	j	80002c18 <bread+0x3c>
    80002c12:	68a4                	ld	s1,80(s1)
    80002c14:	02e48663          	beq	s1,a4,80002c40 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002c18:	449c                	lw	a5,8(s1)
    80002c1a:	ff279ce3          	bne	a5,s2,80002c12 <bread+0x36>
    80002c1e:	44dc                	lw	a5,12(s1)
    80002c20:	ff3799e3          	bne	a5,s3,80002c12 <bread+0x36>
      b->refcnt++;
    80002c24:	40bc                	lw	a5,64(s1)
    80002c26:	2785                	addiw	a5,a5,1
    80002c28:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c2a:	00013517          	auipc	a0,0x13
    80002c2e:	fa650513          	addi	a0,a0,-90 # 80015bd0 <bcache>
    80002c32:	834fe0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002c36:	01048513          	addi	a0,s1,16
    80002c3a:	2d4010ef          	jal	80003f0e <acquiresleep>
      return b;
    80002c3e:	a889                	j	80002c90 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c40:	0001b497          	auipc	s1,0x1b
    80002c44:	2404b483          	ld	s1,576(s1) # 8001de80 <bcache+0x82b0>
    80002c48:	0001b797          	auipc	a5,0x1b
    80002c4c:	1f078793          	addi	a5,a5,496 # 8001de38 <bcache+0x8268>
    80002c50:	00f48863          	beq	s1,a5,80002c60 <bread+0x84>
    80002c54:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c56:	40bc                	lw	a5,64(s1)
    80002c58:	cb91                	beqz	a5,80002c6c <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c5a:	64a4                	ld	s1,72(s1)
    80002c5c:	fee49de3          	bne	s1,a4,80002c56 <bread+0x7a>
  panic("bget: no buffers");
    80002c60:	00004517          	auipc	a0,0x4
    80002c64:	74850513          	addi	a0,a0,1864 # 800073a8 <etext+0x3a8>
    80002c68:	b79fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002c6c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c70:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c74:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c78:	4785                	li	a5,1
    80002c7a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c7c:	00013517          	auipc	a0,0x13
    80002c80:	f5450513          	addi	a0,a0,-172 # 80015bd0 <bcache>
    80002c84:	fe3fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002c88:	01048513          	addi	a0,s1,16
    80002c8c:	282010ef          	jal	80003f0e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c90:	409c                	lw	a5,0(s1)
    80002c92:	cb89                	beqz	a5,80002ca4 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c94:	8526                	mv	a0,s1
    80002c96:	70a2                	ld	ra,40(sp)
    80002c98:	7402                	ld	s0,32(sp)
    80002c9a:	64e2                	ld	s1,24(sp)
    80002c9c:	6942                	ld	s2,16(sp)
    80002c9e:	69a2                	ld	s3,8(sp)
    80002ca0:	6145                	addi	sp,sp,48
    80002ca2:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ca4:	4581                	li	a1,0
    80002ca6:	8526                	mv	a0,s1
    80002ca8:	2c9020ef          	jal	80005770 <virtio_disk_rw>
    b->valid = 1;
    80002cac:	4785                	li	a5,1
    80002cae:	c09c                	sw	a5,0(s1)
  return b;
    80002cb0:	b7d5                	j	80002c94 <bread+0xb8>

0000000080002cb2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002cb2:	1101                	addi	sp,sp,-32
    80002cb4:	ec06                	sd	ra,24(sp)
    80002cb6:	e822                	sd	s0,16(sp)
    80002cb8:	e426                	sd	s1,8(sp)
    80002cba:	1000                	addi	s0,sp,32
    80002cbc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cbe:	0541                	addi	a0,a0,16
    80002cc0:	2cc010ef          	jal	80003f8c <holdingsleep>
    80002cc4:	c911                	beqz	a0,80002cd8 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002cc6:	4585                	li	a1,1
    80002cc8:	8526                	mv	a0,s1
    80002cca:	2a7020ef          	jal	80005770 <virtio_disk_rw>
}
    80002cce:	60e2                	ld	ra,24(sp)
    80002cd0:	6442                	ld	s0,16(sp)
    80002cd2:	64a2                	ld	s1,8(sp)
    80002cd4:	6105                	addi	sp,sp,32
    80002cd6:	8082                	ret
    panic("bwrite");
    80002cd8:	00004517          	auipc	a0,0x4
    80002cdc:	6e850513          	addi	a0,a0,1768 # 800073c0 <etext+0x3c0>
    80002ce0:	b01fd0ef          	jal	800007e0 <panic>

0000000080002ce4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ce4:	1101                	addi	sp,sp,-32
    80002ce6:	ec06                	sd	ra,24(sp)
    80002ce8:	e822                	sd	s0,16(sp)
    80002cea:	e426                	sd	s1,8(sp)
    80002cec:	e04a                	sd	s2,0(sp)
    80002cee:	1000                	addi	s0,sp,32
    80002cf0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cf2:	01050913          	addi	s2,a0,16
    80002cf6:	854a                	mv	a0,s2
    80002cf8:	294010ef          	jal	80003f8c <holdingsleep>
    80002cfc:	c135                	beqz	a0,80002d60 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002cfe:	854a                	mv	a0,s2
    80002d00:	254010ef          	jal	80003f54 <releasesleep>

  acquire(&bcache.lock);
    80002d04:	00013517          	auipc	a0,0x13
    80002d08:	ecc50513          	addi	a0,a0,-308 # 80015bd0 <bcache>
    80002d0c:	ec3fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002d10:	40bc                	lw	a5,64(s1)
    80002d12:	37fd                	addiw	a5,a5,-1
    80002d14:	0007871b          	sext.w	a4,a5
    80002d18:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d1a:	e71d                	bnez	a4,80002d48 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d1c:	68b8                	ld	a4,80(s1)
    80002d1e:	64bc                	ld	a5,72(s1)
    80002d20:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d22:	68b8                	ld	a4,80(s1)
    80002d24:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d26:	0001b797          	auipc	a5,0x1b
    80002d2a:	eaa78793          	addi	a5,a5,-342 # 8001dbd0 <bcache+0x8000>
    80002d2e:	2b87b703          	ld	a4,696(a5)
    80002d32:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d34:	0001b717          	auipc	a4,0x1b
    80002d38:	10470713          	addi	a4,a4,260 # 8001de38 <bcache+0x8268>
    80002d3c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d3e:	2b87b703          	ld	a4,696(a5)
    80002d42:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d44:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d48:	00013517          	auipc	a0,0x13
    80002d4c:	e8850513          	addi	a0,a0,-376 # 80015bd0 <bcache>
    80002d50:	f17fd0ef          	jal	80000c66 <release>
}
    80002d54:	60e2                	ld	ra,24(sp)
    80002d56:	6442                	ld	s0,16(sp)
    80002d58:	64a2                	ld	s1,8(sp)
    80002d5a:	6902                	ld	s2,0(sp)
    80002d5c:	6105                	addi	sp,sp,32
    80002d5e:	8082                	ret
    panic("brelse");
    80002d60:	00004517          	auipc	a0,0x4
    80002d64:	66850513          	addi	a0,a0,1640 # 800073c8 <etext+0x3c8>
    80002d68:	a79fd0ef          	jal	800007e0 <panic>

0000000080002d6c <bpin>:

void
bpin(struct buf *b) {
    80002d6c:	1101                	addi	sp,sp,-32
    80002d6e:	ec06                	sd	ra,24(sp)
    80002d70:	e822                	sd	s0,16(sp)
    80002d72:	e426                	sd	s1,8(sp)
    80002d74:	1000                	addi	s0,sp,32
    80002d76:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d78:	00013517          	auipc	a0,0x13
    80002d7c:	e5850513          	addi	a0,a0,-424 # 80015bd0 <bcache>
    80002d80:	e4ffd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002d84:	40bc                	lw	a5,64(s1)
    80002d86:	2785                	addiw	a5,a5,1
    80002d88:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d8a:	00013517          	auipc	a0,0x13
    80002d8e:	e4650513          	addi	a0,a0,-442 # 80015bd0 <bcache>
    80002d92:	ed5fd0ef          	jal	80000c66 <release>
}
    80002d96:	60e2                	ld	ra,24(sp)
    80002d98:	6442                	ld	s0,16(sp)
    80002d9a:	64a2                	ld	s1,8(sp)
    80002d9c:	6105                	addi	sp,sp,32
    80002d9e:	8082                	ret

0000000080002da0 <bunpin>:

void
bunpin(struct buf *b) {
    80002da0:	1101                	addi	sp,sp,-32
    80002da2:	ec06                	sd	ra,24(sp)
    80002da4:	e822                	sd	s0,16(sp)
    80002da6:	e426                	sd	s1,8(sp)
    80002da8:	1000                	addi	s0,sp,32
    80002daa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dac:	00013517          	auipc	a0,0x13
    80002db0:	e2450513          	addi	a0,a0,-476 # 80015bd0 <bcache>
    80002db4:	e1bfd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002db8:	40bc                	lw	a5,64(s1)
    80002dba:	37fd                	addiw	a5,a5,-1
    80002dbc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dbe:	00013517          	auipc	a0,0x13
    80002dc2:	e1250513          	addi	a0,a0,-494 # 80015bd0 <bcache>
    80002dc6:	ea1fd0ef          	jal	80000c66 <release>
}
    80002dca:	60e2                	ld	ra,24(sp)
    80002dcc:	6442                	ld	s0,16(sp)
    80002dce:	64a2                	ld	s1,8(sp)
    80002dd0:	6105                	addi	sp,sp,32
    80002dd2:	8082                	ret

0000000080002dd4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002dd4:	1101                	addi	sp,sp,-32
    80002dd6:	ec06                	sd	ra,24(sp)
    80002dd8:	e822                	sd	s0,16(sp)
    80002dda:	e426                	sd	s1,8(sp)
    80002ddc:	e04a                	sd	s2,0(sp)
    80002dde:	1000                	addi	s0,sp,32
    80002de0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002de2:	00d5d59b          	srliw	a1,a1,0xd
    80002de6:	0001b797          	auipc	a5,0x1b
    80002dea:	4c67a783          	lw	a5,1222(a5) # 8001e2ac <sb+0x1c>
    80002dee:	9dbd                	addw	a1,a1,a5
    80002df0:	dedff0ef          	jal	80002bdc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002df4:	0074f713          	andi	a4,s1,7
    80002df8:	4785                	li	a5,1
    80002dfa:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002dfe:	14ce                	slli	s1,s1,0x33
    80002e00:	90d9                	srli	s1,s1,0x36
    80002e02:	00950733          	add	a4,a0,s1
    80002e06:	05874703          	lbu	a4,88(a4)
    80002e0a:	00e7f6b3          	and	a3,a5,a4
    80002e0e:	c29d                	beqz	a3,80002e34 <bfree+0x60>
    80002e10:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e12:	94aa                	add	s1,s1,a0
    80002e14:	fff7c793          	not	a5,a5
    80002e18:	8f7d                	and	a4,a4,a5
    80002e1a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e1e:	7f9000ef          	jal	80003e16 <log_write>
  brelse(bp);
    80002e22:	854a                	mv	a0,s2
    80002e24:	ec1ff0ef          	jal	80002ce4 <brelse>
}
    80002e28:	60e2                	ld	ra,24(sp)
    80002e2a:	6442                	ld	s0,16(sp)
    80002e2c:	64a2                	ld	s1,8(sp)
    80002e2e:	6902                	ld	s2,0(sp)
    80002e30:	6105                	addi	sp,sp,32
    80002e32:	8082                	ret
    panic("freeing free block");
    80002e34:	00004517          	auipc	a0,0x4
    80002e38:	59c50513          	addi	a0,a0,1436 # 800073d0 <etext+0x3d0>
    80002e3c:	9a5fd0ef          	jal	800007e0 <panic>

0000000080002e40 <balloc>:
{
    80002e40:	711d                	addi	sp,sp,-96
    80002e42:	ec86                	sd	ra,88(sp)
    80002e44:	e8a2                	sd	s0,80(sp)
    80002e46:	e4a6                	sd	s1,72(sp)
    80002e48:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002e4a:	0001b797          	auipc	a5,0x1b
    80002e4e:	44a7a783          	lw	a5,1098(a5) # 8001e294 <sb+0x4>
    80002e52:	0e078f63          	beqz	a5,80002f50 <balloc+0x110>
    80002e56:	e0ca                	sd	s2,64(sp)
    80002e58:	fc4e                	sd	s3,56(sp)
    80002e5a:	f852                	sd	s4,48(sp)
    80002e5c:	f456                	sd	s5,40(sp)
    80002e5e:	f05a                	sd	s6,32(sp)
    80002e60:	ec5e                	sd	s7,24(sp)
    80002e62:	e862                	sd	s8,16(sp)
    80002e64:	e466                	sd	s9,8(sp)
    80002e66:	8baa                	mv	s7,a0
    80002e68:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e6a:	0001bb17          	auipc	s6,0x1b
    80002e6e:	426b0b13          	addi	s6,s6,1062 # 8001e290 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e72:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002e74:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e76:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e78:	6c89                	lui	s9,0x2
    80002e7a:	a0b5                	j	80002ee6 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e7c:	97ca                	add	a5,a5,s2
    80002e7e:	8e55                	or	a2,a2,a3
    80002e80:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e84:	854a                	mv	a0,s2
    80002e86:	791000ef          	jal	80003e16 <log_write>
        brelse(bp);
    80002e8a:	854a                	mv	a0,s2
    80002e8c:	e59ff0ef          	jal	80002ce4 <brelse>
  bp = bread(dev, bno);
    80002e90:	85a6                	mv	a1,s1
    80002e92:	855e                	mv	a0,s7
    80002e94:	d49ff0ef          	jal	80002bdc <bread>
    80002e98:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e9a:	40000613          	li	a2,1024
    80002e9e:	4581                	li	a1,0
    80002ea0:	05850513          	addi	a0,a0,88
    80002ea4:	dfffd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80002ea8:	854a                	mv	a0,s2
    80002eaa:	76d000ef          	jal	80003e16 <log_write>
  brelse(bp);
    80002eae:	854a                	mv	a0,s2
    80002eb0:	e35ff0ef          	jal	80002ce4 <brelse>
}
    80002eb4:	6906                	ld	s2,64(sp)
    80002eb6:	79e2                	ld	s3,56(sp)
    80002eb8:	7a42                	ld	s4,48(sp)
    80002eba:	7aa2                	ld	s5,40(sp)
    80002ebc:	7b02                	ld	s6,32(sp)
    80002ebe:	6be2                	ld	s7,24(sp)
    80002ec0:	6c42                	ld	s8,16(sp)
    80002ec2:	6ca2                	ld	s9,8(sp)
}
    80002ec4:	8526                	mv	a0,s1
    80002ec6:	60e6                	ld	ra,88(sp)
    80002ec8:	6446                	ld	s0,80(sp)
    80002eca:	64a6                	ld	s1,72(sp)
    80002ecc:	6125                	addi	sp,sp,96
    80002ece:	8082                	ret
    brelse(bp);
    80002ed0:	854a                	mv	a0,s2
    80002ed2:	e13ff0ef          	jal	80002ce4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002ed6:	015c87bb          	addw	a5,s9,s5
    80002eda:	00078a9b          	sext.w	s5,a5
    80002ede:	004b2703          	lw	a4,4(s6)
    80002ee2:	04eaff63          	bgeu	s5,a4,80002f40 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002ee6:	41fad79b          	sraiw	a5,s5,0x1f
    80002eea:	0137d79b          	srliw	a5,a5,0x13
    80002eee:	015787bb          	addw	a5,a5,s5
    80002ef2:	40d7d79b          	sraiw	a5,a5,0xd
    80002ef6:	01cb2583          	lw	a1,28(s6)
    80002efa:	9dbd                	addw	a1,a1,a5
    80002efc:	855e                	mv	a0,s7
    80002efe:	cdfff0ef          	jal	80002bdc <bread>
    80002f02:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f04:	004b2503          	lw	a0,4(s6)
    80002f08:	000a849b          	sext.w	s1,s5
    80002f0c:	8762                	mv	a4,s8
    80002f0e:	fca4f1e3          	bgeu	s1,a0,80002ed0 <balloc+0x90>
      m = 1 << (bi % 8);
    80002f12:	00777693          	andi	a3,a4,7
    80002f16:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f1a:	41f7579b          	sraiw	a5,a4,0x1f
    80002f1e:	01d7d79b          	srliw	a5,a5,0x1d
    80002f22:	9fb9                	addw	a5,a5,a4
    80002f24:	4037d79b          	sraiw	a5,a5,0x3
    80002f28:	00f90633          	add	a2,s2,a5
    80002f2c:	05864603          	lbu	a2,88(a2)
    80002f30:	00c6f5b3          	and	a1,a3,a2
    80002f34:	d5a1                	beqz	a1,80002e7c <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f36:	2705                	addiw	a4,a4,1
    80002f38:	2485                	addiw	s1,s1,1
    80002f3a:	fd471ae3          	bne	a4,s4,80002f0e <balloc+0xce>
    80002f3e:	bf49                	j	80002ed0 <balloc+0x90>
    80002f40:	6906                	ld	s2,64(sp)
    80002f42:	79e2                	ld	s3,56(sp)
    80002f44:	7a42                	ld	s4,48(sp)
    80002f46:	7aa2                	ld	s5,40(sp)
    80002f48:	7b02                	ld	s6,32(sp)
    80002f4a:	6be2                	ld	s7,24(sp)
    80002f4c:	6c42                	ld	s8,16(sp)
    80002f4e:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002f50:	00004517          	auipc	a0,0x4
    80002f54:	49850513          	addi	a0,a0,1176 # 800073e8 <etext+0x3e8>
    80002f58:	da2fd0ef          	jal	800004fa <printf>
  return 0;
    80002f5c:	4481                	li	s1,0
    80002f5e:	b79d                	j	80002ec4 <balloc+0x84>

0000000080002f60 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f60:	7179                	addi	sp,sp,-48
    80002f62:	f406                	sd	ra,40(sp)
    80002f64:	f022                	sd	s0,32(sp)
    80002f66:	ec26                	sd	s1,24(sp)
    80002f68:	e84a                	sd	s2,16(sp)
    80002f6a:	e44e                	sd	s3,8(sp)
    80002f6c:	1800                	addi	s0,sp,48
    80002f6e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f70:	47ad                	li	a5,11
    80002f72:	02b7e663          	bltu	a5,a1,80002f9e <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002f76:	02059793          	slli	a5,a1,0x20
    80002f7a:	01e7d593          	srli	a1,a5,0x1e
    80002f7e:	00b504b3          	add	s1,a0,a1
    80002f82:	0504a903          	lw	s2,80(s1)
    80002f86:	06091a63          	bnez	s2,80002ffa <bmap+0x9a>
      addr = balloc(ip->dev);
    80002f8a:	4108                	lw	a0,0(a0)
    80002f8c:	eb5ff0ef          	jal	80002e40 <balloc>
    80002f90:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f94:	06090363          	beqz	s2,80002ffa <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002f98:	0524a823          	sw	s2,80(s1)
    80002f9c:	a8b9                	j	80002ffa <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f9e:	ff45849b          	addiw	s1,a1,-12
    80002fa2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002fa6:	0ff00793          	li	a5,255
    80002faa:	06e7ee63          	bltu	a5,a4,80003026 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002fae:	08052903          	lw	s2,128(a0)
    80002fb2:	00091d63          	bnez	s2,80002fcc <bmap+0x6c>
      addr = balloc(ip->dev);
    80002fb6:	4108                	lw	a0,0(a0)
    80002fb8:	e89ff0ef          	jal	80002e40 <balloc>
    80002fbc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002fc0:	02090d63          	beqz	s2,80002ffa <bmap+0x9a>
    80002fc4:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fc6:	0929a023          	sw	s2,128(s3)
    80002fca:	a011                	j	80002fce <bmap+0x6e>
    80002fcc:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fce:	85ca                	mv	a1,s2
    80002fd0:	0009a503          	lw	a0,0(s3)
    80002fd4:	c09ff0ef          	jal	80002bdc <bread>
    80002fd8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002fda:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002fde:	02049713          	slli	a4,s1,0x20
    80002fe2:	01e75593          	srli	a1,a4,0x1e
    80002fe6:	00b784b3          	add	s1,a5,a1
    80002fea:	0004a903          	lw	s2,0(s1)
    80002fee:	00090e63          	beqz	s2,8000300a <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002ff2:	8552                	mv	a0,s4
    80002ff4:	cf1ff0ef          	jal	80002ce4 <brelse>
    return addr;
    80002ff8:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002ffa:	854a                	mv	a0,s2
    80002ffc:	70a2                	ld	ra,40(sp)
    80002ffe:	7402                	ld	s0,32(sp)
    80003000:	64e2                	ld	s1,24(sp)
    80003002:	6942                	ld	s2,16(sp)
    80003004:	69a2                	ld	s3,8(sp)
    80003006:	6145                	addi	sp,sp,48
    80003008:	8082                	ret
      addr = balloc(ip->dev);
    8000300a:	0009a503          	lw	a0,0(s3)
    8000300e:	e33ff0ef          	jal	80002e40 <balloc>
    80003012:	0005091b          	sext.w	s2,a0
      if(addr){
    80003016:	fc090ee3          	beqz	s2,80002ff2 <bmap+0x92>
        a[bn] = addr;
    8000301a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000301e:	8552                	mv	a0,s4
    80003020:	5f7000ef          	jal	80003e16 <log_write>
    80003024:	b7f9                	j	80002ff2 <bmap+0x92>
    80003026:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003028:	00004517          	auipc	a0,0x4
    8000302c:	3d850513          	addi	a0,a0,984 # 80007400 <etext+0x400>
    80003030:	fb0fd0ef          	jal	800007e0 <panic>

0000000080003034 <iget>:
{
    80003034:	7179                	addi	sp,sp,-48
    80003036:	f406                	sd	ra,40(sp)
    80003038:	f022                	sd	s0,32(sp)
    8000303a:	ec26                	sd	s1,24(sp)
    8000303c:	e84a                	sd	s2,16(sp)
    8000303e:	e44e                	sd	s3,8(sp)
    80003040:	e052                	sd	s4,0(sp)
    80003042:	1800                	addi	s0,sp,48
    80003044:	89aa                	mv	s3,a0
    80003046:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003048:	0001b517          	auipc	a0,0x1b
    8000304c:	26850513          	addi	a0,a0,616 # 8001e2b0 <itable>
    80003050:	b7ffd0ef          	jal	80000bce <acquire>
  empty = 0;
    80003054:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003056:	0001b497          	auipc	s1,0x1b
    8000305a:	27248493          	addi	s1,s1,626 # 8001e2c8 <itable+0x18>
    8000305e:	0001d697          	auipc	a3,0x1d
    80003062:	cfa68693          	addi	a3,a3,-774 # 8001fd58 <log>
    80003066:	a039                	j	80003074 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003068:	02090963          	beqz	s2,8000309a <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000306c:	08848493          	addi	s1,s1,136
    80003070:	02d48863          	beq	s1,a3,800030a0 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003074:	449c                	lw	a5,8(s1)
    80003076:	fef059e3          	blez	a5,80003068 <iget+0x34>
    8000307a:	4098                	lw	a4,0(s1)
    8000307c:	ff3716e3          	bne	a4,s3,80003068 <iget+0x34>
    80003080:	40d8                	lw	a4,4(s1)
    80003082:	ff4713e3          	bne	a4,s4,80003068 <iget+0x34>
      ip->ref++;
    80003086:	2785                	addiw	a5,a5,1
    80003088:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000308a:	0001b517          	auipc	a0,0x1b
    8000308e:	22650513          	addi	a0,a0,550 # 8001e2b0 <itable>
    80003092:	bd5fd0ef          	jal	80000c66 <release>
      return ip;
    80003096:	8926                	mv	s2,s1
    80003098:	a02d                	j	800030c2 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000309a:	fbe9                	bnez	a5,8000306c <iget+0x38>
      empty = ip;
    8000309c:	8926                	mv	s2,s1
    8000309e:	b7f9                	j	8000306c <iget+0x38>
  if(empty == 0)
    800030a0:	02090a63          	beqz	s2,800030d4 <iget+0xa0>
  ip->dev = dev;
    800030a4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800030a8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800030ac:	4785                	li	a5,1
    800030ae:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800030b2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800030b6:	0001b517          	auipc	a0,0x1b
    800030ba:	1fa50513          	addi	a0,a0,506 # 8001e2b0 <itable>
    800030be:	ba9fd0ef          	jal	80000c66 <release>
}
    800030c2:	854a                	mv	a0,s2
    800030c4:	70a2                	ld	ra,40(sp)
    800030c6:	7402                	ld	s0,32(sp)
    800030c8:	64e2                	ld	s1,24(sp)
    800030ca:	6942                	ld	s2,16(sp)
    800030cc:	69a2                	ld	s3,8(sp)
    800030ce:	6a02                	ld	s4,0(sp)
    800030d0:	6145                	addi	sp,sp,48
    800030d2:	8082                	ret
    panic("iget: no inodes");
    800030d4:	00004517          	auipc	a0,0x4
    800030d8:	34450513          	addi	a0,a0,836 # 80007418 <etext+0x418>
    800030dc:	f04fd0ef          	jal	800007e0 <panic>

00000000800030e0 <iinit>:
{
    800030e0:	7179                	addi	sp,sp,-48
    800030e2:	f406                	sd	ra,40(sp)
    800030e4:	f022                	sd	s0,32(sp)
    800030e6:	ec26                	sd	s1,24(sp)
    800030e8:	e84a                	sd	s2,16(sp)
    800030ea:	e44e                	sd	s3,8(sp)
    800030ec:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030ee:	00004597          	auipc	a1,0x4
    800030f2:	33a58593          	addi	a1,a1,826 # 80007428 <etext+0x428>
    800030f6:	0001b517          	auipc	a0,0x1b
    800030fa:	1ba50513          	addi	a0,a0,442 # 8001e2b0 <itable>
    800030fe:	a51fd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003102:	0001b497          	auipc	s1,0x1b
    80003106:	1d648493          	addi	s1,s1,470 # 8001e2d8 <itable+0x28>
    8000310a:	0001d997          	auipc	s3,0x1d
    8000310e:	c5e98993          	addi	s3,s3,-930 # 8001fd68 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003112:	00004917          	auipc	s2,0x4
    80003116:	31e90913          	addi	s2,s2,798 # 80007430 <etext+0x430>
    8000311a:	85ca                	mv	a1,s2
    8000311c:	8526                	mv	a0,s1
    8000311e:	5bb000ef          	jal	80003ed8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003122:	08848493          	addi	s1,s1,136
    80003126:	ff349ae3          	bne	s1,s3,8000311a <iinit+0x3a>
}
    8000312a:	70a2                	ld	ra,40(sp)
    8000312c:	7402                	ld	s0,32(sp)
    8000312e:	64e2                	ld	s1,24(sp)
    80003130:	6942                	ld	s2,16(sp)
    80003132:	69a2                	ld	s3,8(sp)
    80003134:	6145                	addi	sp,sp,48
    80003136:	8082                	ret

0000000080003138 <ialloc>:
{
    80003138:	7139                	addi	sp,sp,-64
    8000313a:	fc06                	sd	ra,56(sp)
    8000313c:	f822                	sd	s0,48(sp)
    8000313e:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003140:	0001b717          	auipc	a4,0x1b
    80003144:	15c72703          	lw	a4,348(a4) # 8001e29c <sb+0xc>
    80003148:	4785                	li	a5,1
    8000314a:	06e7f063          	bgeu	a5,a4,800031aa <ialloc+0x72>
    8000314e:	f426                	sd	s1,40(sp)
    80003150:	f04a                	sd	s2,32(sp)
    80003152:	ec4e                	sd	s3,24(sp)
    80003154:	e852                	sd	s4,16(sp)
    80003156:	e456                	sd	s5,8(sp)
    80003158:	e05a                	sd	s6,0(sp)
    8000315a:	8aaa                	mv	s5,a0
    8000315c:	8b2e                	mv	s6,a1
    8000315e:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003160:	0001ba17          	auipc	s4,0x1b
    80003164:	130a0a13          	addi	s4,s4,304 # 8001e290 <sb>
    80003168:	00495593          	srli	a1,s2,0x4
    8000316c:	018a2783          	lw	a5,24(s4)
    80003170:	9dbd                	addw	a1,a1,a5
    80003172:	8556                	mv	a0,s5
    80003174:	a69ff0ef          	jal	80002bdc <bread>
    80003178:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000317a:	05850993          	addi	s3,a0,88
    8000317e:	00f97793          	andi	a5,s2,15
    80003182:	079a                	slli	a5,a5,0x6
    80003184:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003186:	00099783          	lh	a5,0(s3)
    8000318a:	cb9d                	beqz	a5,800031c0 <ialloc+0x88>
    brelse(bp);
    8000318c:	b59ff0ef          	jal	80002ce4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003190:	0905                	addi	s2,s2,1
    80003192:	00ca2703          	lw	a4,12(s4)
    80003196:	0009079b          	sext.w	a5,s2
    8000319a:	fce7e7e3          	bltu	a5,a4,80003168 <ialloc+0x30>
    8000319e:	74a2                	ld	s1,40(sp)
    800031a0:	7902                	ld	s2,32(sp)
    800031a2:	69e2                	ld	s3,24(sp)
    800031a4:	6a42                	ld	s4,16(sp)
    800031a6:	6aa2                	ld	s5,8(sp)
    800031a8:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800031aa:	00004517          	auipc	a0,0x4
    800031ae:	28e50513          	addi	a0,a0,654 # 80007438 <etext+0x438>
    800031b2:	b48fd0ef          	jal	800004fa <printf>
  return 0;
    800031b6:	4501                	li	a0,0
}
    800031b8:	70e2                	ld	ra,56(sp)
    800031ba:	7442                	ld	s0,48(sp)
    800031bc:	6121                	addi	sp,sp,64
    800031be:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031c0:	04000613          	li	a2,64
    800031c4:	4581                	li	a1,0
    800031c6:	854e                	mv	a0,s3
    800031c8:	adbfd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    800031cc:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800031d0:	8526                	mv	a0,s1
    800031d2:	445000ef          	jal	80003e16 <log_write>
      brelse(bp);
    800031d6:	8526                	mv	a0,s1
    800031d8:	b0dff0ef          	jal	80002ce4 <brelse>
      return iget(dev, inum);
    800031dc:	0009059b          	sext.w	a1,s2
    800031e0:	8556                	mv	a0,s5
    800031e2:	e53ff0ef          	jal	80003034 <iget>
    800031e6:	74a2                	ld	s1,40(sp)
    800031e8:	7902                	ld	s2,32(sp)
    800031ea:	69e2                	ld	s3,24(sp)
    800031ec:	6a42                	ld	s4,16(sp)
    800031ee:	6aa2                	ld	s5,8(sp)
    800031f0:	6b02                	ld	s6,0(sp)
    800031f2:	b7d9                	j	800031b8 <ialloc+0x80>

00000000800031f4 <iupdate>:
{
    800031f4:	1101                	addi	sp,sp,-32
    800031f6:	ec06                	sd	ra,24(sp)
    800031f8:	e822                	sd	s0,16(sp)
    800031fa:	e426                	sd	s1,8(sp)
    800031fc:	e04a                	sd	s2,0(sp)
    800031fe:	1000                	addi	s0,sp,32
    80003200:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003202:	415c                	lw	a5,4(a0)
    80003204:	0047d79b          	srliw	a5,a5,0x4
    80003208:	0001b597          	auipc	a1,0x1b
    8000320c:	0a05a583          	lw	a1,160(a1) # 8001e2a8 <sb+0x18>
    80003210:	9dbd                	addw	a1,a1,a5
    80003212:	4108                	lw	a0,0(a0)
    80003214:	9c9ff0ef          	jal	80002bdc <bread>
    80003218:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000321a:	05850793          	addi	a5,a0,88
    8000321e:	40d8                	lw	a4,4(s1)
    80003220:	8b3d                	andi	a4,a4,15
    80003222:	071a                	slli	a4,a4,0x6
    80003224:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003226:	04449703          	lh	a4,68(s1)
    8000322a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000322e:	04649703          	lh	a4,70(s1)
    80003232:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003236:	04849703          	lh	a4,72(s1)
    8000323a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000323e:	04a49703          	lh	a4,74(s1)
    80003242:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003246:	44f8                	lw	a4,76(s1)
    80003248:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000324a:	03400613          	li	a2,52
    8000324e:	05048593          	addi	a1,s1,80
    80003252:	00c78513          	addi	a0,a5,12
    80003256:	aa9fd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    8000325a:	854a                	mv	a0,s2
    8000325c:	3bb000ef          	jal	80003e16 <log_write>
  brelse(bp);
    80003260:	854a                	mv	a0,s2
    80003262:	a83ff0ef          	jal	80002ce4 <brelse>
}
    80003266:	60e2                	ld	ra,24(sp)
    80003268:	6442                	ld	s0,16(sp)
    8000326a:	64a2                	ld	s1,8(sp)
    8000326c:	6902                	ld	s2,0(sp)
    8000326e:	6105                	addi	sp,sp,32
    80003270:	8082                	ret

0000000080003272 <idup>:
{
    80003272:	1101                	addi	sp,sp,-32
    80003274:	ec06                	sd	ra,24(sp)
    80003276:	e822                	sd	s0,16(sp)
    80003278:	e426                	sd	s1,8(sp)
    8000327a:	1000                	addi	s0,sp,32
    8000327c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000327e:	0001b517          	auipc	a0,0x1b
    80003282:	03250513          	addi	a0,a0,50 # 8001e2b0 <itable>
    80003286:	949fd0ef          	jal	80000bce <acquire>
  ip->ref++;
    8000328a:	449c                	lw	a5,8(s1)
    8000328c:	2785                	addiw	a5,a5,1
    8000328e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003290:	0001b517          	auipc	a0,0x1b
    80003294:	02050513          	addi	a0,a0,32 # 8001e2b0 <itable>
    80003298:	9cffd0ef          	jal	80000c66 <release>
}
    8000329c:	8526                	mv	a0,s1
    8000329e:	60e2                	ld	ra,24(sp)
    800032a0:	6442                	ld	s0,16(sp)
    800032a2:	64a2                	ld	s1,8(sp)
    800032a4:	6105                	addi	sp,sp,32
    800032a6:	8082                	ret

00000000800032a8 <ilock>:
{
    800032a8:	1101                	addi	sp,sp,-32
    800032aa:	ec06                	sd	ra,24(sp)
    800032ac:	e822                	sd	s0,16(sp)
    800032ae:	e426                	sd	s1,8(sp)
    800032b0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800032b2:	cd19                	beqz	a0,800032d0 <ilock+0x28>
    800032b4:	84aa                	mv	s1,a0
    800032b6:	451c                	lw	a5,8(a0)
    800032b8:	00f05c63          	blez	a5,800032d0 <ilock+0x28>
  acquiresleep(&ip->lock);
    800032bc:	0541                	addi	a0,a0,16
    800032be:	451000ef          	jal	80003f0e <acquiresleep>
  if(ip->valid == 0){
    800032c2:	40bc                	lw	a5,64(s1)
    800032c4:	cf89                	beqz	a5,800032de <ilock+0x36>
}
    800032c6:	60e2                	ld	ra,24(sp)
    800032c8:	6442                	ld	s0,16(sp)
    800032ca:	64a2                	ld	s1,8(sp)
    800032cc:	6105                	addi	sp,sp,32
    800032ce:	8082                	ret
    800032d0:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032d2:	00004517          	auipc	a0,0x4
    800032d6:	17e50513          	addi	a0,a0,382 # 80007450 <etext+0x450>
    800032da:	d06fd0ef          	jal	800007e0 <panic>
    800032de:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032e0:	40dc                	lw	a5,4(s1)
    800032e2:	0047d79b          	srliw	a5,a5,0x4
    800032e6:	0001b597          	auipc	a1,0x1b
    800032ea:	fc25a583          	lw	a1,-62(a1) # 8001e2a8 <sb+0x18>
    800032ee:	9dbd                	addw	a1,a1,a5
    800032f0:	4088                	lw	a0,0(s1)
    800032f2:	8ebff0ef          	jal	80002bdc <bread>
    800032f6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032f8:	05850593          	addi	a1,a0,88
    800032fc:	40dc                	lw	a5,4(s1)
    800032fe:	8bbd                	andi	a5,a5,15
    80003300:	079a                	slli	a5,a5,0x6
    80003302:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003304:	00059783          	lh	a5,0(a1)
    80003308:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000330c:	00259783          	lh	a5,2(a1)
    80003310:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003314:	00459783          	lh	a5,4(a1)
    80003318:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000331c:	00659783          	lh	a5,6(a1)
    80003320:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003324:	459c                	lw	a5,8(a1)
    80003326:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003328:	03400613          	li	a2,52
    8000332c:	05b1                	addi	a1,a1,12
    8000332e:	05048513          	addi	a0,s1,80
    80003332:	9cdfd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    80003336:	854a                	mv	a0,s2
    80003338:	9adff0ef          	jal	80002ce4 <brelse>
    ip->valid = 1;
    8000333c:	4785                	li	a5,1
    8000333e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003340:	04449783          	lh	a5,68(s1)
    80003344:	c399                	beqz	a5,8000334a <ilock+0xa2>
    80003346:	6902                	ld	s2,0(sp)
    80003348:	bfbd                	j	800032c6 <ilock+0x1e>
      panic("ilock: no type");
    8000334a:	00004517          	auipc	a0,0x4
    8000334e:	10e50513          	addi	a0,a0,270 # 80007458 <etext+0x458>
    80003352:	c8efd0ef          	jal	800007e0 <panic>

0000000080003356 <iunlock>:
{
    80003356:	1101                	addi	sp,sp,-32
    80003358:	ec06                	sd	ra,24(sp)
    8000335a:	e822                	sd	s0,16(sp)
    8000335c:	e426                	sd	s1,8(sp)
    8000335e:	e04a                	sd	s2,0(sp)
    80003360:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003362:	c505                	beqz	a0,8000338a <iunlock+0x34>
    80003364:	84aa                	mv	s1,a0
    80003366:	01050913          	addi	s2,a0,16
    8000336a:	854a                	mv	a0,s2
    8000336c:	421000ef          	jal	80003f8c <holdingsleep>
    80003370:	cd09                	beqz	a0,8000338a <iunlock+0x34>
    80003372:	449c                	lw	a5,8(s1)
    80003374:	00f05b63          	blez	a5,8000338a <iunlock+0x34>
  releasesleep(&ip->lock);
    80003378:	854a                	mv	a0,s2
    8000337a:	3db000ef          	jal	80003f54 <releasesleep>
}
    8000337e:	60e2                	ld	ra,24(sp)
    80003380:	6442                	ld	s0,16(sp)
    80003382:	64a2                	ld	s1,8(sp)
    80003384:	6902                	ld	s2,0(sp)
    80003386:	6105                	addi	sp,sp,32
    80003388:	8082                	ret
    panic("iunlock");
    8000338a:	00004517          	auipc	a0,0x4
    8000338e:	0de50513          	addi	a0,a0,222 # 80007468 <etext+0x468>
    80003392:	c4efd0ef          	jal	800007e0 <panic>

0000000080003396 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003396:	7179                	addi	sp,sp,-48
    80003398:	f406                	sd	ra,40(sp)
    8000339a:	f022                	sd	s0,32(sp)
    8000339c:	ec26                	sd	s1,24(sp)
    8000339e:	e84a                	sd	s2,16(sp)
    800033a0:	e44e                	sd	s3,8(sp)
    800033a2:	1800                	addi	s0,sp,48
    800033a4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033a6:	05050493          	addi	s1,a0,80
    800033aa:	08050913          	addi	s2,a0,128
    800033ae:	a021                	j	800033b6 <itrunc+0x20>
    800033b0:	0491                	addi	s1,s1,4
    800033b2:	01248b63          	beq	s1,s2,800033c8 <itrunc+0x32>
    if(ip->addrs[i]){
    800033b6:	408c                	lw	a1,0(s1)
    800033b8:	dde5                	beqz	a1,800033b0 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033ba:	0009a503          	lw	a0,0(s3)
    800033be:	a17ff0ef          	jal	80002dd4 <bfree>
      ip->addrs[i] = 0;
    800033c2:	0004a023          	sw	zero,0(s1)
    800033c6:	b7ed                	j	800033b0 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800033c8:	0809a583          	lw	a1,128(s3)
    800033cc:	ed89                	bnez	a1,800033e6 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033ce:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033d2:	854e                	mv	a0,s3
    800033d4:	e21ff0ef          	jal	800031f4 <iupdate>
}
    800033d8:	70a2                	ld	ra,40(sp)
    800033da:	7402                	ld	s0,32(sp)
    800033dc:	64e2                	ld	s1,24(sp)
    800033de:	6942                	ld	s2,16(sp)
    800033e0:	69a2                	ld	s3,8(sp)
    800033e2:	6145                	addi	sp,sp,48
    800033e4:	8082                	ret
    800033e6:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800033e8:	0009a503          	lw	a0,0(s3)
    800033ec:	ff0ff0ef          	jal	80002bdc <bread>
    800033f0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800033f2:	05850493          	addi	s1,a0,88
    800033f6:	45850913          	addi	s2,a0,1112
    800033fa:	a021                	j	80003402 <itrunc+0x6c>
    800033fc:	0491                	addi	s1,s1,4
    800033fe:	01248963          	beq	s1,s2,80003410 <itrunc+0x7a>
      if(a[j])
    80003402:	408c                	lw	a1,0(s1)
    80003404:	dde5                	beqz	a1,800033fc <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003406:	0009a503          	lw	a0,0(s3)
    8000340a:	9cbff0ef          	jal	80002dd4 <bfree>
    8000340e:	b7fd                	j	800033fc <itrunc+0x66>
    brelse(bp);
    80003410:	8552                	mv	a0,s4
    80003412:	8d3ff0ef          	jal	80002ce4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003416:	0809a583          	lw	a1,128(s3)
    8000341a:	0009a503          	lw	a0,0(s3)
    8000341e:	9b7ff0ef          	jal	80002dd4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003422:	0809a023          	sw	zero,128(s3)
    80003426:	6a02                	ld	s4,0(sp)
    80003428:	b75d                	j	800033ce <itrunc+0x38>

000000008000342a <iput>:
{
    8000342a:	1101                	addi	sp,sp,-32
    8000342c:	ec06                	sd	ra,24(sp)
    8000342e:	e822                	sd	s0,16(sp)
    80003430:	e426                	sd	s1,8(sp)
    80003432:	1000                	addi	s0,sp,32
    80003434:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003436:	0001b517          	auipc	a0,0x1b
    8000343a:	e7a50513          	addi	a0,a0,-390 # 8001e2b0 <itable>
    8000343e:	f90fd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003442:	4498                	lw	a4,8(s1)
    80003444:	4785                	li	a5,1
    80003446:	02f70063          	beq	a4,a5,80003466 <iput+0x3c>
  ip->ref--;
    8000344a:	449c                	lw	a5,8(s1)
    8000344c:	37fd                	addiw	a5,a5,-1
    8000344e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003450:	0001b517          	auipc	a0,0x1b
    80003454:	e6050513          	addi	a0,a0,-416 # 8001e2b0 <itable>
    80003458:	80ffd0ef          	jal	80000c66 <release>
}
    8000345c:	60e2                	ld	ra,24(sp)
    8000345e:	6442                	ld	s0,16(sp)
    80003460:	64a2                	ld	s1,8(sp)
    80003462:	6105                	addi	sp,sp,32
    80003464:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003466:	40bc                	lw	a5,64(s1)
    80003468:	d3ed                	beqz	a5,8000344a <iput+0x20>
    8000346a:	04a49783          	lh	a5,74(s1)
    8000346e:	fff1                	bnez	a5,8000344a <iput+0x20>
    80003470:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003472:	01048913          	addi	s2,s1,16
    80003476:	854a                	mv	a0,s2
    80003478:	297000ef          	jal	80003f0e <acquiresleep>
    release(&itable.lock);
    8000347c:	0001b517          	auipc	a0,0x1b
    80003480:	e3450513          	addi	a0,a0,-460 # 8001e2b0 <itable>
    80003484:	fe2fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    80003488:	8526                	mv	a0,s1
    8000348a:	f0dff0ef          	jal	80003396 <itrunc>
    ip->type = 0;
    8000348e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003492:	8526                	mv	a0,s1
    80003494:	d61ff0ef          	jal	800031f4 <iupdate>
    ip->valid = 0;
    80003498:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000349c:	854a                	mv	a0,s2
    8000349e:	2b7000ef          	jal	80003f54 <releasesleep>
    acquire(&itable.lock);
    800034a2:	0001b517          	auipc	a0,0x1b
    800034a6:	e0e50513          	addi	a0,a0,-498 # 8001e2b0 <itable>
    800034aa:	f24fd0ef          	jal	80000bce <acquire>
    800034ae:	6902                	ld	s2,0(sp)
    800034b0:	bf69                	j	8000344a <iput+0x20>

00000000800034b2 <iunlockput>:
{
    800034b2:	1101                	addi	sp,sp,-32
    800034b4:	ec06                	sd	ra,24(sp)
    800034b6:	e822                	sd	s0,16(sp)
    800034b8:	e426                	sd	s1,8(sp)
    800034ba:	1000                	addi	s0,sp,32
    800034bc:	84aa                	mv	s1,a0
  iunlock(ip);
    800034be:	e99ff0ef          	jal	80003356 <iunlock>
  iput(ip);
    800034c2:	8526                	mv	a0,s1
    800034c4:	f67ff0ef          	jal	8000342a <iput>
}
    800034c8:	60e2                	ld	ra,24(sp)
    800034ca:	6442                	ld	s0,16(sp)
    800034cc:	64a2                	ld	s1,8(sp)
    800034ce:	6105                	addi	sp,sp,32
    800034d0:	8082                	ret

00000000800034d2 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034d2:	0001b717          	auipc	a4,0x1b
    800034d6:	dca72703          	lw	a4,-566(a4) # 8001e29c <sb+0xc>
    800034da:	4785                	li	a5,1
    800034dc:	0ae7ff63          	bgeu	a5,a4,8000359a <ireclaim+0xc8>
{
    800034e0:	7139                	addi	sp,sp,-64
    800034e2:	fc06                	sd	ra,56(sp)
    800034e4:	f822                	sd	s0,48(sp)
    800034e6:	f426                	sd	s1,40(sp)
    800034e8:	f04a                	sd	s2,32(sp)
    800034ea:	ec4e                	sd	s3,24(sp)
    800034ec:	e852                	sd	s4,16(sp)
    800034ee:	e456                	sd	s5,8(sp)
    800034f0:	e05a                	sd	s6,0(sp)
    800034f2:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034f4:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034f6:	00050a1b          	sext.w	s4,a0
    800034fa:	0001ba97          	auipc	s5,0x1b
    800034fe:	d96a8a93          	addi	s5,s5,-618 # 8001e290 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003502:	00004b17          	auipc	s6,0x4
    80003506:	f6eb0b13          	addi	s6,s6,-146 # 80007470 <etext+0x470>
    8000350a:	a099                	j	80003550 <ireclaim+0x7e>
    8000350c:	85ce                	mv	a1,s3
    8000350e:	855a                	mv	a0,s6
    80003510:	febfc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003514:	85ce                	mv	a1,s3
    80003516:	8552                	mv	a0,s4
    80003518:	b1dff0ef          	jal	80003034 <iget>
    8000351c:	89aa                	mv	s3,a0
    brelse(bp);
    8000351e:	854a                	mv	a0,s2
    80003520:	fc4ff0ef          	jal	80002ce4 <brelse>
    if (ip) {
    80003524:	00098f63          	beqz	s3,80003542 <ireclaim+0x70>
      begin_op();
    80003528:	76a000ef          	jal	80003c92 <begin_op>
      ilock(ip);
    8000352c:	854e                	mv	a0,s3
    8000352e:	d7bff0ef          	jal	800032a8 <ilock>
      iunlock(ip);
    80003532:	854e                	mv	a0,s3
    80003534:	e23ff0ef          	jal	80003356 <iunlock>
      iput(ip);
    80003538:	854e                	mv	a0,s3
    8000353a:	ef1ff0ef          	jal	8000342a <iput>
      end_op();
    8000353e:	7be000ef          	jal	80003cfc <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003542:	0485                	addi	s1,s1,1
    80003544:	00caa703          	lw	a4,12(s5)
    80003548:	0004879b          	sext.w	a5,s1
    8000354c:	02e7fd63          	bgeu	a5,a4,80003586 <ireclaim+0xb4>
    80003550:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003554:	0044d593          	srli	a1,s1,0x4
    80003558:	018aa783          	lw	a5,24(s5)
    8000355c:	9dbd                	addw	a1,a1,a5
    8000355e:	8552                	mv	a0,s4
    80003560:	e7cff0ef          	jal	80002bdc <bread>
    80003564:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003566:	05850793          	addi	a5,a0,88
    8000356a:	00f9f713          	andi	a4,s3,15
    8000356e:	071a                	slli	a4,a4,0x6
    80003570:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003572:	00079703          	lh	a4,0(a5)
    80003576:	c701                	beqz	a4,8000357e <ireclaim+0xac>
    80003578:	00679783          	lh	a5,6(a5)
    8000357c:	dbc1                	beqz	a5,8000350c <ireclaim+0x3a>
    brelse(bp);
    8000357e:	854a                	mv	a0,s2
    80003580:	f64ff0ef          	jal	80002ce4 <brelse>
    if (ip) {
    80003584:	bf7d                	j	80003542 <ireclaim+0x70>
}
    80003586:	70e2                	ld	ra,56(sp)
    80003588:	7442                	ld	s0,48(sp)
    8000358a:	74a2                	ld	s1,40(sp)
    8000358c:	7902                	ld	s2,32(sp)
    8000358e:	69e2                	ld	s3,24(sp)
    80003590:	6a42                	ld	s4,16(sp)
    80003592:	6aa2                	ld	s5,8(sp)
    80003594:	6b02                	ld	s6,0(sp)
    80003596:	6121                	addi	sp,sp,64
    80003598:	8082                	ret
    8000359a:	8082                	ret

000000008000359c <fsinit>:
fsinit(int dev) {
    8000359c:	7179                	addi	sp,sp,-48
    8000359e:	f406                	sd	ra,40(sp)
    800035a0:	f022                	sd	s0,32(sp)
    800035a2:	ec26                	sd	s1,24(sp)
    800035a4:	e84a                	sd	s2,16(sp)
    800035a6:	e44e                	sd	s3,8(sp)
    800035a8:	1800                	addi	s0,sp,48
    800035aa:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800035ac:	4585                	li	a1,1
    800035ae:	e2eff0ef          	jal	80002bdc <bread>
    800035b2:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035b4:	0001b997          	auipc	s3,0x1b
    800035b8:	cdc98993          	addi	s3,s3,-804 # 8001e290 <sb>
    800035bc:	02000613          	li	a2,32
    800035c0:	05850593          	addi	a1,a0,88
    800035c4:	854e                	mv	a0,s3
    800035c6:	f38fd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    800035ca:	854a                	mv	a0,s2
    800035cc:	f18ff0ef          	jal	80002ce4 <brelse>
  if(sb.magic != FSMAGIC)
    800035d0:	0009a703          	lw	a4,0(s3)
    800035d4:	102037b7          	lui	a5,0x10203
    800035d8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035dc:	02f71363          	bne	a4,a5,80003602 <fsinit+0x66>
  initlog(dev, &sb);
    800035e0:	0001b597          	auipc	a1,0x1b
    800035e4:	cb058593          	addi	a1,a1,-848 # 8001e290 <sb>
    800035e8:	8526                	mv	a0,s1
    800035ea:	62a000ef          	jal	80003c14 <initlog>
  ireclaim(dev);
    800035ee:	8526                	mv	a0,s1
    800035f0:	ee3ff0ef          	jal	800034d2 <ireclaim>
}
    800035f4:	70a2                	ld	ra,40(sp)
    800035f6:	7402                	ld	s0,32(sp)
    800035f8:	64e2                	ld	s1,24(sp)
    800035fa:	6942                	ld	s2,16(sp)
    800035fc:	69a2                	ld	s3,8(sp)
    800035fe:	6145                	addi	sp,sp,48
    80003600:	8082                	ret
    panic("invalid file system");
    80003602:	00004517          	auipc	a0,0x4
    80003606:	e8e50513          	addi	a0,a0,-370 # 80007490 <etext+0x490>
    8000360a:	9d6fd0ef          	jal	800007e0 <panic>

000000008000360e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000360e:	1141                	addi	sp,sp,-16
    80003610:	e422                	sd	s0,8(sp)
    80003612:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003614:	411c                	lw	a5,0(a0)
    80003616:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003618:	415c                	lw	a5,4(a0)
    8000361a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000361c:	04451783          	lh	a5,68(a0)
    80003620:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003624:	04a51783          	lh	a5,74(a0)
    80003628:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000362c:	04c56783          	lwu	a5,76(a0)
    80003630:	e99c                	sd	a5,16(a1)
}
    80003632:	6422                	ld	s0,8(sp)
    80003634:	0141                	addi	sp,sp,16
    80003636:	8082                	ret

0000000080003638 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003638:	457c                	lw	a5,76(a0)
    8000363a:	0ed7eb63          	bltu	a5,a3,80003730 <readi+0xf8>
{
    8000363e:	7159                	addi	sp,sp,-112
    80003640:	f486                	sd	ra,104(sp)
    80003642:	f0a2                	sd	s0,96(sp)
    80003644:	eca6                	sd	s1,88(sp)
    80003646:	e0d2                	sd	s4,64(sp)
    80003648:	fc56                	sd	s5,56(sp)
    8000364a:	f85a                	sd	s6,48(sp)
    8000364c:	f45e                	sd	s7,40(sp)
    8000364e:	1880                	addi	s0,sp,112
    80003650:	8b2a                	mv	s6,a0
    80003652:	8bae                	mv	s7,a1
    80003654:	8a32                	mv	s4,a2
    80003656:	84b6                	mv	s1,a3
    80003658:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000365a:	9f35                	addw	a4,a4,a3
    return 0;
    8000365c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000365e:	0cd76063          	bltu	a4,a3,8000371e <readi+0xe6>
    80003662:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003664:	00e7f463          	bgeu	a5,a4,8000366c <readi+0x34>
    n = ip->size - off;
    80003668:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000366c:	080a8f63          	beqz	s5,8000370a <readi+0xd2>
    80003670:	e8ca                	sd	s2,80(sp)
    80003672:	f062                	sd	s8,32(sp)
    80003674:	ec66                	sd	s9,24(sp)
    80003676:	e86a                	sd	s10,16(sp)
    80003678:	e46e                	sd	s11,8(sp)
    8000367a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000367c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003680:	5c7d                	li	s8,-1
    80003682:	a80d                	j	800036b4 <readi+0x7c>
    80003684:	020d1d93          	slli	s11,s10,0x20
    80003688:	020ddd93          	srli	s11,s11,0x20
    8000368c:	05890613          	addi	a2,s2,88
    80003690:	86ee                	mv	a3,s11
    80003692:	963a                	add	a2,a2,a4
    80003694:	85d2                	mv	a1,s4
    80003696:	855e                	mv	a0,s7
    80003698:	bbdfe0ef          	jal	80002254 <either_copyout>
    8000369c:	05850763          	beq	a0,s8,800036ea <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800036a0:	854a                	mv	a0,s2
    800036a2:	e42ff0ef          	jal	80002ce4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036a6:	013d09bb          	addw	s3,s10,s3
    800036aa:	009d04bb          	addw	s1,s10,s1
    800036ae:	9a6e                	add	s4,s4,s11
    800036b0:	0559f763          	bgeu	s3,s5,800036fe <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800036b4:	00a4d59b          	srliw	a1,s1,0xa
    800036b8:	855a                	mv	a0,s6
    800036ba:	8a7ff0ef          	jal	80002f60 <bmap>
    800036be:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800036c2:	c5b1                	beqz	a1,8000370e <readi+0xd6>
    bp = bread(ip->dev, addr);
    800036c4:	000b2503          	lw	a0,0(s6)
    800036c8:	d14ff0ef          	jal	80002bdc <bread>
    800036cc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036ce:	3ff4f713          	andi	a4,s1,1023
    800036d2:	40ec87bb          	subw	a5,s9,a4
    800036d6:	413a86bb          	subw	a3,s5,s3
    800036da:	8d3e                	mv	s10,a5
    800036dc:	2781                	sext.w	a5,a5
    800036de:	0006861b          	sext.w	a2,a3
    800036e2:	faf671e3          	bgeu	a2,a5,80003684 <readi+0x4c>
    800036e6:	8d36                	mv	s10,a3
    800036e8:	bf71                	j	80003684 <readi+0x4c>
      brelse(bp);
    800036ea:	854a                	mv	a0,s2
    800036ec:	df8ff0ef          	jal	80002ce4 <brelse>
      tot = -1;
    800036f0:	59fd                	li	s3,-1
      break;
    800036f2:	6946                	ld	s2,80(sp)
    800036f4:	7c02                	ld	s8,32(sp)
    800036f6:	6ce2                	ld	s9,24(sp)
    800036f8:	6d42                	ld	s10,16(sp)
    800036fa:	6da2                	ld	s11,8(sp)
    800036fc:	a831                	j	80003718 <readi+0xe0>
    800036fe:	6946                	ld	s2,80(sp)
    80003700:	7c02                	ld	s8,32(sp)
    80003702:	6ce2                	ld	s9,24(sp)
    80003704:	6d42                	ld	s10,16(sp)
    80003706:	6da2                	ld	s11,8(sp)
    80003708:	a801                	j	80003718 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000370a:	89d6                	mv	s3,s5
    8000370c:	a031                	j	80003718 <readi+0xe0>
    8000370e:	6946                	ld	s2,80(sp)
    80003710:	7c02                	ld	s8,32(sp)
    80003712:	6ce2                	ld	s9,24(sp)
    80003714:	6d42                	ld	s10,16(sp)
    80003716:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003718:	0009851b          	sext.w	a0,s3
    8000371c:	69a6                	ld	s3,72(sp)
}
    8000371e:	70a6                	ld	ra,104(sp)
    80003720:	7406                	ld	s0,96(sp)
    80003722:	64e6                	ld	s1,88(sp)
    80003724:	6a06                	ld	s4,64(sp)
    80003726:	7ae2                	ld	s5,56(sp)
    80003728:	7b42                	ld	s6,48(sp)
    8000372a:	7ba2                	ld	s7,40(sp)
    8000372c:	6165                	addi	sp,sp,112
    8000372e:	8082                	ret
    return 0;
    80003730:	4501                	li	a0,0
}
    80003732:	8082                	ret

0000000080003734 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003734:	457c                	lw	a5,76(a0)
    80003736:	10d7e063          	bltu	a5,a3,80003836 <writei+0x102>
{
    8000373a:	7159                	addi	sp,sp,-112
    8000373c:	f486                	sd	ra,104(sp)
    8000373e:	f0a2                	sd	s0,96(sp)
    80003740:	e8ca                	sd	s2,80(sp)
    80003742:	e0d2                	sd	s4,64(sp)
    80003744:	fc56                	sd	s5,56(sp)
    80003746:	f85a                	sd	s6,48(sp)
    80003748:	f45e                	sd	s7,40(sp)
    8000374a:	1880                	addi	s0,sp,112
    8000374c:	8aaa                	mv	s5,a0
    8000374e:	8bae                	mv	s7,a1
    80003750:	8a32                	mv	s4,a2
    80003752:	8936                	mv	s2,a3
    80003754:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003756:	00e687bb          	addw	a5,a3,a4
    8000375a:	0ed7e063          	bltu	a5,a3,8000383a <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000375e:	00043737          	lui	a4,0x43
    80003762:	0cf76e63          	bltu	a4,a5,8000383e <writei+0x10a>
    80003766:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003768:	0a0b0f63          	beqz	s6,80003826 <writei+0xf2>
    8000376c:	eca6                	sd	s1,88(sp)
    8000376e:	f062                	sd	s8,32(sp)
    80003770:	ec66                	sd	s9,24(sp)
    80003772:	e86a                	sd	s10,16(sp)
    80003774:	e46e                	sd	s11,8(sp)
    80003776:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003778:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000377c:	5c7d                	li	s8,-1
    8000377e:	a825                	j	800037b6 <writei+0x82>
    80003780:	020d1d93          	slli	s11,s10,0x20
    80003784:	020ddd93          	srli	s11,s11,0x20
    80003788:	05848513          	addi	a0,s1,88
    8000378c:	86ee                	mv	a3,s11
    8000378e:	8652                	mv	a2,s4
    80003790:	85de                	mv	a1,s7
    80003792:	953a                	add	a0,a0,a4
    80003794:	b0bfe0ef          	jal	8000229e <either_copyin>
    80003798:	05850a63          	beq	a0,s8,800037ec <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000379c:	8526                	mv	a0,s1
    8000379e:	678000ef          	jal	80003e16 <log_write>
    brelse(bp);
    800037a2:	8526                	mv	a0,s1
    800037a4:	d40ff0ef          	jal	80002ce4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037a8:	013d09bb          	addw	s3,s10,s3
    800037ac:	012d093b          	addw	s2,s10,s2
    800037b0:	9a6e                	add	s4,s4,s11
    800037b2:	0569f063          	bgeu	s3,s6,800037f2 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800037b6:	00a9559b          	srliw	a1,s2,0xa
    800037ba:	8556                	mv	a0,s5
    800037bc:	fa4ff0ef          	jal	80002f60 <bmap>
    800037c0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800037c4:	c59d                	beqz	a1,800037f2 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800037c6:	000aa503          	lw	a0,0(s5)
    800037ca:	c12ff0ef          	jal	80002bdc <bread>
    800037ce:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037d0:	3ff97713          	andi	a4,s2,1023
    800037d4:	40ec87bb          	subw	a5,s9,a4
    800037d8:	413b06bb          	subw	a3,s6,s3
    800037dc:	8d3e                	mv	s10,a5
    800037de:	2781                	sext.w	a5,a5
    800037e0:	0006861b          	sext.w	a2,a3
    800037e4:	f8f67ee3          	bgeu	a2,a5,80003780 <writei+0x4c>
    800037e8:	8d36                	mv	s10,a3
    800037ea:	bf59                	j	80003780 <writei+0x4c>
      brelse(bp);
    800037ec:	8526                	mv	a0,s1
    800037ee:	cf6ff0ef          	jal	80002ce4 <brelse>
  }

  if(off > ip->size)
    800037f2:	04caa783          	lw	a5,76(s5)
    800037f6:	0327fa63          	bgeu	a5,s2,8000382a <writei+0xf6>
    ip->size = off;
    800037fa:	052aa623          	sw	s2,76(s5)
    800037fe:	64e6                	ld	s1,88(sp)
    80003800:	7c02                	ld	s8,32(sp)
    80003802:	6ce2                	ld	s9,24(sp)
    80003804:	6d42                	ld	s10,16(sp)
    80003806:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003808:	8556                	mv	a0,s5
    8000380a:	9ebff0ef          	jal	800031f4 <iupdate>

  return tot;
    8000380e:	0009851b          	sext.w	a0,s3
    80003812:	69a6                	ld	s3,72(sp)
}
    80003814:	70a6                	ld	ra,104(sp)
    80003816:	7406                	ld	s0,96(sp)
    80003818:	6946                	ld	s2,80(sp)
    8000381a:	6a06                	ld	s4,64(sp)
    8000381c:	7ae2                	ld	s5,56(sp)
    8000381e:	7b42                	ld	s6,48(sp)
    80003820:	7ba2                	ld	s7,40(sp)
    80003822:	6165                	addi	sp,sp,112
    80003824:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003826:	89da                	mv	s3,s6
    80003828:	b7c5                	j	80003808 <writei+0xd4>
    8000382a:	64e6                	ld	s1,88(sp)
    8000382c:	7c02                	ld	s8,32(sp)
    8000382e:	6ce2                	ld	s9,24(sp)
    80003830:	6d42                	ld	s10,16(sp)
    80003832:	6da2                	ld	s11,8(sp)
    80003834:	bfd1                	j	80003808 <writei+0xd4>
    return -1;
    80003836:	557d                	li	a0,-1
}
    80003838:	8082                	ret
    return -1;
    8000383a:	557d                	li	a0,-1
    8000383c:	bfe1                	j	80003814 <writei+0xe0>
    return -1;
    8000383e:	557d                	li	a0,-1
    80003840:	bfd1                	j	80003814 <writei+0xe0>

0000000080003842 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003842:	1141                	addi	sp,sp,-16
    80003844:	e406                	sd	ra,8(sp)
    80003846:	e022                	sd	s0,0(sp)
    80003848:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000384a:	4639                	li	a2,14
    8000384c:	d22fd0ef          	jal	80000d6e <strncmp>
}
    80003850:	60a2                	ld	ra,8(sp)
    80003852:	6402                	ld	s0,0(sp)
    80003854:	0141                	addi	sp,sp,16
    80003856:	8082                	ret

0000000080003858 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003858:	7139                	addi	sp,sp,-64
    8000385a:	fc06                	sd	ra,56(sp)
    8000385c:	f822                	sd	s0,48(sp)
    8000385e:	f426                	sd	s1,40(sp)
    80003860:	f04a                	sd	s2,32(sp)
    80003862:	ec4e                	sd	s3,24(sp)
    80003864:	e852                	sd	s4,16(sp)
    80003866:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003868:	04451703          	lh	a4,68(a0)
    8000386c:	4785                	li	a5,1
    8000386e:	00f71a63          	bne	a4,a5,80003882 <dirlookup+0x2a>
    80003872:	892a                	mv	s2,a0
    80003874:	89ae                	mv	s3,a1
    80003876:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003878:	457c                	lw	a5,76(a0)
    8000387a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000387c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000387e:	e39d                	bnez	a5,800038a4 <dirlookup+0x4c>
    80003880:	a095                	j	800038e4 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003882:	00004517          	auipc	a0,0x4
    80003886:	c2650513          	addi	a0,a0,-986 # 800074a8 <etext+0x4a8>
    8000388a:	f57fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    8000388e:	00004517          	auipc	a0,0x4
    80003892:	c3250513          	addi	a0,a0,-974 # 800074c0 <etext+0x4c0>
    80003896:	f4bfc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000389a:	24c1                	addiw	s1,s1,16
    8000389c:	04c92783          	lw	a5,76(s2)
    800038a0:	04f4f163          	bgeu	s1,a5,800038e2 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038a4:	4741                	li	a4,16
    800038a6:	86a6                	mv	a3,s1
    800038a8:	fc040613          	addi	a2,s0,-64
    800038ac:	4581                	li	a1,0
    800038ae:	854a                	mv	a0,s2
    800038b0:	d89ff0ef          	jal	80003638 <readi>
    800038b4:	47c1                	li	a5,16
    800038b6:	fcf51ce3          	bne	a0,a5,8000388e <dirlookup+0x36>
    if(de.inum == 0)
    800038ba:	fc045783          	lhu	a5,-64(s0)
    800038be:	dff1                	beqz	a5,8000389a <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800038c0:	fc240593          	addi	a1,s0,-62
    800038c4:	854e                	mv	a0,s3
    800038c6:	f7dff0ef          	jal	80003842 <namecmp>
    800038ca:	f961                	bnez	a0,8000389a <dirlookup+0x42>
      if(poff)
    800038cc:	000a0463          	beqz	s4,800038d4 <dirlookup+0x7c>
        *poff = off;
    800038d0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800038d4:	fc045583          	lhu	a1,-64(s0)
    800038d8:	00092503          	lw	a0,0(s2)
    800038dc:	f58ff0ef          	jal	80003034 <iget>
    800038e0:	a011                	j	800038e4 <dirlookup+0x8c>
  return 0;
    800038e2:	4501                	li	a0,0
}
    800038e4:	70e2                	ld	ra,56(sp)
    800038e6:	7442                	ld	s0,48(sp)
    800038e8:	74a2                	ld	s1,40(sp)
    800038ea:	7902                	ld	s2,32(sp)
    800038ec:	69e2                	ld	s3,24(sp)
    800038ee:	6a42                	ld	s4,16(sp)
    800038f0:	6121                	addi	sp,sp,64
    800038f2:	8082                	ret

00000000800038f4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800038f4:	711d                	addi	sp,sp,-96
    800038f6:	ec86                	sd	ra,88(sp)
    800038f8:	e8a2                	sd	s0,80(sp)
    800038fa:	e4a6                	sd	s1,72(sp)
    800038fc:	e0ca                	sd	s2,64(sp)
    800038fe:	fc4e                	sd	s3,56(sp)
    80003900:	f852                	sd	s4,48(sp)
    80003902:	f456                	sd	s5,40(sp)
    80003904:	f05a                	sd	s6,32(sp)
    80003906:	ec5e                	sd	s7,24(sp)
    80003908:	e862                	sd	s8,16(sp)
    8000390a:	e466                	sd	s9,8(sp)
    8000390c:	1080                	addi	s0,sp,96
    8000390e:	84aa                	mv	s1,a0
    80003910:	8b2e                	mv	s6,a1
    80003912:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003914:	00054703          	lbu	a4,0(a0)
    80003918:	02f00793          	li	a5,47
    8000391c:	00f70e63          	beq	a4,a5,80003938 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003920:	faffd0ef          	jal	800018ce <myproc>
    80003924:	15053503          	ld	a0,336(a0)
    80003928:	94bff0ef          	jal	80003272 <idup>
    8000392c:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000392e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003932:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003934:	4b85                	li	s7,1
    80003936:	a871                	j	800039d2 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003938:	4585                	li	a1,1
    8000393a:	4505                	li	a0,1
    8000393c:	ef8ff0ef          	jal	80003034 <iget>
    80003940:	8a2a                	mv	s4,a0
    80003942:	b7f5                	j	8000392e <namex+0x3a>
      iunlockput(ip);
    80003944:	8552                	mv	a0,s4
    80003946:	b6dff0ef          	jal	800034b2 <iunlockput>
      return 0;
    8000394a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000394c:	8552                	mv	a0,s4
    8000394e:	60e6                	ld	ra,88(sp)
    80003950:	6446                	ld	s0,80(sp)
    80003952:	64a6                	ld	s1,72(sp)
    80003954:	6906                	ld	s2,64(sp)
    80003956:	79e2                	ld	s3,56(sp)
    80003958:	7a42                	ld	s4,48(sp)
    8000395a:	7aa2                	ld	s5,40(sp)
    8000395c:	7b02                	ld	s6,32(sp)
    8000395e:	6be2                	ld	s7,24(sp)
    80003960:	6c42                	ld	s8,16(sp)
    80003962:	6ca2                	ld	s9,8(sp)
    80003964:	6125                	addi	sp,sp,96
    80003966:	8082                	ret
      iunlock(ip);
    80003968:	8552                	mv	a0,s4
    8000396a:	9edff0ef          	jal	80003356 <iunlock>
      return ip;
    8000396e:	bff9                	j	8000394c <namex+0x58>
      iunlockput(ip);
    80003970:	8552                	mv	a0,s4
    80003972:	b41ff0ef          	jal	800034b2 <iunlockput>
      return 0;
    80003976:	8a4e                	mv	s4,s3
    80003978:	bfd1                	j	8000394c <namex+0x58>
  len = path - s;
    8000397a:	40998633          	sub	a2,s3,s1
    8000397e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003982:	099c5063          	bge	s8,s9,80003a02 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003986:	4639                	li	a2,14
    80003988:	85a6                	mv	a1,s1
    8000398a:	8556                	mv	a0,s5
    8000398c:	b72fd0ef          	jal	80000cfe <memmove>
    80003990:	84ce                	mv	s1,s3
  while(*path == '/')
    80003992:	0004c783          	lbu	a5,0(s1)
    80003996:	01279763          	bne	a5,s2,800039a4 <namex+0xb0>
    path++;
    8000399a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000399c:	0004c783          	lbu	a5,0(s1)
    800039a0:	ff278de3          	beq	a5,s2,8000399a <namex+0xa6>
    ilock(ip);
    800039a4:	8552                	mv	a0,s4
    800039a6:	903ff0ef          	jal	800032a8 <ilock>
    if(ip->type != T_DIR){
    800039aa:	044a1783          	lh	a5,68(s4)
    800039ae:	f9779be3          	bne	a5,s7,80003944 <namex+0x50>
    if(nameiparent && *path == '\0'){
    800039b2:	000b0563          	beqz	s6,800039bc <namex+0xc8>
    800039b6:	0004c783          	lbu	a5,0(s1)
    800039ba:	d7dd                	beqz	a5,80003968 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800039bc:	4601                	li	a2,0
    800039be:	85d6                	mv	a1,s5
    800039c0:	8552                	mv	a0,s4
    800039c2:	e97ff0ef          	jal	80003858 <dirlookup>
    800039c6:	89aa                	mv	s3,a0
    800039c8:	d545                	beqz	a0,80003970 <namex+0x7c>
    iunlockput(ip);
    800039ca:	8552                	mv	a0,s4
    800039cc:	ae7ff0ef          	jal	800034b2 <iunlockput>
    ip = next;
    800039d0:	8a4e                	mv	s4,s3
  while(*path == '/')
    800039d2:	0004c783          	lbu	a5,0(s1)
    800039d6:	01279763          	bne	a5,s2,800039e4 <namex+0xf0>
    path++;
    800039da:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039dc:	0004c783          	lbu	a5,0(s1)
    800039e0:	ff278de3          	beq	a5,s2,800039da <namex+0xe6>
  if(*path == 0)
    800039e4:	cb8d                	beqz	a5,80003a16 <namex+0x122>
  while(*path != '/' && *path != 0)
    800039e6:	0004c783          	lbu	a5,0(s1)
    800039ea:	89a6                	mv	s3,s1
  len = path - s;
    800039ec:	4c81                	li	s9,0
    800039ee:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800039f0:	01278963          	beq	a5,s2,80003a02 <namex+0x10e>
    800039f4:	d3d9                	beqz	a5,8000397a <namex+0x86>
    path++;
    800039f6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800039f8:	0009c783          	lbu	a5,0(s3)
    800039fc:	ff279ce3          	bne	a5,s2,800039f4 <namex+0x100>
    80003a00:	bfad                	j	8000397a <namex+0x86>
    memmove(name, s, len);
    80003a02:	2601                	sext.w	a2,a2
    80003a04:	85a6                	mv	a1,s1
    80003a06:	8556                	mv	a0,s5
    80003a08:	af6fd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003a0c:	9cd6                	add	s9,s9,s5
    80003a0e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003a12:	84ce                	mv	s1,s3
    80003a14:	bfbd                	j	80003992 <namex+0x9e>
  if(nameiparent){
    80003a16:	f20b0be3          	beqz	s6,8000394c <namex+0x58>
    iput(ip);
    80003a1a:	8552                	mv	a0,s4
    80003a1c:	a0fff0ef          	jal	8000342a <iput>
    return 0;
    80003a20:	4a01                	li	s4,0
    80003a22:	b72d                	j	8000394c <namex+0x58>

0000000080003a24 <dirlink>:
{
    80003a24:	7139                	addi	sp,sp,-64
    80003a26:	fc06                	sd	ra,56(sp)
    80003a28:	f822                	sd	s0,48(sp)
    80003a2a:	f04a                	sd	s2,32(sp)
    80003a2c:	ec4e                	sd	s3,24(sp)
    80003a2e:	e852                	sd	s4,16(sp)
    80003a30:	0080                	addi	s0,sp,64
    80003a32:	892a                	mv	s2,a0
    80003a34:	8a2e                	mv	s4,a1
    80003a36:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a38:	4601                	li	a2,0
    80003a3a:	e1fff0ef          	jal	80003858 <dirlookup>
    80003a3e:	e535                	bnez	a0,80003aaa <dirlink+0x86>
    80003a40:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a42:	04c92483          	lw	s1,76(s2)
    80003a46:	c48d                	beqz	s1,80003a70 <dirlink+0x4c>
    80003a48:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a4a:	4741                	li	a4,16
    80003a4c:	86a6                	mv	a3,s1
    80003a4e:	fc040613          	addi	a2,s0,-64
    80003a52:	4581                	li	a1,0
    80003a54:	854a                	mv	a0,s2
    80003a56:	be3ff0ef          	jal	80003638 <readi>
    80003a5a:	47c1                	li	a5,16
    80003a5c:	04f51b63          	bne	a0,a5,80003ab2 <dirlink+0x8e>
    if(de.inum == 0)
    80003a60:	fc045783          	lhu	a5,-64(s0)
    80003a64:	c791                	beqz	a5,80003a70 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a66:	24c1                	addiw	s1,s1,16
    80003a68:	04c92783          	lw	a5,76(s2)
    80003a6c:	fcf4efe3          	bltu	s1,a5,80003a4a <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003a70:	4639                	li	a2,14
    80003a72:	85d2                	mv	a1,s4
    80003a74:	fc240513          	addi	a0,s0,-62
    80003a78:	b2cfd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003a7c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a80:	4741                	li	a4,16
    80003a82:	86a6                	mv	a3,s1
    80003a84:	fc040613          	addi	a2,s0,-64
    80003a88:	4581                	li	a1,0
    80003a8a:	854a                	mv	a0,s2
    80003a8c:	ca9ff0ef          	jal	80003734 <writei>
    80003a90:	1541                	addi	a0,a0,-16
    80003a92:	00a03533          	snez	a0,a0
    80003a96:	40a00533          	neg	a0,a0
    80003a9a:	74a2                	ld	s1,40(sp)
}
    80003a9c:	70e2                	ld	ra,56(sp)
    80003a9e:	7442                	ld	s0,48(sp)
    80003aa0:	7902                	ld	s2,32(sp)
    80003aa2:	69e2                	ld	s3,24(sp)
    80003aa4:	6a42                	ld	s4,16(sp)
    80003aa6:	6121                	addi	sp,sp,64
    80003aa8:	8082                	ret
    iput(ip);
    80003aaa:	981ff0ef          	jal	8000342a <iput>
    return -1;
    80003aae:	557d                	li	a0,-1
    80003ab0:	b7f5                	j	80003a9c <dirlink+0x78>
      panic("dirlink read");
    80003ab2:	00004517          	auipc	a0,0x4
    80003ab6:	a1e50513          	addi	a0,a0,-1506 # 800074d0 <etext+0x4d0>
    80003aba:	d27fc0ef          	jal	800007e0 <panic>

0000000080003abe <namei>:

struct inode*
namei(char *path)
{
    80003abe:	1101                	addi	sp,sp,-32
    80003ac0:	ec06                	sd	ra,24(sp)
    80003ac2:	e822                	sd	s0,16(sp)
    80003ac4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ac6:	fe040613          	addi	a2,s0,-32
    80003aca:	4581                	li	a1,0
    80003acc:	e29ff0ef          	jal	800038f4 <namex>
}
    80003ad0:	60e2                	ld	ra,24(sp)
    80003ad2:	6442                	ld	s0,16(sp)
    80003ad4:	6105                	addi	sp,sp,32
    80003ad6:	8082                	ret

0000000080003ad8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ad8:	1141                	addi	sp,sp,-16
    80003ada:	e406                	sd	ra,8(sp)
    80003adc:	e022                	sd	s0,0(sp)
    80003ade:	0800                	addi	s0,sp,16
    80003ae0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ae2:	4585                	li	a1,1
    80003ae4:	e11ff0ef          	jal	800038f4 <namex>
}
    80003ae8:	60a2                	ld	ra,8(sp)
    80003aea:	6402                	ld	s0,0(sp)
    80003aec:	0141                	addi	sp,sp,16
    80003aee:	8082                	ret

0000000080003af0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003af0:	1101                	addi	sp,sp,-32
    80003af2:	ec06                	sd	ra,24(sp)
    80003af4:	e822                	sd	s0,16(sp)
    80003af6:	e426                	sd	s1,8(sp)
    80003af8:	e04a                	sd	s2,0(sp)
    80003afa:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003afc:	0001c917          	auipc	s2,0x1c
    80003b00:	25c90913          	addi	s2,s2,604 # 8001fd58 <log>
    80003b04:	01892583          	lw	a1,24(s2)
    80003b08:	02492503          	lw	a0,36(s2)
    80003b0c:	8d0ff0ef          	jal	80002bdc <bread>
    80003b10:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b12:	02892603          	lw	a2,40(s2)
    80003b16:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b18:	00c05f63          	blez	a2,80003b36 <write_head+0x46>
    80003b1c:	0001c717          	auipc	a4,0x1c
    80003b20:	26870713          	addi	a4,a4,616 # 8001fd84 <log+0x2c>
    80003b24:	87aa                	mv	a5,a0
    80003b26:	060a                	slli	a2,a2,0x2
    80003b28:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b2a:	4314                	lw	a3,0(a4)
    80003b2c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b2e:	0711                	addi	a4,a4,4
    80003b30:	0791                	addi	a5,a5,4
    80003b32:	fec79ce3          	bne	a5,a2,80003b2a <write_head+0x3a>
  }
  bwrite(buf);
    80003b36:	8526                	mv	a0,s1
    80003b38:	97aff0ef          	jal	80002cb2 <bwrite>
  brelse(buf);
    80003b3c:	8526                	mv	a0,s1
    80003b3e:	9a6ff0ef          	jal	80002ce4 <brelse>
}
    80003b42:	60e2                	ld	ra,24(sp)
    80003b44:	6442                	ld	s0,16(sp)
    80003b46:	64a2                	ld	s1,8(sp)
    80003b48:	6902                	ld	s2,0(sp)
    80003b4a:	6105                	addi	sp,sp,32
    80003b4c:	8082                	ret

0000000080003b4e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b4e:	0001c797          	auipc	a5,0x1c
    80003b52:	2327a783          	lw	a5,562(a5) # 8001fd80 <log+0x28>
    80003b56:	0af05e63          	blez	a5,80003c12 <install_trans+0xc4>
{
    80003b5a:	715d                	addi	sp,sp,-80
    80003b5c:	e486                	sd	ra,72(sp)
    80003b5e:	e0a2                	sd	s0,64(sp)
    80003b60:	fc26                	sd	s1,56(sp)
    80003b62:	f84a                	sd	s2,48(sp)
    80003b64:	f44e                	sd	s3,40(sp)
    80003b66:	f052                	sd	s4,32(sp)
    80003b68:	ec56                	sd	s5,24(sp)
    80003b6a:	e85a                	sd	s6,16(sp)
    80003b6c:	e45e                	sd	s7,8(sp)
    80003b6e:	0880                	addi	s0,sp,80
    80003b70:	8b2a                	mv	s6,a0
    80003b72:	0001ca97          	auipc	s5,0x1c
    80003b76:	212a8a93          	addi	s5,s5,530 # 8001fd84 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b7a:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b7c:	00004b97          	auipc	s7,0x4
    80003b80:	964b8b93          	addi	s7,s7,-1692 # 800074e0 <etext+0x4e0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b84:	0001ca17          	auipc	s4,0x1c
    80003b88:	1d4a0a13          	addi	s4,s4,468 # 8001fd58 <log>
    80003b8c:	a025                	j	80003bb4 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b8e:	000aa603          	lw	a2,0(s5)
    80003b92:	85ce                	mv	a1,s3
    80003b94:	855e                	mv	a0,s7
    80003b96:	965fc0ef          	jal	800004fa <printf>
    80003b9a:	a839                	j	80003bb8 <install_trans+0x6a>
    brelse(lbuf);
    80003b9c:	854a                	mv	a0,s2
    80003b9e:	946ff0ef          	jal	80002ce4 <brelse>
    brelse(dbuf);
    80003ba2:	8526                	mv	a0,s1
    80003ba4:	940ff0ef          	jal	80002ce4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ba8:	2985                	addiw	s3,s3,1
    80003baa:	0a91                	addi	s5,s5,4
    80003bac:	028a2783          	lw	a5,40(s4)
    80003bb0:	04f9d663          	bge	s3,a5,80003bfc <install_trans+0xae>
    if(recovering) {
    80003bb4:	fc0b1de3          	bnez	s6,80003b8e <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003bb8:	018a2583          	lw	a1,24(s4)
    80003bbc:	013585bb          	addw	a1,a1,s3
    80003bc0:	2585                	addiw	a1,a1,1
    80003bc2:	024a2503          	lw	a0,36(s4)
    80003bc6:	816ff0ef          	jal	80002bdc <bread>
    80003bca:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003bcc:	000aa583          	lw	a1,0(s5)
    80003bd0:	024a2503          	lw	a0,36(s4)
    80003bd4:	808ff0ef          	jal	80002bdc <bread>
    80003bd8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003bda:	40000613          	li	a2,1024
    80003bde:	05890593          	addi	a1,s2,88
    80003be2:	05850513          	addi	a0,a0,88
    80003be6:	918fd0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003bea:	8526                	mv	a0,s1
    80003bec:	8c6ff0ef          	jal	80002cb2 <bwrite>
    if(recovering == 0)
    80003bf0:	fa0b16e3          	bnez	s6,80003b9c <install_trans+0x4e>
      bunpin(dbuf);
    80003bf4:	8526                	mv	a0,s1
    80003bf6:	9aaff0ef          	jal	80002da0 <bunpin>
    80003bfa:	b74d                	j	80003b9c <install_trans+0x4e>
}
    80003bfc:	60a6                	ld	ra,72(sp)
    80003bfe:	6406                	ld	s0,64(sp)
    80003c00:	74e2                	ld	s1,56(sp)
    80003c02:	7942                	ld	s2,48(sp)
    80003c04:	79a2                	ld	s3,40(sp)
    80003c06:	7a02                	ld	s4,32(sp)
    80003c08:	6ae2                	ld	s5,24(sp)
    80003c0a:	6b42                	ld	s6,16(sp)
    80003c0c:	6ba2                	ld	s7,8(sp)
    80003c0e:	6161                	addi	sp,sp,80
    80003c10:	8082                	ret
    80003c12:	8082                	ret

0000000080003c14 <initlog>:
{
    80003c14:	7179                	addi	sp,sp,-48
    80003c16:	f406                	sd	ra,40(sp)
    80003c18:	f022                	sd	s0,32(sp)
    80003c1a:	ec26                	sd	s1,24(sp)
    80003c1c:	e84a                	sd	s2,16(sp)
    80003c1e:	e44e                	sd	s3,8(sp)
    80003c20:	1800                	addi	s0,sp,48
    80003c22:	892a                	mv	s2,a0
    80003c24:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c26:	0001c497          	auipc	s1,0x1c
    80003c2a:	13248493          	addi	s1,s1,306 # 8001fd58 <log>
    80003c2e:	00004597          	auipc	a1,0x4
    80003c32:	8d258593          	addi	a1,a1,-1838 # 80007500 <etext+0x500>
    80003c36:	8526                	mv	a0,s1
    80003c38:	f17fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003c3c:	0149a583          	lw	a1,20(s3)
    80003c40:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003c42:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003c46:	854a                	mv	a0,s2
    80003c48:	f95fe0ef          	jal	80002bdc <bread>
  log.lh.n = lh->n;
    80003c4c:	4d30                	lw	a2,88(a0)
    80003c4e:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003c50:	00c05f63          	blez	a2,80003c6e <initlog+0x5a>
    80003c54:	87aa                	mv	a5,a0
    80003c56:	0001c717          	auipc	a4,0x1c
    80003c5a:	12e70713          	addi	a4,a4,302 # 8001fd84 <log+0x2c>
    80003c5e:	060a                	slli	a2,a2,0x2
    80003c60:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003c62:	4ff4                	lw	a3,92(a5)
    80003c64:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c66:	0791                	addi	a5,a5,4
    80003c68:	0711                	addi	a4,a4,4
    80003c6a:	fec79ce3          	bne	a5,a2,80003c62 <initlog+0x4e>
  brelse(buf);
    80003c6e:	876ff0ef          	jal	80002ce4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c72:	4505                	li	a0,1
    80003c74:	edbff0ef          	jal	80003b4e <install_trans>
  log.lh.n = 0;
    80003c78:	0001c797          	auipc	a5,0x1c
    80003c7c:	1007a423          	sw	zero,264(a5) # 8001fd80 <log+0x28>
  write_head(); // clear the log
    80003c80:	e71ff0ef          	jal	80003af0 <write_head>
}
    80003c84:	70a2                	ld	ra,40(sp)
    80003c86:	7402                	ld	s0,32(sp)
    80003c88:	64e2                	ld	s1,24(sp)
    80003c8a:	6942                	ld	s2,16(sp)
    80003c8c:	69a2                	ld	s3,8(sp)
    80003c8e:	6145                	addi	sp,sp,48
    80003c90:	8082                	ret

0000000080003c92 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c92:	1101                	addi	sp,sp,-32
    80003c94:	ec06                	sd	ra,24(sp)
    80003c96:	e822                	sd	s0,16(sp)
    80003c98:	e426                	sd	s1,8(sp)
    80003c9a:	e04a                	sd	s2,0(sp)
    80003c9c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003c9e:	0001c517          	auipc	a0,0x1c
    80003ca2:	0ba50513          	addi	a0,a0,186 # 8001fd58 <log>
    80003ca6:	f29fc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003caa:	0001c497          	auipc	s1,0x1c
    80003cae:	0ae48493          	addi	s1,s1,174 # 8001fd58 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003cb2:	4979                	li	s2,30
    80003cb4:	a029                	j	80003cbe <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003cb6:	85a6                	mv	a1,s1
    80003cb8:	8526                	mv	a0,s1
    80003cba:	a3efe0ef          	jal	80001ef8 <sleep>
    if(log.committing){
    80003cbe:	509c                	lw	a5,32(s1)
    80003cc0:	fbfd                	bnez	a5,80003cb6 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003cc2:	4cd8                	lw	a4,28(s1)
    80003cc4:	2705                	addiw	a4,a4,1
    80003cc6:	0027179b          	slliw	a5,a4,0x2
    80003cca:	9fb9                	addw	a5,a5,a4
    80003ccc:	0017979b          	slliw	a5,a5,0x1
    80003cd0:	5494                	lw	a3,40(s1)
    80003cd2:	9fb5                	addw	a5,a5,a3
    80003cd4:	00f95763          	bge	s2,a5,80003ce2 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003cd8:	85a6                	mv	a1,s1
    80003cda:	8526                	mv	a0,s1
    80003cdc:	a1cfe0ef          	jal	80001ef8 <sleep>
    80003ce0:	bff9                	j	80003cbe <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003ce2:	0001c517          	auipc	a0,0x1c
    80003ce6:	07650513          	addi	a0,a0,118 # 8001fd58 <log>
    80003cea:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003cec:	f7bfc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003cf0:	60e2                	ld	ra,24(sp)
    80003cf2:	6442                	ld	s0,16(sp)
    80003cf4:	64a2                	ld	s1,8(sp)
    80003cf6:	6902                	ld	s2,0(sp)
    80003cf8:	6105                	addi	sp,sp,32
    80003cfa:	8082                	ret

0000000080003cfc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003cfc:	7139                	addi	sp,sp,-64
    80003cfe:	fc06                	sd	ra,56(sp)
    80003d00:	f822                	sd	s0,48(sp)
    80003d02:	f426                	sd	s1,40(sp)
    80003d04:	f04a                	sd	s2,32(sp)
    80003d06:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d08:	0001c497          	auipc	s1,0x1c
    80003d0c:	05048493          	addi	s1,s1,80 # 8001fd58 <log>
    80003d10:	8526                	mv	a0,s1
    80003d12:	ebdfc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003d16:	4cdc                	lw	a5,28(s1)
    80003d18:	37fd                	addiw	a5,a5,-1
    80003d1a:	0007891b          	sext.w	s2,a5
    80003d1e:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003d20:	509c                	lw	a5,32(s1)
    80003d22:	ef9d                	bnez	a5,80003d60 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003d24:	04091763          	bnez	s2,80003d72 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003d28:	0001c497          	auipc	s1,0x1c
    80003d2c:	03048493          	addi	s1,s1,48 # 8001fd58 <log>
    80003d30:	4785                	li	a5,1
    80003d32:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d34:	8526                	mv	a0,s1
    80003d36:	f31fc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d3a:	549c                	lw	a5,40(s1)
    80003d3c:	04f04b63          	bgtz	a5,80003d92 <end_op+0x96>
    acquire(&log.lock);
    80003d40:	0001c497          	auipc	s1,0x1c
    80003d44:	01848493          	addi	s1,s1,24 # 8001fd58 <log>
    80003d48:	8526                	mv	a0,s1
    80003d4a:	e85fc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003d4e:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003d52:	8526                	mv	a0,s1
    80003d54:	9f0fe0ef          	jal	80001f44 <wakeup>
    release(&log.lock);
    80003d58:	8526                	mv	a0,s1
    80003d5a:	f0dfc0ef          	jal	80000c66 <release>
}
    80003d5e:	a025                	j	80003d86 <end_op+0x8a>
    80003d60:	ec4e                	sd	s3,24(sp)
    80003d62:	e852                	sd	s4,16(sp)
    80003d64:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003d66:	00003517          	auipc	a0,0x3
    80003d6a:	7a250513          	addi	a0,a0,1954 # 80007508 <etext+0x508>
    80003d6e:	a73fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003d72:	0001c497          	auipc	s1,0x1c
    80003d76:	fe648493          	addi	s1,s1,-26 # 8001fd58 <log>
    80003d7a:	8526                	mv	a0,s1
    80003d7c:	9c8fe0ef          	jal	80001f44 <wakeup>
  release(&log.lock);
    80003d80:	8526                	mv	a0,s1
    80003d82:	ee5fc0ef          	jal	80000c66 <release>
}
    80003d86:	70e2                	ld	ra,56(sp)
    80003d88:	7442                	ld	s0,48(sp)
    80003d8a:	74a2                	ld	s1,40(sp)
    80003d8c:	7902                	ld	s2,32(sp)
    80003d8e:	6121                	addi	sp,sp,64
    80003d90:	8082                	ret
    80003d92:	ec4e                	sd	s3,24(sp)
    80003d94:	e852                	sd	s4,16(sp)
    80003d96:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d98:	0001ca97          	auipc	s5,0x1c
    80003d9c:	feca8a93          	addi	s5,s5,-20 # 8001fd84 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003da0:	0001ca17          	auipc	s4,0x1c
    80003da4:	fb8a0a13          	addi	s4,s4,-72 # 8001fd58 <log>
    80003da8:	018a2583          	lw	a1,24(s4)
    80003dac:	012585bb          	addw	a1,a1,s2
    80003db0:	2585                	addiw	a1,a1,1
    80003db2:	024a2503          	lw	a0,36(s4)
    80003db6:	e27fe0ef          	jal	80002bdc <bread>
    80003dba:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003dbc:	000aa583          	lw	a1,0(s5)
    80003dc0:	024a2503          	lw	a0,36(s4)
    80003dc4:	e19fe0ef          	jal	80002bdc <bread>
    80003dc8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003dca:	40000613          	li	a2,1024
    80003dce:	05850593          	addi	a1,a0,88
    80003dd2:	05848513          	addi	a0,s1,88
    80003dd6:	f29fc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003dda:	8526                	mv	a0,s1
    80003ddc:	ed7fe0ef          	jal	80002cb2 <bwrite>
    brelse(from);
    80003de0:	854e                	mv	a0,s3
    80003de2:	f03fe0ef          	jal	80002ce4 <brelse>
    brelse(to);
    80003de6:	8526                	mv	a0,s1
    80003de8:	efdfe0ef          	jal	80002ce4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dec:	2905                	addiw	s2,s2,1
    80003dee:	0a91                	addi	s5,s5,4
    80003df0:	028a2783          	lw	a5,40(s4)
    80003df4:	faf94ae3          	blt	s2,a5,80003da8 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003df8:	cf9ff0ef          	jal	80003af0 <write_head>
    install_trans(0); // Now install writes to home locations
    80003dfc:	4501                	li	a0,0
    80003dfe:	d51ff0ef          	jal	80003b4e <install_trans>
    log.lh.n = 0;
    80003e02:	0001c797          	auipc	a5,0x1c
    80003e06:	f607af23          	sw	zero,-130(a5) # 8001fd80 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003e0a:	ce7ff0ef          	jal	80003af0 <write_head>
    80003e0e:	69e2                	ld	s3,24(sp)
    80003e10:	6a42                	ld	s4,16(sp)
    80003e12:	6aa2                	ld	s5,8(sp)
    80003e14:	b735                	j	80003d40 <end_op+0x44>

0000000080003e16 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e16:	1101                	addi	sp,sp,-32
    80003e18:	ec06                	sd	ra,24(sp)
    80003e1a:	e822                	sd	s0,16(sp)
    80003e1c:	e426                	sd	s1,8(sp)
    80003e1e:	e04a                	sd	s2,0(sp)
    80003e20:	1000                	addi	s0,sp,32
    80003e22:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e24:	0001c917          	auipc	s2,0x1c
    80003e28:	f3490913          	addi	s2,s2,-204 # 8001fd58 <log>
    80003e2c:	854a                	mv	a0,s2
    80003e2e:	da1fc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e32:	02892603          	lw	a2,40(s2)
    80003e36:	47f5                	li	a5,29
    80003e38:	04c7cc63          	blt	a5,a2,80003e90 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e3c:	0001c797          	auipc	a5,0x1c
    80003e40:	f387a783          	lw	a5,-200(a5) # 8001fd74 <log+0x1c>
    80003e44:	04f05c63          	blez	a5,80003e9c <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e48:	4781                	li	a5,0
    80003e4a:	04c05f63          	blez	a2,80003ea8 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e4e:	44cc                	lw	a1,12(s1)
    80003e50:	0001c717          	auipc	a4,0x1c
    80003e54:	f3470713          	addi	a4,a4,-204 # 8001fd84 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003e58:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e5a:	4314                	lw	a3,0(a4)
    80003e5c:	04b68663          	beq	a3,a1,80003ea8 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003e60:	2785                	addiw	a5,a5,1
    80003e62:	0711                	addi	a4,a4,4
    80003e64:	fef61be3          	bne	a2,a5,80003e5a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e68:	0621                	addi	a2,a2,8
    80003e6a:	060a                	slli	a2,a2,0x2
    80003e6c:	0001c797          	auipc	a5,0x1c
    80003e70:	eec78793          	addi	a5,a5,-276 # 8001fd58 <log>
    80003e74:	97b2                	add	a5,a5,a2
    80003e76:	44d8                	lw	a4,12(s1)
    80003e78:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003e7a:	8526                	mv	a0,s1
    80003e7c:	ef1fe0ef          	jal	80002d6c <bpin>
    log.lh.n++;
    80003e80:	0001c717          	auipc	a4,0x1c
    80003e84:	ed870713          	addi	a4,a4,-296 # 8001fd58 <log>
    80003e88:	571c                	lw	a5,40(a4)
    80003e8a:	2785                	addiw	a5,a5,1
    80003e8c:	d71c                	sw	a5,40(a4)
    80003e8e:	a80d                	j	80003ec0 <log_write+0xaa>
    panic("too big a transaction");
    80003e90:	00003517          	auipc	a0,0x3
    80003e94:	68850513          	addi	a0,a0,1672 # 80007518 <etext+0x518>
    80003e98:	949fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80003e9c:	00003517          	auipc	a0,0x3
    80003ea0:	69450513          	addi	a0,a0,1684 # 80007530 <etext+0x530>
    80003ea4:	93dfc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80003ea8:	00878693          	addi	a3,a5,8
    80003eac:	068a                	slli	a3,a3,0x2
    80003eae:	0001c717          	auipc	a4,0x1c
    80003eb2:	eaa70713          	addi	a4,a4,-342 # 8001fd58 <log>
    80003eb6:	9736                	add	a4,a4,a3
    80003eb8:	44d4                	lw	a3,12(s1)
    80003eba:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003ebc:	faf60fe3          	beq	a2,a5,80003e7a <log_write+0x64>
  }
  release(&log.lock);
    80003ec0:	0001c517          	auipc	a0,0x1c
    80003ec4:	e9850513          	addi	a0,a0,-360 # 8001fd58 <log>
    80003ec8:	d9ffc0ef          	jal	80000c66 <release>
}
    80003ecc:	60e2                	ld	ra,24(sp)
    80003ece:	6442                	ld	s0,16(sp)
    80003ed0:	64a2                	ld	s1,8(sp)
    80003ed2:	6902                	ld	s2,0(sp)
    80003ed4:	6105                	addi	sp,sp,32
    80003ed6:	8082                	ret

0000000080003ed8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003ed8:	1101                	addi	sp,sp,-32
    80003eda:	ec06                	sd	ra,24(sp)
    80003edc:	e822                	sd	s0,16(sp)
    80003ede:	e426                	sd	s1,8(sp)
    80003ee0:	e04a                	sd	s2,0(sp)
    80003ee2:	1000                	addi	s0,sp,32
    80003ee4:	84aa                	mv	s1,a0
    80003ee6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003ee8:	00003597          	auipc	a1,0x3
    80003eec:	66858593          	addi	a1,a1,1640 # 80007550 <etext+0x550>
    80003ef0:	0521                	addi	a0,a0,8
    80003ef2:	c5dfc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80003ef6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003efa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003efe:	0204a423          	sw	zero,40(s1)
}
    80003f02:	60e2                	ld	ra,24(sp)
    80003f04:	6442                	ld	s0,16(sp)
    80003f06:	64a2                	ld	s1,8(sp)
    80003f08:	6902                	ld	s2,0(sp)
    80003f0a:	6105                	addi	sp,sp,32
    80003f0c:	8082                	ret

0000000080003f0e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f0e:	1101                	addi	sp,sp,-32
    80003f10:	ec06                	sd	ra,24(sp)
    80003f12:	e822                	sd	s0,16(sp)
    80003f14:	e426                	sd	s1,8(sp)
    80003f16:	e04a                	sd	s2,0(sp)
    80003f18:	1000                	addi	s0,sp,32
    80003f1a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f1c:	00850913          	addi	s2,a0,8
    80003f20:	854a                	mv	a0,s2
    80003f22:	cadfc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80003f26:	409c                	lw	a5,0(s1)
    80003f28:	c799                	beqz	a5,80003f36 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f2a:	85ca                	mv	a1,s2
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	fcbfd0ef          	jal	80001ef8 <sleep>
  while (lk->locked) {
    80003f32:	409c                	lw	a5,0(s1)
    80003f34:	fbfd                	bnez	a5,80003f2a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f36:	4785                	li	a5,1
    80003f38:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003f3a:	995fd0ef          	jal	800018ce <myproc>
    80003f3e:	591c                	lw	a5,48(a0)
    80003f40:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003f42:	854a                	mv	a0,s2
    80003f44:	d23fc0ef          	jal	80000c66 <release>
}
    80003f48:	60e2                	ld	ra,24(sp)
    80003f4a:	6442                	ld	s0,16(sp)
    80003f4c:	64a2                	ld	s1,8(sp)
    80003f4e:	6902                	ld	s2,0(sp)
    80003f50:	6105                	addi	sp,sp,32
    80003f52:	8082                	ret

0000000080003f54 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003f54:	1101                	addi	sp,sp,-32
    80003f56:	ec06                	sd	ra,24(sp)
    80003f58:	e822                	sd	s0,16(sp)
    80003f5a:	e426                	sd	s1,8(sp)
    80003f5c:	e04a                	sd	s2,0(sp)
    80003f5e:	1000                	addi	s0,sp,32
    80003f60:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f62:	00850913          	addi	s2,a0,8
    80003f66:	854a                	mv	a0,s2
    80003f68:	c67fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80003f6c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f70:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003f74:	8526                	mv	a0,s1
    80003f76:	fcffd0ef          	jal	80001f44 <wakeup>
  release(&lk->lk);
    80003f7a:	854a                	mv	a0,s2
    80003f7c:	cebfc0ef          	jal	80000c66 <release>
}
    80003f80:	60e2                	ld	ra,24(sp)
    80003f82:	6442                	ld	s0,16(sp)
    80003f84:	64a2                	ld	s1,8(sp)
    80003f86:	6902                	ld	s2,0(sp)
    80003f88:	6105                	addi	sp,sp,32
    80003f8a:	8082                	ret

0000000080003f8c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003f8c:	7179                	addi	sp,sp,-48
    80003f8e:	f406                	sd	ra,40(sp)
    80003f90:	f022                	sd	s0,32(sp)
    80003f92:	ec26                	sd	s1,24(sp)
    80003f94:	e84a                	sd	s2,16(sp)
    80003f96:	1800                	addi	s0,sp,48
    80003f98:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003f9a:	00850913          	addi	s2,a0,8
    80003f9e:	854a                	mv	a0,s2
    80003fa0:	c2ffc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fa4:	409c                	lw	a5,0(s1)
    80003fa6:	ef81                	bnez	a5,80003fbe <holdingsleep+0x32>
    80003fa8:	4481                	li	s1,0
  release(&lk->lk);
    80003faa:	854a                	mv	a0,s2
    80003fac:	cbbfc0ef          	jal	80000c66 <release>
  return r;
}
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	70a2                	ld	ra,40(sp)
    80003fb4:	7402                	ld	s0,32(sp)
    80003fb6:	64e2                	ld	s1,24(sp)
    80003fb8:	6942                	ld	s2,16(sp)
    80003fba:	6145                	addi	sp,sp,48
    80003fbc:	8082                	ret
    80003fbe:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fc0:	0284a983          	lw	s3,40(s1)
    80003fc4:	90bfd0ef          	jal	800018ce <myproc>
    80003fc8:	5904                	lw	s1,48(a0)
    80003fca:	413484b3          	sub	s1,s1,s3
    80003fce:	0014b493          	seqz	s1,s1
    80003fd2:	69a2                	ld	s3,8(sp)
    80003fd4:	bfd9                	j	80003faa <holdingsleep+0x1e>

0000000080003fd6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003fd6:	1141                	addi	sp,sp,-16
    80003fd8:	e406                	sd	ra,8(sp)
    80003fda:	e022                	sd	s0,0(sp)
    80003fdc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003fde:	00003597          	auipc	a1,0x3
    80003fe2:	58258593          	addi	a1,a1,1410 # 80007560 <etext+0x560>
    80003fe6:	0001c517          	auipc	a0,0x1c
    80003fea:	eba50513          	addi	a0,a0,-326 # 8001fea0 <ftable>
    80003fee:	b61fc0ef          	jal	80000b4e <initlock>
}
    80003ff2:	60a2                	ld	ra,8(sp)
    80003ff4:	6402                	ld	s0,0(sp)
    80003ff6:	0141                	addi	sp,sp,16
    80003ff8:	8082                	ret

0000000080003ffa <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003ffa:	1101                	addi	sp,sp,-32
    80003ffc:	ec06                	sd	ra,24(sp)
    80003ffe:	e822                	sd	s0,16(sp)
    80004000:	e426                	sd	s1,8(sp)
    80004002:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004004:	0001c517          	auipc	a0,0x1c
    80004008:	e9c50513          	addi	a0,a0,-356 # 8001fea0 <ftable>
    8000400c:	bc3fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004010:	0001c497          	auipc	s1,0x1c
    80004014:	ea848493          	addi	s1,s1,-344 # 8001feb8 <ftable+0x18>
    80004018:	0001d717          	auipc	a4,0x1d
    8000401c:	e4070713          	addi	a4,a4,-448 # 80020e58 <disk>
    if(f->ref == 0){
    80004020:	40dc                	lw	a5,4(s1)
    80004022:	cf89                	beqz	a5,8000403c <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004024:	02848493          	addi	s1,s1,40
    80004028:	fee49ce3          	bne	s1,a4,80004020 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000402c:	0001c517          	auipc	a0,0x1c
    80004030:	e7450513          	addi	a0,a0,-396 # 8001fea0 <ftable>
    80004034:	c33fc0ef          	jal	80000c66 <release>
  return 0;
    80004038:	4481                	li	s1,0
    8000403a:	a809                	j	8000404c <filealloc+0x52>
      f->ref = 1;
    8000403c:	4785                	li	a5,1
    8000403e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004040:	0001c517          	auipc	a0,0x1c
    80004044:	e6050513          	addi	a0,a0,-416 # 8001fea0 <ftable>
    80004048:	c1ffc0ef          	jal	80000c66 <release>
}
    8000404c:	8526                	mv	a0,s1
    8000404e:	60e2                	ld	ra,24(sp)
    80004050:	6442                	ld	s0,16(sp)
    80004052:	64a2                	ld	s1,8(sp)
    80004054:	6105                	addi	sp,sp,32
    80004056:	8082                	ret

0000000080004058 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004058:	1101                	addi	sp,sp,-32
    8000405a:	ec06                	sd	ra,24(sp)
    8000405c:	e822                	sd	s0,16(sp)
    8000405e:	e426                	sd	s1,8(sp)
    80004060:	1000                	addi	s0,sp,32
    80004062:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004064:	0001c517          	auipc	a0,0x1c
    80004068:	e3c50513          	addi	a0,a0,-452 # 8001fea0 <ftable>
    8000406c:	b63fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004070:	40dc                	lw	a5,4(s1)
    80004072:	02f05063          	blez	a5,80004092 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004076:	2785                	addiw	a5,a5,1
    80004078:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000407a:	0001c517          	auipc	a0,0x1c
    8000407e:	e2650513          	addi	a0,a0,-474 # 8001fea0 <ftable>
    80004082:	be5fc0ef          	jal	80000c66 <release>
  return f;
}
    80004086:	8526                	mv	a0,s1
    80004088:	60e2                	ld	ra,24(sp)
    8000408a:	6442                	ld	s0,16(sp)
    8000408c:	64a2                	ld	s1,8(sp)
    8000408e:	6105                	addi	sp,sp,32
    80004090:	8082                	ret
    panic("filedup");
    80004092:	00003517          	auipc	a0,0x3
    80004096:	4d650513          	addi	a0,a0,1238 # 80007568 <etext+0x568>
    8000409a:	f46fc0ef          	jal	800007e0 <panic>

000000008000409e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000409e:	7139                	addi	sp,sp,-64
    800040a0:	fc06                	sd	ra,56(sp)
    800040a2:	f822                	sd	s0,48(sp)
    800040a4:	f426                	sd	s1,40(sp)
    800040a6:	0080                	addi	s0,sp,64
    800040a8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800040aa:	0001c517          	auipc	a0,0x1c
    800040ae:	df650513          	addi	a0,a0,-522 # 8001fea0 <ftable>
    800040b2:	b1dfc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    800040b6:	40dc                	lw	a5,4(s1)
    800040b8:	04f05a63          	blez	a5,8000410c <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800040bc:	37fd                	addiw	a5,a5,-1
    800040be:	0007871b          	sext.w	a4,a5
    800040c2:	c0dc                	sw	a5,4(s1)
    800040c4:	04e04e63          	bgtz	a4,80004120 <fileclose+0x82>
    800040c8:	f04a                	sd	s2,32(sp)
    800040ca:	ec4e                	sd	s3,24(sp)
    800040cc:	e852                	sd	s4,16(sp)
    800040ce:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800040d0:	0004a903          	lw	s2,0(s1)
    800040d4:	0094ca83          	lbu	s5,9(s1)
    800040d8:	0104ba03          	ld	s4,16(s1)
    800040dc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800040e0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800040e4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800040e8:	0001c517          	auipc	a0,0x1c
    800040ec:	db850513          	addi	a0,a0,-584 # 8001fea0 <ftable>
    800040f0:	b77fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    800040f4:	4785                	li	a5,1
    800040f6:	04f90063          	beq	s2,a5,80004136 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800040fa:	3979                	addiw	s2,s2,-2
    800040fc:	4785                	li	a5,1
    800040fe:	0527f563          	bgeu	a5,s2,80004148 <fileclose+0xaa>
    80004102:	7902                	ld	s2,32(sp)
    80004104:	69e2                	ld	s3,24(sp)
    80004106:	6a42                	ld	s4,16(sp)
    80004108:	6aa2                	ld	s5,8(sp)
    8000410a:	a00d                	j	8000412c <fileclose+0x8e>
    8000410c:	f04a                	sd	s2,32(sp)
    8000410e:	ec4e                	sd	s3,24(sp)
    80004110:	e852                	sd	s4,16(sp)
    80004112:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004114:	00003517          	auipc	a0,0x3
    80004118:	45c50513          	addi	a0,a0,1116 # 80007570 <etext+0x570>
    8000411c:	ec4fc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    80004120:	0001c517          	auipc	a0,0x1c
    80004124:	d8050513          	addi	a0,a0,-640 # 8001fea0 <ftable>
    80004128:	b3ffc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000412c:	70e2                	ld	ra,56(sp)
    8000412e:	7442                	ld	s0,48(sp)
    80004130:	74a2                	ld	s1,40(sp)
    80004132:	6121                	addi	sp,sp,64
    80004134:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004136:	85d6                	mv	a1,s5
    80004138:	8552                	mv	a0,s4
    8000413a:	336000ef          	jal	80004470 <pipeclose>
    8000413e:	7902                	ld	s2,32(sp)
    80004140:	69e2                	ld	s3,24(sp)
    80004142:	6a42                	ld	s4,16(sp)
    80004144:	6aa2                	ld	s5,8(sp)
    80004146:	b7dd                	j	8000412c <fileclose+0x8e>
    begin_op();
    80004148:	b4bff0ef          	jal	80003c92 <begin_op>
    iput(ff.ip);
    8000414c:	854e                	mv	a0,s3
    8000414e:	adcff0ef          	jal	8000342a <iput>
    end_op();
    80004152:	babff0ef          	jal	80003cfc <end_op>
    80004156:	7902                	ld	s2,32(sp)
    80004158:	69e2                	ld	s3,24(sp)
    8000415a:	6a42                	ld	s4,16(sp)
    8000415c:	6aa2                	ld	s5,8(sp)
    8000415e:	b7f9                	j	8000412c <fileclose+0x8e>

0000000080004160 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004160:	715d                	addi	sp,sp,-80
    80004162:	e486                	sd	ra,72(sp)
    80004164:	e0a2                	sd	s0,64(sp)
    80004166:	fc26                	sd	s1,56(sp)
    80004168:	f44e                	sd	s3,40(sp)
    8000416a:	0880                	addi	s0,sp,80
    8000416c:	84aa                	mv	s1,a0
    8000416e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004170:	f5efd0ef          	jal	800018ce <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004174:	409c                	lw	a5,0(s1)
    80004176:	37f9                	addiw	a5,a5,-2
    80004178:	4705                	li	a4,1
    8000417a:	04f76063          	bltu	a4,a5,800041ba <filestat+0x5a>
    8000417e:	f84a                	sd	s2,48(sp)
    80004180:	892a                	mv	s2,a0
    ilock(f->ip);
    80004182:	6c88                	ld	a0,24(s1)
    80004184:	924ff0ef          	jal	800032a8 <ilock>
    stati(f->ip, &st);
    80004188:	fb840593          	addi	a1,s0,-72
    8000418c:	6c88                	ld	a0,24(s1)
    8000418e:	c80ff0ef          	jal	8000360e <stati>
    iunlock(f->ip);
    80004192:	6c88                	ld	a0,24(s1)
    80004194:	9c2ff0ef          	jal	80003356 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004198:	46e1                	li	a3,24
    8000419a:	fb840613          	addi	a2,s0,-72
    8000419e:	85ce                	mv	a1,s3
    800041a0:	05093503          	ld	a0,80(s2)
    800041a4:	c3efd0ef          	jal	800015e2 <copyout>
    800041a8:	41f5551b          	sraiw	a0,a0,0x1f
    800041ac:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800041ae:	60a6                	ld	ra,72(sp)
    800041b0:	6406                	ld	s0,64(sp)
    800041b2:	74e2                	ld	s1,56(sp)
    800041b4:	79a2                	ld	s3,40(sp)
    800041b6:	6161                	addi	sp,sp,80
    800041b8:	8082                	ret
  return -1;
    800041ba:	557d                	li	a0,-1
    800041bc:	bfcd                	j	800041ae <filestat+0x4e>

00000000800041be <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800041be:	7179                	addi	sp,sp,-48
    800041c0:	f406                	sd	ra,40(sp)
    800041c2:	f022                	sd	s0,32(sp)
    800041c4:	e84a                	sd	s2,16(sp)
    800041c6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800041c8:	00854783          	lbu	a5,8(a0)
    800041cc:	cfd1                	beqz	a5,80004268 <fileread+0xaa>
    800041ce:	ec26                	sd	s1,24(sp)
    800041d0:	e44e                	sd	s3,8(sp)
    800041d2:	84aa                	mv	s1,a0
    800041d4:	89ae                	mv	s3,a1
    800041d6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800041d8:	411c                	lw	a5,0(a0)
    800041da:	4705                	li	a4,1
    800041dc:	04e78363          	beq	a5,a4,80004222 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800041e0:	470d                	li	a4,3
    800041e2:	04e78763          	beq	a5,a4,80004230 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800041e6:	4709                	li	a4,2
    800041e8:	06e79a63          	bne	a5,a4,8000425c <fileread+0x9e>
    ilock(f->ip);
    800041ec:	6d08                	ld	a0,24(a0)
    800041ee:	8baff0ef          	jal	800032a8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800041f2:	874a                	mv	a4,s2
    800041f4:	5094                	lw	a3,32(s1)
    800041f6:	864e                	mv	a2,s3
    800041f8:	4585                	li	a1,1
    800041fa:	6c88                	ld	a0,24(s1)
    800041fc:	c3cff0ef          	jal	80003638 <readi>
    80004200:	892a                	mv	s2,a0
    80004202:	00a05563          	blez	a0,8000420c <fileread+0x4e>
      f->off += r;
    80004206:	509c                	lw	a5,32(s1)
    80004208:	9fa9                	addw	a5,a5,a0
    8000420a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000420c:	6c88                	ld	a0,24(s1)
    8000420e:	948ff0ef          	jal	80003356 <iunlock>
    80004212:	64e2                	ld	s1,24(sp)
    80004214:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004216:	854a                	mv	a0,s2
    80004218:	70a2                	ld	ra,40(sp)
    8000421a:	7402                	ld	s0,32(sp)
    8000421c:	6942                	ld	s2,16(sp)
    8000421e:	6145                	addi	sp,sp,48
    80004220:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004222:	6908                	ld	a0,16(a0)
    80004224:	388000ef          	jal	800045ac <piperead>
    80004228:	892a                	mv	s2,a0
    8000422a:	64e2                	ld	s1,24(sp)
    8000422c:	69a2                	ld	s3,8(sp)
    8000422e:	b7e5                	j	80004216 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004230:	02451783          	lh	a5,36(a0)
    80004234:	03079693          	slli	a3,a5,0x30
    80004238:	92c1                	srli	a3,a3,0x30
    8000423a:	4725                	li	a4,9
    8000423c:	02d76863          	bltu	a4,a3,8000426c <fileread+0xae>
    80004240:	0792                	slli	a5,a5,0x4
    80004242:	0001c717          	auipc	a4,0x1c
    80004246:	bbe70713          	addi	a4,a4,-1090 # 8001fe00 <devsw>
    8000424a:	97ba                	add	a5,a5,a4
    8000424c:	639c                	ld	a5,0(a5)
    8000424e:	c39d                	beqz	a5,80004274 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004250:	4505                	li	a0,1
    80004252:	9782                	jalr	a5
    80004254:	892a                	mv	s2,a0
    80004256:	64e2                	ld	s1,24(sp)
    80004258:	69a2                	ld	s3,8(sp)
    8000425a:	bf75                	j	80004216 <fileread+0x58>
    panic("fileread");
    8000425c:	00003517          	auipc	a0,0x3
    80004260:	32450513          	addi	a0,a0,804 # 80007580 <etext+0x580>
    80004264:	d7cfc0ef          	jal	800007e0 <panic>
    return -1;
    80004268:	597d                	li	s2,-1
    8000426a:	b775                	j	80004216 <fileread+0x58>
      return -1;
    8000426c:	597d                	li	s2,-1
    8000426e:	64e2                	ld	s1,24(sp)
    80004270:	69a2                	ld	s3,8(sp)
    80004272:	b755                	j	80004216 <fileread+0x58>
    80004274:	597d                	li	s2,-1
    80004276:	64e2                	ld	s1,24(sp)
    80004278:	69a2                	ld	s3,8(sp)
    8000427a:	bf71                	j	80004216 <fileread+0x58>

000000008000427c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000427c:	00954783          	lbu	a5,9(a0)
    80004280:	10078b63          	beqz	a5,80004396 <filewrite+0x11a>
{
    80004284:	715d                	addi	sp,sp,-80
    80004286:	e486                	sd	ra,72(sp)
    80004288:	e0a2                	sd	s0,64(sp)
    8000428a:	f84a                	sd	s2,48(sp)
    8000428c:	f052                	sd	s4,32(sp)
    8000428e:	e85a                	sd	s6,16(sp)
    80004290:	0880                	addi	s0,sp,80
    80004292:	892a                	mv	s2,a0
    80004294:	8b2e                	mv	s6,a1
    80004296:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004298:	411c                	lw	a5,0(a0)
    8000429a:	4705                	li	a4,1
    8000429c:	02e78763          	beq	a5,a4,800042ca <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042a0:	470d                	li	a4,3
    800042a2:	02e78863          	beq	a5,a4,800042d2 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800042a6:	4709                	li	a4,2
    800042a8:	0ce79c63          	bne	a5,a4,80004380 <filewrite+0x104>
    800042ac:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800042ae:	0ac05863          	blez	a2,8000435e <filewrite+0xe2>
    800042b2:	fc26                	sd	s1,56(sp)
    800042b4:	ec56                	sd	s5,24(sp)
    800042b6:	e45e                	sd	s7,8(sp)
    800042b8:	e062                	sd	s8,0(sp)
    int i = 0;
    800042ba:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800042bc:	6b85                	lui	s7,0x1
    800042be:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800042c2:	6c05                	lui	s8,0x1
    800042c4:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800042c8:	a8b5                	j	80004344 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800042ca:	6908                	ld	a0,16(a0)
    800042cc:	1fc000ef          	jal	800044c8 <pipewrite>
    800042d0:	a04d                	j	80004372 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800042d2:	02451783          	lh	a5,36(a0)
    800042d6:	03079693          	slli	a3,a5,0x30
    800042da:	92c1                	srli	a3,a3,0x30
    800042dc:	4725                	li	a4,9
    800042de:	0ad76e63          	bltu	a4,a3,8000439a <filewrite+0x11e>
    800042e2:	0792                	slli	a5,a5,0x4
    800042e4:	0001c717          	auipc	a4,0x1c
    800042e8:	b1c70713          	addi	a4,a4,-1252 # 8001fe00 <devsw>
    800042ec:	97ba                	add	a5,a5,a4
    800042ee:	679c                	ld	a5,8(a5)
    800042f0:	c7dd                	beqz	a5,8000439e <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800042f2:	4505                	li	a0,1
    800042f4:	9782                	jalr	a5
    800042f6:	a8b5                	j	80004372 <filewrite+0xf6>
      if(n1 > max)
    800042f8:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800042fc:	997ff0ef          	jal	80003c92 <begin_op>
      ilock(f->ip);
    80004300:	01893503          	ld	a0,24(s2)
    80004304:	fa5fe0ef          	jal	800032a8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004308:	8756                	mv	a4,s5
    8000430a:	02092683          	lw	a3,32(s2)
    8000430e:	01698633          	add	a2,s3,s6
    80004312:	4585                	li	a1,1
    80004314:	01893503          	ld	a0,24(s2)
    80004318:	c1cff0ef          	jal	80003734 <writei>
    8000431c:	84aa                	mv	s1,a0
    8000431e:	00a05763          	blez	a0,8000432c <filewrite+0xb0>
        f->off += r;
    80004322:	02092783          	lw	a5,32(s2)
    80004326:	9fa9                	addw	a5,a5,a0
    80004328:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000432c:	01893503          	ld	a0,24(s2)
    80004330:	826ff0ef          	jal	80003356 <iunlock>
      end_op();
    80004334:	9c9ff0ef          	jal	80003cfc <end_op>

      if(r != n1){
    80004338:	029a9563          	bne	s5,s1,80004362 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000433c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004340:	0149da63          	bge	s3,s4,80004354 <filewrite+0xd8>
      int n1 = n - i;
    80004344:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004348:	0004879b          	sext.w	a5,s1
    8000434c:	fafbd6e3          	bge	s7,a5,800042f8 <filewrite+0x7c>
    80004350:	84e2                	mv	s1,s8
    80004352:	b75d                	j	800042f8 <filewrite+0x7c>
    80004354:	74e2                	ld	s1,56(sp)
    80004356:	6ae2                	ld	s5,24(sp)
    80004358:	6ba2                	ld	s7,8(sp)
    8000435a:	6c02                	ld	s8,0(sp)
    8000435c:	a039                	j	8000436a <filewrite+0xee>
    int i = 0;
    8000435e:	4981                	li	s3,0
    80004360:	a029                	j	8000436a <filewrite+0xee>
    80004362:	74e2                	ld	s1,56(sp)
    80004364:	6ae2                	ld	s5,24(sp)
    80004366:	6ba2                	ld	s7,8(sp)
    80004368:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000436a:	033a1c63          	bne	s4,s3,800043a2 <filewrite+0x126>
    8000436e:	8552                	mv	a0,s4
    80004370:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004372:	60a6                	ld	ra,72(sp)
    80004374:	6406                	ld	s0,64(sp)
    80004376:	7942                	ld	s2,48(sp)
    80004378:	7a02                	ld	s4,32(sp)
    8000437a:	6b42                	ld	s6,16(sp)
    8000437c:	6161                	addi	sp,sp,80
    8000437e:	8082                	ret
    80004380:	fc26                	sd	s1,56(sp)
    80004382:	f44e                	sd	s3,40(sp)
    80004384:	ec56                	sd	s5,24(sp)
    80004386:	e45e                	sd	s7,8(sp)
    80004388:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000438a:	00003517          	auipc	a0,0x3
    8000438e:	20650513          	addi	a0,a0,518 # 80007590 <etext+0x590>
    80004392:	c4efc0ef          	jal	800007e0 <panic>
    return -1;
    80004396:	557d                	li	a0,-1
}
    80004398:	8082                	ret
      return -1;
    8000439a:	557d                	li	a0,-1
    8000439c:	bfd9                	j	80004372 <filewrite+0xf6>
    8000439e:	557d                	li	a0,-1
    800043a0:	bfc9                	j	80004372 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800043a2:	557d                	li	a0,-1
    800043a4:	79a2                	ld	s3,40(sp)
    800043a6:	b7f1                	j	80004372 <filewrite+0xf6>

00000000800043a8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800043a8:	7179                	addi	sp,sp,-48
    800043aa:	f406                	sd	ra,40(sp)
    800043ac:	f022                	sd	s0,32(sp)
    800043ae:	ec26                	sd	s1,24(sp)
    800043b0:	e052                	sd	s4,0(sp)
    800043b2:	1800                	addi	s0,sp,48
    800043b4:	84aa                	mv	s1,a0
    800043b6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800043b8:	0005b023          	sd	zero,0(a1)
    800043bc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800043c0:	c3bff0ef          	jal	80003ffa <filealloc>
    800043c4:	e088                	sd	a0,0(s1)
    800043c6:	c549                	beqz	a0,80004450 <pipealloc+0xa8>
    800043c8:	c33ff0ef          	jal	80003ffa <filealloc>
    800043cc:	00aa3023          	sd	a0,0(s4)
    800043d0:	cd25                	beqz	a0,80004448 <pipealloc+0xa0>
    800043d2:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800043d4:	f2afc0ef          	jal	80000afe <kalloc>
    800043d8:	892a                	mv	s2,a0
    800043da:	c12d                	beqz	a0,8000443c <pipealloc+0x94>
    800043dc:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800043de:	4985                	li	s3,1
    800043e0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800043e4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800043e8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800043ec:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800043f0:	00003597          	auipc	a1,0x3
    800043f4:	1b058593          	addi	a1,a1,432 # 800075a0 <etext+0x5a0>
    800043f8:	f56fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    800043fc:	609c                	ld	a5,0(s1)
    800043fe:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004402:	609c                	ld	a5,0(s1)
    80004404:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004408:	609c                	ld	a5,0(s1)
    8000440a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000440e:	609c                	ld	a5,0(s1)
    80004410:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004414:	000a3783          	ld	a5,0(s4)
    80004418:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000441c:	000a3783          	ld	a5,0(s4)
    80004420:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004424:	000a3783          	ld	a5,0(s4)
    80004428:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000442c:	000a3783          	ld	a5,0(s4)
    80004430:	0127b823          	sd	s2,16(a5)
  return 0;
    80004434:	4501                	li	a0,0
    80004436:	6942                	ld	s2,16(sp)
    80004438:	69a2                	ld	s3,8(sp)
    8000443a:	a01d                	j	80004460 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000443c:	6088                	ld	a0,0(s1)
    8000443e:	c119                	beqz	a0,80004444 <pipealloc+0x9c>
    80004440:	6942                	ld	s2,16(sp)
    80004442:	a029                	j	8000444c <pipealloc+0xa4>
    80004444:	6942                	ld	s2,16(sp)
    80004446:	a029                	j	80004450 <pipealloc+0xa8>
    80004448:	6088                	ld	a0,0(s1)
    8000444a:	c10d                	beqz	a0,8000446c <pipealloc+0xc4>
    fileclose(*f0);
    8000444c:	c53ff0ef          	jal	8000409e <fileclose>
  if(*f1)
    80004450:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004454:	557d                	li	a0,-1
  if(*f1)
    80004456:	c789                	beqz	a5,80004460 <pipealloc+0xb8>
    fileclose(*f1);
    80004458:	853e                	mv	a0,a5
    8000445a:	c45ff0ef          	jal	8000409e <fileclose>
  return -1;
    8000445e:	557d                	li	a0,-1
}
    80004460:	70a2                	ld	ra,40(sp)
    80004462:	7402                	ld	s0,32(sp)
    80004464:	64e2                	ld	s1,24(sp)
    80004466:	6a02                	ld	s4,0(sp)
    80004468:	6145                	addi	sp,sp,48
    8000446a:	8082                	ret
  return -1;
    8000446c:	557d                	li	a0,-1
    8000446e:	bfcd                	j	80004460 <pipealloc+0xb8>

0000000080004470 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004470:	1101                	addi	sp,sp,-32
    80004472:	ec06                	sd	ra,24(sp)
    80004474:	e822                	sd	s0,16(sp)
    80004476:	e426                	sd	s1,8(sp)
    80004478:	e04a                	sd	s2,0(sp)
    8000447a:	1000                	addi	s0,sp,32
    8000447c:	84aa                	mv	s1,a0
    8000447e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004480:	f4efc0ef          	jal	80000bce <acquire>
  if(writable){
    80004484:	02090763          	beqz	s2,800044b2 <pipeclose+0x42>
    pi->writeopen = 0;
    80004488:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000448c:	21848513          	addi	a0,s1,536
    80004490:	ab5fd0ef          	jal	80001f44 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004494:	2204b783          	ld	a5,544(s1)
    80004498:	e785                	bnez	a5,800044c0 <pipeclose+0x50>
    release(&pi->lock);
    8000449a:	8526                	mv	a0,s1
    8000449c:	fcafc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    800044a0:	8526                	mv	a0,s1
    800044a2:	d7afc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    800044a6:	60e2                	ld	ra,24(sp)
    800044a8:	6442                	ld	s0,16(sp)
    800044aa:	64a2                	ld	s1,8(sp)
    800044ac:	6902                	ld	s2,0(sp)
    800044ae:	6105                	addi	sp,sp,32
    800044b0:	8082                	ret
    pi->readopen = 0;
    800044b2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800044b6:	21c48513          	addi	a0,s1,540
    800044ba:	a8bfd0ef          	jal	80001f44 <wakeup>
    800044be:	bfd9                	j	80004494 <pipeclose+0x24>
    release(&pi->lock);
    800044c0:	8526                	mv	a0,s1
    800044c2:	fa4fc0ef          	jal	80000c66 <release>
}
    800044c6:	b7c5                	j	800044a6 <pipeclose+0x36>

00000000800044c8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800044c8:	711d                	addi	sp,sp,-96
    800044ca:	ec86                	sd	ra,88(sp)
    800044cc:	e8a2                	sd	s0,80(sp)
    800044ce:	e4a6                	sd	s1,72(sp)
    800044d0:	e0ca                	sd	s2,64(sp)
    800044d2:	fc4e                	sd	s3,56(sp)
    800044d4:	f852                	sd	s4,48(sp)
    800044d6:	f456                	sd	s5,40(sp)
    800044d8:	1080                	addi	s0,sp,96
    800044da:	84aa                	mv	s1,a0
    800044dc:	8aae                	mv	s5,a1
    800044de:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800044e0:	beefd0ef          	jal	800018ce <myproc>
    800044e4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800044e6:	8526                	mv	a0,s1
    800044e8:	ee6fc0ef          	jal	80000bce <acquire>
  while(i < n){
    800044ec:	0b405a63          	blez	s4,800045a0 <pipewrite+0xd8>
    800044f0:	f05a                	sd	s6,32(sp)
    800044f2:	ec5e                	sd	s7,24(sp)
    800044f4:	e862                	sd	s8,16(sp)
  int i = 0;
    800044f6:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800044f8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800044fa:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800044fe:	21c48b93          	addi	s7,s1,540
    80004502:	a81d                	j	80004538 <pipewrite+0x70>
      release(&pi->lock);
    80004504:	8526                	mv	a0,s1
    80004506:	f60fc0ef          	jal	80000c66 <release>
      return -1;
    8000450a:	597d                	li	s2,-1
    8000450c:	7b02                	ld	s6,32(sp)
    8000450e:	6be2                	ld	s7,24(sp)
    80004510:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004512:	854a                	mv	a0,s2
    80004514:	60e6                	ld	ra,88(sp)
    80004516:	6446                	ld	s0,80(sp)
    80004518:	64a6                	ld	s1,72(sp)
    8000451a:	6906                	ld	s2,64(sp)
    8000451c:	79e2                	ld	s3,56(sp)
    8000451e:	7a42                	ld	s4,48(sp)
    80004520:	7aa2                	ld	s5,40(sp)
    80004522:	6125                	addi	sp,sp,96
    80004524:	8082                	ret
      wakeup(&pi->nread);
    80004526:	8562                	mv	a0,s8
    80004528:	a1dfd0ef          	jal	80001f44 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000452c:	85a6                	mv	a1,s1
    8000452e:	855e                	mv	a0,s7
    80004530:	9c9fd0ef          	jal	80001ef8 <sleep>
  while(i < n){
    80004534:	05495b63          	bge	s2,s4,8000458a <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004538:	2204a783          	lw	a5,544(s1)
    8000453c:	d7e1                	beqz	a5,80004504 <pipewrite+0x3c>
    8000453e:	854e                	mv	a0,s3
    80004540:	bf1fd0ef          	jal	80002130 <killed>
    80004544:	f161                	bnez	a0,80004504 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004546:	2184a783          	lw	a5,536(s1)
    8000454a:	21c4a703          	lw	a4,540(s1)
    8000454e:	2007879b          	addiw	a5,a5,512
    80004552:	fcf70ae3          	beq	a4,a5,80004526 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004556:	4685                	li	a3,1
    80004558:	01590633          	add	a2,s2,s5
    8000455c:	faf40593          	addi	a1,s0,-81
    80004560:	0509b503          	ld	a0,80(s3)
    80004564:	962fd0ef          	jal	800016c6 <copyin>
    80004568:	03650e63          	beq	a0,s6,800045a4 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000456c:	21c4a783          	lw	a5,540(s1)
    80004570:	0017871b          	addiw	a4,a5,1
    80004574:	20e4ae23          	sw	a4,540(s1)
    80004578:	1ff7f793          	andi	a5,a5,511
    8000457c:	97a6                	add	a5,a5,s1
    8000457e:	faf44703          	lbu	a4,-81(s0)
    80004582:	00e78c23          	sb	a4,24(a5)
      i++;
    80004586:	2905                	addiw	s2,s2,1
    80004588:	b775                	j	80004534 <pipewrite+0x6c>
    8000458a:	7b02                	ld	s6,32(sp)
    8000458c:	6be2                	ld	s7,24(sp)
    8000458e:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004590:	21848513          	addi	a0,s1,536
    80004594:	9b1fd0ef          	jal	80001f44 <wakeup>
  release(&pi->lock);
    80004598:	8526                	mv	a0,s1
    8000459a:	eccfc0ef          	jal	80000c66 <release>
  return i;
    8000459e:	bf95                	j	80004512 <pipewrite+0x4a>
  int i = 0;
    800045a0:	4901                	li	s2,0
    800045a2:	b7fd                	j	80004590 <pipewrite+0xc8>
    800045a4:	7b02                	ld	s6,32(sp)
    800045a6:	6be2                	ld	s7,24(sp)
    800045a8:	6c42                	ld	s8,16(sp)
    800045aa:	b7dd                	j	80004590 <pipewrite+0xc8>

00000000800045ac <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800045ac:	715d                	addi	sp,sp,-80
    800045ae:	e486                	sd	ra,72(sp)
    800045b0:	e0a2                	sd	s0,64(sp)
    800045b2:	fc26                	sd	s1,56(sp)
    800045b4:	f84a                	sd	s2,48(sp)
    800045b6:	f44e                	sd	s3,40(sp)
    800045b8:	f052                	sd	s4,32(sp)
    800045ba:	ec56                	sd	s5,24(sp)
    800045bc:	0880                	addi	s0,sp,80
    800045be:	84aa                	mv	s1,a0
    800045c0:	892e                	mv	s2,a1
    800045c2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800045c4:	b0afd0ef          	jal	800018ce <myproc>
    800045c8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800045ca:	8526                	mv	a0,s1
    800045cc:	e02fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045d0:	2184a703          	lw	a4,536(s1)
    800045d4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800045d8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045dc:	02f71563          	bne	a4,a5,80004606 <piperead+0x5a>
    800045e0:	2244a783          	lw	a5,548(s1)
    800045e4:	cb85                	beqz	a5,80004614 <piperead+0x68>
    if(killed(pr)){
    800045e6:	8552                	mv	a0,s4
    800045e8:	b49fd0ef          	jal	80002130 <killed>
    800045ec:	ed19                	bnez	a0,8000460a <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800045ee:	85a6                	mv	a1,s1
    800045f0:	854e                	mv	a0,s3
    800045f2:	907fd0ef          	jal	80001ef8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045f6:	2184a703          	lw	a4,536(s1)
    800045fa:	21c4a783          	lw	a5,540(s1)
    800045fe:	fef701e3          	beq	a4,a5,800045e0 <piperead+0x34>
    80004602:	e85a                	sd	s6,16(sp)
    80004604:	a809                	j	80004616 <piperead+0x6a>
    80004606:	e85a                	sd	s6,16(sp)
    80004608:	a039                	j	80004616 <piperead+0x6a>
      release(&pi->lock);
    8000460a:	8526                	mv	a0,s1
    8000460c:	e5afc0ef          	jal	80000c66 <release>
      return -1;
    80004610:	59fd                	li	s3,-1
    80004612:	a8b9                	j	80004670 <piperead+0xc4>
    80004614:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004616:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004618:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000461a:	05505363          	blez	s5,80004660 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    8000461e:	2184a783          	lw	a5,536(s1)
    80004622:	21c4a703          	lw	a4,540(s1)
    80004626:	02f70d63          	beq	a4,a5,80004660 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    8000462a:	1ff7f793          	andi	a5,a5,511
    8000462e:	97a6                	add	a5,a5,s1
    80004630:	0187c783          	lbu	a5,24(a5)
    80004634:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004638:	4685                	li	a3,1
    8000463a:	fbf40613          	addi	a2,s0,-65
    8000463e:	85ca                	mv	a1,s2
    80004640:	050a3503          	ld	a0,80(s4)
    80004644:	f9ffc0ef          	jal	800015e2 <copyout>
    80004648:	03650e63          	beq	a0,s6,80004684 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000464c:	2184a783          	lw	a5,536(s1)
    80004650:	2785                	addiw	a5,a5,1
    80004652:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004656:	2985                	addiw	s3,s3,1
    80004658:	0905                	addi	s2,s2,1
    8000465a:	fd3a92e3          	bne	s5,s3,8000461e <piperead+0x72>
    8000465e:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004660:	21c48513          	addi	a0,s1,540
    80004664:	8e1fd0ef          	jal	80001f44 <wakeup>
  release(&pi->lock);
    80004668:	8526                	mv	a0,s1
    8000466a:	dfcfc0ef          	jal	80000c66 <release>
    8000466e:	6b42                	ld	s6,16(sp)
  return i;
}
    80004670:	854e                	mv	a0,s3
    80004672:	60a6                	ld	ra,72(sp)
    80004674:	6406                	ld	s0,64(sp)
    80004676:	74e2                	ld	s1,56(sp)
    80004678:	7942                	ld	s2,48(sp)
    8000467a:	79a2                	ld	s3,40(sp)
    8000467c:	7a02                	ld	s4,32(sp)
    8000467e:	6ae2                	ld	s5,24(sp)
    80004680:	6161                	addi	sp,sp,80
    80004682:	8082                	ret
      if(i == 0)
    80004684:	fc099ee3          	bnez	s3,80004660 <piperead+0xb4>
        i = -1;
    80004688:	89aa                	mv	s3,a0
    8000468a:	bfd9                	j	80004660 <piperead+0xb4>

000000008000468c <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    8000468c:	1141                	addi	sp,sp,-16
    8000468e:	e422                	sd	s0,8(sp)
    80004690:	0800                	addi	s0,sp,16
    80004692:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004694:	8905                	andi	a0,a0,1
    80004696:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004698:	8b89                	andi	a5,a5,2
    8000469a:	c399                	beqz	a5,800046a0 <flags2perm+0x14>
      perm |= PTE_W;
    8000469c:	00456513          	ori	a0,a0,4
    return perm;
}
    800046a0:	6422                	ld	s0,8(sp)
    800046a2:	0141                	addi	sp,sp,16
    800046a4:	8082                	ret

00000000800046a6 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800046a6:	df010113          	addi	sp,sp,-528
    800046aa:	20113423          	sd	ra,520(sp)
    800046ae:	20813023          	sd	s0,512(sp)
    800046b2:	ffa6                	sd	s1,504(sp)
    800046b4:	fbca                	sd	s2,496(sp)
    800046b6:	0c00                	addi	s0,sp,528
    800046b8:	892a                	mv	s2,a0
    800046ba:	dea43c23          	sd	a0,-520(s0)
    800046be:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800046c2:	a0cfd0ef          	jal	800018ce <myproc>
    800046c6:	84aa                	mv	s1,a0

  begin_op();
    800046c8:	dcaff0ef          	jal	80003c92 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800046cc:	854a                	mv	a0,s2
    800046ce:	bf0ff0ef          	jal	80003abe <namei>
    800046d2:	c931                	beqz	a0,80004726 <kexec+0x80>
    800046d4:	f3d2                	sd	s4,480(sp)
    800046d6:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800046d8:	bd1fe0ef          	jal	800032a8 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800046dc:	04000713          	li	a4,64
    800046e0:	4681                	li	a3,0
    800046e2:	e5040613          	addi	a2,s0,-432
    800046e6:	4581                	li	a1,0
    800046e8:	8552                	mv	a0,s4
    800046ea:	f4ffe0ef          	jal	80003638 <readi>
    800046ee:	04000793          	li	a5,64
    800046f2:	00f51a63          	bne	a0,a5,80004706 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800046f6:	e5042703          	lw	a4,-432(s0)
    800046fa:	464c47b7          	lui	a5,0x464c4
    800046fe:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004702:	02f70663          	beq	a4,a5,8000472e <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004706:	8552                	mv	a0,s4
    80004708:	dabfe0ef          	jal	800034b2 <iunlockput>
    end_op();
    8000470c:	df0ff0ef          	jal	80003cfc <end_op>
  }
  return -1;
    80004710:	557d                	li	a0,-1
    80004712:	7a1e                	ld	s4,480(sp)
}
    80004714:	20813083          	ld	ra,520(sp)
    80004718:	20013403          	ld	s0,512(sp)
    8000471c:	74fe                	ld	s1,504(sp)
    8000471e:	795e                	ld	s2,496(sp)
    80004720:	21010113          	addi	sp,sp,528
    80004724:	8082                	ret
    end_op();
    80004726:	dd6ff0ef          	jal	80003cfc <end_op>
    return -1;
    8000472a:	557d                	li	a0,-1
    8000472c:	b7e5                	j	80004714 <kexec+0x6e>
    8000472e:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004730:	8526                	mv	a0,s1
    80004732:	aa2fd0ef          	jal	800019d4 <proc_pagetable>
    80004736:	8b2a                	mv	s6,a0
    80004738:	2c050b63          	beqz	a0,80004a0e <kexec+0x368>
    8000473c:	f7ce                	sd	s3,488(sp)
    8000473e:	efd6                	sd	s5,472(sp)
    80004740:	e7de                	sd	s7,456(sp)
    80004742:	e3e2                	sd	s8,448(sp)
    80004744:	ff66                	sd	s9,440(sp)
    80004746:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004748:	e7042d03          	lw	s10,-400(s0)
    8000474c:	e8845783          	lhu	a5,-376(s0)
    80004750:	12078963          	beqz	a5,80004882 <kexec+0x1dc>
    80004754:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004756:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004758:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    8000475a:	6c85                	lui	s9,0x1
    8000475c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004760:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004764:	6a85                	lui	s5,0x1
    80004766:	a085                	j	800047c6 <kexec+0x120>
      panic("loadseg: address should exist");
    80004768:	00003517          	auipc	a0,0x3
    8000476c:	e4050513          	addi	a0,a0,-448 # 800075a8 <etext+0x5a8>
    80004770:	870fc0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    80004774:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004776:	8726                	mv	a4,s1
    80004778:	012c06bb          	addw	a3,s8,s2
    8000477c:	4581                	li	a1,0
    8000477e:	8552                	mv	a0,s4
    80004780:	eb9fe0ef          	jal	80003638 <readi>
    80004784:	2501                	sext.w	a0,a0
    80004786:	24a49a63          	bne	s1,a0,800049da <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    8000478a:	012a893b          	addw	s2,s5,s2
    8000478e:	03397363          	bgeu	s2,s3,800047b4 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004792:	02091593          	slli	a1,s2,0x20
    80004796:	9181                	srli	a1,a1,0x20
    80004798:	95de                	add	a1,a1,s7
    8000479a:	855a                	mv	a0,s6
    8000479c:	815fc0ef          	jal	80000fb0 <walkaddr>
    800047a0:	862a                	mv	a2,a0
    if(pa == 0)
    800047a2:	d179                	beqz	a0,80004768 <kexec+0xc2>
    if(sz - i < PGSIZE)
    800047a4:	412984bb          	subw	s1,s3,s2
    800047a8:	0004879b          	sext.w	a5,s1
    800047ac:	fcfcf4e3          	bgeu	s9,a5,80004774 <kexec+0xce>
    800047b0:	84d6                	mv	s1,s5
    800047b2:	b7c9                	j	80004774 <kexec+0xce>
    sz = sz1;
    800047b4:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047b8:	2d85                	addiw	s11,s11,1
    800047ba:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800047be:	e8845783          	lhu	a5,-376(s0)
    800047c2:	08fdd063          	bge	s11,a5,80004842 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800047c6:	2d01                	sext.w	s10,s10
    800047c8:	03800713          	li	a4,56
    800047cc:	86ea                	mv	a3,s10
    800047ce:	e1840613          	addi	a2,s0,-488
    800047d2:	4581                	li	a1,0
    800047d4:	8552                	mv	a0,s4
    800047d6:	e63fe0ef          	jal	80003638 <readi>
    800047da:	03800793          	li	a5,56
    800047de:	1cf51663          	bne	a0,a5,800049aa <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800047e2:	e1842783          	lw	a5,-488(s0)
    800047e6:	4705                	li	a4,1
    800047e8:	fce798e3          	bne	a5,a4,800047b8 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    800047ec:	e4043483          	ld	s1,-448(s0)
    800047f0:	e3843783          	ld	a5,-456(s0)
    800047f4:	1af4ef63          	bltu	s1,a5,800049b2 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800047f8:	e2843783          	ld	a5,-472(s0)
    800047fc:	94be                	add	s1,s1,a5
    800047fe:	1af4ee63          	bltu	s1,a5,800049ba <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004802:	df043703          	ld	a4,-528(s0)
    80004806:	8ff9                	and	a5,a5,a4
    80004808:	1a079d63          	bnez	a5,800049c2 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000480c:	e1c42503          	lw	a0,-484(s0)
    80004810:	e7dff0ef          	jal	8000468c <flags2perm>
    80004814:	86aa                	mv	a3,a0
    80004816:	8626                	mv	a2,s1
    80004818:	85ca                	mv	a1,s2
    8000481a:	855a                	mv	a0,s6
    8000481c:	a6dfc0ef          	jal	80001288 <uvmalloc>
    80004820:	e0a43423          	sd	a0,-504(s0)
    80004824:	1a050363          	beqz	a0,800049ca <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004828:	e2843b83          	ld	s7,-472(s0)
    8000482c:	e2042c03          	lw	s8,-480(s0)
    80004830:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004834:	00098463          	beqz	s3,8000483c <kexec+0x196>
    80004838:	4901                	li	s2,0
    8000483a:	bfa1                	j	80004792 <kexec+0xec>
    sz = sz1;
    8000483c:	e0843903          	ld	s2,-504(s0)
    80004840:	bfa5                	j	800047b8 <kexec+0x112>
    80004842:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004844:	8552                	mv	a0,s4
    80004846:	c6dfe0ef          	jal	800034b2 <iunlockput>
  end_op();
    8000484a:	cb2ff0ef          	jal	80003cfc <end_op>
  p = myproc();
    8000484e:	880fd0ef          	jal	800018ce <myproc>
    80004852:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004854:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004858:	6985                	lui	s3,0x1
    8000485a:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000485c:	99ca                	add	s3,s3,s2
    8000485e:	77fd                	lui	a5,0xfffff
    80004860:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004864:	4691                	li	a3,4
    80004866:	6609                	lui	a2,0x2
    80004868:	964e                	add	a2,a2,s3
    8000486a:	85ce                	mv	a1,s3
    8000486c:	855a                	mv	a0,s6
    8000486e:	a1bfc0ef          	jal	80001288 <uvmalloc>
    80004872:	892a                	mv	s2,a0
    80004874:	e0a43423          	sd	a0,-504(s0)
    80004878:	e519                	bnez	a0,80004886 <kexec+0x1e0>
  if(pagetable)
    8000487a:	e1343423          	sd	s3,-504(s0)
    8000487e:	4a01                	li	s4,0
    80004880:	aab1                	j	800049dc <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004882:	4901                	li	s2,0
    80004884:	b7c1                	j	80004844 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004886:	75f9                	lui	a1,0xffffe
    80004888:	95aa                	add	a1,a1,a0
    8000488a:	855a                	mv	a0,s6
    8000488c:	bd3fc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004890:	7bfd                	lui	s7,0xfffff
    80004892:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004894:	e0043783          	ld	a5,-512(s0)
    80004898:	6388                	ld	a0,0(a5)
    8000489a:	cd39                	beqz	a0,800048f8 <kexec+0x252>
    8000489c:	e9040993          	addi	s3,s0,-368
    800048a0:	f9040c13          	addi	s8,s0,-112
    800048a4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800048a6:	d6cfc0ef          	jal	80000e12 <strlen>
    800048aa:	0015079b          	addiw	a5,a0,1
    800048ae:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800048b2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800048b6:	11796e63          	bltu	s2,s7,800049d2 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800048ba:	e0043d03          	ld	s10,-512(s0)
    800048be:	000d3a03          	ld	s4,0(s10)
    800048c2:	8552                	mv	a0,s4
    800048c4:	d4efc0ef          	jal	80000e12 <strlen>
    800048c8:	0015069b          	addiw	a3,a0,1
    800048cc:	8652                	mv	a2,s4
    800048ce:	85ca                	mv	a1,s2
    800048d0:	855a                	mv	a0,s6
    800048d2:	d11fc0ef          	jal	800015e2 <copyout>
    800048d6:	10054063          	bltz	a0,800049d6 <kexec+0x330>
    ustack[argc] = sp;
    800048da:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800048de:	0485                	addi	s1,s1,1
    800048e0:	008d0793          	addi	a5,s10,8
    800048e4:	e0f43023          	sd	a5,-512(s0)
    800048e8:	008d3503          	ld	a0,8(s10)
    800048ec:	c909                	beqz	a0,800048fe <kexec+0x258>
    if(argc >= MAXARG)
    800048ee:	09a1                	addi	s3,s3,8
    800048f0:	fb899be3          	bne	s3,s8,800048a6 <kexec+0x200>
  ip = 0;
    800048f4:	4a01                	li	s4,0
    800048f6:	a0dd                	j	800049dc <kexec+0x336>
  sp = sz;
    800048f8:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800048fc:	4481                	li	s1,0
  ustack[argc] = 0;
    800048fe:	00349793          	slli	a5,s1,0x3
    80004902:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffddff8>
    80004906:	97a2                	add	a5,a5,s0
    80004908:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000490c:	00148693          	addi	a3,s1,1
    80004910:	068e                	slli	a3,a3,0x3
    80004912:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004916:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000491a:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000491e:	f5796ee3          	bltu	s2,s7,8000487a <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004922:	e9040613          	addi	a2,s0,-368
    80004926:	85ca                	mv	a1,s2
    80004928:	855a                	mv	a0,s6
    8000492a:	cb9fc0ef          	jal	800015e2 <copyout>
    8000492e:	0e054263          	bltz	a0,80004a12 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004932:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004936:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000493a:	df843783          	ld	a5,-520(s0)
    8000493e:	0007c703          	lbu	a4,0(a5)
    80004942:	cf11                	beqz	a4,8000495e <kexec+0x2b8>
    80004944:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004946:	02f00693          	li	a3,47
    8000494a:	a039                	j	80004958 <kexec+0x2b2>
      last = s+1;
    8000494c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004950:	0785                	addi	a5,a5,1
    80004952:	fff7c703          	lbu	a4,-1(a5)
    80004956:	c701                	beqz	a4,8000495e <kexec+0x2b8>
    if(*s == '/')
    80004958:	fed71ce3          	bne	a4,a3,80004950 <kexec+0x2aa>
    8000495c:	bfc5                	j	8000494c <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    8000495e:	4641                	li	a2,16
    80004960:	df843583          	ld	a1,-520(s0)
    80004964:	160a8513          	addi	a0,s5,352
    80004968:	c78fc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    8000496c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004970:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004974:	e0843783          	ld	a5,-504(s0)
    80004978:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    8000497c:	058ab783          	ld	a5,88(s5)
    80004980:	e6843703          	ld	a4,-408(s0)
    80004984:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004986:	058ab783          	ld	a5,88(s5)
    8000498a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000498e:	85e6                	mv	a1,s9
    80004990:	8c8fd0ef          	jal	80001a58 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004994:	0004851b          	sext.w	a0,s1
    80004998:	79be                	ld	s3,488(sp)
    8000499a:	7a1e                	ld	s4,480(sp)
    8000499c:	6afe                	ld	s5,472(sp)
    8000499e:	6b5e                	ld	s6,464(sp)
    800049a0:	6bbe                	ld	s7,456(sp)
    800049a2:	6c1e                	ld	s8,448(sp)
    800049a4:	7cfa                	ld	s9,440(sp)
    800049a6:	7d5a                	ld	s10,432(sp)
    800049a8:	b3b5                	j	80004714 <kexec+0x6e>
    800049aa:	e1243423          	sd	s2,-504(s0)
    800049ae:	7dba                	ld	s11,424(sp)
    800049b0:	a035                	j	800049dc <kexec+0x336>
    800049b2:	e1243423          	sd	s2,-504(s0)
    800049b6:	7dba                	ld	s11,424(sp)
    800049b8:	a015                	j	800049dc <kexec+0x336>
    800049ba:	e1243423          	sd	s2,-504(s0)
    800049be:	7dba                	ld	s11,424(sp)
    800049c0:	a831                	j	800049dc <kexec+0x336>
    800049c2:	e1243423          	sd	s2,-504(s0)
    800049c6:	7dba                	ld	s11,424(sp)
    800049c8:	a811                	j	800049dc <kexec+0x336>
    800049ca:	e1243423          	sd	s2,-504(s0)
    800049ce:	7dba                	ld	s11,424(sp)
    800049d0:	a031                	j	800049dc <kexec+0x336>
  ip = 0;
    800049d2:	4a01                	li	s4,0
    800049d4:	a021                	j	800049dc <kexec+0x336>
    800049d6:	4a01                	li	s4,0
  if(pagetable)
    800049d8:	a011                	j	800049dc <kexec+0x336>
    800049da:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800049dc:	e0843583          	ld	a1,-504(s0)
    800049e0:	855a                	mv	a0,s6
    800049e2:	876fd0ef          	jal	80001a58 <proc_freepagetable>
  return -1;
    800049e6:	557d                	li	a0,-1
  if(ip){
    800049e8:	000a1b63          	bnez	s4,800049fe <kexec+0x358>
    800049ec:	79be                	ld	s3,488(sp)
    800049ee:	7a1e                	ld	s4,480(sp)
    800049f0:	6afe                	ld	s5,472(sp)
    800049f2:	6b5e                	ld	s6,464(sp)
    800049f4:	6bbe                	ld	s7,456(sp)
    800049f6:	6c1e                	ld	s8,448(sp)
    800049f8:	7cfa                	ld	s9,440(sp)
    800049fa:	7d5a                	ld	s10,432(sp)
    800049fc:	bb21                	j	80004714 <kexec+0x6e>
    800049fe:	79be                	ld	s3,488(sp)
    80004a00:	6afe                	ld	s5,472(sp)
    80004a02:	6b5e                	ld	s6,464(sp)
    80004a04:	6bbe                	ld	s7,456(sp)
    80004a06:	6c1e                	ld	s8,448(sp)
    80004a08:	7cfa                	ld	s9,440(sp)
    80004a0a:	7d5a                	ld	s10,432(sp)
    80004a0c:	b9ed                	j	80004706 <kexec+0x60>
    80004a0e:	6b5e                	ld	s6,464(sp)
    80004a10:	b9dd                	j	80004706 <kexec+0x60>
  sz = sz1;
    80004a12:	e0843983          	ld	s3,-504(s0)
    80004a16:	b595                	j	8000487a <kexec+0x1d4>

0000000080004a18 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a18:	7179                	addi	sp,sp,-48
    80004a1a:	f406                	sd	ra,40(sp)
    80004a1c:	f022                	sd	s0,32(sp)
    80004a1e:	ec26                	sd	s1,24(sp)
    80004a20:	e84a                	sd	s2,16(sp)
    80004a22:	1800                	addi	s0,sp,48
    80004a24:	892e                	mv	s2,a1
    80004a26:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a28:	fdc40593          	addi	a1,s0,-36
    80004a2c:	dd1fd0ef          	jal	800027fc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a30:	fdc42703          	lw	a4,-36(s0)
    80004a34:	47bd                	li	a5,15
    80004a36:	02e7e963          	bltu	a5,a4,80004a68 <argfd+0x50>
    80004a3a:	e95fc0ef          	jal	800018ce <myproc>
    80004a3e:	fdc42703          	lw	a4,-36(s0)
    80004a42:	01a70793          	addi	a5,a4,26
    80004a46:	078e                	slli	a5,a5,0x3
    80004a48:	953e                	add	a0,a0,a5
    80004a4a:	611c                	ld	a5,0(a0)
    80004a4c:	c385                	beqz	a5,80004a6c <argfd+0x54>
    return -1;
  if(pfd)
    80004a4e:	00090463          	beqz	s2,80004a56 <argfd+0x3e>
    *pfd = fd;
    80004a52:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004a56:	4501                	li	a0,0
  if(pf)
    80004a58:	c091                	beqz	s1,80004a5c <argfd+0x44>
    *pf = f;
    80004a5a:	e09c                	sd	a5,0(s1)
}
    80004a5c:	70a2                	ld	ra,40(sp)
    80004a5e:	7402                	ld	s0,32(sp)
    80004a60:	64e2                	ld	s1,24(sp)
    80004a62:	6942                	ld	s2,16(sp)
    80004a64:	6145                	addi	sp,sp,48
    80004a66:	8082                	ret
    return -1;
    80004a68:	557d                	li	a0,-1
    80004a6a:	bfcd                	j	80004a5c <argfd+0x44>
    80004a6c:	557d                	li	a0,-1
    80004a6e:	b7fd                	j	80004a5c <argfd+0x44>

0000000080004a70 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004a70:	1101                	addi	sp,sp,-32
    80004a72:	ec06                	sd	ra,24(sp)
    80004a74:	e822                	sd	s0,16(sp)
    80004a76:	e426                	sd	s1,8(sp)
    80004a78:	1000                	addi	s0,sp,32
    80004a7a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004a7c:	e53fc0ef          	jal	800018ce <myproc>
    80004a80:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004a82:	0d050793          	addi	a5,a0,208
    80004a86:	4501                	li	a0,0
    80004a88:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004a8a:	6398                	ld	a4,0(a5)
    80004a8c:	cb19                	beqz	a4,80004aa2 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004a8e:	2505                	addiw	a0,a0,1
    80004a90:	07a1                	addi	a5,a5,8
    80004a92:	fed51ce3          	bne	a0,a3,80004a8a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004a96:	557d                	li	a0,-1
}
    80004a98:	60e2                	ld	ra,24(sp)
    80004a9a:	6442                	ld	s0,16(sp)
    80004a9c:	64a2                	ld	s1,8(sp)
    80004a9e:	6105                	addi	sp,sp,32
    80004aa0:	8082                	ret
      p->ofile[fd] = f;
    80004aa2:	01a50793          	addi	a5,a0,26
    80004aa6:	078e                	slli	a5,a5,0x3
    80004aa8:	963e                	add	a2,a2,a5
    80004aaa:	e204                	sd	s1,0(a2)
      return fd;
    80004aac:	b7f5                	j	80004a98 <fdalloc+0x28>

0000000080004aae <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004aae:	715d                	addi	sp,sp,-80
    80004ab0:	e486                	sd	ra,72(sp)
    80004ab2:	e0a2                	sd	s0,64(sp)
    80004ab4:	fc26                	sd	s1,56(sp)
    80004ab6:	f84a                	sd	s2,48(sp)
    80004ab8:	f44e                	sd	s3,40(sp)
    80004aba:	ec56                	sd	s5,24(sp)
    80004abc:	e85a                	sd	s6,16(sp)
    80004abe:	0880                	addi	s0,sp,80
    80004ac0:	8b2e                	mv	s6,a1
    80004ac2:	89b2                	mv	s3,a2
    80004ac4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004ac6:	fb040593          	addi	a1,s0,-80
    80004aca:	80eff0ef          	jal	80003ad8 <nameiparent>
    80004ace:	84aa                	mv	s1,a0
    80004ad0:	10050a63          	beqz	a0,80004be4 <create+0x136>
    return 0;

  ilock(dp);
    80004ad4:	fd4fe0ef          	jal	800032a8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004ad8:	4601                	li	a2,0
    80004ada:	fb040593          	addi	a1,s0,-80
    80004ade:	8526                	mv	a0,s1
    80004ae0:	d79fe0ef          	jal	80003858 <dirlookup>
    80004ae4:	8aaa                	mv	s5,a0
    80004ae6:	c129                	beqz	a0,80004b28 <create+0x7a>
    iunlockput(dp);
    80004ae8:	8526                	mv	a0,s1
    80004aea:	9c9fe0ef          	jal	800034b2 <iunlockput>
    ilock(ip);
    80004aee:	8556                	mv	a0,s5
    80004af0:	fb8fe0ef          	jal	800032a8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004af4:	4789                	li	a5,2
    80004af6:	02fb1463          	bne	s6,a5,80004b1e <create+0x70>
    80004afa:	044ad783          	lhu	a5,68(s5)
    80004afe:	37f9                	addiw	a5,a5,-2
    80004b00:	17c2                	slli	a5,a5,0x30
    80004b02:	93c1                	srli	a5,a5,0x30
    80004b04:	4705                	li	a4,1
    80004b06:	00f76c63          	bltu	a4,a5,80004b1e <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b0a:	8556                	mv	a0,s5
    80004b0c:	60a6                	ld	ra,72(sp)
    80004b0e:	6406                	ld	s0,64(sp)
    80004b10:	74e2                	ld	s1,56(sp)
    80004b12:	7942                	ld	s2,48(sp)
    80004b14:	79a2                	ld	s3,40(sp)
    80004b16:	6ae2                	ld	s5,24(sp)
    80004b18:	6b42                	ld	s6,16(sp)
    80004b1a:	6161                	addi	sp,sp,80
    80004b1c:	8082                	ret
    iunlockput(ip);
    80004b1e:	8556                	mv	a0,s5
    80004b20:	993fe0ef          	jal	800034b2 <iunlockput>
    return 0;
    80004b24:	4a81                	li	s5,0
    80004b26:	b7d5                	j	80004b0a <create+0x5c>
    80004b28:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b2a:	85da                	mv	a1,s6
    80004b2c:	4088                	lw	a0,0(s1)
    80004b2e:	e0afe0ef          	jal	80003138 <ialloc>
    80004b32:	8a2a                	mv	s4,a0
    80004b34:	cd15                	beqz	a0,80004b70 <create+0xc2>
  ilock(ip);
    80004b36:	f72fe0ef          	jal	800032a8 <ilock>
  ip->major = major;
    80004b3a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004b3e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004b42:	4905                	li	s2,1
    80004b44:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004b48:	8552                	mv	a0,s4
    80004b4a:	eaafe0ef          	jal	800031f4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004b4e:	032b0763          	beq	s6,s2,80004b7c <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b52:	004a2603          	lw	a2,4(s4)
    80004b56:	fb040593          	addi	a1,s0,-80
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	ec9fe0ef          	jal	80003a24 <dirlink>
    80004b60:	06054563          	bltz	a0,80004bca <create+0x11c>
  iunlockput(dp);
    80004b64:	8526                	mv	a0,s1
    80004b66:	94dfe0ef          	jal	800034b2 <iunlockput>
  return ip;
    80004b6a:	8ad2                	mv	s5,s4
    80004b6c:	7a02                	ld	s4,32(sp)
    80004b6e:	bf71                	j	80004b0a <create+0x5c>
    iunlockput(dp);
    80004b70:	8526                	mv	a0,s1
    80004b72:	941fe0ef          	jal	800034b2 <iunlockput>
    return 0;
    80004b76:	8ad2                	mv	s5,s4
    80004b78:	7a02                	ld	s4,32(sp)
    80004b7a:	bf41                	j	80004b0a <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004b7c:	004a2603          	lw	a2,4(s4)
    80004b80:	00003597          	auipc	a1,0x3
    80004b84:	a4858593          	addi	a1,a1,-1464 # 800075c8 <etext+0x5c8>
    80004b88:	8552                	mv	a0,s4
    80004b8a:	e9bfe0ef          	jal	80003a24 <dirlink>
    80004b8e:	02054e63          	bltz	a0,80004bca <create+0x11c>
    80004b92:	40d0                	lw	a2,4(s1)
    80004b94:	00003597          	auipc	a1,0x3
    80004b98:	a3c58593          	addi	a1,a1,-1476 # 800075d0 <etext+0x5d0>
    80004b9c:	8552                	mv	a0,s4
    80004b9e:	e87fe0ef          	jal	80003a24 <dirlink>
    80004ba2:	02054463          	bltz	a0,80004bca <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ba6:	004a2603          	lw	a2,4(s4)
    80004baa:	fb040593          	addi	a1,s0,-80
    80004bae:	8526                	mv	a0,s1
    80004bb0:	e75fe0ef          	jal	80003a24 <dirlink>
    80004bb4:	00054b63          	bltz	a0,80004bca <create+0x11c>
    dp->nlink++;  // for ".."
    80004bb8:	04a4d783          	lhu	a5,74(s1)
    80004bbc:	2785                	addiw	a5,a5,1
    80004bbe:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004bc2:	8526                	mv	a0,s1
    80004bc4:	e30fe0ef          	jal	800031f4 <iupdate>
    80004bc8:	bf71                	j	80004b64 <create+0xb6>
  ip->nlink = 0;
    80004bca:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004bce:	8552                	mv	a0,s4
    80004bd0:	e24fe0ef          	jal	800031f4 <iupdate>
  iunlockput(ip);
    80004bd4:	8552                	mv	a0,s4
    80004bd6:	8ddfe0ef          	jal	800034b2 <iunlockput>
  iunlockput(dp);
    80004bda:	8526                	mv	a0,s1
    80004bdc:	8d7fe0ef          	jal	800034b2 <iunlockput>
  return 0;
    80004be0:	7a02                	ld	s4,32(sp)
    80004be2:	b725                	j	80004b0a <create+0x5c>
    return 0;
    80004be4:	8aaa                	mv	s5,a0
    80004be6:	b715                	j	80004b0a <create+0x5c>

0000000080004be8 <sys_dup>:
{
    80004be8:	7179                	addi	sp,sp,-48
    80004bea:	f406                	sd	ra,40(sp)
    80004bec:	f022                	sd	s0,32(sp)
    80004bee:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004bf0:	fd840613          	addi	a2,s0,-40
    80004bf4:	4581                	li	a1,0
    80004bf6:	4501                	li	a0,0
    80004bf8:	e21ff0ef          	jal	80004a18 <argfd>
    return -1;
    80004bfc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004bfe:	02054363          	bltz	a0,80004c24 <sys_dup+0x3c>
    80004c02:	ec26                	sd	s1,24(sp)
    80004c04:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004c06:	fd843903          	ld	s2,-40(s0)
    80004c0a:	854a                	mv	a0,s2
    80004c0c:	e65ff0ef          	jal	80004a70 <fdalloc>
    80004c10:	84aa                	mv	s1,a0
    return -1;
    80004c12:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004c14:	00054d63          	bltz	a0,80004c2e <sys_dup+0x46>
  filedup(f);
    80004c18:	854a                	mv	a0,s2
    80004c1a:	c3eff0ef          	jal	80004058 <filedup>
  return fd;
    80004c1e:	87a6                	mv	a5,s1
    80004c20:	64e2                	ld	s1,24(sp)
    80004c22:	6942                	ld	s2,16(sp)
}
    80004c24:	853e                	mv	a0,a5
    80004c26:	70a2                	ld	ra,40(sp)
    80004c28:	7402                	ld	s0,32(sp)
    80004c2a:	6145                	addi	sp,sp,48
    80004c2c:	8082                	ret
    80004c2e:	64e2                	ld	s1,24(sp)
    80004c30:	6942                	ld	s2,16(sp)
    80004c32:	bfcd                	j	80004c24 <sys_dup+0x3c>

0000000080004c34 <sys_read>:
{
    80004c34:	7179                	addi	sp,sp,-48
    80004c36:	f406                	sd	ra,40(sp)
    80004c38:	f022                	sd	s0,32(sp)
    80004c3a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c3c:	fd840593          	addi	a1,s0,-40
    80004c40:	4505                	li	a0,1
    80004c42:	bd9fd0ef          	jal	8000281a <argaddr>
  argint(2, &n);
    80004c46:	fe440593          	addi	a1,s0,-28
    80004c4a:	4509                	li	a0,2
    80004c4c:	bb1fd0ef          	jal	800027fc <argint>
  if(argfd(0, 0, &f) < 0)
    80004c50:	fe840613          	addi	a2,s0,-24
    80004c54:	4581                	li	a1,0
    80004c56:	4501                	li	a0,0
    80004c58:	dc1ff0ef          	jal	80004a18 <argfd>
    80004c5c:	87aa                	mv	a5,a0
    return -1;
    80004c5e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c60:	0007ca63          	bltz	a5,80004c74 <sys_read+0x40>
  return fileread(f, p, n);
    80004c64:	fe442603          	lw	a2,-28(s0)
    80004c68:	fd843583          	ld	a1,-40(s0)
    80004c6c:	fe843503          	ld	a0,-24(s0)
    80004c70:	d4eff0ef          	jal	800041be <fileread>
}
    80004c74:	70a2                	ld	ra,40(sp)
    80004c76:	7402                	ld	s0,32(sp)
    80004c78:	6145                	addi	sp,sp,48
    80004c7a:	8082                	ret

0000000080004c7c <sys_write>:
{
    80004c7c:	7179                	addi	sp,sp,-48
    80004c7e:	f406                	sd	ra,40(sp)
    80004c80:	f022                	sd	s0,32(sp)
    80004c82:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c84:	fd840593          	addi	a1,s0,-40
    80004c88:	4505                	li	a0,1
    80004c8a:	b91fd0ef          	jal	8000281a <argaddr>
  argint(2, &n);
    80004c8e:	fe440593          	addi	a1,s0,-28
    80004c92:	4509                	li	a0,2
    80004c94:	b69fd0ef          	jal	800027fc <argint>
  if(argfd(0, 0, &f) < 0)
    80004c98:	fe840613          	addi	a2,s0,-24
    80004c9c:	4581                	li	a1,0
    80004c9e:	4501                	li	a0,0
    80004ca0:	d79ff0ef          	jal	80004a18 <argfd>
    80004ca4:	87aa                	mv	a5,a0
    return -1;
    80004ca6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ca8:	0007ca63          	bltz	a5,80004cbc <sys_write+0x40>
  return filewrite(f, p, n);
    80004cac:	fe442603          	lw	a2,-28(s0)
    80004cb0:	fd843583          	ld	a1,-40(s0)
    80004cb4:	fe843503          	ld	a0,-24(s0)
    80004cb8:	dc4ff0ef          	jal	8000427c <filewrite>
}
    80004cbc:	70a2                	ld	ra,40(sp)
    80004cbe:	7402                	ld	s0,32(sp)
    80004cc0:	6145                	addi	sp,sp,48
    80004cc2:	8082                	ret

0000000080004cc4 <sys_close>:
{
    80004cc4:	1101                	addi	sp,sp,-32
    80004cc6:	ec06                	sd	ra,24(sp)
    80004cc8:	e822                	sd	s0,16(sp)
    80004cca:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004ccc:	fe040613          	addi	a2,s0,-32
    80004cd0:	fec40593          	addi	a1,s0,-20
    80004cd4:	4501                	li	a0,0
    80004cd6:	d43ff0ef          	jal	80004a18 <argfd>
    return -1;
    80004cda:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004cdc:	02054063          	bltz	a0,80004cfc <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004ce0:	beffc0ef          	jal	800018ce <myproc>
    80004ce4:	fec42783          	lw	a5,-20(s0)
    80004ce8:	07e9                	addi	a5,a5,26
    80004cea:	078e                	slli	a5,a5,0x3
    80004cec:	953e                	add	a0,a0,a5
    80004cee:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004cf2:	fe043503          	ld	a0,-32(s0)
    80004cf6:	ba8ff0ef          	jal	8000409e <fileclose>
  return 0;
    80004cfa:	4781                	li	a5,0
}
    80004cfc:	853e                	mv	a0,a5
    80004cfe:	60e2                	ld	ra,24(sp)
    80004d00:	6442                	ld	s0,16(sp)
    80004d02:	6105                	addi	sp,sp,32
    80004d04:	8082                	ret

0000000080004d06 <sys_fstat>:
{
    80004d06:	1101                	addi	sp,sp,-32
    80004d08:	ec06                	sd	ra,24(sp)
    80004d0a:	e822                	sd	s0,16(sp)
    80004d0c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d0e:	fe040593          	addi	a1,s0,-32
    80004d12:	4505                	li	a0,1
    80004d14:	b07fd0ef          	jal	8000281a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004d18:	fe840613          	addi	a2,s0,-24
    80004d1c:	4581                	li	a1,0
    80004d1e:	4501                	li	a0,0
    80004d20:	cf9ff0ef          	jal	80004a18 <argfd>
    80004d24:	87aa                	mv	a5,a0
    return -1;
    80004d26:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d28:	0007c863          	bltz	a5,80004d38 <sys_fstat+0x32>
  return filestat(f, st);
    80004d2c:	fe043583          	ld	a1,-32(s0)
    80004d30:	fe843503          	ld	a0,-24(s0)
    80004d34:	c2cff0ef          	jal	80004160 <filestat>
}
    80004d38:	60e2                	ld	ra,24(sp)
    80004d3a:	6442                	ld	s0,16(sp)
    80004d3c:	6105                	addi	sp,sp,32
    80004d3e:	8082                	ret

0000000080004d40 <sys_link>:
{
    80004d40:	7169                	addi	sp,sp,-304
    80004d42:	f606                	sd	ra,296(sp)
    80004d44:	f222                	sd	s0,288(sp)
    80004d46:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d48:	08000613          	li	a2,128
    80004d4c:	ed040593          	addi	a1,s0,-304
    80004d50:	4501                	li	a0,0
    80004d52:	ae7fd0ef          	jal	80002838 <argstr>
    return -1;
    80004d56:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d58:	0c054e63          	bltz	a0,80004e34 <sys_link+0xf4>
    80004d5c:	08000613          	li	a2,128
    80004d60:	f5040593          	addi	a1,s0,-176
    80004d64:	4505                	li	a0,1
    80004d66:	ad3fd0ef          	jal	80002838 <argstr>
    return -1;
    80004d6a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d6c:	0c054463          	bltz	a0,80004e34 <sys_link+0xf4>
    80004d70:	ee26                	sd	s1,280(sp)
  begin_op();
    80004d72:	f21fe0ef          	jal	80003c92 <begin_op>
  if((ip = namei(old)) == 0){
    80004d76:	ed040513          	addi	a0,s0,-304
    80004d7a:	d45fe0ef          	jal	80003abe <namei>
    80004d7e:	84aa                	mv	s1,a0
    80004d80:	c53d                	beqz	a0,80004dee <sys_link+0xae>
  ilock(ip);
    80004d82:	d26fe0ef          	jal	800032a8 <ilock>
  if(ip->type == T_DIR){
    80004d86:	04449703          	lh	a4,68(s1)
    80004d8a:	4785                	li	a5,1
    80004d8c:	06f70663          	beq	a4,a5,80004df8 <sys_link+0xb8>
    80004d90:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004d92:	04a4d783          	lhu	a5,74(s1)
    80004d96:	2785                	addiw	a5,a5,1
    80004d98:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d9c:	8526                	mv	a0,s1
    80004d9e:	c56fe0ef          	jal	800031f4 <iupdate>
  iunlock(ip);
    80004da2:	8526                	mv	a0,s1
    80004da4:	db2fe0ef          	jal	80003356 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004da8:	fd040593          	addi	a1,s0,-48
    80004dac:	f5040513          	addi	a0,s0,-176
    80004db0:	d29fe0ef          	jal	80003ad8 <nameiparent>
    80004db4:	892a                	mv	s2,a0
    80004db6:	cd21                	beqz	a0,80004e0e <sys_link+0xce>
  ilock(dp);
    80004db8:	cf0fe0ef          	jal	800032a8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004dbc:	00092703          	lw	a4,0(s2)
    80004dc0:	409c                	lw	a5,0(s1)
    80004dc2:	04f71363          	bne	a4,a5,80004e08 <sys_link+0xc8>
    80004dc6:	40d0                	lw	a2,4(s1)
    80004dc8:	fd040593          	addi	a1,s0,-48
    80004dcc:	854a                	mv	a0,s2
    80004dce:	c57fe0ef          	jal	80003a24 <dirlink>
    80004dd2:	02054b63          	bltz	a0,80004e08 <sys_link+0xc8>
  iunlockput(dp);
    80004dd6:	854a                	mv	a0,s2
    80004dd8:	edafe0ef          	jal	800034b2 <iunlockput>
  iput(ip);
    80004ddc:	8526                	mv	a0,s1
    80004dde:	e4cfe0ef          	jal	8000342a <iput>
  end_op();
    80004de2:	f1bfe0ef          	jal	80003cfc <end_op>
  return 0;
    80004de6:	4781                	li	a5,0
    80004de8:	64f2                	ld	s1,280(sp)
    80004dea:	6952                	ld	s2,272(sp)
    80004dec:	a0a1                	j	80004e34 <sys_link+0xf4>
    end_op();
    80004dee:	f0ffe0ef          	jal	80003cfc <end_op>
    return -1;
    80004df2:	57fd                	li	a5,-1
    80004df4:	64f2                	ld	s1,280(sp)
    80004df6:	a83d                	j	80004e34 <sys_link+0xf4>
    iunlockput(ip);
    80004df8:	8526                	mv	a0,s1
    80004dfa:	eb8fe0ef          	jal	800034b2 <iunlockput>
    end_op();
    80004dfe:	efffe0ef          	jal	80003cfc <end_op>
    return -1;
    80004e02:	57fd                	li	a5,-1
    80004e04:	64f2                	ld	s1,280(sp)
    80004e06:	a03d                	j	80004e34 <sys_link+0xf4>
    iunlockput(dp);
    80004e08:	854a                	mv	a0,s2
    80004e0a:	ea8fe0ef          	jal	800034b2 <iunlockput>
  ilock(ip);
    80004e0e:	8526                	mv	a0,s1
    80004e10:	c98fe0ef          	jal	800032a8 <ilock>
  ip->nlink--;
    80004e14:	04a4d783          	lhu	a5,74(s1)
    80004e18:	37fd                	addiw	a5,a5,-1
    80004e1a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e1e:	8526                	mv	a0,s1
    80004e20:	bd4fe0ef          	jal	800031f4 <iupdate>
  iunlockput(ip);
    80004e24:	8526                	mv	a0,s1
    80004e26:	e8cfe0ef          	jal	800034b2 <iunlockput>
  end_op();
    80004e2a:	ed3fe0ef          	jal	80003cfc <end_op>
  return -1;
    80004e2e:	57fd                	li	a5,-1
    80004e30:	64f2                	ld	s1,280(sp)
    80004e32:	6952                	ld	s2,272(sp)
}
    80004e34:	853e                	mv	a0,a5
    80004e36:	70b2                	ld	ra,296(sp)
    80004e38:	7412                	ld	s0,288(sp)
    80004e3a:	6155                	addi	sp,sp,304
    80004e3c:	8082                	ret

0000000080004e3e <sys_unlink>:
{
    80004e3e:	7151                	addi	sp,sp,-240
    80004e40:	f586                	sd	ra,232(sp)
    80004e42:	f1a2                	sd	s0,224(sp)
    80004e44:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004e46:	08000613          	li	a2,128
    80004e4a:	f3040593          	addi	a1,s0,-208
    80004e4e:	4501                	li	a0,0
    80004e50:	9e9fd0ef          	jal	80002838 <argstr>
    80004e54:	16054063          	bltz	a0,80004fb4 <sys_unlink+0x176>
    80004e58:	eda6                	sd	s1,216(sp)
  begin_op();
    80004e5a:	e39fe0ef          	jal	80003c92 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004e5e:	fb040593          	addi	a1,s0,-80
    80004e62:	f3040513          	addi	a0,s0,-208
    80004e66:	c73fe0ef          	jal	80003ad8 <nameiparent>
    80004e6a:	84aa                	mv	s1,a0
    80004e6c:	c945                	beqz	a0,80004f1c <sys_unlink+0xde>
  ilock(dp);
    80004e6e:	c3afe0ef          	jal	800032a8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004e72:	00002597          	auipc	a1,0x2
    80004e76:	75658593          	addi	a1,a1,1878 # 800075c8 <etext+0x5c8>
    80004e7a:	fb040513          	addi	a0,s0,-80
    80004e7e:	9c5fe0ef          	jal	80003842 <namecmp>
    80004e82:	10050e63          	beqz	a0,80004f9e <sys_unlink+0x160>
    80004e86:	00002597          	auipc	a1,0x2
    80004e8a:	74a58593          	addi	a1,a1,1866 # 800075d0 <etext+0x5d0>
    80004e8e:	fb040513          	addi	a0,s0,-80
    80004e92:	9b1fe0ef          	jal	80003842 <namecmp>
    80004e96:	10050463          	beqz	a0,80004f9e <sys_unlink+0x160>
    80004e9a:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004e9c:	f2c40613          	addi	a2,s0,-212
    80004ea0:	fb040593          	addi	a1,s0,-80
    80004ea4:	8526                	mv	a0,s1
    80004ea6:	9b3fe0ef          	jal	80003858 <dirlookup>
    80004eaa:	892a                	mv	s2,a0
    80004eac:	0e050863          	beqz	a0,80004f9c <sys_unlink+0x15e>
  ilock(ip);
    80004eb0:	bf8fe0ef          	jal	800032a8 <ilock>
  if(ip->nlink < 1)
    80004eb4:	04a91783          	lh	a5,74(s2)
    80004eb8:	06f05763          	blez	a5,80004f26 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004ebc:	04491703          	lh	a4,68(s2)
    80004ec0:	4785                	li	a5,1
    80004ec2:	06f70963          	beq	a4,a5,80004f34 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004ec6:	4641                	li	a2,16
    80004ec8:	4581                	li	a1,0
    80004eca:	fc040513          	addi	a0,s0,-64
    80004ece:	dd5fb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ed2:	4741                	li	a4,16
    80004ed4:	f2c42683          	lw	a3,-212(s0)
    80004ed8:	fc040613          	addi	a2,s0,-64
    80004edc:	4581                	li	a1,0
    80004ede:	8526                	mv	a0,s1
    80004ee0:	855fe0ef          	jal	80003734 <writei>
    80004ee4:	47c1                	li	a5,16
    80004ee6:	08f51b63          	bne	a0,a5,80004f7c <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004eea:	04491703          	lh	a4,68(s2)
    80004eee:	4785                	li	a5,1
    80004ef0:	08f70d63          	beq	a4,a5,80004f8a <sys_unlink+0x14c>
  iunlockput(dp);
    80004ef4:	8526                	mv	a0,s1
    80004ef6:	dbcfe0ef          	jal	800034b2 <iunlockput>
  ip->nlink--;
    80004efa:	04a95783          	lhu	a5,74(s2)
    80004efe:	37fd                	addiw	a5,a5,-1
    80004f00:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f04:	854a                	mv	a0,s2
    80004f06:	aeefe0ef          	jal	800031f4 <iupdate>
  iunlockput(ip);
    80004f0a:	854a                	mv	a0,s2
    80004f0c:	da6fe0ef          	jal	800034b2 <iunlockput>
  end_op();
    80004f10:	dedfe0ef          	jal	80003cfc <end_op>
  return 0;
    80004f14:	4501                	li	a0,0
    80004f16:	64ee                	ld	s1,216(sp)
    80004f18:	694e                	ld	s2,208(sp)
    80004f1a:	a849                	j	80004fac <sys_unlink+0x16e>
    end_op();
    80004f1c:	de1fe0ef          	jal	80003cfc <end_op>
    return -1;
    80004f20:	557d                	li	a0,-1
    80004f22:	64ee                	ld	s1,216(sp)
    80004f24:	a061                	j	80004fac <sys_unlink+0x16e>
    80004f26:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004f28:	00002517          	auipc	a0,0x2
    80004f2c:	6b050513          	addi	a0,a0,1712 # 800075d8 <etext+0x5d8>
    80004f30:	8b1fb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f34:	04c92703          	lw	a4,76(s2)
    80004f38:	02000793          	li	a5,32
    80004f3c:	f8e7f5e3          	bgeu	a5,a4,80004ec6 <sys_unlink+0x88>
    80004f40:	e5ce                	sd	s3,200(sp)
    80004f42:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f46:	4741                	li	a4,16
    80004f48:	86ce                	mv	a3,s3
    80004f4a:	f1840613          	addi	a2,s0,-232
    80004f4e:	4581                	li	a1,0
    80004f50:	854a                	mv	a0,s2
    80004f52:	ee6fe0ef          	jal	80003638 <readi>
    80004f56:	47c1                	li	a5,16
    80004f58:	00f51c63          	bne	a0,a5,80004f70 <sys_unlink+0x132>
    if(de.inum != 0)
    80004f5c:	f1845783          	lhu	a5,-232(s0)
    80004f60:	efa1                	bnez	a5,80004fb8 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f62:	29c1                	addiw	s3,s3,16
    80004f64:	04c92783          	lw	a5,76(s2)
    80004f68:	fcf9efe3          	bltu	s3,a5,80004f46 <sys_unlink+0x108>
    80004f6c:	69ae                	ld	s3,200(sp)
    80004f6e:	bfa1                	j	80004ec6 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004f70:	00002517          	auipc	a0,0x2
    80004f74:	68050513          	addi	a0,a0,1664 # 800075f0 <etext+0x5f0>
    80004f78:	869fb0ef          	jal	800007e0 <panic>
    80004f7c:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004f7e:	00002517          	auipc	a0,0x2
    80004f82:	68a50513          	addi	a0,a0,1674 # 80007608 <etext+0x608>
    80004f86:	85bfb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80004f8a:	04a4d783          	lhu	a5,74(s1)
    80004f8e:	37fd                	addiw	a5,a5,-1
    80004f90:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f94:	8526                	mv	a0,s1
    80004f96:	a5efe0ef          	jal	800031f4 <iupdate>
    80004f9a:	bfa9                	j	80004ef4 <sys_unlink+0xb6>
    80004f9c:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004f9e:	8526                	mv	a0,s1
    80004fa0:	d12fe0ef          	jal	800034b2 <iunlockput>
  end_op();
    80004fa4:	d59fe0ef          	jal	80003cfc <end_op>
  return -1;
    80004fa8:	557d                	li	a0,-1
    80004faa:	64ee                	ld	s1,216(sp)
}
    80004fac:	70ae                	ld	ra,232(sp)
    80004fae:	740e                	ld	s0,224(sp)
    80004fb0:	616d                	addi	sp,sp,240
    80004fb2:	8082                	ret
    return -1;
    80004fb4:	557d                	li	a0,-1
    80004fb6:	bfdd                	j	80004fac <sys_unlink+0x16e>
    iunlockput(ip);
    80004fb8:	854a                	mv	a0,s2
    80004fba:	cf8fe0ef          	jal	800034b2 <iunlockput>
    goto bad;
    80004fbe:	694e                	ld	s2,208(sp)
    80004fc0:	69ae                	ld	s3,200(sp)
    80004fc2:	bff1                	j	80004f9e <sys_unlink+0x160>

0000000080004fc4 <sys_open>:

uint64
sys_open(void)
{
    80004fc4:	7131                	addi	sp,sp,-192
    80004fc6:	fd06                	sd	ra,184(sp)
    80004fc8:	f922                	sd	s0,176(sp)
    80004fca:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004fcc:	f4c40593          	addi	a1,s0,-180
    80004fd0:	4505                	li	a0,1
    80004fd2:	82bfd0ef          	jal	800027fc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004fd6:	08000613          	li	a2,128
    80004fda:	f5040593          	addi	a1,s0,-176
    80004fde:	4501                	li	a0,0
    80004fe0:	859fd0ef          	jal	80002838 <argstr>
    80004fe4:	87aa                	mv	a5,a0
    return -1;
    80004fe6:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004fe8:	0a07c263          	bltz	a5,8000508c <sys_open+0xc8>
    80004fec:	f526                	sd	s1,168(sp)

  begin_op();
    80004fee:	ca5fe0ef          	jal	80003c92 <begin_op>

  if(omode & O_CREATE){
    80004ff2:	f4c42783          	lw	a5,-180(s0)
    80004ff6:	2007f793          	andi	a5,a5,512
    80004ffa:	c3d5                	beqz	a5,8000509e <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004ffc:	4681                	li	a3,0
    80004ffe:	4601                	li	a2,0
    80005000:	4589                	li	a1,2
    80005002:	f5040513          	addi	a0,s0,-176
    80005006:	aa9ff0ef          	jal	80004aae <create>
    8000500a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000500c:	c541                	beqz	a0,80005094 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000500e:	04449703          	lh	a4,68(s1)
    80005012:	478d                	li	a5,3
    80005014:	00f71763          	bne	a4,a5,80005022 <sys_open+0x5e>
    80005018:	0464d703          	lhu	a4,70(s1)
    8000501c:	47a5                	li	a5,9
    8000501e:	0ae7ed63          	bltu	a5,a4,800050d8 <sys_open+0x114>
    80005022:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005024:	fd7fe0ef          	jal	80003ffa <filealloc>
    80005028:	892a                	mv	s2,a0
    8000502a:	c179                	beqz	a0,800050f0 <sys_open+0x12c>
    8000502c:	ed4e                	sd	s3,152(sp)
    8000502e:	a43ff0ef          	jal	80004a70 <fdalloc>
    80005032:	89aa                	mv	s3,a0
    80005034:	0a054a63          	bltz	a0,800050e8 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005038:	04449703          	lh	a4,68(s1)
    8000503c:	478d                	li	a5,3
    8000503e:	0cf70263          	beq	a4,a5,80005102 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005042:	4789                	li	a5,2
    80005044:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005048:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000504c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005050:	f4c42783          	lw	a5,-180(s0)
    80005054:	0017c713          	xori	a4,a5,1
    80005058:	8b05                	andi	a4,a4,1
    8000505a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000505e:	0037f713          	andi	a4,a5,3
    80005062:	00e03733          	snez	a4,a4
    80005066:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000506a:	4007f793          	andi	a5,a5,1024
    8000506e:	c791                	beqz	a5,8000507a <sys_open+0xb6>
    80005070:	04449703          	lh	a4,68(s1)
    80005074:	4789                	li	a5,2
    80005076:	08f70d63          	beq	a4,a5,80005110 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000507a:	8526                	mv	a0,s1
    8000507c:	adafe0ef          	jal	80003356 <iunlock>
  end_op();
    80005080:	c7dfe0ef          	jal	80003cfc <end_op>

  return fd;
    80005084:	854e                	mv	a0,s3
    80005086:	74aa                	ld	s1,168(sp)
    80005088:	790a                	ld	s2,160(sp)
    8000508a:	69ea                	ld	s3,152(sp)
}
    8000508c:	70ea                	ld	ra,184(sp)
    8000508e:	744a                	ld	s0,176(sp)
    80005090:	6129                	addi	sp,sp,192
    80005092:	8082                	ret
      end_op();
    80005094:	c69fe0ef          	jal	80003cfc <end_op>
      return -1;
    80005098:	557d                	li	a0,-1
    8000509a:	74aa                	ld	s1,168(sp)
    8000509c:	bfc5                	j	8000508c <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000509e:	f5040513          	addi	a0,s0,-176
    800050a2:	a1dfe0ef          	jal	80003abe <namei>
    800050a6:	84aa                	mv	s1,a0
    800050a8:	c11d                	beqz	a0,800050ce <sys_open+0x10a>
    ilock(ip);
    800050aa:	9fefe0ef          	jal	800032a8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800050ae:	04449703          	lh	a4,68(s1)
    800050b2:	4785                	li	a5,1
    800050b4:	f4f71de3          	bne	a4,a5,8000500e <sys_open+0x4a>
    800050b8:	f4c42783          	lw	a5,-180(s0)
    800050bc:	d3bd                	beqz	a5,80005022 <sys_open+0x5e>
      iunlockput(ip);
    800050be:	8526                	mv	a0,s1
    800050c0:	bf2fe0ef          	jal	800034b2 <iunlockput>
      end_op();
    800050c4:	c39fe0ef          	jal	80003cfc <end_op>
      return -1;
    800050c8:	557d                	li	a0,-1
    800050ca:	74aa                	ld	s1,168(sp)
    800050cc:	b7c1                	j	8000508c <sys_open+0xc8>
      end_op();
    800050ce:	c2ffe0ef          	jal	80003cfc <end_op>
      return -1;
    800050d2:	557d                	li	a0,-1
    800050d4:	74aa                	ld	s1,168(sp)
    800050d6:	bf5d                	j	8000508c <sys_open+0xc8>
    iunlockput(ip);
    800050d8:	8526                	mv	a0,s1
    800050da:	bd8fe0ef          	jal	800034b2 <iunlockput>
    end_op();
    800050de:	c1ffe0ef          	jal	80003cfc <end_op>
    return -1;
    800050e2:	557d                	li	a0,-1
    800050e4:	74aa                	ld	s1,168(sp)
    800050e6:	b75d                	j	8000508c <sys_open+0xc8>
      fileclose(f);
    800050e8:	854a                	mv	a0,s2
    800050ea:	fb5fe0ef          	jal	8000409e <fileclose>
    800050ee:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800050f0:	8526                	mv	a0,s1
    800050f2:	bc0fe0ef          	jal	800034b2 <iunlockput>
    end_op();
    800050f6:	c07fe0ef          	jal	80003cfc <end_op>
    return -1;
    800050fa:	557d                	li	a0,-1
    800050fc:	74aa                	ld	s1,168(sp)
    800050fe:	790a                	ld	s2,160(sp)
    80005100:	b771                	j	8000508c <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005102:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005106:	04649783          	lh	a5,70(s1)
    8000510a:	02f91223          	sh	a5,36(s2)
    8000510e:	bf3d                	j	8000504c <sys_open+0x88>
    itrunc(ip);
    80005110:	8526                	mv	a0,s1
    80005112:	a84fe0ef          	jal	80003396 <itrunc>
    80005116:	b795                	j	8000507a <sys_open+0xb6>

0000000080005118 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005118:	7175                	addi	sp,sp,-144
    8000511a:	e506                	sd	ra,136(sp)
    8000511c:	e122                	sd	s0,128(sp)
    8000511e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005120:	b73fe0ef          	jal	80003c92 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005124:	08000613          	li	a2,128
    80005128:	f7040593          	addi	a1,s0,-144
    8000512c:	4501                	li	a0,0
    8000512e:	f0afd0ef          	jal	80002838 <argstr>
    80005132:	02054363          	bltz	a0,80005158 <sys_mkdir+0x40>
    80005136:	4681                	li	a3,0
    80005138:	4601                	li	a2,0
    8000513a:	4585                	li	a1,1
    8000513c:	f7040513          	addi	a0,s0,-144
    80005140:	96fff0ef          	jal	80004aae <create>
    80005144:	c911                	beqz	a0,80005158 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005146:	b6cfe0ef          	jal	800034b2 <iunlockput>
  end_op();
    8000514a:	bb3fe0ef          	jal	80003cfc <end_op>
  return 0;
    8000514e:	4501                	li	a0,0
}
    80005150:	60aa                	ld	ra,136(sp)
    80005152:	640a                	ld	s0,128(sp)
    80005154:	6149                	addi	sp,sp,144
    80005156:	8082                	ret
    end_op();
    80005158:	ba5fe0ef          	jal	80003cfc <end_op>
    return -1;
    8000515c:	557d                	li	a0,-1
    8000515e:	bfcd                	j	80005150 <sys_mkdir+0x38>

0000000080005160 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005160:	7135                	addi	sp,sp,-160
    80005162:	ed06                	sd	ra,152(sp)
    80005164:	e922                	sd	s0,144(sp)
    80005166:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005168:	b2bfe0ef          	jal	80003c92 <begin_op>
  argint(1, &major);
    8000516c:	f6c40593          	addi	a1,s0,-148
    80005170:	4505                	li	a0,1
    80005172:	e8afd0ef          	jal	800027fc <argint>
  argint(2, &minor);
    80005176:	f6840593          	addi	a1,s0,-152
    8000517a:	4509                	li	a0,2
    8000517c:	e80fd0ef          	jal	800027fc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005180:	08000613          	li	a2,128
    80005184:	f7040593          	addi	a1,s0,-144
    80005188:	4501                	li	a0,0
    8000518a:	eaefd0ef          	jal	80002838 <argstr>
    8000518e:	02054563          	bltz	a0,800051b8 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005192:	f6841683          	lh	a3,-152(s0)
    80005196:	f6c41603          	lh	a2,-148(s0)
    8000519a:	458d                	li	a1,3
    8000519c:	f7040513          	addi	a0,s0,-144
    800051a0:	90fff0ef          	jal	80004aae <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051a4:	c911                	beqz	a0,800051b8 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051a6:	b0cfe0ef          	jal	800034b2 <iunlockput>
  end_op();
    800051aa:	b53fe0ef          	jal	80003cfc <end_op>
  return 0;
    800051ae:	4501                	li	a0,0
}
    800051b0:	60ea                	ld	ra,152(sp)
    800051b2:	644a                	ld	s0,144(sp)
    800051b4:	610d                	addi	sp,sp,160
    800051b6:	8082                	ret
    end_op();
    800051b8:	b45fe0ef          	jal	80003cfc <end_op>
    return -1;
    800051bc:	557d                	li	a0,-1
    800051be:	bfcd                	j	800051b0 <sys_mknod+0x50>

00000000800051c0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800051c0:	7135                	addi	sp,sp,-160
    800051c2:	ed06                	sd	ra,152(sp)
    800051c4:	e922                	sd	s0,144(sp)
    800051c6:	e14a                	sd	s2,128(sp)
    800051c8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800051ca:	f04fc0ef          	jal	800018ce <myproc>
    800051ce:	892a                	mv	s2,a0
  
  begin_op();
    800051d0:	ac3fe0ef          	jal	80003c92 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800051d4:	08000613          	li	a2,128
    800051d8:	f6040593          	addi	a1,s0,-160
    800051dc:	4501                	li	a0,0
    800051de:	e5afd0ef          	jal	80002838 <argstr>
    800051e2:	04054363          	bltz	a0,80005228 <sys_chdir+0x68>
    800051e6:	e526                	sd	s1,136(sp)
    800051e8:	f6040513          	addi	a0,s0,-160
    800051ec:	8d3fe0ef          	jal	80003abe <namei>
    800051f0:	84aa                	mv	s1,a0
    800051f2:	c915                	beqz	a0,80005226 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800051f4:	8b4fe0ef          	jal	800032a8 <ilock>
  if(ip->type != T_DIR){
    800051f8:	04449703          	lh	a4,68(s1)
    800051fc:	4785                	li	a5,1
    800051fe:	02f71963          	bne	a4,a5,80005230 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005202:	8526                	mv	a0,s1
    80005204:	952fe0ef          	jal	80003356 <iunlock>
  iput(p->cwd);
    80005208:	15093503          	ld	a0,336(s2)
    8000520c:	a1efe0ef          	jal	8000342a <iput>
  end_op();
    80005210:	aedfe0ef          	jal	80003cfc <end_op>
  p->cwd = ip;
    80005214:	14993823          	sd	s1,336(s2)
  return 0;
    80005218:	4501                	li	a0,0
    8000521a:	64aa                	ld	s1,136(sp)
}
    8000521c:	60ea                	ld	ra,152(sp)
    8000521e:	644a                	ld	s0,144(sp)
    80005220:	690a                	ld	s2,128(sp)
    80005222:	610d                	addi	sp,sp,160
    80005224:	8082                	ret
    80005226:	64aa                	ld	s1,136(sp)
    end_op();
    80005228:	ad5fe0ef          	jal	80003cfc <end_op>
    return -1;
    8000522c:	557d                	li	a0,-1
    8000522e:	b7fd                	j	8000521c <sys_chdir+0x5c>
    iunlockput(ip);
    80005230:	8526                	mv	a0,s1
    80005232:	a80fe0ef          	jal	800034b2 <iunlockput>
    end_op();
    80005236:	ac7fe0ef          	jal	80003cfc <end_op>
    return -1;
    8000523a:	557d                	li	a0,-1
    8000523c:	64aa                	ld	s1,136(sp)
    8000523e:	bff9                	j	8000521c <sys_chdir+0x5c>

0000000080005240 <sys_exec>:

uint64
sys_exec(void)
{
    80005240:	7121                	addi	sp,sp,-448
    80005242:	ff06                	sd	ra,440(sp)
    80005244:	fb22                	sd	s0,432(sp)
    80005246:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005248:	e4840593          	addi	a1,s0,-440
    8000524c:	4505                	li	a0,1
    8000524e:	dccfd0ef          	jal	8000281a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005252:	08000613          	li	a2,128
    80005256:	f5040593          	addi	a1,s0,-176
    8000525a:	4501                	li	a0,0
    8000525c:	ddcfd0ef          	jal	80002838 <argstr>
    80005260:	87aa                	mv	a5,a0
    return -1;
    80005262:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005264:	0c07c463          	bltz	a5,8000532c <sys_exec+0xec>
    80005268:	f726                	sd	s1,424(sp)
    8000526a:	f34a                	sd	s2,416(sp)
    8000526c:	ef4e                	sd	s3,408(sp)
    8000526e:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005270:	10000613          	li	a2,256
    80005274:	4581                	li	a1,0
    80005276:	e5040513          	addi	a0,s0,-432
    8000527a:	a29fb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000527e:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005282:	89a6                	mv	s3,s1
    80005284:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005286:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000528a:	00391513          	slli	a0,s2,0x3
    8000528e:	e4040593          	addi	a1,s0,-448
    80005292:	e4843783          	ld	a5,-440(s0)
    80005296:	953e                	add	a0,a0,a5
    80005298:	cdafd0ef          	jal	80002772 <fetchaddr>
    8000529c:	02054663          	bltz	a0,800052c8 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800052a0:	e4043783          	ld	a5,-448(s0)
    800052a4:	c3a9                	beqz	a5,800052e6 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800052a6:	859fb0ef          	jal	80000afe <kalloc>
    800052aa:	85aa                	mv	a1,a0
    800052ac:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800052b0:	cd01                	beqz	a0,800052c8 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052b2:	6605                	lui	a2,0x1
    800052b4:	e4043503          	ld	a0,-448(s0)
    800052b8:	d04fd0ef          	jal	800027bc <fetchstr>
    800052bc:	00054663          	bltz	a0,800052c8 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800052c0:	0905                	addi	s2,s2,1
    800052c2:	09a1                	addi	s3,s3,8
    800052c4:	fd4913e3          	bne	s2,s4,8000528a <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052c8:	f5040913          	addi	s2,s0,-176
    800052cc:	6088                	ld	a0,0(s1)
    800052ce:	c931                	beqz	a0,80005322 <sys_exec+0xe2>
    kfree(argv[i]);
    800052d0:	f4cfb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052d4:	04a1                	addi	s1,s1,8
    800052d6:	ff249be3          	bne	s1,s2,800052cc <sys_exec+0x8c>
  return -1;
    800052da:	557d                	li	a0,-1
    800052dc:	74ba                	ld	s1,424(sp)
    800052de:	791a                	ld	s2,416(sp)
    800052e0:	69fa                	ld	s3,408(sp)
    800052e2:	6a5a                	ld	s4,400(sp)
    800052e4:	a0a1                	j	8000532c <sys_exec+0xec>
      argv[i] = 0;
    800052e6:	0009079b          	sext.w	a5,s2
    800052ea:	078e                	slli	a5,a5,0x3
    800052ec:	fd078793          	addi	a5,a5,-48
    800052f0:	97a2                	add	a5,a5,s0
    800052f2:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800052f6:	e5040593          	addi	a1,s0,-432
    800052fa:	f5040513          	addi	a0,s0,-176
    800052fe:	ba8ff0ef          	jal	800046a6 <kexec>
    80005302:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005304:	f5040993          	addi	s3,s0,-176
    80005308:	6088                	ld	a0,0(s1)
    8000530a:	c511                	beqz	a0,80005316 <sys_exec+0xd6>
    kfree(argv[i]);
    8000530c:	f10fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005310:	04a1                	addi	s1,s1,8
    80005312:	ff349be3          	bne	s1,s3,80005308 <sys_exec+0xc8>
  return ret;
    80005316:	854a                	mv	a0,s2
    80005318:	74ba                	ld	s1,424(sp)
    8000531a:	791a                	ld	s2,416(sp)
    8000531c:	69fa                	ld	s3,408(sp)
    8000531e:	6a5a                	ld	s4,400(sp)
    80005320:	a031                	j	8000532c <sys_exec+0xec>
  return -1;
    80005322:	557d                	li	a0,-1
    80005324:	74ba                	ld	s1,424(sp)
    80005326:	791a                	ld	s2,416(sp)
    80005328:	69fa                	ld	s3,408(sp)
    8000532a:	6a5a                	ld	s4,400(sp)
}
    8000532c:	70fa                	ld	ra,440(sp)
    8000532e:	745a                	ld	s0,432(sp)
    80005330:	6139                	addi	sp,sp,448
    80005332:	8082                	ret

0000000080005334 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005334:	7139                	addi	sp,sp,-64
    80005336:	fc06                	sd	ra,56(sp)
    80005338:	f822                	sd	s0,48(sp)
    8000533a:	f426                	sd	s1,40(sp)
    8000533c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000533e:	d90fc0ef          	jal	800018ce <myproc>
    80005342:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005344:	fd840593          	addi	a1,s0,-40
    80005348:	4501                	li	a0,0
    8000534a:	cd0fd0ef          	jal	8000281a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000534e:	fc840593          	addi	a1,s0,-56
    80005352:	fd040513          	addi	a0,s0,-48
    80005356:	852ff0ef          	jal	800043a8 <pipealloc>
    return -1;
    8000535a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000535c:	0a054463          	bltz	a0,80005404 <sys_pipe+0xd0>
  fd0 = -1;
    80005360:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005364:	fd043503          	ld	a0,-48(s0)
    80005368:	f08ff0ef          	jal	80004a70 <fdalloc>
    8000536c:	fca42223          	sw	a0,-60(s0)
    80005370:	08054163          	bltz	a0,800053f2 <sys_pipe+0xbe>
    80005374:	fc843503          	ld	a0,-56(s0)
    80005378:	ef8ff0ef          	jal	80004a70 <fdalloc>
    8000537c:	fca42023          	sw	a0,-64(s0)
    80005380:	06054063          	bltz	a0,800053e0 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005384:	4691                	li	a3,4
    80005386:	fc440613          	addi	a2,s0,-60
    8000538a:	fd843583          	ld	a1,-40(s0)
    8000538e:	68a8                	ld	a0,80(s1)
    80005390:	a52fc0ef          	jal	800015e2 <copyout>
    80005394:	00054e63          	bltz	a0,800053b0 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005398:	4691                	li	a3,4
    8000539a:	fc040613          	addi	a2,s0,-64
    8000539e:	fd843583          	ld	a1,-40(s0)
    800053a2:	0591                	addi	a1,a1,4
    800053a4:	68a8                	ld	a0,80(s1)
    800053a6:	a3cfc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800053aa:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053ac:	04055c63          	bgez	a0,80005404 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800053b0:	fc442783          	lw	a5,-60(s0)
    800053b4:	07e9                	addi	a5,a5,26
    800053b6:	078e                	slli	a5,a5,0x3
    800053b8:	97a6                	add	a5,a5,s1
    800053ba:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800053be:	fc042783          	lw	a5,-64(s0)
    800053c2:	07e9                	addi	a5,a5,26
    800053c4:	078e                	slli	a5,a5,0x3
    800053c6:	94be                	add	s1,s1,a5
    800053c8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800053cc:	fd043503          	ld	a0,-48(s0)
    800053d0:	ccffe0ef          	jal	8000409e <fileclose>
    fileclose(wf);
    800053d4:	fc843503          	ld	a0,-56(s0)
    800053d8:	cc7fe0ef          	jal	8000409e <fileclose>
    return -1;
    800053dc:	57fd                	li	a5,-1
    800053de:	a01d                	j	80005404 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800053e0:	fc442783          	lw	a5,-60(s0)
    800053e4:	0007c763          	bltz	a5,800053f2 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800053e8:	07e9                	addi	a5,a5,26
    800053ea:	078e                	slli	a5,a5,0x3
    800053ec:	97a6                	add	a5,a5,s1
    800053ee:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800053f2:	fd043503          	ld	a0,-48(s0)
    800053f6:	ca9fe0ef          	jal	8000409e <fileclose>
    fileclose(wf);
    800053fa:	fc843503          	ld	a0,-56(s0)
    800053fe:	ca1fe0ef          	jal	8000409e <fileclose>
    return -1;
    80005402:	57fd                	li	a5,-1
}
    80005404:	853e                	mv	a0,a5
    80005406:	70e2                	ld	ra,56(sp)
    80005408:	7442                	ld	s0,48(sp)
    8000540a:	74a2                	ld	s1,40(sp)
    8000540c:	6121                	addi	sp,sp,64
    8000540e:	8082                	ret

0000000080005410 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005410:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005412:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005414:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005416:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005418:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000541a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000541c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000541e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005420:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005422:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005424:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005426:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005428:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000542a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000542c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000542e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005430:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005432:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005434:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005436:	a4cfd0ef          	jal	80002682 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000543a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000543c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000543e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005440:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005442:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005444:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005446:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005448:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000544a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000544c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000544e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005450:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005452:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005454:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005456:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005458:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000545a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000545c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000545e:	10200073          	sret
	...

000000008000546e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000546e:	1141                	addi	sp,sp,-16
    80005470:	e422                	sd	s0,8(sp)
    80005472:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005474:	0c0007b7          	lui	a5,0xc000
    80005478:	4705                	li	a4,1
    8000547a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000547c:	0c0007b7          	lui	a5,0xc000
    80005480:	c3d8                	sw	a4,4(a5)
}
    80005482:	6422                	ld	s0,8(sp)
    80005484:	0141                	addi	sp,sp,16
    80005486:	8082                	ret

0000000080005488 <plicinithart>:

void
plicinithart(void)
{
    80005488:	1141                	addi	sp,sp,-16
    8000548a:	e406                	sd	ra,8(sp)
    8000548c:	e022                	sd	s0,0(sp)
    8000548e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005490:	c12fc0ef          	jal	800018a2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005494:	0085171b          	slliw	a4,a0,0x8
    80005498:	0c0027b7          	lui	a5,0xc002
    8000549c:	97ba                	add	a5,a5,a4
    8000549e:	40200713          	li	a4,1026
    800054a2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800054a6:	00d5151b          	slliw	a0,a0,0xd
    800054aa:	0c2017b7          	lui	a5,0xc201
    800054ae:	97aa                	add	a5,a5,a0
    800054b0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800054b4:	60a2                	ld	ra,8(sp)
    800054b6:	6402                	ld	s0,0(sp)
    800054b8:	0141                	addi	sp,sp,16
    800054ba:	8082                	ret

00000000800054bc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800054bc:	1141                	addi	sp,sp,-16
    800054be:	e406                	sd	ra,8(sp)
    800054c0:	e022                	sd	s0,0(sp)
    800054c2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054c4:	bdefc0ef          	jal	800018a2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800054c8:	00d5151b          	slliw	a0,a0,0xd
    800054cc:	0c2017b7          	lui	a5,0xc201
    800054d0:	97aa                	add	a5,a5,a0
  return irq;
}
    800054d2:	43c8                	lw	a0,4(a5)
    800054d4:	60a2                	ld	ra,8(sp)
    800054d6:	6402                	ld	s0,0(sp)
    800054d8:	0141                	addi	sp,sp,16
    800054da:	8082                	ret

00000000800054dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800054dc:	1101                	addi	sp,sp,-32
    800054de:	ec06                	sd	ra,24(sp)
    800054e0:	e822                	sd	s0,16(sp)
    800054e2:	e426                	sd	s1,8(sp)
    800054e4:	1000                	addi	s0,sp,32
    800054e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800054e8:	bbafc0ef          	jal	800018a2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800054ec:	00d5151b          	slliw	a0,a0,0xd
    800054f0:	0c2017b7          	lui	a5,0xc201
    800054f4:	97aa                	add	a5,a5,a0
    800054f6:	c3c4                	sw	s1,4(a5)
}
    800054f8:	60e2                	ld	ra,24(sp)
    800054fa:	6442                	ld	s0,16(sp)
    800054fc:	64a2                	ld	s1,8(sp)
    800054fe:	6105                	addi	sp,sp,32
    80005500:	8082                	ret

0000000080005502 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005502:	1141                	addi	sp,sp,-16
    80005504:	e406                	sd	ra,8(sp)
    80005506:	e022                	sd	s0,0(sp)
    80005508:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000550a:	479d                	li	a5,7
    8000550c:	04a7ca63          	blt	a5,a0,80005560 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005510:	0001c797          	auipc	a5,0x1c
    80005514:	94878793          	addi	a5,a5,-1720 # 80020e58 <disk>
    80005518:	97aa                	add	a5,a5,a0
    8000551a:	0187c783          	lbu	a5,24(a5)
    8000551e:	e7b9                	bnez	a5,8000556c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005520:	00451693          	slli	a3,a0,0x4
    80005524:	0001c797          	auipc	a5,0x1c
    80005528:	93478793          	addi	a5,a5,-1740 # 80020e58 <disk>
    8000552c:	6398                	ld	a4,0(a5)
    8000552e:	9736                	add	a4,a4,a3
    80005530:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005534:	6398                	ld	a4,0(a5)
    80005536:	9736                	add	a4,a4,a3
    80005538:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000553c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005540:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005544:	97aa                	add	a5,a5,a0
    80005546:	4705                	li	a4,1
    80005548:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000554c:	0001c517          	auipc	a0,0x1c
    80005550:	92450513          	addi	a0,a0,-1756 # 80020e70 <disk+0x18>
    80005554:	9f1fc0ef          	jal	80001f44 <wakeup>
}
    80005558:	60a2                	ld	ra,8(sp)
    8000555a:	6402                	ld	s0,0(sp)
    8000555c:	0141                	addi	sp,sp,16
    8000555e:	8082                	ret
    panic("free_desc 1");
    80005560:	00002517          	auipc	a0,0x2
    80005564:	0b850513          	addi	a0,a0,184 # 80007618 <etext+0x618>
    80005568:	a78fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000556c:	00002517          	auipc	a0,0x2
    80005570:	0bc50513          	addi	a0,a0,188 # 80007628 <etext+0x628>
    80005574:	a6cfb0ef          	jal	800007e0 <panic>

0000000080005578 <virtio_disk_init>:
{
    80005578:	1101                	addi	sp,sp,-32
    8000557a:	ec06                	sd	ra,24(sp)
    8000557c:	e822                	sd	s0,16(sp)
    8000557e:	e426                	sd	s1,8(sp)
    80005580:	e04a                	sd	s2,0(sp)
    80005582:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005584:	00002597          	auipc	a1,0x2
    80005588:	0b458593          	addi	a1,a1,180 # 80007638 <etext+0x638>
    8000558c:	0001c517          	auipc	a0,0x1c
    80005590:	9f450513          	addi	a0,a0,-1548 # 80020f80 <disk+0x128>
    80005594:	dbafb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005598:	100017b7          	lui	a5,0x10001
    8000559c:	4398                	lw	a4,0(a5)
    8000559e:	2701                	sext.w	a4,a4
    800055a0:	747277b7          	lui	a5,0x74727
    800055a4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800055a8:	18f71063          	bne	a4,a5,80005728 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055ac:	100017b7          	lui	a5,0x10001
    800055b0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800055b2:	439c                	lw	a5,0(a5)
    800055b4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055b6:	4709                	li	a4,2
    800055b8:	16e79863          	bne	a5,a4,80005728 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055bc:	100017b7          	lui	a5,0x10001
    800055c0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800055c2:	439c                	lw	a5,0(a5)
    800055c4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055c6:	16e79163          	bne	a5,a4,80005728 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800055ca:	100017b7          	lui	a5,0x10001
    800055ce:	47d8                	lw	a4,12(a5)
    800055d0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055d2:	554d47b7          	lui	a5,0x554d4
    800055d6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800055da:	14f71763          	bne	a4,a5,80005728 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055de:	100017b7          	lui	a5,0x10001
    800055e2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055e6:	4705                	li	a4,1
    800055e8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055ea:	470d                	li	a4,3
    800055ec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800055ee:	10001737          	lui	a4,0x10001
    800055f2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800055f4:	c7ffe737          	lui	a4,0xc7ffe
    800055f8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd7c7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800055fc:	8ef9                	and	a3,a3,a4
    800055fe:	10001737          	lui	a4,0x10001
    80005602:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005604:	472d                	li	a4,11
    80005606:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005608:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000560c:	439c                	lw	a5,0(a5)
    8000560e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005612:	8ba1                	andi	a5,a5,8
    80005614:	12078063          	beqz	a5,80005734 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005618:	100017b7          	lui	a5,0x10001
    8000561c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005620:	100017b7          	lui	a5,0x10001
    80005624:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005628:	439c                	lw	a5,0(a5)
    8000562a:	2781                	sext.w	a5,a5
    8000562c:	10079a63          	bnez	a5,80005740 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005630:	100017b7          	lui	a5,0x10001
    80005634:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005638:	439c                	lw	a5,0(a5)
    8000563a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000563c:	10078863          	beqz	a5,8000574c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005640:	471d                	li	a4,7
    80005642:	10f77b63          	bgeu	a4,a5,80005758 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005646:	cb8fb0ef          	jal	80000afe <kalloc>
    8000564a:	0001c497          	auipc	s1,0x1c
    8000564e:	80e48493          	addi	s1,s1,-2034 # 80020e58 <disk>
    80005652:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005654:	caafb0ef          	jal	80000afe <kalloc>
    80005658:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000565a:	ca4fb0ef          	jal	80000afe <kalloc>
    8000565e:	87aa                	mv	a5,a0
    80005660:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005662:	6088                	ld	a0,0(s1)
    80005664:	10050063          	beqz	a0,80005764 <virtio_disk_init+0x1ec>
    80005668:	0001b717          	auipc	a4,0x1b
    8000566c:	7f873703          	ld	a4,2040(a4) # 80020e60 <disk+0x8>
    80005670:	0e070a63          	beqz	a4,80005764 <virtio_disk_init+0x1ec>
    80005674:	0e078863          	beqz	a5,80005764 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005678:	6605                	lui	a2,0x1
    8000567a:	4581                	li	a1,0
    8000567c:	e26fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005680:	0001b497          	auipc	s1,0x1b
    80005684:	7d848493          	addi	s1,s1,2008 # 80020e58 <disk>
    80005688:	6605                	lui	a2,0x1
    8000568a:	4581                	li	a1,0
    8000568c:	6488                	ld	a0,8(s1)
    8000568e:	e14fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005692:	6605                	lui	a2,0x1
    80005694:	4581                	li	a1,0
    80005696:	6888                	ld	a0,16(s1)
    80005698:	e0afb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000569c:	100017b7          	lui	a5,0x10001
    800056a0:	4721                	li	a4,8
    800056a2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800056a4:	4098                	lw	a4,0(s1)
    800056a6:	100017b7          	lui	a5,0x10001
    800056aa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800056ae:	40d8                	lw	a4,4(s1)
    800056b0:	100017b7          	lui	a5,0x10001
    800056b4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800056b8:	649c                	ld	a5,8(s1)
    800056ba:	0007869b          	sext.w	a3,a5
    800056be:	10001737          	lui	a4,0x10001
    800056c2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800056c6:	9781                	srai	a5,a5,0x20
    800056c8:	10001737          	lui	a4,0x10001
    800056cc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800056d0:	689c                	ld	a5,16(s1)
    800056d2:	0007869b          	sext.w	a3,a5
    800056d6:	10001737          	lui	a4,0x10001
    800056da:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800056de:	9781                	srai	a5,a5,0x20
    800056e0:	10001737          	lui	a4,0x10001
    800056e4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800056e8:	10001737          	lui	a4,0x10001
    800056ec:	4785                	li	a5,1
    800056ee:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800056f0:	00f48c23          	sb	a5,24(s1)
    800056f4:	00f48ca3          	sb	a5,25(s1)
    800056f8:	00f48d23          	sb	a5,26(s1)
    800056fc:	00f48da3          	sb	a5,27(s1)
    80005700:	00f48e23          	sb	a5,28(s1)
    80005704:	00f48ea3          	sb	a5,29(s1)
    80005708:	00f48f23          	sb	a5,30(s1)
    8000570c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005710:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005714:	100017b7          	lui	a5,0x10001
    80005718:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000571c:	60e2                	ld	ra,24(sp)
    8000571e:	6442                	ld	s0,16(sp)
    80005720:	64a2                	ld	s1,8(sp)
    80005722:	6902                	ld	s2,0(sp)
    80005724:	6105                	addi	sp,sp,32
    80005726:	8082                	ret
    panic("could not find virtio disk");
    80005728:	00002517          	auipc	a0,0x2
    8000572c:	f2050513          	addi	a0,a0,-224 # 80007648 <etext+0x648>
    80005730:	8b0fb0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005734:	00002517          	auipc	a0,0x2
    80005738:	f3450513          	addi	a0,a0,-204 # 80007668 <etext+0x668>
    8000573c:	8a4fb0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005740:	00002517          	auipc	a0,0x2
    80005744:	f4850513          	addi	a0,a0,-184 # 80007688 <etext+0x688>
    80005748:	898fb0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000574c:	00002517          	auipc	a0,0x2
    80005750:	f5c50513          	addi	a0,a0,-164 # 800076a8 <etext+0x6a8>
    80005754:	88cfb0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005758:	00002517          	auipc	a0,0x2
    8000575c:	f7050513          	addi	a0,a0,-144 # 800076c8 <etext+0x6c8>
    80005760:	880fb0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005764:	00002517          	auipc	a0,0x2
    80005768:	f8450513          	addi	a0,a0,-124 # 800076e8 <etext+0x6e8>
    8000576c:	874fb0ef          	jal	800007e0 <panic>

0000000080005770 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005770:	7159                	addi	sp,sp,-112
    80005772:	f486                	sd	ra,104(sp)
    80005774:	f0a2                	sd	s0,96(sp)
    80005776:	eca6                	sd	s1,88(sp)
    80005778:	e8ca                	sd	s2,80(sp)
    8000577a:	e4ce                	sd	s3,72(sp)
    8000577c:	e0d2                	sd	s4,64(sp)
    8000577e:	fc56                	sd	s5,56(sp)
    80005780:	f85a                	sd	s6,48(sp)
    80005782:	f45e                	sd	s7,40(sp)
    80005784:	f062                	sd	s8,32(sp)
    80005786:	ec66                	sd	s9,24(sp)
    80005788:	1880                	addi	s0,sp,112
    8000578a:	8a2a                	mv	s4,a0
    8000578c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000578e:	00c52c83          	lw	s9,12(a0)
    80005792:	001c9c9b          	slliw	s9,s9,0x1
    80005796:	1c82                	slli	s9,s9,0x20
    80005798:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000579c:	0001b517          	auipc	a0,0x1b
    800057a0:	7e450513          	addi	a0,a0,2020 # 80020f80 <disk+0x128>
    800057a4:	c2afb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    800057a8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800057aa:	44a1                	li	s1,8
      disk.free[i] = 0;
    800057ac:	0001bb17          	auipc	s6,0x1b
    800057b0:	6acb0b13          	addi	s6,s6,1708 # 80020e58 <disk>
  for(int i = 0; i < 3; i++){
    800057b4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057b6:	0001bc17          	auipc	s8,0x1b
    800057ba:	7cac0c13          	addi	s8,s8,1994 # 80020f80 <disk+0x128>
    800057be:	a8b9                	j	8000581c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800057c0:	00fb0733          	add	a4,s6,a5
    800057c4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800057c8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800057ca:	0207c563          	bltz	a5,800057f4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800057ce:	2905                	addiw	s2,s2,1
    800057d0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800057d2:	05590963          	beq	s2,s5,80005824 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800057d6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800057d8:	0001b717          	auipc	a4,0x1b
    800057dc:	68070713          	addi	a4,a4,1664 # 80020e58 <disk>
    800057e0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800057e2:	01874683          	lbu	a3,24(a4)
    800057e6:	fee9                	bnez	a3,800057c0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800057e8:	2785                	addiw	a5,a5,1
    800057ea:	0705                	addi	a4,a4,1
    800057ec:	fe979be3          	bne	a5,s1,800057e2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800057f0:	57fd                	li	a5,-1
    800057f2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800057f4:	01205d63          	blez	s2,8000580e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800057f8:	f9042503          	lw	a0,-112(s0)
    800057fc:	d07ff0ef          	jal	80005502 <free_desc>
      for(int j = 0; j < i; j++)
    80005800:	4785                	li	a5,1
    80005802:	0127d663          	bge	a5,s2,8000580e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005806:	f9442503          	lw	a0,-108(s0)
    8000580a:	cf9ff0ef          	jal	80005502 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000580e:	85e2                	mv	a1,s8
    80005810:	0001b517          	auipc	a0,0x1b
    80005814:	66050513          	addi	a0,a0,1632 # 80020e70 <disk+0x18>
    80005818:	ee0fc0ef          	jal	80001ef8 <sleep>
  for(int i = 0; i < 3; i++){
    8000581c:	f9040613          	addi	a2,s0,-112
    80005820:	894e                	mv	s2,s3
    80005822:	bf55                	j	800057d6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005824:	f9042503          	lw	a0,-112(s0)
    80005828:	00451693          	slli	a3,a0,0x4

  if(write)
    8000582c:	0001b797          	auipc	a5,0x1b
    80005830:	62c78793          	addi	a5,a5,1580 # 80020e58 <disk>
    80005834:	00a50713          	addi	a4,a0,10
    80005838:	0712                	slli	a4,a4,0x4
    8000583a:	973e                	add	a4,a4,a5
    8000583c:	01703633          	snez	a2,s7
    80005840:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005842:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005846:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000584a:	6398                	ld	a4,0(a5)
    8000584c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000584e:	0a868613          	addi	a2,a3,168
    80005852:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005854:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005856:	6390                	ld	a2,0(a5)
    80005858:	00d605b3          	add	a1,a2,a3
    8000585c:	4741                	li	a4,16
    8000585e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005860:	4805                	li	a6,1
    80005862:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005866:	f9442703          	lw	a4,-108(s0)
    8000586a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000586e:	0712                	slli	a4,a4,0x4
    80005870:	963a                	add	a2,a2,a4
    80005872:	058a0593          	addi	a1,s4,88
    80005876:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005878:	0007b883          	ld	a7,0(a5)
    8000587c:	9746                	add	a4,a4,a7
    8000587e:	40000613          	li	a2,1024
    80005882:	c710                	sw	a2,8(a4)
  if(write)
    80005884:	001bb613          	seqz	a2,s7
    80005888:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000588c:	00166613          	ori	a2,a2,1
    80005890:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005894:	f9842583          	lw	a1,-104(s0)
    80005898:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000589c:	00250613          	addi	a2,a0,2
    800058a0:	0612                	slli	a2,a2,0x4
    800058a2:	963e                	add	a2,a2,a5
    800058a4:	577d                	li	a4,-1
    800058a6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800058aa:	0592                	slli	a1,a1,0x4
    800058ac:	98ae                	add	a7,a7,a1
    800058ae:	03068713          	addi	a4,a3,48
    800058b2:	973e                	add	a4,a4,a5
    800058b4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800058b8:	6398                	ld	a4,0(a5)
    800058ba:	972e                	add	a4,a4,a1
    800058bc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800058c0:	4689                	li	a3,2
    800058c2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800058c6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800058ca:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800058ce:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800058d2:	6794                	ld	a3,8(a5)
    800058d4:	0026d703          	lhu	a4,2(a3)
    800058d8:	8b1d                	andi	a4,a4,7
    800058da:	0706                	slli	a4,a4,0x1
    800058dc:	96ba                	add	a3,a3,a4
    800058de:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800058e2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800058e6:	6798                	ld	a4,8(a5)
    800058e8:	00275783          	lhu	a5,2(a4)
    800058ec:	2785                	addiw	a5,a5,1
    800058ee:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800058f2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800058f6:	100017b7          	lui	a5,0x10001
    800058fa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800058fe:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005902:	0001b917          	auipc	s2,0x1b
    80005906:	67e90913          	addi	s2,s2,1662 # 80020f80 <disk+0x128>
  while(b->disk == 1) {
    8000590a:	4485                	li	s1,1
    8000590c:	01079a63          	bne	a5,a6,80005920 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005910:	85ca                	mv	a1,s2
    80005912:	8552                	mv	a0,s4
    80005914:	de4fc0ef          	jal	80001ef8 <sleep>
  while(b->disk == 1) {
    80005918:	004a2783          	lw	a5,4(s4)
    8000591c:	fe978ae3          	beq	a5,s1,80005910 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005920:	f9042903          	lw	s2,-112(s0)
    80005924:	00290713          	addi	a4,s2,2
    80005928:	0712                	slli	a4,a4,0x4
    8000592a:	0001b797          	auipc	a5,0x1b
    8000592e:	52e78793          	addi	a5,a5,1326 # 80020e58 <disk>
    80005932:	97ba                	add	a5,a5,a4
    80005934:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005938:	0001b997          	auipc	s3,0x1b
    8000593c:	52098993          	addi	s3,s3,1312 # 80020e58 <disk>
    80005940:	00491713          	slli	a4,s2,0x4
    80005944:	0009b783          	ld	a5,0(s3)
    80005948:	97ba                	add	a5,a5,a4
    8000594a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000594e:	854a                	mv	a0,s2
    80005950:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005954:	bafff0ef          	jal	80005502 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005958:	8885                	andi	s1,s1,1
    8000595a:	f0fd                	bnez	s1,80005940 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000595c:	0001b517          	auipc	a0,0x1b
    80005960:	62450513          	addi	a0,a0,1572 # 80020f80 <disk+0x128>
    80005964:	b02fb0ef          	jal	80000c66 <release>
}
    80005968:	70a6                	ld	ra,104(sp)
    8000596a:	7406                	ld	s0,96(sp)
    8000596c:	64e6                	ld	s1,88(sp)
    8000596e:	6946                	ld	s2,80(sp)
    80005970:	69a6                	ld	s3,72(sp)
    80005972:	6a06                	ld	s4,64(sp)
    80005974:	7ae2                	ld	s5,56(sp)
    80005976:	7b42                	ld	s6,48(sp)
    80005978:	7ba2                	ld	s7,40(sp)
    8000597a:	7c02                	ld	s8,32(sp)
    8000597c:	6ce2                	ld	s9,24(sp)
    8000597e:	6165                	addi	sp,sp,112
    80005980:	8082                	ret

0000000080005982 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005982:	1101                	addi	sp,sp,-32
    80005984:	ec06                	sd	ra,24(sp)
    80005986:	e822                	sd	s0,16(sp)
    80005988:	e426                	sd	s1,8(sp)
    8000598a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000598c:	0001b497          	auipc	s1,0x1b
    80005990:	4cc48493          	addi	s1,s1,1228 # 80020e58 <disk>
    80005994:	0001b517          	auipc	a0,0x1b
    80005998:	5ec50513          	addi	a0,a0,1516 # 80020f80 <disk+0x128>
    8000599c:	a32fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800059a0:	100017b7          	lui	a5,0x10001
    800059a4:	53b8                	lw	a4,96(a5)
    800059a6:	8b0d                	andi	a4,a4,3
    800059a8:	100017b7          	lui	a5,0x10001
    800059ac:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800059ae:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800059b2:	689c                	ld	a5,16(s1)
    800059b4:	0204d703          	lhu	a4,32(s1)
    800059b8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800059bc:	04f70663          	beq	a4,a5,80005a08 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800059c0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800059c4:	6898                	ld	a4,16(s1)
    800059c6:	0204d783          	lhu	a5,32(s1)
    800059ca:	8b9d                	andi	a5,a5,7
    800059cc:	078e                	slli	a5,a5,0x3
    800059ce:	97ba                	add	a5,a5,a4
    800059d0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800059d2:	00278713          	addi	a4,a5,2
    800059d6:	0712                	slli	a4,a4,0x4
    800059d8:	9726                	add	a4,a4,s1
    800059da:	01074703          	lbu	a4,16(a4)
    800059de:	e321                	bnez	a4,80005a1e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800059e0:	0789                	addi	a5,a5,2
    800059e2:	0792                	slli	a5,a5,0x4
    800059e4:	97a6                	add	a5,a5,s1
    800059e6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800059e8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800059ec:	d58fc0ef          	jal	80001f44 <wakeup>

    disk.used_idx += 1;
    800059f0:	0204d783          	lhu	a5,32(s1)
    800059f4:	2785                	addiw	a5,a5,1
    800059f6:	17c2                	slli	a5,a5,0x30
    800059f8:	93c1                	srli	a5,a5,0x30
    800059fa:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800059fe:	6898                	ld	a4,16(s1)
    80005a00:	00275703          	lhu	a4,2(a4)
    80005a04:	faf71ee3          	bne	a4,a5,800059c0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005a08:	0001b517          	auipc	a0,0x1b
    80005a0c:	57850513          	addi	a0,a0,1400 # 80020f80 <disk+0x128>
    80005a10:	a56fb0ef          	jal	80000c66 <release>
}
    80005a14:	60e2                	ld	ra,24(sp)
    80005a16:	6442                	ld	s0,16(sp)
    80005a18:	64a2                	ld	s1,8(sp)
    80005a1a:	6105                	addi	sp,sp,32
    80005a1c:	8082                	ret
      panic("virtio_disk_intr status");
    80005a1e:	00002517          	auipc	a0,0x2
    80005a22:	ce250513          	addi	a0,a0,-798 # 80007700 <etext+0x700>
    80005a26:	dbbfa0ef          	jal	800007e0 <panic>
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
