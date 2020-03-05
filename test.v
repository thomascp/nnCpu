
`timescale 1ns / 1ps

module test
(
);

	reg CLK	  = 0;
	reg RST_N = 0;

	initial
	begin
		$display("---reset---");
		#(50000) RST_N = 1;
	end

	integer i;
	initial
	begin
		$dumpfile("test.vcd");
		$dumpvars;
		for (i = 0; i < 10; i++)
			$dumpvars(0, nnRvSoc.RAM[i]);
		for (i = 0; i < 32; i++)
			$dumpvars(0, nnRvSoc.REG[i]);

		for (i = 0; i < 1000; i++)
			#(1000000) CLK = !CLK;
	end

	wire [3:0] LED;
	wire [1:0] KEY;

	nnRvSoc nnRvSoc(RST_N, CLK, KEY, LED);

endmodule

