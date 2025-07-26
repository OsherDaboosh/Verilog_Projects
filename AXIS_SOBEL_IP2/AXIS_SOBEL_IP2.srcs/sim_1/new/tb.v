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
wire        outDataValid;
wire [7:0]  outData;
wire        intr;

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
    #100;
    resetn = 1;
    #100;
    file = $fopen("lena_gray.bmp","rb");
    file1 = $fopen("lena_sobel.bmp","wb");
    for(i = 0; i < `headerSize; i = i + 1) begin
        $fscanf(file,"%c",imgData);
        $fwrite(file1,"%c",imgData);
    end
    
    for(i = 0; i < 4*512; i = i + 1) begin
        @(posedge clk);
        $fscanf(file,"%c",imgData);
        imgDataValid <= 1'b1;
    end

    sentSize = 4*512;
    @(posedge clk);
    imgDataValid <= 1'b0;
    while(sentSize < `imageSize)
    begin
        @(posedge intr);
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
    @(posedge intr);
    for(i = 0; i < 512; i = i + 1)
    begin
        @(posedge clk);
        imgData <= 0;
        imgDataValid <= 1'b1;
    end
    @(posedge clk);
    imgDataValid <= 1'b0;
    @(posedge intr);
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
 
// Instantiate the Unit Under Test (UUT)
axis_sobel uut (
    .s_axi_aclk(clk),
    .s_axi_aresetn(resetn),
    .s_axis_tdata(imgData),
    .s_axis_tvalid(imgDataValid),
    .m_axis_tready(1'b1),
    .s_axis_tready(),
    .m_axis_tvalid(outDataValid),
    .m_axis_tdata(outData),
    .o_intr(intr)
);

endmodule
