
`define RAM_SIZE	2048
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
`define PF_VGA_X_R	32'h80001000
`define PF_VGA_Y_R	32'h80001004
`define PF_VGA_X_G	32'h80001008
`define PF_VGA_Y_G	32'h8000100c

module nnRvSoc
(
	input		RST_N,
	input		CLK,
	input     [3:0]	KEY,
	output    [7:0]	LED,
	output   [31:0] VGA_X_R,
	output   [31:0] VGA_Y_R,
	output   [31:0] VGA_X_G,
	output   [31:0] VGA_Y_G
);
	reg [31:0] RAM [0:`RAM_SIZE-1];
	reg [31:0] REG [0:`REG_NUM-1];
	reg [31:0] jump_pc;

	reg [31:0] LED_OUTPUT;
	reg [31:0] VGA_X_R_OUTPUT;
	reg [31:0] VGA_Y_R_OUTPUT;
	reg [31:0] VGA_X_G_OUTPUT;
	reg [31:0] VGA_Y_G_OUTPUT;

	assign LED = LED_OUTPUT[7:0];
	assign VGA_X_R = VGA_X_R_OUTPUT;
	assign VGA_Y_R = VGA_Y_R_OUTPUT;
	assign VGA_X_G = VGA_X_G_OUTPUT;
	assign VGA_Y_G = VGA_Y_G_OUTPUT;

	integer i;
	initial
	begin
		LED_OUTPUT = 0;
		VGA_X_R_OUTPUT = 0;
		VGA_Y_R_OUTPUT = 0;
		VGA_X_G_OUTPUT = 0;
		VGA_Y_G_OUTPUT = 0;
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
		REG[30] = (`RAM_SIZE - 1) * 4;
		jump_pc = 32'd0;
	end

	wire [31:0] ALL0	= 0;
	wire [31:0] ALL1	= -1;
	wire [31:0] instr	= RAM[REG[31][31:2]];

	wire [7:0]  instr_oper	= instr[31:24];
	wire [4:0]  instr_rd	= instr[23:19];
	wire [4:0]  instr_rs1	= instr[18:14];
	wire [4:0]  instr_rs2	= instr[13:9];
	wire [15:0] instr_uimm	= instr[15:0];
	wire [31:0] instr_simm  = { instr[8] ? ALL1[31:9]:ALL0[31:9], instr[8:0] };
	wire [31:0] instr_calc_rs2
				= REG[instr_rs2] + instr_simm;

	wire [2:0]  oper_mop	= instr_oper[7:5];
	wire [4:0]  oper_sop	= instr_oper[4:0];

	wire [31:0] ldr_str_addr= REG[instr_rs1] + instr_calc_rs2;
	wire [31:0] jump_addr	= REG[instr_rd] + instr_simm;

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
			if (oper_mop == `MOP_UIMM && instr_rd != 0)
			begin
				case (oper_sop)
					`SOP_UIMM_L	: REG[instr_rd][15:0]  <= instr_uimm;
					`SOP_UIMM_H	: REG[instr_rd][31:16] <= instr_uimm;
				endcase

			end

			if (oper_mop == `MOP_LOGI && instr_rd != 0)
			begin
				case (oper_sop)
					`SOP_LOGI_ADD	: REG[instr_rd] <= REG[instr_rs1] +   instr_calc_rs2;
					`SOP_LOGI_SUB	: REG[instr_rd] <= REG[instr_rs1] -   instr_calc_rs2;
					`SOP_LOGI_LLS	: REG[instr_rd] <= REG[instr_rs1] <<  instr_calc_rs2;
					`SOP_LOGI_LRS	: REG[instr_rd] <= REG[instr_rs1] >>  instr_calc_rs2;
					`SOP_LOGI_ARS	: REG[instr_rd] <= REG[instr_rs1] >>> instr_calc_rs2;
					`SOP_LOGI_AND	: REG[instr_rd] <= REG[instr_rs1] & instr_calc_rs2;
					`SOP_LOGI_OR	: REG[instr_rd] <= REG[instr_rs1] | instr_calc_rs2;
					`SOP_LOGI_XOR	: REG[instr_rd] <= REG[instr_rs1] ^ instr_calc_rs2;
				endcase
			end

			if (oper_mop == `MOP_JUMP && jump_stall)
			begin
				case (oper_sop)
					`SOP_JUMP_EQ	: if (REG[instr_rs1] == REG[instr_rs2])
								jump_pc = jump_addr;
					`SOP_JUMP_NE	: if (REG[instr_rs1] != REG[instr_rs2])
								jump_pc = jump_addr;
					`SOP_JUMP_LT	: if (REG[instr_rs1] <  REG[instr_rs2])
								jump_pc = jump_addr;
					`SOP_JUMP_GE	: if (REG[instr_rs1] >= REG[instr_rs2])
								jump_pc = jump_addr;
				endcase
			end

			if (oper_mop == `MOP_MEMY)
			begin
				case (oper_sop)
					`SOP_MEMY_L	:
							if (instr_rd != 0)
							begin
							if (ldr_str_addr == `PF_KEY_IN)
								REG[instr_rd] <= {28'd0, KEY};
							else if (ldr_str_addr == `PF_LED_OUT)
								REG[instr_rd] <= LED_OUTPUT;
							else if (ldr_str_addr == `PF_VGA_X_R)
								REG[instr_rd] <= VGA_X_R_OUTPUT;
							else if (ldr_str_addr == `PF_VGA_Y_R)
								REG[instr_rd] <= VGA_Y_R_OUTPUT;
							else if (ldr_str_addr == `PF_VGA_X_G)
								REG[instr_rd] <= VGA_X_G_OUTPUT;
							else if (ldr_str_addr == `PF_VGA_Y_G)
								REG[instr_rd] <= VGA_Y_G_OUTPUT;
							else
								REG[instr_rd] <= RAM[ldr_str_addr[31:2]];
							end

					`SOP_MEMY_S	:
							if (ldr_str_addr == `PF_LED_OUT)
								LED_OUTPUT <= REG[instr_rd];
							else if (ldr_str_addr == `PF_VGA_X_R)
								VGA_X_R_OUTPUT <= REG[instr_rd];
							else if (ldr_str_addr == `PF_VGA_Y_R)
								VGA_Y_R_OUTPUT <= REG[instr_rd];
							else if (ldr_str_addr == `PF_VGA_X_G)
								VGA_X_G_OUTPUT <= REG[instr_rd];
							else if (ldr_str_addr == `PF_VGA_Y_G)
								VGA_Y_G_OUTPUT <= REG[instr_rd];
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

