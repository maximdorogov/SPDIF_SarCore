`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2020 16:17:54
// Design Name: 
// Module Name: audio_gen_top
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


module audio_gen_top(
    
    input clk,
    input i_reset,  //neg reset
    input [1:0]sw,
    // Audio output    
    output o_SPDIF    //Serial Digital Audio Output.
    
    );
 
  wire SPDF_CLK,clk_98MHZ,clk_48KHZ;
  wire [23:0]parData24;
   
  clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(clk_98MHZ),     // output clk_out1
    // Status and control signals
    .reset(~i_reset), // input reset
   // Clock in ports
    .clk_in1(clk));      // input clk_in1 
 
 signal_gen
    DUT
    (
        .i_clk(clk_98MHZ),
        .i_reset(~i_reset),
        .o_spdif_clk(SPDF_CLK),
        .o_audioSample(parData24),
        .pulse_48khz(clk_48KHZ)
    
    );
 
 F8_SPDIF_TX
    u_SPDIF_TX
    (
        .bit_clock(SPDF_CLK),
        .data_in(parData24),
        .address_out(),
        .spdif_out(o_SPDIF)
    );
    
    ila_0 your_instance_name (
	.clk(clk), // input wire clk
	.probe0(~i_reset), // input wire [0:0]  probe0  
	.probe1(SPDF_CLK), // input wire [0:0]  probe1 
	.probe2(clk_48KHZ), // input wire [0:0]  probe2 
	.probe3(o_SPDIF), // input wire [0:0]  probe3 
	.probe4(parData24) // input wire [23:0]  probe4
);    
    
endmodule
