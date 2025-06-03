`timescale 1ns / 1ps

module spi_master(
    input clk,
    input reset,
    input [7:0] in_data,
    input start,
    output reg mosi,
    output reg sclk,
    output reg ss
);

    reg [3:0] bit_count;
    reg [7:0] data_buffer;
    reg [1:0] state;
    
    localparam IDLE     = 2'b00;
    localparam LOAD     = 2'b01;
    localparam TRANSFER = 2'b10;
    localparam DONE     = 2'b11;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ss        <= 1;
            sclk      <= 0;
            mosi      <= 0;
            bit_count <= 0;
            state     <= IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    ss   <= 1;
                    sclk <= 0;
                    mosi <= 0;
                    if (start) begin
                        state <= LOAD;
                    end
                end
                LOAD: begin
                    ss          <= 0;        // Assert slave select
                    data_buffer <= in_data;  // Load data into buffer
                    bit_count   <= 0;
                    sclk        <= 0;
                    state       <= TRANSFER;
                end
                TRANSFER: begin
                    sclk <= ~sclk;  // Toggle clock
                    if (sclk == 0) begin
                        // On rising edge: Output next bit
                        mosi <= data_buffer[7];
                    end
                    else begin
                        // On falling edge: Shift data
                        data_buffer <= data_buffer << 1;
                        bit_count   <= bit_count + 1;
                        if (bit_count == 7) begin
                            state <= DONE;
                        end
                    end
                end
                DONE: begin
                    ss    <= 1;
                    sclk  <= 0;
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
