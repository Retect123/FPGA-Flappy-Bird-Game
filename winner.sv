module winner (leftHex, rightHex, playfieldReset, gameOver, Clock, Reset, L, R, LED9, LED1);
	input logic Clock, Reset;
	input logic L, R, LED9, LED1;
	output logic [6:0] leftHex, rightHex;
	output logic playfieldReset;
	output logic gameOver;
	
	logic [2:0] leftCounter, rightCounter;
	logic leftWin, rightWin;
	
	assign leftWin = (LED9 & L & ~R);
	assign rightWin = (LED1 & R & ~L);
	assign gameOver = (leftCounter == 3'b111) || (rightCounter == 3'b111);
	// Triggered on rising edge of clock
	always_ff @(posedge Clock) begin

		if (Reset) begin
			leftCounter <= 3'b000;
			rightCounter <= 3'b000;
		end
		else if (!gameOver) begin 
			if (leftWin && leftCounter < 3'b111)
				leftCounter <= leftCounter + 3'b001;

			else if (rightWin && rightCounter < 3'b111)
				rightCounter <= rightCounter + 3'b001;
		end
	end
	
	assign playfieldReset = (leftWin | rightWin);
	
	always_comb begin
		if (leftCounter == 3'b000)	// 0
			leftHex = 7'b1000000;
		else if (leftCounter == 3'b001)	// 1
			leftHex = 7'b1111001;
		else if (leftCounter == 3'b010)	// 2
			leftHex = 7'b0100100;
		else if (leftCounter == 3'b011)	// 3
			leftHex = 7'b0110000;
		else if (leftCounter == 3'b100)	// 4
			leftHex = 7'b0011001;	
		else if (leftCounter == 3'b101)	// 5
			leftHex = 7'b0010010;
		else if (leftCounter == 3'b110)	// 6
			leftHex = 7'b0000010;
		else
			leftHex = 7'b1111000;	// 7
	
		if (rightCounter == 3'b000)	// 0
			rightHex = 7'b1000000;
		else if (rightCounter == 3'b001)	// 1
			rightHex = 7'b1111001;
		else if (rightCounter == 3'b010)	// 2
			rightHex = 7'b0100100;
		else if (rightCounter == 3'b011)	// 3
			rightHex = 7'b0110000;
		else if (rightCounter == 3'b100)	// 4
			rightHex = 7'b0011001;	
		else if (rightCounter == 3'b101)	// 5
			rightHex = 7'b0010010;
		else if (rightCounter == 3'b110)	// 6
			rightHex = 7'b0000010;
		else
			rightHex = 7'b1111000;	// 7
	
	end
endmodule
