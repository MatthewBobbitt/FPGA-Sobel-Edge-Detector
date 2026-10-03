`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 11:35:18 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
input wire clk,
input wire rst,

input wire [7:0] data_in,
input wire data_valid,

output reg tx
    );
    
    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;
    
    
    reg [1:0] state;

    reg [13:0] clock_count;
    reg [2:0] bit_count;
    
    reg [7:0] tx_data; // this will save the byte so that when each bit transmits, the data doesn't change
    
    
    always @(posedge clk) begin
        if (rst) begin
            state <= 0;
            clock_count <= 0;
            bit_count <= 0;
            tx_data <= 0;
            tx <= 1;                //UART is idle high, so reset will force tx = 1
        end
        else begin
            
            case (state)
                IDLE: begin
                    tx <= 1;
                    if (data_valid) begin
                        state <= START;
                        tx_data <= data_in;
                        clock_count <= 0;
                    end
                end
                
                START: begin
                    tx <= 0;

                    clock_count <= clock_count + 1;

                    if (clock_count == 867) begin
                        clock_count <= 0;
                        state <= DATA;
                    end
                end
                
                DATA: begin
                    tx <= tx_data[bit_count];
                    
                    clock_count <= clock_count + 1;
                    if (clock_count == 867) begin
                        clock_count <= 0;

                        if (bit_count == 7) begin
                            bit_count <= 0;
                            clock_count <= 0;
                            state <= STOP;
                        end else begin
                            bit_count <= bit_count + 1;
                        end
                    end
                end
                
                STOP: begin
                    tx <= 1;
                    clock_count <= clock_count + 1;
                
                    if (clock_count == 867) begin
                        clock_count <= 0;
                        state <= IDLE;
                    end
                end
                
                default: begin
                    state <= IDLE;
                    tx <= 1;
                    clock_count <= 0;
                    bit_count <= 0;
                end
            endcase
        end
    end
    
endmodule
