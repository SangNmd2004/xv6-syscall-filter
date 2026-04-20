
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda57>
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
    80000112:	178020ef          	jal	8000228a <either_copyin>
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
    800001bc:	761010ef          	jal	8000211c <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	51f010ef          	jal	80001ee4 <sleep>
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
    8000020a:	036020ef          	jal	80002240 <either_copyout>
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
    800002d8:	7fd010ef          	jal	800022d4 <procdump>
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
    8000041a:	52250513          	addi	a0,a0,1314 # 8000f938 <cons+0x98>
    8000041e:	313010ef          	jal	80001f30 <wakeup>
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
    80000448:	7cc78793          	addi	a5,a5,1996 # 8001fc10 <devsw>
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
    800008ea:	5fa010ef          	jal	80001ee4 <sleep>
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
    800009fc:	e8050513          	addi	a0,a0,-384 # 80007878 <tx_chan>
    80000a00:	530010ef          	jal	80001f30 <wakeup>
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
    80000a34:	37878793          	addi	a5,a5,888 # 80020da8 <end>
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
    80000aee:	2be50513          	addi	a0,a0,702 # 80020da8 <end>
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
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde259>
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
    80000e72:	594010ef          	jal	80002406 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	5d2040ef          	jal	80005448 <plicinithart>
  }

  scheduler();        
    80000e7a:	6d3000ef          	jal	80001d4c <scheduler>
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
    80000eba:	528010ef          	jal	800023e2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	548010ef          	jal	80002406 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	56c040ef          	jal	8000542e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	582040ef          	jal	80005448 <plicinithart>
    binit();         // buffer cache
    80000eca:	443010ef          	jal	80002b0c <binit>
    iinit();         // inode table
    80000ece:	1c8020ef          	jal	80003096 <iinit>
    fileinit();      // file table
    80000ed2:	0ba030ef          	jal	80003f8c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	662040ef          	jal	80005538 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	4c7000ef          	jal	80001ba0 <userinit>
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
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde24f>
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
    80001778:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdc15>
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
    8000179a:	232a8a93          	addi	s5,s5,562 # 800159c8 <tickslock>
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
    8000183e:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdc15>
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
    80001860:	16ca0a13          	addi	s4,s4,364 # 800159c8 <tickslock>
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
    8000187a:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffde259>
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
    8000191e:	435010ef          	jal	80003552 <fsinit>

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
    80001942:	51b020ef          	jal	8000465c <kexec>
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
    80001954:	2cb000ef          	jal	8000241e <prepare_return>
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
    80001b02:	2ca48493          	addi	s1,s1,714 # 8000fdc8 <proc>
    80001b06:	00014917          	auipc	s2,0x14
    80001b0a:	ec290913          	addi	s2,s2,-318 # 800159c8 <tickslock>
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
    80001bb4:	cea7b023          	sd	a0,-800(a5) # 80007890 <initproc>
  p->cwd = namei("/");
    80001bb8:	00005517          	auipc	a0,0x5
    80001bbc:	5d850513          	addi	a0,a0,1496 # 80007190 <etext+0x190>
    80001bc0:	6b5010ef          	jal	80003a74 <namei>
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
    80001c54:	0e050a63          	beqz	a0,80001d48 <kfork+0x10a>
    80001c58:	e852                	sd	s4,16(sp)
    80001c5a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c5c:	048ab603          	ld	a2,72(s5)
    80001c60:	692c                	ld	a1,80(a0)
    80001c62:	050ab503          	ld	a0,80(s5)
    80001c66:	f5aff0ef          	jal	800013c0 <uvmcopy>
    80001c6a:	04054a63          	bltz	a0,80001cbe <kfork+0x80>
    80001c6e:	f426                	sd	s1,40(sp)
    80001c70:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c72:	048ab783          	ld	a5,72(s5)
    80001c76:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c7a:	058ab683          	ld	a3,88(s5)
    80001c7e:	87b6                	mv	a5,a3
    80001c80:	058a3703          	ld	a4,88(s4)
    80001c84:	12068693          	addi	a3,a3,288
    80001c88:	0007b803          	ld	a6,0(a5)
    80001c8c:	6788                	ld	a0,8(a5)
    80001c8e:	6b8c                	ld	a1,16(a5)
    80001c90:	6f90                	ld	a2,24(a5)
    80001c92:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c96:	e708                	sd	a0,8(a4)
    80001c98:	eb0c                	sd	a1,16(a4)
    80001c9a:	ef10                	sd	a2,24(a4)
    80001c9c:	02078793          	addi	a5,a5,32
    80001ca0:	02070713          	addi	a4,a4,32
    80001ca4:	fed792e3          	bne	a5,a3,80001c88 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001ca8:	058a3783          	ld	a5,88(s4)
    80001cac:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001cb0:	0d0a8493          	addi	s1,s5,208
    80001cb4:	0d0a0913          	addi	s2,s4,208
    80001cb8:	150a8993          	addi	s3,s5,336
    80001cbc:	a831                	j	80001cd8 <kfork+0x9a>
    freeproc(np);
    80001cbe:	8552                	mv	a0,s4
    80001cc0:	ddfff0ef          	jal	80001a9e <freeproc>
    release(&np->lock);
    80001cc4:	8552                	mv	a0,s4
    80001cc6:	fa1fe0ef          	jal	80000c66 <release>
    return -1;
    80001cca:	597d                	li	s2,-1
    80001ccc:	6a42                	ld	s4,16(sp)
    80001cce:	a0b5                	j	80001d3a <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001cd0:	04a1                	addi	s1,s1,8
    80001cd2:	0921                	addi	s2,s2,8
    80001cd4:	01348963          	beq	s1,s3,80001ce6 <kfork+0xa8>
    if(p->ofile[i])
    80001cd8:	6088                	ld	a0,0(s1)
    80001cda:	d97d                	beqz	a0,80001cd0 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cdc:	332020ef          	jal	8000400e <filedup>
    80001ce0:	00a93023          	sd	a0,0(s2)
    80001ce4:	b7f5                	j	80001cd0 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001ce6:	150ab503          	ld	a0,336(s5)
    80001cea:	53e010ef          	jal	80003228 <idup>
    80001cee:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cf2:	4641                	li	a2,16
    80001cf4:	160a8593          	addi	a1,s5,352
    80001cf8:	160a0513          	addi	a0,s4,352
    80001cfc:	8e4ff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001d00:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d04:	8552                	mv	a0,s4
    80001d06:	f61fe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001d0a:	0000e497          	auipc	s1,0xe
    80001d0e:	ca648493          	addi	s1,s1,-858 # 8000f9b0 <wait_lock>
    80001d12:	8526                	mv	a0,s1
    80001d14:	ebbfe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001d18:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	f49fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001d22:	8552                	mv	a0,s4
    80001d24:	eabfe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001d28:	478d                	li	a5,3
    80001d2a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d2e:	8552                	mv	a0,s4
    80001d30:	f37fe0ef          	jal	80000c66 <release>
  return pid;
    80001d34:	74a2                	ld	s1,40(sp)
    80001d36:	69e2                	ld	s3,24(sp)
    80001d38:	6a42                	ld	s4,16(sp)
}
    80001d3a:	854a                	mv	a0,s2
    80001d3c:	70e2                	ld	ra,56(sp)
    80001d3e:	7442                	ld	s0,48(sp)
    80001d40:	7902                	ld	s2,32(sp)
    80001d42:	6aa2                	ld	s5,8(sp)
    80001d44:	6121                	addi	sp,sp,64
    80001d46:	8082                	ret
    return -1;
    80001d48:	597d                	li	s2,-1
    80001d4a:	bfc5                	j	80001d3a <kfork+0xfc>

0000000080001d4c <scheduler>:
{
    80001d4c:	715d                	addi	sp,sp,-80
    80001d4e:	e486                	sd	ra,72(sp)
    80001d50:	e0a2                	sd	s0,64(sp)
    80001d52:	fc26                	sd	s1,56(sp)
    80001d54:	f84a                	sd	s2,48(sp)
    80001d56:	f44e                	sd	s3,40(sp)
    80001d58:	f052                	sd	s4,32(sp)
    80001d5a:	ec56                	sd	s5,24(sp)
    80001d5c:	e85a                	sd	s6,16(sp)
    80001d5e:	e45e                	sd	s7,8(sp)
    80001d60:	e062                	sd	s8,0(sp)
    80001d62:	0880                	addi	s0,sp,80
    80001d64:	8792                	mv	a5,tp
  int id = r_tp();
    80001d66:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d68:	00779b13          	slli	s6,a5,0x7
    80001d6c:	0000e717          	auipc	a4,0xe
    80001d70:	c2c70713          	addi	a4,a4,-980 # 8000f998 <pid_lock>
    80001d74:	975a                	add	a4,a4,s6
    80001d76:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d7a:	0000e717          	auipc	a4,0xe
    80001d7e:	c5670713          	addi	a4,a4,-938 # 8000f9d0 <cpus+0x8>
    80001d82:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d84:	4c11                	li	s8,4
        c->proc = p;
    80001d86:	079e                	slli	a5,a5,0x7
    80001d88:	0000ea17          	auipc	s4,0xe
    80001d8c:	c10a0a13          	addi	s4,s4,-1008 # 8000f998 <pid_lock>
    80001d90:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d92:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d94:	00014997          	auipc	s3,0x14
    80001d98:	c3498993          	addi	s3,s3,-972 # 800159c8 <tickslock>
    80001d9c:	a83d                	j	80001dda <scheduler+0x8e>
      release(&p->lock);
    80001d9e:	8526                	mv	a0,s1
    80001da0:	ec7fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001da4:	17048493          	addi	s1,s1,368
    80001da8:	03348563          	beq	s1,s3,80001dd2 <scheduler+0x86>
      acquire(&p->lock);
    80001dac:	8526                	mv	a0,s1
    80001dae:	e21fe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001db2:	4c9c                	lw	a5,24(s1)
    80001db4:	ff2795e3          	bne	a5,s2,80001d9e <scheduler+0x52>
        p->state = RUNNING;
    80001db8:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001dbc:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001dc0:	06048593          	addi	a1,s1,96
    80001dc4:	855a                	mv	a0,s6
    80001dc6:	5b2000ef          	jal	80002378 <swtch>
        c->proc = 0;
    80001dca:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dce:	8ade                	mv	s5,s7
    80001dd0:	b7f9                	j	80001d9e <scheduler+0x52>
    if(found == 0) {
    80001dd2:	000a9463          	bnez	s5,80001dda <scheduler+0x8e>
      asm volatile("wfi");
    80001dd6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dda:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dde:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001de2:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001de6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001dea:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dec:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001df0:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001df2:	0000e497          	auipc	s1,0xe
    80001df6:	fd648493          	addi	s1,s1,-42 # 8000fdc8 <proc>
      if(p->state == RUNNABLE) {
    80001dfa:	490d                	li	s2,3
    80001dfc:	bf45                	j	80001dac <scheduler+0x60>

0000000080001dfe <sched>:
{
    80001dfe:	7179                	addi	sp,sp,-48
    80001e00:	f406                	sd	ra,40(sp)
    80001e02:	f022                	sd	s0,32(sp)
    80001e04:	ec26                	sd	s1,24(sp)
    80001e06:	e84a                	sd	s2,16(sp)
    80001e08:	e44e                	sd	s3,8(sp)
    80001e0a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e0c:	ac3ff0ef          	jal	800018ce <myproc>
    80001e10:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e12:	d53fe0ef          	jal	80000b64 <holding>
    80001e16:	c92d                	beqz	a0,80001e88 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e18:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e1a:	2781                	sext.w	a5,a5
    80001e1c:	079e                	slli	a5,a5,0x7
    80001e1e:	0000e717          	auipc	a4,0xe
    80001e22:	b7a70713          	addi	a4,a4,-1158 # 8000f998 <pid_lock>
    80001e26:	97ba                	add	a5,a5,a4
    80001e28:	0a87a703          	lw	a4,168(a5)
    80001e2c:	4785                	li	a5,1
    80001e2e:	06f71363          	bne	a4,a5,80001e94 <sched+0x96>
  if(p->state == RUNNING)
    80001e32:	4c98                	lw	a4,24(s1)
    80001e34:	4791                	li	a5,4
    80001e36:	06f70563          	beq	a4,a5,80001ea0 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e40:	e7b5                	bnez	a5,80001eac <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e42:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e44:	0000e917          	auipc	s2,0xe
    80001e48:	b5490913          	addi	s2,s2,-1196 # 8000f998 <pid_lock>
    80001e4c:	2781                	sext.w	a5,a5
    80001e4e:	079e                	slli	a5,a5,0x7
    80001e50:	97ca                	add	a5,a5,s2
    80001e52:	0ac7a983          	lw	s3,172(a5)
    80001e56:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e58:	2781                	sext.w	a5,a5
    80001e5a:	079e                	slli	a5,a5,0x7
    80001e5c:	0000e597          	auipc	a1,0xe
    80001e60:	b7458593          	addi	a1,a1,-1164 # 8000f9d0 <cpus+0x8>
    80001e64:	95be                	add	a1,a1,a5
    80001e66:	06048513          	addi	a0,s1,96
    80001e6a:	50e000ef          	jal	80002378 <swtch>
    80001e6e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e70:	2781                	sext.w	a5,a5
    80001e72:	079e                	slli	a5,a5,0x7
    80001e74:	993e                	add	s2,s2,a5
    80001e76:	0b392623          	sw	s3,172(s2)
}
    80001e7a:	70a2                	ld	ra,40(sp)
    80001e7c:	7402                	ld	s0,32(sp)
    80001e7e:	64e2                	ld	s1,24(sp)
    80001e80:	6942                	ld	s2,16(sp)
    80001e82:	69a2                	ld	s3,8(sp)
    80001e84:	6145                	addi	sp,sp,48
    80001e86:	8082                	ret
    panic("sched p->lock");
    80001e88:	00005517          	auipc	a0,0x5
    80001e8c:	31050513          	addi	a0,a0,784 # 80007198 <etext+0x198>
    80001e90:	951fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80001e94:	00005517          	auipc	a0,0x5
    80001e98:	31450513          	addi	a0,a0,788 # 800071a8 <etext+0x1a8>
    80001e9c:	945fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80001ea0:	00005517          	auipc	a0,0x5
    80001ea4:	31850513          	addi	a0,a0,792 # 800071b8 <etext+0x1b8>
    80001ea8:	939fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80001eac:	00005517          	auipc	a0,0x5
    80001eb0:	31c50513          	addi	a0,a0,796 # 800071c8 <etext+0x1c8>
    80001eb4:	92dfe0ef          	jal	800007e0 <panic>

0000000080001eb8 <yield>:
{
    80001eb8:	1101                	addi	sp,sp,-32
    80001eba:	ec06                	sd	ra,24(sp)
    80001ebc:	e822                	sd	s0,16(sp)
    80001ebe:	e426                	sd	s1,8(sp)
    80001ec0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ec2:	a0dff0ef          	jal	800018ce <myproc>
    80001ec6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ec8:	d07fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    80001ecc:	478d                	li	a5,3
    80001ece:	cc9c                	sw	a5,24(s1)
  sched();
    80001ed0:	f2fff0ef          	jal	80001dfe <sched>
  release(&p->lock);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	d91fe0ef          	jal	80000c66 <release>
}
    80001eda:	60e2                	ld	ra,24(sp)
    80001edc:	6442                	ld	s0,16(sp)
    80001ede:	64a2                	ld	s1,8(sp)
    80001ee0:	6105                	addi	sp,sp,32
    80001ee2:	8082                	ret

0000000080001ee4 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ee4:	7179                	addi	sp,sp,-48
    80001ee6:	f406                	sd	ra,40(sp)
    80001ee8:	f022                	sd	s0,32(sp)
    80001eea:	ec26                	sd	s1,24(sp)
    80001eec:	e84a                	sd	s2,16(sp)
    80001eee:	e44e                	sd	s3,8(sp)
    80001ef0:	1800                	addi	s0,sp,48
    80001ef2:	89aa                	mv	s3,a0
    80001ef4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ef6:	9d9ff0ef          	jal	800018ce <myproc>
    80001efa:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001efc:	cd3fe0ef          	jal	80000bce <acquire>
  release(lk);
    80001f00:	854a                	mv	a0,s2
    80001f02:	d65fe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80001f06:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f0a:	4789                	li	a5,2
    80001f0c:	cc9c                	sw	a5,24(s1)

  sched();
    80001f0e:	ef1ff0ef          	jal	80001dfe <sched>

  // Tidy up.
  p->chan = 0;
    80001f12:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f16:	8526                	mv	a0,s1
    80001f18:	d4ffe0ef          	jal	80000c66 <release>
  acquire(lk);
    80001f1c:	854a                	mv	a0,s2
    80001f1e:	cb1fe0ef          	jal	80000bce <acquire>
}
    80001f22:	70a2                	ld	ra,40(sp)
    80001f24:	7402                	ld	s0,32(sp)
    80001f26:	64e2                	ld	s1,24(sp)
    80001f28:	6942                	ld	s2,16(sp)
    80001f2a:	69a2                	ld	s3,8(sp)
    80001f2c:	6145                	addi	sp,sp,48
    80001f2e:	8082                	ret

0000000080001f30 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f30:	7139                	addi	sp,sp,-64
    80001f32:	fc06                	sd	ra,56(sp)
    80001f34:	f822                	sd	s0,48(sp)
    80001f36:	f426                	sd	s1,40(sp)
    80001f38:	f04a                	sd	s2,32(sp)
    80001f3a:	ec4e                	sd	s3,24(sp)
    80001f3c:	e852                	sd	s4,16(sp)
    80001f3e:	e456                	sd	s5,8(sp)
    80001f40:	0080                	addi	s0,sp,64
    80001f42:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f44:	0000e497          	auipc	s1,0xe
    80001f48:	e8448493          	addi	s1,s1,-380 # 8000fdc8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f4c:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f4e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f50:	00014917          	auipc	s2,0x14
    80001f54:	a7890913          	addi	s2,s2,-1416 # 800159c8 <tickslock>
    80001f58:	a801                	j	80001f68 <wakeup+0x38>
      }
      release(&p->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	d0bfe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f60:	17048493          	addi	s1,s1,368
    80001f64:	03248263          	beq	s1,s2,80001f88 <wakeup+0x58>
    if(p != myproc()){
    80001f68:	967ff0ef          	jal	800018ce <myproc>
    80001f6c:	fea48ae3          	beq	s1,a0,80001f60 <wakeup+0x30>
      acquire(&p->lock);
    80001f70:	8526                	mv	a0,s1
    80001f72:	c5dfe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f76:	4c9c                	lw	a5,24(s1)
    80001f78:	ff3791e3          	bne	a5,s3,80001f5a <wakeup+0x2a>
    80001f7c:	709c                	ld	a5,32(s1)
    80001f7e:	fd479ee3          	bne	a5,s4,80001f5a <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f82:	0154ac23          	sw	s5,24(s1)
    80001f86:	bfd1                	j	80001f5a <wakeup+0x2a>
    }
  }
}
    80001f88:	70e2                	ld	ra,56(sp)
    80001f8a:	7442                	ld	s0,48(sp)
    80001f8c:	74a2                	ld	s1,40(sp)
    80001f8e:	7902                	ld	s2,32(sp)
    80001f90:	69e2                	ld	s3,24(sp)
    80001f92:	6a42                	ld	s4,16(sp)
    80001f94:	6aa2                	ld	s5,8(sp)
    80001f96:	6121                	addi	sp,sp,64
    80001f98:	8082                	ret

0000000080001f9a <reparent>:
{
    80001f9a:	7179                	addi	sp,sp,-48
    80001f9c:	f406                	sd	ra,40(sp)
    80001f9e:	f022                	sd	s0,32(sp)
    80001fa0:	ec26                	sd	s1,24(sp)
    80001fa2:	e84a                	sd	s2,16(sp)
    80001fa4:	e44e                	sd	s3,8(sp)
    80001fa6:	e052                	sd	s4,0(sp)
    80001fa8:	1800                	addi	s0,sp,48
    80001faa:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fac:	0000e497          	auipc	s1,0xe
    80001fb0:	e1c48493          	addi	s1,s1,-484 # 8000fdc8 <proc>
      pp->parent = initproc;
    80001fb4:	00006a17          	auipc	s4,0x6
    80001fb8:	8dca0a13          	addi	s4,s4,-1828 # 80007890 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fbc:	00014997          	auipc	s3,0x14
    80001fc0:	a0c98993          	addi	s3,s3,-1524 # 800159c8 <tickslock>
    80001fc4:	a029                	j	80001fce <reparent+0x34>
    80001fc6:	17048493          	addi	s1,s1,368
    80001fca:	01348b63          	beq	s1,s3,80001fe0 <reparent+0x46>
    if(pp->parent == p){
    80001fce:	7c9c                	ld	a5,56(s1)
    80001fd0:	ff279be3          	bne	a5,s2,80001fc6 <reparent+0x2c>
      pp->parent = initproc;
    80001fd4:	000a3503          	ld	a0,0(s4)
    80001fd8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fda:	f57ff0ef          	jal	80001f30 <wakeup>
    80001fde:	b7e5                	j	80001fc6 <reparent+0x2c>
}
    80001fe0:	70a2                	ld	ra,40(sp)
    80001fe2:	7402                	ld	s0,32(sp)
    80001fe4:	64e2                	ld	s1,24(sp)
    80001fe6:	6942                	ld	s2,16(sp)
    80001fe8:	69a2                	ld	s3,8(sp)
    80001fea:	6a02                	ld	s4,0(sp)
    80001fec:	6145                	addi	sp,sp,48
    80001fee:	8082                	ret

0000000080001ff0 <kexit>:
{
    80001ff0:	7179                	addi	sp,sp,-48
    80001ff2:	f406                	sd	ra,40(sp)
    80001ff4:	f022                	sd	s0,32(sp)
    80001ff6:	ec26                	sd	s1,24(sp)
    80001ff8:	e84a                	sd	s2,16(sp)
    80001ffa:	e44e                	sd	s3,8(sp)
    80001ffc:	e052                	sd	s4,0(sp)
    80001ffe:	1800                	addi	s0,sp,48
    80002000:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002002:	8cdff0ef          	jal	800018ce <myproc>
    80002006:	89aa                	mv	s3,a0
  if(p == initproc)
    80002008:	00006797          	auipc	a5,0x6
    8000200c:	8887b783          	ld	a5,-1912(a5) # 80007890 <initproc>
    80002010:	0d050493          	addi	s1,a0,208
    80002014:	15050913          	addi	s2,a0,336
    80002018:	00a79f63          	bne	a5,a0,80002036 <kexit+0x46>
    panic("init exiting");
    8000201c:	00005517          	auipc	a0,0x5
    80002020:	1c450513          	addi	a0,a0,452 # 800071e0 <etext+0x1e0>
    80002024:	fbcfe0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002028:	02c020ef          	jal	80004054 <fileclose>
      p->ofile[fd] = 0;
    8000202c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002030:	04a1                	addi	s1,s1,8
    80002032:	01248563          	beq	s1,s2,8000203c <kexit+0x4c>
    if(p->ofile[fd]){
    80002036:	6088                	ld	a0,0(s1)
    80002038:	f965                	bnez	a0,80002028 <kexit+0x38>
    8000203a:	bfdd                	j	80002030 <kexit+0x40>
  begin_op();
    8000203c:	40d010ef          	jal	80003c48 <begin_op>
  iput(p->cwd);
    80002040:	1509b503          	ld	a0,336(s3)
    80002044:	39c010ef          	jal	800033e0 <iput>
  end_op();
    80002048:	46b010ef          	jal	80003cb2 <end_op>
  p->cwd = 0;
    8000204c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002050:	0000e497          	auipc	s1,0xe
    80002054:	96048493          	addi	s1,s1,-1696 # 8000f9b0 <wait_lock>
    80002058:	8526                	mv	a0,s1
    8000205a:	b75fe0ef          	jal	80000bce <acquire>
  reparent(p);
    8000205e:	854e                	mv	a0,s3
    80002060:	f3bff0ef          	jal	80001f9a <reparent>
  wakeup(p->parent);
    80002064:	0389b503          	ld	a0,56(s3)
    80002068:	ec9ff0ef          	jal	80001f30 <wakeup>
  acquire(&p->lock);
    8000206c:	854e                	mv	a0,s3
    8000206e:	b61fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002072:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002076:	4795                	li	a5,5
    80002078:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	be9fe0ef          	jal	80000c66 <release>
  sched();
    80002082:	d7dff0ef          	jal	80001dfe <sched>
  panic("zombie exit");
    80002086:	00005517          	auipc	a0,0x5
    8000208a:	16a50513          	addi	a0,a0,362 # 800071f0 <etext+0x1f0>
    8000208e:	f52fe0ef          	jal	800007e0 <panic>

0000000080002092 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002092:	7179                	addi	sp,sp,-48
    80002094:	f406                	sd	ra,40(sp)
    80002096:	f022                	sd	s0,32(sp)
    80002098:	ec26                	sd	s1,24(sp)
    8000209a:	e84a                	sd	s2,16(sp)
    8000209c:	e44e                	sd	s3,8(sp)
    8000209e:	1800                	addi	s0,sp,48
    800020a0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020a2:	0000e497          	auipc	s1,0xe
    800020a6:	d2648493          	addi	s1,s1,-730 # 8000fdc8 <proc>
    800020aa:	00014997          	auipc	s3,0x14
    800020ae:	91e98993          	addi	s3,s3,-1762 # 800159c8 <tickslock>
    acquire(&p->lock);
    800020b2:	8526                	mv	a0,s1
    800020b4:	b1bfe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    800020b8:	589c                	lw	a5,48(s1)
    800020ba:	01278b63          	beq	a5,s2,800020d0 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020be:	8526                	mv	a0,s1
    800020c0:	ba7fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020c4:	17048493          	addi	s1,s1,368
    800020c8:	ff3495e3          	bne	s1,s3,800020b2 <kkill+0x20>
  }
  return -1;
    800020cc:	557d                	li	a0,-1
    800020ce:	a819                	j	800020e4 <kkill+0x52>
      p->killed = 1;
    800020d0:	4785                	li	a5,1
    800020d2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020d4:	4c98                	lw	a4,24(s1)
    800020d6:	4789                	li	a5,2
    800020d8:	00f70d63          	beq	a4,a5,800020f2 <kkill+0x60>
      release(&p->lock);
    800020dc:	8526                	mv	a0,s1
    800020de:	b89fe0ef          	jal	80000c66 <release>
      return 0;
    800020e2:	4501                	li	a0,0
}
    800020e4:	70a2                	ld	ra,40(sp)
    800020e6:	7402                	ld	s0,32(sp)
    800020e8:	64e2                	ld	s1,24(sp)
    800020ea:	6942                	ld	s2,16(sp)
    800020ec:	69a2                	ld	s3,8(sp)
    800020ee:	6145                	addi	sp,sp,48
    800020f0:	8082                	ret
        p->state = RUNNABLE;
    800020f2:	478d                	li	a5,3
    800020f4:	cc9c                	sw	a5,24(s1)
    800020f6:	b7dd                	j	800020dc <kkill+0x4a>

00000000800020f8 <setkilled>:

void
setkilled(struct proc *p)
{
    800020f8:	1101                	addi	sp,sp,-32
    800020fa:	ec06                	sd	ra,24(sp)
    800020fc:	e822                	sd	s0,16(sp)
    800020fe:	e426                	sd	s1,8(sp)
    80002100:	1000                	addi	s0,sp,32
    80002102:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002104:	acbfe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    80002108:	4785                	li	a5,1
    8000210a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000210c:	8526                	mv	a0,s1
    8000210e:	b59fe0ef          	jal	80000c66 <release>
}
    80002112:	60e2                	ld	ra,24(sp)
    80002114:	6442                	ld	s0,16(sp)
    80002116:	64a2                	ld	s1,8(sp)
    80002118:	6105                	addi	sp,sp,32
    8000211a:	8082                	ret

000000008000211c <killed>:

int
killed(struct proc *p)
{
    8000211c:	1101                	addi	sp,sp,-32
    8000211e:	ec06                	sd	ra,24(sp)
    80002120:	e822                	sd	s0,16(sp)
    80002122:	e426                	sd	s1,8(sp)
    80002124:	e04a                	sd	s2,0(sp)
    80002126:	1000                	addi	s0,sp,32
    80002128:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000212a:	aa5fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    8000212e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002132:	8526                	mv	a0,s1
    80002134:	b33fe0ef          	jal	80000c66 <release>
  return k;
}
    80002138:	854a                	mv	a0,s2
    8000213a:	60e2                	ld	ra,24(sp)
    8000213c:	6442                	ld	s0,16(sp)
    8000213e:	64a2                	ld	s1,8(sp)
    80002140:	6902                	ld	s2,0(sp)
    80002142:	6105                	addi	sp,sp,32
    80002144:	8082                	ret

0000000080002146 <kwait>:
{
    80002146:	715d                	addi	sp,sp,-80
    80002148:	e486                	sd	ra,72(sp)
    8000214a:	e0a2                	sd	s0,64(sp)
    8000214c:	fc26                	sd	s1,56(sp)
    8000214e:	f84a                	sd	s2,48(sp)
    80002150:	f44e                	sd	s3,40(sp)
    80002152:	f052                	sd	s4,32(sp)
    80002154:	ec56                	sd	s5,24(sp)
    80002156:	e85a                	sd	s6,16(sp)
    80002158:	e45e                	sd	s7,8(sp)
    8000215a:	e062                	sd	s8,0(sp)
    8000215c:	0880                	addi	s0,sp,80
    8000215e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002160:	f6eff0ef          	jal	800018ce <myproc>
    80002164:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002166:	0000e517          	auipc	a0,0xe
    8000216a:	84a50513          	addi	a0,a0,-1974 # 8000f9b0 <wait_lock>
    8000216e:	a61fe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002172:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002174:	4a15                	li	s4,5
        havekids = 1;
    80002176:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002178:	00014997          	auipc	s3,0x14
    8000217c:	85098993          	addi	s3,s3,-1968 # 800159c8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002180:	0000ec17          	auipc	s8,0xe
    80002184:	830c0c13          	addi	s8,s8,-2000 # 8000f9b0 <wait_lock>
    80002188:	a871                	j	80002224 <kwait+0xde>
          pid = pp->pid;
    8000218a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000218e:	000b0c63          	beqz	s6,800021a6 <kwait+0x60>
    80002192:	4691                	li	a3,4
    80002194:	02c48613          	addi	a2,s1,44
    80002198:	85da                	mv	a1,s6
    8000219a:	05093503          	ld	a0,80(s2)
    8000219e:	c44ff0ef          	jal	800015e2 <copyout>
    800021a2:	02054b63          	bltz	a0,800021d8 <kwait+0x92>
          freeproc(pp);
    800021a6:	8526                	mv	a0,s1
    800021a8:	8f7ff0ef          	jal	80001a9e <freeproc>
          release(&pp->lock);
    800021ac:	8526                	mv	a0,s1
    800021ae:	ab9fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    800021b2:	0000d517          	auipc	a0,0xd
    800021b6:	7fe50513          	addi	a0,a0,2046 # 8000f9b0 <wait_lock>
    800021ba:	aadfe0ef          	jal	80000c66 <release>
}
    800021be:	854e                	mv	a0,s3
    800021c0:	60a6                	ld	ra,72(sp)
    800021c2:	6406                	ld	s0,64(sp)
    800021c4:	74e2                	ld	s1,56(sp)
    800021c6:	7942                	ld	s2,48(sp)
    800021c8:	79a2                	ld	s3,40(sp)
    800021ca:	7a02                	ld	s4,32(sp)
    800021cc:	6ae2                	ld	s5,24(sp)
    800021ce:	6b42                	ld	s6,16(sp)
    800021d0:	6ba2                	ld	s7,8(sp)
    800021d2:	6c02                	ld	s8,0(sp)
    800021d4:	6161                	addi	sp,sp,80
    800021d6:	8082                	ret
            release(&pp->lock);
    800021d8:	8526                	mv	a0,s1
    800021da:	a8dfe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800021de:	0000d517          	auipc	a0,0xd
    800021e2:	7d250513          	addi	a0,a0,2002 # 8000f9b0 <wait_lock>
    800021e6:	a81fe0ef          	jal	80000c66 <release>
            return -1;
    800021ea:	59fd                	li	s3,-1
    800021ec:	bfc9                	j	800021be <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ee:	17048493          	addi	s1,s1,368
    800021f2:	03348063          	beq	s1,s3,80002212 <kwait+0xcc>
      if(pp->parent == p){
    800021f6:	7c9c                	ld	a5,56(s1)
    800021f8:	ff279be3          	bne	a5,s2,800021ee <kwait+0xa8>
        acquire(&pp->lock);
    800021fc:	8526                	mv	a0,s1
    800021fe:	9d1fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    80002202:	4c9c                	lw	a5,24(s1)
    80002204:	f94783e3          	beq	a5,s4,8000218a <kwait+0x44>
        release(&pp->lock);
    80002208:	8526                	mv	a0,s1
    8000220a:	a5dfe0ef          	jal	80000c66 <release>
        havekids = 1;
    8000220e:	8756                	mv	a4,s5
    80002210:	bff9                	j	800021ee <kwait+0xa8>
    if(!havekids || killed(p)){
    80002212:	cf19                	beqz	a4,80002230 <kwait+0xea>
    80002214:	854a                	mv	a0,s2
    80002216:	f07ff0ef          	jal	8000211c <killed>
    8000221a:	e919                	bnez	a0,80002230 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000221c:	85e2                	mv	a1,s8
    8000221e:	854a                	mv	a0,s2
    80002220:	cc5ff0ef          	jal	80001ee4 <sleep>
    havekids = 0;
    80002224:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002226:	0000e497          	auipc	s1,0xe
    8000222a:	ba248493          	addi	s1,s1,-1118 # 8000fdc8 <proc>
    8000222e:	b7e1                	j	800021f6 <kwait+0xb0>
      release(&wait_lock);
    80002230:	0000d517          	auipc	a0,0xd
    80002234:	78050513          	addi	a0,a0,1920 # 8000f9b0 <wait_lock>
    80002238:	a2ffe0ef          	jal	80000c66 <release>
      return -1;
    8000223c:	59fd                	li	s3,-1
    8000223e:	b741                	j	800021be <kwait+0x78>

0000000080002240 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002240:	7179                	addi	sp,sp,-48
    80002242:	f406                	sd	ra,40(sp)
    80002244:	f022                	sd	s0,32(sp)
    80002246:	ec26                	sd	s1,24(sp)
    80002248:	e84a                	sd	s2,16(sp)
    8000224a:	e44e                	sd	s3,8(sp)
    8000224c:	e052                	sd	s4,0(sp)
    8000224e:	1800                	addi	s0,sp,48
    80002250:	84aa                	mv	s1,a0
    80002252:	892e                	mv	s2,a1
    80002254:	89b2                	mv	s3,a2
    80002256:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002258:	e76ff0ef          	jal	800018ce <myproc>
  if(user_dst){
    8000225c:	cc99                	beqz	s1,8000227a <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000225e:	86d2                	mv	a3,s4
    80002260:	864e                	mv	a2,s3
    80002262:	85ca                	mv	a1,s2
    80002264:	6928                	ld	a0,80(a0)
    80002266:	b7cff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000226a:	70a2                	ld	ra,40(sp)
    8000226c:	7402                	ld	s0,32(sp)
    8000226e:	64e2                	ld	s1,24(sp)
    80002270:	6942                	ld	s2,16(sp)
    80002272:	69a2                	ld	s3,8(sp)
    80002274:	6a02                	ld	s4,0(sp)
    80002276:	6145                	addi	sp,sp,48
    80002278:	8082                	ret
    memmove((char *)dst, src, len);
    8000227a:	000a061b          	sext.w	a2,s4
    8000227e:	85ce                	mv	a1,s3
    80002280:	854a                	mv	a0,s2
    80002282:	a7dfe0ef          	jal	80000cfe <memmove>
    return 0;
    80002286:	8526                	mv	a0,s1
    80002288:	b7cd                	j	8000226a <either_copyout+0x2a>

000000008000228a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000228a:	7179                	addi	sp,sp,-48
    8000228c:	f406                	sd	ra,40(sp)
    8000228e:	f022                	sd	s0,32(sp)
    80002290:	ec26                	sd	s1,24(sp)
    80002292:	e84a                	sd	s2,16(sp)
    80002294:	e44e                	sd	s3,8(sp)
    80002296:	e052                	sd	s4,0(sp)
    80002298:	1800                	addi	s0,sp,48
    8000229a:	892a                	mv	s2,a0
    8000229c:	84ae                	mv	s1,a1
    8000229e:	89b2                	mv	s3,a2
    800022a0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022a2:	e2cff0ef          	jal	800018ce <myproc>
  if(user_src){
    800022a6:	cc99                	beqz	s1,800022c4 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022a8:	86d2                	mv	a3,s4
    800022aa:	864e                	mv	a2,s3
    800022ac:	85ca                	mv	a1,s2
    800022ae:	6928                	ld	a0,80(a0)
    800022b0:	c16ff0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022b4:	70a2                	ld	ra,40(sp)
    800022b6:	7402                	ld	s0,32(sp)
    800022b8:	64e2                	ld	s1,24(sp)
    800022ba:	6942                	ld	s2,16(sp)
    800022bc:	69a2                	ld	s3,8(sp)
    800022be:	6a02                	ld	s4,0(sp)
    800022c0:	6145                	addi	sp,sp,48
    800022c2:	8082                	ret
    memmove(dst, (char*)src, len);
    800022c4:	000a061b          	sext.w	a2,s4
    800022c8:	85ce                	mv	a1,s3
    800022ca:	854a                	mv	a0,s2
    800022cc:	a33fe0ef          	jal	80000cfe <memmove>
    return 0;
    800022d0:	8526                	mv	a0,s1
    800022d2:	b7cd                	j	800022b4 <either_copyin+0x2a>

00000000800022d4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022d4:	715d                	addi	sp,sp,-80
    800022d6:	e486                	sd	ra,72(sp)
    800022d8:	e0a2                	sd	s0,64(sp)
    800022da:	fc26                	sd	s1,56(sp)
    800022dc:	f84a                	sd	s2,48(sp)
    800022de:	f44e                	sd	s3,40(sp)
    800022e0:	f052                	sd	s4,32(sp)
    800022e2:	ec56                	sd	s5,24(sp)
    800022e4:	e85a                	sd	s6,16(sp)
    800022e6:	e45e                	sd	s7,8(sp)
    800022e8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022ea:	00005517          	auipc	a0,0x5
    800022ee:	d8e50513          	addi	a0,a0,-626 # 80007078 <etext+0x78>
    800022f2:	a08fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022f6:	0000e497          	auipc	s1,0xe
    800022fa:	c3248493          	addi	s1,s1,-974 # 8000ff28 <proc+0x160>
    800022fe:	00014917          	auipc	s2,0x14
    80002302:	82a90913          	addi	s2,s2,-2006 # 80015b28 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002306:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002308:	00005997          	auipc	s3,0x5
    8000230c:	ef898993          	addi	s3,s3,-264 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80002310:	00005a97          	auipc	s5,0x5
    80002314:	ef8a8a93          	addi	s5,s5,-264 # 80007208 <etext+0x208>
    printf("\n");
    80002318:	00005a17          	auipc	s4,0x5
    8000231c:	d60a0a13          	addi	s4,s4,-672 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002320:	00005b97          	auipc	s7,0x5
    80002324:	430b8b93          	addi	s7,s7,1072 # 80007750 <states.0>
    80002328:	a829                	j	80002342 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000232a:	ed06a583          	lw	a1,-304(a3)
    8000232e:	8556                	mv	a0,s5
    80002330:	9cafe0ef          	jal	800004fa <printf>
    printf("\n");
    80002334:	8552                	mv	a0,s4
    80002336:	9c4fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000233a:	17048493          	addi	s1,s1,368
    8000233e:	03248263          	beq	s1,s2,80002362 <procdump+0x8e>
    if(p->state == UNUSED)
    80002342:	86a6                	mv	a3,s1
    80002344:	eb84a783          	lw	a5,-328(s1)
    80002348:	dbed                	beqz	a5,8000233a <procdump+0x66>
      state = "???";
    8000234a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000234c:	fcfb6fe3          	bltu	s6,a5,8000232a <procdump+0x56>
    80002350:	02079713          	slli	a4,a5,0x20
    80002354:	01d75793          	srli	a5,a4,0x1d
    80002358:	97de                	add	a5,a5,s7
    8000235a:	6390                	ld	a2,0(a5)
    8000235c:	f679                	bnez	a2,8000232a <procdump+0x56>
      state = "???";
    8000235e:	864e                	mv	a2,s3
    80002360:	b7e9                	j	8000232a <procdump+0x56>
  }
}
    80002362:	60a6                	ld	ra,72(sp)
    80002364:	6406                	ld	s0,64(sp)
    80002366:	74e2                	ld	s1,56(sp)
    80002368:	7942                	ld	s2,48(sp)
    8000236a:	79a2                	ld	s3,40(sp)
    8000236c:	7a02                	ld	s4,32(sp)
    8000236e:	6ae2                	ld	s5,24(sp)
    80002370:	6b42                	ld	s6,16(sp)
    80002372:	6ba2                	ld	s7,8(sp)
    80002374:	6161                	addi	sp,sp,80
    80002376:	8082                	ret

0000000080002378 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002378:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000237c:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002380:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002382:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002384:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002388:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000238c:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002390:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002394:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002398:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000239c:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800023a0:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023a4:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800023a8:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023ac:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023b0:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023b4:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800023b6:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023b8:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023bc:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023c0:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023c4:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023c8:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023cc:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023d0:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023d4:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800023d8:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023dc:	0685bd83          	ld	s11,104(a1)
        
        ret
    800023e0:	8082                	ret

00000000800023e2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023e2:	1141                	addi	sp,sp,-16
    800023e4:	e406                	sd	ra,8(sp)
    800023e6:	e022                	sd	s0,0(sp)
    800023e8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023ea:	00005597          	auipc	a1,0x5
    800023ee:	e5e58593          	addi	a1,a1,-418 # 80007248 <etext+0x248>
    800023f2:	00013517          	auipc	a0,0x13
    800023f6:	5d650513          	addi	a0,a0,1494 # 800159c8 <tickslock>
    800023fa:	f54fe0ef          	jal	80000b4e <initlock>
}
    800023fe:	60a2                	ld	ra,8(sp)
    80002400:	6402                	ld	s0,0(sp)
    80002402:	0141                	addi	sp,sp,16
    80002404:	8082                	ret

0000000080002406 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002406:	1141                	addi	sp,sp,-16
    80002408:	e422                	sd	s0,8(sp)
    8000240a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000240c:	00003797          	auipc	a5,0x3
    80002410:	fc478793          	addi	a5,a5,-60 # 800053d0 <kernelvec>
    80002414:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002418:	6422                	ld	s0,8(sp)
    8000241a:	0141                	addi	sp,sp,16
    8000241c:	8082                	ret

000000008000241e <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000241e:	1141                	addi	sp,sp,-16
    80002420:	e406                	sd	ra,8(sp)
    80002422:	e022                	sd	s0,0(sp)
    80002424:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002426:	ca8ff0ef          	jal	800018ce <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000242a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000242e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002430:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002434:	04000737          	lui	a4,0x4000
    80002438:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000243a:	0732                	slli	a4,a4,0xc
    8000243c:	00004797          	auipc	a5,0x4
    80002440:	bc478793          	addi	a5,a5,-1084 # 80006000 <_trampoline>
    80002444:	00004697          	auipc	a3,0x4
    80002448:	bbc68693          	addi	a3,a3,-1092 # 80006000 <_trampoline>
    8000244c:	8f95                	sub	a5,a5,a3
    8000244e:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002450:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002454:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002456:	18002773          	csrr	a4,satp
    8000245a:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000245c:	6d38                	ld	a4,88(a0)
    8000245e:	613c                	ld	a5,64(a0)
    80002460:	6685                	lui	a3,0x1
    80002462:	97b6                	add	a5,a5,a3
    80002464:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002466:	6d3c                	ld	a5,88(a0)
    80002468:	00000717          	auipc	a4,0x0
    8000246c:	0f870713          	addi	a4,a4,248 # 80002560 <usertrap>
    80002470:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002472:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002474:	8712                	mv	a4,tp
    80002476:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002478:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000247c:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002480:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002484:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002488:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000248a:	6f9c                	ld	a5,24(a5)
    8000248c:	14179073          	csrw	sepc,a5
}
    80002490:	60a2                	ld	ra,8(sp)
    80002492:	6402                	ld	s0,0(sp)
    80002494:	0141                	addi	sp,sp,16
    80002496:	8082                	ret

0000000080002498 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002498:	1101                	addi	sp,sp,-32
    8000249a:	ec06                	sd	ra,24(sp)
    8000249c:	e822                	sd	s0,16(sp)
    8000249e:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800024a0:	c02ff0ef          	jal	800018a2 <cpuid>
    800024a4:	cd11                	beqz	a0,800024c0 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024a6:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024aa:	000f4737          	lui	a4,0xf4
    800024ae:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024b2:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024b4:	14d79073          	csrw	stimecmp,a5
}
    800024b8:	60e2                	ld	ra,24(sp)
    800024ba:	6442                	ld	s0,16(sp)
    800024bc:	6105                	addi	sp,sp,32
    800024be:	8082                	ret
    800024c0:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024c2:	00013497          	auipc	s1,0x13
    800024c6:	50648493          	addi	s1,s1,1286 # 800159c8 <tickslock>
    800024ca:	8526                	mv	a0,s1
    800024cc:	f02fe0ef          	jal	80000bce <acquire>
    ticks++;
    800024d0:	00005517          	auipc	a0,0x5
    800024d4:	3c850513          	addi	a0,a0,968 # 80007898 <ticks>
    800024d8:	411c                	lw	a5,0(a0)
    800024da:	2785                	addiw	a5,a5,1
    800024dc:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024de:	a53ff0ef          	jal	80001f30 <wakeup>
    release(&tickslock);
    800024e2:	8526                	mv	a0,s1
    800024e4:	f82fe0ef          	jal	80000c66 <release>
    800024e8:	64a2                	ld	s1,8(sp)
    800024ea:	bf75                	j	800024a6 <clockintr+0xe>

00000000800024ec <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024ec:	1101                	addi	sp,sp,-32
    800024ee:	ec06                	sd	ra,24(sp)
    800024f0:	e822                	sd	s0,16(sp)
    800024f2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024f4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024f8:	57fd                	li	a5,-1
    800024fa:	17fe                	slli	a5,a5,0x3f
    800024fc:	07a5                	addi	a5,a5,9
    800024fe:	00f70c63          	beq	a4,a5,80002516 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002502:	57fd                	li	a5,-1
    80002504:	17fe                	slli	a5,a5,0x3f
    80002506:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002508:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000250a:	04f70763          	beq	a4,a5,80002558 <devintr+0x6c>
  }
}
    8000250e:	60e2                	ld	ra,24(sp)
    80002510:	6442                	ld	s0,16(sp)
    80002512:	6105                	addi	sp,sp,32
    80002514:	8082                	ret
    80002516:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002518:	765020ef          	jal	8000547c <plic_claim>
    8000251c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000251e:	47a9                	li	a5,10
    80002520:	00f50963          	beq	a0,a5,80002532 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002524:	4785                	li	a5,1
    80002526:	00f50963          	beq	a0,a5,80002538 <devintr+0x4c>
    return 1;
    8000252a:	4505                	li	a0,1
    } else if(irq){
    8000252c:	e889                	bnez	s1,8000253e <devintr+0x52>
    8000252e:	64a2                	ld	s1,8(sp)
    80002530:	bff9                	j	8000250e <devintr+0x22>
      uartintr();
    80002532:	c7efe0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002536:	a819                	j	8000254c <devintr+0x60>
      virtio_disk_intr();
    80002538:	40a030ef          	jal	80005942 <virtio_disk_intr>
    if(irq)
    8000253c:	a801                	j	8000254c <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000253e:	85a6                	mv	a1,s1
    80002540:	00005517          	auipc	a0,0x5
    80002544:	d1050513          	addi	a0,a0,-752 # 80007250 <etext+0x250>
    80002548:	fb3fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    8000254c:	8526                	mv	a0,s1
    8000254e:	74f020ef          	jal	8000549c <plic_complete>
    return 1;
    80002552:	4505                	li	a0,1
    80002554:	64a2                	ld	s1,8(sp)
    80002556:	bf65                	j	8000250e <devintr+0x22>
    clockintr();
    80002558:	f41ff0ef          	jal	80002498 <clockintr>
    return 2;
    8000255c:	4509                	li	a0,2
    8000255e:	bf45                	j	8000250e <devintr+0x22>

0000000080002560 <usertrap>:
{
    80002560:	1101                	addi	sp,sp,-32
    80002562:	ec06                	sd	ra,24(sp)
    80002564:	e822                	sd	s0,16(sp)
    80002566:	e426                	sd	s1,8(sp)
    80002568:	e04a                	sd	s2,0(sp)
    8000256a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000256c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002570:	1007f793          	andi	a5,a5,256
    80002574:	eba5                	bnez	a5,800025e4 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002576:	00003797          	auipc	a5,0x3
    8000257a:	e5a78793          	addi	a5,a5,-422 # 800053d0 <kernelvec>
    8000257e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002582:	b4cff0ef          	jal	800018ce <myproc>
    80002586:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002588:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000258a:	14102773          	csrr	a4,sepc
    8000258e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002590:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002594:	47a1                	li	a5,8
    80002596:	04f70d63          	beq	a4,a5,800025f0 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    8000259a:	f53ff0ef          	jal	800024ec <devintr>
    8000259e:	892a                	mv	s2,a0
    800025a0:	e945                	bnez	a0,80002650 <usertrap+0xf0>
    800025a2:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800025a6:	47bd                	li	a5,15
    800025a8:	08f70863          	beq	a4,a5,80002638 <usertrap+0xd8>
    800025ac:	14202773          	csrr	a4,scause
    800025b0:	47b5                	li	a5,13
    800025b2:	08f70363          	beq	a4,a5,80002638 <usertrap+0xd8>
    800025b6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025ba:	5890                	lw	a2,48(s1)
    800025bc:	00005517          	auipc	a0,0x5
    800025c0:	cd450513          	addi	a0,a0,-812 # 80007290 <etext+0x290>
    800025c4:	f37fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025c8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025cc:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025d0:	00005517          	auipc	a0,0x5
    800025d4:	cf050513          	addi	a0,a0,-784 # 800072c0 <etext+0x2c0>
    800025d8:	f23fd0ef          	jal	800004fa <printf>
    setkilled(p);
    800025dc:	8526                	mv	a0,s1
    800025de:	b1bff0ef          	jal	800020f8 <setkilled>
    800025e2:	a035                	j	8000260e <usertrap+0xae>
    panic("usertrap: not from user mode");
    800025e4:	00005517          	auipc	a0,0x5
    800025e8:	c8c50513          	addi	a0,a0,-884 # 80007270 <etext+0x270>
    800025ec:	9f4fe0ef          	jal	800007e0 <panic>
    if(killed(p))
    800025f0:	b2dff0ef          	jal	8000211c <killed>
    800025f4:	ed15                	bnez	a0,80002630 <usertrap+0xd0>
    p->trapframe->epc += 4;
    800025f6:	6cb8                	ld	a4,88(s1)
    800025f8:	6f1c                	ld	a5,24(a4)
    800025fa:	0791                	addi	a5,a5,4
    800025fc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025fe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002602:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002606:	10079073          	csrw	sstatus,a5
    syscall();
    8000260a:	248000ef          	jal	80002852 <syscall>
  if(killed(p))
    8000260e:	8526                	mv	a0,s1
    80002610:	b0dff0ef          	jal	8000211c <killed>
    80002614:	e139                	bnez	a0,8000265a <usertrap+0xfa>
  prepare_return();
    80002616:	e09ff0ef          	jal	8000241e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000261a:	68a8                	ld	a0,80(s1)
    8000261c:	8131                	srli	a0,a0,0xc
    8000261e:	57fd                	li	a5,-1
    80002620:	17fe                	slli	a5,a5,0x3f
    80002622:	8d5d                	or	a0,a0,a5
}
    80002624:	60e2                	ld	ra,24(sp)
    80002626:	6442                	ld	s0,16(sp)
    80002628:	64a2                	ld	s1,8(sp)
    8000262a:	6902                	ld	s2,0(sp)
    8000262c:	6105                	addi	sp,sp,32
    8000262e:	8082                	ret
      kexit(-1);
    80002630:	557d                	li	a0,-1
    80002632:	9bfff0ef          	jal	80001ff0 <kexit>
    80002636:	b7c1                	j	800025f6 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002638:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000263c:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002640:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002642:	00163613          	seqz	a2,a2
    80002646:	68a8                	ld	a0,80(s1)
    80002648:	f19fe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000264c:	f169                	bnez	a0,8000260e <usertrap+0xae>
    8000264e:	b7a5                	j	800025b6 <usertrap+0x56>
  if(killed(p))
    80002650:	8526                	mv	a0,s1
    80002652:	acbff0ef          	jal	8000211c <killed>
    80002656:	c511                	beqz	a0,80002662 <usertrap+0x102>
    80002658:	a011                	j	8000265c <usertrap+0xfc>
    8000265a:	4901                	li	s2,0
    kexit(-1);
    8000265c:	557d                	li	a0,-1
    8000265e:	993ff0ef          	jal	80001ff0 <kexit>
  if(which_dev == 2)
    80002662:	4789                	li	a5,2
    80002664:	faf919e3          	bne	s2,a5,80002616 <usertrap+0xb6>
    yield();
    80002668:	851ff0ef          	jal	80001eb8 <yield>
    8000266c:	b76d                	j	80002616 <usertrap+0xb6>

000000008000266e <kerneltrap>:
{
    8000266e:	7179                	addi	sp,sp,-48
    80002670:	f406                	sd	ra,40(sp)
    80002672:	f022                	sd	s0,32(sp)
    80002674:	ec26                	sd	s1,24(sp)
    80002676:	e84a                	sd	s2,16(sp)
    80002678:	e44e                	sd	s3,8(sp)
    8000267a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000267c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002680:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002684:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002688:	1004f793          	andi	a5,s1,256
    8000268c:	c795                	beqz	a5,800026b8 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000268e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002692:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002694:	eb85                	bnez	a5,800026c4 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002696:	e57ff0ef          	jal	800024ec <devintr>
    8000269a:	c91d                	beqz	a0,800026d0 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000269c:	4789                	li	a5,2
    8000269e:	04f50a63          	beq	a0,a5,800026f2 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026a2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026a6:	10049073          	csrw	sstatus,s1
}
    800026aa:	70a2                	ld	ra,40(sp)
    800026ac:	7402                	ld	s0,32(sp)
    800026ae:	64e2                	ld	s1,24(sp)
    800026b0:	6942                	ld	s2,16(sp)
    800026b2:	69a2                	ld	s3,8(sp)
    800026b4:	6145                	addi	sp,sp,48
    800026b6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026b8:	00005517          	auipc	a0,0x5
    800026bc:	c3050513          	addi	a0,a0,-976 # 800072e8 <etext+0x2e8>
    800026c0:	920fe0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    800026c4:	00005517          	auipc	a0,0x5
    800026c8:	c4c50513          	addi	a0,a0,-948 # 80007310 <etext+0x310>
    800026cc:	914fe0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026d0:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026d4:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026d8:	85ce                	mv	a1,s3
    800026da:	00005517          	auipc	a0,0x5
    800026de:	c5650513          	addi	a0,a0,-938 # 80007330 <etext+0x330>
    800026e2:	e19fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800026e6:	00005517          	auipc	a0,0x5
    800026ea:	c7250513          	addi	a0,a0,-910 # 80007358 <etext+0x358>
    800026ee:	8f2fe0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    800026f2:	9dcff0ef          	jal	800018ce <myproc>
    800026f6:	d555                	beqz	a0,800026a2 <kerneltrap+0x34>
    yield();
    800026f8:	fc0ff0ef          	jal	80001eb8 <yield>
    800026fc:	b75d                	j	800026a2 <kerneltrap+0x34>

00000000800026fe <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026fe:	1101                	addi	sp,sp,-32
    80002700:	ec06                	sd	ra,24(sp)
    80002702:	e822                	sd	s0,16(sp)
    80002704:	e426                	sd	s1,8(sp)
    80002706:	1000                	addi	s0,sp,32
    80002708:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000270a:	9c4ff0ef          	jal	800018ce <myproc>
  switch (n) {
    8000270e:	4795                	li	a5,5
    80002710:	0497e163          	bltu	a5,s1,80002752 <argraw+0x54>
    80002714:	048a                	slli	s1,s1,0x2
    80002716:	00005717          	auipc	a4,0x5
    8000271a:	06a70713          	addi	a4,a4,106 # 80007780 <states.0+0x30>
    8000271e:	94ba                	add	s1,s1,a4
    80002720:	409c                	lw	a5,0(s1)
    80002722:	97ba                	add	a5,a5,a4
    80002724:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002726:	6d3c                	ld	a5,88(a0)
    80002728:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000272a:	60e2                	ld	ra,24(sp)
    8000272c:	6442                	ld	s0,16(sp)
    8000272e:	64a2                	ld	s1,8(sp)
    80002730:	6105                	addi	sp,sp,32
    80002732:	8082                	ret
    return p->trapframe->a1;
    80002734:	6d3c                	ld	a5,88(a0)
    80002736:	7fa8                	ld	a0,120(a5)
    80002738:	bfcd                	j	8000272a <argraw+0x2c>
    return p->trapframe->a2;
    8000273a:	6d3c                	ld	a5,88(a0)
    8000273c:	63c8                	ld	a0,128(a5)
    8000273e:	b7f5                	j	8000272a <argraw+0x2c>
    return p->trapframe->a3;
    80002740:	6d3c                	ld	a5,88(a0)
    80002742:	67c8                	ld	a0,136(a5)
    80002744:	b7dd                	j	8000272a <argraw+0x2c>
    return p->trapframe->a4;
    80002746:	6d3c                	ld	a5,88(a0)
    80002748:	6bc8                	ld	a0,144(a5)
    8000274a:	b7c5                	j	8000272a <argraw+0x2c>
    return p->trapframe->a5;
    8000274c:	6d3c                	ld	a5,88(a0)
    8000274e:	6fc8                	ld	a0,152(a5)
    80002750:	bfe9                	j	8000272a <argraw+0x2c>
  panic("argraw");
    80002752:	00005517          	auipc	a0,0x5
    80002756:	c1650513          	addi	a0,a0,-1002 # 80007368 <etext+0x368>
    8000275a:	886fe0ef          	jal	800007e0 <panic>

000000008000275e <fetchaddr>:
{
    8000275e:	1101                	addi	sp,sp,-32
    80002760:	ec06                	sd	ra,24(sp)
    80002762:	e822                	sd	s0,16(sp)
    80002764:	e426                	sd	s1,8(sp)
    80002766:	e04a                	sd	s2,0(sp)
    80002768:	1000                	addi	s0,sp,32
    8000276a:	84aa                	mv	s1,a0
    8000276c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000276e:	960ff0ef          	jal	800018ce <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002772:	653c                	ld	a5,72(a0)
    80002774:	02f4f663          	bgeu	s1,a5,800027a0 <fetchaddr+0x42>
    80002778:	00848713          	addi	a4,s1,8
    8000277c:	02e7e463          	bltu	a5,a4,800027a4 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002780:	46a1                	li	a3,8
    80002782:	8626                	mv	a2,s1
    80002784:	85ca                	mv	a1,s2
    80002786:	6928                	ld	a0,80(a0)
    80002788:	f3ffe0ef          	jal	800016c6 <copyin>
    8000278c:	00a03533          	snez	a0,a0
    80002790:	40a00533          	neg	a0,a0
}
    80002794:	60e2                	ld	ra,24(sp)
    80002796:	6442                	ld	s0,16(sp)
    80002798:	64a2                	ld	s1,8(sp)
    8000279a:	6902                	ld	s2,0(sp)
    8000279c:	6105                	addi	sp,sp,32
    8000279e:	8082                	ret
    return -1;
    800027a0:	557d                	li	a0,-1
    800027a2:	bfcd                	j	80002794 <fetchaddr+0x36>
    800027a4:	557d                	li	a0,-1
    800027a6:	b7fd                	j	80002794 <fetchaddr+0x36>

00000000800027a8 <fetchstr>:
{
    800027a8:	7179                	addi	sp,sp,-48
    800027aa:	f406                	sd	ra,40(sp)
    800027ac:	f022                	sd	s0,32(sp)
    800027ae:	ec26                	sd	s1,24(sp)
    800027b0:	e84a                	sd	s2,16(sp)
    800027b2:	e44e                	sd	s3,8(sp)
    800027b4:	1800                	addi	s0,sp,48
    800027b6:	892a                	mv	s2,a0
    800027b8:	84ae                	mv	s1,a1
    800027ba:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027bc:	912ff0ef          	jal	800018ce <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027c0:	86ce                	mv	a3,s3
    800027c2:	864a                	mv	a2,s2
    800027c4:	85a6                	mv	a1,s1
    800027c6:	6928                	ld	a0,80(a0)
    800027c8:	cc1fe0ef          	jal	80001488 <copyinstr>
    800027cc:	00054c63          	bltz	a0,800027e4 <fetchstr+0x3c>
  return strlen(buf);
    800027d0:	8526                	mv	a0,s1
    800027d2:	e40fe0ef          	jal	80000e12 <strlen>
}
    800027d6:	70a2                	ld	ra,40(sp)
    800027d8:	7402                	ld	s0,32(sp)
    800027da:	64e2                	ld	s1,24(sp)
    800027dc:	6942                	ld	s2,16(sp)
    800027de:	69a2                	ld	s3,8(sp)
    800027e0:	6145                	addi	sp,sp,48
    800027e2:	8082                	ret
    return -1;
    800027e4:	557d                	li	a0,-1
    800027e6:	bfc5                	j	800027d6 <fetchstr+0x2e>

00000000800027e8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027e8:	1101                	addi	sp,sp,-32
    800027ea:	ec06                	sd	ra,24(sp)
    800027ec:	e822                	sd	s0,16(sp)
    800027ee:	e426                	sd	s1,8(sp)
    800027f0:	1000                	addi	s0,sp,32
    800027f2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027f4:	f0bff0ef          	jal	800026fe <argraw>
    800027f8:	c088                	sw	a0,0(s1)
}
    800027fa:	60e2                	ld	ra,24(sp)
    800027fc:	6442                	ld	s0,16(sp)
    800027fe:	64a2                	ld	s1,8(sp)
    80002800:	6105                	addi	sp,sp,32
    80002802:	8082                	ret

0000000080002804 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002804:	1101                	addi	sp,sp,-32
    80002806:	ec06                	sd	ra,24(sp)
    80002808:	e822                	sd	s0,16(sp)
    8000280a:	e426                	sd	s1,8(sp)
    8000280c:	1000                	addi	s0,sp,32
    8000280e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002810:	eefff0ef          	jal	800026fe <argraw>
    80002814:	e088                	sd	a0,0(s1)
  return 0;
}
    80002816:	4501                	li	a0,0
    80002818:	60e2                	ld	ra,24(sp)
    8000281a:	6442                	ld	s0,16(sp)
    8000281c:	64a2                	ld	s1,8(sp)
    8000281e:	6105                	addi	sp,sp,32
    80002820:	8082                	ret

0000000080002822 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002822:	7179                	addi	sp,sp,-48
    80002824:	f406                	sd	ra,40(sp)
    80002826:	f022                	sd	s0,32(sp)
    80002828:	ec26                	sd	s1,24(sp)
    8000282a:	e84a                	sd	s2,16(sp)
    8000282c:	1800                	addi	s0,sp,48
    8000282e:	84ae                	mv	s1,a1
    80002830:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002832:	fd840593          	addi	a1,s0,-40
    80002836:	fcfff0ef          	jal	80002804 <argaddr>
  return fetchstr(addr, buf, max);
    8000283a:	864a                	mv	a2,s2
    8000283c:	85a6                	mv	a1,s1
    8000283e:	fd843503          	ld	a0,-40(s0)
    80002842:	f67ff0ef          	jal	800027a8 <fetchstr>
}
    80002846:	70a2                	ld	ra,40(sp)
    80002848:	7402                	ld	s0,32(sp)
    8000284a:	64e2                	ld	s1,24(sp)
    8000284c:	6942                	ld	s2,16(sp)
    8000284e:	6145                	addi	sp,sp,48
    80002850:	8082                	ret

0000000080002852 <syscall>:
};

// Trong kernel/syscall.c
void
syscall(void)
{
    80002852:	1101                	addi	sp,sp,-32
    80002854:	ec06                	sd	ra,24(sp)
    80002856:	e822                	sd	s0,16(sp)
    80002858:	e426                	sd	s1,8(sp)
    8000285a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000285c:	872ff0ef          	jal	800018ce <myproc>

  num = p->trapframe->a7;
    80002860:	6d24                	ld	s1,88(a0)
    80002862:	74dc                	ld	a5,168(s1)
  //printf("DEBUG: Syscall dang duoc goi co so hieu la: %d\n", num);
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002864:	fff7869b          	addiw	a3,a5,-1
    80002868:	475d                	li	a4,23
    8000286a:	02d76463          	bltu	a4,a3,80002892 <syscall+0x40>
  num = p->trapframe->a7;
    8000286e:	2781                	sext.w	a5,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002870:	00379693          	slli	a3,a5,0x3
    80002874:	00005717          	auipc	a4,0x5
    80002878:	f2470713          	addi	a4,a4,-220 # 80007798 <syscalls>
    8000287c:	9736                	add	a4,a4,a3
    8000287e:	6314                	ld	a3,0(a4)
    80002880:	ca89                	beqz	a3,80002892 <syscall+0x40>
    
    // Kiểm tra xem bit thứ num có được bật trong syscall_mask không
    if((p->syscall_mask >> num) & 1) {
    80002882:	15853703          	ld	a4,344(a0)
    80002886:	00f757b3          	srl	a5,a4,a5
    8000288a:	8b85                	andi	a5,a5,1
    8000288c:	eb81                	bnez	a5,8000289c <syscall+0x4a>
      p->trapframe->a0 = -1; // Trả về lỗi nếu bị chặn
      return;
    }

    p->trapframe->a0 = syscalls[num]();
    8000288e:	9682                	jalr	a3
    80002890:	f8a8                	sd	a0,112(s1)
  } else {
    // ...
  }
    80002892:	60e2                	ld	ra,24(sp)
    80002894:	6442                	ld	s0,16(sp)
    80002896:	64a2                	ld	s1,8(sp)
    80002898:	6105                	addi	sp,sp,32
    8000289a:	8082                	ret
      p->trapframe->a0 = -1; // Trả về lỗi nếu bị chặn
    8000289c:	57fd                	li	a5,-1
    8000289e:	f8bc                	sd	a5,112(s1)
      return;
    800028a0:	bfcd                	j	80002892 <syscall+0x40>

00000000800028a2 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800028a2:	1101                	addi	sp,sp,-32
    800028a4:	ec06                	sd	ra,24(sp)
    800028a6:	e822                	sd	s0,16(sp)
    800028a8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028aa:	fec40593          	addi	a1,s0,-20
    800028ae:	4501                	li	a0,0
    800028b0:	f39ff0ef          	jal	800027e8 <argint>
  kexit(n);
    800028b4:	fec42503          	lw	a0,-20(s0)
    800028b8:	f38ff0ef          	jal	80001ff0 <kexit>
  return 0;  // not reached
}
    800028bc:	4501                	li	a0,0
    800028be:	60e2                	ld	ra,24(sp)
    800028c0:	6442                	ld	s0,16(sp)
    800028c2:	6105                	addi	sp,sp,32
    800028c4:	8082                	ret

00000000800028c6 <sys_getpid>:

uint64
sys_getpid(void)
{
    800028c6:	1141                	addi	sp,sp,-16
    800028c8:	e406                	sd	ra,8(sp)
    800028ca:	e022                	sd	s0,0(sp)
    800028cc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028ce:	800ff0ef          	jal	800018ce <myproc>
}
    800028d2:	5908                	lw	a0,48(a0)
    800028d4:	60a2                	ld	ra,8(sp)
    800028d6:	6402                	ld	s0,0(sp)
    800028d8:	0141                	addi	sp,sp,16
    800028da:	8082                	ret

00000000800028dc <sys_fork>:

uint64
sys_fork(void)
{
    800028dc:	1141                	addi	sp,sp,-16
    800028de:	e406                	sd	ra,8(sp)
    800028e0:	e022                	sd	s0,0(sp)
    800028e2:	0800                	addi	s0,sp,16
  return kfork();
    800028e4:	b5aff0ef          	jal	80001c3e <kfork>
}
    800028e8:	60a2                	ld	ra,8(sp)
    800028ea:	6402                	ld	s0,0(sp)
    800028ec:	0141                	addi	sp,sp,16
    800028ee:	8082                	ret

00000000800028f0 <sys_wait>:

uint64
sys_wait(void)
{
    800028f0:	1101                	addi	sp,sp,-32
    800028f2:	ec06                	sd	ra,24(sp)
    800028f4:	e822                	sd	s0,16(sp)
    800028f6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028f8:	fe840593          	addi	a1,s0,-24
    800028fc:	4501                	li	a0,0
    800028fe:	f07ff0ef          	jal	80002804 <argaddr>
  return kwait(p);
    80002902:	fe843503          	ld	a0,-24(s0)
    80002906:	841ff0ef          	jal	80002146 <kwait>
}
    8000290a:	60e2                	ld	ra,24(sp)
    8000290c:	6442                	ld	s0,16(sp)
    8000290e:	6105                	addi	sp,sp,32
    80002910:	8082                	ret

0000000080002912 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002912:	7179                	addi	sp,sp,-48
    80002914:	f406                	sd	ra,40(sp)
    80002916:	f022                	sd	s0,32(sp)
    80002918:	ec26                	sd	s1,24(sp)
    8000291a:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    8000291c:	fd840593          	addi	a1,s0,-40
    80002920:	4501                	li	a0,0
    80002922:	ec7ff0ef          	jal	800027e8 <argint>
  argint(1, &t);
    80002926:	fdc40593          	addi	a1,s0,-36
    8000292a:	4505                	li	a0,1
    8000292c:	ebdff0ef          	jal	800027e8 <argint>
  addr = myproc()->sz;
    80002930:	f9ffe0ef          	jal	800018ce <myproc>
    80002934:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002936:	fdc42703          	lw	a4,-36(s0)
    8000293a:	4785                	li	a5,1
    8000293c:	02f70763          	beq	a4,a5,8000296a <sys_sbrk+0x58>
    80002940:	fd842783          	lw	a5,-40(s0)
    80002944:	0207c363          	bltz	a5,8000296a <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002948:	97a6                	add	a5,a5,s1
    8000294a:	0297ee63          	bltu	a5,s1,80002986 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    8000294e:	02000737          	lui	a4,0x2000
    80002952:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002954:	0736                	slli	a4,a4,0xd
    80002956:	02f76a63          	bltu	a4,a5,8000298a <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    8000295a:	f75fe0ef          	jal	800018ce <myproc>
    8000295e:	fd842703          	lw	a4,-40(s0)
    80002962:	653c                	ld	a5,72(a0)
    80002964:	97ba                	add	a5,a5,a4
    80002966:	e53c                	sd	a5,72(a0)
    80002968:	a039                	j	80002976 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    8000296a:	fd842503          	lw	a0,-40(s0)
    8000296e:	a6eff0ef          	jal	80001bdc <growproc>
    80002972:	00054863          	bltz	a0,80002982 <sys_sbrk+0x70>
  }
  return addr;
}
    80002976:	8526                	mv	a0,s1
    80002978:	70a2                	ld	ra,40(sp)
    8000297a:	7402                	ld	s0,32(sp)
    8000297c:	64e2                	ld	s1,24(sp)
    8000297e:	6145                	addi	sp,sp,48
    80002980:	8082                	ret
      return -1;
    80002982:	54fd                	li	s1,-1
    80002984:	bfcd                	j	80002976 <sys_sbrk+0x64>
      return -1;
    80002986:	54fd                	li	s1,-1
    80002988:	b7fd                	j	80002976 <sys_sbrk+0x64>
      return -1;
    8000298a:	54fd                	li	s1,-1
    8000298c:	b7ed                	j	80002976 <sys_sbrk+0x64>

000000008000298e <sys_pause>:

uint64
sys_pause(void)
{
    8000298e:	7139                	addi	sp,sp,-64
    80002990:	fc06                	sd	ra,56(sp)
    80002992:	f822                	sd	s0,48(sp)
    80002994:	f04a                	sd	s2,32(sp)
    80002996:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002998:	fcc40593          	addi	a1,s0,-52
    8000299c:	4501                	li	a0,0
    8000299e:	e4bff0ef          	jal	800027e8 <argint>
  if(n < 0)
    800029a2:	fcc42783          	lw	a5,-52(s0)
    800029a6:	0607c763          	bltz	a5,80002a14 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029aa:	00013517          	auipc	a0,0x13
    800029ae:	01e50513          	addi	a0,a0,30 # 800159c8 <tickslock>
    800029b2:	a1cfe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    800029b6:	00005917          	auipc	s2,0x5
    800029ba:	ee292903          	lw	s2,-286(s2) # 80007898 <ticks>
  while(ticks - ticks0 < n){
    800029be:	fcc42783          	lw	a5,-52(s0)
    800029c2:	cf8d                	beqz	a5,800029fc <sys_pause+0x6e>
    800029c4:	f426                	sd	s1,40(sp)
    800029c6:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029c8:	00013997          	auipc	s3,0x13
    800029cc:	00098993          	mv	s3,s3
    800029d0:	00005497          	auipc	s1,0x5
    800029d4:	ec848493          	addi	s1,s1,-312 # 80007898 <ticks>
    if(killed(myproc())){
    800029d8:	ef7fe0ef          	jal	800018ce <myproc>
    800029dc:	f40ff0ef          	jal	8000211c <killed>
    800029e0:	ed0d                	bnez	a0,80002a1a <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800029e2:	85ce                	mv	a1,s3
    800029e4:	8526                	mv	a0,s1
    800029e6:	cfeff0ef          	jal	80001ee4 <sleep>
  while(ticks - ticks0 < n){
    800029ea:	409c                	lw	a5,0(s1)
    800029ec:	412787bb          	subw	a5,a5,s2
    800029f0:	fcc42703          	lw	a4,-52(s0)
    800029f4:	fee7e2e3          	bltu	a5,a4,800029d8 <sys_pause+0x4a>
    800029f8:	74a2                	ld	s1,40(sp)
    800029fa:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800029fc:	00013517          	auipc	a0,0x13
    80002a00:	fcc50513          	addi	a0,a0,-52 # 800159c8 <tickslock>
    80002a04:	a62fe0ef          	jal	80000c66 <release>
  return 0;
    80002a08:	4501                	li	a0,0
}
    80002a0a:	70e2                	ld	ra,56(sp)
    80002a0c:	7442                	ld	s0,48(sp)
    80002a0e:	7902                	ld	s2,32(sp)
    80002a10:	6121                	addi	sp,sp,64
    80002a12:	8082                	ret
    n = 0;
    80002a14:	fc042623          	sw	zero,-52(s0)
    80002a18:	bf49                	j	800029aa <sys_pause+0x1c>
      release(&tickslock);
    80002a1a:	00013517          	auipc	a0,0x13
    80002a1e:	fae50513          	addi	a0,a0,-82 # 800159c8 <tickslock>
    80002a22:	a44fe0ef          	jal	80000c66 <release>
      return -1;
    80002a26:	557d                	li	a0,-1
    80002a28:	74a2                	ld	s1,40(sp)
    80002a2a:	69e2                	ld	s3,24(sp)
    80002a2c:	bff9                	j	80002a0a <sys_pause+0x7c>

0000000080002a2e <sys_kill>:

uint64
sys_kill(void)
{
    80002a2e:	1101                	addi	sp,sp,-32
    80002a30:	ec06                	sd	ra,24(sp)
    80002a32:	e822                	sd	s0,16(sp)
    80002a34:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a36:	fec40593          	addi	a1,s0,-20
    80002a3a:	4501                	li	a0,0
    80002a3c:	dadff0ef          	jal	800027e8 <argint>
  return kkill(pid);
    80002a40:	fec42503          	lw	a0,-20(s0)
    80002a44:	e4eff0ef          	jal	80002092 <kkill>
}
    80002a48:	60e2                	ld	ra,24(sp)
    80002a4a:	6442                	ld	s0,16(sp)
    80002a4c:	6105                	addi	sp,sp,32
    80002a4e:	8082                	ret

0000000080002a50 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a50:	1101                	addi	sp,sp,-32
    80002a52:	ec06                	sd	ra,24(sp)
    80002a54:	e822                	sd	s0,16(sp)
    80002a56:	e426                	sd	s1,8(sp)
    80002a58:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a5a:	00013517          	auipc	a0,0x13
    80002a5e:	f6e50513          	addi	a0,a0,-146 # 800159c8 <tickslock>
    80002a62:	96cfe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002a66:	00005497          	auipc	s1,0x5
    80002a6a:	e324a483          	lw	s1,-462(s1) # 80007898 <ticks>
  release(&tickslock);
    80002a6e:	00013517          	auipc	a0,0x13
    80002a72:	f5a50513          	addi	a0,a0,-166 # 800159c8 <tickslock>
    80002a76:	9f0fe0ef          	jal	80000c66 <release>
  return xticks;
}
    80002a7a:	02049513          	slli	a0,s1,0x20
    80002a7e:	9101                	srli	a0,a0,0x20
    80002a80:	60e2                	ld	ra,24(sp)
    80002a82:	6442                	ld	s0,16(sp)
    80002a84:	64a2                	ld	s1,8(sp)
    80002a86:	6105                	addi	sp,sp,32
    80002a88:	8082                	ret

0000000080002a8a <sys_hello>:
uint64
sys_hello(void)
{
    80002a8a:	1141                	addi	sp,sp,-16
    80002a8c:	e406                	sd	ra,8(sp)
    80002a8e:	e022                	sd	s0,0(sp)
    80002a90:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a92:	e3dfe0ef          	jal	800018ce <myproc>
  printf("kernel: hello() called by pid %d\n", p->pid);
    80002a96:	590c                	lw	a1,48(a0)
    80002a98:	00005517          	auipc	a0,0x5
    80002a9c:	8d850513          	addi	a0,a0,-1832 # 80007370 <etext+0x370>
    80002aa0:	a5bfd0ef          	jal	800004fa <printf>
  return 0;
}
    80002aa4:	4501                	li	a0,0
    80002aa6:	60a2                	ld	ra,8(sp)
    80002aa8:	6402                	ld	s0,0(sp)
    80002aaa:	0141                	addi	sp,sp,16
    80002aac:	8082                	ret

0000000080002aae <sys_getfilter>:
// [DEV 3 TỰ THÊM ĐỂ TEST - SẼ XÓA KHI DUY PUSH CODE THẬT]
uint64
sys_getfilter(void)
{
    80002aae:	1101                	addi	sp,sp,-32
    80002ab0:	ec06                	sd	ra,24(sp)
    80002ab2:	e822                	sd	s0,16(sp)
    80002ab4:	e426                	sd	s1,8(sp)
    80002ab6:	1000                	addi	s0,sp,32
  uint64 mask = myproc()->syscall_mask;
    80002ab8:	e17fe0ef          	jal	800018ce <myproc>
    80002abc:	15853483          	ld	s1,344(a0)
  printf("DEBUG: Kernel tra ve mask = %d\n", (int)mask);
    80002ac0:	0004859b          	sext.w	a1,s1
    80002ac4:	00005517          	auipc	a0,0x5
    80002ac8:	8d450513          	addi	a0,a0,-1836 # 80007398 <etext+0x398>
    80002acc:	a2ffd0ef          	jal	800004fa <printf>
  return mask;
}
    80002ad0:	8526                	mv	a0,s1
    80002ad2:	60e2                	ld	ra,24(sp)
    80002ad4:	6442                	ld	s0,16(sp)
    80002ad6:	64a2                	ld	s1,8(sp)
    80002ad8:	6105                	addi	sp,sp,32
    80002ada:	8082                	ret

0000000080002adc <sys_setfilter>:

uint64
sys_setfilter(void)
{
    80002adc:	1101                	addi	sp,sp,-32
    80002ade:	ec06                	sd	ra,24(sp)
    80002ae0:	e822                	sd	s0,16(sp)
    80002ae2:	1000                	addi	s0,sp,32
  uint64 mask;
  // Lấy tham số mask từ user space
  if(argaddr(0, &mask) < 0)
    80002ae4:	fe840593          	addi	a1,s0,-24
    80002ae8:	4501                	li	a0,0
    80002aea:	d1bff0ef          	jal	80002804 <argaddr>
    return -1;
    80002aee:	57fd                	li	a5,-1
  if(argaddr(0, &mask) < 0)
    80002af0:	00054963          	bltz	a0,80002b02 <sys_setfilter+0x26>
  
  // Gán mask vào struct proc
  myproc()->syscall_mask = mask;
    80002af4:	ddbfe0ef          	jal	800018ce <myproc>
    80002af8:	fe843783          	ld	a5,-24(s0)
    80002afc:	14f53c23          	sd	a5,344(a0)
  
  return 0;
    80002b00:	4781                	li	a5,0
    80002b02:	853e                	mv	a0,a5
    80002b04:	60e2                	ld	ra,24(sp)
    80002b06:	6442                	ld	s0,16(sp)
    80002b08:	6105                	addi	sp,sp,32
    80002b0a:	8082                	ret

0000000080002b0c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b0c:	7179                	addi	sp,sp,-48
    80002b0e:	f406                	sd	ra,40(sp)
    80002b10:	f022                	sd	s0,32(sp)
    80002b12:	ec26                	sd	s1,24(sp)
    80002b14:	e84a                	sd	s2,16(sp)
    80002b16:	e44e                	sd	s3,8(sp)
    80002b18:	e052                	sd	s4,0(sp)
    80002b1a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b1c:	00005597          	auipc	a1,0x5
    80002b20:	89c58593          	addi	a1,a1,-1892 # 800073b8 <etext+0x3b8>
    80002b24:	00013517          	auipc	a0,0x13
    80002b28:	ebc50513          	addi	a0,a0,-324 # 800159e0 <bcache>
    80002b2c:	822fe0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b30:	0001b797          	auipc	a5,0x1b
    80002b34:	eb078793          	addi	a5,a5,-336 # 8001d9e0 <bcache+0x8000>
    80002b38:	0001b717          	auipc	a4,0x1b
    80002b3c:	11070713          	addi	a4,a4,272 # 8001dc48 <bcache+0x8268>
    80002b40:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b44:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b48:	00013497          	auipc	s1,0x13
    80002b4c:	eb048493          	addi	s1,s1,-336 # 800159f8 <bcache+0x18>
    b->next = bcache.head.next;
    80002b50:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b52:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b54:	00005a17          	auipc	s4,0x5
    80002b58:	86ca0a13          	addi	s4,s4,-1940 # 800073c0 <etext+0x3c0>
    b->next = bcache.head.next;
    80002b5c:	2b893783          	ld	a5,696(s2)
    80002b60:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b62:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b66:	85d2                	mv	a1,s4
    80002b68:	01048513          	addi	a0,s1,16
    80002b6c:	322010ef          	jal	80003e8e <initsleeplock>
    bcache.head.next->prev = b;
    80002b70:	2b893783          	ld	a5,696(s2)
    80002b74:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b76:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b7a:	45848493          	addi	s1,s1,1112
    80002b7e:	fd349fe3          	bne	s1,s3,80002b5c <binit+0x50>
  }
}
    80002b82:	70a2                	ld	ra,40(sp)
    80002b84:	7402                	ld	s0,32(sp)
    80002b86:	64e2                	ld	s1,24(sp)
    80002b88:	6942                	ld	s2,16(sp)
    80002b8a:	69a2                	ld	s3,8(sp)
    80002b8c:	6a02                	ld	s4,0(sp)
    80002b8e:	6145                	addi	sp,sp,48
    80002b90:	8082                	ret

0000000080002b92 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b92:	7179                	addi	sp,sp,-48
    80002b94:	f406                	sd	ra,40(sp)
    80002b96:	f022                	sd	s0,32(sp)
    80002b98:	ec26                	sd	s1,24(sp)
    80002b9a:	e84a                	sd	s2,16(sp)
    80002b9c:	e44e                	sd	s3,8(sp)
    80002b9e:	1800                	addi	s0,sp,48
    80002ba0:	892a                	mv	s2,a0
    80002ba2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ba4:	00013517          	auipc	a0,0x13
    80002ba8:	e3c50513          	addi	a0,a0,-452 # 800159e0 <bcache>
    80002bac:	822fe0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002bb0:	0001b497          	auipc	s1,0x1b
    80002bb4:	0e84b483          	ld	s1,232(s1) # 8001dc98 <bcache+0x82b8>
    80002bb8:	0001b797          	auipc	a5,0x1b
    80002bbc:	09078793          	addi	a5,a5,144 # 8001dc48 <bcache+0x8268>
    80002bc0:	02f48b63          	beq	s1,a5,80002bf6 <bread+0x64>
    80002bc4:	873e                	mv	a4,a5
    80002bc6:	a021                	j	80002bce <bread+0x3c>
    80002bc8:	68a4                	ld	s1,80(s1)
    80002bca:	02e48663          	beq	s1,a4,80002bf6 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002bce:	449c                	lw	a5,8(s1)
    80002bd0:	ff279ce3          	bne	a5,s2,80002bc8 <bread+0x36>
    80002bd4:	44dc                	lw	a5,12(s1)
    80002bd6:	ff3799e3          	bne	a5,s3,80002bc8 <bread+0x36>
      b->refcnt++;
    80002bda:	40bc                	lw	a5,64(s1)
    80002bdc:	2785                	addiw	a5,a5,1
    80002bde:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002be0:	00013517          	auipc	a0,0x13
    80002be4:	e0050513          	addi	a0,a0,-512 # 800159e0 <bcache>
    80002be8:	87efe0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002bec:	01048513          	addi	a0,s1,16
    80002bf0:	2d4010ef          	jal	80003ec4 <acquiresleep>
      return b;
    80002bf4:	a889                	j	80002c46 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bf6:	0001b497          	auipc	s1,0x1b
    80002bfa:	09a4b483          	ld	s1,154(s1) # 8001dc90 <bcache+0x82b0>
    80002bfe:	0001b797          	auipc	a5,0x1b
    80002c02:	04a78793          	addi	a5,a5,74 # 8001dc48 <bcache+0x8268>
    80002c06:	00f48863          	beq	s1,a5,80002c16 <bread+0x84>
    80002c0a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c0c:	40bc                	lw	a5,64(s1)
    80002c0e:	cb91                	beqz	a5,80002c22 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c10:	64a4                	ld	s1,72(s1)
    80002c12:	fee49de3          	bne	s1,a4,80002c0c <bread+0x7a>
  panic("bget: no buffers");
    80002c16:	00004517          	auipc	a0,0x4
    80002c1a:	7b250513          	addi	a0,a0,1970 # 800073c8 <etext+0x3c8>
    80002c1e:	bc3fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002c22:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c26:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c2a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c2e:	4785                	li	a5,1
    80002c30:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c32:	00013517          	auipc	a0,0x13
    80002c36:	dae50513          	addi	a0,a0,-594 # 800159e0 <bcache>
    80002c3a:	82cfe0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002c3e:	01048513          	addi	a0,s1,16
    80002c42:	282010ef          	jal	80003ec4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c46:	409c                	lw	a5,0(s1)
    80002c48:	cb89                	beqz	a5,80002c5a <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c4a:	8526                	mv	a0,s1
    80002c4c:	70a2                	ld	ra,40(sp)
    80002c4e:	7402                	ld	s0,32(sp)
    80002c50:	64e2                	ld	s1,24(sp)
    80002c52:	6942                	ld	s2,16(sp)
    80002c54:	69a2                	ld	s3,8(sp)
    80002c56:	6145                	addi	sp,sp,48
    80002c58:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c5a:	4581                	li	a1,0
    80002c5c:	8526                	mv	a0,s1
    80002c5e:	2d3020ef          	jal	80005730 <virtio_disk_rw>
    b->valid = 1;
    80002c62:	4785                	li	a5,1
    80002c64:	c09c                	sw	a5,0(s1)
  return b;
    80002c66:	b7d5                	j	80002c4a <bread+0xb8>

0000000080002c68 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c68:	1101                	addi	sp,sp,-32
    80002c6a:	ec06                	sd	ra,24(sp)
    80002c6c:	e822                	sd	s0,16(sp)
    80002c6e:	e426                	sd	s1,8(sp)
    80002c70:	1000                	addi	s0,sp,32
    80002c72:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c74:	0541                	addi	a0,a0,16
    80002c76:	2cc010ef          	jal	80003f42 <holdingsleep>
    80002c7a:	c911                	beqz	a0,80002c8e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c7c:	4585                	li	a1,1
    80002c7e:	8526                	mv	a0,s1
    80002c80:	2b1020ef          	jal	80005730 <virtio_disk_rw>
}
    80002c84:	60e2                	ld	ra,24(sp)
    80002c86:	6442                	ld	s0,16(sp)
    80002c88:	64a2                	ld	s1,8(sp)
    80002c8a:	6105                	addi	sp,sp,32
    80002c8c:	8082                	ret
    panic("bwrite");
    80002c8e:	00004517          	auipc	a0,0x4
    80002c92:	75250513          	addi	a0,a0,1874 # 800073e0 <etext+0x3e0>
    80002c96:	b4bfd0ef          	jal	800007e0 <panic>

0000000080002c9a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c9a:	1101                	addi	sp,sp,-32
    80002c9c:	ec06                	sd	ra,24(sp)
    80002c9e:	e822                	sd	s0,16(sp)
    80002ca0:	e426                	sd	s1,8(sp)
    80002ca2:	e04a                	sd	s2,0(sp)
    80002ca4:	1000                	addi	s0,sp,32
    80002ca6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ca8:	01050913          	addi	s2,a0,16
    80002cac:	854a                	mv	a0,s2
    80002cae:	294010ef          	jal	80003f42 <holdingsleep>
    80002cb2:	c135                	beqz	a0,80002d16 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002cb4:	854a                	mv	a0,s2
    80002cb6:	254010ef          	jal	80003f0a <releasesleep>

  acquire(&bcache.lock);
    80002cba:	00013517          	auipc	a0,0x13
    80002cbe:	d2650513          	addi	a0,a0,-730 # 800159e0 <bcache>
    80002cc2:	f0dfd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002cc6:	40bc                	lw	a5,64(s1)
    80002cc8:	37fd                	addiw	a5,a5,-1
    80002cca:	0007871b          	sext.w	a4,a5
    80002cce:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002cd0:	e71d                	bnez	a4,80002cfe <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002cd2:	68b8                	ld	a4,80(s1)
    80002cd4:	64bc                	ld	a5,72(s1)
    80002cd6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002cd8:	68b8                	ld	a4,80(s1)
    80002cda:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002cdc:	0001b797          	auipc	a5,0x1b
    80002ce0:	d0478793          	addi	a5,a5,-764 # 8001d9e0 <bcache+0x8000>
    80002ce4:	2b87b703          	ld	a4,696(a5)
    80002ce8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002cea:	0001b717          	auipc	a4,0x1b
    80002cee:	f5e70713          	addi	a4,a4,-162 # 8001dc48 <bcache+0x8268>
    80002cf2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002cf4:	2b87b703          	ld	a4,696(a5)
    80002cf8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002cfa:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002cfe:	00013517          	auipc	a0,0x13
    80002d02:	ce250513          	addi	a0,a0,-798 # 800159e0 <bcache>
    80002d06:	f61fd0ef          	jal	80000c66 <release>
}
    80002d0a:	60e2                	ld	ra,24(sp)
    80002d0c:	6442                	ld	s0,16(sp)
    80002d0e:	64a2                	ld	s1,8(sp)
    80002d10:	6902                	ld	s2,0(sp)
    80002d12:	6105                	addi	sp,sp,32
    80002d14:	8082                	ret
    panic("brelse");
    80002d16:	00004517          	auipc	a0,0x4
    80002d1a:	6d250513          	addi	a0,a0,1746 # 800073e8 <etext+0x3e8>
    80002d1e:	ac3fd0ef          	jal	800007e0 <panic>

0000000080002d22 <bpin>:

void
bpin(struct buf *b) {
    80002d22:	1101                	addi	sp,sp,-32
    80002d24:	ec06                	sd	ra,24(sp)
    80002d26:	e822                	sd	s0,16(sp)
    80002d28:	e426                	sd	s1,8(sp)
    80002d2a:	1000                	addi	s0,sp,32
    80002d2c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d2e:	00013517          	auipc	a0,0x13
    80002d32:	cb250513          	addi	a0,a0,-846 # 800159e0 <bcache>
    80002d36:	e99fd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002d3a:	40bc                	lw	a5,64(s1)
    80002d3c:	2785                	addiw	a5,a5,1
    80002d3e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d40:	00013517          	auipc	a0,0x13
    80002d44:	ca050513          	addi	a0,a0,-864 # 800159e0 <bcache>
    80002d48:	f1ffd0ef          	jal	80000c66 <release>
}
    80002d4c:	60e2                	ld	ra,24(sp)
    80002d4e:	6442                	ld	s0,16(sp)
    80002d50:	64a2                	ld	s1,8(sp)
    80002d52:	6105                	addi	sp,sp,32
    80002d54:	8082                	ret

0000000080002d56 <bunpin>:

void
bunpin(struct buf *b) {
    80002d56:	1101                	addi	sp,sp,-32
    80002d58:	ec06                	sd	ra,24(sp)
    80002d5a:	e822                	sd	s0,16(sp)
    80002d5c:	e426                	sd	s1,8(sp)
    80002d5e:	1000                	addi	s0,sp,32
    80002d60:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d62:	00013517          	auipc	a0,0x13
    80002d66:	c7e50513          	addi	a0,a0,-898 # 800159e0 <bcache>
    80002d6a:	e65fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002d6e:	40bc                	lw	a5,64(s1)
    80002d70:	37fd                	addiw	a5,a5,-1
    80002d72:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d74:	00013517          	auipc	a0,0x13
    80002d78:	c6c50513          	addi	a0,a0,-916 # 800159e0 <bcache>
    80002d7c:	eebfd0ef          	jal	80000c66 <release>
}
    80002d80:	60e2                	ld	ra,24(sp)
    80002d82:	6442                	ld	s0,16(sp)
    80002d84:	64a2                	ld	s1,8(sp)
    80002d86:	6105                	addi	sp,sp,32
    80002d88:	8082                	ret

0000000080002d8a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d8a:	1101                	addi	sp,sp,-32
    80002d8c:	ec06                	sd	ra,24(sp)
    80002d8e:	e822                	sd	s0,16(sp)
    80002d90:	e426                	sd	s1,8(sp)
    80002d92:	e04a                	sd	s2,0(sp)
    80002d94:	1000                	addi	s0,sp,32
    80002d96:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d98:	00d5d59b          	srliw	a1,a1,0xd
    80002d9c:	0001b797          	auipc	a5,0x1b
    80002da0:	3207a783          	lw	a5,800(a5) # 8001e0bc <sb+0x1c>
    80002da4:	9dbd                	addw	a1,a1,a5
    80002da6:	dedff0ef          	jal	80002b92 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002daa:	0074f713          	andi	a4,s1,7
    80002dae:	4785                	li	a5,1
    80002db0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002db4:	14ce                	slli	s1,s1,0x33
    80002db6:	90d9                	srli	s1,s1,0x36
    80002db8:	00950733          	add	a4,a0,s1
    80002dbc:	05874703          	lbu	a4,88(a4)
    80002dc0:	00e7f6b3          	and	a3,a5,a4
    80002dc4:	c29d                	beqz	a3,80002dea <bfree+0x60>
    80002dc6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002dc8:	94aa                	add	s1,s1,a0
    80002dca:	fff7c793          	not	a5,a5
    80002dce:	8f7d                	and	a4,a4,a5
    80002dd0:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002dd4:	7f9000ef          	jal	80003dcc <log_write>
  brelse(bp);
    80002dd8:	854a                	mv	a0,s2
    80002dda:	ec1ff0ef          	jal	80002c9a <brelse>
}
    80002dde:	60e2                	ld	ra,24(sp)
    80002de0:	6442                	ld	s0,16(sp)
    80002de2:	64a2                	ld	s1,8(sp)
    80002de4:	6902                	ld	s2,0(sp)
    80002de6:	6105                	addi	sp,sp,32
    80002de8:	8082                	ret
    panic("freeing free block");
    80002dea:	00004517          	auipc	a0,0x4
    80002dee:	60650513          	addi	a0,a0,1542 # 800073f0 <etext+0x3f0>
    80002df2:	9effd0ef          	jal	800007e0 <panic>

0000000080002df6 <balloc>:
{
    80002df6:	711d                	addi	sp,sp,-96
    80002df8:	ec86                	sd	ra,88(sp)
    80002dfa:	e8a2                	sd	s0,80(sp)
    80002dfc:	e4a6                	sd	s1,72(sp)
    80002dfe:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002e00:	0001b797          	auipc	a5,0x1b
    80002e04:	2a47a783          	lw	a5,676(a5) # 8001e0a4 <sb+0x4>
    80002e08:	0e078f63          	beqz	a5,80002f06 <balloc+0x110>
    80002e0c:	e0ca                	sd	s2,64(sp)
    80002e0e:	fc4e                	sd	s3,56(sp)
    80002e10:	f852                	sd	s4,48(sp)
    80002e12:	f456                	sd	s5,40(sp)
    80002e14:	f05a                	sd	s6,32(sp)
    80002e16:	ec5e                	sd	s7,24(sp)
    80002e18:	e862                	sd	s8,16(sp)
    80002e1a:	e466                	sd	s9,8(sp)
    80002e1c:	8baa                	mv	s7,a0
    80002e1e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e20:	0001bb17          	auipc	s6,0x1b
    80002e24:	280b0b13          	addi	s6,s6,640 # 8001e0a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e28:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002e2a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e2c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e2e:	6c89                	lui	s9,0x2
    80002e30:	a0b5                	j	80002e9c <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e32:	97ca                	add	a5,a5,s2
    80002e34:	8e55                	or	a2,a2,a3
    80002e36:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e3a:	854a                	mv	a0,s2
    80002e3c:	791000ef          	jal	80003dcc <log_write>
        brelse(bp);
    80002e40:	854a                	mv	a0,s2
    80002e42:	e59ff0ef          	jal	80002c9a <brelse>
  bp = bread(dev, bno);
    80002e46:	85a6                	mv	a1,s1
    80002e48:	855e                	mv	a0,s7
    80002e4a:	d49ff0ef          	jal	80002b92 <bread>
    80002e4e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e50:	40000613          	li	a2,1024
    80002e54:	4581                	li	a1,0
    80002e56:	05850513          	addi	a0,a0,88
    80002e5a:	e49fd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80002e5e:	854a                	mv	a0,s2
    80002e60:	76d000ef          	jal	80003dcc <log_write>
  brelse(bp);
    80002e64:	854a                	mv	a0,s2
    80002e66:	e35ff0ef          	jal	80002c9a <brelse>
}
    80002e6a:	6906                	ld	s2,64(sp)
    80002e6c:	79e2                	ld	s3,56(sp)
    80002e6e:	7a42                	ld	s4,48(sp)
    80002e70:	7aa2                	ld	s5,40(sp)
    80002e72:	7b02                	ld	s6,32(sp)
    80002e74:	6be2                	ld	s7,24(sp)
    80002e76:	6c42                	ld	s8,16(sp)
    80002e78:	6ca2                	ld	s9,8(sp)
}
    80002e7a:	8526                	mv	a0,s1
    80002e7c:	60e6                	ld	ra,88(sp)
    80002e7e:	6446                	ld	s0,80(sp)
    80002e80:	64a6                	ld	s1,72(sp)
    80002e82:	6125                	addi	sp,sp,96
    80002e84:	8082                	ret
    brelse(bp);
    80002e86:	854a                	mv	a0,s2
    80002e88:	e13ff0ef          	jal	80002c9a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e8c:	015c87bb          	addw	a5,s9,s5
    80002e90:	00078a9b          	sext.w	s5,a5
    80002e94:	004b2703          	lw	a4,4(s6)
    80002e98:	04eaff63          	bgeu	s5,a4,80002ef6 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002e9c:	41fad79b          	sraiw	a5,s5,0x1f
    80002ea0:	0137d79b          	srliw	a5,a5,0x13
    80002ea4:	015787bb          	addw	a5,a5,s5
    80002ea8:	40d7d79b          	sraiw	a5,a5,0xd
    80002eac:	01cb2583          	lw	a1,28(s6)
    80002eb0:	9dbd                	addw	a1,a1,a5
    80002eb2:	855e                	mv	a0,s7
    80002eb4:	cdfff0ef          	jal	80002b92 <bread>
    80002eb8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002eba:	004b2503          	lw	a0,4(s6)
    80002ebe:	000a849b          	sext.w	s1,s5
    80002ec2:	8762                	mv	a4,s8
    80002ec4:	fca4f1e3          	bgeu	s1,a0,80002e86 <balloc+0x90>
      m = 1 << (bi % 8);
    80002ec8:	00777693          	andi	a3,a4,7
    80002ecc:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002ed0:	41f7579b          	sraiw	a5,a4,0x1f
    80002ed4:	01d7d79b          	srliw	a5,a5,0x1d
    80002ed8:	9fb9                	addw	a5,a5,a4
    80002eda:	4037d79b          	sraiw	a5,a5,0x3
    80002ede:	00f90633          	add	a2,s2,a5
    80002ee2:	05864603          	lbu	a2,88(a2)
    80002ee6:	00c6f5b3          	and	a1,a3,a2
    80002eea:	d5a1                	beqz	a1,80002e32 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002eec:	2705                	addiw	a4,a4,1
    80002eee:	2485                	addiw	s1,s1,1
    80002ef0:	fd471ae3          	bne	a4,s4,80002ec4 <balloc+0xce>
    80002ef4:	bf49                	j	80002e86 <balloc+0x90>
    80002ef6:	6906                	ld	s2,64(sp)
    80002ef8:	79e2                	ld	s3,56(sp)
    80002efa:	7a42                	ld	s4,48(sp)
    80002efc:	7aa2                	ld	s5,40(sp)
    80002efe:	7b02                	ld	s6,32(sp)
    80002f00:	6be2                	ld	s7,24(sp)
    80002f02:	6c42                	ld	s8,16(sp)
    80002f04:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002f06:	00004517          	auipc	a0,0x4
    80002f0a:	50250513          	addi	a0,a0,1282 # 80007408 <etext+0x408>
    80002f0e:	decfd0ef          	jal	800004fa <printf>
  return 0;
    80002f12:	4481                	li	s1,0
    80002f14:	b79d                	j	80002e7a <balloc+0x84>

0000000080002f16 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f16:	7179                	addi	sp,sp,-48
    80002f18:	f406                	sd	ra,40(sp)
    80002f1a:	f022                	sd	s0,32(sp)
    80002f1c:	ec26                	sd	s1,24(sp)
    80002f1e:	e84a                	sd	s2,16(sp)
    80002f20:	e44e                	sd	s3,8(sp)
    80002f22:	1800                	addi	s0,sp,48
    80002f24:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f26:	47ad                	li	a5,11
    80002f28:	02b7e663          	bltu	a5,a1,80002f54 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002f2c:	02059793          	slli	a5,a1,0x20
    80002f30:	01e7d593          	srli	a1,a5,0x1e
    80002f34:	00b504b3          	add	s1,a0,a1
    80002f38:	0504a903          	lw	s2,80(s1)
    80002f3c:	06091a63          	bnez	s2,80002fb0 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002f40:	4108                	lw	a0,0(a0)
    80002f42:	eb5ff0ef          	jal	80002df6 <balloc>
    80002f46:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f4a:	06090363          	beqz	s2,80002fb0 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002f4e:	0524a823          	sw	s2,80(s1)
    80002f52:	a8b9                	j	80002fb0 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f54:	ff45849b          	addiw	s1,a1,-12
    80002f58:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002f5c:	0ff00793          	li	a5,255
    80002f60:	06e7ee63          	bltu	a5,a4,80002fdc <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f64:	08052903          	lw	s2,128(a0)
    80002f68:	00091d63          	bnez	s2,80002f82 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002f6c:	4108                	lw	a0,0(a0)
    80002f6e:	e89ff0ef          	jal	80002df6 <balloc>
    80002f72:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f76:	02090d63          	beqz	s2,80002fb0 <bmap+0x9a>
    80002f7a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f7c:	0929a023          	sw	s2,128(s3) # 80015a48 <bcache+0x68>
    80002f80:	a011                	j	80002f84 <bmap+0x6e>
    80002f82:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f84:	85ca                	mv	a1,s2
    80002f86:	0009a503          	lw	a0,0(s3)
    80002f8a:	c09ff0ef          	jal	80002b92 <bread>
    80002f8e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f90:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f94:	02049713          	slli	a4,s1,0x20
    80002f98:	01e75593          	srli	a1,a4,0x1e
    80002f9c:	00b784b3          	add	s1,a5,a1
    80002fa0:	0004a903          	lw	s2,0(s1)
    80002fa4:	00090e63          	beqz	s2,80002fc0 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fa8:	8552                	mv	a0,s4
    80002faa:	cf1ff0ef          	jal	80002c9a <brelse>
    return addr;
    80002fae:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fb0:	854a                	mv	a0,s2
    80002fb2:	70a2                	ld	ra,40(sp)
    80002fb4:	7402                	ld	s0,32(sp)
    80002fb6:	64e2                	ld	s1,24(sp)
    80002fb8:	6942                	ld	s2,16(sp)
    80002fba:	69a2                	ld	s3,8(sp)
    80002fbc:	6145                	addi	sp,sp,48
    80002fbe:	8082                	ret
      addr = balloc(ip->dev);
    80002fc0:	0009a503          	lw	a0,0(s3)
    80002fc4:	e33ff0ef          	jal	80002df6 <balloc>
    80002fc8:	0005091b          	sext.w	s2,a0
      if(addr){
    80002fcc:	fc090ee3          	beqz	s2,80002fa8 <bmap+0x92>
        a[bn] = addr;
    80002fd0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002fd4:	8552                	mv	a0,s4
    80002fd6:	5f7000ef          	jal	80003dcc <log_write>
    80002fda:	b7f9                	j	80002fa8 <bmap+0x92>
    80002fdc:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002fde:	00004517          	auipc	a0,0x4
    80002fe2:	44250513          	addi	a0,a0,1090 # 80007420 <etext+0x420>
    80002fe6:	ffafd0ef          	jal	800007e0 <panic>

0000000080002fea <iget>:
{
    80002fea:	7179                	addi	sp,sp,-48
    80002fec:	f406                	sd	ra,40(sp)
    80002fee:	f022                	sd	s0,32(sp)
    80002ff0:	ec26                	sd	s1,24(sp)
    80002ff2:	e84a                	sd	s2,16(sp)
    80002ff4:	e44e                	sd	s3,8(sp)
    80002ff6:	e052                	sd	s4,0(sp)
    80002ff8:	1800                	addi	s0,sp,48
    80002ffa:	89aa                	mv	s3,a0
    80002ffc:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002ffe:	0001b517          	auipc	a0,0x1b
    80003002:	0c250513          	addi	a0,a0,194 # 8001e0c0 <itable>
    80003006:	bc9fd0ef          	jal	80000bce <acquire>
  empty = 0;
    8000300a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000300c:	0001b497          	auipc	s1,0x1b
    80003010:	0cc48493          	addi	s1,s1,204 # 8001e0d8 <itable+0x18>
    80003014:	0001d697          	auipc	a3,0x1d
    80003018:	b5468693          	addi	a3,a3,-1196 # 8001fb68 <log>
    8000301c:	a039                	j	8000302a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000301e:	02090963          	beqz	s2,80003050 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003022:	08848493          	addi	s1,s1,136
    80003026:	02d48863          	beq	s1,a3,80003056 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000302a:	449c                	lw	a5,8(s1)
    8000302c:	fef059e3          	blez	a5,8000301e <iget+0x34>
    80003030:	4098                	lw	a4,0(s1)
    80003032:	ff3716e3          	bne	a4,s3,8000301e <iget+0x34>
    80003036:	40d8                	lw	a4,4(s1)
    80003038:	ff4713e3          	bne	a4,s4,8000301e <iget+0x34>
      ip->ref++;
    8000303c:	2785                	addiw	a5,a5,1
    8000303e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003040:	0001b517          	auipc	a0,0x1b
    80003044:	08050513          	addi	a0,a0,128 # 8001e0c0 <itable>
    80003048:	c1ffd0ef          	jal	80000c66 <release>
      return ip;
    8000304c:	8926                	mv	s2,s1
    8000304e:	a02d                	j	80003078 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003050:	fbe9                	bnez	a5,80003022 <iget+0x38>
      empty = ip;
    80003052:	8926                	mv	s2,s1
    80003054:	b7f9                	j	80003022 <iget+0x38>
  if(empty == 0)
    80003056:	02090a63          	beqz	s2,8000308a <iget+0xa0>
  ip->dev = dev;
    8000305a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000305e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003062:	4785                	li	a5,1
    80003064:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003068:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000306c:	0001b517          	auipc	a0,0x1b
    80003070:	05450513          	addi	a0,a0,84 # 8001e0c0 <itable>
    80003074:	bf3fd0ef          	jal	80000c66 <release>
}
    80003078:	854a                	mv	a0,s2
    8000307a:	70a2                	ld	ra,40(sp)
    8000307c:	7402                	ld	s0,32(sp)
    8000307e:	64e2                	ld	s1,24(sp)
    80003080:	6942                	ld	s2,16(sp)
    80003082:	69a2                	ld	s3,8(sp)
    80003084:	6a02                	ld	s4,0(sp)
    80003086:	6145                	addi	sp,sp,48
    80003088:	8082                	ret
    panic("iget: no inodes");
    8000308a:	00004517          	auipc	a0,0x4
    8000308e:	3ae50513          	addi	a0,a0,942 # 80007438 <etext+0x438>
    80003092:	f4efd0ef          	jal	800007e0 <panic>

0000000080003096 <iinit>:
{
    80003096:	7179                	addi	sp,sp,-48
    80003098:	f406                	sd	ra,40(sp)
    8000309a:	f022                	sd	s0,32(sp)
    8000309c:	ec26                	sd	s1,24(sp)
    8000309e:	e84a                	sd	s2,16(sp)
    800030a0:	e44e                	sd	s3,8(sp)
    800030a2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030a4:	00004597          	auipc	a1,0x4
    800030a8:	3a458593          	addi	a1,a1,932 # 80007448 <etext+0x448>
    800030ac:	0001b517          	auipc	a0,0x1b
    800030b0:	01450513          	addi	a0,a0,20 # 8001e0c0 <itable>
    800030b4:	a9bfd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    800030b8:	0001b497          	auipc	s1,0x1b
    800030bc:	03048493          	addi	s1,s1,48 # 8001e0e8 <itable+0x28>
    800030c0:	0001d997          	auipc	s3,0x1d
    800030c4:	ab898993          	addi	s3,s3,-1352 # 8001fb78 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030c8:	00004917          	auipc	s2,0x4
    800030cc:	38890913          	addi	s2,s2,904 # 80007450 <etext+0x450>
    800030d0:	85ca                	mv	a1,s2
    800030d2:	8526                	mv	a0,s1
    800030d4:	5bb000ef          	jal	80003e8e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800030d8:	08848493          	addi	s1,s1,136
    800030dc:	ff349ae3          	bne	s1,s3,800030d0 <iinit+0x3a>
}
    800030e0:	70a2                	ld	ra,40(sp)
    800030e2:	7402                	ld	s0,32(sp)
    800030e4:	64e2                	ld	s1,24(sp)
    800030e6:	6942                	ld	s2,16(sp)
    800030e8:	69a2                	ld	s3,8(sp)
    800030ea:	6145                	addi	sp,sp,48
    800030ec:	8082                	ret

00000000800030ee <ialloc>:
{
    800030ee:	7139                	addi	sp,sp,-64
    800030f0:	fc06                	sd	ra,56(sp)
    800030f2:	f822                	sd	s0,48(sp)
    800030f4:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800030f6:	0001b717          	auipc	a4,0x1b
    800030fa:	fb672703          	lw	a4,-74(a4) # 8001e0ac <sb+0xc>
    800030fe:	4785                	li	a5,1
    80003100:	06e7f063          	bgeu	a5,a4,80003160 <ialloc+0x72>
    80003104:	f426                	sd	s1,40(sp)
    80003106:	f04a                	sd	s2,32(sp)
    80003108:	ec4e                	sd	s3,24(sp)
    8000310a:	e852                	sd	s4,16(sp)
    8000310c:	e456                	sd	s5,8(sp)
    8000310e:	e05a                	sd	s6,0(sp)
    80003110:	8aaa                	mv	s5,a0
    80003112:	8b2e                	mv	s6,a1
    80003114:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003116:	0001ba17          	auipc	s4,0x1b
    8000311a:	f8aa0a13          	addi	s4,s4,-118 # 8001e0a0 <sb>
    8000311e:	00495593          	srli	a1,s2,0x4
    80003122:	018a2783          	lw	a5,24(s4)
    80003126:	9dbd                	addw	a1,a1,a5
    80003128:	8556                	mv	a0,s5
    8000312a:	a69ff0ef          	jal	80002b92 <bread>
    8000312e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003130:	05850993          	addi	s3,a0,88
    80003134:	00f97793          	andi	a5,s2,15
    80003138:	079a                	slli	a5,a5,0x6
    8000313a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000313c:	00099783          	lh	a5,0(s3)
    80003140:	cb9d                	beqz	a5,80003176 <ialloc+0x88>
    brelse(bp);
    80003142:	b59ff0ef          	jal	80002c9a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003146:	0905                	addi	s2,s2,1
    80003148:	00ca2703          	lw	a4,12(s4)
    8000314c:	0009079b          	sext.w	a5,s2
    80003150:	fce7e7e3          	bltu	a5,a4,8000311e <ialloc+0x30>
    80003154:	74a2                	ld	s1,40(sp)
    80003156:	7902                	ld	s2,32(sp)
    80003158:	69e2                	ld	s3,24(sp)
    8000315a:	6a42                	ld	s4,16(sp)
    8000315c:	6aa2                	ld	s5,8(sp)
    8000315e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003160:	00004517          	auipc	a0,0x4
    80003164:	2f850513          	addi	a0,a0,760 # 80007458 <etext+0x458>
    80003168:	b92fd0ef          	jal	800004fa <printf>
  return 0;
    8000316c:	4501                	li	a0,0
}
    8000316e:	70e2                	ld	ra,56(sp)
    80003170:	7442                	ld	s0,48(sp)
    80003172:	6121                	addi	sp,sp,64
    80003174:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003176:	04000613          	li	a2,64
    8000317a:	4581                	li	a1,0
    8000317c:	854e                	mv	a0,s3
    8000317e:	b25fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    80003182:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003186:	8526                	mv	a0,s1
    80003188:	445000ef          	jal	80003dcc <log_write>
      brelse(bp);
    8000318c:	8526                	mv	a0,s1
    8000318e:	b0dff0ef          	jal	80002c9a <brelse>
      return iget(dev, inum);
    80003192:	0009059b          	sext.w	a1,s2
    80003196:	8556                	mv	a0,s5
    80003198:	e53ff0ef          	jal	80002fea <iget>
    8000319c:	74a2                	ld	s1,40(sp)
    8000319e:	7902                	ld	s2,32(sp)
    800031a0:	69e2                	ld	s3,24(sp)
    800031a2:	6a42                	ld	s4,16(sp)
    800031a4:	6aa2                	ld	s5,8(sp)
    800031a6:	6b02                	ld	s6,0(sp)
    800031a8:	b7d9                	j	8000316e <ialloc+0x80>

00000000800031aa <iupdate>:
{
    800031aa:	1101                	addi	sp,sp,-32
    800031ac:	ec06                	sd	ra,24(sp)
    800031ae:	e822                	sd	s0,16(sp)
    800031b0:	e426                	sd	s1,8(sp)
    800031b2:	e04a                	sd	s2,0(sp)
    800031b4:	1000                	addi	s0,sp,32
    800031b6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031b8:	415c                	lw	a5,4(a0)
    800031ba:	0047d79b          	srliw	a5,a5,0x4
    800031be:	0001b597          	auipc	a1,0x1b
    800031c2:	efa5a583          	lw	a1,-262(a1) # 8001e0b8 <sb+0x18>
    800031c6:	9dbd                	addw	a1,a1,a5
    800031c8:	4108                	lw	a0,0(a0)
    800031ca:	9c9ff0ef          	jal	80002b92 <bread>
    800031ce:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800031d0:	05850793          	addi	a5,a0,88
    800031d4:	40d8                	lw	a4,4(s1)
    800031d6:	8b3d                	andi	a4,a4,15
    800031d8:	071a                	slli	a4,a4,0x6
    800031da:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800031dc:	04449703          	lh	a4,68(s1)
    800031e0:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800031e4:	04649703          	lh	a4,70(s1)
    800031e8:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800031ec:	04849703          	lh	a4,72(s1)
    800031f0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800031f4:	04a49703          	lh	a4,74(s1)
    800031f8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031fc:	44f8                	lw	a4,76(s1)
    800031fe:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003200:	03400613          	li	a2,52
    80003204:	05048593          	addi	a1,s1,80
    80003208:	00c78513          	addi	a0,a5,12
    8000320c:	af3fd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    80003210:	854a                	mv	a0,s2
    80003212:	3bb000ef          	jal	80003dcc <log_write>
  brelse(bp);
    80003216:	854a                	mv	a0,s2
    80003218:	a83ff0ef          	jal	80002c9a <brelse>
}
    8000321c:	60e2                	ld	ra,24(sp)
    8000321e:	6442                	ld	s0,16(sp)
    80003220:	64a2                	ld	s1,8(sp)
    80003222:	6902                	ld	s2,0(sp)
    80003224:	6105                	addi	sp,sp,32
    80003226:	8082                	ret

0000000080003228 <idup>:
{
    80003228:	1101                	addi	sp,sp,-32
    8000322a:	ec06                	sd	ra,24(sp)
    8000322c:	e822                	sd	s0,16(sp)
    8000322e:	e426                	sd	s1,8(sp)
    80003230:	1000                	addi	s0,sp,32
    80003232:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003234:	0001b517          	auipc	a0,0x1b
    80003238:	e8c50513          	addi	a0,a0,-372 # 8001e0c0 <itable>
    8000323c:	993fd0ef          	jal	80000bce <acquire>
  ip->ref++;
    80003240:	449c                	lw	a5,8(s1)
    80003242:	2785                	addiw	a5,a5,1
    80003244:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003246:	0001b517          	auipc	a0,0x1b
    8000324a:	e7a50513          	addi	a0,a0,-390 # 8001e0c0 <itable>
    8000324e:	a19fd0ef          	jal	80000c66 <release>
}
    80003252:	8526                	mv	a0,s1
    80003254:	60e2                	ld	ra,24(sp)
    80003256:	6442                	ld	s0,16(sp)
    80003258:	64a2                	ld	s1,8(sp)
    8000325a:	6105                	addi	sp,sp,32
    8000325c:	8082                	ret

000000008000325e <ilock>:
{
    8000325e:	1101                	addi	sp,sp,-32
    80003260:	ec06                	sd	ra,24(sp)
    80003262:	e822                	sd	s0,16(sp)
    80003264:	e426                	sd	s1,8(sp)
    80003266:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003268:	cd19                	beqz	a0,80003286 <ilock+0x28>
    8000326a:	84aa                	mv	s1,a0
    8000326c:	451c                	lw	a5,8(a0)
    8000326e:	00f05c63          	blez	a5,80003286 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003272:	0541                	addi	a0,a0,16
    80003274:	451000ef          	jal	80003ec4 <acquiresleep>
  if(ip->valid == 0){
    80003278:	40bc                	lw	a5,64(s1)
    8000327a:	cf89                	beqz	a5,80003294 <ilock+0x36>
}
    8000327c:	60e2                	ld	ra,24(sp)
    8000327e:	6442                	ld	s0,16(sp)
    80003280:	64a2                	ld	s1,8(sp)
    80003282:	6105                	addi	sp,sp,32
    80003284:	8082                	ret
    80003286:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003288:	00004517          	auipc	a0,0x4
    8000328c:	1e850513          	addi	a0,a0,488 # 80007470 <etext+0x470>
    80003290:	d50fd0ef          	jal	800007e0 <panic>
    80003294:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003296:	40dc                	lw	a5,4(s1)
    80003298:	0047d79b          	srliw	a5,a5,0x4
    8000329c:	0001b597          	auipc	a1,0x1b
    800032a0:	e1c5a583          	lw	a1,-484(a1) # 8001e0b8 <sb+0x18>
    800032a4:	9dbd                	addw	a1,a1,a5
    800032a6:	4088                	lw	a0,0(s1)
    800032a8:	8ebff0ef          	jal	80002b92 <bread>
    800032ac:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032ae:	05850593          	addi	a1,a0,88
    800032b2:	40dc                	lw	a5,4(s1)
    800032b4:	8bbd                	andi	a5,a5,15
    800032b6:	079a                	slli	a5,a5,0x6
    800032b8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800032ba:	00059783          	lh	a5,0(a1)
    800032be:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800032c2:	00259783          	lh	a5,2(a1)
    800032c6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800032ca:	00459783          	lh	a5,4(a1)
    800032ce:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800032d2:	00659783          	lh	a5,6(a1)
    800032d6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800032da:	459c                	lw	a5,8(a1)
    800032dc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800032de:	03400613          	li	a2,52
    800032e2:	05b1                	addi	a1,a1,12
    800032e4:	05048513          	addi	a0,s1,80
    800032e8:	a17fd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    800032ec:	854a                	mv	a0,s2
    800032ee:	9adff0ef          	jal	80002c9a <brelse>
    ip->valid = 1;
    800032f2:	4785                	li	a5,1
    800032f4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800032f6:	04449783          	lh	a5,68(s1)
    800032fa:	c399                	beqz	a5,80003300 <ilock+0xa2>
    800032fc:	6902                	ld	s2,0(sp)
    800032fe:	bfbd                	j	8000327c <ilock+0x1e>
      panic("ilock: no type");
    80003300:	00004517          	auipc	a0,0x4
    80003304:	17850513          	addi	a0,a0,376 # 80007478 <etext+0x478>
    80003308:	cd8fd0ef          	jal	800007e0 <panic>

000000008000330c <iunlock>:
{
    8000330c:	1101                	addi	sp,sp,-32
    8000330e:	ec06                	sd	ra,24(sp)
    80003310:	e822                	sd	s0,16(sp)
    80003312:	e426                	sd	s1,8(sp)
    80003314:	e04a                	sd	s2,0(sp)
    80003316:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003318:	c505                	beqz	a0,80003340 <iunlock+0x34>
    8000331a:	84aa                	mv	s1,a0
    8000331c:	01050913          	addi	s2,a0,16
    80003320:	854a                	mv	a0,s2
    80003322:	421000ef          	jal	80003f42 <holdingsleep>
    80003326:	cd09                	beqz	a0,80003340 <iunlock+0x34>
    80003328:	449c                	lw	a5,8(s1)
    8000332a:	00f05b63          	blez	a5,80003340 <iunlock+0x34>
  releasesleep(&ip->lock);
    8000332e:	854a                	mv	a0,s2
    80003330:	3db000ef          	jal	80003f0a <releasesleep>
}
    80003334:	60e2                	ld	ra,24(sp)
    80003336:	6442                	ld	s0,16(sp)
    80003338:	64a2                	ld	s1,8(sp)
    8000333a:	6902                	ld	s2,0(sp)
    8000333c:	6105                	addi	sp,sp,32
    8000333e:	8082                	ret
    panic("iunlock");
    80003340:	00004517          	auipc	a0,0x4
    80003344:	14850513          	addi	a0,a0,328 # 80007488 <etext+0x488>
    80003348:	c98fd0ef          	jal	800007e0 <panic>

000000008000334c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000334c:	7179                	addi	sp,sp,-48
    8000334e:	f406                	sd	ra,40(sp)
    80003350:	f022                	sd	s0,32(sp)
    80003352:	ec26                	sd	s1,24(sp)
    80003354:	e84a                	sd	s2,16(sp)
    80003356:	e44e                	sd	s3,8(sp)
    80003358:	1800                	addi	s0,sp,48
    8000335a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000335c:	05050493          	addi	s1,a0,80
    80003360:	08050913          	addi	s2,a0,128
    80003364:	a021                	j	8000336c <itrunc+0x20>
    80003366:	0491                	addi	s1,s1,4
    80003368:	01248b63          	beq	s1,s2,8000337e <itrunc+0x32>
    if(ip->addrs[i]){
    8000336c:	408c                	lw	a1,0(s1)
    8000336e:	dde5                	beqz	a1,80003366 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003370:	0009a503          	lw	a0,0(s3)
    80003374:	a17ff0ef          	jal	80002d8a <bfree>
      ip->addrs[i] = 0;
    80003378:	0004a023          	sw	zero,0(s1)
    8000337c:	b7ed                	j	80003366 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000337e:	0809a583          	lw	a1,128(s3)
    80003382:	ed89                	bnez	a1,8000339c <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003384:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003388:	854e                	mv	a0,s3
    8000338a:	e21ff0ef          	jal	800031aa <iupdate>
}
    8000338e:	70a2                	ld	ra,40(sp)
    80003390:	7402                	ld	s0,32(sp)
    80003392:	64e2                	ld	s1,24(sp)
    80003394:	6942                	ld	s2,16(sp)
    80003396:	69a2                	ld	s3,8(sp)
    80003398:	6145                	addi	sp,sp,48
    8000339a:	8082                	ret
    8000339c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000339e:	0009a503          	lw	a0,0(s3)
    800033a2:	ff0ff0ef          	jal	80002b92 <bread>
    800033a6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800033a8:	05850493          	addi	s1,a0,88
    800033ac:	45850913          	addi	s2,a0,1112
    800033b0:	a021                	j	800033b8 <itrunc+0x6c>
    800033b2:	0491                	addi	s1,s1,4
    800033b4:	01248963          	beq	s1,s2,800033c6 <itrunc+0x7a>
      if(a[j])
    800033b8:	408c                	lw	a1,0(s1)
    800033ba:	dde5                	beqz	a1,800033b2 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800033bc:	0009a503          	lw	a0,0(s3)
    800033c0:	9cbff0ef          	jal	80002d8a <bfree>
    800033c4:	b7fd                	j	800033b2 <itrunc+0x66>
    brelse(bp);
    800033c6:	8552                	mv	a0,s4
    800033c8:	8d3ff0ef          	jal	80002c9a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800033cc:	0809a583          	lw	a1,128(s3)
    800033d0:	0009a503          	lw	a0,0(s3)
    800033d4:	9b7ff0ef          	jal	80002d8a <bfree>
    ip->addrs[NDIRECT] = 0;
    800033d8:	0809a023          	sw	zero,128(s3)
    800033dc:	6a02                	ld	s4,0(sp)
    800033de:	b75d                	j	80003384 <itrunc+0x38>

00000000800033e0 <iput>:
{
    800033e0:	1101                	addi	sp,sp,-32
    800033e2:	ec06                	sd	ra,24(sp)
    800033e4:	e822                	sd	s0,16(sp)
    800033e6:	e426                	sd	s1,8(sp)
    800033e8:	1000                	addi	s0,sp,32
    800033ea:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033ec:	0001b517          	auipc	a0,0x1b
    800033f0:	cd450513          	addi	a0,a0,-812 # 8001e0c0 <itable>
    800033f4:	fdafd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033f8:	4498                	lw	a4,8(s1)
    800033fa:	4785                	li	a5,1
    800033fc:	02f70063          	beq	a4,a5,8000341c <iput+0x3c>
  ip->ref--;
    80003400:	449c                	lw	a5,8(s1)
    80003402:	37fd                	addiw	a5,a5,-1
    80003404:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003406:	0001b517          	auipc	a0,0x1b
    8000340a:	cba50513          	addi	a0,a0,-838 # 8001e0c0 <itable>
    8000340e:	859fd0ef          	jal	80000c66 <release>
}
    80003412:	60e2                	ld	ra,24(sp)
    80003414:	6442                	ld	s0,16(sp)
    80003416:	64a2                	ld	s1,8(sp)
    80003418:	6105                	addi	sp,sp,32
    8000341a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000341c:	40bc                	lw	a5,64(s1)
    8000341e:	d3ed                	beqz	a5,80003400 <iput+0x20>
    80003420:	04a49783          	lh	a5,74(s1)
    80003424:	fff1                	bnez	a5,80003400 <iput+0x20>
    80003426:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003428:	01048913          	addi	s2,s1,16
    8000342c:	854a                	mv	a0,s2
    8000342e:	297000ef          	jal	80003ec4 <acquiresleep>
    release(&itable.lock);
    80003432:	0001b517          	auipc	a0,0x1b
    80003436:	c8e50513          	addi	a0,a0,-882 # 8001e0c0 <itable>
    8000343a:	82dfd0ef          	jal	80000c66 <release>
    itrunc(ip);
    8000343e:	8526                	mv	a0,s1
    80003440:	f0dff0ef          	jal	8000334c <itrunc>
    ip->type = 0;
    80003444:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003448:	8526                	mv	a0,s1
    8000344a:	d61ff0ef          	jal	800031aa <iupdate>
    ip->valid = 0;
    8000344e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003452:	854a                	mv	a0,s2
    80003454:	2b7000ef          	jal	80003f0a <releasesleep>
    acquire(&itable.lock);
    80003458:	0001b517          	auipc	a0,0x1b
    8000345c:	c6850513          	addi	a0,a0,-920 # 8001e0c0 <itable>
    80003460:	f6efd0ef          	jal	80000bce <acquire>
    80003464:	6902                	ld	s2,0(sp)
    80003466:	bf69                	j	80003400 <iput+0x20>

0000000080003468 <iunlockput>:
{
    80003468:	1101                	addi	sp,sp,-32
    8000346a:	ec06                	sd	ra,24(sp)
    8000346c:	e822                	sd	s0,16(sp)
    8000346e:	e426                	sd	s1,8(sp)
    80003470:	1000                	addi	s0,sp,32
    80003472:	84aa                	mv	s1,a0
  iunlock(ip);
    80003474:	e99ff0ef          	jal	8000330c <iunlock>
  iput(ip);
    80003478:	8526                	mv	a0,s1
    8000347a:	f67ff0ef          	jal	800033e0 <iput>
}
    8000347e:	60e2                	ld	ra,24(sp)
    80003480:	6442                	ld	s0,16(sp)
    80003482:	64a2                	ld	s1,8(sp)
    80003484:	6105                	addi	sp,sp,32
    80003486:	8082                	ret

0000000080003488 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003488:	0001b717          	auipc	a4,0x1b
    8000348c:	c2472703          	lw	a4,-988(a4) # 8001e0ac <sb+0xc>
    80003490:	4785                	li	a5,1
    80003492:	0ae7ff63          	bgeu	a5,a4,80003550 <ireclaim+0xc8>
{
    80003496:	7139                	addi	sp,sp,-64
    80003498:	fc06                	sd	ra,56(sp)
    8000349a:	f822                	sd	s0,48(sp)
    8000349c:	f426                	sd	s1,40(sp)
    8000349e:	f04a                	sd	s2,32(sp)
    800034a0:	ec4e                	sd	s3,24(sp)
    800034a2:	e852                	sd	s4,16(sp)
    800034a4:	e456                	sd	s5,8(sp)
    800034a6:	e05a                	sd	s6,0(sp)
    800034a8:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034aa:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034ac:	00050a1b          	sext.w	s4,a0
    800034b0:	0001ba97          	auipc	s5,0x1b
    800034b4:	bf0a8a93          	addi	s5,s5,-1040 # 8001e0a0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800034b8:	00004b17          	auipc	s6,0x4
    800034bc:	fd8b0b13          	addi	s6,s6,-40 # 80007490 <etext+0x490>
    800034c0:	a099                	j	80003506 <ireclaim+0x7e>
    800034c2:	85ce                	mv	a1,s3
    800034c4:	855a                	mv	a0,s6
    800034c6:	834fd0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800034ca:	85ce                	mv	a1,s3
    800034cc:	8552                	mv	a0,s4
    800034ce:	b1dff0ef          	jal	80002fea <iget>
    800034d2:	89aa                	mv	s3,a0
    brelse(bp);
    800034d4:	854a                	mv	a0,s2
    800034d6:	fc4ff0ef          	jal	80002c9a <brelse>
    if (ip) {
    800034da:	00098f63          	beqz	s3,800034f8 <ireclaim+0x70>
      begin_op();
    800034de:	76a000ef          	jal	80003c48 <begin_op>
      ilock(ip);
    800034e2:	854e                	mv	a0,s3
    800034e4:	d7bff0ef          	jal	8000325e <ilock>
      iunlock(ip);
    800034e8:	854e                	mv	a0,s3
    800034ea:	e23ff0ef          	jal	8000330c <iunlock>
      iput(ip);
    800034ee:	854e                	mv	a0,s3
    800034f0:	ef1ff0ef          	jal	800033e0 <iput>
      end_op();
    800034f4:	7be000ef          	jal	80003cb2 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034f8:	0485                	addi	s1,s1,1
    800034fa:	00caa703          	lw	a4,12(s5)
    800034fe:	0004879b          	sext.w	a5,s1
    80003502:	02e7fd63          	bgeu	a5,a4,8000353c <ireclaim+0xb4>
    80003506:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000350a:	0044d593          	srli	a1,s1,0x4
    8000350e:	018aa783          	lw	a5,24(s5)
    80003512:	9dbd                	addw	a1,a1,a5
    80003514:	8552                	mv	a0,s4
    80003516:	e7cff0ef          	jal	80002b92 <bread>
    8000351a:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000351c:	05850793          	addi	a5,a0,88
    80003520:	00f9f713          	andi	a4,s3,15
    80003524:	071a                	slli	a4,a4,0x6
    80003526:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003528:	00079703          	lh	a4,0(a5)
    8000352c:	c701                	beqz	a4,80003534 <ireclaim+0xac>
    8000352e:	00679783          	lh	a5,6(a5)
    80003532:	dbc1                	beqz	a5,800034c2 <ireclaim+0x3a>
    brelse(bp);
    80003534:	854a                	mv	a0,s2
    80003536:	f64ff0ef          	jal	80002c9a <brelse>
    if (ip) {
    8000353a:	bf7d                	j	800034f8 <ireclaim+0x70>
}
    8000353c:	70e2                	ld	ra,56(sp)
    8000353e:	7442                	ld	s0,48(sp)
    80003540:	74a2                	ld	s1,40(sp)
    80003542:	7902                	ld	s2,32(sp)
    80003544:	69e2                	ld	s3,24(sp)
    80003546:	6a42                	ld	s4,16(sp)
    80003548:	6aa2                	ld	s5,8(sp)
    8000354a:	6b02                	ld	s6,0(sp)
    8000354c:	6121                	addi	sp,sp,64
    8000354e:	8082                	ret
    80003550:	8082                	ret

0000000080003552 <fsinit>:
fsinit(int dev) {
    80003552:	7179                	addi	sp,sp,-48
    80003554:	f406                	sd	ra,40(sp)
    80003556:	f022                	sd	s0,32(sp)
    80003558:	ec26                	sd	s1,24(sp)
    8000355a:	e84a                	sd	s2,16(sp)
    8000355c:	e44e                	sd	s3,8(sp)
    8000355e:	1800                	addi	s0,sp,48
    80003560:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003562:	4585                	li	a1,1
    80003564:	e2eff0ef          	jal	80002b92 <bread>
    80003568:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000356a:	0001b997          	auipc	s3,0x1b
    8000356e:	b3698993          	addi	s3,s3,-1226 # 8001e0a0 <sb>
    80003572:	02000613          	li	a2,32
    80003576:	05850593          	addi	a1,a0,88
    8000357a:	854e                	mv	a0,s3
    8000357c:	f82fd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    80003580:	854a                	mv	a0,s2
    80003582:	f18ff0ef          	jal	80002c9a <brelse>
  if(sb.magic != FSMAGIC)
    80003586:	0009a703          	lw	a4,0(s3)
    8000358a:	102037b7          	lui	a5,0x10203
    8000358e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003592:	02f71363          	bne	a4,a5,800035b8 <fsinit+0x66>
  initlog(dev, &sb);
    80003596:	0001b597          	auipc	a1,0x1b
    8000359a:	b0a58593          	addi	a1,a1,-1270 # 8001e0a0 <sb>
    8000359e:	8526                	mv	a0,s1
    800035a0:	62a000ef          	jal	80003bca <initlog>
  ireclaim(dev);
    800035a4:	8526                	mv	a0,s1
    800035a6:	ee3ff0ef          	jal	80003488 <ireclaim>
}
    800035aa:	70a2                	ld	ra,40(sp)
    800035ac:	7402                	ld	s0,32(sp)
    800035ae:	64e2                	ld	s1,24(sp)
    800035b0:	6942                	ld	s2,16(sp)
    800035b2:	69a2                	ld	s3,8(sp)
    800035b4:	6145                	addi	sp,sp,48
    800035b6:	8082                	ret
    panic("invalid file system");
    800035b8:	00004517          	auipc	a0,0x4
    800035bc:	ef850513          	addi	a0,a0,-264 # 800074b0 <etext+0x4b0>
    800035c0:	a20fd0ef          	jal	800007e0 <panic>

00000000800035c4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800035c4:	1141                	addi	sp,sp,-16
    800035c6:	e422                	sd	s0,8(sp)
    800035c8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800035ca:	411c                	lw	a5,0(a0)
    800035cc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800035ce:	415c                	lw	a5,4(a0)
    800035d0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800035d2:	04451783          	lh	a5,68(a0)
    800035d6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800035da:	04a51783          	lh	a5,74(a0)
    800035de:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800035e2:	04c56783          	lwu	a5,76(a0)
    800035e6:	e99c                	sd	a5,16(a1)
}
    800035e8:	6422                	ld	s0,8(sp)
    800035ea:	0141                	addi	sp,sp,16
    800035ec:	8082                	ret

00000000800035ee <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800035ee:	457c                	lw	a5,76(a0)
    800035f0:	0ed7eb63          	bltu	a5,a3,800036e6 <readi+0xf8>
{
    800035f4:	7159                	addi	sp,sp,-112
    800035f6:	f486                	sd	ra,104(sp)
    800035f8:	f0a2                	sd	s0,96(sp)
    800035fa:	eca6                	sd	s1,88(sp)
    800035fc:	e0d2                	sd	s4,64(sp)
    800035fe:	fc56                	sd	s5,56(sp)
    80003600:	f85a                	sd	s6,48(sp)
    80003602:	f45e                	sd	s7,40(sp)
    80003604:	1880                	addi	s0,sp,112
    80003606:	8b2a                	mv	s6,a0
    80003608:	8bae                	mv	s7,a1
    8000360a:	8a32                	mv	s4,a2
    8000360c:	84b6                	mv	s1,a3
    8000360e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003610:	9f35                	addw	a4,a4,a3
    return 0;
    80003612:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003614:	0cd76063          	bltu	a4,a3,800036d4 <readi+0xe6>
    80003618:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000361a:	00e7f463          	bgeu	a5,a4,80003622 <readi+0x34>
    n = ip->size - off;
    8000361e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003622:	080a8f63          	beqz	s5,800036c0 <readi+0xd2>
    80003626:	e8ca                	sd	s2,80(sp)
    80003628:	f062                	sd	s8,32(sp)
    8000362a:	ec66                	sd	s9,24(sp)
    8000362c:	e86a                	sd	s10,16(sp)
    8000362e:	e46e                	sd	s11,8(sp)
    80003630:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003632:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003636:	5c7d                	li	s8,-1
    80003638:	a80d                	j	8000366a <readi+0x7c>
    8000363a:	020d1d93          	slli	s11,s10,0x20
    8000363e:	020ddd93          	srli	s11,s11,0x20
    80003642:	05890613          	addi	a2,s2,88
    80003646:	86ee                	mv	a3,s11
    80003648:	963a                	add	a2,a2,a4
    8000364a:	85d2                	mv	a1,s4
    8000364c:	855e                	mv	a0,s7
    8000364e:	bf3fe0ef          	jal	80002240 <either_copyout>
    80003652:	05850763          	beq	a0,s8,800036a0 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003656:	854a                	mv	a0,s2
    80003658:	e42ff0ef          	jal	80002c9a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000365c:	013d09bb          	addw	s3,s10,s3
    80003660:	009d04bb          	addw	s1,s10,s1
    80003664:	9a6e                	add	s4,s4,s11
    80003666:	0559f763          	bgeu	s3,s5,800036b4 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    8000366a:	00a4d59b          	srliw	a1,s1,0xa
    8000366e:	855a                	mv	a0,s6
    80003670:	8a7ff0ef          	jal	80002f16 <bmap>
    80003674:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003678:	c5b1                	beqz	a1,800036c4 <readi+0xd6>
    bp = bread(ip->dev, addr);
    8000367a:	000b2503          	lw	a0,0(s6)
    8000367e:	d14ff0ef          	jal	80002b92 <bread>
    80003682:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003684:	3ff4f713          	andi	a4,s1,1023
    80003688:	40ec87bb          	subw	a5,s9,a4
    8000368c:	413a86bb          	subw	a3,s5,s3
    80003690:	8d3e                	mv	s10,a5
    80003692:	2781                	sext.w	a5,a5
    80003694:	0006861b          	sext.w	a2,a3
    80003698:	faf671e3          	bgeu	a2,a5,8000363a <readi+0x4c>
    8000369c:	8d36                	mv	s10,a3
    8000369e:	bf71                	j	8000363a <readi+0x4c>
      brelse(bp);
    800036a0:	854a                	mv	a0,s2
    800036a2:	df8ff0ef          	jal	80002c9a <brelse>
      tot = -1;
    800036a6:	59fd                	li	s3,-1
      break;
    800036a8:	6946                	ld	s2,80(sp)
    800036aa:	7c02                	ld	s8,32(sp)
    800036ac:	6ce2                	ld	s9,24(sp)
    800036ae:	6d42                	ld	s10,16(sp)
    800036b0:	6da2                	ld	s11,8(sp)
    800036b2:	a831                	j	800036ce <readi+0xe0>
    800036b4:	6946                	ld	s2,80(sp)
    800036b6:	7c02                	ld	s8,32(sp)
    800036b8:	6ce2                	ld	s9,24(sp)
    800036ba:	6d42                	ld	s10,16(sp)
    800036bc:	6da2                	ld	s11,8(sp)
    800036be:	a801                	j	800036ce <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036c0:	89d6                	mv	s3,s5
    800036c2:	a031                	j	800036ce <readi+0xe0>
    800036c4:	6946                	ld	s2,80(sp)
    800036c6:	7c02                	ld	s8,32(sp)
    800036c8:	6ce2                	ld	s9,24(sp)
    800036ca:	6d42                	ld	s10,16(sp)
    800036cc:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800036ce:	0009851b          	sext.w	a0,s3
    800036d2:	69a6                	ld	s3,72(sp)
}
    800036d4:	70a6                	ld	ra,104(sp)
    800036d6:	7406                	ld	s0,96(sp)
    800036d8:	64e6                	ld	s1,88(sp)
    800036da:	6a06                	ld	s4,64(sp)
    800036dc:	7ae2                	ld	s5,56(sp)
    800036de:	7b42                	ld	s6,48(sp)
    800036e0:	7ba2                	ld	s7,40(sp)
    800036e2:	6165                	addi	sp,sp,112
    800036e4:	8082                	ret
    return 0;
    800036e6:	4501                	li	a0,0
}
    800036e8:	8082                	ret

00000000800036ea <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800036ea:	457c                	lw	a5,76(a0)
    800036ec:	10d7e063          	bltu	a5,a3,800037ec <writei+0x102>
{
    800036f0:	7159                	addi	sp,sp,-112
    800036f2:	f486                	sd	ra,104(sp)
    800036f4:	f0a2                	sd	s0,96(sp)
    800036f6:	e8ca                	sd	s2,80(sp)
    800036f8:	e0d2                	sd	s4,64(sp)
    800036fa:	fc56                	sd	s5,56(sp)
    800036fc:	f85a                	sd	s6,48(sp)
    800036fe:	f45e                	sd	s7,40(sp)
    80003700:	1880                	addi	s0,sp,112
    80003702:	8aaa                	mv	s5,a0
    80003704:	8bae                	mv	s7,a1
    80003706:	8a32                	mv	s4,a2
    80003708:	8936                	mv	s2,a3
    8000370a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000370c:	00e687bb          	addw	a5,a3,a4
    80003710:	0ed7e063          	bltu	a5,a3,800037f0 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003714:	00043737          	lui	a4,0x43
    80003718:	0cf76e63          	bltu	a4,a5,800037f4 <writei+0x10a>
    8000371c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000371e:	0a0b0f63          	beqz	s6,800037dc <writei+0xf2>
    80003722:	eca6                	sd	s1,88(sp)
    80003724:	f062                	sd	s8,32(sp)
    80003726:	ec66                	sd	s9,24(sp)
    80003728:	e86a                	sd	s10,16(sp)
    8000372a:	e46e                	sd	s11,8(sp)
    8000372c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000372e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003732:	5c7d                	li	s8,-1
    80003734:	a825                	j	8000376c <writei+0x82>
    80003736:	020d1d93          	slli	s11,s10,0x20
    8000373a:	020ddd93          	srli	s11,s11,0x20
    8000373e:	05848513          	addi	a0,s1,88
    80003742:	86ee                	mv	a3,s11
    80003744:	8652                	mv	a2,s4
    80003746:	85de                	mv	a1,s7
    80003748:	953a                	add	a0,a0,a4
    8000374a:	b41fe0ef          	jal	8000228a <either_copyin>
    8000374e:	05850a63          	beq	a0,s8,800037a2 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003752:	8526                	mv	a0,s1
    80003754:	678000ef          	jal	80003dcc <log_write>
    brelse(bp);
    80003758:	8526                	mv	a0,s1
    8000375a:	d40ff0ef          	jal	80002c9a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000375e:	013d09bb          	addw	s3,s10,s3
    80003762:	012d093b          	addw	s2,s10,s2
    80003766:	9a6e                	add	s4,s4,s11
    80003768:	0569f063          	bgeu	s3,s6,800037a8 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000376c:	00a9559b          	srliw	a1,s2,0xa
    80003770:	8556                	mv	a0,s5
    80003772:	fa4ff0ef          	jal	80002f16 <bmap>
    80003776:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000377a:	c59d                	beqz	a1,800037a8 <writei+0xbe>
    bp = bread(ip->dev, addr);
    8000377c:	000aa503          	lw	a0,0(s5)
    80003780:	c12ff0ef          	jal	80002b92 <bread>
    80003784:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003786:	3ff97713          	andi	a4,s2,1023
    8000378a:	40ec87bb          	subw	a5,s9,a4
    8000378e:	413b06bb          	subw	a3,s6,s3
    80003792:	8d3e                	mv	s10,a5
    80003794:	2781                	sext.w	a5,a5
    80003796:	0006861b          	sext.w	a2,a3
    8000379a:	f8f67ee3          	bgeu	a2,a5,80003736 <writei+0x4c>
    8000379e:	8d36                	mv	s10,a3
    800037a0:	bf59                	j	80003736 <writei+0x4c>
      brelse(bp);
    800037a2:	8526                	mv	a0,s1
    800037a4:	cf6ff0ef          	jal	80002c9a <brelse>
  }

  if(off > ip->size)
    800037a8:	04caa783          	lw	a5,76(s5)
    800037ac:	0327fa63          	bgeu	a5,s2,800037e0 <writei+0xf6>
    ip->size = off;
    800037b0:	052aa623          	sw	s2,76(s5)
    800037b4:	64e6                	ld	s1,88(sp)
    800037b6:	7c02                	ld	s8,32(sp)
    800037b8:	6ce2                	ld	s9,24(sp)
    800037ba:	6d42                	ld	s10,16(sp)
    800037bc:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800037be:	8556                	mv	a0,s5
    800037c0:	9ebff0ef          	jal	800031aa <iupdate>

  return tot;
    800037c4:	0009851b          	sext.w	a0,s3
    800037c8:	69a6                	ld	s3,72(sp)
}
    800037ca:	70a6                	ld	ra,104(sp)
    800037cc:	7406                	ld	s0,96(sp)
    800037ce:	6946                	ld	s2,80(sp)
    800037d0:	6a06                	ld	s4,64(sp)
    800037d2:	7ae2                	ld	s5,56(sp)
    800037d4:	7b42                	ld	s6,48(sp)
    800037d6:	7ba2                	ld	s7,40(sp)
    800037d8:	6165                	addi	sp,sp,112
    800037da:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037dc:	89da                	mv	s3,s6
    800037de:	b7c5                	j	800037be <writei+0xd4>
    800037e0:	64e6                	ld	s1,88(sp)
    800037e2:	7c02                	ld	s8,32(sp)
    800037e4:	6ce2                	ld	s9,24(sp)
    800037e6:	6d42                	ld	s10,16(sp)
    800037e8:	6da2                	ld	s11,8(sp)
    800037ea:	bfd1                	j	800037be <writei+0xd4>
    return -1;
    800037ec:	557d                	li	a0,-1
}
    800037ee:	8082                	ret
    return -1;
    800037f0:	557d                	li	a0,-1
    800037f2:	bfe1                	j	800037ca <writei+0xe0>
    return -1;
    800037f4:	557d                	li	a0,-1
    800037f6:	bfd1                	j	800037ca <writei+0xe0>

00000000800037f8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800037f8:	1141                	addi	sp,sp,-16
    800037fa:	e406                	sd	ra,8(sp)
    800037fc:	e022                	sd	s0,0(sp)
    800037fe:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003800:	4639                	li	a2,14
    80003802:	d6cfd0ef          	jal	80000d6e <strncmp>
}
    80003806:	60a2                	ld	ra,8(sp)
    80003808:	6402                	ld	s0,0(sp)
    8000380a:	0141                	addi	sp,sp,16
    8000380c:	8082                	ret

000000008000380e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000380e:	7139                	addi	sp,sp,-64
    80003810:	fc06                	sd	ra,56(sp)
    80003812:	f822                	sd	s0,48(sp)
    80003814:	f426                	sd	s1,40(sp)
    80003816:	f04a                	sd	s2,32(sp)
    80003818:	ec4e                	sd	s3,24(sp)
    8000381a:	e852                	sd	s4,16(sp)
    8000381c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000381e:	04451703          	lh	a4,68(a0)
    80003822:	4785                	li	a5,1
    80003824:	00f71a63          	bne	a4,a5,80003838 <dirlookup+0x2a>
    80003828:	892a                	mv	s2,a0
    8000382a:	89ae                	mv	s3,a1
    8000382c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000382e:	457c                	lw	a5,76(a0)
    80003830:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003832:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003834:	e39d                	bnez	a5,8000385a <dirlookup+0x4c>
    80003836:	a095                	j	8000389a <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003838:	00004517          	auipc	a0,0x4
    8000383c:	c9050513          	addi	a0,a0,-880 # 800074c8 <etext+0x4c8>
    80003840:	fa1fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003844:	00004517          	auipc	a0,0x4
    80003848:	c9c50513          	addi	a0,a0,-868 # 800074e0 <etext+0x4e0>
    8000384c:	f95fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003850:	24c1                	addiw	s1,s1,16
    80003852:	04c92783          	lw	a5,76(s2)
    80003856:	04f4f163          	bgeu	s1,a5,80003898 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000385a:	4741                	li	a4,16
    8000385c:	86a6                	mv	a3,s1
    8000385e:	fc040613          	addi	a2,s0,-64
    80003862:	4581                	li	a1,0
    80003864:	854a                	mv	a0,s2
    80003866:	d89ff0ef          	jal	800035ee <readi>
    8000386a:	47c1                	li	a5,16
    8000386c:	fcf51ce3          	bne	a0,a5,80003844 <dirlookup+0x36>
    if(de.inum == 0)
    80003870:	fc045783          	lhu	a5,-64(s0)
    80003874:	dff1                	beqz	a5,80003850 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003876:	fc240593          	addi	a1,s0,-62
    8000387a:	854e                	mv	a0,s3
    8000387c:	f7dff0ef          	jal	800037f8 <namecmp>
    80003880:	f961                	bnez	a0,80003850 <dirlookup+0x42>
      if(poff)
    80003882:	000a0463          	beqz	s4,8000388a <dirlookup+0x7c>
        *poff = off;
    80003886:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000388a:	fc045583          	lhu	a1,-64(s0)
    8000388e:	00092503          	lw	a0,0(s2)
    80003892:	f58ff0ef          	jal	80002fea <iget>
    80003896:	a011                	j	8000389a <dirlookup+0x8c>
  return 0;
    80003898:	4501                	li	a0,0
}
    8000389a:	70e2                	ld	ra,56(sp)
    8000389c:	7442                	ld	s0,48(sp)
    8000389e:	74a2                	ld	s1,40(sp)
    800038a0:	7902                	ld	s2,32(sp)
    800038a2:	69e2                	ld	s3,24(sp)
    800038a4:	6a42                	ld	s4,16(sp)
    800038a6:	6121                	addi	sp,sp,64
    800038a8:	8082                	ret

00000000800038aa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800038aa:	711d                	addi	sp,sp,-96
    800038ac:	ec86                	sd	ra,88(sp)
    800038ae:	e8a2                	sd	s0,80(sp)
    800038b0:	e4a6                	sd	s1,72(sp)
    800038b2:	e0ca                	sd	s2,64(sp)
    800038b4:	fc4e                	sd	s3,56(sp)
    800038b6:	f852                	sd	s4,48(sp)
    800038b8:	f456                	sd	s5,40(sp)
    800038ba:	f05a                	sd	s6,32(sp)
    800038bc:	ec5e                	sd	s7,24(sp)
    800038be:	e862                	sd	s8,16(sp)
    800038c0:	e466                	sd	s9,8(sp)
    800038c2:	1080                	addi	s0,sp,96
    800038c4:	84aa                	mv	s1,a0
    800038c6:	8b2e                	mv	s6,a1
    800038c8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800038ca:	00054703          	lbu	a4,0(a0)
    800038ce:	02f00793          	li	a5,47
    800038d2:	00f70e63          	beq	a4,a5,800038ee <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800038d6:	ff9fd0ef          	jal	800018ce <myproc>
    800038da:	15053503          	ld	a0,336(a0)
    800038de:	94bff0ef          	jal	80003228 <idup>
    800038e2:	8a2a                	mv	s4,a0
  while(*path == '/')
    800038e4:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800038e8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800038ea:	4b85                	li	s7,1
    800038ec:	a871                	j	80003988 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800038ee:	4585                	li	a1,1
    800038f0:	4505                	li	a0,1
    800038f2:	ef8ff0ef          	jal	80002fea <iget>
    800038f6:	8a2a                	mv	s4,a0
    800038f8:	b7f5                	j	800038e4 <namex+0x3a>
      iunlockput(ip);
    800038fa:	8552                	mv	a0,s4
    800038fc:	b6dff0ef          	jal	80003468 <iunlockput>
      return 0;
    80003900:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003902:	8552                	mv	a0,s4
    80003904:	60e6                	ld	ra,88(sp)
    80003906:	6446                	ld	s0,80(sp)
    80003908:	64a6                	ld	s1,72(sp)
    8000390a:	6906                	ld	s2,64(sp)
    8000390c:	79e2                	ld	s3,56(sp)
    8000390e:	7a42                	ld	s4,48(sp)
    80003910:	7aa2                	ld	s5,40(sp)
    80003912:	7b02                	ld	s6,32(sp)
    80003914:	6be2                	ld	s7,24(sp)
    80003916:	6c42                	ld	s8,16(sp)
    80003918:	6ca2                	ld	s9,8(sp)
    8000391a:	6125                	addi	sp,sp,96
    8000391c:	8082                	ret
      iunlock(ip);
    8000391e:	8552                	mv	a0,s4
    80003920:	9edff0ef          	jal	8000330c <iunlock>
      return ip;
    80003924:	bff9                	j	80003902 <namex+0x58>
      iunlockput(ip);
    80003926:	8552                	mv	a0,s4
    80003928:	b41ff0ef          	jal	80003468 <iunlockput>
      return 0;
    8000392c:	8a4e                	mv	s4,s3
    8000392e:	bfd1                	j	80003902 <namex+0x58>
  len = path - s;
    80003930:	40998633          	sub	a2,s3,s1
    80003934:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003938:	099c5063          	bge	s8,s9,800039b8 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    8000393c:	4639                	li	a2,14
    8000393e:	85a6                	mv	a1,s1
    80003940:	8556                	mv	a0,s5
    80003942:	bbcfd0ef          	jal	80000cfe <memmove>
    80003946:	84ce                	mv	s1,s3
  while(*path == '/')
    80003948:	0004c783          	lbu	a5,0(s1)
    8000394c:	01279763          	bne	a5,s2,8000395a <namex+0xb0>
    path++;
    80003950:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003952:	0004c783          	lbu	a5,0(s1)
    80003956:	ff278de3          	beq	a5,s2,80003950 <namex+0xa6>
    ilock(ip);
    8000395a:	8552                	mv	a0,s4
    8000395c:	903ff0ef          	jal	8000325e <ilock>
    if(ip->type != T_DIR){
    80003960:	044a1783          	lh	a5,68(s4)
    80003964:	f9779be3          	bne	a5,s7,800038fa <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003968:	000b0563          	beqz	s6,80003972 <namex+0xc8>
    8000396c:	0004c783          	lbu	a5,0(s1)
    80003970:	d7dd                	beqz	a5,8000391e <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003972:	4601                	li	a2,0
    80003974:	85d6                	mv	a1,s5
    80003976:	8552                	mv	a0,s4
    80003978:	e97ff0ef          	jal	8000380e <dirlookup>
    8000397c:	89aa                	mv	s3,a0
    8000397e:	d545                	beqz	a0,80003926 <namex+0x7c>
    iunlockput(ip);
    80003980:	8552                	mv	a0,s4
    80003982:	ae7ff0ef          	jal	80003468 <iunlockput>
    ip = next;
    80003986:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003988:	0004c783          	lbu	a5,0(s1)
    8000398c:	01279763          	bne	a5,s2,8000399a <namex+0xf0>
    path++;
    80003990:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003992:	0004c783          	lbu	a5,0(s1)
    80003996:	ff278de3          	beq	a5,s2,80003990 <namex+0xe6>
  if(*path == 0)
    8000399a:	cb8d                	beqz	a5,800039cc <namex+0x122>
  while(*path != '/' && *path != 0)
    8000399c:	0004c783          	lbu	a5,0(s1)
    800039a0:	89a6                	mv	s3,s1
  len = path - s;
    800039a2:	4c81                	li	s9,0
    800039a4:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800039a6:	01278963          	beq	a5,s2,800039b8 <namex+0x10e>
    800039aa:	d3d9                	beqz	a5,80003930 <namex+0x86>
    path++;
    800039ac:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800039ae:	0009c783          	lbu	a5,0(s3)
    800039b2:	ff279ce3          	bne	a5,s2,800039aa <namex+0x100>
    800039b6:	bfad                	j	80003930 <namex+0x86>
    memmove(name, s, len);
    800039b8:	2601                	sext.w	a2,a2
    800039ba:	85a6                	mv	a1,s1
    800039bc:	8556                	mv	a0,s5
    800039be:	b40fd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    800039c2:	9cd6                	add	s9,s9,s5
    800039c4:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800039c8:	84ce                	mv	s1,s3
    800039ca:	bfbd                	j	80003948 <namex+0x9e>
  if(nameiparent){
    800039cc:	f20b0be3          	beqz	s6,80003902 <namex+0x58>
    iput(ip);
    800039d0:	8552                	mv	a0,s4
    800039d2:	a0fff0ef          	jal	800033e0 <iput>
    return 0;
    800039d6:	4a01                	li	s4,0
    800039d8:	b72d                	j	80003902 <namex+0x58>

00000000800039da <dirlink>:
{
    800039da:	7139                	addi	sp,sp,-64
    800039dc:	fc06                	sd	ra,56(sp)
    800039de:	f822                	sd	s0,48(sp)
    800039e0:	f04a                	sd	s2,32(sp)
    800039e2:	ec4e                	sd	s3,24(sp)
    800039e4:	e852                	sd	s4,16(sp)
    800039e6:	0080                	addi	s0,sp,64
    800039e8:	892a                	mv	s2,a0
    800039ea:	8a2e                	mv	s4,a1
    800039ec:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800039ee:	4601                	li	a2,0
    800039f0:	e1fff0ef          	jal	8000380e <dirlookup>
    800039f4:	e535                	bnez	a0,80003a60 <dirlink+0x86>
    800039f6:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039f8:	04c92483          	lw	s1,76(s2)
    800039fc:	c48d                	beqz	s1,80003a26 <dirlink+0x4c>
    800039fe:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a00:	4741                	li	a4,16
    80003a02:	86a6                	mv	a3,s1
    80003a04:	fc040613          	addi	a2,s0,-64
    80003a08:	4581                	li	a1,0
    80003a0a:	854a                	mv	a0,s2
    80003a0c:	be3ff0ef          	jal	800035ee <readi>
    80003a10:	47c1                	li	a5,16
    80003a12:	04f51b63          	bne	a0,a5,80003a68 <dirlink+0x8e>
    if(de.inum == 0)
    80003a16:	fc045783          	lhu	a5,-64(s0)
    80003a1a:	c791                	beqz	a5,80003a26 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a1c:	24c1                	addiw	s1,s1,16
    80003a1e:	04c92783          	lw	a5,76(s2)
    80003a22:	fcf4efe3          	bltu	s1,a5,80003a00 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003a26:	4639                	li	a2,14
    80003a28:	85d2                	mv	a1,s4
    80003a2a:	fc240513          	addi	a0,s0,-62
    80003a2e:	b76fd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003a32:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a36:	4741                	li	a4,16
    80003a38:	86a6                	mv	a3,s1
    80003a3a:	fc040613          	addi	a2,s0,-64
    80003a3e:	4581                	li	a1,0
    80003a40:	854a                	mv	a0,s2
    80003a42:	ca9ff0ef          	jal	800036ea <writei>
    80003a46:	1541                	addi	a0,a0,-16
    80003a48:	00a03533          	snez	a0,a0
    80003a4c:	40a00533          	neg	a0,a0
    80003a50:	74a2                	ld	s1,40(sp)
}
    80003a52:	70e2                	ld	ra,56(sp)
    80003a54:	7442                	ld	s0,48(sp)
    80003a56:	7902                	ld	s2,32(sp)
    80003a58:	69e2                	ld	s3,24(sp)
    80003a5a:	6a42                	ld	s4,16(sp)
    80003a5c:	6121                	addi	sp,sp,64
    80003a5e:	8082                	ret
    iput(ip);
    80003a60:	981ff0ef          	jal	800033e0 <iput>
    return -1;
    80003a64:	557d                	li	a0,-1
    80003a66:	b7f5                	j	80003a52 <dirlink+0x78>
      panic("dirlink read");
    80003a68:	00004517          	auipc	a0,0x4
    80003a6c:	a8850513          	addi	a0,a0,-1400 # 800074f0 <etext+0x4f0>
    80003a70:	d71fc0ef          	jal	800007e0 <panic>

0000000080003a74 <namei>:

struct inode*
namei(char *path)
{
    80003a74:	1101                	addi	sp,sp,-32
    80003a76:	ec06                	sd	ra,24(sp)
    80003a78:	e822                	sd	s0,16(sp)
    80003a7a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003a7c:	fe040613          	addi	a2,s0,-32
    80003a80:	4581                	li	a1,0
    80003a82:	e29ff0ef          	jal	800038aa <namex>
}
    80003a86:	60e2                	ld	ra,24(sp)
    80003a88:	6442                	ld	s0,16(sp)
    80003a8a:	6105                	addi	sp,sp,32
    80003a8c:	8082                	ret

0000000080003a8e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003a8e:	1141                	addi	sp,sp,-16
    80003a90:	e406                	sd	ra,8(sp)
    80003a92:	e022                	sd	s0,0(sp)
    80003a94:	0800                	addi	s0,sp,16
    80003a96:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003a98:	4585                	li	a1,1
    80003a9a:	e11ff0ef          	jal	800038aa <namex>
}
    80003a9e:	60a2                	ld	ra,8(sp)
    80003aa0:	6402                	ld	s0,0(sp)
    80003aa2:	0141                	addi	sp,sp,16
    80003aa4:	8082                	ret

0000000080003aa6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003aa6:	1101                	addi	sp,sp,-32
    80003aa8:	ec06                	sd	ra,24(sp)
    80003aaa:	e822                	sd	s0,16(sp)
    80003aac:	e426                	sd	s1,8(sp)
    80003aae:	e04a                	sd	s2,0(sp)
    80003ab0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ab2:	0001c917          	auipc	s2,0x1c
    80003ab6:	0b690913          	addi	s2,s2,182 # 8001fb68 <log>
    80003aba:	01892583          	lw	a1,24(s2)
    80003abe:	02492503          	lw	a0,36(s2)
    80003ac2:	8d0ff0ef          	jal	80002b92 <bread>
    80003ac6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003ac8:	02892603          	lw	a2,40(s2)
    80003acc:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ace:	00c05f63          	blez	a2,80003aec <write_head+0x46>
    80003ad2:	0001c717          	auipc	a4,0x1c
    80003ad6:	0c270713          	addi	a4,a4,194 # 8001fb94 <log+0x2c>
    80003ada:	87aa                	mv	a5,a0
    80003adc:	060a                	slli	a2,a2,0x2
    80003ade:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003ae0:	4314                	lw	a3,0(a4)
    80003ae2:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003ae4:	0711                	addi	a4,a4,4
    80003ae6:	0791                	addi	a5,a5,4
    80003ae8:	fec79ce3          	bne	a5,a2,80003ae0 <write_head+0x3a>
  }
  bwrite(buf);
    80003aec:	8526                	mv	a0,s1
    80003aee:	97aff0ef          	jal	80002c68 <bwrite>
  brelse(buf);
    80003af2:	8526                	mv	a0,s1
    80003af4:	9a6ff0ef          	jal	80002c9a <brelse>
}
    80003af8:	60e2                	ld	ra,24(sp)
    80003afa:	6442                	ld	s0,16(sp)
    80003afc:	64a2                	ld	s1,8(sp)
    80003afe:	6902                	ld	s2,0(sp)
    80003b00:	6105                	addi	sp,sp,32
    80003b02:	8082                	ret

0000000080003b04 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b04:	0001c797          	auipc	a5,0x1c
    80003b08:	08c7a783          	lw	a5,140(a5) # 8001fb90 <log+0x28>
    80003b0c:	0af05e63          	blez	a5,80003bc8 <install_trans+0xc4>
{
    80003b10:	715d                	addi	sp,sp,-80
    80003b12:	e486                	sd	ra,72(sp)
    80003b14:	e0a2                	sd	s0,64(sp)
    80003b16:	fc26                	sd	s1,56(sp)
    80003b18:	f84a                	sd	s2,48(sp)
    80003b1a:	f44e                	sd	s3,40(sp)
    80003b1c:	f052                	sd	s4,32(sp)
    80003b1e:	ec56                	sd	s5,24(sp)
    80003b20:	e85a                	sd	s6,16(sp)
    80003b22:	e45e                	sd	s7,8(sp)
    80003b24:	0880                	addi	s0,sp,80
    80003b26:	8b2a                	mv	s6,a0
    80003b28:	0001ca97          	auipc	s5,0x1c
    80003b2c:	06ca8a93          	addi	s5,s5,108 # 8001fb94 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b30:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b32:	00004b97          	auipc	s7,0x4
    80003b36:	9ceb8b93          	addi	s7,s7,-1586 # 80007500 <etext+0x500>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b3a:	0001ca17          	auipc	s4,0x1c
    80003b3e:	02ea0a13          	addi	s4,s4,46 # 8001fb68 <log>
    80003b42:	a025                	j	80003b6a <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b44:	000aa603          	lw	a2,0(s5)
    80003b48:	85ce                	mv	a1,s3
    80003b4a:	855e                	mv	a0,s7
    80003b4c:	9affc0ef          	jal	800004fa <printf>
    80003b50:	a839                	j	80003b6e <install_trans+0x6a>
    brelse(lbuf);
    80003b52:	854a                	mv	a0,s2
    80003b54:	946ff0ef          	jal	80002c9a <brelse>
    brelse(dbuf);
    80003b58:	8526                	mv	a0,s1
    80003b5a:	940ff0ef          	jal	80002c9a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b5e:	2985                	addiw	s3,s3,1
    80003b60:	0a91                	addi	s5,s5,4
    80003b62:	028a2783          	lw	a5,40(s4)
    80003b66:	04f9d663          	bge	s3,a5,80003bb2 <install_trans+0xae>
    if(recovering) {
    80003b6a:	fc0b1de3          	bnez	s6,80003b44 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b6e:	018a2583          	lw	a1,24(s4)
    80003b72:	013585bb          	addw	a1,a1,s3
    80003b76:	2585                	addiw	a1,a1,1
    80003b78:	024a2503          	lw	a0,36(s4)
    80003b7c:	816ff0ef          	jal	80002b92 <bread>
    80003b80:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003b82:	000aa583          	lw	a1,0(s5)
    80003b86:	024a2503          	lw	a0,36(s4)
    80003b8a:	808ff0ef          	jal	80002b92 <bread>
    80003b8e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003b90:	40000613          	li	a2,1024
    80003b94:	05890593          	addi	a1,s2,88
    80003b98:	05850513          	addi	a0,a0,88
    80003b9c:	962fd0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003ba0:	8526                	mv	a0,s1
    80003ba2:	8c6ff0ef          	jal	80002c68 <bwrite>
    if(recovering == 0)
    80003ba6:	fa0b16e3          	bnez	s6,80003b52 <install_trans+0x4e>
      bunpin(dbuf);
    80003baa:	8526                	mv	a0,s1
    80003bac:	9aaff0ef          	jal	80002d56 <bunpin>
    80003bb0:	b74d                	j	80003b52 <install_trans+0x4e>
}
    80003bb2:	60a6                	ld	ra,72(sp)
    80003bb4:	6406                	ld	s0,64(sp)
    80003bb6:	74e2                	ld	s1,56(sp)
    80003bb8:	7942                	ld	s2,48(sp)
    80003bba:	79a2                	ld	s3,40(sp)
    80003bbc:	7a02                	ld	s4,32(sp)
    80003bbe:	6ae2                	ld	s5,24(sp)
    80003bc0:	6b42                	ld	s6,16(sp)
    80003bc2:	6ba2                	ld	s7,8(sp)
    80003bc4:	6161                	addi	sp,sp,80
    80003bc6:	8082                	ret
    80003bc8:	8082                	ret

0000000080003bca <initlog>:
{
    80003bca:	7179                	addi	sp,sp,-48
    80003bcc:	f406                	sd	ra,40(sp)
    80003bce:	f022                	sd	s0,32(sp)
    80003bd0:	ec26                	sd	s1,24(sp)
    80003bd2:	e84a                	sd	s2,16(sp)
    80003bd4:	e44e                	sd	s3,8(sp)
    80003bd6:	1800                	addi	s0,sp,48
    80003bd8:	892a                	mv	s2,a0
    80003bda:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003bdc:	0001c497          	auipc	s1,0x1c
    80003be0:	f8c48493          	addi	s1,s1,-116 # 8001fb68 <log>
    80003be4:	00004597          	auipc	a1,0x4
    80003be8:	93c58593          	addi	a1,a1,-1732 # 80007520 <etext+0x520>
    80003bec:	8526                	mv	a0,s1
    80003bee:	f61fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003bf2:	0149a583          	lw	a1,20(s3)
    80003bf6:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003bf8:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003bfc:	854a                	mv	a0,s2
    80003bfe:	f95fe0ef          	jal	80002b92 <bread>
  log.lh.n = lh->n;
    80003c02:	4d30                	lw	a2,88(a0)
    80003c04:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003c06:	00c05f63          	blez	a2,80003c24 <initlog+0x5a>
    80003c0a:	87aa                	mv	a5,a0
    80003c0c:	0001c717          	auipc	a4,0x1c
    80003c10:	f8870713          	addi	a4,a4,-120 # 8001fb94 <log+0x2c>
    80003c14:	060a                	slli	a2,a2,0x2
    80003c16:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003c18:	4ff4                	lw	a3,92(a5)
    80003c1a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c1c:	0791                	addi	a5,a5,4
    80003c1e:	0711                	addi	a4,a4,4
    80003c20:	fec79ce3          	bne	a5,a2,80003c18 <initlog+0x4e>
  brelse(buf);
    80003c24:	876ff0ef          	jal	80002c9a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c28:	4505                	li	a0,1
    80003c2a:	edbff0ef          	jal	80003b04 <install_trans>
  log.lh.n = 0;
    80003c2e:	0001c797          	auipc	a5,0x1c
    80003c32:	f607a123          	sw	zero,-158(a5) # 8001fb90 <log+0x28>
  write_head(); // clear the log
    80003c36:	e71ff0ef          	jal	80003aa6 <write_head>
}
    80003c3a:	70a2                	ld	ra,40(sp)
    80003c3c:	7402                	ld	s0,32(sp)
    80003c3e:	64e2                	ld	s1,24(sp)
    80003c40:	6942                	ld	s2,16(sp)
    80003c42:	69a2                	ld	s3,8(sp)
    80003c44:	6145                	addi	sp,sp,48
    80003c46:	8082                	ret

0000000080003c48 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c48:	1101                	addi	sp,sp,-32
    80003c4a:	ec06                	sd	ra,24(sp)
    80003c4c:	e822                	sd	s0,16(sp)
    80003c4e:	e426                	sd	s1,8(sp)
    80003c50:	e04a                	sd	s2,0(sp)
    80003c52:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003c54:	0001c517          	auipc	a0,0x1c
    80003c58:	f1450513          	addi	a0,a0,-236 # 8001fb68 <log>
    80003c5c:	f73fc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003c60:	0001c497          	auipc	s1,0x1c
    80003c64:	f0848493          	addi	s1,s1,-248 # 8001fb68 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003c68:	4979                	li	s2,30
    80003c6a:	a029                	j	80003c74 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003c6c:	85a6                	mv	a1,s1
    80003c6e:	8526                	mv	a0,s1
    80003c70:	a74fe0ef          	jal	80001ee4 <sleep>
    if(log.committing){
    80003c74:	509c                	lw	a5,32(s1)
    80003c76:	fbfd                	bnez	a5,80003c6c <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003c78:	4cd8                	lw	a4,28(s1)
    80003c7a:	2705                	addiw	a4,a4,1
    80003c7c:	0027179b          	slliw	a5,a4,0x2
    80003c80:	9fb9                	addw	a5,a5,a4
    80003c82:	0017979b          	slliw	a5,a5,0x1
    80003c86:	5494                	lw	a3,40(s1)
    80003c88:	9fb5                	addw	a5,a5,a3
    80003c8a:	00f95763          	bge	s2,a5,80003c98 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003c8e:	85a6                	mv	a1,s1
    80003c90:	8526                	mv	a0,s1
    80003c92:	a52fe0ef          	jal	80001ee4 <sleep>
    80003c96:	bff9                	j	80003c74 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003c98:	0001c517          	auipc	a0,0x1c
    80003c9c:	ed050513          	addi	a0,a0,-304 # 8001fb68 <log>
    80003ca0:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003ca2:	fc5fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003ca6:	60e2                	ld	ra,24(sp)
    80003ca8:	6442                	ld	s0,16(sp)
    80003caa:	64a2                	ld	s1,8(sp)
    80003cac:	6902                	ld	s2,0(sp)
    80003cae:	6105                	addi	sp,sp,32
    80003cb0:	8082                	ret

0000000080003cb2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003cb2:	7139                	addi	sp,sp,-64
    80003cb4:	fc06                	sd	ra,56(sp)
    80003cb6:	f822                	sd	s0,48(sp)
    80003cb8:	f426                	sd	s1,40(sp)
    80003cba:	f04a                	sd	s2,32(sp)
    80003cbc:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003cbe:	0001c497          	auipc	s1,0x1c
    80003cc2:	eaa48493          	addi	s1,s1,-342 # 8001fb68 <log>
    80003cc6:	8526                	mv	a0,s1
    80003cc8:	f07fc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003ccc:	4cdc                	lw	a5,28(s1)
    80003cce:	37fd                	addiw	a5,a5,-1
    80003cd0:	0007891b          	sext.w	s2,a5
    80003cd4:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003cd6:	509c                	lw	a5,32(s1)
    80003cd8:	ef9d                	bnez	a5,80003d16 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003cda:	04091763          	bnez	s2,80003d28 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003cde:	0001c497          	auipc	s1,0x1c
    80003ce2:	e8a48493          	addi	s1,s1,-374 # 8001fb68 <log>
    80003ce6:	4785                	li	a5,1
    80003ce8:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003cea:	8526                	mv	a0,s1
    80003cec:	f7bfc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003cf0:	549c                	lw	a5,40(s1)
    80003cf2:	04f04b63          	bgtz	a5,80003d48 <end_op+0x96>
    acquire(&log.lock);
    80003cf6:	0001c497          	auipc	s1,0x1c
    80003cfa:	e7248493          	addi	s1,s1,-398 # 8001fb68 <log>
    80003cfe:	8526                	mv	a0,s1
    80003d00:	ecffc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003d04:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003d08:	8526                	mv	a0,s1
    80003d0a:	a26fe0ef          	jal	80001f30 <wakeup>
    release(&log.lock);
    80003d0e:	8526                	mv	a0,s1
    80003d10:	f57fc0ef          	jal	80000c66 <release>
}
    80003d14:	a025                	j	80003d3c <end_op+0x8a>
    80003d16:	ec4e                	sd	s3,24(sp)
    80003d18:	e852                	sd	s4,16(sp)
    80003d1a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003d1c:	00004517          	auipc	a0,0x4
    80003d20:	80c50513          	addi	a0,a0,-2036 # 80007528 <etext+0x528>
    80003d24:	abdfc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003d28:	0001c497          	auipc	s1,0x1c
    80003d2c:	e4048493          	addi	s1,s1,-448 # 8001fb68 <log>
    80003d30:	8526                	mv	a0,s1
    80003d32:	9fefe0ef          	jal	80001f30 <wakeup>
  release(&log.lock);
    80003d36:	8526                	mv	a0,s1
    80003d38:	f2ffc0ef          	jal	80000c66 <release>
}
    80003d3c:	70e2                	ld	ra,56(sp)
    80003d3e:	7442                	ld	s0,48(sp)
    80003d40:	74a2                	ld	s1,40(sp)
    80003d42:	7902                	ld	s2,32(sp)
    80003d44:	6121                	addi	sp,sp,64
    80003d46:	8082                	ret
    80003d48:	ec4e                	sd	s3,24(sp)
    80003d4a:	e852                	sd	s4,16(sp)
    80003d4c:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d4e:	0001ca97          	auipc	s5,0x1c
    80003d52:	e46a8a93          	addi	s5,s5,-442 # 8001fb94 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003d56:	0001ca17          	auipc	s4,0x1c
    80003d5a:	e12a0a13          	addi	s4,s4,-494 # 8001fb68 <log>
    80003d5e:	018a2583          	lw	a1,24(s4)
    80003d62:	012585bb          	addw	a1,a1,s2
    80003d66:	2585                	addiw	a1,a1,1
    80003d68:	024a2503          	lw	a0,36(s4)
    80003d6c:	e27fe0ef          	jal	80002b92 <bread>
    80003d70:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003d72:	000aa583          	lw	a1,0(s5)
    80003d76:	024a2503          	lw	a0,36(s4)
    80003d7a:	e19fe0ef          	jal	80002b92 <bread>
    80003d7e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003d80:	40000613          	li	a2,1024
    80003d84:	05850593          	addi	a1,a0,88
    80003d88:	05848513          	addi	a0,s1,88
    80003d8c:	f73fc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003d90:	8526                	mv	a0,s1
    80003d92:	ed7fe0ef          	jal	80002c68 <bwrite>
    brelse(from);
    80003d96:	854e                	mv	a0,s3
    80003d98:	f03fe0ef          	jal	80002c9a <brelse>
    brelse(to);
    80003d9c:	8526                	mv	a0,s1
    80003d9e:	efdfe0ef          	jal	80002c9a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003da2:	2905                	addiw	s2,s2,1
    80003da4:	0a91                	addi	s5,s5,4
    80003da6:	028a2783          	lw	a5,40(s4)
    80003daa:	faf94ae3          	blt	s2,a5,80003d5e <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003dae:	cf9ff0ef          	jal	80003aa6 <write_head>
    install_trans(0); // Now install writes to home locations
    80003db2:	4501                	li	a0,0
    80003db4:	d51ff0ef          	jal	80003b04 <install_trans>
    log.lh.n = 0;
    80003db8:	0001c797          	auipc	a5,0x1c
    80003dbc:	dc07ac23          	sw	zero,-552(a5) # 8001fb90 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003dc0:	ce7ff0ef          	jal	80003aa6 <write_head>
    80003dc4:	69e2                	ld	s3,24(sp)
    80003dc6:	6a42                	ld	s4,16(sp)
    80003dc8:	6aa2                	ld	s5,8(sp)
    80003dca:	b735                	j	80003cf6 <end_op+0x44>

0000000080003dcc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003dcc:	1101                	addi	sp,sp,-32
    80003dce:	ec06                	sd	ra,24(sp)
    80003dd0:	e822                	sd	s0,16(sp)
    80003dd2:	e426                	sd	s1,8(sp)
    80003dd4:	e04a                	sd	s2,0(sp)
    80003dd6:	1000                	addi	s0,sp,32
    80003dd8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003dda:	0001c917          	auipc	s2,0x1c
    80003dde:	d8e90913          	addi	s2,s2,-626 # 8001fb68 <log>
    80003de2:	854a                	mv	a0,s2
    80003de4:	debfc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003de8:	02892603          	lw	a2,40(s2)
    80003dec:	47f5                	li	a5,29
    80003dee:	04c7cc63          	blt	a5,a2,80003e46 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003df2:	0001c797          	auipc	a5,0x1c
    80003df6:	d927a783          	lw	a5,-622(a5) # 8001fb84 <log+0x1c>
    80003dfa:	04f05c63          	blez	a5,80003e52 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003dfe:	4781                	li	a5,0
    80003e00:	04c05f63          	blez	a2,80003e5e <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e04:	44cc                	lw	a1,12(s1)
    80003e06:	0001c717          	auipc	a4,0x1c
    80003e0a:	d8e70713          	addi	a4,a4,-626 # 8001fb94 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003e0e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e10:	4314                	lw	a3,0(a4)
    80003e12:	04b68663          	beq	a3,a1,80003e5e <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003e16:	2785                	addiw	a5,a5,1
    80003e18:	0711                	addi	a4,a4,4
    80003e1a:	fef61be3          	bne	a2,a5,80003e10 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e1e:	0621                	addi	a2,a2,8
    80003e20:	060a                	slli	a2,a2,0x2
    80003e22:	0001c797          	auipc	a5,0x1c
    80003e26:	d4678793          	addi	a5,a5,-698 # 8001fb68 <log>
    80003e2a:	97b2                	add	a5,a5,a2
    80003e2c:	44d8                	lw	a4,12(s1)
    80003e2e:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003e30:	8526                	mv	a0,s1
    80003e32:	ef1fe0ef          	jal	80002d22 <bpin>
    log.lh.n++;
    80003e36:	0001c717          	auipc	a4,0x1c
    80003e3a:	d3270713          	addi	a4,a4,-718 # 8001fb68 <log>
    80003e3e:	571c                	lw	a5,40(a4)
    80003e40:	2785                	addiw	a5,a5,1
    80003e42:	d71c                	sw	a5,40(a4)
    80003e44:	a80d                	j	80003e76 <log_write+0xaa>
    panic("too big a transaction");
    80003e46:	00003517          	auipc	a0,0x3
    80003e4a:	6f250513          	addi	a0,a0,1778 # 80007538 <etext+0x538>
    80003e4e:	993fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80003e52:	00003517          	auipc	a0,0x3
    80003e56:	6fe50513          	addi	a0,a0,1790 # 80007550 <etext+0x550>
    80003e5a:	987fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80003e5e:	00878693          	addi	a3,a5,8
    80003e62:	068a                	slli	a3,a3,0x2
    80003e64:	0001c717          	auipc	a4,0x1c
    80003e68:	d0470713          	addi	a4,a4,-764 # 8001fb68 <log>
    80003e6c:	9736                	add	a4,a4,a3
    80003e6e:	44d4                	lw	a3,12(s1)
    80003e70:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003e72:	faf60fe3          	beq	a2,a5,80003e30 <log_write+0x64>
  }
  release(&log.lock);
    80003e76:	0001c517          	auipc	a0,0x1c
    80003e7a:	cf250513          	addi	a0,a0,-782 # 8001fb68 <log>
    80003e7e:	de9fc0ef          	jal	80000c66 <release>
}
    80003e82:	60e2                	ld	ra,24(sp)
    80003e84:	6442                	ld	s0,16(sp)
    80003e86:	64a2                	ld	s1,8(sp)
    80003e88:	6902                	ld	s2,0(sp)
    80003e8a:	6105                	addi	sp,sp,32
    80003e8c:	8082                	ret

0000000080003e8e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003e8e:	1101                	addi	sp,sp,-32
    80003e90:	ec06                	sd	ra,24(sp)
    80003e92:	e822                	sd	s0,16(sp)
    80003e94:	e426                	sd	s1,8(sp)
    80003e96:	e04a                	sd	s2,0(sp)
    80003e98:	1000                	addi	s0,sp,32
    80003e9a:	84aa                	mv	s1,a0
    80003e9c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003e9e:	00003597          	auipc	a1,0x3
    80003ea2:	6d258593          	addi	a1,a1,1746 # 80007570 <etext+0x570>
    80003ea6:	0521                	addi	a0,a0,8
    80003ea8:	ca7fc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80003eac:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003eb0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003eb4:	0204a423          	sw	zero,40(s1)
}
    80003eb8:	60e2                	ld	ra,24(sp)
    80003eba:	6442                	ld	s0,16(sp)
    80003ebc:	64a2                	ld	s1,8(sp)
    80003ebe:	6902                	ld	s2,0(sp)
    80003ec0:	6105                	addi	sp,sp,32
    80003ec2:	8082                	ret

0000000080003ec4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003ec4:	1101                	addi	sp,sp,-32
    80003ec6:	ec06                	sd	ra,24(sp)
    80003ec8:	e822                	sd	s0,16(sp)
    80003eca:	e426                	sd	s1,8(sp)
    80003ecc:	e04a                	sd	s2,0(sp)
    80003ece:	1000                	addi	s0,sp,32
    80003ed0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003ed2:	00850913          	addi	s2,a0,8
    80003ed6:	854a                	mv	a0,s2
    80003ed8:	cf7fc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80003edc:	409c                	lw	a5,0(s1)
    80003ede:	c799                	beqz	a5,80003eec <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003ee0:	85ca                	mv	a1,s2
    80003ee2:	8526                	mv	a0,s1
    80003ee4:	800fe0ef          	jal	80001ee4 <sleep>
  while (lk->locked) {
    80003ee8:	409c                	lw	a5,0(s1)
    80003eea:	fbfd                	bnez	a5,80003ee0 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003eec:	4785                	li	a5,1
    80003eee:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003ef0:	9dffd0ef          	jal	800018ce <myproc>
    80003ef4:	591c                	lw	a5,48(a0)
    80003ef6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003ef8:	854a                	mv	a0,s2
    80003efa:	d6dfc0ef          	jal	80000c66 <release>
}
    80003efe:	60e2                	ld	ra,24(sp)
    80003f00:	6442                	ld	s0,16(sp)
    80003f02:	64a2                	ld	s1,8(sp)
    80003f04:	6902                	ld	s2,0(sp)
    80003f06:	6105                	addi	sp,sp,32
    80003f08:	8082                	ret

0000000080003f0a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003f0a:	1101                	addi	sp,sp,-32
    80003f0c:	ec06                	sd	ra,24(sp)
    80003f0e:	e822                	sd	s0,16(sp)
    80003f10:	e426                	sd	s1,8(sp)
    80003f12:	e04a                	sd	s2,0(sp)
    80003f14:	1000                	addi	s0,sp,32
    80003f16:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f18:	00850913          	addi	s2,a0,8
    80003f1c:	854a                	mv	a0,s2
    80003f1e:	cb1fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80003f22:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f26:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003f2a:	8526                	mv	a0,s1
    80003f2c:	804fe0ef          	jal	80001f30 <wakeup>
  release(&lk->lk);
    80003f30:	854a                	mv	a0,s2
    80003f32:	d35fc0ef          	jal	80000c66 <release>
}
    80003f36:	60e2                	ld	ra,24(sp)
    80003f38:	6442                	ld	s0,16(sp)
    80003f3a:	64a2                	ld	s1,8(sp)
    80003f3c:	6902                	ld	s2,0(sp)
    80003f3e:	6105                	addi	sp,sp,32
    80003f40:	8082                	ret

0000000080003f42 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003f42:	7179                	addi	sp,sp,-48
    80003f44:	f406                	sd	ra,40(sp)
    80003f46:	f022                	sd	s0,32(sp)
    80003f48:	ec26                	sd	s1,24(sp)
    80003f4a:	e84a                	sd	s2,16(sp)
    80003f4c:	1800                	addi	s0,sp,48
    80003f4e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003f50:	00850913          	addi	s2,a0,8
    80003f54:	854a                	mv	a0,s2
    80003f56:	c79fc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f5a:	409c                	lw	a5,0(s1)
    80003f5c:	ef81                	bnez	a5,80003f74 <holdingsleep+0x32>
    80003f5e:	4481                	li	s1,0
  release(&lk->lk);
    80003f60:	854a                	mv	a0,s2
    80003f62:	d05fc0ef          	jal	80000c66 <release>
  return r;
}
    80003f66:	8526                	mv	a0,s1
    80003f68:	70a2                	ld	ra,40(sp)
    80003f6a:	7402                	ld	s0,32(sp)
    80003f6c:	64e2                	ld	s1,24(sp)
    80003f6e:	6942                	ld	s2,16(sp)
    80003f70:	6145                	addi	sp,sp,48
    80003f72:	8082                	ret
    80003f74:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f76:	0284a983          	lw	s3,40(s1)
    80003f7a:	955fd0ef          	jal	800018ce <myproc>
    80003f7e:	5904                	lw	s1,48(a0)
    80003f80:	413484b3          	sub	s1,s1,s3
    80003f84:	0014b493          	seqz	s1,s1
    80003f88:	69a2                	ld	s3,8(sp)
    80003f8a:	bfd9                	j	80003f60 <holdingsleep+0x1e>

0000000080003f8c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003f8c:	1141                	addi	sp,sp,-16
    80003f8e:	e406                	sd	ra,8(sp)
    80003f90:	e022                	sd	s0,0(sp)
    80003f92:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003f94:	00003597          	auipc	a1,0x3
    80003f98:	5ec58593          	addi	a1,a1,1516 # 80007580 <etext+0x580>
    80003f9c:	0001c517          	auipc	a0,0x1c
    80003fa0:	d1450513          	addi	a0,a0,-748 # 8001fcb0 <ftable>
    80003fa4:	babfc0ef          	jal	80000b4e <initlock>
}
    80003fa8:	60a2                	ld	ra,8(sp)
    80003faa:	6402                	ld	s0,0(sp)
    80003fac:	0141                	addi	sp,sp,16
    80003fae:	8082                	ret

0000000080003fb0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003fb0:	1101                	addi	sp,sp,-32
    80003fb2:	ec06                	sd	ra,24(sp)
    80003fb4:	e822                	sd	s0,16(sp)
    80003fb6:	e426                	sd	s1,8(sp)
    80003fb8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003fba:	0001c517          	auipc	a0,0x1c
    80003fbe:	cf650513          	addi	a0,a0,-778 # 8001fcb0 <ftable>
    80003fc2:	c0dfc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003fc6:	0001c497          	auipc	s1,0x1c
    80003fca:	d0248493          	addi	s1,s1,-766 # 8001fcc8 <ftable+0x18>
    80003fce:	0001d717          	auipc	a4,0x1d
    80003fd2:	c9a70713          	addi	a4,a4,-870 # 80020c68 <disk>
    if(f->ref == 0){
    80003fd6:	40dc                	lw	a5,4(s1)
    80003fd8:	cf89                	beqz	a5,80003ff2 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003fda:	02848493          	addi	s1,s1,40
    80003fde:	fee49ce3          	bne	s1,a4,80003fd6 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003fe2:	0001c517          	auipc	a0,0x1c
    80003fe6:	cce50513          	addi	a0,a0,-818 # 8001fcb0 <ftable>
    80003fea:	c7dfc0ef          	jal	80000c66 <release>
  return 0;
    80003fee:	4481                	li	s1,0
    80003ff0:	a809                	j	80004002 <filealloc+0x52>
      f->ref = 1;
    80003ff2:	4785                	li	a5,1
    80003ff4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003ff6:	0001c517          	auipc	a0,0x1c
    80003ffa:	cba50513          	addi	a0,a0,-838 # 8001fcb0 <ftable>
    80003ffe:	c69fc0ef          	jal	80000c66 <release>
}
    80004002:	8526                	mv	a0,s1
    80004004:	60e2                	ld	ra,24(sp)
    80004006:	6442                	ld	s0,16(sp)
    80004008:	64a2                	ld	s1,8(sp)
    8000400a:	6105                	addi	sp,sp,32
    8000400c:	8082                	ret

000000008000400e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000400e:	1101                	addi	sp,sp,-32
    80004010:	ec06                	sd	ra,24(sp)
    80004012:	e822                	sd	s0,16(sp)
    80004014:	e426                	sd	s1,8(sp)
    80004016:	1000                	addi	s0,sp,32
    80004018:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000401a:	0001c517          	auipc	a0,0x1c
    8000401e:	c9650513          	addi	a0,a0,-874 # 8001fcb0 <ftable>
    80004022:	badfc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004026:	40dc                	lw	a5,4(s1)
    80004028:	02f05063          	blez	a5,80004048 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000402c:	2785                	addiw	a5,a5,1
    8000402e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004030:	0001c517          	auipc	a0,0x1c
    80004034:	c8050513          	addi	a0,a0,-896 # 8001fcb0 <ftable>
    80004038:	c2ffc0ef          	jal	80000c66 <release>
  return f;
}
    8000403c:	8526                	mv	a0,s1
    8000403e:	60e2                	ld	ra,24(sp)
    80004040:	6442                	ld	s0,16(sp)
    80004042:	64a2                	ld	s1,8(sp)
    80004044:	6105                	addi	sp,sp,32
    80004046:	8082                	ret
    panic("filedup");
    80004048:	00003517          	auipc	a0,0x3
    8000404c:	54050513          	addi	a0,a0,1344 # 80007588 <etext+0x588>
    80004050:	f90fc0ef          	jal	800007e0 <panic>

0000000080004054 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004054:	7139                	addi	sp,sp,-64
    80004056:	fc06                	sd	ra,56(sp)
    80004058:	f822                	sd	s0,48(sp)
    8000405a:	f426                	sd	s1,40(sp)
    8000405c:	0080                	addi	s0,sp,64
    8000405e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004060:	0001c517          	auipc	a0,0x1c
    80004064:	c5050513          	addi	a0,a0,-944 # 8001fcb0 <ftable>
    80004068:	b67fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    8000406c:	40dc                	lw	a5,4(s1)
    8000406e:	04f05a63          	blez	a5,800040c2 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004072:	37fd                	addiw	a5,a5,-1
    80004074:	0007871b          	sext.w	a4,a5
    80004078:	c0dc                	sw	a5,4(s1)
    8000407a:	04e04e63          	bgtz	a4,800040d6 <fileclose+0x82>
    8000407e:	f04a                	sd	s2,32(sp)
    80004080:	ec4e                	sd	s3,24(sp)
    80004082:	e852                	sd	s4,16(sp)
    80004084:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004086:	0004a903          	lw	s2,0(s1)
    8000408a:	0094ca83          	lbu	s5,9(s1)
    8000408e:	0104ba03          	ld	s4,16(s1)
    80004092:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004096:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000409a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000409e:	0001c517          	auipc	a0,0x1c
    800040a2:	c1250513          	addi	a0,a0,-1006 # 8001fcb0 <ftable>
    800040a6:	bc1fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    800040aa:	4785                	li	a5,1
    800040ac:	04f90063          	beq	s2,a5,800040ec <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800040b0:	3979                	addiw	s2,s2,-2
    800040b2:	4785                	li	a5,1
    800040b4:	0527f563          	bgeu	a5,s2,800040fe <fileclose+0xaa>
    800040b8:	7902                	ld	s2,32(sp)
    800040ba:	69e2                	ld	s3,24(sp)
    800040bc:	6a42                	ld	s4,16(sp)
    800040be:	6aa2                	ld	s5,8(sp)
    800040c0:	a00d                	j	800040e2 <fileclose+0x8e>
    800040c2:	f04a                	sd	s2,32(sp)
    800040c4:	ec4e                	sd	s3,24(sp)
    800040c6:	e852                	sd	s4,16(sp)
    800040c8:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800040ca:	00003517          	auipc	a0,0x3
    800040ce:	4c650513          	addi	a0,a0,1222 # 80007590 <etext+0x590>
    800040d2:	f0efc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    800040d6:	0001c517          	auipc	a0,0x1c
    800040da:	bda50513          	addi	a0,a0,-1062 # 8001fcb0 <ftable>
    800040de:	b89fc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800040e2:	70e2                	ld	ra,56(sp)
    800040e4:	7442                	ld	s0,48(sp)
    800040e6:	74a2                	ld	s1,40(sp)
    800040e8:	6121                	addi	sp,sp,64
    800040ea:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800040ec:	85d6                	mv	a1,s5
    800040ee:	8552                	mv	a0,s4
    800040f0:	336000ef          	jal	80004426 <pipeclose>
    800040f4:	7902                	ld	s2,32(sp)
    800040f6:	69e2                	ld	s3,24(sp)
    800040f8:	6a42                	ld	s4,16(sp)
    800040fa:	6aa2                	ld	s5,8(sp)
    800040fc:	b7dd                	j	800040e2 <fileclose+0x8e>
    begin_op();
    800040fe:	b4bff0ef          	jal	80003c48 <begin_op>
    iput(ff.ip);
    80004102:	854e                	mv	a0,s3
    80004104:	adcff0ef          	jal	800033e0 <iput>
    end_op();
    80004108:	babff0ef          	jal	80003cb2 <end_op>
    8000410c:	7902                	ld	s2,32(sp)
    8000410e:	69e2                	ld	s3,24(sp)
    80004110:	6a42                	ld	s4,16(sp)
    80004112:	6aa2                	ld	s5,8(sp)
    80004114:	b7f9                	j	800040e2 <fileclose+0x8e>

0000000080004116 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004116:	715d                	addi	sp,sp,-80
    80004118:	e486                	sd	ra,72(sp)
    8000411a:	e0a2                	sd	s0,64(sp)
    8000411c:	fc26                	sd	s1,56(sp)
    8000411e:	f44e                	sd	s3,40(sp)
    80004120:	0880                	addi	s0,sp,80
    80004122:	84aa                	mv	s1,a0
    80004124:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004126:	fa8fd0ef          	jal	800018ce <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000412a:	409c                	lw	a5,0(s1)
    8000412c:	37f9                	addiw	a5,a5,-2
    8000412e:	4705                	li	a4,1
    80004130:	04f76063          	bltu	a4,a5,80004170 <filestat+0x5a>
    80004134:	f84a                	sd	s2,48(sp)
    80004136:	892a                	mv	s2,a0
    ilock(f->ip);
    80004138:	6c88                	ld	a0,24(s1)
    8000413a:	924ff0ef          	jal	8000325e <ilock>
    stati(f->ip, &st);
    8000413e:	fb840593          	addi	a1,s0,-72
    80004142:	6c88                	ld	a0,24(s1)
    80004144:	c80ff0ef          	jal	800035c4 <stati>
    iunlock(f->ip);
    80004148:	6c88                	ld	a0,24(s1)
    8000414a:	9c2ff0ef          	jal	8000330c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000414e:	46e1                	li	a3,24
    80004150:	fb840613          	addi	a2,s0,-72
    80004154:	85ce                	mv	a1,s3
    80004156:	05093503          	ld	a0,80(s2)
    8000415a:	c88fd0ef          	jal	800015e2 <copyout>
    8000415e:	41f5551b          	sraiw	a0,a0,0x1f
    80004162:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004164:	60a6                	ld	ra,72(sp)
    80004166:	6406                	ld	s0,64(sp)
    80004168:	74e2                	ld	s1,56(sp)
    8000416a:	79a2                	ld	s3,40(sp)
    8000416c:	6161                	addi	sp,sp,80
    8000416e:	8082                	ret
  return -1;
    80004170:	557d                	li	a0,-1
    80004172:	bfcd                	j	80004164 <filestat+0x4e>

0000000080004174 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004174:	7179                	addi	sp,sp,-48
    80004176:	f406                	sd	ra,40(sp)
    80004178:	f022                	sd	s0,32(sp)
    8000417a:	e84a                	sd	s2,16(sp)
    8000417c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000417e:	00854783          	lbu	a5,8(a0)
    80004182:	cfd1                	beqz	a5,8000421e <fileread+0xaa>
    80004184:	ec26                	sd	s1,24(sp)
    80004186:	e44e                	sd	s3,8(sp)
    80004188:	84aa                	mv	s1,a0
    8000418a:	89ae                	mv	s3,a1
    8000418c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000418e:	411c                	lw	a5,0(a0)
    80004190:	4705                	li	a4,1
    80004192:	04e78363          	beq	a5,a4,800041d8 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004196:	470d                	li	a4,3
    80004198:	04e78763          	beq	a5,a4,800041e6 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000419c:	4709                	li	a4,2
    8000419e:	06e79a63          	bne	a5,a4,80004212 <fileread+0x9e>
    ilock(f->ip);
    800041a2:	6d08                	ld	a0,24(a0)
    800041a4:	8baff0ef          	jal	8000325e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800041a8:	874a                	mv	a4,s2
    800041aa:	5094                	lw	a3,32(s1)
    800041ac:	864e                	mv	a2,s3
    800041ae:	4585                	li	a1,1
    800041b0:	6c88                	ld	a0,24(s1)
    800041b2:	c3cff0ef          	jal	800035ee <readi>
    800041b6:	892a                	mv	s2,a0
    800041b8:	00a05563          	blez	a0,800041c2 <fileread+0x4e>
      f->off += r;
    800041bc:	509c                	lw	a5,32(s1)
    800041be:	9fa9                	addw	a5,a5,a0
    800041c0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800041c2:	6c88                	ld	a0,24(s1)
    800041c4:	948ff0ef          	jal	8000330c <iunlock>
    800041c8:	64e2                	ld	s1,24(sp)
    800041ca:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800041cc:	854a                	mv	a0,s2
    800041ce:	70a2                	ld	ra,40(sp)
    800041d0:	7402                	ld	s0,32(sp)
    800041d2:	6942                	ld	s2,16(sp)
    800041d4:	6145                	addi	sp,sp,48
    800041d6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800041d8:	6908                	ld	a0,16(a0)
    800041da:	388000ef          	jal	80004562 <piperead>
    800041de:	892a                	mv	s2,a0
    800041e0:	64e2                	ld	s1,24(sp)
    800041e2:	69a2                	ld	s3,8(sp)
    800041e4:	b7e5                	j	800041cc <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800041e6:	02451783          	lh	a5,36(a0)
    800041ea:	03079693          	slli	a3,a5,0x30
    800041ee:	92c1                	srli	a3,a3,0x30
    800041f0:	4725                	li	a4,9
    800041f2:	02d76863          	bltu	a4,a3,80004222 <fileread+0xae>
    800041f6:	0792                	slli	a5,a5,0x4
    800041f8:	0001c717          	auipc	a4,0x1c
    800041fc:	a1870713          	addi	a4,a4,-1512 # 8001fc10 <devsw>
    80004200:	97ba                	add	a5,a5,a4
    80004202:	639c                	ld	a5,0(a5)
    80004204:	c39d                	beqz	a5,8000422a <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004206:	4505                	li	a0,1
    80004208:	9782                	jalr	a5
    8000420a:	892a                	mv	s2,a0
    8000420c:	64e2                	ld	s1,24(sp)
    8000420e:	69a2                	ld	s3,8(sp)
    80004210:	bf75                	j	800041cc <fileread+0x58>
    panic("fileread");
    80004212:	00003517          	auipc	a0,0x3
    80004216:	38e50513          	addi	a0,a0,910 # 800075a0 <etext+0x5a0>
    8000421a:	dc6fc0ef          	jal	800007e0 <panic>
    return -1;
    8000421e:	597d                	li	s2,-1
    80004220:	b775                	j	800041cc <fileread+0x58>
      return -1;
    80004222:	597d                	li	s2,-1
    80004224:	64e2                	ld	s1,24(sp)
    80004226:	69a2                	ld	s3,8(sp)
    80004228:	b755                	j	800041cc <fileread+0x58>
    8000422a:	597d                	li	s2,-1
    8000422c:	64e2                	ld	s1,24(sp)
    8000422e:	69a2                	ld	s3,8(sp)
    80004230:	bf71                	j	800041cc <fileread+0x58>

0000000080004232 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004232:	00954783          	lbu	a5,9(a0)
    80004236:	10078b63          	beqz	a5,8000434c <filewrite+0x11a>
{
    8000423a:	715d                	addi	sp,sp,-80
    8000423c:	e486                	sd	ra,72(sp)
    8000423e:	e0a2                	sd	s0,64(sp)
    80004240:	f84a                	sd	s2,48(sp)
    80004242:	f052                	sd	s4,32(sp)
    80004244:	e85a                	sd	s6,16(sp)
    80004246:	0880                	addi	s0,sp,80
    80004248:	892a                	mv	s2,a0
    8000424a:	8b2e                	mv	s6,a1
    8000424c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000424e:	411c                	lw	a5,0(a0)
    80004250:	4705                	li	a4,1
    80004252:	02e78763          	beq	a5,a4,80004280 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004256:	470d                	li	a4,3
    80004258:	02e78863          	beq	a5,a4,80004288 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000425c:	4709                	li	a4,2
    8000425e:	0ce79c63          	bne	a5,a4,80004336 <filewrite+0x104>
    80004262:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004264:	0ac05863          	blez	a2,80004314 <filewrite+0xe2>
    80004268:	fc26                	sd	s1,56(sp)
    8000426a:	ec56                	sd	s5,24(sp)
    8000426c:	e45e                	sd	s7,8(sp)
    8000426e:	e062                	sd	s8,0(sp)
    int i = 0;
    80004270:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004272:	6b85                	lui	s7,0x1
    80004274:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004278:	6c05                	lui	s8,0x1
    8000427a:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000427e:	a8b5                	j	800042fa <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004280:	6908                	ld	a0,16(a0)
    80004282:	1fc000ef          	jal	8000447e <pipewrite>
    80004286:	a04d                	j	80004328 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004288:	02451783          	lh	a5,36(a0)
    8000428c:	03079693          	slli	a3,a5,0x30
    80004290:	92c1                	srli	a3,a3,0x30
    80004292:	4725                	li	a4,9
    80004294:	0ad76e63          	bltu	a4,a3,80004350 <filewrite+0x11e>
    80004298:	0792                	slli	a5,a5,0x4
    8000429a:	0001c717          	auipc	a4,0x1c
    8000429e:	97670713          	addi	a4,a4,-1674 # 8001fc10 <devsw>
    800042a2:	97ba                	add	a5,a5,a4
    800042a4:	679c                	ld	a5,8(a5)
    800042a6:	c7dd                	beqz	a5,80004354 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800042a8:	4505                	li	a0,1
    800042aa:	9782                	jalr	a5
    800042ac:	a8b5                	j	80004328 <filewrite+0xf6>
      if(n1 > max)
    800042ae:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800042b2:	997ff0ef          	jal	80003c48 <begin_op>
      ilock(f->ip);
    800042b6:	01893503          	ld	a0,24(s2)
    800042ba:	fa5fe0ef          	jal	8000325e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800042be:	8756                	mv	a4,s5
    800042c0:	02092683          	lw	a3,32(s2)
    800042c4:	01698633          	add	a2,s3,s6
    800042c8:	4585                	li	a1,1
    800042ca:	01893503          	ld	a0,24(s2)
    800042ce:	c1cff0ef          	jal	800036ea <writei>
    800042d2:	84aa                	mv	s1,a0
    800042d4:	00a05763          	blez	a0,800042e2 <filewrite+0xb0>
        f->off += r;
    800042d8:	02092783          	lw	a5,32(s2)
    800042dc:	9fa9                	addw	a5,a5,a0
    800042de:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800042e2:	01893503          	ld	a0,24(s2)
    800042e6:	826ff0ef          	jal	8000330c <iunlock>
      end_op();
    800042ea:	9c9ff0ef          	jal	80003cb2 <end_op>

      if(r != n1){
    800042ee:	029a9563          	bne	s5,s1,80004318 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800042f2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800042f6:	0149da63          	bge	s3,s4,8000430a <filewrite+0xd8>
      int n1 = n - i;
    800042fa:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800042fe:	0004879b          	sext.w	a5,s1
    80004302:	fafbd6e3          	bge	s7,a5,800042ae <filewrite+0x7c>
    80004306:	84e2                	mv	s1,s8
    80004308:	b75d                	j	800042ae <filewrite+0x7c>
    8000430a:	74e2                	ld	s1,56(sp)
    8000430c:	6ae2                	ld	s5,24(sp)
    8000430e:	6ba2                	ld	s7,8(sp)
    80004310:	6c02                	ld	s8,0(sp)
    80004312:	a039                	j	80004320 <filewrite+0xee>
    int i = 0;
    80004314:	4981                	li	s3,0
    80004316:	a029                	j	80004320 <filewrite+0xee>
    80004318:	74e2                	ld	s1,56(sp)
    8000431a:	6ae2                	ld	s5,24(sp)
    8000431c:	6ba2                	ld	s7,8(sp)
    8000431e:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004320:	033a1c63          	bne	s4,s3,80004358 <filewrite+0x126>
    80004324:	8552                	mv	a0,s4
    80004326:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004328:	60a6                	ld	ra,72(sp)
    8000432a:	6406                	ld	s0,64(sp)
    8000432c:	7942                	ld	s2,48(sp)
    8000432e:	7a02                	ld	s4,32(sp)
    80004330:	6b42                	ld	s6,16(sp)
    80004332:	6161                	addi	sp,sp,80
    80004334:	8082                	ret
    80004336:	fc26                	sd	s1,56(sp)
    80004338:	f44e                	sd	s3,40(sp)
    8000433a:	ec56                	sd	s5,24(sp)
    8000433c:	e45e                	sd	s7,8(sp)
    8000433e:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004340:	00003517          	auipc	a0,0x3
    80004344:	27050513          	addi	a0,a0,624 # 800075b0 <etext+0x5b0>
    80004348:	c98fc0ef          	jal	800007e0 <panic>
    return -1;
    8000434c:	557d                	li	a0,-1
}
    8000434e:	8082                	ret
      return -1;
    80004350:	557d                	li	a0,-1
    80004352:	bfd9                	j	80004328 <filewrite+0xf6>
    80004354:	557d                	li	a0,-1
    80004356:	bfc9                	j	80004328 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004358:	557d                	li	a0,-1
    8000435a:	79a2                	ld	s3,40(sp)
    8000435c:	b7f1                	j	80004328 <filewrite+0xf6>

000000008000435e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000435e:	7179                	addi	sp,sp,-48
    80004360:	f406                	sd	ra,40(sp)
    80004362:	f022                	sd	s0,32(sp)
    80004364:	ec26                	sd	s1,24(sp)
    80004366:	e052                	sd	s4,0(sp)
    80004368:	1800                	addi	s0,sp,48
    8000436a:	84aa                	mv	s1,a0
    8000436c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000436e:	0005b023          	sd	zero,0(a1)
    80004372:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004376:	c3bff0ef          	jal	80003fb0 <filealloc>
    8000437a:	e088                	sd	a0,0(s1)
    8000437c:	c549                	beqz	a0,80004406 <pipealloc+0xa8>
    8000437e:	c33ff0ef          	jal	80003fb0 <filealloc>
    80004382:	00aa3023          	sd	a0,0(s4)
    80004386:	cd25                	beqz	a0,800043fe <pipealloc+0xa0>
    80004388:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000438a:	f74fc0ef          	jal	80000afe <kalloc>
    8000438e:	892a                	mv	s2,a0
    80004390:	c12d                	beqz	a0,800043f2 <pipealloc+0x94>
    80004392:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004394:	4985                	li	s3,1
    80004396:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000439a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000439e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800043a2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800043a6:	00003597          	auipc	a1,0x3
    800043aa:	21a58593          	addi	a1,a1,538 # 800075c0 <etext+0x5c0>
    800043ae:	fa0fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    800043b2:	609c                	ld	a5,0(s1)
    800043b4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800043b8:	609c                	ld	a5,0(s1)
    800043ba:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800043be:	609c                	ld	a5,0(s1)
    800043c0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800043c4:	609c                	ld	a5,0(s1)
    800043c6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800043ca:	000a3783          	ld	a5,0(s4)
    800043ce:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800043d2:	000a3783          	ld	a5,0(s4)
    800043d6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800043da:	000a3783          	ld	a5,0(s4)
    800043de:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800043e2:	000a3783          	ld	a5,0(s4)
    800043e6:	0127b823          	sd	s2,16(a5)
  return 0;
    800043ea:	4501                	li	a0,0
    800043ec:	6942                	ld	s2,16(sp)
    800043ee:	69a2                	ld	s3,8(sp)
    800043f0:	a01d                	j	80004416 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800043f2:	6088                	ld	a0,0(s1)
    800043f4:	c119                	beqz	a0,800043fa <pipealloc+0x9c>
    800043f6:	6942                	ld	s2,16(sp)
    800043f8:	a029                	j	80004402 <pipealloc+0xa4>
    800043fa:	6942                	ld	s2,16(sp)
    800043fc:	a029                	j	80004406 <pipealloc+0xa8>
    800043fe:	6088                	ld	a0,0(s1)
    80004400:	c10d                	beqz	a0,80004422 <pipealloc+0xc4>
    fileclose(*f0);
    80004402:	c53ff0ef          	jal	80004054 <fileclose>
  if(*f1)
    80004406:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000440a:	557d                	li	a0,-1
  if(*f1)
    8000440c:	c789                	beqz	a5,80004416 <pipealloc+0xb8>
    fileclose(*f1);
    8000440e:	853e                	mv	a0,a5
    80004410:	c45ff0ef          	jal	80004054 <fileclose>
  return -1;
    80004414:	557d                	li	a0,-1
}
    80004416:	70a2                	ld	ra,40(sp)
    80004418:	7402                	ld	s0,32(sp)
    8000441a:	64e2                	ld	s1,24(sp)
    8000441c:	6a02                	ld	s4,0(sp)
    8000441e:	6145                	addi	sp,sp,48
    80004420:	8082                	ret
  return -1;
    80004422:	557d                	li	a0,-1
    80004424:	bfcd                	j	80004416 <pipealloc+0xb8>

0000000080004426 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004426:	1101                	addi	sp,sp,-32
    80004428:	ec06                	sd	ra,24(sp)
    8000442a:	e822                	sd	s0,16(sp)
    8000442c:	e426                	sd	s1,8(sp)
    8000442e:	e04a                	sd	s2,0(sp)
    80004430:	1000                	addi	s0,sp,32
    80004432:	84aa                	mv	s1,a0
    80004434:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004436:	f98fc0ef          	jal	80000bce <acquire>
  if(writable){
    8000443a:	02090763          	beqz	s2,80004468 <pipeclose+0x42>
    pi->writeopen = 0;
    8000443e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004442:	21848513          	addi	a0,s1,536
    80004446:	aebfd0ef          	jal	80001f30 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000444a:	2204b783          	ld	a5,544(s1)
    8000444e:	e785                	bnez	a5,80004476 <pipeclose+0x50>
    release(&pi->lock);
    80004450:	8526                	mv	a0,s1
    80004452:	815fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    80004456:	8526                	mv	a0,s1
    80004458:	dc4fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    8000445c:	60e2                	ld	ra,24(sp)
    8000445e:	6442                	ld	s0,16(sp)
    80004460:	64a2                	ld	s1,8(sp)
    80004462:	6902                	ld	s2,0(sp)
    80004464:	6105                	addi	sp,sp,32
    80004466:	8082                	ret
    pi->readopen = 0;
    80004468:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000446c:	21c48513          	addi	a0,s1,540
    80004470:	ac1fd0ef          	jal	80001f30 <wakeup>
    80004474:	bfd9                	j	8000444a <pipeclose+0x24>
    release(&pi->lock);
    80004476:	8526                	mv	a0,s1
    80004478:	feefc0ef          	jal	80000c66 <release>
}
    8000447c:	b7c5                	j	8000445c <pipeclose+0x36>

000000008000447e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000447e:	711d                	addi	sp,sp,-96
    80004480:	ec86                	sd	ra,88(sp)
    80004482:	e8a2                	sd	s0,80(sp)
    80004484:	e4a6                	sd	s1,72(sp)
    80004486:	e0ca                	sd	s2,64(sp)
    80004488:	fc4e                	sd	s3,56(sp)
    8000448a:	f852                	sd	s4,48(sp)
    8000448c:	f456                	sd	s5,40(sp)
    8000448e:	1080                	addi	s0,sp,96
    80004490:	84aa                	mv	s1,a0
    80004492:	8aae                	mv	s5,a1
    80004494:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004496:	c38fd0ef          	jal	800018ce <myproc>
    8000449a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000449c:	8526                	mv	a0,s1
    8000449e:	f30fc0ef          	jal	80000bce <acquire>
  while(i < n){
    800044a2:	0b405a63          	blez	s4,80004556 <pipewrite+0xd8>
    800044a6:	f05a                	sd	s6,32(sp)
    800044a8:	ec5e                	sd	s7,24(sp)
    800044aa:	e862                	sd	s8,16(sp)
  int i = 0;
    800044ac:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800044ae:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800044b0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800044b4:	21c48b93          	addi	s7,s1,540
    800044b8:	a81d                	j	800044ee <pipewrite+0x70>
      release(&pi->lock);
    800044ba:	8526                	mv	a0,s1
    800044bc:	faafc0ef          	jal	80000c66 <release>
      return -1;
    800044c0:	597d                	li	s2,-1
    800044c2:	7b02                	ld	s6,32(sp)
    800044c4:	6be2                	ld	s7,24(sp)
    800044c6:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800044c8:	854a                	mv	a0,s2
    800044ca:	60e6                	ld	ra,88(sp)
    800044cc:	6446                	ld	s0,80(sp)
    800044ce:	64a6                	ld	s1,72(sp)
    800044d0:	6906                	ld	s2,64(sp)
    800044d2:	79e2                	ld	s3,56(sp)
    800044d4:	7a42                	ld	s4,48(sp)
    800044d6:	7aa2                	ld	s5,40(sp)
    800044d8:	6125                	addi	sp,sp,96
    800044da:	8082                	ret
      wakeup(&pi->nread);
    800044dc:	8562                	mv	a0,s8
    800044de:	a53fd0ef          	jal	80001f30 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800044e2:	85a6                	mv	a1,s1
    800044e4:	855e                	mv	a0,s7
    800044e6:	9fffd0ef          	jal	80001ee4 <sleep>
  while(i < n){
    800044ea:	05495b63          	bge	s2,s4,80004540 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800044ee:	2204a783          	lw	a5,544(s1)
    800044f2:	d7e1                	beqz	a5,800044ba <pipewrite+0x3c>
    800044f4:	854e                	mv	a0,s3
    800044f6:	c27fd0ef          	jal	8000211c <killed>
    800044fa:	f161                	bnez	a0,800044ba <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800044fc:	2184a783          	lw	a5,536(s1)
    80004500:	21c4a703          	lw	a4,540(s1)
    80004504:	2007879b          	addiw	a5,a5,512
    80004508:	fcf70ae3          	beq	a4,a5,800044dc <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000450c:	4685                	li	a3,1
    8000450e:	01590633          	add	a2,s2,s5
    80004512:	faf40593          	addi	a1,s0,-81
    80004516:	0509b503          	ld	a0,80(s3)
    8000451a:	9acfd0ef          	jal	800016c6 <copyin>
    8000451e:	03650e63          	beq	a0,s6,8000455a <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004522:	21c4a783          	lw	a5,540(s1)
    80004526:	0017871b          	addiw	a4,a5,1
    8000452a:	20e4ae23          	sw	a4,540(s1)
    8000452e:	1ff7f793          	andi	a5,a5,511
    80004532:	97a6                	add	a5,a5,s1
    80004534:	faf44703          	lbu	a4,-81(s0)
    80004538:	00e78c23          	sb	a4,24(a5)
      i++;
    8000453c:	2905                	addiw	s2,s2,1
    8000453e:	b775                	j	800044ea <pipewrite+0x6c>
    80004540:	7b02                	ld	s6,32(sp)
    80004542:	6be2                	ld	s7,24(sp)
    80004544:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004546:	21848513          	addi	a0,s1,536
    8000454a:	9e7fd0ef          	jal	80001f30 <wakeup>
  release(&pi->lock);
    8000454e:	8526                	mv	a0,s1
    80004550:	f16fc0ef          	jal	80000c66 <release>
  return i;
    80004554:	bf95                	j	800044c8 <pipewrite+0x4a>
  int i = 0;
    80004556:	4901                	li	s2,0
    80004558:	b7fd                	j	80004546 <pipewrite+0xc8>
    8000455a:	7b02                	ld	s6,32(sp)
    8000455c:	6be2                	ld	s7,24(sp)
    8000455e:	6c42                	ld	s8,16(sp)
    80004560:	b7dd                	j	80004546 <pipewrite+0xc8>

0000000080004562 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004562:	715d                	addi	sp,sp,-80
    80004564:	e486                	sd	ra,72(sp)
    80004566:	e0a2                	sd	s0,64(sp)
    80004568:	fc26                	sd	s1,56(sp)
    8000456a:	f84a                	sd	s2,48(sp)
    8000456c:	f44e                	sd	s3,40(sp)
    8000456e:	f052                	sd	s4,32(sp)
    80004570:	ec56                	sd	s5,24(sp)
    80004572:	0880                	addi	s0,sp,80
    80004574:	84aa                	mv	s1,a0
    80004576:	892e                	mv	s2,a1
    80004578:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000457a:	b54fd0ef          	jal	800018ce <myproc>
    8000457e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004580:	8526                	mv	a0,s1
    80004582:	e4cfc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004586:	2184a703          	lw	a4,536(s1)
    8000458a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000458e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004592:	02f71563          	bne	a4,a5,800045bc <piperead+0x5a>
    80004596:	2244a783          	lw	a5,548(s1)
    8000459a:	cb85                	beqz	a5,800045ca <piperead+0x68>
    if(killed(pr)){
    8000459c:	8552                	mv	a0,s4
    8000459e:	b7ffd0ef          	jal	8000211c <killed>
    800045a2:	ed19                	bnez	a0,800045c0 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800045a4:	85a6                	mv	a1,s1
    800045a6:	854e                	mv	a0,s3
    800045a8:	93dfd0ef          	jal	80001ee4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045ac:	2184a703          	lw	a4,536(s1)
    800045b0:	21c4a783          	lw	a5,540(s1)
    800045b4:	fef701e3          	beq	a4,a5,80004596 <piperead+0x34>
    800045b8:	e85a                	sd	s6,16(sp)
    800045ba:	a809                	j	800045cc <piperead+0x6a>
    800045bc:	e85a                	sd	s6,16(sp)
    800045be:	a039                	j	800045cc <piperead+0x6a>
      release(&pi->lock);
    800045c0:	8526                	mv	a0,s1
    800045c2:	ea4fc0ef          	jal	80000c66 <release>
      return -1;
    800045c6:	59fd                	li	s3,-1
    800045c8:	a8b9                	j	80004626 <piperead+0xc4>
    800045ca:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045cc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800045ce:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045d0:	05505363          	blez	s5,80004616 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800045d4:	2184a783          	lw	a5,536(s1)
    800045d8:	21c4a703          	lw	a4,540(s1)
    800045dc:	02f70d63          	beq	a4,a5,80004616 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    800045e0:	1ff7f793          	andi	a5,a5,511
    800045e4:	97a6                	add	a5,a5,s1
    800045e6:	0187c783          	lbu	a5,24(a5)
    800045ea:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800045ee:	4685                	li	a3,1
    800045f0:	fbf40613          	addi	a2,s0,-65
    800045f4:	85ca                	mv	a1,s2
    800045f6:	050a3503          	ld	a0,80(s4)
    800045fa:	fe9fc0ef          	jal	800015e2 <copyout>
    800045fe:	03650e63          	beq	a0,s6,8000463a <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004602:	2184a783          	lw	a5,536(s1)
    80004606:	2785                	addiw	a5,a5,1
    80004608:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000460c:	2985                	addiw	s3,s3,1
    8000460e:	0905                	addi	s2,s2,1
    80004610:	fd3a92e3          	bne	s5,s3,800045d4 <piperead+0x72>
    80004614:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004616:	21c48513          	addi	a0,s1,540
    8000461a:	917fd0ef          	jal	80001f30 <wakeup>
  release(&pi->lock);
    8000461e:	8526                	mv	a0,s1
    80004620:	e46fc0ef          	jal	80000c66 <release>
    80004624:	6b42                	ld	s6,16(sp)
  return i;
}
    80004626:	854e                	mv	a0,s3
    80004628:	60a6                	ld	ra,72(sp)
    8000462a:	6406                	ld	s0,64(sp)
    8000462c:	74e2                	ld	s1,56(sp)
    8000462e:	7942                	ld	s2,48(sp)
    80004630:	79a2                	ld	s3,40(sp)
    80004632:	7a02                	ld	s4,32(sp)
    80004634:	6ae2                	ld	s5,24(sp)
    80004636:	6161                	addi	sp,sp,80
    80004638:	8082                	ret
      if(i == 0)
    8000463a:	fc099ee3          	bnez	s3,80004616 <piperead+0xb4>
        i = -1;
    8000463e:	89aa                	mv	s3,a0
    80004640:	bfd9                	j	80004616 <piperead+0xb4>

0000000080004642 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004642:	1141                	addi	sp,sp,-16
    80004644:	e422                	sd	s0,8(sp)
    80004646:	0800                	addi	s0,sp,16
    80004648:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000464a:	8905                	andi	a0,a0,1
    8000464c:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000464e:	8b89                	andi	a5,a5,2
    80004650:	c399                	beqz	a5,80004656 <flags2perm+0x14>
      perm |= PTE_W;
    80004652:	00456513          	ori	a0,a0,4
    return perm;
}
    80004656:	6422                	ld	s0,8(sp)
    80004658:	0141                	addi	sp,sp,16
    8000465a:	8082                	ret

000000008000465c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000465c:	df010113          	addi	sp,sp,-528
    80004660:	20113423          	sd	ra,520(sp)
    80004664:	20813023          	sd	s0,512(sp)
    80004668:	ffa6                	sd	s1,504(sp)
    8000466a:	fbca                	sd	s2,496(sp)
    8000466c:	0c00                	addi	s0,sp,528
    8000466e:	892a                	mv	s2,a0
    80004670:	dea43c23          	sd	a0,-520(s0)
    80004674:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004678:	a56fd0ef          	jal	800018ce <myproc>
    8000467c:	84aa                	mv	s1,a0

  begin_op();
    8000467e:	dcaff0ef          	jal	80003c48 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004682:	854a                	mv	a0,s2
    80004684:	bf0ff0ef          	jal	80003a74 <namei>
    80004688:	c931                	beqz	a0,800046dc <kexec+0x80>
    8000468a:	f3d2                	sd	s4,480(sp)
    8000468c:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000468e:	bd1fe0ef          	jal	8000325e <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004692:	04000713          	li	a4,64
    80004696:	4681                	li	a3,0
    80004698:	e5040613          	addi	a2,s0,-432
    8000469c:	4581                	li	a1,0
    8000469e:	8552                	mv	a0,s4
    800046a0:	f4ffe0ef          	jal	800035ee <readi>
    800046a4:	04000793          	li	a5,64
    800046a8:	00f51a63          	bne	a0,a5,800046bc <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800046ac:	e5042703          	lw	a4,-432(s0)
    800046b0:	464c47b7          	lui	a5,0x464c4
    800046b4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800046b8:	02f70663          	beq	a4,a5,800046e4 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800046bc:	8552                	mv	a0,s4
    800046be:	dabfe0ef          	jal	80003468 <iunlockput>
    end_op();
    800046c2:	df0ff0ef          	jal	80003cb2 <end_op>
  }
  return -1;
    800046c6:	557d                	li	a0,-1
    800046c8:	7a1e                	ld	s4,480(sp)
}
    800046ca:	20813083          	ld	ra,520(sp)
    800046ce:	20013403          	ld	s0,512(sp)
    800046d2:	74fe                	ld	s1,504(sp)
    800046d4:	795e                	ld	s2,496(sp)
    800046d6:	21010113          	addi	sp,sp,528
    800046da:	8082                	ret
    end_op();
    800046dc:	dd6ff0ef          	jal	80003cb2 <end_op>
    return -1;
    800046e0:	557d                	li	a0,-1
    800046e2:	b7e5                	j	800046ca <kexec+0x6e>
    800046e4:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800046e6:	8526                	mv	a0,s1
    800046e8:	aecfd0ef          	jal	800019d4 <proc_pagetable>
    800046ec:	8b2a                	mv	s6,a0
    800046ee:	2c050b63          	beqz	a0,800049c4 <kexec+0x368>
    800046f2:	f7ce                	sd	s3,488(sp)
    800046f4:	efd6                	sd	s5,472(sp)
    800046f6:	e7de                	sd	s7,456(sp)
    800046f8:	e3e2                	sd	s8,448(sp)
    800046fa:	ff66                	sd	s9,440(sp)
    800046fc:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046fe:	e7042d03          	lw	s10,-400(s0)
    80004702:	e8845783          	lhu	a5,-376(s0)
    80004706:	12078963          	beqz	a5,80004838 <kexec+0x1dc>
    8000470a:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000470c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000470e:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004710:	6c85                	lui	s9,0x1
    80004712:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004716:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000471a:	6a85                	lui	s5,0x1
    8000471c:	a085                	j	8000477c <kexec+0x120>
      panic("loadseg: address should exist");
    8000471e:	00003517          	auipc	a0,0x3
    80004722:	eaa50513          	addi	a0,a0,-342 # 800075c8 <etext+0x5c8>
    80004726:	8bafc0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    8000472a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000472c:	8726                	mv	a4,s1
    8000472e:	012c06bb          	addw	a3,s8,s2
    80004732:	4581                	li	a1,0
    80004734:	8552                	mv	a0,s4
    80004736:	eb9fe0ef          	jal	800035ee <readi>
    8000473a:	2501                	sext.w	a0,a0
    8000473c:	24a49a63          	bne	s1,a0,80004990 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004740:	012a893b          	addw	s2,s5,s2
    80004744:	03397363          	bgeu	s2,s3,8000476a <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004748:	02091593          	slli	a1,s2,0x20
    8000474c:	9181                	srli	a1,a1,0x20
    8000474e:	95de                	add	a1,a1,s7
    80004750:	855a                	mv	a0,s6
    80004752:	85ffc0ef          	jal	80000fb0 <walkaddr>
    80004756:	862a                	mv	a2,a0
    if(pa == 0)
    80004758:	d179                	beqz	a0,8000471e <kexec+0xc2>
    if(sz - i < PGSIZE)
    8000475a:	412984bb          	subw	s1,s3,s2
    8000475e:	0004879b          	sext.w	a5,s1
    80004762:	fcfcf4e3          	bgeu	s9,a5,8000472a <kexec+0xce>
    80004766:	84d6                	mv	s1,s5
    80004768:	b7c9                	j	8000472a <kexec+0xce>
    sz = sz1;
    8000476a:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000476e:	2d85                	addiw	s11,s11,1
    80004770:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004774:	e8845783          	lhu	a5,-376(s0)
    80004778:	08fdd063          	bge	s11,a5,800047f8 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000477c:	2d01                	sext.w	s10,s10
    8000477e:	03800713          	li	a4,56
    80004782:	86ea                	mv	a3,s10
    80004784:	e1840613          	addi	a2,s0,-488
    80004788:	4581                	li	a1,0
    8000478a:	8552                	mv	a0,s4
    8000478c:	e63fe0ef          	jal	800035ee <readi>
    80004790:	03800793          	li	a5,56
    80004794:	1cf51663          	bne	a0,a5,80004960 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004798:	e1842783          	lw	a5,-488(s0)
    8000479c:	4705                	li	a4,1
    8000479e:	fce798e3          	bne	a5,a4,8000476e <kexec+0x112>
    if(ph.memsz < ph.filesz)
    800047a2:	e4043483          	ld	s1,-448(s0)
    800047a6:	e3843783          	ld	a5,-456(s0)
    800047aa:	1af4ef63          	bltu	s1,a5,80004968 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800047ae:	e2843783          	ld	a5,-472(s0)
    800047b2:	94be                	add	s1,s1,a5
    800047b4:	1af4ee63          	bltu	s1,a5,80004970 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800047b8:	df043703          	ld	a4,-528(s0)
    800047bc:	8ff9                	and	a5,a5,a4
    800047be:	1a079d63          	bnez	a5,80004978 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800047c2:	e1c42503          	lw	a0,-484(s0)
    800047c6:	e7dff0ef          	jal	80004642 <flags2perm>
    800047ca:	86aa                	mv	a3,a0
    800047cc:	8626                	mv	a2,s1
    800047ce:	85ca                	mv	a1,s2
    800047d0:	855a                	mv	a0,s6
    800047d2:	ab7fc0ef          	jal	80001288 <uvmalloc>
    800047d6:	e0a43423          	sd	a0,-504(s0)
    800047da:	1a050363          	beqz	a0,80004980 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800047de:	e2843b83          	ld	s7,-472(s0)
    800047e2:	e2042c03          	lw	s8,-480(s0)
    800047e6:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800047ea:	00098463          	beqz	s3,800047f2 <kexec+0x196>
    800047ee:	4901                	li	s2,0
    800047f0:	bfa1                	j	80004748 <kexec+0xec>
    sz = sz1;
    800047f2:	e0843903          	ld	s2,-504(s0)
    800047f6:	bfa5                	j	8000476e <kexec+0x112>
    800047f8:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800047fa:	8552                	mv	a0,s4
    800047fc:	c6dfe0ef          	jal	80003468 <iunlockput>
  end_op();
    80004800:	cb2ff0ef          	jal	80003cb2 <end_op>
  p = myproc();
    80004804:	8cafd0ef          	jal	800018ce <myproc>
    80004808:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000480a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000480e:	6985                	lui	s3,0x1
    80004810:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004812:	99ca                	add	s3,s3,s2
    80004814:	77fd                	lui	a5,0xfffff
    80004816:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000481a:	4691                	li	a3,4
    8000481c:	6609                	lui	a2,0x2
    8000481e:	964e                	add	a2,a2,s3
    80004820:	85ce                	mv	a1,s3
    80004822:	855a                	mv	a0,s6
    80004824:	a65fc0ef          	jal	80001288 <uvmalloc>
    80004828:	892a                	mv	s2,a0
    8000482a:	e0a43423          	sd	a0,-504(s0)
    8000482e:	e519                	bnez	a0,8000483c <kexec+0x1e0>
  if(pagetable)
    80004830:	e1343423          	sd	s3,-504(s0)
    80004834:	4a01                	li	s4,0
    80004836:	aab1                	j	80004992 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004838:	4901                	li	s2,0
    8000483a:	b7c1                	j	800047fa <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000483c:	75f9                	lui	a1,0xffffe
    8000483e:	95aa                	add	a1,a1,a0
    80004840:	855a                	mv	a0,s6
    80004842:	c1dfc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004846:	7bfd                	lui	s7,0xfffff
    80004848:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000484a:	e0043783          	ld	a5,-512(s0)
    8000484e:	6388                	ld	a0,0(a5)
    80004850:	cd39                	beqz	a0,800048ae <kexec+0x252>
    80004852:	e9040993          	addi	s3,s0,-368
    80004856:	f9040c13          	addi	s8,s0,-112
    8000485a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000485c:	db6fc0ef          	jal	80000e12 <strlen>
    80004860:	0015079b          	addiw	a5,a0,1
    80004864:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004868:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000486c:	11796e63          	bltu	s2,s7,80004988 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004870:	e0043d03          	ld	s10,-512(s0)
    80004874:	000d3a03          	ld	s4,0(s10)
    80004878:	8552                	mv	a0,s4
    8000487a:	d98fc0ef          	jal	80000e12 <strlen>
    8000487e:	0015069b          	addiw	a3,a0,1
    80004882:	8652                	mv	a2,s4
    80004884:	85ca                	mv	a1,s2
    80004886:	855a                	mv	a0,s6
    80004888:	d5bfc0ef          	jal	800015e2 <copyout>
    8000488c:	10054063          	bltz	a0,8000498c <kexec+0x330>
    ustack[argc] = sp;
    80004890:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004894:	0485                	addi	s1,s1,1
    80004896:	008d0793          	addi	a5,s10,8
    8000489a:	e0f43023          	sd	a5,-512(s0)
    8000489e:	008d3503          	ld	a0,8(s10)
    800048a2:	c909                	beqz	a0,800048b4 <kexec+0x258>
    if(argc >= MAXARG)
    800048a4:	09a1                	addi	s3,s3,8
    800048a6:	fb899be3          	bne	s3,s8,8000485c <kexec+0x200>
  ip = 0;
    800048aa:	4a01                	li	s4,0
    800048ac:	a0dd                	j	80004992 <kexec+0x336>
  sp = sz;
    800048ae:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800048b2:	4481                	li	s1,0
  ustack[argc] = 0;
    800048b4:	00349793          	slli	a5,s1,0x3
    800048b8:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde1e8>
    800048bc:	97a2                	add	a5,a5,s0
    800048be:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800048c2:	00148693          	addi	a3,s1,1
    800048c6:	068e                	slli	a3,a3,0x3
    800048c8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800048cc:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800048d0:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800048d4:	f5796ee3          	bltu	s2,s7,80004830 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800048d8:	e9040613          	addi	a2,s0,-368
    800048dc:	85ca                	mv	a1,s2
    800048de:	855a                	mv	a0,s6
    800048e0:	d03fc0ef          	jal	800015e2 <copyout>
    800048e4:	0e054263          	bltz	a0,800049c8 <kexec+0x36c>
  p->trapframe->a1 = sp;
    800048e8:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800048ec:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800048f0:	df843783          	ld	a5,-520(s0)
    800048f4:	0007c703          	lbu	a4,0(a5)
    800048f8:	cf11                	beqz	a4,80004914 <kexec+0x2b8>
    800048fa:	0785                	addi	a5,a5,1
    if(*s == '/')
    800048fc:	02f00693          	li	a3,47
    80004900:	a039                	j	8000490e <kexec+0x2b2>
      last = s+1;
    80004902:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004906:	0785                	addi	a5,a5,1
    80004908:	fff7c703          	lbu	a4,-1(a5)
    8000490c:	c701                	beqz	a4,80004914 <kexec+0x2b8>
    if(*s == '/')
    8000490e:	fed71ce3          	bne	a4,a3,80004906 <kexec+0x2aa>
    80004912:	bfc5                	j	80004902 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004914:	4641                	li	a2,16
    80004916:	df843583          	ld	a1,-520(s0)
    8000491a:	160a8513          	addi	a0,s5,352
    8000491e:	cc2fc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004922:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004926:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000492a:	e0843783          	ld	a5,-504(s0)
    8000492e:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004932:	058ab783          	ld	a5,88(s5)
    80004936:	e6843703          	ld	a4,-408(s0)
    8000493a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000493c:	058ab783          	ld	a5,88(s5)
    80004940:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004944:	85e6                	mv	a1,s9
    80004946:	912fd0ef          	jal	80001a58 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000494a:	0004851b          	sext.w	a0,s1
    8000494e:	79be                	ld	s3,488(sp)
    80004950:	7a1e                	ld	s4,480(sp)
    80004952:	6afe                	ld	s5,472(sp)
    80004954:	6b5e                	ld	s6,464(sp)
    80004956:	6bbe                	ld	s7,456(sp)
    80004958:	6c1e                	ld	s8,448(sp)
    8000495a:	7cfa                	ld	s9,440(sp)
    8000495c:	7d5a                	ld	s10,432(sp)
    8000495e:	b3b5                	j	800046ca <kexec+0x6e>
    80004960:	e1243423          	sd	s2,-504(s0)
    80004964:	7dba                	ld	s11,424(sp)
    80004966:	a035                	j	80004992 <kexec+0x336>
    80004968:	e1243423          	sd	s2,-504(s0)
    8000496c:	7dba                	ld	s11,424(sp)
    8000496e:	a015                	j	80004992 <kexec+0x336>
    80004970:	e1243423          	sd	s2,-504(s0)
    80004974:	7dba                	ld	s11,424(sp)
    80004976:	a831                	j	80004992 <kexec+0x336>
    80004978:	e1243423          	sd	s2,-504(s0)
    8000497c:	7dba                	ld	s11,424(sp)
    8000497e:	a811                	j	80004992 <kexec+0x336>
    80004980:	e1243423          	sd	s2,-504(s0)
    80004984:	7dba                	ld	s11,424(sp)
    80004986:	a031                	j	80004992 <kexec+0x336>
  ip = 0;
    80004988:	4a01                	li	s4,0
    8000498a:	a021                	j	80004992 <kexec+0x336>
    8000498c:	4a01                	li	s4,0
  if(pagetable)
    8000498e:	a011                	j	80004992 <kexec+0x336>
    80004990:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004992:	e0843583          	ld	a1,-504(s0)
    80004996:	855a                	mv	a0,s6
    80004998:	8c0fd0ef          	jal	80001a58 <proc_freepagetable>
  return -1;
    8000499c:	557d                	li	a0,-1
  if(ip){
    8000499e:	000a1b63          	bnez	s4,800049b4 <kexec+0x358>
    800049a2:	79be                	ld	s3,488(sp)
    800049a4:	7a1e                	ld	s4,480(sp)
    800049a6:	6afe                	ld	s5,472(sp)
    800049a8:	6b5e                	ld	s6,464(sp)
    800049aa:	6bbe                	ld	s7,456(sp)
    800049ac:	6c1e                	ld	s8,448(sp)
    800049ae:	7cfa                	ld	s9,440(sp)
    800049b0:	7d5a                	ld	s10,432(sp)
    800049b2:	bb21                	j	800046ca <kexec+0x6e>
    800049b4:	79be                	ld	s3,488(sp)
    800049b6:	6afe                	ld	s5,472(sp)
    800049b8:	6b5e                	ld	s6,464(sp)
    800049ba:	6bbe                	ld	s7,456(sp)
    800049bc:	6c1e                	ld	s8,448(sp)
    800049be:	7cfa                	ld	s9,440(sp)
    800049c0:	7d5a                	ld	s10,432(sp)
    800049c2:	b9ed                	j	800046bc <kexec+0x60>
    800049c4:	6b5e                	ld	s6,464(sp)
    800049c6:	b9dd                	j	800046bc <kexec+0x60>
  sz = sz1;
    800049c8:	e0843983          	ld	s3,-504(s0)
    800049cc:	b595                	j	80004830 <kexec+0x1d4>

00000000800049ce <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800049ce:	7179                	addi	sp,sp,-48
    800049d0:	f406                	sd	ra,40(sp)
    800049d2:	f022                	sd	s0,32(sp)
    800049d4:	ec26                	sd	s1,24(sp)
    800049d6:	e84a                	sd	s2,16(sp)
    800049d8:	1800                	addi	s0,sp,48
    800049da:	892e                	mv	s2,a1
    800049dc:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800049de:	fdc40593          	addi	a1,s0,-36
    800049e2:	e07fd0ef          	jal	800027e8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800049e6:	fdc42703          	lw	a4,-36(s0)
    800049ea:	47bd                	li	a5,15
    800049ec:	02e7e963          	bltu	a5,a4,80004a1e <argfd+0x50>
    800049f0:	edffc0ef          	jal	800018ce <myproc>
    800049f4:	fdc42703          	lw	a4,-36(s0)
    800049f8:	01a70793          	addi	a5,a4,26
    800049fc:	078e                	slli	a5,a5,0x3
    800049fe:	953e                	add	a0,a0,a5
    80004a00:	611c                	ld	a5,0(a0)
    80004a02:	c385                	beqz	a5,80004a22 <argfd+0x54>
    return -1;
  if(pfd)
    80004a04:	00090463          	beqz	s2,80004a0c <argfd+0x3e>
    *pfd = fd;
    80004a08:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004a0c:	4501                	li	a0,0
  if(pf)
    80004a0e:	c091                	beqz	s1,80004a12 <argfd+0x44>
    *pf = f;
    80004a10:	e09c                	sd	a5,0(s1)
}
    80004a12:	70a2                	ld	ra,40(sp)
    80004a14:	7402                	ld	s0,32(sp)
    80004a16:	64e2                	ld	s1,24(sp)
    80004a18:	6942                	ld	s2,16(sp)
    80004a1a:	6145                	addi	sp,sp,48
    80004a1c:	8082                	ret
    return -1;
    80004a1e:	557d                	li	a0,-1
    80004a20:	bfcd                	j	80004a12 <argfd+0x44>
    80004a22:	557d                	li	a0,-1
    80004a24:	b7fd                	j	80004a12 <argfd+0x44>

0000000080004a26 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004a26:	1101                	addi	sp,sp,-32
    80004a28:	ec06                	sd	ra,24(sp)
    80004a2a:	e822                	sd	s0,16(sp)
    80004a2c:	e426                	sd	s1,8(sp)
    80004a2e:	1000                	addi	s0,sp,32
    80004a30:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004a32:	e9dfc0ef          	jal	800018ce <myproc>
    80004a36:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004a38:	0d050793          	addi	a5,a0,208
    80004a3c:	4501                	li	a0,0
    80004a3e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004a40:	6398                	ld	a4,0(a5)
    80004a42:	cb19                	beqz	a4,80004a58 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004a44:	2505                	addiw	a0,a0,1
    80004a46:	07a1                	addi	a5,a5,8
    80004a48:	fed51ce3          	bne	a0,a3,80004a40 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004a4c:	557d                	li	a0,-1
}
    80004a4e:	60e2                	ld	ra,24(sp)
    80004a50:	6442                	ld	s0,16(sp)
    80004a52:	64a2                	ld	s1,8(sp)
    80004a54:	6105                	addi	sp,sp,32
    80004a56:	8082                	ret
      p->ofile[fd] = f;
    80004a58:	01a50793          	addi	a5,a0,26
    80004a5c:	078e                	slli	a5,a5,0x3
    80004a5e:	963e                	add	a2,a2,a5
    80004a60:	e204                	sd	s1,0(a2)
      return fd;
    80004a62:	b7f5                	j	80004a4e <fdalloc+0x28>

0000000080004a64 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004a64:	715d                	addi	sp,sp,-80
    80004a66:	e486                	sd	ra,72(sp)
    80004a68:	e0a2                	sd	s0,64(sp)
    80004a6a:	fc26                	sd	s1,56(sp)
    80004a6c:	f84a                	sd	s2,48(sp)
    80004a6e:	f44e                	sd	s3,40(sp)
    80004a70:	ec56                	sd	s5,24(sp)
    80004a72:	e85a                	sd	s6,16(sp)
    80004a74:	0880                	addi	s0,sp,80
    80004a76:	8b2e                	mv	s6,a1
    80004a78:	89b2                	mv	s3,a2
    80004a7a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004a7c:	fb040593          	addi	a1,s0,-80
    80004a80:	80eff0ef          	jal	80003a8e <nameiparent>
    80004a84:	84aa                	mv	s1,a0
    80004a86:	10050a63          	beqz	a0,80004b9a <create+0x136>
    return 0;

  ilock(dp);
    80004a8a:	fd4fe0ef          	jal	8000325e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a8e:	4601                	li	a2,0
    80004a90:	fb040593          	addi	a1,s0,-80
    80004a94:	8526                	mv	a0,s1
    80004a96:	d79fe0ef          	jal	8000380e <dirlookup>
    80004a9a:	8aaa                	mv	s5,a0
    80004a9c:	c129                	beqz	a0,80004ade <create+0x7a>
    iunlockput(dp);
    80004a9e:	8526                	mv	a0,s1
    80004aa0:	9c9fe0ef          	jal	80003468 <iunlockput>
    ilock(ip);
    80004aa4:	8556                	mv	a0,s5
    80004aa6:	fb8fe0ef          	jal	8000325e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004aaa:	4789                	li	a5,2
    80004aac:	02fb1463          	bne	s6,a5,80004ad4 <create+0x70>
    80004ab0:	044ad783          	lhu	a5,68(s5)
    80004ab4:	37f9                	addiw	a5,a5,-2
    80004ab6:	17c2                	slli	a5,a5,0x30
    80004ab8:	93c1                	srli	a5,a5,0x30
    80004aba:	4705                	li	a4,1
    80004abc:	00f76c63          	bltu	a4,a5,80004ad4 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004ac0:	8556                	mv	a0,s5
    80004ac2:	60a6                	ld	ra,72(sp)
    80004ac4:	6406                	ld	s0,64(sp)
    80004ac6:	74e2                	ld	s1,56(sp)
    80004ac8:	7942                	ld	s2,48(sp)
    80004aca:	79a2                	ld	s3,40(sp)
    80004acc:	6ae2                	ld	s5,24(sp)
    80004ace:	6b42                	ld	s6,16(sp)
    80004ad0:	6161                	addi	sp,sp,80
    80004ad2:	8082                	ret
    iunlockput(ip);
    80004ad4:	8556                	mv	a0,s5
    80004ad6:	993fe0ef          	jal	80003468 <iunlockput>
    return 0;
    80004ada:	4a81                	li	s5,0
    80004adc:	b7d5                	j	80004ac0 <create+0x5c>
    80004ade:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004ae0:	85da                	mv	a1,s6
    80004ae2:	4088                	lw	a0,0(s1)
    80004ae4:	e0afe0ef          	jal	800030ee <ialloc>
    80004ae8:	8a2a                	mv	s4,a0
    80004aea:	cd15                	beqz	a0,80004b26 <create+0xc2>
  ilock(ip);
    80004aec:	f72fe0ef          	jal	8000325e <ilock>
  ip->major = major;
    80004af0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004af4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004af8:	4905                	li	s2,1
    80004afa:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004afe:	8552                	mv	a0,s4
    80004b00:	eaafe0ef          	jal	800031aa <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004b04:	032b0763          	beq	s6,s2,80004b32 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b08:	004a2603          	lw	a2,4(s4)
    80004b0c:	fb040593          	addi	a1,s0,-80
    80004b10:	8526                	mv	a0,s1
    80004b12:	ec9fe0ef          	jal	800039da <dirlink>
    80004b16:	06054563          	bltz	a0,80004b80 <create+0x11c>
  iunlockput(dp);
    80004b1a:	8526                	mv	a0,s1
    80004b1c:	94dfe0ef          	jal	80003468 <iunlockput>
  return ip;
    80004b20:	8ad2                	mv	s5,s4
    80004b22:	7a02                	ld	s4,32(sp)
    80004b24:	bf71                	j	80004ac0 <create+0x5c>
    iunlockput(dp);
    80004b26:	8526                	mv	a0,s1
    80004b28:	941fe0ef          	jal	80003468 <iunlockput>
    return 0;
    80004b2c:	8ad2                	mv	s5,s4
    80004b2e:	7a02                	ld	s4,32(sp)
    80004b30:	bf41                	j	80004ac0 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004b32:	004a2603          	lw	a2,4(s4)
    80004b36:	00003597          	auipc	a1,0x3
    80004b3a:	ab258593          	addi	a1,a1,-1358 # 800075e8 <etext+0x5e8>
    80004b3e:	8552                	mv	a0,s4
    80004b40:	e9bfe0ef          	jal	800039da <dirlink>
    80004b44:	02054e63          	bltz	a0,80004b80 <create+0x11c>
    80004b48:	40d0                	lw	a2,4(s1)
    80004b4a:	00003597          	auipc	a1,0x3
    80004b4e:	aa658593          	addi	a1,a1,-1370 # 800075f0 <etext+0x5f0>
    80004b52:	8552                	mv	a0,s4
    80004b54:	e87fe0ef          	jal	800039da <dirlink>
    80004b58:	02054463          	bltz	a0,80004b80 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b5c:	004a2603          	lw	a2,4(s4)
    80004b60:	fb040593          	addi	a1,s0,-80
    80004b64:	8526                	mv	a0,s1
    80004b66:	e75fe0ef          	jal	800039da <dirlink>
    80004b6a:	00054b63          	bltz	a0,80004b80 <create+0x11c>
    dp->nlink++;  // for ".."
    80004b6e:	04a4d783          	lhu	a5,74(s1)
    80004b72:	2785                	addiw	a5,a5,1
    80004b74:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004b78:	8526                	mv	a0,s1
    80004b7a:	e30fe0ef          	jal	800031aa <iupdate>
    80004b7e:	bf71                	j	80004b1a <create+0xb6>
  ip->nlink = 0;
    80004b80:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004b84:	8552                	mv	a0,s4
    80004b86:	e24fe0ef          	jal	800031aa <iupdate>
  iunlockput(ip);
    80004b8a:	8552                	mv	a0,s4
    80004b8c:	8ddfe0ef          	jal	80003468 <iunlockput>
  iunlockput(dp);
    80004b90:	8526                	mv	a0,s1
    80004b92:	8d7fe0ef          	jal	80003468 <iunlockput>
  return 0;
    80004b96:	7a02                	ld	s4,32(sp)
    80004b98:	b725                	j	80004ac0 <create+0x5c>
    return 0;
    80004b9a:	8aaa                	mv	s5,a0
    80004b9c:	b715                	j	80004ac0 <create+0x5c>

0000000080004b9e <sys_dup>:
{
    80004b9e:	7179                	addi	sp,sp,-48
    80004ba0:	f406                	sd	ra,40(sp)
    80004ba2:	f022                	sd	s0,32(sp)
    80004ba4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004ba6:	fd840613          	addi	a2,s0,-40
    80004baa:	4581                	li	a1,0
    80004bac:	4501                	li	a0,0
    80004bae:	e21ff0ef          	jal	800049ce <argfd>
    return -1;
    80004bb2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004bb4:	02054363          	bltz	a0,80004bda <sys_dup+0x3c>
    80004bb8:	ec26                	sd	s1,24(sp)
    80004bba:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004bbc:	fd843903          	ld	s2,-40(s0)
    80004bc0:	854a                	mv	a0,s2
    80004bc2:	e65ff0ef          	jal	80004a26 <fdalloc>
    80004bc6:	84aa                	mv	s1,a0
    return -1;
    80004bc8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004bca:	00054d63          	bltz	a0,80004be4 <sys_dup+0x46>
  filedup(f);
    80004bce:	854a                	mv	a0,s2
    80004bd0:	c3eff0ef          	jal	8000400e <filedup>
  return fd;
    80004bd4:	87a6                	mv	a5,s1
    80004bd6:	64e2                	ld	s1,24(sp)
    80004bd8:	6942                	ld	s2,16(sp)
}
    80004bda:	853e                	mv	a0,a5
    80004bdc:	70a2                	ld	ra,40(sp)
    80004bde:	7402                	ld	s0,32(sp)
    80004be0:	6145                	addi	sp,sp,48
    80004be2:	8082                	ret
    80004be4:	64e2                	ld	s1,24(sp)
    80004be6:	6942                	ld	s2,16(sp)
    80004be8:	bfcd                	j	80004bda <sys_dup+0x3c>

0000000080004bea <sys_read>:
{
    80004bea:	7179                	addi	sp,sp,-48
    80004bec:	f406                	sd	ra,40(sp)
    80004bee:	f022                	sd	s0,32(sp)
    80004bf0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bf2:	fd840593          	addi	a1,s0,-40
    80004bf6:	4505                	li	a0,1
    80004bf8:	c0dfd0ef          	jal	80002804 <argaddr>
  argint(2, &n);
    80004bfc:	fe440593          	addi	a1,s0,-28
    80004c00:	4509                	li	a0,2
    80004c02:	be7fd0ef          	jal	800027e8 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c06:	fe840613          	addi	a2,s0,-24
    80004c0a:	4581                	li	a1,0
    80004c0c:	4501                	li	a0,0
    80004c0e:	dc1ff0ef          	jal	800049ce <argfd>
    80004c12:	87aa                	mv	a5,a0
    return -1;
    80004c14:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c16:	0007ca63          	bltz	a5,80004c2a <sys_read+0x40>
  return fileread(f, p, n);
    80004c1a:	fe442603          	lw	a2,-28(s0)
    80004c1e:	fd843583          	ld	a1,-40(s0)
    80004c22:	fe843503          	ld	a0,-24(s0)
    80004c26:	d4eff0ef          	jal	80004174 <fileread>
}
    80004c2a:	70a2                	ld	ra,40(sp)
    80004c2c:	7402                	ld	s0,32(sp)
    80004c2e:	6145                	addi	sp,sp,48
    80004c30:	8082                	ret

0000000080004c32 <sys_write>:
{
    80004c32:	7179                	addi	sp,sp,-48
    80004c34:	f406                	sd	ra,40(sp)
    80004c36:	f022                	sd	s0,32(sp)
    80004c38:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c3a:	fd840593          	addi	a1,s0,-40
    80004c3e:	4505                	li	a0,1
    80004c40:	bc5fd0ef          	jal	80002804 <argaddr>
  argint(2, &n);
    80004c44:	fe440593          	addi	a1,s0,-28
    80004c48:	4509                	li	a0,2
    80004c4a:	b9ffd0ef          	jal	800027e8 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c4e:	fe840613          	addi	a2,s0,-24
    80004c52:	4581                	li	a1,0
    80004c54:	4501                	li	a0,0
    80004c56:	d79ff0ef          	jal	800049ce <argfd>
    80004c5a:	87aa                	mv	a5,a0
    return -1;
    80004c5c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c5e:	0007ca63          	bltz	a5,80004c72 <sys_write+0x40>
  return filewrite(f, p, n);
    80004c62:	fe442603          	lw	a2,-28(s0)
    80004c66:	fd843583          	ld	a1,-40(s0)
    80004c6a:	fe843503          	ld	a0,-24(s0)
    80004c6e:	dc4ff0ef          	jal	80004232 <filewrite>
}
    80004c72:	70a2                	ld	ra,40(sp)
    80004c74:	7402                	ld	s0,32(sp)
    80004c76:	6145                	addi	sp,sp,48
    80004c78:	8082                	ret

0000000080004c7a <sys_close>:
{
    80004c7a:	1101                	addi	sp,sp,-32
    80004c7c:	ec06                	sd	ra,24(sp)
    80004c7e:	e822                	sd	s0,16(sp)
    80004c80:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004c82:	fe040613          	addi	a2,s0,-32
    80004c86:	fec40593          	addi	a1,s0,-20
    80004c8a:	4501                	li	a0,0
    80004c8c:	d43ff0ef          	jal	800049ce <argfd>
    return -1;
    80004c90:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004c92:	02054063          	bltz	a0,80004cb2 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c96:	c39fc0ef          	jal	800018ce <myproc>
    80004c9a:	fec42783          	lw	a5,-20(s0)
    80004c9e:	07e9                	addi	a5,a5,26
    80004ca0:	078e                	slli	a5,a5,0x3
    80004ca2:	953e                	add	a0,a0,a5
    80004ca4:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004ca8:	fe043503          	ld	a0,-32(s0)
    80004cac:	ba8ff0ef          	jal	80004054 <fileclose>
  return 0;
    80004cb0:	4781                	li	a5,0
}
    80004cb2:	853e                	mv	a0,a5
    80004cb4:	60e2                	ld	ra,24(sp)
    80004cb6:	6442                	ld	s0,16(sp)
    80004cb8:	6105                	addi	sp,sp,32
    80004cba:	8082                	ret

0000000080004cbc <sys_fstat>:
{
    80004cbc:	1101                	addi	sp,sp,-32
    80004cbe:	ec06                	sd	ra,24(sp)
    80004cc0:	e822                	sd	s0,16(sp)
    80004cc2:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004cc4:	fe040593          	addi	a1,s0,-32
    80004cc8:	4505                	li	a0,1
    80004cca:	b3bfd0ef          	jal	80002804 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004cce:	fe840613          	addi	a2,s0,-24
    80004cd2:	4581                	li	a1,0
    80004cd4:	4501                	li	a0,0
    80004cd6:	cf9ff0ef          	jal	800049ce <argfd>
    80004cda:	87aa                	mv	a5,a0
    return -1;
    80004cdc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cde:	0007c863          	bltz	a5,80004cee <sys_fstat+0x32>
  return filestat(f, st);
    80004ce2:	fe043583          	ld	a1,-32(s0)
    80004ce6:	fe843503          	ld	a0,-24(s0)
    80004cea:	c2cff0ef          	jal	80004116 <filestat>
}
    80004cee:	60e2                	ld	ra,24(sp)
    80004cf0:	6442                	ld	s0,16(sp)
    80004cf2:	6105                	addi	sp,sp,32
    80004cf4:	8082                	ret

0000000080004cf6 <sys_link>:
{
    80004cf6:	7169                	addi	sp,sp,-304
    80004cf8:	f606                	sd	ra,296(sp)
    80004cfa:	f222                	sd	s0,288(sp)
    80004cfc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cfe:	08000613          	li	a2,128
    80004d02:	ed040593          	addi	a1,s0,-304
    80004d06:	4501                	li	a0,0
    80004d08:	b1bfd0ef          	jal	80002822 <argstr>
    return -1;
    80004d0c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d0e:	0c054e63          	bltz	a0,80004dea <sys_link+0xf4>
    80004d12:	08000613          	li	a2,128
    80004d16:	f5040593          	addi	a1,s0,-176
    80004d1a:	4505                	li	a0,1
    80004d1c:	b07fd0ef          	jal	80002822 <argstr>
    return -1;
    80004d20:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d22:	0c054463          	bltz	a0,80004dea <sys_link+0xf4>
    80004d26:	ee26                	sd	s1,280(sp)
  begin_op();
    80004d28:	f21fe0ef          	jal	80003c48 <begin_op>
  if((ip = namei(old)) == 0){
    80004d2c:	ed040513          	addi	a0,s0,-304
    80004d30:	d45fe0ef          	jal	80003a74 <namei>
    80004d34:	84aa                	mv	s1,a0
    80004d36:	c53d                	beqz	a0,80004da4 <sys_link+0xae>
  ilock(ip);
    80004d38:	d26fe0ef          	jal	8000325e <ilock>
  if(ip->type == T_DIR){
    80004d3c:	04449703          	lh	a4,68(s1)
    80004d40:	4785                	li	a5,1
    80004d42:	06f70663          	beq	a4,a5,80004dae <sys_link+0xb8>
    80004d46:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004d48:	04a4d783          	lhu	a5,74(s1)
    80004d4c:	2785                	addiw	a5,a5,1
    80004d4e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d52:	8526                	mv	a0,s1
    80004d54:	c56fe0ef          	jal	800031aa <iupdate>
  iunlock(ip);
    80004d58:	8526                	mv	a0,s1
    80004d5a:	db2fe0ef          	jal	8000330c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004d5e:	fd040593          	addi	a1,s0,-48
    80004d62:	f5040513          	addi	a0,s0,-176
    80004d66:	d29fe0ef          	jal	80003a8e <nameiparent>
    80004d6a:	892a                	mv	s2,a0
    80004d6c:	cd21                	beqz	a0,80004dc4 <sys_link+0xce>
  ilock(dp);
    80004d6e:	cf0fe0ef          	jal	8000325e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004d72:	00092703          	lw	a4,0(s2)
    80004d76:	409c                	lw	a5,0(s1)
    80004d78:	04f71363          	bne	a4,a5,80004dbe <sys_link+0xc8>
    80004d7c:	40d0                	lw	a2,4(s1)
    80004d7e:	fd040593          	addi	a1,s0,-48
    80004d82:	854a                	mv	a0,s2
    80004d84:	c57fe0ef          	jal	800039da <dirlink>
    80004d88:	02054b63          	bltz	a0,80004dbe <sys_link+0xc8>
  iunlockput(dp);
    80004d8c:	854a                	mv	a0,s2
    80004d8e:	edafe0ef          	jal	80003468 <iunlockput>
  iput(ip);
    80004d92:	8526                	mv	a0,s1
    80004d94:	e4cfe0ef          	jal	800033e0 <iput>
  end_op();
    80004d98:	f1bfe0ef          	jal	80003cb2 <end_op>
  return 0;
    80004d9c:	4781                	li	a5,0
    80004d9e:	64f2                	ld	s1,280(sp)
    80004da0:	6952                	ld	s2,272(sp)
    80004da2:	a0a1                	j	80004dea <sys_link+0xf4>
    end_op();
    80004da4:	f0ffe0ef          	jal	80003cb2 <end_op>
    return -1;
    80004da8:	57fd                	li	a5,-1
    80004daa:	64f2                	ld	s1,280(sp)
    80004dac:	a83d                	j	80004dea <sys_link+0xf4>
    iunlockput(ip);
    80004dae:	8526                	mv	a0,s1
    80004db0:	eb8fe0ef          	jal	80003468 <iunlockput>
    end_op();
    80004db4:	efffe0ef          	jal	80003cb2 <end_op>
    return -1;
    80004db8:	57fd                	li	a5,-1
    80004dba:	64f2                	ld	s1,280(sp)
    80004dbc:	a03d                	j	80004dea <sys_link+0xf4>
    iunlockput(dp);
    80004dbe:	854a                	mv	a0,s2
    80004dc0:	ea8fe0ef          	jal	80003468 <iunlockput>
  ilock(ip);
    80004dc4:	8526                	mv	a0,s1
    80004dc6:	c98fe0ef          	jal	8000325e <ilock>
  ip->nlink--;
    80004dca:	04a4d783          	lhu	a5,74(s1)
    80004dce:	37fd                	addiw	a5,a5,-1
    80004dd0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004dd4:	8526                	mv	a0,s1
    80004dd6:	bd4fe0ef          	jal	800031aa <iupdate>
  iunlockput(ip);
    80004dda:	8526                	mv	a0,s1
    80004ddc:	e8cfe0ef          	jal	80003468 <iunlockput>
  end_op();
    80004de0:	ed3fe0ef          	jal	80003cb2 <end_op>
  return -1;
    80004de4:	57fd                	li	a5,-1
    80004de6:	64f2                	ld	s1,280(sp)
    80004de8:	6952                	ld	s2,272(sp)
}
    80004dea:	853e                	mv	a0,a5
    80004dec:	70b2                	ld	ra,296(sp)
    80004dee:	7412                	ld	s0,288(sp)
    80004df0:	6155                	addi	sp,sp,304
    80004df2:	8082                	ret

0000000080004df4 <sys_unlink>:
{
    80004df4:	7151                	addi	sp,sp,-240
    80004df6:	f586                	sd	ra,232(sp)
    80004df8:	f1a2                	sd	s0,224(sp)
    80004dfa:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004dfc:	08000613          	li	a2,128
    80004e00:	f3040593          	addi	a1,s0,-208
    80004e04:	4501                	li	a0,0
    80004e06:	a1dfd0ef          	jal	80002822 <argstr>
    80004e0a:	16054063          	bltz	a0,80004f6a <sys_unlink+0x176>
    80004e0e:	eda6                	sd	s1,216(sp)
  begin_op();
    80004e10:	e39fe0ef          	jal	80003c48 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004e14:	fb040593          	addi	a1,s0,-80
    80004e18:	f3040513          	addi	a0,s0,-208
    80004e1c:	c73fe0ef          	jal	80003a8e <nameiparent>
    80004e20:	84aa                	mv	s1,a0
    80004e22:	c945                	beqz	a0,80004ed2 <sys_unlink+0xde>
  ilock(dp);
    80004e24:	c3afe0ef          	jal	8000325e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004e28:	00002597          	auipc	a1,0x2
    80004e2c:	7c058593          	addi	a1,a1,1984 # 800075e8 <etext+0x5e8>
    80004e30:	fb040513          	addi	a0,s0,-80
    80004e34:	9c5fe0ef          	jal	800037f8 <namecmp>
    80004e38:	10050e63          	beqz	a0,80004f54 <sys_unlink+0x160>
    80004e3c:	00002597          	auipc	a1,0x2
    80004e40:	7b458593          	addi	a1,a1,1972 # 800075f0 <etext+0x5f0>
    80004e44:	fb040513          	addi	a0,s0,-80
    80004e48:	9b1fe0ef          	jal	800037f8 <namecmp>
    80004e4c:	10050463          	beqz	a0,80004f54 <sys_unlink+0x160>
    80004e50:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004e52:	f2c40613          	addi	a2,s0,-212
    80004e56:	fb040593          	addi	a1,s0,-80
    80004e5a:	8526                	mv	a0,s1
    80004e5c:	9b3fe0ef          	jal	8000380e <dirlookup>
    80004e60:	892a                	mv	s2,a0
    80004e62:	0e050863          	beqz	a0,80004f52 <sys_unlink+0x15e>
  ilock(ip);
    80004e66:	bf8fe0ef          	jal	8000325e <ilock>
  if(ip->nlink < 1)
    80004e6a:	04a91783          	lh	a5,74(s2)
    80004e6e:	06f05763          	blez	a5,80004edc <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004e72:	04491703          	lh	a4,68(s2)
    80004e76:	4785                	li	a5,1
    80004e78:	06f70963          	beq	a4,a5,80004eea <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004e7c:	4641                	li	a2,16
    80004e7e:	4581                	li	a1,0
    80004e80:	fc040513          	addi	a0,s0,-64
    80004e84:	e1ffb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e88:	4741                	li	a4,16
    80004e8a:	f2c42683          	lw	a3,-212(s0)
    80004e8e:	fc040613          	addi	a2,s0,-64
    80004e92:	4581                	li	a1,0
    80004e94:	8526                	mv	a0,s1
    80004e96:	855fe0ef          	jal	800036ea <writei>
    80004e9a:	47c1                	li	a5,16
    80004e9c:	08f51b63          	bne	a0,a5,80004f32 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004ea0:	04491703          	lh	a4,68(s2)
    80004ea4:	4785                	li	a5,1
    80004ea6:	08f70d63          	beq	a4,a5,80004f40 <sys_unlink+0x14c>
  iunlockput(dp);
    80004eaa:	8526                	mv	a0,s1
    80004eac:	dbcfe0ef          	jal	80003468 <iunlockput>
  ip->nlink--;
    80004eb0:	04a95783          	lhu	a5,74(s2)
    80004eb4:	37fd                	addiw	a5,a5,-1
    80004eb6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004eba:	854a                	mv	a0,s2
    80004ebc:	aeefe0ef          	jal	800031aa <iupdate>
  iunlockput(ip);
    80004ec0:	854a                	mv	a0,s2
    80004ec2:	da6fe0ef          	jal	80003468 <iunlockput>
  end_op();
    80004ec6:	dedfe0ef          	jal	80003cb2 <end_op>
  return 0;
    80004eca:	4501                	li	a0,0
    80004ecc:	64ee                	ld	s1,216(sp)
    80004ece:	694e                	ld	s2,208(sp)
    80004ed0:	a849                	j	80004f62 <sys_unlink+0x16e>
    end_op();
    80004ed2:	de1fe0ef          	jal	80003cb2 <end_op>
    return -1;
    80004ed6:	557d                	li	a0,-1
    80004ed8:	64ee                	ld	s1,216(sp)
    80004eda:	a061                	j	80004f62 <sys_unlink+0x16e>
    80004edc:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004ede:	00002517          	auipc	a0,0x2
    80004ee2:	71a50513          	addi	a0,a0,1818 # 800075f8 <etext+0x5f8>
    80004ee6:	8fbfb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004eea:	04c92703          	lw	a4,76(s2)
    80004eee:	02000793          	li	a5,32
    80004ef2:	f8e7f5e3          	bgeu	a5,a4,80004e7c <sys_unlink+0x88>
    80004ef6:	e5ce                	sd	s3,200(sp)
    80004ef8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004efc:	4741                	li	a4,16
    80004efe:	86ce                	mv	a3,s3
    80004f00:	f1840613          	addi	a2,s0,-232
    80004f04:	4581                	li	a1,0
    80004f06:	854a                	mv	a0,s2
    80004f08:	ee6fe0ef          	jal	800035ee <readi>
    80004f0c:	47c1                	li	a5,16
    80004f0e:	00f51c63          	bne	a0,a5,80004f26 <sys_unlink+0x132>
    if(de.inum != 0)
    80004f12:	f1845783          	lhu	a5,-232(s0)
    80004f16:	efa1                	bnez	a5,80004f6e <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f18:	29c1                	addiw	s3,s3,16
    80004f1a:	04c92783          	lw	a5,76(s2)
    80004f1e:	fcf9efe3          	bltu	s3,a5,80004efc <sys_unlink+0x108>
    80004f22:	69ae                	ld	s3,200(sp)
    80004f24:	bfa1                	j	80004e7c <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004f26:	00002517          	auipc	a0,0x2
    80004f2a:	6ea50513          	addi	a0,a0,1770 # 80007610 <etext+0x610>
    80004f2e:	8b3fb0ef          	jal	800007e0 <panic>
    80004f32:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004f34:	00002517          	auipc	a0,0x2
    80004f38:	6f450513          	addi	a0,a0,1780 # 80007628 <etext+0x628>
    80004f3c:	8a5fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80004f40:	04a4d783          	lhu	a5,74(s1)
    80004f44:	37fd                	addiw	a5,a5,-1
    80004f46:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f4a:	8526                	mv	a0,s1
    80004f4c:	a5efe0ef          	jal	800031aa <iupdate>
    80004f50:	bfa9                	j	80004eaa <sys_unlink+0xb6>
    80004f52:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004f54:	8526                	mv	a0,s1
    80004f56:	d12fe0ef          	jal	80003468 <iunlockput>
  end_op();
    80004f5a:	d59fe0ef          	jal	80003cb2 <end_op>
  return -1;
    80004f5e:	557d                	li	a0,-1
    80004f60:	64ee                	ld	s1,216(sp)
}
    80004f62:	70ae                	ld	ra,232(sp)
    80004f64:	740e                	ld	s0,224(sp)
    80004f66:	616d                	addi	sp,sp,240
    80004f68:	8082                	ret
    return -1;
    80004f6a:	557d                	li	a0,-1
    80004f6c:	bfdd                	j	80004f62 <sys_unlink+0x16e>
    iunlockput(ip);
    80004f6e:	854a                	mv	a0,s2
    80004f70:	cf8fe0ef          	jal	80003468 <iunlockput>
    goto bad;
    80004f74:	694e                	ld	s2,208(sp)
    80004f76:	69ae                	ld	s3,200(sp)
    80004f78:	bff1                	j	80004f54 <sys_unlink+0x160>

0000000080004f7a <sys_open>:

uint64
sys_open(void)
{
    80004f7a:	7131                	addi	sp,sp,-192
    80004f7c:	fd06                	sd	ra,184(sp)
    80004f7e:	f922                	sd	s0,176(sp)
    80004f80:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004f82:	f4c40593          	addi	a1,s0,-180
    80004f86:	4505                	li	a0,1
    80004f88:	861fd0ef          	jal	800027e8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f8c:	08000613          	li	a2,128
    80004f90:	f5040593          	addi	a1,s0,-176
    80004f94:	4501                	li	a0,0
    80004f96:	88dfd0ef          	jal	80002822 <argstr>
    80004f9a:	87aa                	mv	a5,a0
    return -1;
    80004f9c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f9e:	0a07c263          	bltz	a5,80005042 <sys_open+0xc8>
    80004fa2:	f526                	sd	s1,168(sp)

  begin_op();
    80004fa4:	ca5fe0ef          	jal	80003c48 <begin_op>

  if(omode & O_CREATE){
    80004fa8:	f4c42783          	lw	a5,-180(s0)
    80004fac:	2007f793          	andi	a5,a5,512
    80004fb0:	c3d5                	beqz	a5,80005054 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004fb2:	4681                	li	a3,0
    80004fb4:	4601                	li	a2,0
    80004fb6:	4589                	li	a1,2
    80004fb8:	f5040513          	addi	a0,s0,-176
    80004fbc:	aa9ff0ef          	jal	80004a64 <create>
    80004fc0:	84aa                	mv	s1,a0
    if(ip == 0){
    80004fc2:	c541                	beqz	a0,8000504a <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004fc4:	04449703          	lh	a4,68(s1)
    80004fc8:	478d                	li	a5,3
    80004fca:	00f71763          	bne	a4,a5,80004fd8 <sys_open+0x5e>
    80004fce:	0464d703          	lhu	a4,70(s1)
    80004fd2:	47a5                	li	a5,9
    80004fd4:	0ae7ed63          	bltu	a5,a4,8000508e <sys_open+0x114>
    80004fd8:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004fda:	fd7fe0ef          	jal	80003fb0 <filealloc>
    80004fde:	892a                	mv	s2,a0
    80004fe0:	c179                	beqz	a0,800050a6 <sys_open+0x12c>
    80004fe2:	ed4e                	sd	s3,152(sp)
    80004fe4:	a43ff0ef          	jal	80004a26 <fdalloc>
    80004fe8:	89aa                	mv	s3,a0
    80004fea:	0a054a63          	bltz	a0,8000509e <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004fee:	04449703          	lh	a4,68(s1)
    80004ff2:	478d                	li	a5,3
    80004ff4:	0cf70263          	beq	a4,a5,800050b8 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004ff8:	4789                	li	a5,2
    80004ffa:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004ffe:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005002:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005006:	f4c42783          	lw	a5,-180(s0)
    8000500a:	0017c713          	xori	a4,a5,1
    8000500e:	8b05                	andi	a4,a4,1
    80005010:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005014:	0037f713          	andi	a4,a5,3
    80005018:	00e03733          	snez	a4,a4
    8000501c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005020:	4007f793          	andi	a5,a5,1024
    80005024:	c791                	beqz	a5,80005030 <sys_open+0xb6>
    80005026:	04449703          	lh	a4,68(s1)
    8000502a:	4789                	li	a5,2
    8000502c:	08f70d63          	beq	a4,a5,800050c6 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005030:	8526                	mv	a0,s1
    80005032:	adafe0ef          	jal	8000330c <iunlock>
  end_op();
    80005036:	c7dfe0ef          	jal	80003cb2 <end_op>

  return fd;
    8000503a:	854e                	mv	a0,s3
    8000503c:	74aa                	ld	s1,168(sp)
    8000503e:	790a                	ld	s2,160(sp)
    80005040:	69ea                	ld	s3,152(sp)
}
    80005042:	70ea                	ld	ra,184(sp)
    80005044:	744a                	ld	s0,176(sp)
    80005046:	6129                	addi	sp,sp,192
    80005048:	8082                	ret
      end_op();
    8000504a:	c69fe0ef          	jal	80003cb2 <end_op>
      return -1;
    8000504e:	557d                	li	a0,-1
    80005050:	74aa                	ld	s1,168(sp)
    80005052:	bfc5                	j	80005042 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005054:	f5040513          	addi	a0,s0,-176
    80005058:	a1dfe0ef          	jal	80003a74 <namei>
    8000505c:	84aa                	mv	s1,a0
    8000505e:	c11d                	beqz	a0,80005084 <sys_open+0x10a>
    ilock(ip);
    80005060:	9fefe0ef          	jal	8000325e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005064:	04449703          	lh	a4,68(s1)
    80005068:	4785                	li	a5,1
    8000506a:	f4f71de3          	bne	a4,a5,80004fc4 <sys_open+0x4a>
    8000506e:	f4c42783          	lw	a5,-180(s0)
    80005072:	d3bd                	beqz	a5,80004fd8 <sys_open+0x5e>
      iunlockput(ip);
    80005074:	8526                	mv	a0,s1
    80005076:	bf2fe0ef          	jal	80003468 <iunlockput>
      end_op();
    8000507a:	c39fe0ef          	jal	80003cb2 <end_op>
      return -1;
    8000507e:	557d                	li	a0,-1
    80005080:	74aa                	ld	s1,168(sp)
    80005082:	b7c1                	j	80005042 <sys_open+0xc8>
      end_op();
    80005084:	c2ffe0ef          	jal	80003cb2 <end_op>
      return -1;
    80005088:	557d                	li	a0,-1
    8000508a:	74aa                	ld	s1,168(sp)
    8000508c:	bf5d                	j	80005042 <sys_open+0xc8>
    iunlockput(ip);
    8000508e:	8526                	mv	a0,s1
    80005090:	bd8fe0ef          	jal	80003468 <iunlockput>
    end_op();
    80005094:	c1ffe0ef          	jal	80003cb2 <end_op>
    return -1;
    80005098:	557d                	li	a0,-1
    8000509a:	74aa                	ld	s1,168(sp)
    8000509c:	b75d                	j	80005042 <sys_open+0xc8>
      fileclose(f);
    8000509e:	854a                	mv	a0,s2
    800050a0:	fb5fe0ef          	jal	80004054 <fileclose>
    800050a4:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800050a6:	8526                	mv	a0,s1
    800050a8:	bc0fe0ef          	jal	80003468 <iunlockput>
    end_op();
    800050ac:	c07fe0ef          	jal	80003cb2 <end_op>
    return -1;
    800050b0:	557d                	li	a0,-1
    800050b2:	74aa                	ld	s1,168(sp)
    800050b4:	790a                	ld	s2,160(sp)
    800050b6:	b771                	j	80005042 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800050b8:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800050bc:	04649783          	lh	a5,70(s1)
    800050c0:	02f91223          	sh	a5,36(s2)
    800050c4:	bf3d                	j	80005002 <sys_open+0x88>
    itrunc(ip);
    800050c6:	8526                	mv	a0,s1
    800050c8:	a84fe0ef          	jal	8000334c <itrunc>
    800050cc:	b795                	j	80005030 <sys_open+0xb6>

00000000800050ce <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800050ce:	7175                	addi	sp,sp,-144
    800050d0:	e506                	sd	ra,136(sp)
    800050d2:	e122                	sd	s0,128(sp)
    800050d4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800050d6:	b73fe0ef          	jal	80003c48 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800050da:	08000613          	li	a2,128
    800050de:	f7040593          	addi	a1,s0,-144
    800050e2:	4501                	li	a0,0
    800050e4:	f3efd0ef          	jal	80002822 <argstr>
    800050e8:	02054363          	bltz	a0,8000510e <sys_mkdir+0x40>
    800050ec:	4681                	li	a3,0
    800050ee:	4601                	li	a2,0
    800050f0:	4585                	li	a1,1
    800050f2:	f7040513          	addi	a0,s0,-144
    800050f6:	96fff0ef          	jal	80004a64 <create>
    800050fa:	c911                	beqz	a0,8000510e <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050fc:	b6cfe0ef          	jal	80003468 <iunlockput>
  end_op();
    80005100:	bb3fe0ef          	jal	80003cb2 <end_op>
  return 0;
    80005104:	4501                	li	a0,0
}
    80005106:	60aa                	ld	ra,136(sp)
    80005108:	640a                	ld	s0,128(sp)
    8000510a:	6149                	addi	sp,sp,144
    8000510c:	8082                	ret
    end_op();
    8000510e:	ba5fe0ef          	jal	80003cb2 <end_op>
    return -1;
    80005112:	557d                	li	a0,-1
    80005114:	bfcd                	j	80005106 <sys_mkdir+0x38>

0000000080005116 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005116:	7135                	addi	sp,sp,-160
    80005118:	ed06                	sd	ra,152(sp)
    8000511a:	e922                	sd	s0,144(sp)
    8000511c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000511e:	b2bfe0ef          	jal	80003c48 <begin_op>
  argint(1, &major);
    80005122:	f6c40593          	addi	a1,s0,-148
    80005126:	4505                	li	a0,1
    80005128:	ec0fd0ef          	jal	800027e8 <argint>
  argint(2, &minor);
    8000512c:	f6840593          	addi	a1,s0,-152
    80005130:	4509                	li	a0,2
    80005132:	eb6fd0ef          	jal	800027e8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005136:	08000613          	li	a2,128
    8000513a:	f7040593          	addi	a1,s0,-144
    8000513e:	4501                	li	a0,0
    80005140:	ee2fd0ef          	jal	80002822 <argstr>
    80005144:	02054563          	bltz	a0,8000516e <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005148:	f6841683          	lh	a3,-152(s0)
    8000514c:	f6c41603          	lh	a2,-148(s0)
    80005150:	458d                	li	a1,3
    80005152:	f7040513          	addi	a0,s0,-144
    80005156:	90fff0ef          	jal	80004a64 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000515a:	c911                	beqz	a0,8000516e <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000515c:	b0cfe0ef          	jal	80003468 <iunlockput>
  end_op();
    80005160:	b53fe0ef          	jal	80003cb2 <end_op>
  return 0;
    80005164:	4501                	li	a0,0
}
    80005166:	60ea                	ld	ra,152(sp)
    80005168:	644a                	ld	s0,144(sp)
    8000516a:	610d                	addi	sp,sp,160
    8000516c:	8082                	ret
    end_op();
    8000516e:	b45fe0ef          	jal	80003cb2 <end_op>
    return -1;
    80005172:	557d                	li	a0,-1
    80005174:	bfcd                	j	80005166 <sys_mknod+0x50>

0000000080005176 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005176:	7135                	addi	sp,sp,-160
    80005178:	ed06                	sd	ra,152(sp)
    8000517a:	e922                	sd	s0,144(sp)
    8000517c:	e14a                	sd	s2,128(sp)
    8000517e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005180:	f4efc0ef          	jal	800018ce <myproc>
    80005184:	892a                	mv	s2,a0
  
  begin_op();
    80005186:	ac3fe0ef          	jal	80003c48 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000518a:	08000613          	li	a2,128
    8000518e:	f6040593          	addi	a1,s0,-160
    80005192:	4501                	li	a0,0
    80005194:	e8efd0ef          	jal	80002822 <argstr>
    80005198:	04054363          	bltz	a0,800051de <sys_chdir+0x68>
    8000519c:	e526                	sd	s1,136(sp)
    8000519e:	f6040513          	addi	a0,s0,-160
    800051a2:	8d3fe0ef          	jal	80003a74 <namei>
    800051a6:	84aa                	mv	s1,a0
    800051a8:	c915                	beqz	a0,800051dc <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800051aa:	8b4fe0ef          	jal	8000325e <ilock>
  if(ip->type != T_DIR){
    800051ae:	04449703          	lh	a4,68(s1)
    800051b2:	4785                	li	a5,1
    800051b4:	02f71963          	bne	a4,a5,800051e6 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800051b8:	8526                	mv	a0,s1
    800051ba:	952fe0ef          	jal	8000330c <iunlock>
  iput(p->cwd);
    800051be:	15093503          	ld	a0,336(s2)
    800051c2:	a1efe0ef          	jal	800033e0 <iput>
  end_op();
    800051c6:	aedfe0ef          	jal	80003cb2 <end_op>
  p->cwd = ip;
    800051ca:	14993823          	sd	s1,336(s2)
  return 0;
    800051ce:	4501                	li	a0,0
    800051d0:	64aa                	ld	s1,136(sp)
}
    800051d2:	60ea                	ld	ra,152(sp)
    800051d4:	644a                	ld	s0,144(sp)
    800051d6:	690a                	ld	s2,128(sp)
    800051d8:	610d                	addi	sp,sp,160
    800051da:	8082                	ret
    800051dc:	64aa                	ld	s1,136(sp)
    end_op();
    800051de:	ad5fe0ef          	jal	80003cb2 <end_op>
    return -1;
    800051e2:	557d                	li	a0,-1
    800051e4:	b7fd                	j	800051d2 <sys_chdir+0x5c>
    iunlockput(ip);
    800051e6:	8526                	mv	a0,s1
    800051e8:	a80fe0ef          	jal	80003468 <iunlockput>
    end_op();
    800051ec:	ac7fe0ef          	jal	80003cb2 <end_op>
    return -1;
    800051f0:	557d                	li	a0,-1
    800051f2:	64aa                	ld	s1,136(sp)
    800051f4:	bff9                	j	800051d2 <sys_chdir+0x5c>

00000000800051f6 <sys_exec>:

uint64
sys_exec(void)
{
    800051f6:	7121                	addi	sp,sp,-448
    800051f8:	ff06                	sd	ra,440(sp)
    800051fa:	fb22                	sd	s0,432(sp)
    800051fc:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800051fe:	e4840593          	addi	a1,s0,-440
    80005202:	4505                	li	a0,1
    80005204:	e00fd0ef          	jal	80002804 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005208:	08000613          	li	a2,128
    8000520c:	f5040593          	addi	a1,s0,-176
    80005210:	4501                	li	a0,0
    80005212:	e10fd0ef          	jal	80002822 <argstr>
    80005216:	87aa                	mv	a5,a0
    return -1;
    80005218:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000521a:	0c07c463          	bltz	a5,800052e2 <sys_exec+0xec>
    8000521e:	f726                	sd	s1,424(sp)
    80005220:	f34a                	sd	s2,416(sp)
    80005222:	ef4e                	sd	s3,408(sp)
    80005224:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005226:	10000613          	li	a2,256
    8000522a:	4581                	li	a1,0
    8000522c:	e5040513          	addi	a0,s0,-432
    80005230:	a73fb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005234:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005238:	89a6                	mv	s3,s1
    8000523a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000523c:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005240:	00391513          	slli	a0,s2,0x3
    80005244:	e4040593          	addi	a1,s0,-448
    80005248:	e4843783          	ld	a5,-440(s0)
    8000524c:	953e                	add	a0,a0,a5
    8000524e:	d10fd0ef          	jal	8000275e <fetchaddr>
    80005252:	02054663          	bltz	a0,8000527e <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005256:	e4043783          	ld	a5,-448(s0)
    8000525a:	c3a9                	beqz	a5,8000529c <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000525c:	8a3fb0ef          	jal	80000afe <kalloc>
    80005260:	85aa                	mv	a1,a0
    80005262:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005266:	cd01                	beqz	a0,8000527e <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005268:	6605                	lui	a2,0x1
    8000526a:	e4043503          	ld	a0,-448(s0)
    8000526e:	d3afd0ef          	jal	800027a8 <fetchstr>
    80005272:	00054663          	bltz	a0,8000527e <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005276:	0905                	addi	s2,s2,1
    80005278:	09a1                	addi	s3,s3,8
    8000527a:	fd4913e3          	bne	s2,s4,80005240 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000527e:	f5040913          	addi	s2,s0,-176
    80005282:	6088                	ld	a0,0(s1)
    80005284:	c931                	beqz	a0,800052d8 <sys_exec+0xe2>
    kfree(argv[i]);
    80005286:	f96fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000528a:	04a1                	addi	s1,s1,8
    8000528c:	ff249be3          	bne	s1,s2,80005282 <sys_exec+0x8c>
  return -1;
    80005290:	557d                	li	a0,-1
    80005292:	74ba                	ld	s1,424(sp)
    80005294:	791a                	ld	s2,416(sp)
    80005296:	69fa                	ld	s3,408(sp)
    80005298:	6a5a                	ld	s4,400(sp)
    8000529a:	a0a1                	j	800052e2 <sys_exec+0xec>
      argv[i] = 0;
    8000529c:	0009079b          	sext.w	a5,s2
    800052a0:	078e                	slli	a5,a5,0x3
    800052a2:	fd078793          	addi	a5,a5,-48
    800052a6:	97a2                	add	a5,a5,s0
    800052a8:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800052ac:	e5040593          	addi	a1,s0,-432
    800052b0:	f5040513          	addi	a0,s0,-176
    800052b4:	ba8ff0ef          	jal	8000465c <kexec>
    800052b8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052ba:	f5040993          	addi	s3,s0,-176
    800052be:	6088                	ld	a0,0(s1)
    800052c0:	c511                	beqz	a0,800052cc <sys_exec+0xd6>
    kfree(argv[i]);
    800052c2:	f5afb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052c6:	04a1                	addi	s1,s1,8
    800052c8:	ff349be3          	bne	s1,s3,800052be <sys_exec+0xc8>
  return ret;
    800052cc:	854a                	mv	a0,s2
    800052ce:	74ba                	ld	s1,424(sp)
    800052d0:	791a                	ld	s2,416(sp)
    800052d2:	69fa                	ld	s3,408(sp)
    800052d4:	6a5a                	ld	s4,400(sp)
    800052d6:	a031                	j	800052e2 <sys_exec+0xec>
  return -1;
    800052d8:	557d                	li	a0,-1
    800052da:	74ba                	ld	s1,424(sp)
    800052dc:	791a                	ld	s2,416(sp)
    800052de:	69fa                	ld	s3,408(sp)
    800052e0:	6a5a                	ld	s4,400(sp)
}
    800052e2:	70fa                	ld	ra,440(sp)
    800052e4:	745a                	ld	s0,432(sp)
    800052e6:	6139                	addi	sp,sp,448
    800052e8:	8082                	ret

00000000800052ea <sys_pipe>:

uint64
sys_pipe(void)
{
    800052ea:	7139                	addi	sp,sp,-64
    800052ec:	fc06                	sd	ra,56(sp)
    800052ee:	f822                	sd	s0,48(sp)
    800052f0:	f426                	sd	s1,40(sp)
    800052f2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800052f4:	ddafc0ef          	jal	800018ce <myproc>
    800052f8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800052fa:	fd840593          	addi	a1,s0,-40
    800052fe:	4501                	li	a0,0
    80005300:	d04fd0ef          	jal	80002804 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005304:	fc840593          	addi	a1,s0,-56
    80005308:	fd040513          	addi	a0,s0,-48
    8000530c:	852ff0ef          	jal	8000435e <pipealloc>
    return -1;
    80005310:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005312:	0a054463          	bltz	a0,800053ba <sys_pipe+0xd0>
  fd0 = -1;
    80005316:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000531a:	fd043503          	ld	a0,-48(s0)
    8000531e:	f08ff0ef          	jal	80004a26 <fdalloc>
    80005322:	fca42223          	sw	a0,-60(s0)
    80005326:	08054163          	bltz	a0,800053a8 <sys_pipe+0xbe>
    8000532a:	fc843503          	ld	a0,-56(s0)
    8000532e:	ef8ff0ef          	jal	80004a26 <fdalloc>
    80005332:	fca42023          	sw	a0,-64(s0)
    80005336:	06054063          	bltz	a0,80005396 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000533a:	4691                	li	a3,4
    8000533c:	fc440613          	addi	a2,s0,-60
    80005340:	fd843583          	ld	a1,-40(s0)
    80005344:	68a8                	ld	a0,80(s1)
    80005346:	a9cfc0ef          	jal	800015e2 <copyout>
    8000534a:	00054e63          	bltz	a0,80005366 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000534e:	4691                	li	a3,4
    80005350:	fc040613          	addi	a2,s0,-64
    80005354:	fd843583          	ld	a1,-40(s0)
    80005358:	0591                	addi	a1,a1,4
    8000535a:	68a8                	ld	a0,80(s1)
    8000535c:	a86fc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005360:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005362:	04055c63          	bgez	a0,800053ba <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005366:	fc442783          	lw	a5,-60(s0)
    8000536a:	07e9                	addi	a5,a5,26
    8000536c:	078e                	slli	a5,a5,0x3
    8000536e:	97a6                	add	a5,a5,s1
    80005370:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005374:	fc042783          	lw	a5,-64(s0)
    80005378:	07e9                	addi	a5,a5,26
    8000537a:	078e                	slli	a5,a5,0x3
    8000537c:	94be                	add	s1,s1,a5
    8000537e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005382:	fd043503          	ld	a0,-48(s0)
    80005386:	ccffe0ef          	jal	80004054 <fileclose>
    fileclose(wf);
    8000538a:	fc843503          	ld	a0,-56(s0)
    8000538e:	cc7fe0ef          	jal	80004054 <fileclose>
    return -1;
    80005392:	57fd                	li	a5,-1
    80005394:	a01d                	j	800053ba <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005396:	fc442783          	lw	a5,-60(s0)
    8000539a:	0007c763          	bltz	a5,800053a8 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000539e:	07e9                	addi	a5,a5,26
    800053a0:	078e                	slli	a5,a5,0x3
    800053a2:	97a6                	add	a5,a5,s1
    800053a4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800053a8:	fd043503          	ld	a0,-48(s0)
    800053ac:	ca9fe0ef          	jal	80004054 <fileclose>
    fileclose(wf);
    800053b0:	fc843503          	ld	a0,-56(s0)
    800053b4:	ca1fe0ef          	jal	80004054 <fileclose>
    return -1;
    800053b8:	57fd                	li	a5,-1
}
    800053ba:	853e                	mv	a0,a5
    800053bc:	70e2                	ld	ra,56(sp)
    800053be:	7442                	ld	s0,48(sp)
    800053c0:	74a2                	ld	s1,40(sp)
    800053c2:	6121                	addi	sp,sp,64
    800053c4:	8082                	ret
	...

00000000800053d0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800053d0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800053d2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800053d4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800053d6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800053d8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800053da:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800053dc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800053de:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800053e0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800053e2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800053e4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800053e6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800053e8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800053ea:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800053ec:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800053ee:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800053f0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800053f2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800053f4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800053f6:	a78fd0ef          	jal	8000266e <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800053fa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800053fc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800053fe:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005400:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005402:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005404:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005406:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005408:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000540a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000540c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000540e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005410:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005412:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005414:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005416:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005418:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000541a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000541c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000541e:	10200073          	sret
	...

000000008000542e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000542e:	1141                	addi	sp,sp,-16
    80005430:	e422                	sd	s0,8(sp)
    80005432:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005434:	0c0007b7          	lui	a5,0xc000
    80005438:	4705                	li	a4,1
    8000543a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000543c:	0c0007b7          	lui	a5,0xc000
    80005440:	c3d8                	sw	a4,4(a5)
}
    80005442:	6422                	ld	s0,8(sp)
    80005444:	0141                	addi	sp,sp,16
    80005446:	8082                	ret

0000000080005448 <plicinithart>:

void
plicinithart(void)
{
    80005448:	1141                	addi	sp,sp,-16
    8000544a:	e406                	sd	ra,8(sp)
    8000544c:	e022                	sd	s0,0(sp)
    8000544e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005450:	c52fc0ef          	jal	800018a2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005454:	0085171b          	slliw	a4,a0,0x8
    80005458:	0c0027b7          	lui	a5,0xc002
    8000545c:	97ba                	add	a5,a5,a4
    8000545e:	40200713          	li	a4,1026
    80005462:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005466:	00d5151b          	slliw	a0,a0,0xd
    8000546a:	0c2017b7          	lui	a5,0xc201
    8000546e:	97aa                	add	a5,a5,a0
    80005470:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005474:	60a2                	ld	ra,8(sp)
    80005476:	6402                	ld	s0,0(sp)
    80005478:	0141                	addi	sp,sp,16
    8000547a:	8082                	ret

000000008000547c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000547c:	1141                	addi	sp,sp,-16
    8000547e:	e406                	sd	ra,8(sp)
    80005480:	e022                	sd	s0,0(sp)
    80005482:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005484:	c1efc0ef          	jal	800018a2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005488:	00d5151b          	slliw	a0,a0,0xd
    8000548c:	0c2017b7          	lui	a5,0xc201
    80005490:	97aa                	add	a5,a5,a0
  return irq;
}
    80005492:	43c8                	lw	a0,4(a5)
    80005494:	60a2                	ld	ra,8(sp)
    80005496:	6402                	ld	s0,0(sp)
    80005498:	0141                	addi	sp,sp,16
    8000549a:	8082                	ret

000000008000549c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000549c:	1101                	addi	sp,sp,-32
    8000549e:	ec06                	sd	ra,24(sp)
    800054a0:	e822                	sd	s0,16(sp)
    800054a2:	e426                	sd	s1,8(sp)
    800054a4:	1000                	addi	s0,sp,32
    800054a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800054a8:	bfafc0ef          	jal	800018a2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800054ac:	00d5151b          	slliw	a0,a0,0xd
    800054b0:	0c2017b7          	lui	a5,0xc201
    800054b4:	97aa                	add	a5,a5,a0
    800054b6:	c3c4                	sw	s1,4(a5)
}
    800054b8:	60e2                	ld	ra,24(sp)
    800054ba:	6442                	ld	s0,16(sp)
    800054bc:	64a2                	ld	s1,8(sp)
    800054be:	6105                	addi	sp,sp,32
    800054c0:	8082                	ret

00000000800054c2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800054c2:	1141                	addi	sp,sp,-16
    800054c4:	e406                	sd	ra,8(sp)
    800054c6:	e022                	sd	s0,0(sp)
    800054c8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800054ca:	479d                	li	a5,7
    800054cc:	04a7ca63          	blt	a5,a0,80005520 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800054d0:	0001b797          	auipc	a5,0x1b
    800054d4:	79878793          	addi	a5,a5,1944 # 80020c68 <disk>
    800054d8:	97aa                	add	a5,a5,a0
    800054da:	0187c783          	lbu	a5,24(a5)
    800054de:	e7b9                	bnez	a5,8000552c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800054e0:	00451693          	slli	a3,a0,0x4
    800054e4:	0001b797          	auipc	a5,0x1b
    800054e8:	78478793          	addi	a5,a5,1924 # 80020c68 <disk>
    800054ec:	6398                	ld	a4,0(a5)
    800054ee:	9736                	add	a4,a4,a3
    800054f0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800054f4:	6398                	ld	a4,0(a5)
    800054f6:	9736                	add	a4,a4,a3
    800054f8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800054fc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005500:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005504:	97aa                	add	a5,a5,a0
    80005506:	4705                	li	a4,1
    80005508:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000550c:	0001b517          	auipc	a0,0x1b
    80005510:	77450513          	addi	a0,a0,1908 # 80020c80 <disk+0x18>
    80005514:	a1dfc0ef          	jal	80001f30 <wakeup>
}
    80005518:	60a2                	ld	ra,8(sp)
    8000551a:	6402                	ld	s0,0(sp)
    8000551c:	0141                	addi	sp,sp,16
    8000551e:	8082                	ret
    panic("free_desc 1");
    80005520:	00002517          	auipc	a0,0x2
    80005524:	11850513          	addi	a0,a0,280 # 80007638 <etext+0x638>
    80005528:	ab8fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000552c:	00002517          	auipc	a0,0x2
    80005530:	11c50513          	addi	a0,a0,284 # 80007648 <etext+0x648>
    80005534:	aacfb0ef          	jal	800007e0 <panic>

0000000080005538 <virtio_disk_init>:
{
    80005538:	1101                	addi	sp,sp,-32
    8000553a:	ec06                	sd	ra,24(sp)
    8000553c:	e822                	sd	s0,16(sp)
    8000553e:	e426                	sd	s1,8(sp)
    80005540:	e04a                	sd	s2,0(sp)
    80005542:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005544:	00002597          	auipc	a1,0x2
    80005548:	11458593          	addi	a1,a1,276 # 80007658 <etext+0x658>
    8000554c:	0001c517          	auipc	a0,0x1c
    80005550:	84450513          	addi	a0,a0,-1980 # 80020d90 <disk+0x128>
    80005554:	dfafb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005558:	100017b7          	lui	a5,0x10001
    8000555c:	4398                	lw	a4,0(a5)
    8000555e:	2701                	sext.w	a4,a4
    80005560:	747277b7          	lui	a5,0x74727
    80005564:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005568:	18f71063          	bne	a4,a5,800056e8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000556c:	100017b7          	lui	a5,0x10001
    80005570:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005572:	439c                	lw	a5,0(a5)
    80005574:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005576:	4709                	li	a4,2
    80005578:	16e79863          	bne	a5,a4,800056e8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000557c:	100017b7          	lui	a5,0x10001
    80005580:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005582:	439c                	lw	a5,0(a5)
    80005584:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005586:	16e79163          	bne	a5,a4,800056e8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000558a:	100017b7          	lui	a5,0x10001
    8000558e:	47d8                	lw	a4,12(a5)
    80005590:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005592:	554d47b7          	lui	a5,0x554d4
    80005596:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000559a:	14f71763          	bne	a4,a5,800056e8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000559e:	100017b7          	lui	a5,0x10001
    800055a2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055a6:	4705                	li	a4,1
    800055a8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055aa:	470d                	li	a4,3
    800055ac:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800055ae:	10001737          	lui	a4,0x10001
    800055b2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800055b4:	c7ffe737          	lui	a4,0xc7ffe
    800055b8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd9b7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800055bc:	8ef9                	and	a3,a3,a4
    800055be:	10001737          	lui	a4,0x10001
    800055c2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055c4:	472d                	li	a4,11
    800055c6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055c8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800055cc:	439c                	lw	a5,0(a5)
    800055ce:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800055d2:	8ba1                	andi	a5,a5,8
    800055d4:	12078063          	beqz	a5,800056f4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800055d8:	100017b7          	lui	a5,0x10001
    800055dc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800055e0:	100017b7          	lui	a5,0x10001
    800055e4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800055e8:	439c                	lw	a5,0(a5)
    800055ea:	2781                	sext.w	a5,a5
    800055ec:	10079a63          	bnez	a5,80005700 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800055f0:	100017b7          	lui	a5,0x10001
    800055f4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800055f8:	439c                	lw	a5,0(a5)
    800055fa:	2781                	sext.w	a5,a5
  if(max == 0)
    800055fc:	10078863          	beqz	a5,8000570c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005600:	471d                	li	a4,7
    80005602:	10f77b63          	bgeu	a4,a5,80005718 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005606:	cf8fb0ef          	jal	80000afe <kalloc>
    8000560a:	0001b497          	auipc	s1,0x1b
    8000560e:	65e48493          	addi	s1,s1,1630 # 80020c68 <disk>
    80005612:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005614:	ceafb0ef          	jal	80000afe <kalloc>
    80005618:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000561a:	ce4fb0ef          	jal	80000afe <kalloc>
    8000561e:	87aa                	mv	a5,a0
    80005620:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005622:	6088                	ld	a0,0(s1)
    80005624:	10050063          	beqz	a0,80005724 <virtio_disk_init+0x1ec>
    80005628:	0001b717          	auipc	a4,0x1b
    8000562c:	64873703          	ld	a4,1608(a4) # 80020c70 <disk+0x8>
    80005630:	0e070a63          	beqz	a4,80005724 <virtio_disk_init+0x1ec>
    80005634:	0e078863          	beqz	a5,80005724 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005638:	6605                	lui	a2,0x1
    8000563a:	4581                	li	a1,0
    8000563c:	e66fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005640:	0001b497          	auipc	s1,0x1b
    80005644:	62848493          	addi	s1,s1,1576 # 80020c68 <disk>
    80005648:	6605                	lui	a2,0x1
    8000564a:	4581                	li	a1,0
    8000564c:	6488                	ld	a0,8(s1)
    8000564e:	e54fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005652:	6605                	lui	a2,0x1
    80005654:	4581                	li	a1,0
    80005656:	6888                	ld	a0,16(s1)
    80005658:	e4afb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000565c:	100017b7          	lui	a5,0x10001
    80005660:	4721                	li	a4,8
    80005662:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005664:	4098                	lw	a4,0(s1)
    80005666:	100017b7          	lui	a5,0x10001
    8000566a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000566e:	40d8                	lw	a4,4(s1)
    80005670:	100017b7          	lui	a5,0x10001
    80005674:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005678:	649c                	ld	a5,8(s1)
    8000567a:	0007869b          	sext.w	a3,a5
    8000567e:	10001737          	lui	a4,0x10001
    80005682:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005686:	9781                	srai	a5,a5,0x20
    80005688:	10001737          	lui	a4,0x10001
    8000568c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005690:	689c                	ld	a5,16(s1)
    80005692:	0007869b          	sext.w	a3,a5
    80005696:	10001737          	lui	a4,0x10001
    8000569a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000569e:	9781                	srai	a5,a5,0x20
    800056a0:	10001737          	lui	a4,0x10001
    800056a4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800056a8:	10001737          	lui	a4,0x10001
    800056ac:	4785                	li	a5,1
    800056ae:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800056b0:	00f48c23          	sb	a5,24(s1)
    800056b4:	00f48ca3          	sb	a5,25(s1)
    800056b8:	00f48d23          	sb	a5,26(s1)
    800056bc:	00f48da3          	sb	a5,27(s1)
    800056c0:	00f48e23          	sb	a5,28(s1)
    800056c4:	00f48ea3          	sb	a5,29(s1)
    800056c8:	00f48f23          	sb	a5,30(s1)
    800056cc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800056d0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800056d4:	100017b7          	lui	a5,0x10001
    800056d8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800056dc:	60e2                	ld	ra,24(sp)
    800056de:	6442                	ld	s0,16(sp)
    800056e0:	64a2                	ld	s1,8(sp)
    800056e2:	6902                	ld	s2,0(sp)
    800056e4:	6105                	addi	sp,sp,32
    800056e6:	8082                	ret
    panic("could not find virtio disk");
    800056e8:	00002517          	auipc	a0,0x2
    800056ec:	f8050513          	addi	a0,a0,-128 # 80007668 <etext+0x668>
    800056f0:	8f0fb0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    800056f4:	00002517          	auipc	a0,0x2
    800056f8:	f9450513          	addi	a0,a0,-108 # 80007688 <etext+0x688>
    800056fc:	8e4fb0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005700:	00002517          	auipc	a0,0x2
    80005704:	fa850513          	addi	a0,a0,-88 # 800076a8 <etext+0x6a8>
    80005708:	8d8fb0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000570c:	00002517          	auipc	a0,0x2
    80005710:	fbc50513          	addi	a0,a0,-68 # 800076c8 <etext+0x6c8>
    80005714:	8ccfb0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005718:	00002517          	auipc	a0,0x2
    8000571c:	fd050513          	addi	a0,a0,-48 # 800076e8 <etext+0x6e8>
    80005720:	8c0fb0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005724:	00002517          	auipc	a0,0x2
    80005728:	fe450513          	addi	a0,a0,-28 # 80007708 <etext+0x708>
    8000572c:	8b4fb0ef          	jal	800007e0 <panic>

0000000080005730 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005730:	7159                	addi	sp,sp,-112
    80005732:	f486                	sd	ra,104(sp)
    80005734:	f0a2                	sd	s0,96(sp)
    80005736:	eca6                	sd	s1,88(sp)
    80005738:	e8ca                	sd	s2,80(sp)
    8000573a:	e4ce                	sd	s3,72(sp)
    8000573c:	e0d2                	sd	s4,64(sp)
    8000573e:	fc56                	sd	s5,56(sp)
    80005740:	f85a                	sd	s6,48(sp)
    80005742:	f45e                	sd	s7,40(sp)
    80005744:	f062                	sd	s8,32(sp)
    80005746:	ec66                	sd	s9,24(sp)
    80005748:	1880                	addi	s0,sp,112
    8000574a:	8a2a                	mv	s4,a0
    8000574c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000574e:	00c52c83          	lw	s9,12(a0)
    80005752:	001c9c9b          	slliw	s9,s9,0x1
    80005756:	1c82                	slli	s9,s9,0x20
    80005758:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000575c:	0001b517          	auipc	a0,0x1b
    80005760:	63450513          	addi	a0,a0,1588 # 80020d90 <disk+0x128>
    80005764:	c6afb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    80005768:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000576a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000576c:	0001bb17          	auipc	s6,0x1b
    80005770:	4fcb0b13          	addi	s6,s6,1276 # 80020c68 <disk>
  for(int i = 0; i < 3; i++){
    80005774:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005776:	0001bc17          	auipc	s8,0x1b
    8000577a:	61ac0c13          	addi	s8,s8,1562 # 80020d90 <disk+0x128>
    8000577e:	a8b9                	j	800057dc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005780:	00fb0733          	add	a4,s6,a5
    80005784:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005788:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000578a:	0207c563          	bltz	a5,800057b4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000578e:	2905                	addiw	s2,s2,1
    80005790:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005792:	05590963          	beq	s2,s5,800057e4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005796:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005798:	0001b717          	auipc	a4,0x1b
    8000579c:	4d070713          	addi	a4,a4,1232 # 80020c68 <disk>
    800057a0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800057a2:	01874683          	lbu	a3,24(a4)
    800057a6:	fee9                	bnez	a3,80005780 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800057a8:	2785                	addiw	a5,a5,1
    800057aa:	0705                	addi	a4,a4,1
    800057ac:	fe979be3          	bne	a5,s1,800057a2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800057b0:	57fd                	li	a5,-1
    800057b2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800057b4:	01205d63          	blez	s2,800057ce <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800057b8:	f9042503          	lw	a0,-112(s0)
    800057bc:	d07ff0ef          	jal	800054c2 <free_desc>
      for(int j = 0; j < i; j++)
    800057c0:	4785                	li	a5,1
    800057c2:	0127d663          	bge	a5,s2,800057ce <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800057c6:	f9442503          	lw	a0,-108(s0)
    800057ca:	cf9ff0ef          	jal	800054c2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057ce:	85e2                	mv	a1,s8
    800057d0:	0001b517          	auipc	a0,0x1b
    800057d4:	4b050513          	addi	a0,a0,1200 # 80020c80 <disk+0x18>
    800057d8:	f0cfc0ef          	jal	80001ee4 <sleep>
  for(int i = 0; i < 3; i++){
    800057dc:	f9040613          	addi	a2,s0,-112
    800057e0:	894e                	mv	s2,s3
    800057e2:	bf55                	j	80005796 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057e4:	f9042503          	lw	a0,-112(s0)
    800057e8:	00451693          	slli	a3,a0,0x4

  if(write)
    800057ec:	0001b797          	auipc	a5,0x1b
    800057f0:	47c78793          	addi	a5,a5,1148 # 80020c68 <disk>
    800057f4:	00a50713          	addi	a4,a0,10
    800057f8:	0712                	slli	a4,a4,0x4
    800057fa:	973e                	add	a4,a4,a5
    800057fc:	01703633          	snez	a2,s7
    80005800:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005802:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005806:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000580a:	6398                	ld	a4,0(a5)
    8000580c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000580e:	0a868613          	addi	a2,a3,168
    80005812:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005814:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005816:	6390                	ld	a2,0(a5)
    80005818:	00d605b3          	add	a1,a2,a3
    8000581c:	4741                	li	a4,16
    8000581e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005820:	4805                	li	a6,1
    80005822:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005826:	f9442703          	lw	a4,-108(s0)
    8000582a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000582e:	0712                	slli	a4,a4,0x4
    80005830:	963a                	add	a2,a2,a4
    80005832:	058a0593          	addi	a1,s4,88
    80005836:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005838:	0007b883          	ld	a7,0(a5)
    8000583c:	9746                	add	a4,a4,a7
    8000583e:	40000613          	li	a2,1024
    80005842:	c710                	sw	a2,8(a4)
  if(write)
    80005844:	001bb613          	seqz	a2,s7
    80005848:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000584c:	00166613          	ori	a2,a2,1
    80005850:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005854:	f9842583          	lw	a1,-104(s0)
    80005858:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000585c:	00250613          	addi	a2,a0,2
    80005860:	0612                	slli	a2,a2,0x4
    80005862:	963e                	add	a2,a2,a5
    80005864:	577d                	li	a4,-1
    80005866:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000586a:	0592                	slli	a1,a1,0x4
    8000586c:	98ae                	add	a7,a7,a1
    8000586e:	03068713          	addi	a4,a3,48
    80005872:	973e                	add	a4,a4,a5
    80005874:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005878:	6398                	ld	a4,0(a5)
    8000587a:	972e                	add	a4,a4,a1
    8000587c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005880:	4689                	li	a3,2
    80005882:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005886:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000588a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000588e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005892:	6794                	ld	a3,8(a5)
    80005894:	0026d703          	lhu	a4,2(a3)
    80005898:	8b1d                	andi	a4,a4,7
    8000589a:	0706                	slli	a4,a4,0x1
    8000589c:	96ba                	add	a3,a3,a4
    8000589e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800058a2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800058a6:	6798                	ld	a4,8(a5)
    800058a8:	00275783          	lhu	a5,2(a4)
    800058ac:	2785                	addiw	a5,a5,1
    800058ae:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800058b2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800058b6:	100017b7          	lui	a5,0x10001
    800058ba:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800058be:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800058c2:	0001b917          	auipc	s2,0x1b
    800058c6:	4ce90913          	addi	s2,s2,1230 # 80020d90 <disk+0x128>
  while(b->disk == 1) {
    800058ca:	4485                	li	s1,1
    800058cc:	01079a63          	bne	a5,a6,800058e0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800058d0:	85ca                	mv	a1,s2
    800058d2:	8552                	mv	a0,s4
    800058d4:	e10fc0ef          	jal	80001ee4 <sleep>
  while(b->disk == 1) {
    800058d8:	004a2783          	lw	a5,4(s4)
    800058dc:	fe978ae3          	beq	a5,s1,800058d0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800058e0:	f9042903          	lw	s2,-112(s0)
    800058e4:	00290713          	addi	a4,s2,2
    800058e8:	0712                	slli	a4,a4,0x4
    800058ea:	0001b797          	auipc	a5,0x1b
    800058ee:	37e78793          	addi	a5,a5,894 # 80020c68 <disk>
    800058f2:	97ba                	add	a5,a5,a4
    800058f4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800058f8:	0001b997          	auipc	s3,0x1b
    800058fc:	37098993          	addi	s3,s3,880 # 80020c68 <disk>
    80005900:	00491713          	slli	a4,s2,0x4
    80005904:	0009b783          	ld	a5,0(s3)
    80005908:	97ba                	add	a5,a5,a4
    8000590a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000590e:	854a                	mv	a0,s2
    80005910:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005914:	bafff0ef          	jal	800054c2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005918:	8885                	andi	s1,s1,1
    8000591a:	f0fd                	bnez	s1,80005900 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000591c:	0001b517          	auipc	a0,0x1b
    80005920:	47450513          	addi	a0,a0,1140 # 80020d90 <disk+0x128>
    80005924:	b42fb0ef          	jal	80000c66 <release>
}
    80005928:	70a6                	ld	ra,104(sp)
    8000592a:	7406                	ld	s0,96(sp)
    8000592c:	64e6                	ld	s1,88(sp)
    8000592e:	6946                	ld	s2,80(sp)
    80005930:	69a6                	ld	s3,72(sp)
    80005932:	6a06                	ld	s4,64(sp)
    80005934:	7ae2                	ld	s5,56(sp)
    80005936:	7b42                	ld	s6,48(sp)
    80005938:	7ba2                	ld	s7,40(sp)
    8000593a:	7c02                	ld	s8,32(sp)
    8000593c:	6ce2                	ld	s9,24(sp)
    8000593e:	6165                	addi	sp,sp,112
    80005940:	8082                	ret

0000000080005942 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005942:	1101                	addi	sp,sp,-32
    80005944:	ec06                	sd	ra,24(sp)
    80005946:	e822                	sd	s0,16(sp)
    80005948:	e426                	sd	s1,8(sp)
    8000594a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000594c:	0001b497          	auipc	s1,0x1b
    80005950:	31c48493          	addi	s1,s1,796 # 80020c68 <disk>
    80005954:	0001b517          	auipc	a0,0x1b
    80005958:	43c50513          	addi	a0,a0,1084 # 80020d90 <disk+0x128>
    8000595c:	a72fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005960:	100017b7          	lui	a5,0x10001
    80005964:	53b8                	lw	a4,96(a5)
    80005966:	8b0d                	andi	a4,a4,3
    80005968:	100017b7          	lui	a5,0x10001
    8000596c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000596e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005972:	689c                	ld	a5,16(s1)
    80005974:	0204d703          	lhu	a4,32(s1)
    80005978:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000597c:	04f70663          	beq	a4,a5,800059c8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005980:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005984:	6898                	ld	a4,16(s1)
    80005986:	0204d783          	lhu	a5,32(s1)
    8000598a:	8b9d                	andi	a5,a5,7
    8000598c:	078e                	slli	a5,a5,0x3
    8000598e:	97ba                	add	a5,a5,a4
    80005990:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005992:	00278713          	addi	a4,a5,2
    80005996:	0712                	slli	a4,a4,0x4
    80005998:	9726                	add	a4,a4,s1
    8000599a:	01074703          	lbu	a4,16(a4)
    8000599e:	e321                	bnez	a4,800059de <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800059a0:	0789                	addi	a5,a5,2
    800059a2:	0792                	slli	a5,a5,0x4
    800059a4:	97a6                	add	a5,a5,s1
    800059a6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800059a8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800059ac:	d84fc0ef          	jal	80001f30 <wakeup>

    disk.used_idx += 1;
    800059b0:	0204d783          	lhu	a5,32(s1)
    800059b4:	2785                	addiw	a5,a5,1
    800059b6:	17c2                	slli	a5,a5,0x30
    800059b8:	93c1                	srli	a5,a5,0x30
    800059ba:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800059be:	6898                	ld	a4,16(s1)
    800059c0:	00275703          	lhu	a4,2(a4)
    800059c4:	faf71ee3          	bne	a4,a5,80005980 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800059c8:	0001b517          	auipc	a0,0x1b
    800059cc:	3c850513          	addi	a0,a0,968 # 80020d90 <disk+0x128>
    800059d0:	a96fb0ef          	jal	80000c66 <release>
}
    800059d4:	60e2                	ld	ra,24(sp)
    800059d6:	6442                	ld	s0,16(sp)
    800059d8:	64a2                	ld	s1,8(sp)
    800059da:	6105                	addi	sp,sp,32
    800059dc:	8082                	ret
      panic("virtio_disk_intr status");
    800059de:	00002517          	auipc	a0,0x2
    800059e2:	d4250513          	addi	a0,a0,-702 # 80007720 <etext+0x720>
    800059e6:	dfbfa0ef          	jal	800007e0 <panic>
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
