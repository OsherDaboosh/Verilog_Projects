`timescale 1ns / 1ps

module dc_motor_control(
    input       CLK,
    input       RESET,
    input [1:0] SW,
    output      PWM_OUT
);

wire sw0_out;
wire sw1_out;

debouncer d1 (
    .clk(CLK),
    .reset(RESET),
    .sw_in(SW[0]),
    .sw_out(sw0_out)
);

debouncer d2 (
    .clk(CLK),
    .reset(RESET),
    .sw_in(SW[1]),
    .sw_out(sw1_out)
);

speed_control sc (
    .clk(CLK),
    .reset(RESET),
    .sw0(sw0_out),
    .sw1(sw1_out),
    .pwm_out(PWM_OUT)
);

endmodule
