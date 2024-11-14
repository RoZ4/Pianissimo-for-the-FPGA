`timescale 1ns / 1ps
`include "../DefineMacros.vh"
module testbench ( );

	parameter CLOCK_PERIOD = 20;

    reg CLOCK_50;	
	//reg [7:0] SW;
	reg [3:0] KEY;
	wire [7:0] VGA_X;
	wire [6:0] VGA_Y;
	wire [23:0] VGA_COLOR;
	wire plot, PS2_CLK, PS2_DAT;

	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
        KEY <= 4'b0;
        #20 KEY <= 1'b1; // reset

	end // initial

	// KEY IS OPPOSITE !!!!!!!
	initial begin
        KEY[0] <= 1'b0; #20 KEY[0] <= 1'b1;
	#25000
	force U1.inputStateStorage[`noPress] = 1'b0;
	force U1.inputStateStorage[`keySpacebar] = 1'b1;
	force U1.inputStateStorage[`keyBackslash] = 1'b0;
	#25000
	force U1.inputStateStorage[`keySpacebar] = 1'b0;
	#25000
	force U1.inputStateStorage[`keyRSquareBracket] = 1'b1;
	force U1.inputStateStorage[`keySpacebar] = 1'b0;
	#25000
	force U1.inputStateStorage[`noPress] = 1'b0;
	force U1.inputStateStorage[`keyBackslash] = 1'b0;


	end // initial

	PianissimoFinalProjectModelsim U1 (CLOCK_50, VGA_COLOR, VGA_X, VGA_Y, plot, PS2_CLK, PS2_DAT, KEY);

    //initial begin $monitor("time=%0d, reset=%b, counter=%d, hex=%7b", $time, KEY[0], slowCounterOut, HEX0); end 

endmodule
