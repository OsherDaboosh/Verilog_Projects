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

// Local variables
reg [WIDTH-1:0] ram [0:DEPTH-1];
reg [$clog2(DEPTH)-1:0] head;
reg [$clog2(DEPTH)-1:0] tail;
reg [$clog2(DEPTH):0] count;
reg [$clog2(DEPTH):0] count_p1;
reg read_while_write_p1;

// Assign s_axis_tready
assign s_axis_tready = (count < DEPTH - 1);

// Head (write pointer) update
always @(posedge s_axi_aclk) begin
    if (!s_axi_aresetn)
        head <= 0;
    else if (s_axis_tvalid && s_axis_tready)
        head <= (head == DEPTH-1) ? 0 : head + 1;
end

// Tail (read pointer) update
always @(posedge s_axi_aclk) begin
    if (!s_axi_aresetn)
        tail <= 0;
    else if (m_axis_tvalid && m_axis_tready)
        tail <= (tail == DEPTH-1) ? 0 : tail + 1;
end

// Write to memory
always @(posedge s_axi_aclk) begin
    if (s_axis_tvalid && s_axis_tready)
        ram[head] <= s_axis_tdata;
end

// Read from memory (next read address)
wire [$clog2(DEPTH)-1:0] tail_next = (tail == DEPTH-1) ? 0 : tail + 1;
always @(posedge s_axi_aclk) begin
    m_axis_tdata <= ram[tail_next];
end

// Count calculation
always @(*) begin
    if (head < tail)
        count = head - tail + DEPTH;
    else
        count = head - tail;
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
        read_while_write_p1 <= s_axis_tvalid && s_axis_tready && m_axis_tvalid && m_axis_tready;
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
