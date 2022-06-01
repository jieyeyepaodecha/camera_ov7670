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
parameter   INIT       = 6'b00_0001;
parameter   IDLE       = 6'b00_0010;
parameter   WRITE      = 6'b00_0011;
parameter	READ       = 6'b00_0100;
//FSM_INIT Steps
parameter	IDLE_INIT  = 6'b00_0101;
parameter	WAIT_INIT  = 6'b00_0110;
parameter	PR_INIT    = 6'b00_0111;
parameter	AR_INIT0   = 6'b00_1000;
parameter	AR_INIT1   = 6'b00_1001;
parameter	LMR_INIT   = 6'b00_1010;
parameter   DELAY      = 6'b00_1011;
//FSM_IDLE Steps
parameter	PR_IDLE    = 6'b00_1100;
parameter	AR_IDLE0   = 6'b00_1101;
parameter	AR_IDLE1   = 6'b00_1110;
parameter	IsReady    = 6'b00_1111;
parameter	COUNT      = 6'b01_0000;
//FSM_WRITE Steps
parameter	ACT_WIRTE  = 6'b01_0001;
parameter	WR_WRITE   = 6'b01_0010;
//FSM_READ Steps
parameter	ACT_READ   = 6'b01_0011;
parameter	RD_READ    = 6'b01_0100;
parameter	DATA_READ  = 6'b01_0101;

//command time interval
parameter   _100us = 13333;//100us
parameter   tRP    = 3;//20ns
parameter   tRRC   = 9;//63ns
parameter   tRCD   = 3;//20ns
parameter   tMRD   = 2;//2CLK
parameter   tDAL   = 5;//2CLK + 20ns

