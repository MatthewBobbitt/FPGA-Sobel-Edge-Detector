`timescale 1ns / 1ps

module uart_tx(
    input wire clk,
    input wire rst,

    input wire [7:0] data_in,
    input wire data_valid,

    output reg tx,
    output wire busy
);

parameter IDLE = 2'b00;
parameter START = 2'b01;
parameter DATA = 2'b10;
parameter STOP = 2'b11;


reg [1:0] state;

reg [13:0] clock_count;

reg [2:0] bit_count;

reg [7:0] tx_data;


// BUSY SIGNAL
// busy = 0 UART can accept a new byte
// busy = 1 UART is currently transmitting

assign busy = (state != IDLE);

always @(posedge clk) begin

    if (rst) begin

        state <= IDLE;

        clock_count <= 0;

        bit_count <= 0;

        tx_data <= 0;

        // UART idles HIGH
        tx <= 1;

    end

    else begin

        case (state)

            IDLE: begin

                tx <= 1;

                clock_count <= 0;

                bit_count <= 0;

                
                if (data_valid) begin // Start transmitting when new data becomes available

                    tx_data <= data_in;

                    state <= START;

                end

            end


            START: begin

                tx <= 0;

                if (clock_count == 49) begin //NEEDS TO BE # - 1 

                    clock_count <= 0;

                    state <= DATA;

                end

                else begin

                    clock_count <= clock_count + 1;

                end

            end


            DATA: begin

                tx <= tx_data[bit_count];

                if (clock_count == 49) begin //NEEDS TO BE # - 1 

                    clock_count <= 0;

                    if (bit_count == 7) begin

                        bit_count <= 0;

                        state <= STOP;

                    end else begin

                        bit_count <= bit_count + 1;

                    end

                end else begin

                    clock_count <= clock_count + 1;

                end

            end


            STOP: begin

                tx <= 1;

                if (clock_count == 49) begin //NEEDS TO BE # - 1 

                    clock_count <= 0;

                    state <= IDLE;

                end

                else begin

                    clock_count <= clock_count + 1;

                end

            end

            default: begin

                state <= IDLE;

                clock_count <= 0;

                bit_count <= 0;

                tx <= 1;

            end

        endcase

    end

end


endmodule
