`timescale 1ns / 1ps

module seven_seg_decoder(
    input      [3:0] x,
    output reg [6:0] y
);

always @(*) begin
    case (x)
        4'b0000: y = 7'b0000001;
        4'b0001: y = 7'b1001111;
        4'b0010: y = 7'b0010010;
        4'b0011: y = 7'b0000110;
        4'b0100: y = 7'b1001100;
        4'b0101: y = 7'b0100100;
        4'b0110: y = 7'b0100000;
        4'b0111: y = 7'b0001111;
        4'b1000: y = 7'b0000000;
        4'b1001: y = 7'b0000100;
    endcase
end
endmodule
