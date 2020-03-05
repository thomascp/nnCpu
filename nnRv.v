
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

module nnRvSoc
(
	input		RST_N,
	input		CLK,
	input     [1:0]	KEY,
	output    [7:0]	LED
);
	reg [31:0] RAM [0:`RAM_SIZE-1];
	reg [31:0] REG [0:`REG_NUM-1];
	reg [31:0] jump_pc;

	reg [31:0] OUTPUT;

	assign LED = OUTPUT[7:0];

	integer i;
	initial
	begin
	   OUTPUT = 0;
		RAM[00]=32'h20080000;
		RAM[01]=32'h20100000;
		RAM[02]=32'h20180000;
		RAM[03]=32'h00180080;
		RAM[04]=32'h20200000;
		RAM[05]=32'h01208000;
		RAM[06]=32'h20280000;
		RAM[07]=32'h01288000;
		RAM[08]=32'h00280004;
		RAM[09]=32'h20300000;
		RAM[10]=32'h00300001;
		RAM[11]=32'h00500001;
		RAM[12]=32'h41514000;
		RAM[13]=32'h40390000;
		RAM[14]=32'h20400000;
		RAM[15]=32'h00400001;
		RAM[16]=32'h25420e00;
		RAM[17]=32'h00480070;
		RAM[18]=32'h01480000;
		RAM[19]=32'h614a0000;
		RAM[20]=32'h00400002;
		RAM[21]=32'h25420e00;
		RAM[22]=32'h00480088;
		RAM[23]=32'h01480000;
		RAM[24]=32'h614a0000;
		RAM[25]=32'h00480094;
		RAM[26]=32'h01480000;
		RAM[27]=32'h614fc000;
		RAM[28]=32'h40394000;
		RAM[29]=32'h2239cc00;
		RAM[30]=32'h41394000;
		RAM[31]=32'h00480094;
		RAM[32]=32'h01480000;
		RAM[33]=32'h614fc000;
		RAM[34]=32'h40394000;
		RAM[35]=32'h2339cc00;
		RAM[36]=32'h41394000;
		RAM[37]=32'h20100000;
		RAM[38]=32'h004800a0;
		RAM[39]=32'h01480000;
		RAM[40]=32'h20108c00;
		RAM[41]=32'h62488600;
		RAM[42]=32'h20480000;
		RAM[43]=32'h00480034;
		RAM[44]=32'h01480000;
		RAM[45]=32'h614fc000;
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
								REG[instr_rd] <= {30'd0, KEY};
							else if (ldr_str_addr == `PF_LED_OUT)
								REG[instr_rd] <= OUTPUT;
							else
								REG[instr_rd] <= RAM[ldr_str_addr[31:2]];

					`SOP_MEMY_S	:
							if (ldr_str_addr == `PF_LED_OUT)
								OUTPUT <= REG[instr_rd];
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

