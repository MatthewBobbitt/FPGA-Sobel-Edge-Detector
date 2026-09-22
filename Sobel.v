module Sobel (
input wire clk,
input wire rst,

input wire window_valid,

input wire [7:0] P1,
input wire [7:0] P2,
input wire [7:0] P3,
input wire [7:0] P4,
input wire [7:0] P5,
input wire [7:0] P6,
input wire [7:0] P7,
input wire [7:0] P8,
input wire [7:0] P9,

output reg [7:0] Edge,
output reg edge_valid
);

reg signed [10:0] Gx; //These will be signed regs because they can be negative. 
reg signed [10:0] Gy; //They are [10:0] because the highest possible value is 1020; 2^10 = 1024
reg [10:0] absGx;
reg [10:0] absGy;
reg [10:0] magnitude;
reg gxgy_valid;
reg abs_valid;
reg magnitude_valid;

wire signed [10:0] sP1; assign sP1 = {3'b000, P1};
wire signed [10:0] sP2; assign sP2 = {3'b000, P2};
wire signed [10:0] sP3; assign sP3 = {3'b000, P3};
wire signed [10:0] sP4; assign sP4 = {3'b000, P4};
wire signed [10:0] sP5; assign sP5 = {3'b000, P5};
wire signed [10:0] sP6; assign sP6 = {3'b000, P6};
wire signed [10:0] sP7; assign sP7 = {3'b000, P7};
wire signed [10:0] sP8; assign sP8 = {3'b000, P8};
wire signed [10:0] sP9; assign sP9 = {3'b000, P9};




always @(posedge clk) begin
if (rst) begin
Gx <= 0;
Gy <= 0;

absGx <= 0;
absGy <= 0;
magnitude <= 0;

gxgy_valid <= 0;
abs_valid <= 0;
magnitude_valid <= 0;

Edge <= 0;
edge_valid <= 0;
end else begin
if (window_valid) begin
Gx <= (sP3-sP1)+2*(sP6-sP4)+(sP9-sP7);
Gy <= (sP1+(2*sP2)+sP3) - (sP7+(2*sP8)+sP9);
gxgy_valid <= 1;
end else begin
gxgy_valid <= 0;
end
//----------------------------------------------
if (gxgy_valid) begin
if (Gx[10] == 1)
absGx <= -Gx;
else
absGx <= Gx;

if (Gy[10] == 1)
absGy <= -Gy;
else
absGy <= Gy;

abs_valid <= 1;
end else begin
abs_valid <= 0;
end

//---------------------------------------------
if (abs_valid) begin
magnitude <= absGx + absGy;
magnitude_valid <= 1;
end else begin
magnitude_valid <= 0;
end
//----------------------------------------------------
if (magnitude_valid) begin
if (magnitude > 255) begin
Edge <= 255;
edge_valid <= 1;
end else if (magnitude <= 255) begin
Edge <= magnitude[7:0];
edge_valid <= 1;
end
end else begin
edge_valid <= 0;

end

end
end
endmodule
