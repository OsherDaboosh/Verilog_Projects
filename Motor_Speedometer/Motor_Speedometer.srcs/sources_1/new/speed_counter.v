`timescale 1ns / 1ps

module speed_counter(
    input            clk100,        
    input            reset,
    input      [1:0] speed_level,   // From speed_control
    output reg [7:0] current_speed  // 3-digit decimal (e.g., 100, 060, 020)
);

reg [7:0] target_speed;

always @(*) begin
    case (speed_level) 
        2'b00:   target_speed = 8'd0;
        2'b01:   target_speed = 8'd20;
        2'b10:   target_speed = 8'd60;
        2'b11:   target_speed = 8'd100;
        default: target_speed = 8'd0;
    endcase
end

always @(posedge clk100) begin
    if (reset) begin
        current_speed <= 8'd0;
    end
    else begin
        if (current_speed < target_speed)
            current_speed <= current_speed + 1;
        else if (current_speed > target_speed)
            current_speed <= current_speed - 1;
    end
end
endmodule
