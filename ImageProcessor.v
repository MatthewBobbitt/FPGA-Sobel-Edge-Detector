module ImageProcessor #(parameter WIDTH = 64, parameter HEIGHT = 64)(
input wire clk,
input wire rst,

input wire rx,

output wire tx
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

reg [7:0] R;
reg [7:0] G;
reg [7:0] B;
reg valid;


wire [7:0] Edge;
wire edge_valid;

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

Window #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) window_inst (
.clk(clk),
.rst(rst),
.Gray(gray_pixel),
.gray_valid(gray_valid),
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

uart_rx RX(
.clk(clk),
.rst(rst),
.rx(rx),
.data_out(rx_data),
.data_valid(rx_valid)
);

uart_tx TX(
.clk(clk),
.rst(rst),
.data_in(Edge),
.data_valid(edge_valid),
.tx(tx)
);
reg [1:0] byte_state;

always @(posedge clk) begin
    if (rst) begin
        R <= 0;
        G <= 0;
        B <= 0;
        byte_state <= 0;
        valid <= 0;
    end 
    else begin

        valid <= 0;

        case (byte_state)

            0: begin
                if (rx_valid) begin
                    R <= rx_data;
                    byte_state <= 1;
                end
            end

            1: begin
                if (rx_valid) begin
                    G <= rx_data;
                    byte_state <= 2;
                end
            end

            2: begin
                if (rx_valid) begin
                    B <= rx_data;
                    byte_state <= 3;
                end
            end

            3: begin
                valid <= 1;
                byte_state <= 0;
            end

        endcase
    end
end
endmodule

