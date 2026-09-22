`timescale 1ns/1ps
module ImageProcessor_tb;

parameter WIDTH = 3456;
parameter HEIGHT = 4608;

parameter NUM_PIXELS = WIDTH * HEIGHT;

reg clk;
reg rst;
reg valid;

reg [7:0] R;
reg [7:0] G;
reg [7:0] B;

wire [7:0] Edge;
wire edge_valid;

integer pixel_file;
integer output_file;
integer scan;
integer i;
integer edge_count;


ImageProcessor #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) uut (
.clk(clk),
.rst(rst),
.valid(valid),

.R(R), .G(G), .B(B),

.Edge(Edge),
.edge_valid(edge_valid)
);

initial begin
clk = 0;
end
always #5 clk = ~clk;

//---------------------------------------------------------------
always @(posedge clk) begin
#1;

if (edge_valid) begin
$fwrite(output_file, "%d\n", Edge);
edge_count = edge_count + 1;
end

end
//------------------------------------------------------------------
initial begin



rst = 1;
valid = 0;

R = 0;
G = 0;
B = 0;

edge_count = 0;


pixel_file = $fopen("pixels.txt", "r");

output_file = $fopen("edge_pixels.txt", "w");




    @(posedge clk);
    @(posedge clk);

    rst = 0;


    for (i = 0; i < NUM_PIXELS; i = i + 1) begin

        scan = $fscanf(
            pixel_file,
            "%d %d %d",
            R,
            G,
            B
        );

        if (scan == 3)
            valid = 1;
        else
            valid = 0;

        // Wait for processor clock
        @(posedge clk);

    end


    valid = 0;


 
    repeat(10)
        @(posedge clk);


    $fclose(pixel_file);
    $fclose(output_file);

end

endmodule