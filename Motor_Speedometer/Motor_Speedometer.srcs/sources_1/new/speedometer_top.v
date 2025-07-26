`timescale 1ns / 1ps

module speedometer_top(
    input        clk,         // 100MHz
    input        reset,
    input  [1:0] sw,          // SW0 & SW1
    output       pwm_out,     // PWM signal for motor
    output [6:0] seg,         // 7-segment segments
    output [3:0] an           // 7-segment anodes
);

wire       clk_100hz;
wire       sw0, sw1;
wire [1:0] sw_clean = {sw1, sw0};
wire [1:0] speed_level;
wire [7:0] current_speed;

divider div (
    .clk(clk),
    .reset(reset),
    .clk100(clk_100hz)
);

debouncer db0 (
    .clk(clk),
    .reset(reset),
    .sw_in(sw[0]),
    .sw_out(sw0)
);

debouncer db1 (
    .clk(clk),
    .reset(reset),
    .sw_in(sw[1]),
    .sw_out(sw1)
);

speed_control speed_ctrl (
    .clk(clk),
    .reset(reset),
    .sw_in(sw_clean),
    .pwm_out(pwm_out),
    .speed_level(speed_level)
);

speed_counter speed_cntr (
    .clk100(clk_100hz),            
    .reset(reset),
    .speed_level(speed_level),
    .current_speed(current_speed)
);

seven_segment_display seven_seg_disp (
    .clk(clk),
    .reset(reset),
    .speed(current_speed),
    .seg(seg),
    .an(an)
);

endmodule
