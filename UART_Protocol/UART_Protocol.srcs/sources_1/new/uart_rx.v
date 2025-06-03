`timescale 1ns / 1ps

module uart_rx #(parameter BAUD_RATE_X16 = 54) (  // (100MHZ / 115200) / 16 = 54  
    input clk,
    input reset,
    input rx_in_data,
    output reg [7:0] rx_out_data
);

    // FSM States
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;
    
    reg [1:0] rxState = IDLE;

    // Internal registers
    reg [7:0] rxDataStored     = 8'd0;
    reg [3:0] bitDurationCount = 4'd0;
    reg [2:0] bitCount         = 3'd0;
    
    // Baud rate x16 clock
    reg [$clog2(BAUD_RATE_X16)-1:0] baudX16Count = BAUD_RATE_X16 - 1;
    wire baudRateClkX16 = (baudX16Count == 0);
    
    // Baud rate x16 generator
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            baudX16Count   <= BAUD_RATE_X16 - 1;
        end
        else begin
            if (baudX16Count == 0) begin
                baudX16Count   <= BAUD_RATE_X16 - 1;
            end
            else begin
                baudX16Count   <= baudX16Count - 1;
            end
        end
    end
    
    // UART Receiver FSM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rxState          <= IDLE;
            rxDataStored     <= 8'd0;
            rx_out_data      <= 8'd0;
            bitDurationCount <= 0;
            bitCount         <= 0;
        end
        else begin
            if (baudRateClkX16) begin
                case (rxState)
                    IDLE: begin
                        rxDataStored     <= 8'd0;
                        bitDurationCount <= 0;
                        bitCount         <= 0;
                        if (rx_in_data == 0) begin
                            rxState <= START;
                        end
                    end
                    START: begin
                        if (rx_in_data == 0) begin  // Confirm start bit
                            if(bitDurationCount == 4'd7) begin  // Mid-bit sample
                                rxState          <= DATA;
                                bitDurationCount <= 0;
                            end
                            else begin
                                bitDurationCount <= bitDurationCount + 1;
                            end
                        end
                        else begin
                            rxState <= IDLE;
                        end
                    end
                    DATA: begin
                        if(bitDurationCount == 4'd15) begin  
                            rxDataStored[bitCount] <= rx_in_data;
                            bitDurationCount       <= 0;
                            if (bitCount == 3'd7) begin
                                rxState <= STOP;
                            end
                            else begin
                                bitCount <= bitCount + 1;
                            end
                        end
                        else begin
                            bitDurationCount <= bitDurationCount + 1;
                        end
                    end
                    STOP: begin
                        if(bitDurationCount == 4'd15) begin  
                            if (rx_in_data == 1'b1) begin  // Valid stop bit
                                rx_out_data      <= rxDataStored;
                            end
                            rxState          <= IDLE;
                            bitDurationCount <= 0;
                        end
                        else begin
                            bitDurationCount <= bitDurationCount + 1;
                        end
                    end
                    
                    default: rxState <= IDLE;
                endcase
            end
        end
    end
endmodule
