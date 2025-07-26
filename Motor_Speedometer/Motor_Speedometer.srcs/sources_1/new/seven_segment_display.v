`timescale 1ns / 1ps

module seven_segment_display(
    input            clk,
    input            reset,
    input      [7:0] speed,
    output reg [6:0] seg,
    output reg [3:0] an
);

// Internal digit values
reg [3:0] digit0, digit1, digit2;

// Break the 8-bit speed into 3 digits
always @(*) begin
    digit0 = speed % 10;             // Units
    digit1 = (speed / 10) % 10;      // Tens
    digit2 = (speed / 100) % 10;     // Hundreds
end

// Digit refresh counter
reg  [16:0] refresh_counter = 0;
wire [1:0]  refresh_sel = refresh_counter[16:15]; // 4 multiplexed states

always @(posedge clk) begin
    if (reset)
        refresh_counter <= 0;
    else
        refresh_counter <= refresh_counter + 1;
end

// 7-segment decoder
reg [3:0] current_digit;
always @(*) begin
    case (refresh_sel)
        2'b00: begin
            an = 4'b1110;       // Enable digit0 (rightmost)
            current_digit = digit0;
        end
        2'b01: begin
            an = 4'b1101;       // Enable digit1
            current_digit = digit1;
        end
        2'b10: begin
            an = 4'b1011;       // Enable digit2
            current_digit = digit2;
        end
        default: begin
            an = 4'b1111;       // Turn off all
            current_digit = 4'd0;
        end
    endcase
end

always @(*) begin
    case (current_digit)
        4'd0:    seg = 7'b0000001;
        4'd1:    seg = 7'b1001111;
        4'd2:    seg = 7'b0010010;
        4'd3:    seg = 7'b0000110;
        4'd4:    seg = 7'b1001100;
        4'd5:    seg = 7'b0100100;
        4'd6:    seg = 7'b0100000;
        4'd7:    seg = 7'b0001111;
        4'd8:    seg = 7'b0000000;
        4'd9:    seg = 7'b0000100;
        default: seg = 7'b1111111;
    endcase
end
endmodule
