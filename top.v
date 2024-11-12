module top (CLOCK_50, VGA_COLOR, VGA_X, VGA_Y, plot, PS2_CLK, PS2_DAT, KEY);

    input CLOCK_50;             // DE-series 50 MHz clock signal
    input wire PS2_CLK, PS2_DAT;
    input wire [3:0] KEY;       // DE-series pushbuttons

    output wire [23:0] VGA_COLOR;
    output wire [7:0] VGA_X;
    output wire [6:0] VGA_Y;
    output wire plot;

    PianissimoFinalProjectModelsim U1 (CLOCK_50, VGA_COLOR, VGA_X, VGA_Y, plot, PS2_CLK, PS2_DAT, KEY);

endmodule

