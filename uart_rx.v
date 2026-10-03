`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 11:05:10 PM
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx(
    input wire clk,
    input wire rst,
    input wire rx,

    output reg [7:0] data_out,
    output reg data_valid
    );

    // State definitions
    parameter IDLE = 2'b00;
    parameter START = 2'b01;
    parameter DATA = 2'b10;
    parameter STOP = 2'b11;

    reg [1:0] state;

    // 14 bits is the maximum count of over 16,000
    // Basys 3 clock = 100 MHz
    // 100,000,000 / 9600 baud = approximately 10,417 clocks per UART bit
    reg [13:0] clock_count;

    // Counts the 8 UART data bits
    reg [2:0] bit_count;


    always @(posedge clk) begin

        if (rst) begin
            state <= IDLE;
            clock_count <= 0;
            bit_count <= 0;
            data_out <= 0;
            data_valid  <= 0;
        end

        else begin

            case (state)

//------------------------------------------------------------------------------

                IDLE: begin
                    // Wait for a possible start bit (rx = 0)
                    data_valid <= 0;
                    clock_count <= 0;

                    if (rx == 0) begin
                        state <= START;
                        clock_count <= 0;
                    end
                end

//------------------------------------------------------------------------------

                START: begin
                    // Move toward the middle of the start bit
                    clock_count <= clock_count + 1;

                    if (clock_count == 433) begin

                        // Verify that RX is still low
                        if (rx == 0) begin
                            state <= DATA;
                            clock_count <= 0;
                        end

                        // False start bit
                        else begin
                            state <= IDLE;
                            clock_count <= 0;
                        end

                    end

                    else begin
                        state <= START;
                        data_valid <= 0;
                    end
                end

//------------------------------------------------------------------------------

                DATA: begin
                    // Wait one complete UART bit period
                    clock_count <= clock_count + 1;

                    if (clock_count == 867) begin

                        // UART sends LSB first
                        data_out[bit_count] <= rx;

                        clock_count <= 0;
                        bit_count <= bit_count + 1;

                        // All 8 bits have been received
                        if (bit_count == 7) begin
                            bit_count <= 0;
                            clock_count <= 0;
                            state <= STOP;
                        end
                    end
                end

//------------------------------------------------------------------------------

                STOP: begin
                    clock_count <= clock_count + 1;

                    if (clock_count == 867) begin
                        clock_count <= 0;

                        // Invalid stop bit
                        if (rx == 0) begin
                            data_valid <= 0;
                            state <= IDLE;
                        end

                        // Valid stop bit
                        else begin
                            data_valid <= 1;
                            state <= IDLE;
                        end
                    end
                end

//------------------------------------------------------------------------------

                default: begin
                    state <= IDLE;
                    clock_count <= 0;
                    bit_count <= 0;
                    data_valid <= 0;
                end

            endcase
        end
    end

endmodule
