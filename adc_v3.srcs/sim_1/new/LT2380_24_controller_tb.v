`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.01.2020 13:05:43
// Design Name: 
// Module Name: LT2380_24_controller_tb
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


module LT2380_24_controller_tb(

    );
    
    wire o_CNV,o_SCK,data_valid;
	reg clk,rst,busy;
	wire [5:0]sck_ctr;
	
LT2380_24_controller
    U_LT2380_24_controller
    (   
        .i_clk(clk),   
        .i_reset(~rst),      
        .i_BUSY(busy),
        .i_SDO(),        
        .o_SCK(o_SCK),
        .o_CNV(o_CNV),
        .o_parData(), //parallel output
        .o_dataValid(data_valid),
        .sck_ctr(sck_ctr)
      
    );

 initial begin
				clk = 1'b0;
				busy = 1'b0;
				rst = 1'b0;
			#10000 $finish;
	end
	
    always #5 	clk = ~clk;
    always #40  rst = 1'b1;
    
    always@(o_CNV)
        begin
            if(o_CNV == 0) begin
                #15 busy = 1'b1;
                #30 busy = 1'b0;
            end
            else
               busy = 1'b0; 
        end 
  
    
endmodule
