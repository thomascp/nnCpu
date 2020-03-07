
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
		RAM[0000]=32'h20080000
;		RAM[0001]=32'h20100000
;		RAM[0002]=32'h01208000
;		RAM[0003]=32'h00200000
;		RAM[0004]=32'h01288000
;		RAM[0005]=32'h00281000
;		RAM[0006]=32'h01308000
;		RAM[0007]=32'h00301004
;		RAM[0008]=32'h20380000
;		RAM[0009]=32'h00380001
;		RAM[0010]=32'h20400000
;		RAM[0011]=32'h00400010
;		RAM[0012]=32'h20480000
;		RAM[0013]=32'h00480014
;		RAM[0014]=32'h00080000
;		RAM[0015]=32'h01080014
;		RAM[0016]=32'h41094000
;		RAM[0017]=32'h41098000
;		RAM[0018]=32'h40090000
;		RAM[0019]=32'h20100000
;		RAM[0020]=32'h00100001
;		RAM[0021]=32'h25108200
;		RAM[0022]=32'h001800ac
;		RAM[0023]=32'h01180000
;		RAM[0024]=32'h61188000
;		RAM[0025]=32'h00100002
;		RAM[0026]=32'h25108200
;		RAM[0027]=32'h001800e0
;		RAM[0028]=32'h01180000
;		RAM[0029]=32'h61188000
;		RAM[0030]=32'h00100004
;		RAM[0031]=32'h25108200
;		RAM[0032]=32'h00180114
;		RAM[0033]=32'h01180000
;		RAM[0034]=32'h61188000
;		RAM[0035]=32'h00100008
;		RAM[0036]=32'h25108200
;		RAM[0037]=32'h00180148
;		RAM[0038]=32'h01180000
;		RAM[0039]=32'h61188000
;		RAM[0040]=32'h0018017c
;		RAM[0041]=32'h01180000
;		RAM[0042]=32'h611fc000
;		RAM[0043]=32'h40094000
;		RAM[0044]=32'h20100000
;		RAM[0045]=32'h0010ffff
;		RAM[0046]=32'h25188200
;		RAM[0047]=32'h2118d200
;		RAM[0048]=32'h23105000
;		RAM[0049]=32'h21109200
;		RAM[0050]=32'h22109000
;		RAM[0051]=32'h26088600
;		RAM[0052]=32'h41094000
;		RAM[0053]=32'h0018017c
;		RAM[0054]=32'h01180000
;		RAM[0055]=32'h611fc000
;		RAM[0056]=32'h40094000
;		RAM[0057]=32'h20100000
;		RAM[0058]=32'h0010ffff
;		RAM[0059]=32'h25188200
;		RAM[0060]=32'h2018d200
;		RAM[0061]=32'h23105000
;		RAM[0062]=32'h20109200
;		RAM[0063]=32'h22109000
;		RAM[0064]=32'h26088600
;		RAM[0065]=32'h41094000
;		RAM[0066]=32'h0018017c
;		RAM[0067]=32'h01180000
;		RAM[0068]=32'h611fc000
;		RAM[0069]=32'h40098000
;		RAM[0070]=32'h20100000
;		RAM[0071]=32'h0010ffff
;		RAM[0072]=32'h25188200
;		RAM[0073]=32'h2118d200
;		RAM[0074]=32'h23105000
;		RAM[0075]=32'h21109200
;		RAM[0076]=32'h22109000
;		RAM[0077]=32'h26088600
;		RAM[0078]=32'h41098000
;		RAM[0079]=32'h0018017c
;		RAM[0080]=32'h01180000
;		RAM[0081]=32'h611fc000
;		RAM[0082]=32'h40098000
;		RAM[0083]=32'h20100000
;		RAM[0084]=32'h0010ffff
;		RAM[0085]=32'h25188200
;		RAM[0086]=32'h2018d200
;		RAM[0087]=32'h23105000
;		RAM[0088]=32'h20109200
;		RAM[0089]=32'h22109000
;		RAM[0090]=32'h26088600
;		RAM[0091]=32'h41098000
;		RAM[0092]=32'h0018017c
;		RAM[0093]=32'h01180000
;		RAM[0094]=32'h611fc000
;		RAM[0095]=32'h20100000
;		RAM[0096]=32'h00180190
;		RAM[0097]=32'h01180000
;		RAM[0098]=32'h20080000
;		RAM[0099]=32'h00080080
;		RAM[0100]=32'h20108e00
;		RAM[0101]=32'h62188200
;		RAM[0102]=32'h20180000
;		RAM[0103]=32'h00180048
;		RAM[0104]=32'h01180000
;		RAM[0105]=32'h611fc000
;	end

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

