module draw_screen(
    input  logic              RST,
    input  logic [3:0]        bird_y,
    input  logic [3:0]        pipe_x,
    input  logic [3:0]        gap_top,
    output logic [15:0][15:0] RedPixels,
    output logic [15:0][15:0] GrnPixels
);

    logic [15:0][15:0] bird_pixels;
    logic [15:0][15:0] pipe_pixels;

    // Bird → red
    bird_draw BD(
        .RST(RST),
        .bird_y(bird_y),
        .RedPixels(bird_pixels)
    );

    // Pipe → green
    pipe_draw PD(
        .pipe_x(pipe_x),
        .gap_top(gap_top),
        .pipe_pixels(pipe_pixels)
    );

    always_comb begin
        if (RST) begin
            RedPixels = '{default:'{default:0}};
            GrnPixels = '{default:'{default:0}};
        end else begin
            RedPixels = bird_pixels;
            GrnPixels = pipe_pixels;
        end
    end
endmodule
