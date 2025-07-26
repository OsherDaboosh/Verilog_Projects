`timescale 1ns / 1ps

`define headerSize 1080
`define imageSize 512*512

module tb;
    // Testbench signals
    integer     file, file1, i;
    integer     sentSize;
    integer     receivedData = 0;
    reg         clk;
    reg         resetn;
    reg  [7:0]  imgData;
    reg         imgDataValid;
    wire        imgDataReady;
    wire        outDataValid;
    wire [7:0]  outData;
    reg  [7:0]  threshold;
    
    // Clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;  // 100 MHz clock
    end
    
    // Stimulus
    initial begin
        resetn = 0;
        sentSize = 0;
        imgDataValid = 0;
        threshold = 8'd128; // Set threshold value
        #100;
        resetn = 1;
        #100;
        
        file = $fopen("lena_gray.bmp","rb");
        if (file == 0) begin
            $display("Error: Could not open input file");
            $finish;
        end
        
        file1 = $fopen("binary_lena.bmp","wb");
        if (file1 == 0) begin
            $display("Error: Could not open output file");
            $finish;
        end
        
        // Copy header
        for(i = 0; i < `headerSize; i = i + 1) begin
            $fscanf(file,"%c",imgData);
            $fwrite(file1,"%c",imgData);
        end
        
        // Process image data with proper handshaking
        for(i = 0; i < 4*512; i = i + 1) begin
            @(posedge clk);
            while (!imgDataReady) @(posedge clk); // Wait for ready
            $fscanf(file,"%c",imgData);
            imgDataValid <= 1'b1;
        end
        sentSize = 4*512;
        
        @(posedge clk);
        imgDataValid <= 1'b0;
        
        while(sentSize < `imageSize) begin
            for(i = 0; i < 512; i = i + 1) begin
                @(posedge clk);
                while (!imgDataReady) @(posedge clk); // Wait for ready
                $fscanf(file,"%c",imgData);
                imgDataValid <= 1'b1;    
            end
            @(posedge clk);
            imgDataValid <= 1'b0;
            sentSize = sentSize + 512;
        end
        
        @(posedge clk);
        imgDataValid <= 1'b0;
        
        // Send padding zeros
        for(i = 0; i < 512; i = i + 1) begin
            @(posedge clk);
            while (!imgDataReady) @(posedge clk);
            imgData <= 0;
            imgDataValid <= 1'b1;
        end
        
        @(posedge clk);
        imgDataValid <= 1'b0;
        
        for(i = 0; i < 512; i = i + 1) begin
            @(posedge clk);
            while (!imgDataReady) @(posedge clk);
            imgData <= 0;
            imgDataValid <= 1'b1; 
        end
        
        @(posedge clk);
        imgDataValid <= 1'b0;
        $fclose(file);
    end
    
    // Output data handling
    always @(posedge clk) begin
        if(outDataValid) begin
            $fwrite(file1,"%c",outData);
            receivedData = receivedData + 1;
        end 
        if(receivedData == `imageSize) begin
            $fclose(file1);
            $display("Processing complete. Output written to binary_lena.bmp");
            $finish;
        end
    end
     
    // Instantiate the Unit Under Test (UUT) - Fixed module name
    axis_gray2binary uut (
        .s_axi_aclk(clk),
        .s_axi_aresetn(resetn),
        .s_axis_tdata(imgData),
        .s_axis_tvalid(imgDataValid),
        .s_axis_tready(imgDataReady),
        .m_axis_tready(1'b1),
        .m_axis_tvalid(outDataValid),
        .m_axis_tdata(outData),
        .threshold(threshold)
    );
endmodule
