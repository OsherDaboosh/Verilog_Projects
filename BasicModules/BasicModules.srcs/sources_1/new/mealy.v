`timescale 1ns / 1ps

module mealy(
    input clk,
    input reset,
    input in_data,
    output reg out_data
);

    parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10;
    reg [1:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            out_data <= 0;
        end 
        else begin
            case (state)
                S0: begin
                    state <= (in_data) ? S1 : S0;
                    out_data <= 0;
                end
                S1: begin
                    state <= (in_data) ? S1 : S2;
                    out_data <= 0;
                end
                S2: begin
                    if (in_data) begin
                        state <= S1;
                        out_data <= 1;  // Sequence detected
                    end else begin
                        state <= S0;
                        out_data <= 0;
                    end
                end
                default: begin
                    state <= S0;
                    out_data <= 0;
                end
            endcase
        end
    end
endmodule
