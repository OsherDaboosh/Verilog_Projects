`timescale 1ns / 1ps

module line_detector #(
    parameter IMG_WIDTH = 640,
    parameter IMG_HEIGHT = 480,
    parameter ADDR_WIDTH = 19,      // log2(640*480) rounded up
    parameter LINE_THRESHOLD = 10,  // Minimum pixels for line detection
    parameter PIXEL_THRESHOLD = 3   // Minimum consecutive pixels
)(
    input wire clk,
    input wire rst_n,
    input wire enable,
    
    // Image memory interface
    output reg [ADDR_WIDTH-1:0] img_addr,
    input wire img_data,  // Binary pixel data (1 bit)
    output reg img_rd_en,
    
    // Line detection results
    output reg [15:0] horizontal_lines_count,
    output reg [15:0] vertical_lines_count,
    output reg [9:0] line_start_x,
    output reg [9:0] line_start_y,
    output reg [9:0] line_end_x,
    output reg [9:0] line_end_y,
    output reg line_detected,
    output reg processing_done
);

// State machine states
localparam IDLE = 3'b000;
localparam INIT = 3'b001;
localparam SCAN_HORIZONTAL = 3'b010;
localparam SCAN_VERTICAL = 3'b011;
localparam DONE = 3'b100;

reg [2:0] state, next_state;
reg [9:0] x_coord, y_coord;
reg [9:0] line_length;
reg [9:0] current_line_start;
reg [15:0] h_line_count, v_line_count;
reg [1:0] read_delay;

// Registers for line detection
reg [9:0] best_line_start_x, best_line_start_y;
reg [9:0] best_line_end_x, best_line_end_y;
reg [9:0] max_line_length;

// Address calculation
always @(*) begin
    img_addr = y_coord * IMG_WIDTH + x_coord;
end

// State machine
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        x_coord <= 0;
        y_coord <= 0;
        line_length <= 0;
        current_line_start <= 0;
        h_line_count <= 0;
        v_line_count <= 0;
        read_delay <= 0;
        max_line_length <= 0;
        best_line_start_x <= 0;
        best_line_start_y <= 0;
        best_line_end_x <= 0;
        best_line_end_y <= 0;
    end else begin
        state <= next_state;
        
        case (state)
            IDLE: begin
                if (enable) begin
                    x_coord <= 0;
                    y_coord <= 0;
                    line_length <= 0;
                    current_line_start <= 0;
                    h_line_count <= 0;
                    v_line_count <= 0;
                    read_delay <= 0;
                    max_line_length <= 0;
                end
            end
            
            INIT: begin
                img_rd_en <= 1'b1;
                read_delay <= 0;
            end
            
            SCAN_HORIZONTAL: begin
                if (read_delay < 2) begin
                    read_delay <= read_delay + 1;
                end else begin
                    read_delay <= 0;
                    
                    if (img_data) begin
                        if (line_length == 0) begin
                            current_line_start <= x_coord;
                        end
                        line_length <= line_length + 1;
                    end else begin
                        if (line_length >= LINE_THRESHOLD) begin
                            h_line_count <= h_line_count + 1;
                            // Check if this is the longest line found
                            if (line_length > max_line_length) begin
                                max_line_length <= line_length;
                                best_line_start_x <= current_line_start;
                                best_line_start_y <= y_coord;
                                best_line_end_x <= x_coord - 1;
                                best_line_end_y <= y_coord;
                            end
                        end
                        line_length <= 0;
                    end
                    
                    // Move to next pixel
                    if (x_coord < IMG_WIDTH - 1) begin
                        x_coord <= x_coord + 1;
                    end else begin
                        x_coord <= 0;
                        if (y_coord < IMG_HEIGHT - 1) begin
                            y_coord <= y_coord + 1;
                        end else begin
                            // Start vertical scan
                            x_coord <= 0;
                            y_coord <= 0;
                            line_length <= 0;
                        end
                    end
                end
            end
            
            SCAN_VERTICAL: begin
                if (read_delay < 2) begin
                    read_delay <= read_delay + 1;
                end else begin
                    read_delay <= 0;
                    
                    if (img_data) begin
                        if (line_length == 0) begin
                            current_line_start <= y_coord;
                        end
                        line_length <= line_length + 1;
                    end else begin
                        if (line_length >= LINE_THRESHOLD) begin
                            v_line_count <= v_line_count + 1;
                            // Check if this is the longest line found
                            if (line_length > max_line_length) begin
                                max_line_length <= line_length;
                                best_line_start_x <= x_coord;
                                best_line_start_y <= current_line_start;
                                best_line_end_x <= x_coord;
                                best_line_end_y <= y_coord - 1;
                            end
                        end
                        line_length <= 0;
                    end
                    
                    // Move to next pixel
                    if (y_coord < IMG_HEIGHT - 1) begin
                        y_coord <= y_coord + 1;
                    end else begin
                        y_coord <= 0;
                        if (x_coord < IMG_WIDTH - 1) begin
                            x_coord <= x_coord + 1;
                        end else begin
                            // Scanning complete
                            x_coord <= 0;
                            y_coord <= 0;
                        end
                    end
                end
            end
            
            DONE: begin
                img_rd_en <= 1'b0;
            end
        endcase
    end
end

// Next state logic
always @(*) begin
    next_state = state;
    
    case (state)
        IDLE: begin
            if (enable) begin
                next_state = INIT;
            end
        end
        
        INIT: begin
            next_state = SCAN_HORIZONTAL;
        end
        
        SCAN_HORIZONTAL: begin
            if (read_delay >= 2) begin
                if (x_coord >= IMG_WIDTH - 1 && y_coord >= IMG_HEIGHT - 1) begin
                    next_state = SCAN_VERTICAL;
                end
            end
        end
        
        SCAN_VERTICAL: begin
            if (read_delay >= 2) begin
                if (x_coord >= IMG_WIDTH - 1 && y_coord >= IMG_HEIGHT - 1) begin
                    next_state = DONE;
                end
            end
        end
        
        DONE: begin
            if (!enable) begin
                next_state = IDLE;
            end
        end
    endcase
end

// Output assignments
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        horizontal_lines_count <= 0;
        vertical_lines_count <= 0;
        line_start_x <= 0;
        line_start_y <= 0;
        line_end_x <= 0;
        line_end_y <= 0;
        line_detected <= 0;
        processing_done <= 0;
        img_rd_en <= 0;
    end else begin
        case (state)
            DONE: begin
                horizontal_lines_count <= h_line_count;
                vertical_lines_count <= v_line_count;
                line_start_x <= best_line_start_x;
                line_start_y <= best_line_start_y;
                line_end_x <= best_line_end_x;
                line_end_y <= best_line_end_y;
                line_detected <= (h_line_count > 0 || v_line_count > 0);
                processing_done <= 1'b1;
            end
            
            IDLE: begin
                if (enable) begin
                    processing_done <= 1'b0;
                    line_detected <= 1'b0;
                end
            end
        endcase
    end
end
endmodule
