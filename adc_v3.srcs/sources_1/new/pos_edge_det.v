`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.01.2020 23:54:48
// Design Name: 
// Module Name: pos_edge_det
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


module pos_edge_det ( input clk,            // Input signal for clock
                      input sig,            // Input signal for which positive edge has to be detected                      
                      output pulse);           // Output signal that gives a pulse when a positive edge occurs
 
    reg   sig_dly;                          // Internal signal to store the delayed version of signal
 
    // This always block ensures that sig_dly is exactly 1 clock behind sig
  always @ (posedge clk) begin
    sig_dly <= sig;
  end
 
    // Combinational logic where sig is AND with delayed, inverted version of sig
    // Assign statement assigns the evaluated expression in the RHS to the internal net pe
  assign pulse = sig & ~sig_dly;            
endmodule 
