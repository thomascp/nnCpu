
`define RAM_SIZE	1024
`define REG_NUM		32
`define REG_SIZE	4

`define MOP_UIMM	0
`define MOP_LOGI	1
`define MOP_MEMY	2
`define MOP_JUMP	3

`define SOP_UIMM_L	0
`define SOP_UIMM_H	1

`define SOP_LOGI_ADD	0
`define SOP_LOGI_SUB	1
`define SOP_LOGI_LLS	2
`define SOP_LOGI_LRS	3
`define SOP_LOGI_ARS	4
`define SOP_LOGI_AND	5
`define SOP_LOGI_OR	6
`define SOP_LOGI_XOR	7

`define SOP_MEMY_L	0
`define SOP_MEMY_S	1

`define SOP_JUMP_EQ	0
`define SOP_JUMP_NE	1
`define SOP_JUMP_LT	2
`define SOP_JUMP_GE	3

`define PF_KEY_IN	32'h80000000
`define PF_LED_OUT	32'h80000004
`define PF_VGA_X	32'h80001000
`define PF_VGA_Y	32'h80001004

module nnRvSoc
(
	input		RST_N,
	input		CLK,
	input     [3:0]	KEY,
	output    [7:0]	LED,
	output   [31:0] VGA_X,
	output   [31:0] VGA_Y
);
	reg [31:0] RAM [0:`RAM_SIZE-1];
	reg [31:0] REG [0:`REG_NUM-1];
	reg [31:0] jump_pc;

	reg [31:0] LED_OUTPUT;
	reg [31:0] VGA_X_OUTPUT;
	reg [31:0] VGA_Y_OUTPUT;

	assign LED = LED_OUTPUT[7:0];
	assign VGA_X = VGA_X_OUTPUT;
	assign VGA_Y = VGA_Y_OUTPUT;

	integer i;
	initial
	begin
		LED_OUTPUT = 0;
		VGA_X_OUTPUT = 0;
		VGA_Y_OUTPUT = 0;
	end

	initial
	begin
		RAM_INIT_PROCESS
	end

	initial
	begin
		for (i = 0; i < `REG_NUM; i=i+1)
		begin
			REG[i] = 32'd0;
		end
		jump_pc = 32'd0;
	end

	wire [31:0] instr	= RAM[REG[31][31:2]];

	wire [7:0]  instr_oper	= instr[31:24];
	wire [4:0]  instr_rd	= instr[23:19];
	wire [4:0]  instr_rs1	= instr[18:14];
	wire [4:0]  instr_rs2	= instr[13:9];
	wire [15:0] instr_uimm	= instr[15:0];

	wire [2:0]  oper_mop	= instr_oper[7:5];
	wire [4:0]  oper_sop	= instr_oper[4:0];

	wire [31:0] ldr_str_addr= REG[instr_rs1] + REG[instr_rs2];

	wire memory_stall = 0;
	wire jump_stall = (oper_mop == `MOP_JUMP) && (
				((oper_sop == `SOP_JUMP_EQ) && (REG[instr_rs1] == REG[instr_rs2])) ||
				((oper_sop == `SOP_JUMP_NE) && (REG[instr_rs1] != REG[instr_rs2])) ||
				((oper_sop == `SOP_JUMP_LT) && (REG[instr_rs1] <  REG[instr_rs2])) ||
				((oper_sop == `SOP_JUMP_GE) && (REG[instr_rs1] >= REG[instr_rs2]))
				);
	wire stall = jump_stall | memory_stall;

	always@(posedge CLK)
	begin
		if (RST_N)
		begin
			if (oper_mop == `MOP_UIMM)
			begin
				case (oper_sop)
					`SOP_UIMM_L	: REG[instr_rd][15:0]  <= instr_uimm;
					`SOP_UIMM_H	: REG[instr_rd][31:16] <= instr_uimm;
				endcase

			end

			if (oper_mop == `MOP_LOGI)
			begin
				case (oper_sop)
					`SOP_LOGI_ADD	: REG[instr_rd] <= REG[instr_rs1] +   REG[instr_rs2];
					`SOP_LOGI_SUB	: REG[instr_rd] <= REG[instr_rs1] -   REG[instr_rs2];
					`SOP_LOGI_LLS	: REG[instr_rd] <= REG[instr_rs1] <<  REG[instr_rs2];
					`SOP_LOGI_LRS	: REG[instr_rd] <= REG[instr_rs1] >>  REG[instr_rs2];
					`SOP_LOGI_ARS	: REG[instr_rd] <= REG[instr_rs1] >>> REG[instr_rs2];
					`SOP_LOGI_AND	: REG[instr_rd] <= REG[instr_rs1] & REG[instr_rs2];
					`SOP_LOGI_OR	: REG[instr_rd] <= REG[instr_rs1] | REG[instr_rs2];
					`SOP_LOGI_XOR	: REG[instr_rd] <= REG[instr_rs1] ^ REG[instr_rs2];
				endcase
			end

			if (oper_mop == `MOP_JUMP && jump_stall)
			begin
				case (oper_sop)
					`SOP_JUMP_EQ	: if (REG[instr_rs1] == REG[instr_rs2]) 
								jump_pc = REG[instr_rd];
					`SOP_JUMP_NE	: if (REG[instr_rs1] != REG[instr_rs2]) 
								jump_pc = REG[instr_rd];
					`SOP_JUMP_LT	: if (REG[instr_rs1] <  REG[instr_rs2]) 
								jump_pc = REG[instr_rd];
					`SOP_JUMP_GE	: if (REG[instr_rs1] >= REG[instr_rs2]) 
								jump_pc = REG[instr_rd];
				endcase
			end

			if (oper_mop == `MOP_MEMY)
			begin
				case (oper_sop)
					`SOP_MEMY_L	:
							if (ldr_str_addr == `PF_KEY_IN)
								REG[instr_rd] <= {28'd0, KEY};
							else if (ldr_str_addr == `PF_LED_OUT)
								REG[instr_rd] <= LED_OUTPUT;
							else if (ldr_str_addr == `PF_VGA_X)
								REG[instr_rd] <= VGA_X_OUTPUT;
							else if (ldr_str_addr == `PF_VGA_Y)
								REG[instr_rd] <= VGA_Y_OUTPUT;
							else
								REG[instr_rd] <= RAM[ldr_str_addr[31:2]];

					`SOP_MEMY_S	:
							if (ldr_str_addr == `PF_LED_OUT)
								LED_OUTPUT <= REG[instr_rd];
							else if (ldr_str_addr == `PF_VGA_X)
								VGA_X_OUTPUT <= REG[instr_rd];
							else if (ldr_str_addr == `PF_VGA_Y)
								VGA_Y_OUTPUT <= REG[instr_rd];
							else
								RAM[ldr_str_addr[31:2]] <= REG[instr_rd];
				endcase
			end

			if (stall == 0)
				REG[31] = REG[31] + 4;
			else if (jump_stall)
				REG[31] = jump_pc;

		end
	end

endmodule