//single flag
reg SDRAM_flag = 1'b1;//SDRAM start flag
reg wait_flag;
reg delay_flag, delay_finish;
reg pr_init_flag, ar0_init_flag, ar1_init_flag, lmr_init_flag;
reg pr_idle_flag, ar0_idle_flag, ar1_idle_flag, isready_y_flag, isready_n_flag;
reg write_flag, read_flag;
reg act_read_flag,rd_read_flag, data_read_flag;
reg act_write_flag, wr_write_flag;
//time_cnt
reg [13:0]  time_cnt;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        time_cnt <= 'd0;
    else if(delay_flag == 1'b1)
        time_cnt <= time_cnt + 1'b1;
    else
        time_cnt <= 'd0;

//delay
always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        delay_finish <= 1'b0;
    else if(time_cnt == delay_select)
        delay_finish <= 1'b1;
    else
        delay_finish <= 1'b0;

//single pin
reg [4:0]   single;

always @(*) 
    {CKE,CS,RAS,CAS,WE} = single;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        single <= NOP;
    else if(delay_flag == 1'b1)
        single <= NOP;
    else if(wait_flag == 1'b1)
        single <= NOP;
    else if(pr_init_flag == 1'b1)
        single <= PR;
    else if(ar0_init_flag == 1'b1)
        single <= AR;
    else if(ar1_init_flag == 1'b1)
        single <= AR;
    else if(lmr_init_flag == 1'b1)
        single <= LMR;
    else if(pr_idle_flag == 1'b1)
        single <= PR;
    else if(ar0_idle_flag == 1'b1)
        single <= AR;
    else if(ar1_idle_flag == 1'b1)
        single <= AR;
    else if(act_read_flag == 1'b1)
        single <= ACT;
    else if(rd_read_flag == 1'b1)
        single <= RD;
    else if(act_write_flag == 1'b1)
        single <= ACT;
    else if(wr_write_flag == 1'b1)
        single <= WR;

//FSM
reg [13:0]  delay_select;
reg state, next_state;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        state <= IDLE_INIT;
    else
        state <= next_state;

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
            next_state <= DELAY;
        end
        PR_INIT:begin
            next_state <= DELAY;
        end
        AR_INIT0:begin
            next_state <= DELAY;
        end
        AR_INIT1:begin
            next_state <= DELAY;
        end
        LMR_INIT:begin
            next_state <= DELAY;
        end
        PR_IDLE:begin
            next_state <= DELAY;
        end
        AR_IDLE0:begin
            next_state <= DELAY;
        end
        AR_IDLE1:begin
            next_state <= DELAY;
        end
        IsReady:begin
            next_state <= DELAY;
        end
        COUNT:begin
            next_state <= DELAY;
        end
        ACT_READ:begin
            next_state <= DELAY;
        end
        RD_READ:begin
            next_state <= DELAY;
        end
        DATA_READ:begin
            next_state <= DELAY;
        end
        ACT_WIRTE:begin
            next_state <= DELAY;
        end
        WR_WRITE:begin
            next_state <= DELAY;
        end
        DELAY:begin
            if(delay_finish == 1'b1 && wait_flag == 1'b1)   next_state <= PR_INIT;//开始初始化模式
            else if(delay_finish == 1'b1 && pr_init_flag == 1'b1)   next_state <= AR_INIT0;
            else if(delay_finish == 1'b1 && ar0_init_flag == 1'b1)  next_state <= AR_INIT1;
            else if(delay_finish == 1'b1 && ar1_init_flag == 1'b1)  next_state <= LMR_INIT;
            else if(delay_finish == 1'b1 && lmr_init_flag == 1'b1)  next_state <= PR_IDLE;//开始空闲刷新模式
            else if(delay_finish == 1'b1 && pr_idle_flag == 1'b1)   next_state <= AR_IDLE0;
            else if(delay_finish == 1'b1 && ar0_idle_flag == 1'b1)  next_state <= AR_IDLE1;
            else if(delay_finish == 1'b1 && ar1_idle_flag == 1'b1)  next_state <= IsReady;
            else if(delay_finish == 1'b1 && isready_n_flag == 1'b1) next_state <= COUNT;
            else if(delay_finish == 1'b1 && isready_y_flag == 1'b1 && read_flag == 1'b1)  next_state <= ACT_READ;//开始读模式
            else if(delay_finish == 1'b1 && act_read_flag == 1'b1)  next_state <= RD_READ;
            else if(delay_finish == 1'b1 && rd_read_flag == 1'b1)   next_state <= DATA_READ;
            else if(delay_finish == 1'b1 && data_read_flag == 1'b1) next_state <= PR_IDLE;//返回空闲刷新模式
            else if(delay_finish == 1'b1 && isready_y_flag == 1'b1 && write_flag == 1'b1) next_state <= ACT_WIRTE;//开始写模式
            else if(delay_finish == 1'b1 && act_write_flag == 1'b1) next_state <= WR_WRITE;
            else if(delay_finish == 1'b1 && wr_write_flag == 1'b1) next_state <= PR_IDLE;//返回空闲刷新模式
            else    next_state <= next_state;
        end
        default:begin
            next_state <= DELAY;
        end

        endcase

always @(posedge sclk or negedge rst_n)
    if(!rst_n)begin
        delay_flag <= 1'b0;
        delay_select <= 'd0;
        wait_flag <= 1'b0;
        pr_init_flag <= 1'b0;
    end
    else
        case(state)
        IDLE_INIT:begin
            delay_flag <= 1'b0;
            delay_select <= 'd0;
            wait_flag <= 1'b0;
            pr_init_flag <= 1'b0;
        end
        WAIT_INIT:begin
            delay_flag <= 1'b0;
            delay_select <= _100us;
            wait_flag <= 1'b1;
            pr_init_flag <= 1'b0;
        end
        PR_INIT:begin
            delay_flag <= 1'b0;
            delay_select <= tRP;
            wait_flag <= 1'b0;
            pr_init_flag <= 1'b1;
        end
        AR_INIT0:begin
            delay_flag <= 1'b0;
            delay_select <= tRRC;
            wait_flag <= 1'b0;
            pr_init_flag <= 1'b0;
        end
        AR_INIT1:begin
            delay_flag <= 1'b0;
            delay_select <= tRRC;
            wait_flag <= 1'b0;
            pr_init_flag <= 1'b0;
        end
        LMR_INIT:begin
            delay_flag <= 1'b0;
            delay_select <= tMRD;
            wait_flag <= 1'b0;
            pr_init_flag <= 1'b0;
        end
        DELAY:begin
            delay_flag <= 1'b1;
            delay_select <= delay_select;
            wait_flag <= wait_flag;
            pr_init_flag <= pr_init_flag;
        end
        default:begin
            delay_flag <= 1'b0;
            delay_select <= 'd0;
            wait_flag <= 1'b0;
            pr_init_flag <= 1'b0;
        end
        endcase


endmodule