`timescale 1ns / 1ps

module d_flip_flop(
    input d,
    input clk,
    input reset,
    output reg q
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 0;
        else
            q <= d;
    end
endmodule
