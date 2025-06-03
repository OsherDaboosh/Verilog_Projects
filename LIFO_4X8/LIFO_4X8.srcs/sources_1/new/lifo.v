`timescale 1ns / 1ps

module lifo(
    input clk,
    input reset,
    input push,
    input pop,
    input [3:0] in_data,
    output reg [3:0] out_data,
    output reg full,
    output reg empty
);

    reg [3:0] stack [7:0];  // 8-depth stack
    reg [2:0] sp;           // Stack Pointer
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sp <= 0;
        end
        else begin
            if (push && !full) begin
                stack[sp] <= in_data;
                sp        <= sp + 1;
            end
            if (pop && !empty) begin
                sp       <= sp - 1;
                out_data <= stack[sp];
            end
        end
    end
    
    always @(*) begin
        full  = (sp == 8);
        empty = (sp == 0);
    end
endmodule
