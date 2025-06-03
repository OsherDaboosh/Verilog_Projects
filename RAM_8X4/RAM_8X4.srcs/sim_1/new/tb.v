`timescale 1ns / 1ps

module tb;

    reg clk, we;
    reg [2:0] address;
    reg [3:0] in_data;
    wire [3:0] out_data;

    // Instantiate RAM
    ram uut (
        .clk(clk),
        .we(we),
        .address(address),
        .in_data(in_data),
        .out_data(out_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Time\tWE\tAddr\tIn\tOut");
        $monitor("%g\t%b\t%0d\t%0d\t%0d", $time, we, address, in_data, out_data);

        clk = 0;
        we = 1;

        // Write to all addresses
        for (address = 0; address < 8; address = address + 1) begin
            in_data = address + 1;   // Just example values
            #10;
        end

        // Read back from all addresses
        we = 0;
        for (address = 0; address < 8; address = address + 1) begin
            #10;
        end

        $finish;
    end
endmodule
