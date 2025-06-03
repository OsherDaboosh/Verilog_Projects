`timescale 1ns / 1ps

module tb;
    // Testbench signals
    reg clk;
    reg reset;
    reg we;
    reg re;
    reg [3:0] in_data;
    wire [3:0] out_data;
    wire full, empty;

    // Declare loop index outside
    reg [3:0] i;

    // Instantiate FIFO
    fifo uut (
        .clk(clk),
        .reset(reset),
        .we(we),
        .re(re),
        .in_data(in_data),
        .out_data(out_data),
        .full(full),
        .empty(empty)
    );

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        we = 0;
        re = 0;
        in_data = 0;

        // Reset the FIFO
        #10;
        reset = 0;

        $display("Time\tWE\tRE\tIn\tOut\tFull\tEmpty");
        $monitor("%g\t%b\t%b\t%h\t%h\t%b\t%b", $time, we, re, in_data, out_data, full, empty);

        // WRITE 8 items into FIFO (until full)
        we = 1;
        re = 0;
        for (i = 0; i < 8; i = i + 1) begin
            in_data = i + 1;
            #10;
        end

        // Try one extra write (should be ignored)
        in_data = 4'hF;
        #10;

        // READ 8 items from FIFO (until empty)
        we = 0;
        re = 1;
        #10;

        for (i = 0; i < 8; i = i + 1) begin
            #10;
        end

        // Extra read
        #10;

        $finish;
    end
endmodule
