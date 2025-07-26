`timescale 1ns / 1ps

module up_counter(
    input clk,
    input reset,
    output reg [3:0] count
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= 4'b0000;  // Reset the counter to 0
        else
            count <= count + 1;  // Increment count on each clock cycle
    end
endmodule
