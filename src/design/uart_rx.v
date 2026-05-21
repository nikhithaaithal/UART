`timescale 1ns / 1ps

module uart_rx#(
    parameter N=8,
    parameter baud_rate = 2400,
    parameter XTAL_CLK = 50000000
   
)(
    input wire baud_clk,
    input wire sys_rst_l,
    input wire uart_REC_dataH,

    output reg rec_readyH,
    output reg rec_busy,
    output reg [N-1:0] rec_dataH
);

localparam idle     = 2'b00;
localparam start    = 2'b01;
localparam data_out = 2'b10;
localparam stop     = 2'b11;

reg [1:0] current_state, next_state;

reg [N-1:0] rx_data, next_rx_data;
reg [$clog2(N)-1:0] bit_index, next_bit_index;
reg [3:0] count, next_count;

reg [N-1:0] next_rec_dataH;

reg next_rec_readyH;
reg next_rec_busy;

reg rx_sync1, rx_sync2;



always @(posedge baud_clk or negedge sys_rst_l)
begin
    if(!sys_rst_l)
    begin
        rx_sync1 <= 1'b1;
        rx_sync2 <= 1'b1;
    end

    else
    begin
        rx_sync1 <= uart_REC_dataH;
        rx_sync2 <= rx_sync1;
    end
end

always @(posedge baud_clk or negedge sys_rst_l)
begin
    if(!sys_rst_l)
    begin
        current_state <= idle;

        rec_readyH    <= 1;
        rec_busy      <= 0;
        rec_dataH     <= 0;

        rx_data       <= 0;
        bit_index     <= 0;
        count         <= 0;
    end

    else
    begin
        current_state <= next_state;

        rec_readyH    <= next_rec_readyH;
        rec_busy      <= next_rec_busy;
        rec_dataH     <= next_rec_dataH;

        rx_data       <= next_rx_data;
        bit_index     <= next_bit_index;
        count         <= next_count;
    end
end

always @(*)
begin



    next_state       = current_state;

    next_rx_data     = rx_data;
    next_bit_index   = bit_index;
    next_count       = count;

    next_rec_readyH  = rec_readyH;
    next_rec_busy    = rec_busy;
    next_rec_dataH   = rec_dataH;

    case(current_state)


    idle:
    begin
        next_rec_readyH = 1;
        next_rec_busy   = 0;

        next_count      = 0;
        next_bit_index  = 0;

        if(rx_sync2 == 0)
        begin
            next_state   = start;
            next_rx_data = 0;
        end
    end

    start:
    begin
        next_rec_busy   = 1;
        next_rec_readyH = 0;

        if(count == 4'd4)
        begin
            next_count = 0;

            if(rx_sync2 == 0)
                next_state = data_out;
            else
                next_state = idle;
        end

        else
            next_count = count + 1;
    end

    data_out:
    begin
        next_rec_busy   = 1;
        next_rec_readyH = 0;

        if(count == 4'd15)
        begin
            next_count = 0;

            next_rx_data[bit_index] = rx_sync2;

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
        if(count == 4'd15)
        begin
            next_count = 0;

            if(rx_sync2 == 1'b1)
            begin
                next_rec_dataH  = rx_data;
                next_rec_readyH = 1;
                
            end

            next_rec_busy = 0;
            next_state    = idle;
        end

        else
            next_count = count + 1;
    end

    endcase
end

endmodule
