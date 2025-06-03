`timescale 1ns / 1ps

module uart_controller(
    input wire clk,
    input wire reset,
    input wire tx_enable,
    input wire [7:0] in_data,
    input wire rx,
    output wire [7:0] out_data,
    output wire tx
);

    wire swPressed; 
    
    // Debouncer for the tx_enable input
    debouncer uutD (.clk(clk), .reset(reset), .sw_in(tx_enable), .sw_out(swPressed));
    
    // UART Top Module
    uart_top uutT (.clk(clk), .reset(reset), .tx_start(swPressed), .in_data(in_data),
                   .out_data(out_data), .rx(rx), .tx(tx));

endmodule
