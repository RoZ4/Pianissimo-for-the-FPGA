`timescale 1ns / 1ps
`include "../DefineMacros.vh"
module testbench ( );

	parameter CLOCK_PERIOD = 20;

    	reg CLOCK_50;	
	//reg [7:0] SW;
	wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6;
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
	#10
	force U1.inputStateStorage[`keySpacebar] = 1'b1;
	force U1.mainStateDrumsController.nextSubState = `subSTARTNOTERECORDING;
	force U1.inputStateStorage[`keyBackslash] = 1'b0;
	#200
	force U1.inputStateStorage[`keySpacebar] = 1'b0;
	force U1.inputStateStorage[`keyF] = 1'b1;
	release U1.mainStateDrumsController.nextSubState;
	#100
	force U1.inputStateStorage[`keyF] = 1'b0;
	#400
	force U1.inputStateStorage[`keyG] = 1'b1;
	#100
	force U1.inputStateStorage[`keyG] = 1'b0;
	#100
	force U1.inputStateStorage[`keyEnter] = 1'b1;
	#100
	force U1.inputStateStorage[`keyEnter] = 1'b0;


	#1500
	force U1.inputStateStorage[`keySpacebar] = 1'b1;
	#20
	force U1.inputStateStorage[`keySpacebar] = 1'b0;
	#200
	force U1.inputStateStorage[`keyF] = 1'b1;
	#200
	force U1.inputStateStorage[`keyF] = 1'b0;
	#600
	force U1.inputStateStorage[`keyG] = 1'b1;
	#100
	force U1.inputStateStorage[`keyG] = 1'b0;
	#100
	force U1.inputStateStorage[`keyEnter] = 1'b1;
	#100
	force U1.inputStateStorage[`keyEnter] = 1'b0;
	

	end // initial

	PianissimoFinalProjectModelsim U1 (CLOCK_50, VGA_COLOR, VGA_X, VGA_Y, plot, PS2_CLK, PS2_DAT, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6);
    //initial begin $monitor("time=%0d, reset=%b, counter=%d, hex=%7b", $time, KEY[0], slowCounterOut, HEX0); end 

endmodule
