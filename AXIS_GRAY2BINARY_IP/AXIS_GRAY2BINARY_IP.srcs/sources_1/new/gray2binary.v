`timescale 1ns / 1ps

module gray2binary(
    input             clk,
    input             resetn,
    input      [7:0]  in_data,
    input             in_tvalid,
    output            in_tready,
    output            out_tvalid,
    output reg [7:0]  out_data,
    input      [7:0]  threshold
);
    reg outValid;
    
    // Ready when we can accept data (always ready in this simple implementation)
    assign in_tready = 1'b1;
    
    always @(posedge clk) begin
        if (!resetn) begin
            out_data <= 8'b0;
            outValid <= 1'b0;
        end
        else if (in_tvalid && in_tready) begin
            outValid <= 1'b1;
            // Convert grayscale to binary based on threshold
            if (in_data > threshold) begin
                out_data <= 8'hFF;  // White (255)
            end
            else begin
                out_data <= 8'h00;  // Black (0)
            end
        end
        else begin
            outValid <= 1'b0;
        end
    end
    
    assign out_tvalid = outValid;
endmodule
