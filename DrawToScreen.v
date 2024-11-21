`include "DefineMacros.vh"

module drawToScreen (clk, nextAddress, doneDrawing, outputDrawScreenPosX, outputDrawScreenPosY, currentState);
	input clk;
	input [4:0] currentState;
	output reg doneDrawing;
	output reg [14:0] nextAddress;
	output reg [7:0] outputDrawScreenPosX = 0, outputDrawScreenPosY = 0;

	initial doneDrawing = 0;
	initial nextAddress = 0;

	always @(posedge clk) begin
		if (doneDrawing) doneDrawing <= 0;

		else begin
			if (outputDrawScreenPosX < 8'd159) begin
				outputDrawScreenPosX <= outputDrawScreenPosX + 1;
			end
			else if (outputDrawScreenPosX == 8'd159 && outputDrawScreenPosY < 8'd119) begin
				outputDrawScreenPosY <= outputDrawScreenPosY + 1;
				outputDrawScreenPosX <= 0;
				
			end

			nextAddress <= nextAddress + 1;
		end

		if (outputDrawScreenPosX == 8'd159 && outputDrawScreenPosY == 8'd119) begin
			outputDrawScreenPosX <= 0;
			outputDrawScreenPosY <= 0;
			doneDrawing <= 1;
			nextAddress <= 0;
		end

	end
endmodule

module resetScreen (clk, noteBlocksDoneDrawing, currentState, inputDrawScreenPosX, inputDrawScreenPosY,  inputStateStorage, outputColour);
	input clk, noteBlocksDoneDrawing;
	input [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage;
	input [7:0] inputDrawScreenPosX, inputDrawScreenPosY;
	input [4:0] currentState;
	output reg [23:0] outputColour;
	
	// wire [23:0] pianoColour;
	// reg [12:0] internalPianoAddress = 0;
	// PianoROM pianoImage(internalPianoAddress, clk, pianoColour);

	// always @(posedge clk) begin
	// 	if (noteBlocksDoneDrawing || currentState == `RECORD) begin
	// 		if (internalPianoAddress >= 13'd4480) internalPianoAddress <= 0;
	// 		else if (inputDrawScreenPosY >= 8'd92) begin
	// 			internalPianoAddress <= internalPianoAddress + 1;
	// 		end
	// 	end

	// end

	always @(*) begin //was clk
		if (currentState == `RECORD || noteBlocksDoneDrawing) begin
			if (inputDrawScreenPosY < 8'd92) begin
				outputColour <= `COLOURWHITE;
			end
			else begin
				// `ifdef SIMULATION
				// outputColour <= 24'b00000000_00000000_00000001;
				// `else
				// outputColour <= pianoColour;
				// `endif
				// Black notes
				if (inputDrawScreenPosY < 111 && inputDrawScreenPosX > 4 && inputDrawScreenPosX < 12) begin //C#
					outputColour <= inputStateStorage[`key1] ? `COLOURWHENBLACKPRESSED : `COLOURBLACK;
				end
				else if (inputDrawScreenPosY < 111 && inputDrawScreenPosX > 18 && inputDrawScreenPosX < 26) begin //D#
					outputColour <= inputStateStorage[`key2] ? `COLOURWHENBLACKPRESSED : `COLOURBLACK;
				end
				else if (inputDrawScreenPosY < 111 && inputDrawScreenPosX > 39 && inputDrawScreenPosX < 47) begin //F#
					outputColour <= inputStateStorage[`key4] ? `COLOURWHENBLACKPRESSED : `COLOURBLACK;
				end
				else if (inputDrawScreenPosY < 111 && inputDrawScreenPosX > 52 && inputDrawScreenPosX < 60) begin //G#
					outputColour <= inputStateStorage[`key5] ? `COLOURWHENBLACKPRESSED : `COLOURBLACK;
				end
				else if (inputDrawScreenPosY < 111 && inputDrawScreenPosX > 65 && inputDrawScreenPosX < 73) begin //A#
					outputColour <= inputStateStorage[`key6] ? `COLOURWHENBLACKPRESSED : `COLOURBLACK;
				end
				else if (inputDrawScreenPosY < 111 && inputDrawScreenPosX > 86 && inputDrawScreenPosX < 94) begin //C#
					outputColour <= inputStateStorage[`key8] ? `COLOURWHENBLACKPRESSED : `COLOURBLACK;
				end
				else if (inputDrawScreenPosY < 111 && inputDrawScreenPosX > 100 && inputDrawScreenPosX < 108) begin //D#
					outputColour <= inputStateStorage[`key9] ? `COLOURWHENBLACKPRESSED : `COLOURBLACK;
				end
				else if (inputDrawScreenPosY < 111 && inputDrawScreenPosX > 121 && inputDrawScreenPosX < 129) begin //F#
					outputColour <= inputStateStorage[`keyMinus] ? `COLOURWHENBLACKPRESSED : `COLOURBLACK;
				end
				else if (inputDrawScreenPosY < 111 && inputDrawScreenPosX > 134 && inputDrawScreenPosX < 142) begin //G#
					outputColour <= inputStateStorage[`keyEquals] ? `COLOURWHENBLACKPRESSED : `COLOURBLACK;
				end
				else if (inputDrawScreenPosY < 111 && inputDrawScreenPosX > 147 && inputDrawScreenPosX < 155) begin //A#
					outputColour <= inputStateStorage[`keyBackspace] ? `COLOURWHENBLACKPRESSED : `COLOURBLACK;
				end
				else begin
					if (inputDrawScreenPosX < 9) begin
						outputColour <= inputStateStorage[`keyTab] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 10 && inputDrawScreenPosX < 20) begin
						outputColour <= inputStateStorage[`keyQ] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 21 && inputDrawScreenPosX < 32) begin
						outputColour <= inputStateStorage[`keyW] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 33 && inputDrawScreenPosX < 44) begin
						outputColour <= inputStateStorage[`keyE] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 45 && inputDrawScreenPosX < 56) begin
						outputColour <= inputStateStorage[`keyR] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 56 && inputDrawScreenPosX < 67) begin
						outputColour <= inputStateStorage[`keyT] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 68 && inputDrawScreenPosX < 79) begin
						outputColour <= inputStateStorage[`keyY] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 80 && inputDrawScreenPosX < 91) begin
						outputColour <= inputStateStorage[`keyU] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 92 && inputDrawScreenPosX < 102) begin
						outputColour <= inputStateStorage[`keyI] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 103 && inputDrawScreenPosX < 114) begin
						outputColour <= inputStateStorage[`keyO] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 115 && inputDrawScreenPosX < 126) begin
						outputColour <= inputStateStorage[`keyP] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 127 && inputDrawScreenPosX < 138) begin
						outputColour <= inputStateStorage[`keyLSquareBracket] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 138 && inputDrawScreenPosX < 149) begin
						outputColour <= inputStateStorage[`keyRSquareBracket] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else if (inputDrawScreenPosX > 150) begin
						outputColour <= inputStateStorage[`keyBackslash] ? `COLOURWHENWHITEPRESSED : `COLOURWHITE;
					end
					else outputColour <= 24'b10011111_10011111_10011111;
				end

			end
		end
	end
endmodule