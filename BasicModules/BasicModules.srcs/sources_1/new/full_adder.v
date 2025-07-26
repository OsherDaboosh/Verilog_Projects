`timescale 1ns / 1ps

module full_adder(input A,
                  input B,
                  input CIN,
                  output SUM,
                  output COUT
);
    wire S1, C1, C2;
    
    half_adder HA1 (.A(A), .B(B), .SUM(S1), .COUT(C1));
    half_adder HA2 (.A(S1), .B(CIN), .SUM(SUM), .COUT(C2));
    
    or G1 (COUT, C1, C2);  // OR gate for COUT
endmodule
