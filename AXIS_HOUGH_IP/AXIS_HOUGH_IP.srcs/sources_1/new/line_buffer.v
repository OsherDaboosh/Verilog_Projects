`timescale 1ns / 1ps

module line_buffer (
    input         clk,
    input         resetn,
    input  [7:0]  in_data,
    input         in_tvalid,
    input         in_rd_data,
    output [23:0] out_data
);

// Memory type
reg [7:0] lB [511:0]; //Line Buffer

// Pointers
reg [8:0] wrPtr;  // log2(512) = 8 
reg [8:0] rdPtr;  // log2(512) = 8 

always @(posedge clk) begin
    if (in_tvalid)
        lB[wrPtr] <= in_data;
end

always @(posedge clk) begin
    if(!resetn) 
        wrPtr <= 'd0;
    else if (in_tvalid)
        wrPtr <= wrPtr + 1;
end

assign out_data = {lB[rdPtr],lB[rdPtr+1],lB[rdPtr+2]};

always @(posedge clk) begin
    if(!resetn) 
        rdPtr <= 'd0;
    else if (in_rd_data)
        rdPtr <= rdPtr + 'd1;
end
endmodule
