`timescale 1ns / 1ps

module tb;
    reg [2:0] address;
    wire [3:0] data;

    rom uut (.address(address), .data(data));

    initial begin
        address = 3'b000;
        #10; address = 3'b001;
        #10; address = 3'b010;
        #10; address = 3'b011;
        #10; address = 3'b100;
        #10; address = 3'b101;
        #10; address = 3'b110;
        #10; address = 3'b111;
        $finish;
    end
endmodule
