// FPGA VGA Graphics Part 1: Top Module (static squares in 800x600)
// (C)2018 Will Green - Licensed under the MIT License
// Learn more at https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

module vgaTop(
    input  wire CLK,             // board clock: 100 MHz on Arty/Basys3/Nexys
    input  wire RST_BTN,         // reset button
    output wire VGA_HS_O,       // horizontal sync output
    output wire VGA_VS_O,       // vertical sync output
    output wire [3:0] VGA_R,    // 4-bit VGA red output
    output wire [3:0] VGA_G,    // 4-bit VGA green output
    output wire [3:0] VGA_B,    // 4-bit VGA blue output
    input  wire [31:0] vga_x_r,
    input  wire [31:0] vga_y_r,
    input  wire [31:0] vga_x_g,
    input  wire [31:0] vga_y_g
    );

    // wire rst = ~RST_BTN;    // reset is active low on Arty & Nexys Video
    wire rst = RST_BTN;  // reset is active high on Basys3 (BTNC)

    // generate a 40 MHz pixel strobe
    reg [15:0] cnt;
    reg pix_stb;
    always @(posedge CLK)
        {pix_stb, cnt} <= cnt + 16'h6666;  // divide by 2.5: (2^16)/2.5 = 0x6666

    wire [10:0] x;  // current pixel x position: 11-bit value: 0-2047
    wire  [9:0] y;  // current pixel y position: 10-bit value: 0-1023

    vga800x600 display (
        .i_clk(CLK),
        .i_pix_stb(pix_stb),
        .i_rst(rst),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x), 
        .o_y(y)
    );

    wire sq_r;
    wire sq_g;
    assign sq_r = ((x > vga_x_r[31:16]) & (y > vga_y_r[31:16]) & (x < vga_x_r[15:0]) & (y < vga_y_r[15:0])) ? 1 : 0;
    assign sq_g = ((x > vga_x_g[31:16]) & (y > vga_y_g[31:16]) & (x < vga_x_g[15:0]) & (y < vga_y_g[15:0])) ? 1 : 0;

    assign VGA_R[3] = sq_r;
    assign VGA_G[3] = sq_g;
endmodule
