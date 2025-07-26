`timescale 1ns / 1ps

module decoder_4x8(
    input [3:0] sel,
    output reg [7:0] y
);
    always @(*) begin
        casez (sel)
            4'b000?: y = 8'b00000001;  // matches 0000 to 0001
            4'b001?: y = 8'b00000010;  // matches 0010 to 0011
            4'b01??: y = 8'b00000100;  // matches 0100 to 0111
            default: y = 8'b00000000;
        endcase
    end
endmodule
