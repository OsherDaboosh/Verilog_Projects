`timescale 1ns / 1ps

module axis_rgb2gray2binary(
    input         s_axi_aclk,
    input         s_axi_aresetn,
    input  [31:0] s_axis_tdata,
    input         s_axis_tvalid,
    output        s_axis_tready,
    output [31:0] m_axis_tdata,
    output        m_axis_tvalid,
    input         m_axis_tready,
    input  [7:0]  threshold
);

    wire [7:0]  grayPixel;
    wire        grayValid;
    wire [31:0] binaryData;
    wire        binaryValid;

    rgb2gray gray (
        .clk(s_axi_aclk),
        .resetn(s_axi_aresetn),
        .in_data(s_axis_tdata),
        .in_tvalid(s_axis_tvalid),
        .out_tvalid(grayValid),
        .out_data(grayPixel)
    );

    gray2binary binary (
        .clk(s_axi_aclk),
        .resetn(s_axi_aresetn),
        .in_data(s_axis_tdata),
        .in_tvalid(grayValid),
        .threshold(threshold),
        .out_tvalid(binaryValid),
        .out_data(binaryData)
    );

    OutputBuffer OB (
        .wr_rst_busy(),      
        .rd_rst_busy(),      
        .s_aclk(s_axi_aclk),                
        .s_aresetn(s_axi_aresetn),          
        .s_axis_tvalid(binaryValid),  
        .s_axis_tready(),  
        .s_axis_tdata(binaryData),    
        .m_axis_tvalid(m_axis_tvalid),  
        .m_axis_tready(m_axis_tready),  
        .m_axis_tdata(m_axis_tdata)    
    );

endmodule
