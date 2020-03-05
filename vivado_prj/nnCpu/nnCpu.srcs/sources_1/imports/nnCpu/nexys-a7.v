
module nexys_a7_nnCpu
(
    input  CLK100MHZ,
    input  BTNL,
    input  BTNR,
    output [7:0] LED
);

	reg RST_N = 0;
	reg CLK = 0;
	reg [15:0] count = 0;

	always @ (posedge(CLK100MHZ))
	begin
		count <= count + 1;
		if (count == 0)
		begin
			CLK = !CLK;
			if (RST_N == 0)
				RST_N = 1;
		end
	end

	// assign LED[0] = count[23];
	// assign LED[1] = CLK;
	// assign LED[2] = RST_N;
	// assign LED[3] = BTNL;
	// assign LED[4] = BTNR;
	
	//reg [31:0] RAM [7:0];
	//initial
	//begin
	//   RAM[0] = 32'hffff5a5a;
	//end
	//
	//reg [31:0] RAMFF = 0;
	//
	//always@(posedge CLK)
	//begin
	//   RAMFF <= RAM[0];
	//end
	//assign LED = RAMFF[7:0];

	nnRvSoc nnRvSoc(RST_N, CLK, {BTNR, BTNL}, LED);

endmodule

