`timescale 1ns / 1ps

module tb();

// Parameters
parameter WIDTH = 8;
parameter DEPTH = 16;

// DUT Signals
reg              clk;
reg              resetn;
reg  [WIDTH-1:0] s_axis_tdata;
reg              s_axis_tvalid;
wire             s_axis_tready;
wire             m_axis_tvalid;
reg              m_axis_tready;
wire [WIDTH-1:0] m_axis_tdata;

// Instantiate DUT
fifo #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) dut (
    .s_axi_aclk(clk),
    .s_axi_aresetn(resetn),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tdata(m_axis_tdata)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;  
end

// Stimulus
initial begin
    // Init
    resetn = 0;
    s_axis_tdata = 0;
    s_axis_tvalid = 0;
    m_axis_tready = 0;

    // Reset pulse
    #20 resetn = 1;

    // Write 10 values to FIFO
    repeat (10) begin
        @(posedge clk);
        if (s_axis_tready) begin
            s_axis_tvalid <= 1;
            s_axis_tdata <= s_axis_tdata + 1;
        end
    end
    s_axis_tvalid <= 0;

    // Wait a bit before reading
    #50;

    // Start reading from FIFO
    m_axis_tready <= 1;

    // Read while valid
    repeat (12) begin
        @(posedge clk);
        if (m_axis_tvalid) begin
            $display("Read data: %d", m_axis_tdata);
        end
    end

    // Finish
    $finish;
end
endmodule
