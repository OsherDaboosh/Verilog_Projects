`timescale 1ns / 1ps

module gray2binary(
    input             clk,
    input             resetn,
    input      [7:0]  in_data,
    input             in_tvalid,
    output reg        out_tvalid,
    output reg [31:0] out_data,
    input      [7:0]  threshold
);
        
    always @(posedge clk) begin
        if (!resetn) begin
            out_data   <= 32'b0;
            out_tvalid <= 1'b0;
        end
        else if (in_tvalid) begin
            out_tvalid <= 1'b1;
            // Convert grayscale to binary based on threshold
            if (in_data > threshold) begin
                out_data <= 32'hFFFFFFFF;  // White (255)
            end
            else begin
                out_data <= 32'h00000000;  // Black (0)
            end
        end
        else begin
            out_tvalid <= 1'b0;
        end
    end
endmodule
