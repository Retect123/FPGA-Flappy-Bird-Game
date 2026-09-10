module dd_flip(out, Clock, Reset, button);
	input logic Clock;
	input logic Reset;
	input logic button;
	output logic out;
	
	logic ff;
	// Make keys go through two D flipflops to remove metastability
	always_ff @(posedge Clock) begin
		if (Reset) begin
			ff <= 1'b0;
			out <= 1'b0;
		end else begin
			ff <= button;
			out <= ff;
		end
	end
endmodule
