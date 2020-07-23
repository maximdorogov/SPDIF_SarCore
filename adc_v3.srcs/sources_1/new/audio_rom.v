`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2020 18:01:59
// Design Name: 
// Module Name: audio_rom
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


module audio_rom(
    
        input i_clk,
        input i_enable,
        input i_rst,
        output reg [23:0]o_data,
        output reg [8:0]read_addr
    
    );
    
    localparam AUDIO_SAMPLES = 480;
    localparam INIT_FILE = "sin_1khz_48k.mem";
    
    reg [24:0]data_rom[AUDIO_SAMPLES-1:0]; 
    
    always@(posedge i_clk)begin
        if(i_rst) begin
            read_addr <= 0;
            o_data <= 23'b0;
        end
        else
        if(i_enable)
            begin
                read_addr <=  read_addr + 1; 
                o_data <= data_rom[read_addr];
                
                if(read_addr >= AUDIO_SAMPLES-1)begin
                     read_addr <= 0;
                end
			/*else
			    read_addr <= read_addr;*/
		end
	end
    
    generate
		initial
			$readmemh(INIT_FILE, data_rom);
	endgenerate
    
    
endmodule
