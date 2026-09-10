module gameTracker(
    input  logic Clock,
    input  logic Reset,
    input  logic hit,
    output logic game_over
);

    always_ff @(posedge Clock or posedge Reset) begin
        if (Reset)
            game_over <= 1'b0;
        else if (hit)
            game_over <= 1'b1;
    end
endmodule
