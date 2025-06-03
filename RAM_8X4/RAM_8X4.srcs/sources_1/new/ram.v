`timescale 1ns / 1ps

module ram(
    input clk,
    input we,   // Write Enable
    input [2:0] address,
    input [3:0] in_data,
    output reg [3:0] out_data
);
    reg [3:0] memory [7:0];
    always @(posedge clk) begin
        if (we)
            memory[address] <= in_data;  // Write operation
            out_data <= memory[address]; // Read operation  (Always update output)
    end
endmodule
