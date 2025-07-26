`timescale 1ns / 1ps

module up_down_counter(
    input clk,
    input reset,
    input mode,  //  1 for up, 0 for down
    output [3:0] count
);
    reg [3:0] next_count;
    always @(posedge clk or posedge reset) begin
        if (reset)
            next_count <= 4'b0000;
        else if (mode)
            next_count <= next_count + 1;  // Up Counter
        else
            next_count <= next_count - 1;  // Down Counter
    end
    // Instantiate D Flip-Flops to store the count value
    d_flip_flop DFF0 (.d(next_count[0]), .clk(clk), .reset(reset), .q(count[0]));
    d_flip_flop DFF1 (.d(next_count[1]), .clk(clk), .reset(reset), .q(count[1]));
    d_flip_flop DFF2 (.d(next_count[2]), .clk(clk), .reset(reset), .q(count[2]));
    d_flip_flop DFF3 (.d(next_count[3]), .clk(clk), .reset(reset), .q(count[3]));
endmodule
