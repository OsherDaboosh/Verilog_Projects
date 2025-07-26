`timescale 1ns / 1ps

module line_buffer (
    input         clk,
    input         resetn,
    input         in_tvalid,
    input  [7:0]  in_data,
    input         in_rd_data,
    output [23:0] out_data
);

reg [7:0] lB [511:0];
reg [8:0] wrPtr;
reg [8:0] rdPtr;

always @(posedge clk) begin
    if (in_tvalid) 
        lB[wrPtr] <= in_data;
end

always @(posedge clk) begin
    if (!resetn) 
        wrPtr <= 9'd0;
    else if (in_tvalid)
        wrPtr <= (wrPtr == 511) ? 9'd0 : wrPtr + 1'd1;
end

always @(posedge clk) begin
    if (!resetn) 
        rdPtr <= 9'd0;  
    else if (in_rd_data) 
        rdPtr <= (rdPtr == 511) ? 9'd0 : rdPtr + 1'd1;
end

assign out_data = {lB[rdPtr], lB[rdPtr+1], lB[rdPtr+2]};

endmodule
