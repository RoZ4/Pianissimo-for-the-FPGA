`include "DefineMacros.vh"

module drawToScreen (clk, nextAddress, inputStateStorage, doneDrawing, outputDrawScreenPosX, outputDrawScreenPosY, currentState);
	input clk;
	input [4:0] currentState;
	input [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage;
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

		if ((outputDrawScreenPosX == 8'd159 && outputDrawScreenPosY == 8'd119) || currentState == `STARTSCREEN || inputStateStorage[`keySpacebar]) begin
			outputDrawScreenPosX <= 0;
			outputDrawScreenPosY <= 0;
			doneDrawing <= 1;
			nextAddress <= 0;
		end

	end
endmodule

module resetScreen (clk, noteBlocksDoneDrawing, currentState, inputDrawScreenPosX, inputDrawScreenPosY,  inputStateStorage, retrievedNoteDataNote, playDrumNote, outputColour);
	input clk, noteBlocksDoneDrawing;
	input [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage;
	input [7:0] inputDrawScreenPosX, inputDrawScreenPosY;
	input [2:0] retrievedNoteDataNote;
	input playDrumNote;
	input [4:0] currentState;
	output reg [23:0] outputColour;

	reg [12:0] internalDrumkitBackgroundAddress = 0;
	reg [10:0] BassdrumAddress = 0;
	reg [9:0] cymbelAddress = 0;
	reg [7:0] middleDrumAddress = 0;
	reg [8:0] topLeftDrumAddress = 0;

	wire [23:0] dkbkColour;
	wire bassDrumColour;
	wire cymbelColour;
	wire middleDrumColour;
	wire topLeftDrumColour;
	
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

	DrumkitBackgroundROM dkbk(internalDrumkitBackgroundAddress, clk, dkbkColour);
	BassdrumROM bass(BassdrumAddress, clk, bassDrumColour);
	cymbelROM cymbel(cymbelAddress, clk, cymbelColour);
	middleDrumROM middle(middleDrumAddress, clk, middleDrumColour);
	topLeftDrumROM topleft(topLeftDrumAddress, clk, topLeftDrumColour);

	always @(posedge clk) begin
		if (inputDrawScreenPosX == 0 && inputDrawScreenPosY == 0) begin
			internalDrumkitBackgroundAddress <= 0;
			BassdrumAddress <= 0;
			cymbelAddress <= 0;
			middleDrumAddress <= 0;
			topLeftDrumAddress <= 0;
		end

		if (internalDrumkitBackgroundAddress >= 7198) internalDrumkitBackgroundAddress <= 0;
		if (BassdrumAddress >= 1722) BassdrumAddress <= 0;
		if (cymbelAddress >= 570) cymbelAddress <= 0;
		if (middleDrumAddress >= 198) middleDrumAddress <= 0;
		if (topLeftDrumAddress >= 357) topLeftDrumAddress <= 0;
		if (currentState == `RECORD || currentState == `PLAYBACK) begin
			if (inputDrawScreenPosX > 21 && inputDrawScreenPosX < 140 && inputDrawScreenPosY > 10 && inputDrawScreenPosY < 72) begin
				internalDrumkitBackgroundAddress <= internalDrumkitBackgroundAddress + 1;
				if (inputDrawScreenPosX > 21 && inputDrawScreenPosX < 43 && inputDrawScreenPosY > 10 && inputDrawScreenPosY < 28) topLeftDrumAddress <= topLeftDrumAddress + 1;
				if (inputDrawScreenPosX > 45 && inputDrawScreenPosX < 87 && inputDrawScreenPosY > 22 && inputDrawScreenPosY < 65) BassdrumAddress <= BassdrumAddress + 1;
				if (inputDrawScreenPosX > 77 && inputDrawScreenPosX < 100 && inputDrawScreenPosY > 10 && inputDrawScreenPosY < 20) middleDrumAddress <= middleDrumAddress + 1;
				if (inputDrawScreenPosX > 99 && inputDrawScreenPosX < 130 && inputDrawScreenPosY > 11 && inputDrawScreenPosY < 31) cymbelAddress <= cymbelAddress + 1;
			end
		end
	end

	always @(*) begin //was clk
		if (currentState == `RECORD || currentState == `PLAYBACK) begin
			if ((inputDrawScreenPosX > 21 && inputDrawScreenPosX < 140 && inputDrawScreenPosY > 10 && inputDrawScreenPosY < 72) && (currentState == `RECORD || currentState == `PLAYBACK)) begin
				outputColour <= dkbkColour;
				if (topLeftDrumColour && inputDrawScreenPosX > 22 && inputDrawScreenPosX < 44 && inputDrawScreenPosY > 10 && inputDrawScreenPosY < 28) outputColour <= ((inputStateStorage[`keyF] && currentState == `RECORD) || (retrievedNoteDataNote == 0 && playDrumNote)) ? 24'b11111111_11011000_00000000 : `COLOURBLACK;
				else if (bassDrumColour && inputDrawScreenPosX > 46 && inputDrawScreenPosX < 88 && inputDrawScreenPosY > 21 && inputDrawScreenPosY < 64) outputColour <= ((inputStateStorage[`keyG] && currentState == `RECORD) || (retrievedNoteDataNote == 1 && playDrumNote)) ? 24'b11111111_11011000_00000000 : `COLOURBLACK;
				else if (middleDrumColour && inputDrawScreenPosX > 78 && inputDrawScreenPosX < 101 && inputDrawScreenPosY > 10 && inputDrawScreenPosY < 20) outputColour <= ((inputStateStorage[`keyH] && currentState == `RECORD) || (retrievedNoteDataNote == 2 && playDrumNote)) ? 24'b11111111_11011000_00000000 : `COLOURBLACK;
				else if (cymbelColour && inputDrawScreenPosX > 100 && inputDrawScreenPosX < 131 && inputDrawScreenPosY > 12 && inputDrawScreenPosY < 32) outputColour <= ((inputStateStorage[`keyJ] && currentState == `RECORD) || (retrievedNoteDataNote == 3 && playDrumNote)) ? 24'b11111111_11011000_00000000 : `COLOURBLACK;
				
			end
			else if (inputDrawScreenPosY < 8'd92) begin
				outputColour <= `COLOURWHITE; //24'b10101010_00000000_01010101;
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