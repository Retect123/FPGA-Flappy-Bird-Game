module normalLight (lightOn, Clock, Reset, L, R, NL, NR, playfieldReset);
	input logic Clock, Reset;
	// L is true when left key is pressed, R is true when the right key
	// is pressed, NL is true when the light on the left is on, and NR
	// is true when the light on the right is on.
	input logic L, R, NL, NR, playfieldReset;
	// when lightOn is true, the normal light should be on.
	output logic lightOn;
	
	// State variables
	enum {OFF, ON} ps, ns;
	
	// Next State logic
	always_comb begin
		case(ps)
			OFF: if ((L & NR & ~R) | (R & NL & ~L)) ns = ON;
						else ns = OFF;
					
			ON:  if ((~L & R) | (L & ~R)) ns = OFF;
						else ns = ON;
						
		endcase
	end
	
	// Output logic
	always_comb begin
		case(ps)
			ON: lightOn = 1;
			OFF: lightOn = 0;
		endcase
	end
	
	// DFFs
	always_ff @(posedge Clock) begin
		if (Reset | playfieldReset)
			ps <= OFF;
		else
			ps <= ns;
	end
endmodule

										