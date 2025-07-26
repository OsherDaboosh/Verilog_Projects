`timescale 1ns / 1ps

module debouncer(
    input      clk,
    input      reset,
    input      sw_in,
    output reg sw_out
);

localparam [19:0] DELAY_COUNTER = 20'h7A120;  // 500,000

parameter IDLE = 2'b00, COUNTING = 2'b01, STABLE = 2'B10;

reg [1:0]  state = IDLE;
reg [19:0] count = 0;
reg        sw_reg = 1'b0;  // Stores stable switch state

always @(posedge clk) begin
    if (reset) begin
        state  <= IDLE;
        count  <= 20'd0;
        sw_reg <= 1'b0;
        sw_out <= 1'b0;
    end
    else begin
        case (state)
            // IDLE State: Wait for switch change
            IDLE: begin
                if (sw_in != sw_reg) begin
                    state <= COUNTING;
                    count <= 20'd0;
                end
            end
            // COUNTING State: Wait until stable
            COUNTING: begin
                if (count == DELAY_COUNTER) begin
                    state  <= STABLE;
                    sw_reg <= sw_in;
                    sw_out <= sw_in;
                end
                else begin
                    count <= count + 1;
                end
            end
            // Stable State: Switch has been debounced
            STABLE: begin
                if (sw_in != sw_reg) begin
                    state <= COUNTING;
                    count <= 20'd0;
                end
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end
end
endmodule
