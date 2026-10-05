`timescale 1ns / 1ps

module uart_rx(
    input wire clk,
    input wire rst,
    input wire rx,

    output reg [7:0] data_out,
    output reg data_valid
);

parameter IDLE = 2'b00;
parameter START = 2'b01;
parameter DATA = 2'b10;
parameter STOP = 2'b11;

reg [1:0] state;
reg [13:0] clock_count;
reg [2:0] bit_count;

reg rx_meta;
reg rx_sync;


always @(posedge clk) begin

    if (rst) begin

        rx_meta <= 1;
        rx_sync <= 1;

    end

    else begin

        rx_meta <= rx;
        rx_sync <= rx_meta;

    end

end


always @(posedge clk) begin

    if (rst) begin

        state <= IDLE;
        clock_count <= 0;
        bit_count <= 0;
        data_out <= 0;
        data_valid <= 0;

    end

    else begin

        case (state)

            IDLE: begin

                data_valid <= 0;
                clock_count <= 0;

                if (rx_sync == 0) begin

                    state <= START;
                    clock_count <= 0;

                end

            end


            START: begin

                clock_count <= clock_count + 1;

                if (clock_count == 24) begin

                    if (rx_sync == 0) begin

                        state <= DATA;
                        clock_count <= 0;

                    end

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


            DATA: begin

                clock_count <= clock_count + 1;

                if (clock_count == 49) begin

                    data_out[bit_count] <= rx_sync;

                    clock_count <= 0;
                    bit_count <= bit_count + 1;

                    if (bit_count == 7) begin

                        bit_count <= 0;
                        clock_count <= 0;
                        state <= STOP;

                    end

                end

            end


            STOP: begin

                clock_count <= clock_count + 1;

                if (clock_count == 49) begin

                    clock_count <= 0;

                    if (rx_sync == 0) begin

                        data_valid <= 0;
                        state <= IDLE;

                    end

                    else begin

                        data_valid <= 1;
                        state <= IDLE;

                    end

                end

            end


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
