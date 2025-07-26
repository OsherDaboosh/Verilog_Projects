`timescale 1ns / 1ps

module tb;

    // Parameters
    parameter CLK_PERIOD  = 10;  // 100MHz clock (10ns period)
    parameter DELAY_COUNT = 10;  // Small count for simulation speed

    // Testbench signals
    reg clk;
    reg reset;
    reg sw_in;
    wire sw_out;

    // Instantiate the debouncer
    switch_dobouncer #(.DELAY_COUNT(DELAY_COUNT)) 
        uut (.clk(clk), .reset(reset), .sw_in(sw_in), .sw_out(sw_out));
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        reset = 1;
        sw_in = 0;
        
        $display("Starting debouncer test...");
        
        // Release reset
        #20;
        reset = 0;
        #100;
        
        // Test Case 1: Clean switch press
        $display("Test 1: Clean switch press");
        sw_in = 1;
        #(CLK_PERIOD * (DELAY_COUNT + 2));
        
        // Test Case 2: Clean switch release
        $display("Test 2: Clean switch release");
        sw_in = 0;
        #(CLK_PERIOD * (DELAY_COUNT + 2));
        
        // Test Case 3: Bouncing switch
        $display("Test 3: Bouncing switch");
        repeat(5) begin
            sw_in = 1;
            #(CLK_PERIOD * 2);
            sw_in = 0;
            #(CLK_PERIOD * 1);
        end
    
        sw_in = 1;  // Final stable state
        #(CLK_PERIOD * (DELAY_COUNT + 2));
        
        // Test Case 4: Short glitch (should be ignored)
        $display("Test 4: Short glitch");
        sw_in = 0;
        #(CLK_PERIOD * 2);
        sw_in = 1;
        #(CLK_PERIOD * 1);
        sw_in = 0;
        #(CLK_PERIOD * (DELAY_COUNT + 2));
    
        $display("Test completed successfully!");
        $finish;
    end
    
    // Monitor output changes
    always @(sw_out) begin
        $display("Time %0t: sw_out changed to %b", $time, sw_out);
    end
    
endmodule
