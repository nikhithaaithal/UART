module uart_top #(parameter N=8,parameter baud_rate=2400,parameter XTAL_CLK=50000000)(
    input wire sys_clk,
    input wire sys_rst_l, 
    input wire xmitH,
    input wire [N-1:0] xmit_dataH ,
    output  uart_XMIT_dataH,
    output  xmit_doneH,
    output  xmit_active,

    input wire uart_REC_dataH,
    output  rec_readyH,
    output  rec_busy,
    output  [N-1:0] rec_dataH);

wire baud_clk;
baud_generator #(N,baud_rate,XTAL_CLK)baud(
    sys_clk,
     sys_rst_l,
     baud_clk);
     
uart_tx#( N, baud_rate, XTAL_CLK)tx(
   baud_clk, 
   sys_rst_l, 
   xmitH,
   xmit_dataH ,
   uart_XMIT_dataH,
   xmit_doneH,
   xmit_active); 
   
     
uart_rx#( N, baud_rate,  XTAL_CLK)rx(
     baud_clk, 
     sys_rst_l,
     uart_REC_dataH,
     rec_readyH,
     rec_busy,
     rec_dataH);

endmodule
