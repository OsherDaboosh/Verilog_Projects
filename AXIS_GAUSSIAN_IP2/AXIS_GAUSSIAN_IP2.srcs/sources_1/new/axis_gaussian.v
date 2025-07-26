`timescale 1ns / 1ps

module axis_gaussian(
    input         s_axi_aclk,
    input         s_axi_aresetn,
    input  [7:0]  s_axis_tdata,
    input         s_axis_tvalid,
    input  [7:0]  sigma_x16,
    output        s_axis_tready,
    output [7:0]  m_axis_tdata,
    output        m_axis_tvalid,
    input         m_axis_tready,
    output        out_intr
);

wire [71:0] pixel_data;
wire        pixel_data_valid;
wire        axis_prog_full;
wire [7:0]  gauss_data;
wire        gauss_data_valid;

assign s_axis_tready = !axis_prog_full;

gaussian_control GC (
    .clk(s_axi_aclk),
    .resetn(s_axi_aresetn),
    .in_data(s_axis_tdata),
    .in_tvalid(s_axis_tvalid),
    .out_tvalid(pixel_data_valid),
    .out_data(pixel_data),
    .out_intr(out_intr)
);    

gaussian G (
    .clk(s_axi_aclk),
    .in_data(pixel_data),
    .in_tvalid(pixel_data_valid),
    .sigma_x16(sigma_x16),
    .out_tvalid(gauss_data_valid),
    .out_data(gauss_data)
);

OutputBuffer OB (
  .wr_rst_busy(),        
  .rd_rst_busy(),       
  .s_aclk(s_axi_aclk),                  
  .s_aresetn(s_axi_aresetn),            
  .s_axis_tvalid(gauss_data_valid),    
  .s_axis_tready(),   
  .s_axis_tdata(gauss_data),      
  .m_axis_tvalid(m_axis_tvalid),  
  .m_axis_tready(m_axis_tready),    
  .m_axis_tdata(m_axis_tdata),      
  .axis_prog_full(axis_prog_full)  
);

endmodule
