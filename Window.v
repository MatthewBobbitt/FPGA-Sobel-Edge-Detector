module Window #(parameter WIDTH = 5, parameter HEIGHT = 4)(
input wire clk,
input wire rst,

input wire [7:0] Gray, // Gray is input now because it will be brough in from Gray.v

input wire gray_valid, // same here

output reg [7:0] P3,
output reg [7:0] P6,
output reg [7:0] P9,

output reg [7:0] P1,
output reg [7:0] P2,
output reg [7:0] P4,
output reg [7:0] P5,
output reg [7:0] P7,
output reg [7:0] P8,

output reg window_valid
);

reg [7:0] line1 [0:WIDTH-1];
reg [7:0] line2 [0:WIDTH-1];



integer row;

integer column;

always @(posedge clk) begin
if (rst) begin
column <= 0;
row <= 0;
window_valid <= 0;
P1 <= 0;
P2 <= 0;
P3 <= 0;
P4 <= 0;
P5 <= 0;
P6 <= 0;
P7 <= 0;
P8 <= 0;
P9 <= 0;

end
else if (gray_valid) begin

line2[column] <= line1[column];   	// Move previous-row pixel into two-rows-ago buffer
line1[column] <= Gray;            	// Store current pixel in previous-row buffer

P3 <= line2[column];			// two pixels above current pixel
P6 <= line1[column];			// one pixel above current pixel
P9 <= Gray;				// current pixel
					// When Gray goes to the next pixel, all shift left
P1 <= P2;
P2 <= P3;
P4 <= P5;
P5 <= P6;
P7 <= P8;
P8 <= P9;

if (column == WIDTH - 1) begin
column <= 0; 
row <= row + 1;		//makes the row increment by one and column resets to 0 after maxing out
end else begin
column <= column +1;
end
if ((row >= 2) && (column >= 2))  // 3x3 windows are only possible after column and row #2
    window_valid <= 1;
else
    window_valid <= 0;


end


end

endmodule
