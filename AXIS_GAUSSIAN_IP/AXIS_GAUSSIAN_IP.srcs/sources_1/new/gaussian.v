`timescale 1ns / 1ps
module gaussian(
    input         clk,
    input  [71:0] in_data,    
    input         in_tvalid,
    output        out_tvalid,
    output [7:0]  out_data
);

integer    i;
reg [7:0]  gaussKernel [8:0];
reg [10:0] mulData [8:0];
reg        mulDataValid;
reg [13:0] sumData;  // Fixed: Made this a reg and sized properly
reg        sumDataValid;

initial begin
    gaussKernel[0] = 8'd1;
    gaussKernel[1] = 8'd2;
    gaussKernel[2] = 8'd1;
    gaussKernel[3] = 8'd2;
    gaussKernel[4] = 8'd4;
    gaussKernel[5] = 8'd2;
    gaussKernel[6] = 8'd1;
    gaussKernel[7] = 8'd2;
    gaussKernel[8] = 8'd1;
end

always @(posedge clk) begin
    for (i = 0; i < 9; i = i + 1) begin
        mulData[i] <= gaussKernel[i] * in_data[i*8+:8];
    end
    mulDataValid <= in_tvalid;
end

// Fixed: Made this clocked instead of combinational
always @(posedge clk) begin
    sumData <= mulData[0] + mulData[1] + mulData[2] + mulData[3] + mulData[4] + 
               mulData[5] + mulData[6] + mulData[7] + mulData[8];
    sumDataValid <= mulDataValid;
end

assign out_data   = sumData >> 4;  // Divide by 16
assign out_tvalid = sumDataValid;

endmodule
