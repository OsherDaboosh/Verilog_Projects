`timescale 1ns / 1ps

module divider(
    input      clk,     // Clock 100MHZ
    input      reset,
    output reg clk100   // Clock 100HZ
);

// Constant
localparam [19:0] DIV100 = 20'd500000;

// Internal signals
reg [19:0] count = 0;

always @(posedge clk) begin
    if (reset) begin
        count  <= 20'd0;
        clk100 <= 1'b0;
    end
    else begin
        if (count == DIV100-1) begin
            count  <= 0;
            clk100 <= ~clk100;
        end
        else begin
            count <= count + 1;
        end
    end
end
endmodule
