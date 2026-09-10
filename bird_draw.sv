module bird_draw(
    input  logic RST,
    input  logic [3:0] bird_y,
    output logic [15:0][15:0] RedPixels
);

    always_comb begin
        // Clear display
        for (int r = 0; r < 16; r++)
            RedPixels[r] = 16'b0;

        if (!RST) begin
            // BIRD occupies 2 rows (bird_y and bird_y+1)
            // And 2 columns: bits 11 and 10 (columns 4 and 5 from left)

            if (bird_y < 15) begin
                RedPixels[bird_y][12] = 1'b1;  // column 4 (from left)
                RedPixels[bird_y][11] = 1'b1;  // column 5 (from left)
            end

            if ((bird_y + 1) < 15) begin
                RedPixels[bird_y+1][12] = 1'b1;
                RedPixels[bird_y+1][11] = 1'b1;
            end
        end
    end

endmodule
