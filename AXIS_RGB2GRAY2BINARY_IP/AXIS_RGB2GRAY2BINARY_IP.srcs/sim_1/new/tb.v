`timescale 1ns / 1ps

`define headerSize 1080
`define imageSize 512*512

module tb();

    // Testbench signals
    integer     file, file1;
    integer     i;
    integer     sentSize; 
    integer     receivedData = 0;

    reg         clk;
    reg         resetn;
    reg  [31:0] imgData;
    reg         imgDataValid;
    reg  [7:0]  threshold;
    
    wire        outDataValid;
    wire [31:0] outData;
    
    // Clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;  // 100 MHz clock
    end
    
    // Stimulus
    initial begin
        resetn       = 0;
        sentSize     = 0;
        imgDataValid = 0;
        threshold    = 8'd128; 
        #100;
        resetn = 1;
        #100;
        file = $fopen("lena_gray.bmp", "rb");
        file1 = $fopen("lena_binary.bmp", "wb");
        for (i = 0; i < `headerSize; i = i + 1) begin
            $fscanf(file, "%c", imgData);
            $fwrite(file1, "%c", imgData);
        end
        for (i = 0; i < 4*512; i = i + 1) begin
            @(posedge clk);
            $fscanf(file,"%c",imgData);
            imgDataValid <= 1'b1;
        end
        sentSize = 4*512;
        @(posedge clk);
        imgDataValid <= 1'b0;
        while(sentSize < `imageSize)
        begin
            for(i = 0; i < 512; i = i + 1)
            begin
                @(posedge clk);
                $fscanf(file,"%c",imgData);
                imgDataValid <= 1'b1;    
            end
            @(posedge clk);
            imgDataValid <= 1'b0;
            sentSize = sentSize + 512;
        end
        @(posedge clk);
        imgDataValid <= 1'b0;
        for(i = 0; i < 512; i = i + 1)
        begin
            @(posedge clk);
            imgData <= 0;
            imgDataValid <= 1'b1;
        end
        @(posedge clk);
        imgDataValid <= 1'b0;
        for(i = 0; i < 512; i = i + 1)
        begin
            @(posedge clk);
            imgData <= 0;
            imgDataValid <= 1'b1; 
        end
        @(posedge clk);
        imgDataValid <= 1'b0;
        $fclose(file);
     end

     always @(posedge clk)
     begin
         if(outDataValid)
         begin
             $fwrite(file1,"%c",outData);
             receivedData = receivedData + 1;
         end 
         if(receivedData == `imageSize)
         begin
            $fclose(file1);
            $stop;
         end
     end
     
    axis_rgb2gray2binary uut (
        .s_axi_aclk(clk),
        .s_axi_aresetn(resetn),
        .s_axis_tdata(imgData),
        .s_axis_tvalid(imgDataValid),
        .m_axis_tready(1'b1),
        .s_axis_tready(),
        .m_axis_tvalid(outDataValid),
        .m_axis_tdata(outData),
        .threshold(threshold)
    );

endmodule
