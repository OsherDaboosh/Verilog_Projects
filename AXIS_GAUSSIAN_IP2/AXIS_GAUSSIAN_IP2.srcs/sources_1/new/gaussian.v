`timescale 1ns / 1ps

module gaussian (
    input         clk,
    input         resetn,
    input  [71:0] in_data,    
    input         in_tvalid,
    input  [7:0]  sigma_x16,  // Sigma * 16 (for fixed point: sigma=1.0 -> 16)
    output        out_tvalid,
    output [7:0]  out_data
);

parameter KERNEL_SIZE = 9;

integer i, j;
reg [7:0] gaussKernel [8:0];
reg [10:0] mulData [8:0];
reg [13:0] sumData;
reg [1:0] pipeline_valid;
reg [7:0] kernel_sum;

// Precomputed kernels for different sigma values (sigma*16)
always @(*) begin
    case (sigma_x16)
        8'd8: begin   // sigma = 0.5
            gaussKernel[0] = 8'd0; gaussKernel[1] = 8'd1; gaussKernel[2] = 8'd0;
            gaussKernel[3] = 8'd1; gaussKernel[4] = 8'd12; gaussKernel[5] = 8'd1;
            gaussKernel[6] = 8'd0; gaussKernel[7] = 8'd1; gaussKernel[8] = 8'd0;
        end
        8'd16: begin  // sigma = 1.0 (standard)
            gaussKernel[0] = 8'd1; gaussKernel[1] = 8'd2; gaussKernel[2] = 8'd1;
            gaussKernel[3] = 8'd2; gaussKernel[4] = 8'd4; gaussKernel[5] = 8'd2;
            gaussKernel[6] = 8'd1; gaussKernel[7] = 8'd2; gaussKernel[8] = 8'd1;
        end
        8'd24: begin  // sigma = 1.5
            gaussKernel[0] = 8'd1; gaussKernel[1] = 8'd3; gaussKernel[2] = 8'd1;
            gaussKernel[3] = 8'd3; gaussKernel[4] = 8'd6; gaussKernel[5] = 8'd3;
            gaussKernel[6] = 8'd1; gaussKernel[7] = 8'd3; gaussKernel[8] = 8'd1;
        end
        8'd32: begin  // sigma = 2.0
            gaussKernel[0] = 8'd2; gaussKernel[1] = 8'd4; gaussKernel[2] = 8'd2;
            gaussKernel[3] = 8'd4; gaussKernel[4] = 8'd8; gaussKernel[5] = 8'd4;
            gaussKernel[6] = 8'd2; gaussKernel[7] = 8'd4; gaussKernel[8] = 8'd2;
        end
        default: begin // Default to sigma = 1.0
            gaussKernel[0] = 8'd1; gaussKernel[1] = 8'd2; gaussKernel[2] = 8'd1;
            gaussKernel[3] = 8'd2; gaussKernel[4] = 8'd4; gaussKernel[5] = 8'd2;
            gaussKernel[6] = 8'd1; gaussKernel[7] = 8'd2; gaussKernel[8] = 8'd1;
        end
    endcase
end

// Calculate kernel sum for normalization
always @(*) begin
    kernel_sum = gaussKernel[0] + gaussKernel[1] + gaussKernel[2] + 
                 gaussKernel[3] + gaussKernel[4] + gaussKernel[5] + 
                 gaussKernel[6] + gaussKernel[7] + gaussKernel[8];
end

always @(posedge clk) begin
    if (!resetn) begin
        pipeline_valid <= 2'b00;
    end else begin
        // Stage 1: Multiply
        for (i = 0; i < 9; i = i + 1) begin
            mulData[i] <= gaussKernel[i] * in_data[i*8+:8];
        end
        pipeline_valid[0] <= in_tvalid;
        
        // Stage 2: Sum and normalize
        sumData <= mulData[0] + mulData[1] + mulData[2] + mulData[3] + mulData[4] + 
                   mulData[5] + mulData[6] + mulData[7] + mulData[8];
        pipeline_valid[1] <= pipeline_valid[0];
    end
end

// Normalize by kernel sum (approximate division)
wire [7:0] normalized_data;
assign normalized_data = (kernel_sum == 8'd16) ? (sumData >> 4) :  // Divide by 16
                        (kernel_sum == 8'd32) ? (sumData >> 5) :  // Divide by 32
                        (kernel_sum == 8'd18) ? (sumData / 18) :  // Approximate
                        (kernel_sum == 8'd21) ? (sumData / 21) :  // Approximate
                        (sumData / kernel_sum);                   // Generic division

assign out_data = normalized_data;
assign out_tvalid = pipeline_valid[1];

endmodule
