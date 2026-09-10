module LFSR(Q, Clock, Reset);
	input logic Clock, Reset;
	output logic [2:0] Q;
	
	logic xnor_out;
	assign xnor_out = ~(Q[2] ^ Q[1]);
	
	always_ff @(posedge Clock) begin
		if (Reset)
			Q <= 3'b001;
		else
			Q <= {Q[1:0], xnor_out};
	end
endmodule

module LFSR_testbench();
	logic [2:0] Q;
	logic Clock, Reset;
	logic xnor_out;
	
	LFSR dut(.Clock, .Reset, .Q);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		Clock <= 0;
		forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
	end
	
	initial begin
		Reset <= 1;													@(posedge Clock);
																		@(posedge Clock);
		Reset <= 0;				repeat(64)						@(posedge Clock);
																		@(posedge Clock);
																		@(posedge Clock);
																		@(posedge Clock);
																		@(posedge Clock);
																		@(posedge Clock);
		$stop;
	end																	
endmodule
