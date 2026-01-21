//spi design code
`timescale 1ns/1ps

module spi(
    input wire clk,           // System clock
    input wire rst,           // Reset signal
    input wire enable,        // Enable the master to start operation
    input wire [31:0] data_out, // Data to be sent
    input wire [7:0] commands,  // Commands to be sent
    input wire [23:0] address,  // Address to be sent
    output reg CS,            // Chip Select (active low)
    output reg SCLK,          // Serial Clock
    output reg MOSI,          // Master Out Slave In
    input wire MISO           // Data received from the slave (MISO)
);

parameter IDLE = 2'b00;
parameter START = 2'b01;
parameter TRANSFER = 2'b10;
parameter STOP = 2'b11;

reg [1:0] current_state, next_state;
reg [31:0] shift_reg = 0;
reg [5:0] shift_count = 0;
reg [5:0] bit_index = 0;
reg clk_div = 1'b0;

// Clock divider for SCLK
always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= IDLE;
        SCLK <= 1'b1;
    end else begin
        clk_div <= ~clk_div;
        SCLK <= clk_div;
        current_state <= next_state;
    end
end

// FSM logic
always @(posedge clk) begin
    case (current_state)
        IDLE: begin
            if (enable) begin
                shift_reg <= {address, commands}; // Prepare the shift register
                next_state <= START;
                shift_count <= 0;
                bit_index <= 0;
            end else begin
                next_state <= IDLE;
            end
        end

        START: begin
            next_state <= TRANSFER;
        end

        TRANSFER: begin
            if (SCLK) begin
                shift_reg = data_out;
                MOSI <= shift_reg[31 - bit_index]; // Send MSB first
                bit_index <= bit_index + 1;
                if (bit_index == 32) begin
                    MOSI <= 32'b0;
                    next_state <= STOP;
                end
            end else begin
                next_state <= TRANSFER;
            end
        end

        STOP: begin
            next_state <= IDLE;
        end

        default: begin
            next_state <= IDLE;
        end
    endcase
end

endmodule
