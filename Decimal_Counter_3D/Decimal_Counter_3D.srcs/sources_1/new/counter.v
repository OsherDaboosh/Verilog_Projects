`timescale 1ns / 1ps

module counter(
    input            clk5,
    input            reset,
    input            en,
    input            clr,
    input      [3:0] top_count,
    output reg       top_count_reach,
    output reg       reach9,
    output reg [3:0] q
);

always @(posedge clk5) begin
    if (reset || clr) begin
        q <= 4'd0;
    end
    else if (en) begin
        if (q == 4'd9) 
            q <= 4'd0;
        else 
            q <= q + 1;
    end
end

always @(*) begin
    reach9          = (q == 4'd9) ? 1'b1 : 1'b0;
    top_count_reach = (q == top_count) ? 1'b1 : 1'b0;
end
endmodule
