`timescale 1ns / 1ps

module mux2x1(input a,
              input b,
              input sel,
              output reg y
);
    always @(*) begin
        if (sel)
            y = b;
        else
            y = a;
    end
endmodule
