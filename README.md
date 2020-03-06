# nnCpu
# This project contains:
1. design of a very simple ISA
2. SOC + CPU named nnRv, nn is my daughter's name niannian, this whole thing is as 'simple' as my little daughter.
3. assembler, so you can write some code, build and run it in simulations.

This is a totally useless project, but just a hobby for me which makes me understand the basic concept of ISA, CPU etc.

# About this ISA

```
r0 - r31 32 general registers
r0  - zero
r31 - pc

1) instr code:

I-Type:
|--Op(8 bits)---|---Rd(5 bits)---|---NU(3 bits)---|---uImm(16 bits)---|
R-Type:
|--Op(8 bits)---|---Rd(5 bits)---|---Rs1(5 bits)---|---Rs2(5 bits)---|---NU(9 bits)---|

OP = MOP(3 bits) + SOP(5 bits)

2) instr type:

2.1) get uImm

MOP = 0x0

Rd[31:x]  = uImm
Rd[x-1:0] = uImm

lul rd, uImm_16bit
SOP = 0x0
luh rd, uImm_16bit
SOP = 0x1

1st rise, uImm, rd_idx

2.2) Logical

MOP = 0x1

Rd = Rs1 oper Rs2
	oper : add, sub, lls, lrs, ars, and, or, xor
	SOP	 : 0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7

xxx rd, rs1, rs2

2.3) Load and Store

MOP = 0x2

Rd = mem[Rs1 + Rs2]
SOP = 0x0
mem[Rs1 + Rs2] = Rd
sop = 0x1

ldr rd, rs1, rs2
str rd, rs1, rs2

2.4) jump

MOP = 0x3

Jumpxxx Rd, Rs1, Rs2
xxx means (eq, ne, lt, ge)
SOP = 0x0 1 2 3

jxxx rd, rs1, rs2
```

# About the SOC Periperals

```
0x80000000 gpio in  KEY[1:0] 2-DOWN 1-UP 0-LEFT 1-RIGHT
0x80000004 gpio out LED[7:0]
0x80001000 VGA square x [31:16] left-x [15:0] right-x
0x80001004 VGA square y [31:16] up-y [15:0] down-y
```

# How to play it
```
If you have a nexys-a7 board, you can open the project file and program it into the board.
There are two branches,
nexys-a7 uses BTNR and BTNL as input, LED0-8 as output, if you press
BTNR, the lighted LED should shift to left side, if you press BTNL, the lighted LED should shift
to right. Notes: if you press BTNL when the LED[0] is lighted, all of the LED will be off,
because the 1 bit is shifted out of the register.
nexys-a7 uses BTNR, BTNL, BTNU, BTND to control a red square which will show on VGA screen.

If you don't have a board, you can checkout sim branch, and use 'make sim' to run a simple code
in iverilog simulation tool.
```
