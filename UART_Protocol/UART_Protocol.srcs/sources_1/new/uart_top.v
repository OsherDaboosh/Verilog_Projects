`timescale 1ns / 1ps

module uart_top(
    input wire clk,
    input wire reset,
    input wire tx_start,
    input wire [7:0] in_data,
    input wire rx,
    output wire [7:0] out_data,
    output wire tx
);

    // UART Transmitter instance
    uart_tx uutTx (.clk(clk), .reset(reset), .tx_start(tx_start), .tx_in_data(in_data), .tx_out_data(tx));

    // UART Receiver instance
    uart_rx uutRx (.clk(clk), .reset(reset), .rx_in_data(rx), .rx_out_data(out_data));

endmodule
