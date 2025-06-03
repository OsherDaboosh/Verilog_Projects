`timescale 1ns / 1ps

module axis_sobel(
    input         s_axi_aclk,
    input         s_axi_aresetn,
    input  [7:0]  s_axis_tdata,
    input         s_axis_tvalid,
    output        s_axis_tready,
    output [7:0]  m_axis_tdata,
    output        m_axis_tvalid,
    output        o_intr,
    input         m_axis_tready
);

    wire [71:0] pixel_data;
    wire        pixel_data_valid;
    wire        axis_prog_full;
    wire [7:0]  sobel_data;
    wire        sobel_data_valid;
    
    assign s_axis_tready = !axis_prog_full;
    
    sobel_control SB (
        .clk(s_axi_aclk),
        .resetn(s_axi_aresetn),
        .in_data(s_axis_tdata),
        .in_tvalid(s_axis_tvalid),
        .out_tvalid(pixel_data_valid),
        .o_intr(o_intr),
        .out_data(pixel_data)
    );
        
    sobel S (
        .clk(s_axi_aclk),
        .in_data(pixel_data),
        .in_tvalid(pixel_data_valid),
        .out_tvalid(sobel_data_valid),
        .out_data(sobel_data)
    );

    OutputBuffer OB (
        .wr_rst_busy(),       
        .rd_rst_busy(),       
        .s_aclk(s_axi_aclk),                 
        .s_aresetn(s_axi_aresetn),           
        .s_axis_tvalid(sobel_data_valid),    
        .s_axis_tready(),    
        .s_axis_tdata(sobel_data),     
        .m_axis_tvalid(m_axis_tvalid),    
        .m_axis_tready(m_axis_tready),    
        .m_axis_tdata(m_axis_tdata),     
        .axis_prog_full(axis_prog_full)  
    );
   
endmodule
