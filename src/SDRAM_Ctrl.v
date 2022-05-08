module SDRAM_Ctrl(
input	wire	sclk,
input	wire	rst_n,
output	reg		CKE,
output	reg		CS,
output	reg		RAS,
output	reg		CAS,
output	reg		WE
);

parameter	NOP  = 5'b1_0111;
parameter	ACT  = 5'b1_0011;
parameter	WR   = 5'b1_0100;
parameter	RD   = 5'b1_0101;
parameter	BSTP = 5'b1_0110;
parameter	PR   = 5'b1_0010;
parameter	AR   = 5'b1_0001;
parameter	LMR  = 5'b1_0000;




endmodule