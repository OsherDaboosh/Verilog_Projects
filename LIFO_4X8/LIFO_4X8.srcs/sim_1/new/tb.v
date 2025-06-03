`timescale 1ns / 1ps

module tb;

    reg clk;
    reg reset;
    reg push;
    reg pop;
    reg [3:0] in_data;
    wire [3:0] out_data;
    wire full;
    wire empty;
    
    reg [3:0] i;

    lifo uut (.clk(clk), .reset(reset), .push(push), .pop(pop), .in_data(in_data), 
              .out_data(out_data), .full(full), .empty(empty));

    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        reset = 1;
        push = 0;
        pop = 0;
        in_data = 0;
        
        #10;
        reset = 0; 

        push = 1;
        pop = 0;
        for (i = 0; i < 8; i = i + 1) begin
            in_data = i + 1;
            #10;
        end
        
        push = 0;
        pop = 1;
        for (i = 0; i < 8; i = i + 1) begin
            #10;
        end
        
        #10;
        
        $finish;
    end
endmodule
