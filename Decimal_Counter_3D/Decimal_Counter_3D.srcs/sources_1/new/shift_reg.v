`timescale 1ns / 1ps

module shift_reg(
    input             clk500,
    input             reset,
    output wire [2:0] anode
);

reg [2:0] temp = 3'b110; 

always @(posedge clk500) begin
    if (reset) 
        temp <= 3'b110;
    else 
        temp <= {temp[1:0], temp[2]};
end

assign anode = temp;

endmodule
