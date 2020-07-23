`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.01.2020 22:11:31
// Design Name: 
// Module Name: LT2380_24_controller
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


module LT2380_24_controller(

        input i_clk,   
        input i_reset,
        input i_BUSY,
        input i_SDO, 
        
        output reg [23:0]o_dataOutput24b,   //parallel output     
        output o_SCK,
        output reg o_CNV,
        output reg o_dataValid,
        output reg [5:0]sck_ctr

    );

//o_CNV related signals
    
localparam DELAY_MAX = 6;  // o_CNV length measured in clock pulses  
localparam SDI_DATABITS = 48;  //24 x 2


reg [5:0]clk_divider;
reg sig_dly; // aux signal for CNV pulse generation
wire CNV_posedge; //CNV 1 clock pulse length
reg start_ctr, long_pulse;
reg [3:0]pulse_ctr;

//clock division assingments
    
wire clk_div2 = clk_divider[0] ;	// --  49.152 MHz clock (50MHz with 100M clk)
wire clk_div4 = clk_divider[1];	// --  24.576 MHz clock (25MHz with 100M clk)
//wire clk_div8 = clk_divider[2];	// --  12.288 MHz clock (12.5MHz with 100M clk)
//wire clk_div16 = clk_divider[3];	// --   6.144 MHz clock (6.125MHz with 100M clk)    
wire max_sampling = clk_divider[5]; // -- 1562.5 kHz (384x4/192x8/96x16/48x32)


wire clk_98MHZ;

//BUSY signal edge detection and syncro

wire BUSY_negedge;
reg busy_dly;
reg sck_ctr_start;
//reg [5:0]sck_ctr;
reg sck_ena;

// output parallel audio frame

reg [23:0]o_parData;

assign o_SCK = sck_ena & clk_divider[0];
/*
main clock divider for all used frequencies
*/
always @(posedge clk_98MHZ) begin
     if (i_reset) begin
         clk_divider <= 6'b0;
     end
     else  begin
        clk_divider   <= clk_divider + 6'b1;           
     end
 end 



  clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(clk_98MHZ),     // output clk_out1
    // Status and control signals
    .reset(~i_reset), // input reset
   // Clock in ports
    .clk_in1(i_clk));      // input clk_in1

     
/*
Pos edge detector for CNV pulse generation
*/
assign CNV_posedge = max_sampling & ~sig_dly; 

 always @ (posedge clk_98MHZ) begin
    sig_dly <= max_sampling;
 end

/*
Neg edge detector for BUSY signal
*/
assign BUSY_negedge =  busy_dly & ~i_BUSY; 

 always @ (posedge clk_98MHZ) begin
    busy_dly <= i_BUSY;
 end


/*
o_CNV pulse generation
*/
  
always @ (posedge clk_98MHZ) begin
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
 
  always @ (posedge clk_98MHZ) begin
    if (i_reset) begin

        sck_ena <= 1'b0;
        sck_ctr_start <=1'b0;
        sck_ctr <= 6'b0;
    end
    else
    if(BUSY_negedge) begin    
        sck_ena <= 1'b1; 
        sck_ctr_start <= 1'b1;    
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

 always @ (posedge clk_98MHZ) begin
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
