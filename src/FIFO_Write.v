module FIFO_Write(
input	wire	sclk,
input	wire	rst_n,
input	wire	PCLK,
input	wire	RGB_ready,
output	reg		FIFO_Write_en
);

//signal RGB_ready negedge
reg ready_buf;
wire RGB_ready_n;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        ready_buf <= 1'b0;
    else
        ready_buf <= RGB_ready;

assign RGB_ready_n = !RGB_ready & ready_buf;

//FIFO_Write_en

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        FIFO_Write_en <= 1'b0;
    else if(RGB_ready_n == 1'b1)
        FIFO_Write_en <= 1'b1;
    else
        FIFO_Write_en <= 1'b0;



endmodule
