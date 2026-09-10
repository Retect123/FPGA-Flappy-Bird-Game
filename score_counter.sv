module score_counter(
    input  logic Clock,
    input  logic Reset,
    input  logic game_over,
    input  logic pipe_passed,   // signal: pipe just passed the bird
    output logic [9:0] score
);

    always_ff @(posedge Clock) begin
        if (Reset)
            score <= 10'd0;
        else if (!game_over && pipe_passed && score < 10'd999)
            score <= score + 10'd1;
    end
endmodule
