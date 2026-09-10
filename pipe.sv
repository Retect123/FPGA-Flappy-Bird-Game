module pipe (
    input  logic Clock,
    input  logic Reset,
    input  logic [2:0] lsfr_pipe,   // new pipe from LSFR
	 input logic game_active,
    output logic [15:0][15:0] GrnPixels,
	 output logic [15:0] pipe_col_11,	// pipe pixels in bird zone
	 output logic [15:0] pipe_col_12,	// pipe pixels in bird zone
	 output logic [3:0]  pipe_x
);

    // ------------------------
    // Pipe patterns storage
    // ------------------------
    logic [15:0] pipePatterns [0:7][0:15]; // 8 patterns, 16x16

    // Pipe scrolling
    logic [3:0]  x_position;      // horizontal scroll position
    logic [2:0]  current_pipe;    // pipe currently on screen
    logic        load_new_pipe;   // flag to load new pipe

	initial begin
    // Pattern 0
		 pipePatterns[0][0]  = 16'b0000000000001110;
		 pipePatterns[0][1]  = 16'b0000000000001110;
		 pipePatterns[0][2]  = 16'b0000000000001110;
		 pipePatterns[0][3]  = 16'b0000000000001110;
		 pipePatterns[0][4]  = 16'b0000000000001110;
		 pipePatterns[0][5]  = 16'b0000000000000000;
		 pipePatterns[0][6]  = 16'b0000000000000000;
		 pipePatterns[0][7]  = 16'b0000000000000000;
		 pipePatterns[0][8]  = 16'b0000000000000000;
		 pipePatterns[0][9]  = 16'b0000000000000000;
		 pipePatterns[0][10] = 16'b0000000000001110;
		 pipePatterns[0][11] = 16'b0000000000001110;
		 pipePatterns[0][12] = 16'b0000000000001110;
		 pipePatterns[0][13] = 16'b0000000000001110;
		 pipePatterns[0][14] = 16'b0000000000001110;
		 pipePatterns[0][15] = 16'b0000000000001110;

		 // Pattern 1
		 pipePatterns[1][0]  = 16'b0000000000001110;
		 pipePatterns[1][1]  = 16'b0000000000000000;
		 pipePatterns[1][2]  = 16'b0000000000000000;
		 pipePatterns[1][3]  = 16'b0000000000000000;
		 pipePatterns[1][4]  = 16'b0000000000000000;
		 pipePatterns[1][5]  = 16'b0000000000000000;
		 pipePatterns[1][6]  = 16'b0000000000001110;
		 pipePatterns[1][7]  = 16'b0000000000001110;
		 pipePatterns[1][8]  = 16'b0000000000001110;
		 pipePatterns[1][9]  = 16'b0000000000001110;
		 pipePatterns[1][10] = 16'b0000000000001110;
		 pipePatterns[1][11] = 16'b0000000000001110;
		 pipePatterns[1][12] = 16'b0000000000001110;
		 pipePatterns[1][13] = 16'b0000000000001110;
		 pipePatterns[1][14] = 16'b0000000000001110;
		 pipePatterns[1][15] = 16'b0000000000001110;

		 // Pattern 2
		 pipePatterns[2][0]  = 16'b0000000000001110;
		 pipePatterns[2][1]  = 16'b0000000000001110;
		 pipePatterns[2][2]  = 16'b0000000000001110;
		 pipePatterns[2][3]  = 16'b0000000000001110;
		 pipePatterns[2][4]  = 16'b0000000000001110;
		 pipePatterns[2][5]  = 16'b0000000000001110;
		 pipePatterns[2][6]  = 16'b0000000000001110;
		 pipePatterns[2][7]  = 16'b0000000000001110;
		 pipePatterns[2][8]  = 16'b0000000000001110;
		 pipePatterns[2][9]  = 16'b0000000000001110;
		 pipePatterns[2][10] = 16'b0000000000000000;
		 pipePatterns[2][11] = 16'b0000000000000000;
		 pipePatterns[2][12] = 16'b0000000000000000;
		 pipePatterns[2][13] = 16'b0000000000000000;
		 pipePatterns[2][14] = 16'b0000000000000000;
		 pipePatterns[2][15] = 16'b0000000000001110;

		 // Pattern 3
		 pipePatterns[3][0]  = 16'b0000000000001110;
		 pipePatterns[3][1]  = 16'b0000000000001110;
		 pipePatterns[3][2]  = 16'b0000000000001110;
		 pipePatterns[3][3]  = 16'b0000000000001110;
		 pipePatterns[3][4]  = 16'b0000000000001110;
		 pipePatterns[3][5]  = 16'b0000000000001110;
		 pipePatterns[3][6]  = 16'b0000000000001110;
		 pipePatterns[3][7]  = 16'b0000000000001110;
		 pipePatterns[3][8]  = 16'b0000000000000000;
		 pipePatterns[3][9]  = 16'b0000000000000000;
		 pipePatterns[3][10] = 16'b0000000000000000;
		 pipePatterns[3][11] = 16'b0000000000000000;
		 pipePatterns[3][12] = 16'b0000000000000000;
		 pipePatterns[3][13] = 16'b0000000000001110;
		 pipePatterns[3][14] = 16'b0000000000001110;
		 pipePatterns[3][15] = 16'b0000000000001110;

		 // Pattern 4
		 pipePatterns[4][0]  = 16'b0000000000001110;
		 pipePatterns[4][1]  = 16'b0000000000001110;
		 pipePatterns[4][2]  = 16'b0000000000001110;
		 pipePatterns[4][3]  = 16'b0000000000000000;
		 pipePatterns[4][4]  = 16'b0000000000000000;
		 pipePatterns[4][5]  = 16'b0000000000000000;
		 pipePatterns[4][6]  = 16'b0000000000000000;
		 pipePatterns[4][7]  = 16'b0000000000000000;
		 pipePatterns[4][8]  = 16'b0000000000001110;
		 pipePatterns[4][9]  = 16'b0000000000001110;
		 pipePatterns[4][10] = 16'b0000000000001110;
		 pipePatterns[4][11] = 16'b0000000000001110;
		 pipePatterns[4][12] = 16'b0000000000001110;
		 pipePatterns[4][13] = 16'b0000000000001110;
		 pipePatterns[4][14] = 16'b0000000000001110;
		 pipePatterns[4][15] = 16'b0000000000001110;

		 // Pattern 5
		 pipePatterns[5][0]  = 16'b0000000000001110;
		 pipePatterns[5][1]  = 16'b0000000000001110;
		 pipePatterns[5][2]  = 16'b0000000000001110;
		 pipePatterns[5][3]  = 16'b0000000000001110;
		 pipePatterns[5][4]  = 16'b0000000000001110;
		 pipePatterns[5][5]  = 16'b0000000000001110;
		 pipePatterns[5][6]  = 16'b0000000000001110;
		 pipePatterns[5][7]  = 16'b0000000000001110;
		 pipePatterns[5][8]  = 16'b0000000000001110;
		 pipePatterns[5][9]  = 16'b0000000000000000;
		 pipePatterns[5][10] = 16'b0000000000000000;
		 pipePatterns[5][11] = 16'b0000000000000000;
		 pipePatterns[5][12] = 16'b0000000000000000;
		 pipePatterns[5][13] = 16'b0000000000000000;
		 pipePatterns[5][14] = 16'b0000000000001110;
		 pipePatterns[5][15] = 16'b0000000000001110;

		 // Pattern 6
		 pipePatterns[6][0]  = 16'b0000000000001110;
		 pipePatterns[6][1]  = 16'b0000000000001110;
		 pipePatterns[6][2]  = 16'b0000000000001110;
		 pipePatterns[6][3]  = 16'b0000000000001110;
		 pipePatterns[6][4]  = 16'b0000000000001110;
		 pipePatterns[6][5]  = 16'b0000000000001110;
		 pipePatterns[6][6]  = 16'b0000000000001110;
		 pipePatterns[6][7]  = 16'b0000000000001110;
		 pipePatterns[6][8]  = 16'b0000000000001110;
		 pipePatterns[6][9]  = 16'b0000000000000000;
		 pipePatterns[6][10] = 16'b0000000000000000;
		 pipePatterns[6][11] = 16'b0000000000000000;
		 pipePatterns[6][12] = 16'b0000000000000000;
		 pipePatterns[6][13] = 16'b0000000000000000;
		 pipePatterns[6][14] = 16'b0000000000001110;
		 pipePatterns[6][15] = 16'b0000000000001110;

		 // Pattern 7
		 pipePatterns[7][0]  = 16'b0000000000001110;
		 pipePatterns[7][1]  = 16'b0000000000001110;
		 pipePatterns[7][2]  = 16'b0000000000001110;
		 pipePatterns[7][3]  = 16'b0000000000001110;
		 pipePatterns[7][4]  = 16'b0000000000000000;
		 pipePatterns[7][5]  = 16'b0000000000000000;
		 pipePatterns[7][6]  = 16'b0000000000000000;
		 pipePatterns[7][7]  = 16'b0000000000000000;
		 pipePatterns[7][8]  = 16'b0000000000000000;
		 pipePatterns[7][9]  = 16'b0000000000001110;
		 pipePatterns[7][10] = 16'b0000000000001110;
		 pipePatterns[7][11] = 16'b0000000000001110;
		 pipePatterns[7][12] = 16'b0000000000001110;
		 pipePatterns[7][13] = 16'b0000000000001110;
		 pipePatterns[7][14] = 16'b0000000000001110;
		 pipePatterns[7][15] = 16'b0000000000001110;
	end 
		
	 // ------------------------
    // Scroll pipe left by shifting bits in every row
    // ------------------------
    always_ff @(posedge Clock) begin
        if (Reset) begin
            current_pipe <= lsfr_pipe;
            x_position   <= 0;
				// Load selected pipe pattern
            for (int r = 0; r < 16; r++)
                GrnPixels[r] <= pipePatterns[0][r];
        end
        else if (game_active) begin
				// Shift pipe pixels left by multiplying
            for (int r = 0; r < 16; r++)
                GrnPixels[r] <= GrnPixels[r] * 4'd2 ;  // shift left 1 pixel

            x_position <= x_position + 4'd1;

            // Load a new pipe when previous fully scrolled off
            if (x_position == 15) begin
                current_pipe <= lsfr_pipe;
                x_position   <= 0;
                for (int r = 0; r < 16; r++)
                    GrnPixels[r] <= pipePatterns[current_pipe][r];
            end
        end
    end
	 
	 // ---------------------------------------------------------
	 // Extract the two pipe columns where the bird lives (11 & 12)
	 // Allows my top level to detect bird and pipe overlapping
	// ---------------------------------------------------------
	 always_comb begin
		  for (int r = 0; r < 16; r++) begin
			   pipe_col_11[r] = GrnPixels[r][15-11];  // column 11 from left
			   pipe_col_12[r] = GrnPixels[r][15-12];  // column 12 from left
		  end

		  pipe_x = x_position;   // export pipe horizontal position
	 end

endmodule
