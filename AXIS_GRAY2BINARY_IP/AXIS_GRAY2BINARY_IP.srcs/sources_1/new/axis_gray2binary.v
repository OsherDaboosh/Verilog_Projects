`timescale 1ns / 1ps

module axis_gray2binary(
    input         s_axi_aclk,
    input         s_axi_aresetn,
    input  [7:0]  s_axis_tdata,
    input         s_axis_tvalid,
    output        s_axis_tready,
    output [7:0]  m_axis_tdata,
    output        m_axis_tvalid,
    input         m_axis_tready,
    input  [7:0]  threshold
);
    wire [7:0] binaryData;
    wire       binaryValid;
    wire       gray_ready;
    
    // Connect the ready signal properly
    assign s_axis_tready = gray_ready;
    
    gray2binary gray_uut (
        .clk(s_axi_aclk),
        .resetn(s_axi_aresetn),
        .in_data(s_axis_tdata),
        .in_tvalid(s_axis_tvalid),
        .in_tready(gray_ready),
        .out_tvalid(binaryValid),
        .out_data(binaryData),
        .threshold(threshold)
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
