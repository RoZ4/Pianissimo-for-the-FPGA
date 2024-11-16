`include "../DefineMacros.vh"

module startScreenHandler(clk, inputGetAtAddress, outputColour);
	input clk; //! Testing clk
	input [14:0] inputGetAtAddress;
	output [23:0] outputColour;

	StartScreen startScreenMemoryController (inputGetAtAddress, clk, outputColour);
endmodule