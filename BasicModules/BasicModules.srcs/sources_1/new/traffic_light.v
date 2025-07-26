`timescale 1ns / 1ps

module traffic_light(
    input clk,
    input reset,
    output reg [1:0] light
);
    parameter GREEN = 2'b00, YELLOW = 2'b01, RED = 2'b10;
    reg [1:0] state;
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= GREEN;  // Start with GREEN light
        else begin
            case (state)
                GREEN: state <= YELLOW;
                YELLOW: state <= RED;
                RED: state <= GREEN;
                default: state <= GREEN;
            endcase
        end
    end

    always @(*) begin
        case (state)
            GREEN: light = 2'b00;
            YELLOW: light = 2'b01;
            RED: light = 2'b10;
            default: light = 2'b00;
        endcase
    end
endmodule
