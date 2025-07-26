`timescale 1ns / 1ps

module divider(
    input      clk,
    input      reset,
    output reg clk5,
    output reg clk500
);

// Constants
localparam [31:0] DIV5   = 32'h00989680; // 10,000,000
localparam [31:0] DIV500 = 32'h000186A0; // 100,000

// Internal signals
reg [31:0] count5   = 0;
reg [31:0] count500 = 0;

always @(posedge clk) begin
    if (reset) begin
        count5      <= 32'd0;
        count500    <= 32'd0;
        clk5        <= 1'b0;
        clk500      <= 1'b0;
    end 
    else begin
        if (count5 == DIV5-1) begin
            count5 <= 32'd0;
            clk5   <= ~clk5;
        end
        else begin
            count5 <= count5 + 1;
        end
        
        if (count500 == DIV500-1) begin
            count500 <= 32'd0;
            clk500   <= ~clk500;
        end
        else begin
            count500 <= count500 + 1;
        end
    end
end
endmodule
