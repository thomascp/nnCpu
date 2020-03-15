
module nexys_a7_nnCpu
(
    input  CLK100MHZ,
    input  BTNL,
    input  BTNR,
    input  BTNU,
    input  BTND,
    output [7:0] LED,
    output VGA_HS,
    output VGA_VS,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B
);

	reg RST_N = 0;
	reg VGA_RST = 0;
	reg CLK = 0;
	reg [15:0] count = 0;
	wire [31:0] vga_x[1:0];
	wire [31:0] vga_y[1:0];

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

	nnRvSoc nnRvSoc(RST_N, CLK, {BTND, BTNU, BTNR, BTNL}, LED, vga_x, vga_y);
	vgaTop  vgaTop(CLK100MHZ, VGA_RST, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B, vga_x, vga_y);

endmodule

