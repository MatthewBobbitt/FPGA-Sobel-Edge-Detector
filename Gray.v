module Gray (
input wire clk,
input wire valid,
input wire rst,

input wire [7:0]R,
input wire [7:0]G,
input wire [7:0]B,

output reg [7:0]Gray,
output reg gray_valid
);

wire [17:0] sum; // 299(255) + 587(255) + 114(255) == 255,000   ;   2^18 = 262143, so 18 bits are needed to hold largest value

assign sum = (299*R)+(587*G)+(114*B);


always @(posedge clk) begin
if (valid) begin
Gray <= sum/1000;
gray_valid <= 1;
end
else begin
gray_valid <= 0;
end
end
endmodule






//The next step is to learn how to process a stream of pixels
