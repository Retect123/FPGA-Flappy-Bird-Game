module bird(
    input  logic Clock,
    input  logic Reset,
    input  logic fly,                 // input to flap
	 input logic game_active,
    output logic [3:0] height,        // current vertical position
    output logic [15:0][15:0] RedPixels // 16x16 red LED array
);
    parameter START_HEIGHT = 4'd7;
    parameter MAX_HEIGHT   = 4'd0;	// top boundary
    parameter MIN_HEIGHT   = 4'd14;	// bottom boundary

    // Track bird height
    always_ff @(posedge Clock or posedge Reset) begin
        if (Reset)
            height <= START_HEIGHT;
        else if (game_active) begin
             if (fly && height > MAX_HEIGHT)
                 height <= height - 4'd1;
             else if (!fly && height < MIN_HEIGHT)
                 height <= height + 4'd1;
        end
    end

    // Draw 2x2 bird on LED array
	 always_comb begin
    // clear entire array every cycle
    RedPixels = '{default:16'b0};

    if (!Reset) begin
        if (height <= 14) begin
            RedPixels[height]   = 16'b0001100000000000;
            RedPixels[height+1] = 16'b0001100000000000;
        end
    end
	 end
endmodule


module bird_testbench();
  logic Clock, Reset, fly;
  logic [3:0] height;

  bird dut(.Clock, .Reset, .fly, .height);

  parameter CLOCK_PERIOD = 100;
  initial begin
    Clock <= 0;
    forever #(CLOCK_PERIOD / 2) Clock <= ~Clock;
  end

  integer i;
  initial begin
                          @(posedge Clock);
    Reset <= 1; fly <= 0; @(posedge Clock);
    Reset <= 0; fly <= 0; repeat(8) @(posedge Clock);
    fly <= 1;             @(posedge Clock);
    fly <= 0;             @(posedge Clock);
    fly <= 1;             @(posedge Clock);
                          @(posedge Clock);
                          @(posedge Clock);
    fly <= 0;             @(posedge Clock);
                          @(posedge Clock);
    fly <= 1;             @(posedge Clock);

    $stop;
  end
endmodule
