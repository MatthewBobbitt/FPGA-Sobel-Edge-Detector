module Window #(
    parameter MAX_WIDTH = 1920
)(
    input wire clk,
    input wire rst,

    input wire [7:0] Gray,
    input wire gray_valid,

    input wire [15:0] image_width,
    input wire [15:0] image_height,

    output reg [7:0] P1,
    output reg [7:0] P2,
    output reg [7:0] P3,

    output reg [7:0] P4,
    output reg [7:0] P5,
    output reg [7:0] P6,

    output reg [7:0] P7,
    output reg [7:0] P8,
    output reg [7:0] P9,

    output reg window_valid
);


reg [7:0] line1 [0:MAX_WIDTH-1];
reg [7:0] line2 [0:MAX_WIDTH-1];

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

        // Move old rows through line buffers
        line2[column] <= line1[column];
        line1[column] <= Gray;


        // Right side of 3x3 window
        P3 <= line2[column];
        P6 <= line1[column];
        P9 <= Gray;


        // Shift existing pixels left
        P1 <= P2;
        P2 <= P3;

        P4 <= P5;
        P5 <= P6;

        P7 <= P8;
        P8 <= P9;


        if (column == image_width - 1) begin

            column <= 0;

            if (row == image_height - 1)
                row <= 0;
            else
                row <= row + 1;

        end

        else begin

            column <= column + 1;

        end


        if ((row >= 2) && (column >= 2))
            window_valid <= 1;
        else
            window_valid <= 0;

    end

    else begin

        window_valid <= 0;

    end

end


endmodule
