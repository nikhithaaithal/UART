module baud_generator#(parameter N=8,parameter baud_rate=2400,parameter XTAL_CLK=50000000)(
    input wire sys_clk,
    input wire sys_rst_l,
    output reg baud_clk=0);
localparam integer  CLK_DIV=XTAL_CLK/(baud_rate*16*2);
reg [$clog2(CLK_DIV) - 1:0]count;
always@(posedge sys_clk or negedge sys_rst_l)
begin
    if(!sys_rst_l)
    begin
        count<=0;
        baud_clk<=0;
    end
    else
    begin
        if(count==CLK_DIV-1)
        begin
            count<=0;
            baud_clk<=~baud_clk;
        end
        else 
            count<=count+1;
    end
end   
endmodule
