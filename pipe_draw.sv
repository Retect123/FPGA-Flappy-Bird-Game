module pipe_draw(
    input  logic [3:0] pipe_x,
    input  logic [3:0] gap_top,
    output logic [15:0][15:0] pipe_pixels
);
    parameter GAP_SIZE = 4'd8;

    always_comb begin
        pipe_pixels = '{default:16'b0};

        if (pipe_x < 16) begin
            // Create a mask for the column
            logic [15:0] column_mask;
            column_mask = 16'b1111111111111111;

            // Zero out the gap
            column_mask[gap_top +: GAP_SIZE] = {GAP_SIZE{1'b0}};

            // Assign mask to the column
            for (int r = 0; r < 16; r++)
                pipe_pixels[r][pipe_x] = column_mask[r];
        end
    end
endmodule
