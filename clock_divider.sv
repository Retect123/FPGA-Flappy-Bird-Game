/* divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... 
  [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ... */
module clock_divider (Clock, divided_clocks);
 input logic Clock;
 output logic [31:0] divided_clocks = 0;

 always_ff @(posedge Clock) begin
	divided_clocks <= divided_clocks + 1;
 end

endmodule 