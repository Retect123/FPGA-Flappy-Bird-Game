// ----------------------------
// Top-level module for DE1-SoC
// ----------------------------
module DE1_SoC (
    HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    KEY, SW, LEDR, GPIO_1, CLOCK_50
);
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0] LEDR;
    input  logic [3:0] KEY;
    input  logic [9:0] SW;
    output logic [35:0] GPIO_1;
    input  logic CLOCK_50;

    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;
    assign LEDR = 10'd0;

    // ------------------------
    // System clock
    // ------------------------
    logic [31:0] clk_div;
    logic SYSTEM_CLOCK;
    clock_divider divider (.Clock(CLOCK_50), .divided_clocks(clk_div));
    assign SYSTEM_CLOCK = clk_div[22]; // slow clock
	 // assign SYSTEM_CLOCK = CLOCK_50;
	 
    // ------------------------
    // Button synchronizer
    // ------------------------
	 logic flap;
    dd_flip sync_flap (.Clock(SYSTEM_CLOCK), .Reset(SW[9]), .button(~KEY[0]), .out(flap));

	 // ------------------------
	 // Collision Detector
	 // If any overlapping pixels are ON at the same time then collision is active
	 // ------------------------
	 logic pixel_collision;
	 logic [15:0][15:0] BirdRed;
	 logic [15:0][15:0] PipeGrn;

	 always_comb begin
		  pixel_collision = 0;
		 for (int r = 0; r < 16; r++) begin
			  for (int c = 0; c < 16; c++) begin
		 			if (BirdRed[r][c] & PipeGrn[r][c])
						 pixel_collision = 1;
			  end
		 end
	end
	// If the bottom pixel reaches the bottom row it crashes
	logic [3:0] bird_height;
	logic hit_floor;
	assign hit_floor = (bird_height >= 14); // bird is 2 pixels tall

	// ------------------------
	// Game state tracker
	// Game resets when SW[9] is on
	// Game becomes inactive when collision is active or floor collision occurs
	// ------------------------
	logic game_active;
	always_ff @(posedge SYSTEM_CLOCK or posedge SW[9]) begin
		 if (SW[9])
			  game_active <= 1;
		 else if (pixel_collision || hit_floor)
			  game_active <= 0;
	end
	 
    // ------------------------
    // Bird
    // ------------------------
    bird flappy (
        .Clock(SYSTEM_CLOCK),
        .Reset(SW[9]),
        .fly(flap),
		  .game_active(game_active),
        .height(bird_height),
        .RedPixels(BirdRed)
    );
	 
	 // ------------------------
    // Random pipe height
    // ------------------------
    logic [2:0] rand_val;
    LFSR random_gen (.Clock(SYSTEM_CLOCK), .Reset(SW[9]), .Q(rand_val));

	 // ------------------------
	 // Pipe
	 // Keeps track of pipe position
	 // ------------------------
	 logic [15:0] pipe_col_11, pipe_col_12;
	 logic [3:0] pipe_x;

	 pipe moving_pipe (
		 .Clock(SYSTEM_CLOCK),
		 .Reset(SW[9]),
		 .lsfr_pipe(rand_val),
		 .game_active(game_active),
		 .GrnPixels(PipeGrn),
		 .pipe_col_11(pipe_col_11),
		 .pipe_col_12(pipe_col_12),
		 .pipe_x(pipe_x)
	 );
	 
	 

	 // ------------------------
    // Score logic
	 // Increments score when pipe moves past bird's x column without collision
    // ------------------------
    logic [9:0] score;
    logic prev_pixel_collision;
    logic pipe_passed;

    localparam int BIRD_COLUMN_X = 11; // adjust based on bird's x position

    always_ff @(posedge SYSTEM_CLOCK or posedge SW[9]) begin
        if (SW[9]) begin
            prev_pixel_collision <= 0;
            pipe_passed <= 0;
        end else begin
            // Detect a pipe just passed the bird if game is active,
				// no collision, and pipe's x matches bird's column
            pipe_passed <= game_active && (prev_pixel_collision == 0 && pixel_collision == 0 && pipe_x == BIRD_COLUMN_X);
            prev_pixel_collision <= pixel_collision;
        end
    end

	 score_counter points (
		 .Clock(SYSTEM_CLOCK),
		 .Reset(SW[9]),
		 .game_over(~game_active),
		 .pipe_passed(pipe_passed),
		 .score(score)
	 );
	 
	 // Convert score to 3 digit decimal
    logic [3:0] hundreds, tens, ones;
    always_comb begin
        hundreds = 4'(score / 100);
        tens     = 4'((score % 100) / 10);
        ones     = 4'(score % 10);
    end

    hex7seg H0 (.value(ones),     .hex(HEX0));
    hex7seg H1 (.value(tens),     .hex(HEX1));
    hex7seg H2 (.value(hundreds), .hex(HEX2));
	 
	 // ------------------------
    // LED driver
    // ------------------------
    logic [15:0][15:0] RedPixels, GrnPixels;
    always_comb begin
        RedPixels = BirdRed;
        GrnPixels = PipeGrn;
    end
	 
	 LEDDriver #(.FREQDIV(12)) Driver (
    .GPIO_1(GPIO_1),
    .RedPixels(RedPixels),
    .GrnPixels(GrnPixels),
    .EnableCount(1'b1),
    .CLK(CLOCK_50),
    .RST(SW[9])
	 );

