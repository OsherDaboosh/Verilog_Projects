`timescale 1ns / 1ps
module line_buffer(
    input         clk,
    input         resetn,
    input  [7:0]  in_data,
    input         in_tvalid,
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
        wrPtr <= wrPtr + 9'd1;
end

// Fixed: Handle boundary conditions properly
wire [8:0] rdPtr_p1 = (rdPtr == 9'd511) ? 9'd0 : rdPtr + 9'd1;
wire [8:0] rdPtr_p2 = (rdPtr >= 9'd510) ? ((rdPtr == 9'd510) ? 9'd0 : 9'd1) : rdPtr + 9'd2;

assign out_data = {lB[rdPtr], lB[rdPtr_p1], lB[rdPtr_p2]};

always @(posedge clk) begin
    if (!resetn) 
        rdPtr <= 9'd0;
    else if (in_rd_data)
        rdPtr <= rdPtr + 9'd1;
end
endmodule
