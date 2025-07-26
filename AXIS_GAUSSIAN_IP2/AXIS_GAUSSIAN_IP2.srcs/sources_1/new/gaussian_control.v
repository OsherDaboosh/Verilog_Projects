`timescale 1ns / 1ps

module gaussian_control(
    input             clk,
    input             resetn,
    input      [7:0]  in_data,
    input             in_tvalid,
    output            out_tvalid,
    output reg [71:0] out_data,
    output reg        out_intr
);

localparam  IDLE = 1'b0, READ_BUFFER = 1'b1;

reg         state = IDLE;
reg [8:0]   pixelCounter;
reg [8:0]   rdCounter;
reg [11:0]  totalPixelCounter;
reg [1:0]   currentWrLineBuffer;
reg [1:0]   currentRdLineBuffer;
reg [3:0]   lineBuffDataValid;
reg [3:0]   lineBuffRdData;
reg         rdLineBuffer;

wire [23:0] lB0data;
wire [23:0] lB1data;
wire [23:0] lB2data;
wire [23:0] lB3data;

assign out_tvalid = rdLineBuffer;

always @(posedge clk) begin
    if(!resetn) begin
        totalPixelCounter <= 12'd0;
    end
    else begin
        if (in_tvalid & !rdLineBuffer)
            totalPixelCounter <= totalPixelCounter + 12'd1;
        else if (!in_tvalid & rdLineBuffer)
            totalPixelCounter <= totalPixelCounter - 12'd1;
    end
end

always @(posedge clk) begin
    if(!resetn) begin
        state        <= IDLE;
        rdLineBuffer <= 1'b0;
        out_intr     <= 1'b0;
        rdCounter    <= 9'd0;  // Fixed: Reset rdCounter
    end
    else begin
        case (state)
            IDLE: begin
                out_intr  <= 1'b0;
                rdCounter <= 9'd0;  // Fixed: Reset counter when entering IDLE
                if (totalPixelCounter >= 12'd1536) begin
                    rdLineBuffer <= 1'b1;
                    state        <= READ_BUFFER;
                end
            end
            READ_BUFFER: begin
                if (rdLineBuffer)
                    rdCounter <= rdCounter + 9'd1;
                    
                if (rdCounter == 9'd511) begin
                    state        <= IDLE;
                    rdLineBuffer <= 1'b0;
                    out_intr     <= 1'b1;
                end
            end
        endcase
    end
end

always @(posedge clk) begin
    if(!resetn) 
        pixelCounter <= 9'd0;
    else if (in_tvalid)
        pixelCounter <= pixelCounter + 9'd1;
end
        
always @(posedge clk) begin
    if(!resetn) begin
        currentWrLineBuffer <= 2'd0;
    end
    else if (pixelCounter == 9'd511 && in_tvalid)
        currentWrLineBuffer <= currentWrLineBuffer + 2'd1;
end

always @(*) begin
    lineBuffDataValid = 4'h0;
    lineBuffDataValid[currentWrLineBuffer] = in_tvalid;
end

always @(posedge clk) begin
    if(!resetn) begin
        currentRdLineBuffer <= 2'd0;
    end
    else if (rdCounter == 9'd511 && rdLineBuffer)
        currentRdLineBuffer <= currentRdLineBuffer + 2'd1;
end

always @(*) begin
    case (currentRdLineBuffer)
        2'd0: out_data = {lB2data,lB1data,lB0data};
        2'd1: out_data = {lB3data,lB2data,lB1data};
        2'd2: out_data = {lB0data,lB3data,lB2data};
        2'd3: out_data = {lB1data,lB0data,lB3data};
    endcase
end

always @(*) begin
    case (currentRdLineBuffer)
        2'd0: begin
            lineBuffRdData[0] = rdLineBuffer;
            lineBuffRdData[1] = rdLineBuffer;
            lineBuffRdData[2] = rdLineBuffer;
            lineBuffRdData[3] = 1'b0;
        end
        2'd1: begin
            lineBuffRdData[0] = 1'b0;
            lineBuffRdData[1] = rdLineBuffer;
            lineBuffRdData[2] = rdLineBuffer;
            lineBuffRdData[3] = rdLineBuffer;
        end
        2'd2: begin
            lineBuffRdData[0] = rdLineBuffer;
            lineBuffRdData[1] = 1'b0;
            lineBuffRdData[2] = rdLineBuffer;
            lineBuffRdData[3] = rdLineBuffer;
        end
        2'd3: begin
            lineBuffRdData[0] = rdLineBuffer;
            lineBuffRdData[1] = rdLineBuffer;
            lineBuffRdData[2] = 1'b0;
            lineBuffRdData[3] = rdLineBuffer;
        end
    endcase
end

// Line buffer instances (unchanged)
line_buffer lB0 (
    .clk(clk),
    .resetn(resetn),
    .in_data(in_data),
    .in_tvalid(lineBuffDataValid[0]),
    .in_rd_data(lineBuffRdData[0]),
    .out_data(lB0data)
);

line_buffer lB1 (
    .clk(clk),
    .resetn(resetn),
    .in_data(in_data),
    .in_tvalid(lineBuffDataValid[1]),
    .in_rd_data(lineBuffRdData[1]),
    .out_data(lB1data)
);

line_buffer lB2 (
    .clk(clk),
    .resetn(resetn),
    .in_data(in_data),
    .in_tvalid(lineBuffDataValid[2]),
    .in_rd_data(lineBuffRdData[2]),
    .out_data(lB2data)
);

line_buffer lB3 (
    .clk(clk),
    .resetn(resetn),
    .in_data(in_data),
    .in_tvalid(lineBuffDataValid[3]),
    .in_rd_data(lineBuffRdData[3]),
    .out_data(lB3data)
);

endmodule
