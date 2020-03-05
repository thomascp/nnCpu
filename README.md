# nnCpu
simple new ISA, and correspond implementation niannian CPU, niannian assembler

1. instr code:

I-Type:
|--Op(8 bits)---|---Rd(5 bits)---|---NU(3 bits)---|---uImm(16 bits)---|
R-Type:
|--Op(8 bits)---|---Rd(5 bits)---|---Rs1(5 bits)---|---Rs2(5 bits)---|---NU(9 bits)---|

OP = MOP(3 bits) + SOP(5 bits)

2. instr type:

2.1. get uImm

MOP = 0x0

Rd[31:x]  = uImm
Rd[x-1:0] = uImm

lul rd, uImm_16bit
SOP = 0x0
luh rd, uImm_16bit
SOP = 0x1

1st rise, uImm, rd_idx

2.2 Logical

MOP = 0x1

Rd = Rs1 oper Rs2
	oper : add, sub, lls, lrs, ars, and, or, xor
	SOP	 : 0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7

xxx rd, rs1, rs2

2.3. Load and Store

MOP = 0x2

Rd = mem[Rs1 + Rs2]
SOP = 0x0
mem[Rs1 + Rs2] = Rd
sop = 0x1

ldr rd, rs1, rs2
str rd, rs1, rs2

2.4. jump

MOP = 0x3

Jumpxxx Rd, Rs1, Rs2
xxx means (eq, ne, lt, ge)
SOP = 0x0 1 2 3

jxxx rd, rs1, rs2

