
`timescale 1ns / 1ps

module nexys_a7_nnCpu
(
);

	reg RST_N = 0;
	reg CLK = 0;
	reg [1:0] count = 0;
	reg BTND = 0;
	reg BTNU = 0;
	reg BTNR = 1;
	reg BTNL = 0;
	wire [7:0] LED;
	wire [31:0] vga_x [1:0];
	wire [31:0] vga_y [1:0];
	reg  CLK100MHZ = 0;

	integer i;
	initial
	begin
		$dumpfile("test.vcd");
		$dumpvars;
		for (i = 0; i < 100; i++)
			$dumpvars(0, nnRvSoc.RAM[i]);
		for (i = 0; i < 32; i++)
			$dumpvars(0, nnRvSoc.REG[i]);

		for (i = 0; i < 100000; i++)
			#(1) CLK100MHZ = !CLK100MHZ;
	end

	initial
	begin
		#10000 BTNR = 1; BTNL = 0;
		#10000 BTNR = 0; BTNL = 1;
		#10000 BTNR = 1; BTNL = 0;
		#10000 BTNR = 0; BTNL = 1;
		#10000 BTNR = 1; BTNL = 0;
		#10000 BTNR = 0; BTNL = 1;
		#10000 BTNR = 1; BTNL = 0;
		#10000 BTNR = 0; BTNL = 1;
	end

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

	nnRvSoc nnRvSoc(RST_N, CLK, {BTND, BTNU, BTNR, BTNL}, LED, vga_x[0], vga_y[0], vga_x[1], vga_y[1]);

endmodule

