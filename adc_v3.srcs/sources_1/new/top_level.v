`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.01.2020 21:55:51
// Design Name: 
// Module Name: top_level
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


module top_level(
    input clk,
    input i_reset,  //neg reset
      
    input i_BUSY,
    input i_SDO,
    output  o_CNV,    //sample clock
    output  o_SCK,    //Transmition clock
    
    input [1:0]sw,
    // Audio output    
    output o_SPDIF    //Serial Digital Audio Output.
    );

 wire smp,cnv_neg,data_valid,SPDF_CLK,clk_98MHZ;
 wire [23:0]parData24;  
 reg i_busy_sync;
/*
i_BUSY sinchro
*/

 always @(posedge clk_98MHZ) begin
 if(~i_reset) begin
    i_busy_sync <= 1'b0;
 end
 else
    i_busy_sync <= i_BUSY;  
 end

//LT2380_24_controller
//    U_LT2380_24_controller
//    (   
//        .i_clk(clk),   
//        .i_reset(~i_reset),      
//        .i_BUSY(i_busy_sync),
//        .i_SDO(i_SDO),        
//        .o_SCK(o_SCK),
//        .o_CNV(o_CNV),
//        .o_dataOutput24b(parData24), //parallel output
//        .o_dataValid(data_valid),
//        .sck_ctr()        
//    );

  clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(clk_98MHZ),     // output clk_out1
    // Status and control signals
    .reset(~i_reset), // input reset
   // Clock in ports
    .clk_in1(clk));      // input clk_in1
    
LT2380_24_controller_prom
    U_LT2380_24_controller
    (   
        .i_clk(clk_98MHZ),   
        .i_reset(~i_reset),      
        .i_BUSY(i_busy_sync),
        .i_SDO(i_SDO),        
        .o_SCK(o_SCK),
        .o_CNV(o_CNV),
        .o_dataOutput24b(parData24), //parallel output
        .o_dataValid(data_valid),
        .i_Fs(sw),  /*00 -> 48khz 01 -> 96khz 10 -> 192khz 11-> 1.5625 MHz*/
        .o_SPDIF_clk(SPDF_CLK)
    
    );
    
F8_SPDIF_TX
    u_SPDIF_TX
    (
        .bit_clock(SPDF_CLK),
        .data_in(parData24),
        .address_out(),
        .spdif_out(o_SPDIF)
    );    
/*

*/ 
/*   
ila_0 your_instance_name (
	.clk(clk), // input wire clk

	.probe0(i_busy_sync), // input wire [0:0]  probe0  
	.probe1(o_SCK), // input wire [0:0]  probe1 
	.probe2(data_valid), // input wire [0:0]  probe2
	.probe3(o_CNV),
	.probe4(parData24) // input wire [23:0]  probe4

);
*/
    
endmodule