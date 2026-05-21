
module uart_rx_ref #(parameter N=8)(
    input  wire         baud_clk,
    input  wire         sys_rst_l,
    input  wire         uart_REC_dataH,
    output reg  [N-1:0] rec_dataH,
    output reg          rec_readyH,
    output reg          rec_busy);


reg [N-1:0] rx;
integer i;
reg rx_sync1, rx_sync2;
always @(posedge baud_clk or negedge sys_rst_l) begin
    if (!sys_rst_l) begin
        rx_sync1 <= 1'b1;
        rx_sync2 <= 1'b1;
    end 
    else begin
        rx_sync1 <= uart_REC_dataH;
        rx_sync2 <= rx_sync1;
        end
    end


always @(negedge sys_rst_l)
    begin
    rec_dataH  = 0;
    rec_readyH = 1;  
    rec_busy = 0;
    rx = 0;
    end
    
    
initial begin
rec_dataH  = 0;
rec_readyH = 1;  
rec_busy = 0;
rx = 0;

wait(sys_rst_l == 1);

forever begin          
    rec_readyH = 1;
    rec_busy   = 0;
    
    wait(rx_sync2 == 0); 
    rec_readyH = 0;
    rec_busy   = 1;
    
    repeat(5) @(posedge baud_clk);
     
    if(rx_sync2 != 0) begin
        rec_readyH = 1;  
        rec_busy   = 0;
        wait(rx_sync2==1);
    end 
    
    else begin
    for(i = 0; i < N; i = i + 1) begin
        repeat(16) @(posedge baud_clk); 
         rx[i] = rx_sync2;               
    end    
    repeat(16) @(posedge baud_clk); 
    if(rx_sync2 == 1'b1) 
    begin
        rec_dataH  = rx;
        rec_readyH = 1;
     end
    else 
    rec_readyH = 0; 
                
    rec_busy = 0;
     
    end
   end
end

endmodule
 

