module test(
input   wire    sclk,
input	wire	rst_n,
input	wire	p,
output	reg		[7:0]   cnt,
output	reg		q
);

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        cnt <= 'd0;
    else
        cnt <= cnt + 1'b1;

always @(posedge sclk or negedge rst_n)
    if(!rst_n)
        q <= 1'b0;
    else if(p == 'd1)
        q <= !q;


endmodule