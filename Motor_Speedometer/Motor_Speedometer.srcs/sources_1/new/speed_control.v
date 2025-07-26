`timescale 1ns / 1ps

module speed_control(
    input            clk,
    input            reset,
    input      [1:0] sw_in,
    output reg       pwm_out,
    output reg [1:0] speed_level  // Added output for current speed
);

localparam [11:0] PERIOD = 1023;               // 100% Duty Cycle
localparam [11:0] DUTY20 = (PERIOD * 2) / 10;  // 20% Duty Cycle
localparam [11:0] DUTY60 = (PERIOD * 6) / 10;  // 60% Duty Cycle

reg [11:0] count      = 0;
reg [11:0] duty_cycle = 0;

always @(posedge clk) begin
    if (reset) begin
        duty_cycle  <= 0;
        speed_level <= 2'b00;
    end
    else begin
        case (sw_in)
            2'b11: begin
                duty_cycle  <= PERIOD; // 100% Duty Cycle (Full Speed)
                speed_level <= 2'b11;  // Speed level 3
            end
            2'b01: begin
                duty_cycle  <= DUTY20; // 20% Speed
                speed_level <= 2'b01;  // Speed level 1
            end
            2'b10: begin
                duty_cycle  <= DUTY60;  // 60% Speed
                speed_level <= 2'b10;  // Speed level 2
            end
            default: begin
                duty_cycle  <= 0;      // 0% (Motor Off)
                speed_level <= 2'b00;  // Speed level 0
            end
        endcase
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
