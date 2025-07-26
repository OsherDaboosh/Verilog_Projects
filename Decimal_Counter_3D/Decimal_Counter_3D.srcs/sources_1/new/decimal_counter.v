`timescale 1ns / 1ps

module decimal_counter(
    input             CLK100MHZ,
    input             RESET,
    input       [3:0] TOP_COUNT,
    output wire [6:0] SEVEN_SEG,
    output wire [2:0] ANODES,
    output wire       LED,
    output wire       AN3
);

wire       CLK5;
wire       CLK500;
wire [2:0] AN;
wire [1:0] SEL;
wire       T0, T1, T2;
wire       EN1, EN2;
wire       R0, R1;
wire       CLR_ALL;
wire [3:0] D0, D1, D2;
wire [3:0] I;

assign ANODES = AN;
assign LED    = T0 & T1 & T2;
assign AN3    = 1'b1;

divider div (
    .clk(CLK100MHZ),
    .reset(RESET),
    .clk5(CLK5),
    .clk500(CLK500)
);

counter cnt0 (
    .clk5(CLK5),
    .reset(RESET),
    .en(1'b1),
    .clr(CLR_ALL),
    .top_count(TOP_COUNT),
    .top_count_reach(T0),
    .reach9(R0),
    .q(D0)
);

counter cnt1 (
    .clk5(CLK5),
    .reset(RESET),
    .en(EN1),
    .clr(CLR_ALL),
    .top_count(TOP_COUNT),
    .top_count_reach(T1),
    .reach9(R1),
    .q(D1)
);

counter cnt2 (
    .clk5(CLK5),
    .reset(RESET),
    .en(EN2),
    .clr(CLR_ALL),
    .top_count(TOP_COUNT),
    .top_count_reach(T2),
    .reach9(R2),
    .q(D2)
);

comb_logic comb_log (
    .t0(T0),
    .t1(T1),
    .t2(T2),
    .r0(R0),
    .r1(R1),
    .en1(EN1),
    .en2(EN2),
    .clr_all(CLR_ALL)
);

shift_reg s_r (
    .clk500(CLK500),
    .reset(RESET),
    .anode(AN)
);

anode_encoder anode_enc (
    .anode(AN),
    .sel(SEL)
);

mux_4x1 mux (
    .x0(D0),
    .x1(D1),
    .x2(D2),
    .sel(SEL),
    .y(I)
);

seven_seg_decoder seg_decoder (
    .x(I),
    .y(SEVEN_SEG)
);

endmodule
