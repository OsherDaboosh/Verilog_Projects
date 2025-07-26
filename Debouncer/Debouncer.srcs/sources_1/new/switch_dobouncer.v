`timescale 1ns / 1ps

module switch_debouncer #(parameter DELAY_COUNT = 500000) (  // Default for ~10ms at 50MHz
    input wire clk,
    input wire reset,
    input wire sw_in,
    output reg sw_out
);
    
    // Calculate counter width based on DELAY_COUNT
    localparam COUNTER_WIDTH = $clog2(DELAY_COUNT);
    
    // FSM States
    localparam  IDLE     = 1'b0;
    localparam  COUNTING = 1'b1;

    reg state = IDLE;

    reg [COUNTER_WIDTH-1:0] counter;

    reg sw_sync;  // Synchronized input
    
    // Synchronize input to avoid metastability
    always @(posedge clk or posedge reset) begin
        if (reset)
            sw_sync <= 1'b0;
        else
            sw_sync <= sw_in;
    end
    
    // Main debouncer FSM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state   <= IDLE;
            counter <= {COUNTER_WIDTH{1'b0}};
            sw_out  <= 1'b0;
        end
        else begin
            case (state)
                // IDLE State: Detect change in synchronized input
                IDLE: begin
                    if (sw_in != sw_out) begin
                        state   <= COUNTING;
                        counter <= {COUNTER_WIDTH{1'b0}};
                    end
                end
                // COUNTING State: Wait until stable
                COUNTING: begin
                    if (sw_sync != sw_out) begin
                        // Input is still different, continue counting
                        if (counter == DELAY_COUNT-1) begin
                            // Debounce period complete, update output
                            sw_out <= sw_sync;
                            state  <= IDLE;
                        end
                        else begin
                            counter <= counter + 1'b1;
                        end
                    end
                    else begin
                        // Input changed back, return to idle
                        state <= IDLE;
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
