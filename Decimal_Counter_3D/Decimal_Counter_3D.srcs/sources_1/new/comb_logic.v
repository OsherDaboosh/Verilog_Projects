`timescale 1ns / 1ps

module comb_logic(
    input       t0,
    input       t1,
    input       t2,
    input       r0,
    input       r1,
    output reg  en1,
    output reg  en2,
    output wire clr_all
);

always @(*) begin
    en1 = (r0) ? 1'b1 : 1'b0;
    en2 = (r0 && r1) ? 1'b1 : 1'b0;
end

assign clr_all = t0 & t1 & t2;

endmodule
