//SDRAM'model :H57V2562GTR  4Banks × 4Mbits × 16 = 256Mb
//Mode Register BA1 BA0 A12~A0: 15'b000_0000_0010_0000

module SDRAM_Ctrl(
input	wire	sclk,//133MHz 7.5ns
input	wire	rst_n,
output	reg		CKE,
output	reg		CS,//芯片选择
output	reg		RAS,//行地址选通
output	reg		CAS,//列地址选通
output	reg		WE//写允许
);

//SDRAM Command
parameter	NOP  = 5'b1_0111;//No Operation
parameter	ACT  = 5'b1_0011;//Bank Active
parameter	WR   = 5'b1_0100;//Write
parameter	RD   = 5'b1_0101;//Read
parameter	BSTP = 5'b1_0110;//Burst stop
parameter	PR   = 5'b1_0010;//Precharge Bank
parameter	AR   = 5'b1_0001;//Auto Refresh
parameter	LMR  = 5'b1_0000;//Load Mode Register

//FSM_main Steps
parameter   INIT = 4'b0001;
parameter   IDLE = 4'b0010;
parameter   WRITE= 4'b0100;
parameter	READ = 4'b1000;

//FSM_INIT Steps
parameter	IDLE_INIT = 6'b00_0001;
parameter	WAIT_INIT = 6'b00_0010;
parameter	PR_INIT   = 6'b00_0100;
parameter	AR_INIT0  = 6'b00_1000;
parameter	AR_INIT1  = 6'b01_0000;
parameter	LMR_INIT  = 6'b10_0000;

//FSM_IDLE Steps
parameter	PR_IDLE   = 5'b0_0001;
parameter	AR_IDLE0  = 5'b0_0010;
parameter	AR_IDLE1  = 5'b0_0100;
parameter	IsReady   = 5'b0_1000;
parameter	COUNT     = 5'b1_0000;

//FSM_WRITE Steps
parameter	ACT_WIRTE  = 3'b001;
parameter	WR_WRITE0  = 3'b010;
parameter	WR_WRITE1  = 3'b100;

//FSM_READ Steps
parameter	ACT_READ   = 3'b001;
parameter	RD_READ    = 3'b010;
parameter	DATA_READ  = 3'b100;

//command time interval
parameter   _100us = 13333;
parameter   tRP    = 3;
parameter   tRRC   = 9;
parameter   tRCD   = 3;
parameter   tMRD   = 2;
parameter   tDAL   = 5;

//time_cnt
reg cnt_flag;
reg [13:0]  time_cnt;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        time_cnt <= 'd0;
    else if(cnt_flag == 1'b1)
        time_cnt <= time_cnt + 1'b1;
    else
        time_cnt <= 'd0;

//FSM
reg SDRAM_flag = 1'b1;//SDRAM start flag
reg state, next_state;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        state <= IDLE_INIT;
    else
        state <= next_state;

//FSM_INIT
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        next_state <= IDLE_INIT;
    else
        case(state)
        IDLE_INIT:begin
            if(SDRAM_flag == 1'b1)  next_state <= WAIT_INIT;
            else    next_state <= IDLE_INIT;
        end
        WAIT_INIT:begin
            
        end

        endcase

always @(posedge sclk or negedge rst_n)
    if(!rst_n)begin
        ;
    end
    else
        case(state)
        IDLE_INIT:begin
            ;
        end
        WAIT_INIT:begin
            ;
        end

        default:begin
            ;
        end
        endcase


endmodule