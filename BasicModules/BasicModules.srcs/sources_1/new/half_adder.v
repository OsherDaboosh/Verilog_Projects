`timescale 1ns / 1ps

module half_adder(
    input A,
    input B,
    output SUM,
    output COUT
);
    xor G1 (SUM, A, B);   // XOR gate for sum
    and G2 (COUT, A, B);  // AND gate for carry
endmodule
