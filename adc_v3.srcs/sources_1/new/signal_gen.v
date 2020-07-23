`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2020 17:15:23
// Design Name: 
// Module Name: signal_gen
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


module signal_gen(
    
    input i_clk,
    input i_reset,
    output o_spdif_clk,
    output [23:0]o_audioSample,
    output  pulse_48khz
    );
    
localparam CTR_MAX_48KHZ = 1024;
    
reg [5:0]clk_divider;    

wire clk_25MHZ = clk_divider[1];	// (128*192)  24.576 MHz clock 
wire clk_12MHZ = clk_divider[2];	// (128*96)  12.288 MHz clock 
wire clk_6MHZ = clk_divider[3];	    // (128*48)   6.144 MHz clock    

reg [10:0]counterRead;
assign pulse_48khz = (counterRead == (CTR_MAX_48KHZ-1)) ? 1'b1 : 1'b0;

assign o_spdif_clk = clk_6MHZ;


always @(posedge i_clk) begin
     if (i_reset) begin
         counterRead <= 10'b0;
     end
     else  begin
         counterRead   <=  counterRead + 10'b1;           
     end
 end  

always @(posedge i_clk) begin
     if (i_reset) begin
         clk_divider <= 6'b0;
     end
     else  begin
        clk_divider   <= clk_divider + 6'b1;           
     end
 end         
 
 audio_rom
    u_rom
    (
        .i_clk(i_clk),
        .i_enable(pulse_48khz),
        .i_rst(i_reset),
        .o_data(o_audioSample)
     );
            
endmodule
