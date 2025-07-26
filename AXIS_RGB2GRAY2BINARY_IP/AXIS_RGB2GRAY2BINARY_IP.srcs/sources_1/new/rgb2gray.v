`timescale 1ns / 1ps

module rgb2gray(
    input             clk,
    input             resetn,
    input      [31:0] in_data,       // R[23:16], G[15:8], B[7:0]
    input             in_tvalid,
    output reg        out_tvalid,
    output reg [7:0]  out_data
);

    reg [7:0]  r, g, b;
    reg        rgbValid;

    // Stage 1: Capture RGB values
    always @(posedge clk) begin
        if (!resetn) begin
            r        <= 8'd0;
            g        <= 8'd0;
            b        <= 8'd0;
            rgbValid <= 1'b0;
        end 
        else if (in_tvalid) begin
            r        <= in_data[23:16];
            g        <= in_data[15:8];
            b        <= in_data[7:0];
            rgbValid <= 1'b1;
        end 
        else begin
            rgbValid <= 1'b0;
        end
    end

    // Stage 2: Compute grayscale
    always @(posedge clk) begin
        if (!resetn) begin
            out_data   <= 8'd0;
            out_tvalid <= 1'b0;
        end 
        else if (rgbValid) begin
            out_data   <= (r * 8'd77 + g * 8'd150 + b * 8'd29) >> 8;
            out_tvalid <= 1'b1;
        end else begin
            out_tvalid <= 1'b0;
        end
    end
endmodule
