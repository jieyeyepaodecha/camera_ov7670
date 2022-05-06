module SCCB(
input   wire    sclk,//50MHz
input   wire    rst_n,
input   wire    write_en,
input   wire    [7:0]   sccb_addr,
input   wire    [7:0]   sccb_data,
output  reg     data_finish,
output  reg     init_en,
output  reg     sio_c,//sccb_clk 
output	reg		sio_e,
inout   wire     sio_d
);

//FSM
parameter   INIT    = 'b000_0001,
            IDLE    = 'b000_0010,
            START   = 'b000_0100,
            DEVICE  = 'b000_1000,
            ADDR    = 'b001_0000,
            DATA    = 'b010_0000,
            STOP    = 'b100_0000;

reg [7:0] ID_OV7670 = 8'b1010_1010;
reg [4:0]   state, next_state;
reg init_flag, start_flag, device_flag, addr_flag, data_flag, stop_flag;
reg write_flag;

//Init_en
//上电到RESET拉高，时间大于等于3ms
//从RESET拉高到SCCB初始代码，时间大于等于3ms
reg [18:0] init_cnt;
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        init_cnt <= 19'd0;
    else if(init_flag == 1'b0)
        init_cnt <= init_cnt + 1'b1;
    else
        init_cnt <= init_cnt;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        init_en <= 1'b0;
    else if(init_cnt == 'd20_0000)
        init_en <= 1'b1;
    else
        init_en <= init_en;


//SCCB enable signal
reg SCCB_EN;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        SCCB_EN <= 1'b0;
    else if(write_en == 1'b1)
        SCCB_EN <= 1'b1;
    else
        SCCB_EN <= 1'b0;

//sclk_cnt
reg [7:0]   clk_cnt;//25MHz / 100 = 250KHz

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        clk_cnt <= 8'd0;
    else if(clk_cnt == 8'd99)
        clk_cnt <= 8'd0;
    else if(SCCB_EN == 1'b1)
        clk_cnt <= clk_cnt + 1'b1;
    else
        clk_cnt <= 8'd0;

//sccb_clk
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        sio_c <= 1'b1;
    else if(stop_flag == 1'b1 && clk_cnt == 'd99)
        sio_c <= 1'b1;
    else if(clk_cnt == 8'd99)
        sio_c <= ~sio_c;

//sio_e
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        sio_e <= 1'b1;
    else if(SCCB_EN == 1'b1)
        sio_e <= 1'b0;
    else
        sio_e <= 1'b1;

//end of state->start
reg end_start;
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        end_start <= 1'b0;
    else if(start_flag == 1'b0)
        end_start <= 1'b0;
    else if(start_flag == 1'b1 && clk_cnt == 8'd99)
        end_start <= 1'b1;
    else
        end_start <= end_start;

//end of state->device
reg end_device;
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        end_device <= 1'b0;
    else if(bit_cnt == 'd9 && byte_cnt == 'd1)
        end_device <= 1'b1;
    else    
        end_device <= 1'b0;

//end of state->addr
reg end_addr;
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        end_addr <= 1'b0;
    else if(bit_cnt == 'd9 && byte_cnt == 'd2)
        end_addr <= 1'b1;
    else    
        end_addr <= 1'b0;

//end of state->data
reg end_data;
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        end_data <= 1'b0;
    else if(bit_cnt == 'd9 && byte_cnt == 'd3 && clk_cnt == 'd48)
        end_data <= 1'b1;
    else
        end_data <= 1'b0;

//end of state->stop
reg end_stop;
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        end_stop <= 1'b0;
    else if(stop_flag == 1'b1 && clk_cnt == 'd48)
        end_stop <= 1'b1;
    else
        end_stop <= 1'b0;

//data_finish
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        data_finish <= 1'b0;
    else if(bit_cnt == 'd9)
        data_finish <= 1'b1;
    else
        data_finish <= 1'b0;

//sio_d' send
reg [3:0] bit_cnt;
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        bit_cnt <= 4'd0;
    else if(clk_cnt == 8'd48 && bit_cnt == 4'd9)
        bit_cnt <= 4'd1;
    else if(clk_cnt == 8'd49 && write_flag == 1'b1)
        bit_cnt <= bit_cnt + 1'b1;
    else
        bit_cnt <= bit_cnt;

reg [2:0] byte_cnt;
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        byte_cnt <= 3'd0;
    else if(stop_flag == 1'b1)
        byte_cnt <= 3'd0;
    else if(bit_cnt == 4'd1 && clk_cnt == 8'd50)
        byte_cnt <= byte_cnt + 1'b1;
    else
        byte_cnt <= byte_cnt;

reg sio_data;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        sio_data <= 1'b1;
    else if(start_flag == 1'b1 && clk_cnt == 8'd49)
        sio_data <= 1'b0;
    else if(stop_flag == 1'b1 && clk_cnt == 'd49)
        sio_data <= 1'b1;
    else if(bit_cnt == 4'd9)
        sio_data <= 1'bz;
    else if(device_flag == 1'b1)
        sio_data <= ID_OV7670[9-bit_cnt];
    else if(addr_flag == 1'b1)
        sio_data <= sccb_addr[9-bit_cnt];
    else if(data_flag == 1'b1)
        sio_data <= sccb_addr[9-bit_cnt];
    else
        sio_data <= sio_data;

assign sio_d = sio_data;

//FSM
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        state <= IDLE;
    else
        state <= next_state;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        next_state <= IDLE;
    else
    begin
        case(state)
            INIT:begin
                if(init_cnt >= 'd40_0000) next_state <= IDLE;
                else    next_state <= INIT;
            end
            IDLE:begin
                if(SCCB_EN == 1'b1) next_state <= START;
                else    next_state <= IDLE;
            end
            START:begin
                if(end_start == 1'b1) next_state <= DEVICE;
                else    next_state <= START;
            end
            DEVICE:begin
                if(end_device == 1'b1) next_state <= ADDR;
                else next_state <= DEVICE;
            end
            ADDR:begin
                if(end_addr == 1'b1) next_state <= DATA;
                else next_state <= ADDR;
            end
            DATA:begin
                if(end_data == 1'b1) next_state <= STOP;
                else next_state <= DATA;
            end
            STOP:begin
                if(end_stop == 1'b1)   next_state <= IDLE;
                else next_state <= STOP;
            end
            default:begin
                next_state <= IDLE;
            end
        endcase
    end

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        begin
            init_flag <= 1'b0;
            start_flag <= 1'b0;
            write_flag <= 1'b0;
            device_flag <= 1'b0;
            addr_flag <= 1'b0;
            data_flag <= 1'b0;
            stop_flag <= 1'b0;
        end
    else
    begin
        case (state)
            INIT:begin
                init_flag <= 1'b0;
                start_flag <= 1'b0;
                write_flag <= 1'b0;
                device_flag <= 1'b0;
                addr_flag <= 1'b0;
                data_flag <= 1'b0;
                stop_flag <= 1'b0;
            end
            IDLE:begin
                init_flag <= 1'b1;
                start_flag <= 1'b0;
                write_flag <= 1'b0;
                device_flag <= 1'b0;
                addr_flag <= 1'b0;
                data_flag <= 1'b0;
                stop_flag <= 1'b0;
            end 
            START:begin
                init_flag <= 1'b1;
                start_flag <= 1'b1;
                write_flag <= 1'b0;
                device_flag <= 1'b0;
                addr_flag <= 1'b0;
                data_flag <= 1'b0;
                stop_flag <= 1'b0;
            end
            DEVICE:begin
                init_flag <= 1'b1;
                start_flag <= 1'b0;
                write_flag <= 1'b1;
                device_flag <= 1'b1;
                addr_flag <= 1'b0;
                data_flag <= 1'b0;
                stop_flag <= 1'b0;
            end
            ADDR:begin
                init_flag <= 1'b1;
                start_flag <= 1'b0;
                write_flag <= 1'b1;
                device_flag <= 1'b0;
                addr_flag <= 1'b1;
                data_flag <= 1'b0;
                stop_flag <= 1'b0;
            end
            DATA:begin
                init_flag <= 1'b1;
                start_flag <= 1'b0;
                write_flag <= 1'b1;
                device_flag <= 1'b0;
                addr_flag <= 1'b0;
                data_flag <= 1'b1;
                stop_flag <= 1'b0;
            end
            STOP:begin
                init_flag <= 1'b1;
                start_flag <= 1'b0;
                write_flag <= 1'b0;
                device_flag <= 1'b0;
                addr_flag <= 1'b0;
                data_flag <= 1'b0;
                stop_flag <= 1'b1;
            end
            default:begin
                init_flag <= 1'b1;
                start_flag <= 1'b0;
                write_flag <= 1'b0;
                device_flag <= 1'b0;
                addr_flag <= 1'b0;
                data_flag <= 1'b0;
                stop_flag <= 1'b0;
            end
            default:begin
                init_flag <= 1'b0;
                start_flag <= 1'b0;
                write_flag <= 1'b0;
                device_flag <= 1'b0;
                addr_flag <= 1'b0;
                data_flag <= 1'b0;
                stop_flag <= 1'b0;
            end
        endcase
    end

endmodule

