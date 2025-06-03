`timescale 1ns / 1ps

module fifo(
    input clk,
    input reset,
    input we,
    input re,
    input [3:0] in_data,
    output reg [3:0] out_data,
    output reg full,
    output reg empty
);

    reg [3:0] memory [7:0];
    reg [2:0] wrPtr, rdPtr, count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wrPtr    <= 0;
            rdPtr    <= 0;
            count    <= 0;
            out_data <= 0;
            full     <= 0;
            empty    <= 1;
        end else begin
            // Write
            if (we && !full) begin
                memory[wrPtr] <= in_data;
                wrPtr         <= wrPtr + 1;
                count         <= count + 1;
            end

            // Read
            if (re && !empty) begin
                out_data <= memory[rdPtr];
                rdPtr    <= rdPtr + 1;
                count    <= count - 1;
            end

            // Update full/empty flags
            full  <= (count == 8);
            empty <= (count == 0);
        end
    end
endmodule
