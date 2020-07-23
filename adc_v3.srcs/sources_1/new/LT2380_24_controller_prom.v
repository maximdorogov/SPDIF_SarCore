`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.01.2020 20:39:56
// Design Name: 
// Module Name: LT2380_24_controller_prom
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


module LT2380_24_controller_prom(

        input i_clk,   
        input i_reset,
        input i_BUSY,
        input i_SDO, 
        input [1:0]i_Fs,      //sampling frequency
              
        output o_SCK,
        output reg o_CNV,
        output reg [23:0]o_dataOutput24b, //parallel output
        output reg o_dataValid,
        output reg o_SPDIF_clk

       
    );
    

//o_CNV related signals
    
localparam DELAY_MAX = 6;  // o_CNV length measured in clock pulses  
localparam SDI_DATABITS = 48;  //24 x 2

/*
------------------  ADC Clocking Scheme ----------------
SPDIF_clk = 128xFs

Fs = 48Khz ->  averaging = 32x   SPDIF_clk = 6.144M (6.125M with 100M clk)
Fs = 96Khz ->  averaging = 16x   SPDIF_clk = 12.288M (12.5M with 100M clk)
Fs = 192Khz ->  averaging = 8x   SPDIF_clk = 24.576M (25M with 100M clk)
Fs = 384Khz ->  averaging = 4x   SPDIF_clk = 49.152M (50M with 100M clk)
*/

//localparam AVG_FS = 8; //96Khz sampling rate

reg [5:0]clk_divider;
reg sig_dly; // aux signal for CNV pulse generation
wire CNV_posedge; //CNV 1 clock pulse length
reg start_ctr, long_pulse;
reg [3:0]pulse_ctr;
reg read_data;

reg [5:0]AVG_FS;



/*
clock division assingments
*/    
wire clk_50MHZ = clk_divider[0] ;	// (128*384)  49.152 MHz clock (50MHz with 100M clk)
wire clk_25MHZ = clk_divider[1];	// (128*192)  24.576 MHz clock (25MHz with 100M clk)
wire clk_12MHZ = clk_divider[2];	// (128*96)  12.288 MHz clock (12.5MHz with 100M clk)
wire clk_6MHZ = clk_divider[3];	// (128*48)   6.144 MHz clock (6.125MHz with 100M clk)    
wire max_sampling = clk_divider[5]; // -- 1562.5 kHz (384x4/192x8/96x16/48x32)

/*
signal aquisition and acquiring
*/
wire BUSY_negedge;
reg busy_dly;
reg sck_ctr_start;
reg [5:0]sck_ctr;
reg sck_ena;
reg [5:0]AVG_ctr;
reg [23:0] o_parData;    

assign o_SCK = sck_ena & clk_divider[0];

always @(posedge i_clk) begin

    case(i_Fs)
         2'b00: begin //48kHZ
                    AVG_FS <= 6'd32;
                    o_SPDIF_clk <= clk_6MHZ;
                end
         2'b01: begin //96KHZ
                    AVG_FS <= 6'd16;
                    o_SPDIF_clk <=  clk_12MHZ; 
                end
         2'b10: begin //192Khz
                    AVG_FS <= 6'd8;
                    o_SPDIF_clk <=  clk_25MHZ;
                end
         2'b11: begin   //1,5Mhz
                    AVG_FS <= 6'd0;
                    o_SPDIF_clk <= 1'b0; //No hay spdif si Fs es 1.5Mhz
                end
     endcase

end


/*
main clock divider for all used frequencies
*/
always @(posedge i_clk) begin
     if (i_reset) begin
         clk_divider <= 6'b0;
     end
     else  begin
        clk_divider   <= clk_divider + 6'b1;           
     end
 end 
     
/*
Pos edge detector for CNV pulse generation
*/
assign CNV_posedge = max_sampling & ~sig_dly; 

 always @ (posedge i_clk) begin
    sig_dly <= max_sampling;
 end

/*
Neg edge detector for BUSY signal
*/
assign BUSY_negedge =  busy_dly & ~i_BUSY; 

 always @ (posedge i_clk) begin
    busy_dly <= i_BUSY;
 end


/*
o_CNV pulse generation
*/
  
always @ (posedge i_clk) begin
    if (i_reset) begin
        pulse_ctr <= 4'b0;
        start_ctr <=1'b0;
    end
    else
    if (CNV_posedge) begin      
        o_CNV <= 1'b1;
        start_ctr  <= 1'b1;        
     end
     else if (start_ctr == 1'b1) begin
        pulse_ctr = pulse_ctr + 4'b1;
     end
     if( pulse_ctr == DELAY_MAX ) begin
        pulse_ctr <= 4'b0;
        start_ctr <=1'b0;
        o_CNV <= 1'b0;
     end
 end
 
/*
SCK signal generation 
*/

  always @ (posedge i_clk) begin
    if (i_reset) begin

        sck_ena <= 1'b0;
        sck_ctr_start <=1'b0;
        sck_ctr <= 6'b0;
    end
    else
    if(BUSY_negedge) begin
        if(read_data) begin    
            sck_ena <= 1'b1; 
            sck_ctr_start <= 1'b1;
        end
        else begin
            sck_ena <= sck_ena; 
            sck_ctr_start <= sck_ctr_start;
        end
    end
    else if(sck_ctr_start == 1'b1) begin
         sck_ctr <=  sck_ctr + 1'b1;
    end
    if(sck_ctr >= SDI_DATABITS) begin
     
        sck_ena <= 1'b0;
        sck_ctr_start <= 1'b0;
        sck_ctr <= 6'b0;    
    end
 end
/*
Average Filter
*/
 always @ (posedge i_clk) begin
    if (i_reset) begin
        AVG_ctr <= 6'b0;
        read_data <= 1'b0;                 
    end
    else if(CNV_posedge) begin
        AVG_ctr <= AVG_ctr + 6'b1;       
    end
    else begin
        AVG_ctr <= AVG_ctr;
    end    
    if( AVG_ctr == AVG_FS) begin
        AVG_ctr <= 6'b0;
        read_data <= 1'b1; 
    end
    else if (BUSY_negedge) begin
        read_data <= 1'b0;  
    end
    
 end

/*
Serial data to 24 bit parallel output
*/
 always @ (posedge i_clk) begin
    if (i_reset) begin
        o_dataValid <= 1'b0;
        o_parData <= 24'b0;
        o_dataOutput24b <= 24'b0;
    end
    else    
    case(sck_ctr)
        0: o_dataValid <= 1'b0;
        2: o_parData[23] <= i_SDO;
        4: o_parData[22] <= i_SDO;
        6: o_parData[21]<= i_SDO;
        8: o_parData[20] <= i_SDO;
        10:o_parData[19] <= i_SDO;
        12:o_parData[18] <= i_SDO;
        14:o_parData[17] <= i_SDO;
        16:o_parData[16] <= i_SDO;
        18:o_parData[15] <= i_SDO;
        20:o_parData[14] <= i_SDO;
        22:o_parData[13] <= i_SDO;
        24:o_parData[12] <= i_SDO;
        26:o_parData[11] <= i_SDO;
        28:o_parData[10] <= i_SDO;
        30:o_parData[9] <= i_SDO;
        32:o_parData[8] <= i_SDO;
        34:o_parData[7] <= i_SDO;
        36:o_parData[6] <= i_SDO;
        38:o_parData[5] <= i_SDO;
        40:o_parData[4] <= i_SDO;
        42:o_parData[3] <= i_SDO;
        44:o_parData[2] <= i_SDO;
        46:o_parData[1] <= i_SDO;
        48: 
            begin 
                o_parData[0] <= i_SDO;
                o_dataOutput24b <= o_parData;
                o_dataValid <= 1'b1;
            end
        default: begin
                    o_dataValid <= 1'b0;
                    //o_parData <= o_parData;
                 end
    endcase
 end
  
endmodule
