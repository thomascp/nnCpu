
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

	nnRvSoc nnRvSoc(RST_N, CLK, {BTNR, BTNL}, LED);

endmodule

