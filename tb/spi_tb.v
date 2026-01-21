// spi testbench 
`timescale 1ns/1ps

module SPI_tb;

// Inputs
reg clk;
reg rst;
reg enable;
reg [31:0] data_out;
reg [7:0] commands;
reg [23:0] Address;

// Outputs
wire SCLK;
wire MOSI;
wire MISO;

// Instantiate the Unit Under Test (UUT)
spi uut (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .data_out(data_out),
    .commands(commands),
    .address(Address),
    .SCLK(SCLK),
    .MOSI(MOSI),
    .MISO(MISO)
);

// Clock generation
always #1 clk = ~clk;

// Initialization
initial begin
    clk = 1'b1;
    enable = 1'b0;
    rst = 1'b1;
end

initial begin
    commands = 8'b0;
    Address = 24'b0;
    data_out = 32'b0;

    #20 rst = 1'b0;
    enable = 1'b1;
    commands = 8'b1101001;
    Address = 24'b001010101010101010101100;
    data_out = 32'b10010110101010101110100101011001;

    #1000;
    Address = 24'b001010101010101010101100;
    data_out = 32'hAAAAAAAA;
    enable = 1'b1;

    #30000;
    $finish;
end

endmodule
