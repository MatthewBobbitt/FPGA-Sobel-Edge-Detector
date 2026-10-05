`timescale 1ns / 1ps

module ImageProcessor #(
    parameter MAX_WIDTH = 1920
)(
    input wire clk,
    input wire rst,

    input wire rx,
    output wire tx,

    input wire sw,
    output wire [15:0] led
);


wire [7:0] gray_pixel;
wire gray_valid;


wire [7:0] P1;
wire [7:0] P2;
wire [7:0] P3;
wire [7:0] P4;
wire [7:0] P5;
wire [7:0] P6;
wire [7:0] P7;
wire [7:0] P8;
wire [7:0] P9;

wire window_valid;


wire [7:0] rx_data;
wire rx_valid;



reg [15:0] image_width;
reg [15:0] image_height;



reg [7:0] R;
reg [7:0] G;
reg [7:0] B;

reg valid;

wire [7:0] Edge;
wire edge_valid;

wire tx_busy;

reg [7:0] tx_buffer;
reg tx_buffer_valid;

reg [7:0] tx_fifo [0:255];
reg [7:0] fifo_write_ptr;
reg [7:0] fifo_read_ptr;
reg [8:0] fifo_count;

wire fifo_empty;
wire fifo_full;

wire do_read;
wire do_write;

reg [31:0] edge_count;
reg [31:0] dropped_count;

assign fifo_empty = (fifo_count == 0);
assign fifo_full  = (fifo_count == 256);

assign do_read = !tx_busy && !tx_buffer_valid && !fifo_empty;
assign do_write = edge_valid && (!fifo_full || do_read);

assign led = sw ? edge_count[15:0] : dropped_count[15:0];


uart_rx RX(
    .clk(clk),
    .rst(rst),
    .rx(rx),

    .data_out(rx_data),
    .data_valid(rx_valid)
);


Gray gray_inst(
    .clk(clk),
    .rst(rst),

    .valid(valid),

    .R(R),
    .G(G),
    .B(B),

    .Gray(gray_pixel),
    .gray_valid(gray_valid)
);


Window #(
    .MAX_WIDTH(MAX_WIDTH)
) window_inst (
    .clk(clk),
    .rst(rst),

    .Gray(gray_pixel),
    .gray_valid(gray_valid),

    .image_width(image_width),
    .image_height(image_height),

    .P1(P1),
    .P2(P2),
    .P3(P3),
    .P4(P4),
    .P5(P5),
    .P6(P6),
    .P7(P7),
    .P8(P8),
    .P9(P9),

    .window_valid(window_valid)
);


Sobel sobel_inst(
    .clk(clk),
    .rst(rst),

    .window_valid(window_valid),

    .P1(P1),
    .P2(P2),
    .P3(P3),
    .P4(P4),
    .P5(P5),
    .P6(P6),
    .P7(P7),
    .P8(P8),
    .P9(P9),

    .Edge(Edge),
    .edge_valid(edge_valid)
);


uart_tx TX(
    .clk(clk),
    .rst(rst),

    .data_in(tx_buffer),
    .data_valid(tx_buffer_valid),

    .tx(tx),
    .busy(tx_busy)
);


parameter WIDTH_HIGH  = 3'd0;
parameter WIDTH_LOW   = 3'd1;
parameter HEIGHT_HIGH = 3'd2;
parameter HEIGHT_LOW  = 3'd3;

parameter RED         = 3'd4;
parameter GREEN       = 3'd5;
parameter BLUE        = 3'd6;
parameter PIXEL_VALID = 3'd7;

reg [2:0] input_state;


always @(posedge clk) begin

    if (rst)
        edge_count <= 0;

    else if (edge_valid)
        edge_count <= edge_count + 1;

end


always @(posedge clk) begin

    if (rst) begin

        dropped_count <= 0;

    end

    else if (edge_valid && !do_write) begin

        dropped_count <= dropped_count + 1;

    end

end


//--------------
always @(posedge clk) begin

    if (rst) begin

        image_width <= 0;
        image_height <= 0;

        R <= 0;
        G <= 0;
        B <= 0;

        valid <= 0;

        input_state <= WIDTH_HIGH;

    end

    else begin

        // valid should normally be LOW
        valid <= 0;

//------------------------------------------------------------------------------------------
        case (input_state)

            WIDTH_HIGH: begin

                if (rx_valid) begin

                    image_width[15:8] <= rx_data;

                    input_state <= WIDTH_LOW;

                end

            end


            WIDTH_LOW: begin

                if (rx_valid) begin

                    image_width[7:0] <= rx_data;

                    input_state <= HEIGHT_HIGH;

                end

            end


            HEIGHT_HIGH: begin

                if (rx_valid) begin

                    image_height[15:8] <= rx_data;

                    input_state <= HEIGHT_LOW;

                end

            end


            HEIGHT_LOW: begin

                if (rx_valid) begin

                    image_height[7:0] <= rx_data;

                    input_state <= RED;

                end

            end


//---------------------------------------------------------------------------------
            RED: begin

                if (rx_valid) begin

                    R <= rx_data;

                    input_state <= GREEN;

                end

            end


            GREEN: begin

                if (rx_valid) begin

                    G <= rx_data;

                    input_state <= BLUE;

                end

            end


            BLUE: begin

                if (rx_valid) begin

                    B <= rx_data;

                    input_state <= PIXEL_VALID;

                end

            end


//-----------------------------------------------------------------------------------
            PIXEL_VALID: begin

                valid <= 1;

                input_state <= RED;

            end


            default: begin

                input_state <= WIDTH_HIGH;

                valid <= 0;

            end

        endcase

    end

end



// edge_valid means Sobel has produced a new result.
// Store that result in tx_buffer.
// When UART is available, pulse tx_buffer_valid
// for one clock to start transmission.


always @(posedge clk) begin

    if (rst) begin

        tx_buffer <= 0;
        tx_buffer_valid <= 0;

       
        fifo_write_ptr <= 0;
        fifo_read_ptr <= 0;
        fifo_count <= 0;

    end

    else begin

        tx_buffer_valid <= 0;


        
        if (do_write) begin                        // Sobel result enters FIFO

            tx_fifo[fifo_write_ptr] <= Edge;

            fifo_write_ptr <= fifo_write_ptr + 1;

        end


        
        if (do_read) begin                        // UART takes oldest byte from FIFO when available

            tx_buffer <= tx_fifo[fifo_read_ptr];

            tx_buffer_valid <= 1;

            fifo_read_ptr <= fifo_read_ptr + 1;

        end


        
        case ({                                 //update FIFO count for write-only, read-only, or simultaneous
            do_write,
            do_read
        })

            2'b10:
                fifo_count <= fifo_count + 1;

            2'b01:
                fifo_count <= fifo_count - 1;

            2'b11:
                fifo_count <= fifo_count;

            default:
                fifo_count <= fifo_count;

        endcase

    end

end


endmodule
