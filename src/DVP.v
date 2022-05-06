module DVP (
input	wire	sclk,
input	wire	rst_n,
input   wire    VSYNC,
input   wire    HREF,
input   wire    PCLK,//camera_out_clk
input	wire	[7:0]   DVP_data,
output	reg		[15:0]  FIFO_in_data
);

//VSYNC' pos
reg VSYNC_buffer;
wire VSYNC_pos;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        VSYNC_buffer <= 1'b0;
    else
        VSYNC_buffer <= VSYNC;

assign VSYNC_pos = VSYNC & !VSYNC_buffer;

//HREF' posedge and nengdge
reg HREF_buffer;
wire HREF_pos, HREF_neg;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        HREF_buffer <= 1'b0;
    else
        HREF_buffer <= HREF;

assign HREF_pos = HREF & !HREF_buffer;
assign HREF_neg = !HREF & HREF_buffer;

//ROW' cnt    the max number is 480
reg [8:0]   row_cnt;
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        row_cnt <= 'd0;
    else if(VSYNC_pos == 1'b1)
        row_cnt <= 'd0;
    else if(HREF_neg == 1'b1)
        row_cnt <= row_cnt + 1'b1;
    else
        row_cnt <= row_cnt;

//camera' rgb data
//a complete signal
reg [1:0] data_state;
reg [15:0] RGB_buf;

always @(posedge PCLK or negedge rst_n)
    if(!rst_n)
        data_state <= 'd3;
    else if(data_state == 'd1)
        data_state <= 'd0;
    else if(HREF_pos == 1'b1)
        data_state <= 'd0;
    else if(HREF == 1'b1)
        data_state <= data_state + 1'b1;
    else
        data_state <= data_state;

always @(posedge PCLK or negedge rst_n)
    if(!rst_n)
        RGB_buf <= 'd0;
    else if(HREF == 1'b1)
        RGB_buf <= {RGB_buf[7:0],DVP_data};
    else
        RGB_buf <= RGB_buf;

always @(posedge PCLK or negedge rst_n)
    if(!rst_n)
        FIFO_in_data <= 'd0;
    else if(data_state == 'd1)
        FIFO_in_data <= RGB_buf;
    else
        FIFO_in_data <= FIFO_in_data;

endmodule
