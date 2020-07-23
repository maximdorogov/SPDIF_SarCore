`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.01.2020 21:47:47
// Design Name: 
// Module Name: LT2380_24_controller_prom_tb
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

module LT2380_24_controller_prom_tb(

    );
    
    wire o_CNV,o_SCK,data_valid,spdf_CLK;
	reg clk,rst,busy;
	wire [5:0]sck_ctr;
	wire [5:0]AVG_ctr;
	wire read_enable;
	
LT2380_24_controller_prom
    U_LT2380_24_controller
    (   
        .i_clk(clk),   
        .i_reset(~rst),      
        .i_BUSY(busy),
        .i_SDO(),
        .i_Fs(2'b10),
        
        .o_SPDIF_clk(spdf_CLK),        
        .o_SCK(o_SCK),
        .o_CNV(o_CNV),
        .o_dataOutput24b(), //parallel output
        .o_dataValid(data_valid)
      
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
