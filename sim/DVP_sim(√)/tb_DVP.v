`include "../../src/DVP.v"
`timescale  1ns / 1ps

module tb_DVP;//the module has been validated

// DVP Parameters
parameter PERIOD  = 50;//unit MHz


// DVP Inputs
reg   sclk                                 = 0 ;
reg   rst_n                                = 0 ;
reg   VSYNC                                = 0 ;
reg   HREF                                 = 0 ;
reg   PCLK                                 = 0 ;
reg   [7:0]  DVP_data                      = 0 ;

// DVP Outputs
wire  [15:0]  FIFO_in_data                 ;


always #(500/PERIOD) sclk = ~sclk;

initial
begin
    #100 rst_n  =  1;
end

DVP  u_DVP (
    .sclk                    ( sclk                 ),
    .rst_n                   ( rst_n                ),
    .VSYNC                   ( VSYNC                ),
    .HREF                    ( HREF                 ),
    .PCLK                    ( PCLK                 ),
    .DVP_data                ( DVP_data      [7:0]  ),

    .FIFO_in_data            ( FIFO_in_data  [15:0] )
);

//instance

always #50 PCLK = ~PCLK;

reg [9:0] clk_cnt;
always @(posedge PCLK or negedge rst_n)
    if(!rst_n)
        clk_cnt <= 'd0;
    else if(clk_cnt == 'd784)
        clk_cnt <= 'd0;
    else 
        clk_cnt <= clk_cnt + 1'b1;

reg [9:0] LINE_cnt;

always @(posedge PCLK or negedge rst_n)
    if(!rst_n)
        LINE_cnt <= 'd0;
    else if(clk_cnt == 'd784)
        LINE_cnt <= LINE_cnt + 1'b1;

//VSYNC'timing    
always @(posedge PCLK or negedge rst_n)
    if(!rst_n)
        VSYNC <= 1'b0;
    else if(LINE_cnt == 'd1)
        VSYNC <= 1'b1;
    else if(LINE_cnt == 'd4)
        VSYNC <= 1'b0;
    else if(LINE_cnt == 'd511)
        VSYNC <= 1'b1;
    else if(LINE_cnt == 'd514)
        VSYNC <= 1'b0;
    else
        VSYNC <= VSYNC;

//HREF'timing

always @(negedge PCLK or negedge rst_n)
    if(!rst_n)
        HREF <= 1'b0;
    else if(LINE_cnt >= 'd21 && LINE_cnt <= 'd501 && clk_cnt < 'd640)
        HREF <= 1'b1;
    else if(LINE_cnt >= 'd21 && LINE_cnt <= 'd501 && clk_cnt >= 'd640)
        HREF <= 1'b0;
    else
        HREF <= HREF;

always @(negedge PCLK or negedge rst_n)
    if(!rst_n)
        DVP_data <= 'd0;
    else if(HREF == 1'b1)
        DVP_data <= DVP_data + 1'b1;
    else
        DVP_data <= DVP_data;


endmodule
