`timescale 1ns / 1ps

module anode_encoder(
    input  wire [2:0] anode,
    output reg  [1:0] sel
);

always @(*) begin
    case (anode)
        3'b110:  sel = 2'b00;
        3'b101:  sel = 2'b01;
        3'b011:  sel = 2'b10;
        default: sel = 2'bxx;
    endcase
end
endmodule
