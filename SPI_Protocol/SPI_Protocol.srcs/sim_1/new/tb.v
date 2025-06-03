`timescale 1ns / 1ps

module tb;

    // Parameters
    parameter CLK_PERIOD = 10;  // 100MHz clock (10ns period)

    // Testbench signals
    reg clk;
    reg reset;
    reg [7:0] in_data;
    reg start;
    wire mosi;
    wire sclk;
    wire ss;

    // Instantiate the SPI master module
    spi_master uut (
        .clk(clk),
        .reset(reset),
        .in_data(in_data),
        .start(start),
        .mosi(mosi),
        .sclk(sclk),
        .ss(ss)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        start = 0;
        in_data = 8'b10101010;

        // Apply reset
        #20;
        reset = 0;

        // Start SPI transmission
        #10;
        start = 1;

        // Deassert start after one cycle
        #10;
        start = 0;

        // Wait for transmission to complete
        #300;

        // End simulation
        $finish;
    end

    // Monitor useful signal activity
    initial begin
        $display("Time\tclk\treset\tstart\tss\tmosi\tsclk\tbit_count");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%0d",
                 $time, clk, reset, start, ss, mosi, sclk, uut.bit_count);
    end

endmodule
