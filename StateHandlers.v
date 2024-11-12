`include "DefineMacros.vh"

module startScreenHandler(clk, inputGetAtAddress, outputColour);
	input clk;
	input [14:0] inputGetAtAddress;
	output [23:0] outputColour;

	StartScreen startScreenMemoryController (inputGetAtAddress, clk, outputColour);
endmodule

module mainStateHandler(clk, inputClearScreenDoneDrawing, outputScreenX, outputScreenY, currentState, inputStateStorage, outputColour, doneDrawing);
	input clk, inputClearScreenDoneDrawing;
	input [4:0] currentState;
	input [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage;
	output reg [7:0] outputScreenX, outputScreenY;
	output reg doneDrawing;
	output reg [23:0] outputColour;

	reg [61:0] currentNoteData;
	reg [6:0] noteReadAddress, noteWriteAddress;
	reg memoryWriteEnable, resetTimer;
	reg [8:0] linesDrawn;
	reg [2:0] currentSubState, nextSubState;
	initial memoryWriteEnable = 0;
	initial noteReadAddress = 0;
	initial noteWriteAddress = 0;

	wire [61:0] retrievedNoteData;
	wire [28:0] microSecondCounter;


	NoteStorage noteRamStorage(clk, currentNoteData, noteReadAddress, noteWriteAddress, memoryWriteEnable, retrievedNoteData);
	timeCounter timecounter(clk, resetTimer, 1'b1, microSecondCounter);

	localparam STARTNOTERECORDING = 3'd0, WRITETOMEMORY = 3'd1, RESETPLAYBACK = 3'd2, DRAWNOTEBLOCK = 3'd3, DRAWNEWLINEOFNOTEBLOCK = 3'd4, DRAWNEXTNOTEBLOCK = 3'd5, DONEDRAWING = 3'd6, IDLE = 3'd7;
	always@(*) begin: subStates
		case(currentSubState)
			IDLE: nextSubState <= (currentState == `RECORD ? STARTNOTERECORDING : IDLE);
			STARTNOTERECORDING: nextSubState <= currentState == `RECORD ? (inputStateStorage[`noPress] ? WRITETOMEMORY : STARTNOTERECORDING) : RESETPLAYBACK;
			WRITETOMEMORY: nextSubState <= STARTNOTERECORDING;
			RESETPLAYBACK: nextSubState <= DRAWNEWLINEOFNOTEBLOCK;
			DRAWNEWLINEOFNOTEBLOCK: nextSubState <= (linesDrawn != (retrievedNoteData[57:29] - retrievedNoteData[28:0]) >> 20) ? DRAWNOTEBLOCK : DRAWNEXTNOTEBLOCK; // )[28:20]) ? 
			DRAWNOTEBLOCK: nextSubState <= outputScreenX == 8'd160 ? DRAWNEWLINEOFNOTEBLOCK : DRAWNOTEBLOCK;
			DRAWNEXTNOTEBLOCK: nextSubState <= retrievedNoteData != 62'd0 ? DRAWNEWLINEOFNOTEBLOCK : DONEDRAWING;
			DONEDRAWING: begin
				if (currentState == `RESTARTPLAYBACK) begin
					nextSubState <= RESETPLAYBACK;
				end
				else if (currentState == `RECORD) begin
					nextSubState <= STARTNOTERECORDING;
				end
				else begin
					nextSubState <= inputClearScreenDoneDrawing ? DRAWNOTEBLOCK : DONEDRAWING;
				end
			end
			default: nextSubState <= STARTNOTERECORDING;
		endcase
	end
	
	parameter key0 = 0, key1 = 1, key2 = 2, key3 = 3, key4 = 4, key5 = 5, key6 = 6, key7 = 7, key8 = 8, key9 = 9, keyTilda = 10, keyMinus = 11, keyEquals = 12, keyBackspace = 13, keyTab = 14, keyQ = 15, keyW = 16, keyE = 17, keyR = 18, keyT = 19, keyY = 20, keyU = 21, keyI = 22, keyO = 23, keyP = 24, keyLSquareBracket = 25, keyRSquareBracket = 26, keyBackslash = 27, keySpacebar = 28, noPress = 29;
	always @(posedge clk) begin
		case(currentSubState)
			STARTNOTERECORDING: begin
				resetTimer <= 0;
				memoryWriteEnable <= 0;
				if(inputStateStorage[keyTab]) currentNoteData <= {4'd0, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyQ]) currentNoteData <= {4'd1, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyW]) currentNoteData <= {4'd2, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyE]) currentNoteData <= {4'd3, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyR]) currentNoteData <= {4'd4, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyT]) currentNoteData <= {4'd5, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyY]) currentNoteData <= {4'd6, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyU]) currentNoteData <= {4'd7, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyI]) currentNoteData <= {4'd8, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyO]) currentNoteData <= {4'd9, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyP]) currentNoteData <= {4'd10, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyLSquareBracket]) currentNoteData <= {4'd11, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyRSquareBracket]) currentNoteData <= {4'd12, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyBackslash]) currentNoteData <= {4'd13, microSecondCounter, 29'b0};

				else if(inputStateStorage[key1]) currentNoteData <= {4'd14, microSecondCounter, 29'b0};
				else if(inputStateStorage[key2]) currentNoteData <= {4'd15, microSecondCounter, 29'b0};
				else if(inputStateStorage[key4]) currentNoteData <= {4'd16, microSecondCounter, 29'b0};
				else if(inputStateStorage[key5]) currentNoteData <= {4'd17, microSecondCounter, 29'b0};
				else if(inputStateStorage[key6]) currentNoteData <= {4'd18, microSecondCounter, 29'b0};
				else if(inputStateStorage[key8]) currentNoteData <= {4'd19, microSecondCounter, 29'b0};
				else if(inputStateStorage[key9]) currentNoteData <= {4'd20, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyMinus]) currentNoteData <= {4'd21, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyEquals]) currentNoteData <= {4'd22, microSecondCounter, 29'b0};
				else if(inputStateStorage[keyBackspace]) currentNoteData <= {4'd23, microSecondCounter, 29'b0};
			end
			WRITETOMEMORY: begin
				// Concatenate when user stops pressing key
				memoryWriteEnable <= 1;
				currentNoteData <= {currentNoteData, microSecondCounter};
				noteWriteAddress <= noteWriteAddress + 1;
			end
			RESETPLAYBACK: begin
				memoryWriteEnable <= 0;
				noteWriteAddress <= 0;
				noteReadAddress <= 0;
				doneDrawing <= 0;
				if (!resetTimer) resetTimer <= 1;
			end
			DRAWNOTEBLOCK: begin
				if (resetTimer) begin 
					resetTimer <= 0;
				end
				outputColour <= 24'b0000_0000_1111; 
				outputScreenX <= outputScreenX + 1;
			end
			DRAWNEWLINEOFNOTEBLOCK: begin
				case(retrievedNoteData[61:58])
					4'd0: outputScreenX <= 8'd0;
					4'd1: outputScreenX <= 8'd11;
					4'd2: outputScreenX <= 8'd22;
					4'd3: outputScreenX <= 8'd34;
					4'd4: outputScreenX <= 8'd46;
					4'd5: outputScreenX <= 8'd57;
					4'd6: outputScreenX <= 8'd69;
					4'd7: outputScreenX <= 8'd81;
					4'd8: outputScreenX <= 8'd93;
					4'd9: outputScreenX <= 8'd104;
					4'd10: outputScreenX <= 8'd116;
					4'd11: outputScreenX <= 8'd128;
					4'd12: outputScreenX <= 8'd139;
					4'd13: outputScreenX <= 8'd151;
					
					4'd14: outputScreenX <= 8'd5;
					4'd15: outputScreenX <= 8'd19;
					4'd16: outputScreenX <= 8'd40;
					4'd17: outputScreenX <= 8'd53;
					4'd18: outputScreenX <= 8'd66;
					4'd19: outputScreenX <= 8'd87;
					4'd20: outputScreenX <= 8'd101;
					4'd21: outputScreenX <= 8'd122;
					4'd22: outputScreenX <= 8'd135;
					4'd23: outputScreenX <= 8'd148;
					default: outputScreenX <= 8'd0;
				endcase
				//[8:0] 
				linesDrawn <= linesDrawn + 1;
				outputScreenY <= 92-((retrievedNoteData[57:29]-microSecondCounter) >> 20); // )[28:20]); trucate to about 1 second, subtract from working screen height
			end
		DRAWNEXTNOTEBLOCK: begin
			linesDrawn <= 0;
			noteReadAddress <= noteReadAddress + 1;
		end
		DONEDRAWING: begin
			doneDrawing <= 1;
			noteReadAddress <= 0;
			outputScreenX <= 0;
			outputScreenY <= 0;
		end
		default: begin
			resetTimer <= 1;
		end
		endcase
	end

	always@(posedge clk) begin
		currentSubState <= nextSubState;
	end

endmodule

