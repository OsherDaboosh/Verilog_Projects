`timescale 1ns / 1ps

module logic_gates(
    input A,
    input B,
    output AND_OUT,
    output OR_OUT,
    output XOR_OUT,
    output NOT_OUT
);
    assign AND_OUT = A & B;  // AND operation
    assign OR_OUT  = A | B;  // OR operation
    assign XOR_OUT = A ^ B;  // XOR operation
    assign NOT_OUT = ~A;     // NOT operation
endmodule
