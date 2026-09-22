module ImageProcessor #(parameter WIDTH = 5, parameter HEIGHT = 4)(
input wire clk,
input wire rst,
input wire valid,

input wire [7:0] R,
input wire [7:0] G,
input wire [7:0] B,

output wire [7:0] Edge,
output wire edge_valid
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

endmodule

