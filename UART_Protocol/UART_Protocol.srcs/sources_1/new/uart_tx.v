`timescale 1ns / 1ps

module uart_tx #(parameter BAUD_RATE = 868) (  // 100MHZ / 115200 = 868  // For Baud Rate = 115200
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_in_data,
    output reg tx_out_data
);

    // FSM State
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;
    
    reg [1:0] txState = IDLE;

    // Internal signals
    reg baudRateClk          = 0;
    reg [9:0] baudCount      = BAUD_RATE - 1;
    reg [7:0] dataStored     = 8'd0;
    reg [2:0] dataIndex      = 3'd0;
    reg [2:0] dataIndexReset = 1'b1;
    
    reg startDetected = 1'b0;
    reg startReset = 1'b1;
    
    // Baud rate clock generator
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            baudRateClk <= 0;
            baudCount   <= BAUD_RATE - 1;
        end
        else begin
            if (baudCount == 0) begin
                baudRateClk <= 1;
                baudCount   <= BAUD_RATE - 1;
            end
            else begin
                baudRateClk <= 0;
                baudCount   <= baudCount - 1;
            end
        end
    end
    
    // Start detection and data latching
    always @(posedge clk or posedge reset) begin
        if (reset || startReset) begin
            startDetected <= 0;
        end
        else if (tx_start && !startDetected) begin
            startDetected <= 1;
            dataStored    <= tx_in_data;
        end
    end
    
    // Data index counter
    always @(posedge clk or posedge reset) begin
        if (reset || dataIndexReset) begin
            dataIndex <= 0;
        end
        else if (baudRateClk) begin
            dataIndex <= dataIndex + 1;
        end
    end
    
    // UART Transmission FSM
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            txState        <= IDLE;
            dataIndexReset <= 1;
            startReset     <= 1;
            tx_out_data    <= 1;  // IDLE state for UART is high
        end
        else if (baudRateClk) begin
            case (txState)
                IDLE: begin
                    dataIndexReset <= 1;
                    startReset     <= 0;
                    tx_out_data    <= 1;
                    if (startDetected) begin
                        txState <= START;
                    end
                end
                START: begin
                    dataIndexReset <= 0;
                    tx_out_data    <= 0;  // Start bit
                    txState        <= DATA;
                end
                DATA: begin
                    tx_out_data <= dataStored[dataIndex];
                    if (dataIndex == 3'd7) begin
                        dataIndexReset <= 1;
                        txState        <= STOP;
                    end
                end
                STOP: begin
                    tx_out_data <= 1; 
                    startReset  <= 1;
                    txState     <= IDLE;
                end
                
                default: txState <= IDLE;
            endcase
        end
    end
endmodule
