`timescale 1ns / 1ps

module tb;
    reg d, clk;
    wire q;
    
    d_flip_flop uut(.d(d), .clk(clk), .q(q));

    always #5 clk = ~clk; // Clock toggles every 5 time units

    initial begin
        
        clk = 0; d = 0;
        #10; d = 1;
        #10; d = 0;
        #10; d = 1;
        #10; d = 0;
        #10;
        
        $finish;
    end
        
endmodule
