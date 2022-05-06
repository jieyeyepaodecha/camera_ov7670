`include "../../src/test.v"

`timescale 1ns/1ps

module tb_test;
// test Parameters
parameter PERIOD  = 10;//unit MHz


// test Inputs
reg   sclk                                 = 0 ;
reg   rst_n                                = 0 ;
reg   p                                    = 0 ;

// test Outputs
wire  [7:0]  cnt                           ;
wire  q                                    ;



always #(500/PERIOD) sclk = ~sclk;


initial
begin
    #(PERIOD*2) rst_n  =  1;
end

test  u_test (
    .sclk                    ( sclk         ),
    .rst_n                   ( rst_n        ),
    .p                       ( p            ),

    .cnt                     ( cnt    [7:0] ),
    .q                       ( q            )
);

initial begin
    $display("start a tb_test");    // 打印开始标记
    $dumpfile("test.vcd");              // 指定记录模拟波形的文件
    $dumpvars(0, tb_test);          // 指定记录的模块层级
    #1000 $finish;                      // 6000个单位时间后结束模拟
end

initial begin
    p = 0;
    #45 p = 1;
end



endmodule