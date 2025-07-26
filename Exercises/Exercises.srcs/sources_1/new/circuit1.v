`timescale 1ns / 1ps

module circuit1(
    input  clk,
    input  en,
    input  up_dn,
    input  clr,
    output y
);

reg [1:0] count;
reg [2:0] b;
reg       t0, t2;
wire      t1;

// COUNT
always @(posedge clk) begin
    if (clr) begin
        count <= 2'b00;
    end
    else if (en) begin
        if (up_dn) 
            count <= count + 1;
        else 
            count <= count - 1;
    end
end

// DECODER
always @(*) begin
    case (count)
        2'b00:   b <= 3'b001;
        2'b01:   b <= 3'b010;
        2'b10:   b <= 3'b100;
        default: b <= 3'b000;
    endcase
end

always @(posedge clk) begin
    t0 <= b[2];
end

assign t1 = b[0] & t0;

always @(posedge clk) begin
    t2 <= t1;
end

assign y = b[1] ^ t2;

endmodule
