module collision_detector (
    input  logic Clock,
    input  logic Reset,
    input  logic [3:0] bird_y,
    input  logic [15:0] pipe_col_11,
    input  logic [15:0] pipe_col_12,
    input  logic [3:0] pipe_x,
    output logic collision,
    output logic pipe_at_bird
);

    always_comb begin
        // pipe is at bird's horizontal columns
        pipe_at_bird = (pipe_x == 4'd11) || (pipe_x == 4'd12);

        // default no collision
        collision = 0;

        if (pipe_at_bird) begin
            // check if bird overlaps a lit pixel
            if ((pipe_x == 4'd11 && pipe_col_11[bird_y]) ||
                (pipe_x == 4'd12 && pipe_col_12[bird_y])) begin
                collision = 1;
            end
        end
    end
endmodule
