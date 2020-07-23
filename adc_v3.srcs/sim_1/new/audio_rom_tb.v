`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2020 20:30:29
// Design Name: 
// Module Name: audio_rom_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module audio_rom_tb();

    reg clk,rst;
    wire [23:0]audio_data;
    wire [8:0]read_addr;
    wire spdif_clk,clk_48KHZ;
    
    signal_gen
        DUT(
    
        .i_clk(clk),
        .i_reset(~rst),
        .o_spdif_clk(spdif_clk),
        .o_audioSample(audio_data),
        .pulse_48khz(clk_48KHZ)
    
    ); 
    
  /*  audio_rom
        DUT(
        .i_clk(clk),
        .i_enable(1'b1),
        .i_rst(~rst),
        .read_addr(read_addr),
        .o_data(audio_data)
    
    );
    */
    initial begin
				clk = 1'b0;
				rst = 1'b0;
			#10000 $finish;
	end
	
    always #5 	clk = ~clk;
    always #40  rst = 1'b1;
    
    
endmodule
