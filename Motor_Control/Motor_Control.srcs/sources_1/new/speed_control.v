`timescale 1ns / 1ps

module speed_control(
    input      clk,
    input      reset,
    input      sw0,
    input      sw1,
    output reg pwm_out
);

localparam [11:0] PERIOD = 12'h3FF; // 1023
localparam [11:0] DUTY20 = (PERIOD * 2) / 10;  // 20% Duty Cycle
localparam [11:0] DUTY60 = (PERIOD * 6) / 10;  // 60% Duty Cycle

reg [11:0] count      = 0;
reg [11:0] duty_cycle = 0;

always @(posedge clk) begin
    if (reset) begin
        duty_cycle <= 0;
    end
    else begin
        if (sw0 & sw1) 
            duty_cycle <= PERIOD;  // 100% Duty Cycle (Full Speed)
        else if (sw0)
            duty_cycle <= DUTY20;  // 20% Speed
        else if (sw1)
            duty_cycle <= DUTY60;  // 60% Speed
        else
            duty_cycle <= 0;       // 0% (Motor Off)
    end
end

always @(posedge clk) begin
    if (reset) begin
        count   <= 12'd0;
        pwm_out <= 1'b0;
    end
    else begin
        if (count < PERIOD) 
            count <= count + 1;
        else
            count <= 12'd0;
    end
    if (count < duty_cycle)
        pwm_out <= 1'b1;
    else
        pwm_out <= 1'b0;
end
endmodule
