`timescale 1ns / 1ps

module rom(
    input [2:0] address,
    output reg [3:0] data
);
    always @(*) begin
        case (address)
            3'b000:  data = 4'b0001;
            3'b001:  data = 4'b0010;
            3'b010:  data = 4'b0011;
            3'b011:  data = 4'b0100;
            3'b100:  data = 4'b0101;
            3'b101:  data = 4'b0110;
            3'b110:  data = 4'b0111;
            3'b111:  data = 4'b1000;
            default: data = 4'b0000;
        endcase
    end
endmodule
