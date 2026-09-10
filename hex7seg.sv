module hex7seg(
    input  logic [3:0] value,
    output logic [6:0] hex
);
    always_comb begin
        case (value)
            4'd0: hex = 7'b1000000;
            4'd1: hex = 7'b1111001;
            4'd2: hex = 7'b0100100;
            4'd3: hex = 7'b0110000;
            4'd4: hex = 7'b0011001;
            4'd5: hex = 7'b0010010; // corrected pattern
            4'd6: hex = 7'b0000010;
            4'd7: hex = 7'b1111000;
            4'd8: hex = 7'b0000000;
            4'd9: hex = 7'b0010000;
            default: hex = 7'b1111111;
        endcase
    end
endmodule
