`timescale 1ns / 1ps

module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input                  s_axi_aclk,
    input                  s_axi_aresetn,
    input      [WIDTH-1:0] s_axis_tdata,
    input                  s_axis_tvalid,
    output                 s_axis_tready,
    output reg             m_axis_tvalid,
    input                  m_axis_tready,
    output reg [WIDTH-1:0] m_axis_tdata
);

// Memory
reg [WIDTH-1:0] memory [0:DEPTH-1];

// Pointers
reg [$clog2(DEPTH)-1:0] wrPtr;
reg [$clog2(DEPTH)-1:0] rdPtr;

// Counters
reg [$clog2(DEPTH):0] count;
reg [$clog2(DEPTH):0] count_p1;

// Control Signals
wire wr_en = s_axis_tvalid && s_axis_tready;
wire rd_en = m_axis_tvalid && m_axis_tready;
reg read_while_write_p1;

// Assign s_axis_tready
assign s_axis_tready = (count < DEPTH-1);

// Write pointer update
always @(posedge s_axi_aclk) begin
    if (!s_axi_aresetn)
        wrPtr <= 0;
    else if (wr_en)
        wrPtr <= (wrPtr == DEPTH-1) ? 0 : wrPtr + 1;
end

// Read pointer update
always @(posedge s_axi_aclk) begin
    if (!s_axi_aresetn)
        rdPtr <= 0;
    else if (rd_en)
        rdPtr <= (rdPtr == DEPTH-1) ? 0 : rdPtr + 1;
end

// Write to memory
always @(posedge s_axi_aclk) begin
    if (wr_en)
        memory[wrPtr] <= s_axis_tdata;
end

// Read from memory (next read address)
wire [$clog2(DEPTH)-1:0] next_rd_addr = (rdPtr == DEPTH-1) ? 0 : rdPtr + 1;

always @(posedge s_axi_aclk) begin
    m_axis_tdata <= memory[next_rd_addr];
end

// Count calculation
always @(*) begin
    if (wrPtr < rdPtr)
        count = wrPtr - rdPtr + DEPTH;
    else
        count = wrPtr - rdPtr;
end

// Count pipeline register
always @(posedge s_axi_aclk) begin
    if (!s_axi_aresetn)
        count_p1 <= 0;
    else
        count_p1 <= count;
end

// Read-while-write overlap detection
always @(posedge s_axi_aclk) begin
    if (!s_axi_aresetn)
        read_while_write_p1 <= 0;
    else
        read_while_write_p1 <= wr_en && rd_en;
end

// Output valid logic
always @(*) begin
    m_axis_tvalid = 1'b1;
    if (count == 0 || count_p1 == 0)
        m_axis_tvalid = 1'b0;
    else if (count == 1 && read_while_write_p1)
        m_axis_tvalid = 1'b0;
end
endmodule