endmodule

module DE1_SoC_testbench();
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [35:0] GPIO_1;
    logic CLOCK_50;

    // Instantiate DUT
    DE1_SoC dut (
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2),
        .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
        .KEY(KEY), .SW(SW),
        .LEDR(LEDR), .GPIO_1(GPIO_1),
        .CLOCK_50(CLOCK_50)
    );
	parameter CLOCK_PERIOD = 100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
		// Reset
		SW[9] <= 1;													@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
		// Let the bird fall down to test gravity
		SW[9] <= 0;		repeat(10)								@(posedge CLOCK_50);
		// Test the button going all the way up by holding and testing collision detector
		SW[9] <= 1;													@(posedge CLOCK_50);
		SW[9] <= 0;													@(posedge CLOCK_50);
		KEY[0] <= 0;				repeat(10)					@(posedge CLOCK_50);
		KEY[1] <= 1;												@(posedge CLOCK_50);
		// Test clicking of the button and score counter
		SW[9] <= 1;													@(posedge CLOCK_50);
		SW[9] <= 0;													@(posedge CLOCK_50);
		KEY[0] <= 0;												@(posedge CLOCK_50);
		KEY[0] <= 1;												@(posedge CLOCK_50);
		KEY[0] <= 0;												@(posedge CLOCK_50);
		KEY[0] <= 1;												@(posedge CLOCK_50);
		KEY[0] <= 0;												@(posedge CLOCK_50);
		KEY[0] <= 1;												@(posedge CLOCK_50);
		KEY[0] <= 0;												@(posedge CLOCK_50);
		KEY[0] <= 1;			repeat(15)						@(posedge CLOCK_50);
		// Test collision
		
		SW[9] <= 1;													@(posedge CLOCK_50);
		SW[9] <= 0;													@(posedge CLOCK_50);
		KEY[0] <= 0;				repeat(5)					@(posedge CLOCK_50);
		KEY[0] <= 1;												@(posedge CLOCK_50);
		KEY[0] <= 0;												@(posedge CLOCK_50);
		KEY[0] <= 1;												@(posedge CLOCK_50);
		KEY[0] <= 0;												@(posedge CLOCK_50);
		KEY[0] <= 1;				repeat(5)					@(posedge CLOCK_50);
		
		
		KEY[0] <= 0;				repeat(2)					@(posedge CLOCK_50);
		KEY[0] <= 1;				repeat(3)					@(posedge CLOCK_50);
		KEY[0] <= 0;												@(posedge CLOCK_50);
		KEY[0] <= 1;												@(posedge CLOCK_50);
		KEY[0] <= 0;												@(posedge CLOCK_50);
		KEY[0] <= 1;												@(posedge CLOCK_50);

		KEY[0] <= 0;				repeat(5)					@(posedge CLOCK_50);
		KEY[0] <= 1;												@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
																		@(posedge CLOCK_50);
		$stop;
	end
	
endmodule
