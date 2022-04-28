`timescale  1ns / 1ps

module tb_SCCB;

// SCCB Parameters
parameter PERIOD = 20    ;

// SCCB Inputs
reg   sclk                                 = 0 ;
reg   rst_n                                = 0 ;
reg   write_en                             = 0 ;
reg   [7:0]  sccb_addr                     = 12 ;
reg   [7:0]  sccb_data                     = 11 ;

// SCCB Outputs
wire  data_finish                          ;
wire  init_en                              ;
wire  sio_c                                ;

// SCCB Bidirs
wire  sio_d                                ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

 u_SCCB (
    .sclk                    ( sclk               ),
    .rst_n                   ( rst_n              ),
    .write_en                ( write_en           ),
    .sccb_addr               ( sccb_addr    [7:0] ),
    .sccb_data               ( sccb_data    [7:0] ),
    .data_finish             ( data_finish        ),
    .init_en                 ( init_en            ),
    .sio_c                   ( sio_c              ),
    .sio_d                   ( sio_d              )
);

initial
begin
    #200;
    write_en = 1;
end

endmodule
