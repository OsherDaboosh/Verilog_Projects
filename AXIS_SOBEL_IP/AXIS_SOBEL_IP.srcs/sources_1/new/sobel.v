`timescale 1ns / 1ps

module sobel (
    input             clk,
    input      [71:0] in_data,    // 9 pixels, 8-bit each
    input             in_tvalid,
    output reg        out_tvalid,
    output reg [7:0]  out_data
);
    
    integer i;
    
    reg  [7:0]  kernel1  [8:0];
    reg  [7:0]  kernel2  [8:0];
    reg  [10:0] mulData1 [8:0];
    reg  [10:0] mulData2 [8:0];
    reg         mulDataValid;
    
    reg  [10:0] sumData1;
    reg  [10:0] sumData2;
    reg  [10:0] sumDataInt1;
    reg  [10:0] sumDataInt2;
    reg         sumDataValid;
    
    wire [21:0] sobelDataInt;
    reg  [20:0] sobelDataInt1;
    reg  [20:0] sobelDataInt2;
    reg         sobelDataValid;
            
    initial
    begin
        kernel1[0] =  1;
        kernel1[1] =  0;
        kernel1[2] = -1;
        kernel1[3] =  2;
        kernel1[4] =  0;
        kernel1[5] = -2;
        kernel1[6] =  1;
        kernel1[7] =  0;
        kernel1[8] = -1;
        
        kernel2[0] =  1;
        kernel2[1] =  2;
        kernel2[2] =  1;
        kernel2[3] =  0;
        kernel2[4] =  0;
        kernel2[5] =  0;
        kernel2[6] = -1;
        kernel2[7] = -2;
        kernel2[8] = -1;
    end

    always @(posedge clk) begin
        for (i = 0; i < 9; i = i + 1) begin
            mulData1[i] <= $signed(kernel1[i])*$signed({1'b0,in_data[i*8+:8]});
            mulData2[i] <= $signed(kernel2[i])*$signed({1'b0,in_data[i*8+:8]});
        end
        mulDataValid <= in_tvalid;
    end
    
    always @(*) begin
        sumDataInt1 = 0;
        sumDataInt2 = 0;
        for (i = 0; i < 9; i = i + 1) begin
            sumDataInt1 = $signed(sumDataInt1) + $signed(mulData1[i]);
            sumDataInt2 = $signed(sumDataInt2) + $signed(mulData2[i]);
        end
    end
    
    always @(posedge clk) begin
        sumData1     <= sumDataInt1;
        sumData2     <= sumDataInt2;
        sumDataValid <= mulDataValid;
    end
    
    always @(posedge clk) begin
        sobelDataInt1  <= $signed(sumData1)*$signed(sumData1);
        sobelDataInt2  <= $signed(sumData2)*$signed(sumData2);
        sobelDataValid <= sumDataValid;
    end
    
    assign sobelDataInt = sobelDataInt1 + sobelDataInt2;
    
    always @(posedge clk) begin
        if (sobelDataInt > 4000)
            out_data <= 8'hff;  // White Pixel
        else
            out_data <= 8'h00;  // Black Pixel
        out_tvalid <= sobelDataValid;
    end
endmodule
