
`timescale 1ns / 1ps

module uart_tx#(
    parameter N=8,
    parameter baud_rate = 2400,
    parameter XTAL_CLK = 50000000
   
)(
    input wire baud_clk,
    input wire sys_rst_l,
    input wire xmitH,
    input wire [N-1:0] xmit_dataH ,

    output reg uart_XMIT_dataH,
    output reg xmit_doneH,
    output reg xmit_active
);

localparam idle  = 2'b00;
localparam start = 2'b01;
localparam data  = 2'b10;
localparam stop  = 2'b11;

reg [1:0] current_state, next_state;

reg [N-1:0] tx_data,next_tx_data;
reg [$clog2(N)-1:0] bit_index,next_bit_index;
reg [3:0] count,next_count;


always @(posedge baud_clk or negedge sys_rst_l)
begin
    if(!sys_rst_l)
    begin
        current_state   <= idle;

        uart_XMIT_dataH <= 1;
        xmit_doneH      <= 1;
        xmit_active     <= 0;

        tx_data         <= 0;
        bit_index       <= 0;
        count           <= 0;
    end

    else
    begin
        current_state   <= next_state;

        tx_data         <= next_tx_data;
        bit_index       <= next_bit_index;
        count           <= next_count;
    end
end


always @(*)
begin

    next_state      = current_state;

    next_tx_data    = tx_data;
    next_bit_index  = bit_index;
    next_count      = count;

    uart_XMIT_dataH = 1;
    xmit_doneH      = 1;
    xmit_active     = 0;

    case(current_state)

    
    idle:
    begin
        uart_XMIT_dataH = 1;
        xmit_doneH      = 1;
        xmit_active     = 0;

        next_count      = 0;
        next_bit_index  = 0;

        if(xmitH == 1)
        begin
            next_state   = start;
            next_tx_data = xmit_dataH;
        end
    end

  
    start:
    begin
        uart_XMIT_dataH = 0;
        xmit_doneH      = 0;
        xmit_active     = 1;

        if(count == 4'd15)
        begin
            next_state = data;
            next_count = 0;
        end
        else
            next_count = count + 1;
    end

    data:
    begin
        uart_XMIT_dataH = tx_data[0];
        xmit_doneH      = 0;
        xmit_active     = 1;

        if(count == 4'd15)
        begin
            next_count   = 0;
            next_tx_data = tx_data >> 1;

            if(bit_index == N-1)
            begin
                next_state     = stop;
                next_bit_index = 0;
            end
            else
                next_bit_index = bit_index + 1;
        end

        else
            next_count = count + 1;
    end

 
stop:
begin
    uart_XMIT_dataH = 1;

    if(count == 4'd15)
    begin
        next_count = 0;

        if(xmitH)
        begin
            next_state   = start;
            next_tx_data = xmit_dataH;
            xmit_doneH   = 1;
            xmit_active  = 1;
        end

        else
        begin
            next_state   = idle;
            xmit_doneH   = 1;
            xmit_active  = 0;
        end
    end

    else
    begin
        next_count  = count + 1;
        xmit_doneH  = 0;
        xmit_active = 1;
    end
end
    endcase
end

endmodule


