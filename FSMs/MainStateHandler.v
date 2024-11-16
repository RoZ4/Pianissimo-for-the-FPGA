`include "../DefineMacros.vh"

module mainStateHandler(clk, inputClearScreenDoneDrawing, outputScreenX, outputScreenY, currentState, currentSubState, inputStateStorage, outputColour, doneDrawing, retrievedNoteData);
	input clk, inputClearScreenDoneDrawing;
	input [4:0] currentState;
	input [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage; //! Stores the state of the inputs
	reg [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStoragePrevious; //! Stores the state of the inputs in the previous clock cycle
	output reg [7:0] outputScreenX, outputScreenY;
	output reg doneDrawing;
	output reg [23:0] outputColour;

	reg [12:0] writeToScreenAddress;

	reg [61:0] currentNoteData; //! Data to write to memory
	reg [6:0] noteReadAddress = 0, noteWriteAddress = 0, mostRecentCompleteWriteAddress = 0;
	reg [3:0] currentWriteNote = 0; //! Current note being written to

	reg foundMemoryToWriteTo; //! found an empty block of memory to write to during `subSCANMEMORYFORWRITESTART
	reg memoryWriteEnable = 0, resetTimer = 0;
	reg [8:0] linesDrawn = 0;
	output reg [3:0] currentSubState;
	reg [3:0] nextSubState;

	output [61:0] retrievedNoteData; //! Data read from memory || 4 bits - 24 notes, 29 bits - timeStart, 29bits-timeEnd
	


	NoteStorage noteRamStorage(clk, currentNoteData, noteReadAddress, noteWriteAddress, memoryWriteEnable, retrievedNoteData);
	wire [28:0] microSecondCounter;
	timeCounter timecounter(clk, resetTimer, 1'b1, microSecondCounter);
	defparam timecounter.MAXBITSINCOUNT = 29;


	always @(*) begin: nextSubstateLogic
		case(currentSubState)
			`subIDLE: begin 
				if (currentState == `RECORD && (inputStateStorage[`keySpacebar] && inputStateStorage['keyReleasePulse])) nextSubState <= `subSTARTNOTERECORDING;
				else nextSubState <= `subIDLE;
			end
			`subSTARTNOTERECORDING: begin
				if (currentState == `RECORD) begin
					if (inputStateStorage[`keyPressPulse]) nextSubState <= `subWRITESTARTOFNOTE;
					if (inputStateStorage[`keyReleasePulse]) nextSubState <= `subWRITEENDOFNOTE; 
					else nextSubState <= `subSTARTNOTERECORDING;
				end 
				else nextSubState <= `subRESETPLAYBACK;
			end
			`subWRITESTARTOFNOTE: nextSubState <= `subSCANMEMORYFORWRITESTART;
			`subSCANMEMORYFORWRITESTART: begin
				if (foundMemoryToWriteTo) nextSubState <= `STARTNOTERECORDING
				else nextSubState <= `subSCANMEMORYFORWRITESTART;
			end
			`subWRITEENDOFNOTE: nextSubState <= `subSCANMEMORYFORWRITEEND;
			`subSCANMEMORYFORWRITEEND: begin
				if (~|retrievedNoteData) nextSubState <= `STARTNOTERECORDING;
				else nextSubState <= `subSCANMEMORYFORWRITEEND;
			end
			`subRESETPLAYBACK: nextSubState <= `subDRAWNEWLINEOFNOTEBLOCK;
			`subDRAWNEWLINEOFNOTEBLOCK: begin
				if (linesDrawn != (retrievedNoteData[57:29] - retrievedNoteData[28:0]) >> 20) nextSubState <= `subDRAWNOTEBLOCK; 
				else nextSubState <= `subDRAWNEXTNOTEBLOCK; // )[28:20]) ? 
			end
			`subDRAWNOTEBLOCK: begin
				if (outputScreenX == 8'd160) nextSubState <= `subDRAWNEWLINENOFNOTEBLOCK;
				else nextSubState <= `subDONEDRAWING;
			end
			`subDRAWNEXTNOTEBLOCK: begin
				if (retrievedNoteData != 62'd0) nextSubState <= `subDRAWNEWLINEOFNOTEBLOCK;
				else nextSubState <= `subDONEDRAWING;
			end
			`subDONEDRAWING: begin
				if (currentState == `RESTARTPLAYBACK) nextSubState <= `subRESETPLAYBACK;
				else if (currentState == `RECORD) nextSubState <= `subSTARTNOTERECORDING;
				
				else if (inputClearScreenDoneDrawing) nextSubState <= `subDRAWNOTEBLOCK;
				else nextSubState <= `subDONEDRAWING;
			end
			default: nextSubState <= `subIDLE;
		endcase
	end
	
	always @(posedge clk) begin
		case(currentSubState)
			`subSTARTNOTERECORDING: begin
				resetTimer <= 0;
				memoryWriteEnable <= 0;
				foundMemoryToWriteTo <= 0;
			end
			`subWRITESTARTOFNOTE begin
				if(inputStateStorage[`keyTab] && !inputStateStoragePrevious[`keyTab]) begin currentNoteData <= {4'd0, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyTab] <= 1; end
				else if(inputStateStorage[`keyQ] && !inputStateStoragePrevious[`keyQ]) begin currentNoteData <= {4'd1, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyQ] <= 1; end
				else if(inputStateStorage[`keyW] && !inputStateStoragePrevious[`keyW]) begin currentNoteData <= {4'd2, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyW] <= 1; end
				else if(inputStateStorage[`keyE] && !inputStateStoragePrevious[`keyE]) begin currentNoteData <= {4'd3, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyE] <= 1; end
				else if(inputStateStorage[`keyR] && !inputStateStoragePrevious[`keyR]) begin currentNoteData <= {4'd4, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyR] <= 1; end
				else if(inputStateStorage[`keyT] && !inputStateStoragePrevious[`keyT]) begin currentNoteData <= {4'd5, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyT] <= 1; end
				else if(inputStateStorage[`keyY] && !inputStateStoragePrevious[`keyY]) begin currentNoteData <= {4'd6, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyY] <= 1; end
				else if(inputStateStorage[`keyU] && !inputStateStoragePrevious[`keyU]) begin currentNoteData <= {4'd7, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyU] <= 1; end
				else if(inputStateStorage[`keyI] && !inputStateStoragePrevious[`keyI]) begin currentNoteData <= {4'd8, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyI] <= 1; end
				else if(inputStateStorage[`keyO] && !inputStateStoragePrevious[`keyO]) begin currentNoteData <= {4'd9, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyO] <= 1; end
				else if(inputStateStorage[`keyP] && !inputStateStoragePrevious[`keyP]) begin currentNoteData <= {4'd10, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyP] <= 1; end
				else if(inputStateStorage[`keyLSquareBracket] && !inputStateStoragePrevious[`keyLSquareBracket]) begin currentNoteData <= {4'd11, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyLSquareBracket] <= 1; end
				else if(inputStateStorage[`keyRSquareBracket] && !inputStateStoragePrevious[`keyRSquareBracket]) begin currentNoteData <= {4'd12, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyRSquareBracket] <= 1; end
				else if(inputStateStorage[`keyBackslash] && !inputStateStoragePrevious[`keyBackslash]) begin currentNoteData <= {4'd13, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyBackslash] <= 1; end

				else if(inputStateStorage[`key1] && !inputStateStoragePrevious[`key1]) begin currentNoteData <= {4'd14, microSecondCounter, 29'b0}; inputStateStoragePrevious[`key1] <= 1; end
				else if(inputStateStorage[`key2] && !inputStateStoragePrevious[`key2]) begin currentNoteData <= {4'd15, microSecondCounter, 29'b0}; inputStateStoragePrevious[`key2] <= 1; end
				else if(inputStateStorage[`key4] && !inputStateStoragePrevious[`key4]) begin currentNoteData <= {4'd16, microSecondCounter, 29'b0}; inputStateStoragePrevious[`key4] <= 1; end
				else if(inputStateStorage[`key5] && !inputStateStoragePrevious[`key5]) begin currentNoteData <= {4'd17, microSecondCounter, 29'b0}; inputStateStoragePrevious[`key5] <= 1; end
				else if(inputStateStorage[`key6] && !inputStateStoragePrevious[`key6]) begin currentNoteData <= {4'd18, microSecondCounter, 29'b0}; inputStateStoragePrevious[`key6] <= 1; end
				else if(inputStateStorage[`key8] && !inputStateStoragePrevious[`key8]) begin currentNoteData <= {4'd19, microSecondCounter, 29'b0}; inputStateStoragePrevious[`key8] <= 1; end
				else if(inputStateStorage[`key9] && !inputStateStoragePrevious[`key9]) begin currentNoteData <= {4'd20, microSecondCounter, 29'b0}; inputStateStoragePrevious[`key9] <= 1; end
				else if(inputStateStorage[`keyMinus] && !inputStateStoragePrevious[`keyMinus]) begin currentNoteData <= {4'd21, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyMinus] <= 1; end
				else if(inputStateStorage[`keyEquals] && !inputStateStoragePrevious[`keyEquals]) begin currentNoteData <= {4'd22, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyEquals] <= 1; end
				else if(inputStateStorage[`keyBackspace] && !inputStateStoragePrevious[`keyBackspace]) begin currentNoteData <= {4'd23, microSecondCounter, 29'b0}; inputStateStoragePrevious[`keyBackspace] <= 1; end
				
				noteReadAddress <= mostRecentCompleteWriteAddress;
				
			end
			`subSCANMEMORYFORWRITESTART: begin
				if (~|retrievedNoteData) begin
					noteWriteAddress <= noteReadAddress;
					memoryWriteEnable <= 1;
					foundMemoryToWriteTo <= 1;
				end
				else noteReadAddress <= noteReadAddress + 1;
			end
			`subWRITEENDOFNOTE: begin
				if(!inputStateStorage[`keyTab] && inputStateStoragePrevious[`keyTab]) begin inputStateStoragePrevious[`keyTab] <= 0; currentWriteNote <= 4'd0; end
				else if(!inputStateStorage[`keyQ] && inputStateStoragePrevious[`keyQ]) begin inputStateStoragePrevious[`keyQ] <= 0; currentWriteNote <= 4'd1; end
				else if(!inputStateStorage[`keyW] && inputStateStoragePrevious[`keyW]) begin inputStateStoragePrevious[`keyW] <= 0; currentWriteNote <= 4'd2; end
				else if(!inputStateStorage[`keyE] && inputStateStoragePrevious[`keyE]) begin inputStateStoragePrevious[`keyE] <= 0; currentWriteNote <= 4'd3; end
				else if(!inputStateStorage[`keyR] && inputStateStoragePrevious[`keyR]) begin inputStateStoragePrevious[`keyR] <= 0; currentWriteNote <= 4'd4; end
				else if(!inputStateStorage[`keyT] && inputStateStoragePrevious[`keyT]) begin inputStateStoragePrevious[`keyT] <= 0; currentWriteNote <= 4'd5; end
				else if(!inputStateStorage[`keyY] && inputStateStoragePrevious[`keyY]) begin inputStateStoragePrevious[`keyY] <= 0; currentWriteNote <= 4'd6; end
				else if(!inputStateStorage[`keyU] && inputStateStoragePrevious[`keyU]) begin inputStateStoragePrevious[`keyU] <= 0; currentWriteNote <= 4'd7; end
				else if(!inputStateStorage[`keyI] && inputStateStoragePrevious[`keyI]) begin inputStateStoragePrevious[`keyI] <= 0; currentWriteNote <= 4'd8; end
				else if(!inputStateStorage[`keyO] && inputStateStoragePrevious[`keyO]) begin inputStateStoragePrevious[`keyO] <= 0; currentWriteNote <= 4'd9; end
				else if(!inputStateStorage[`keyP] && inputStateStoragePrevious[`keyP]) begin inputStateStoragePrevious[`keyP] <= 0; currentWriteNote <= 4'd10; end
				else if(!inputStateStorage[`keyLSquareBracket] && inputStateStoragePrevious[`keyLSquareBracket]) begin inputStateStoragePrevious[`keyLSquareBracket] <= 0; currentWriteNote <= 4'd11; end
				else if(!inputStateStorage[`keyRSquareBracket] && inputStateStoragePrevious[`keyRSquareBracket]) begin inputStateStoragePrevious[`keyRSquareBracket] <= 0; currentWriteNote <= 4'd12; end
				else if(!inputStateStorage[`keyBackslash] && inputStateStoragePrevious[`keyBackslash]) begin inputStateStoragePrevious[`keyBackslash] <= 0; currentWriteNote <= 4'd13; end

				else if(!inputStateStorage[`key1] && inputStateStoragePrevious[`key1]) begin inputStateStoragePrevious[`key1] <= 0; currentWriteNote <= 4'd14; end
				else if(!inputStateStorage[`key2] && inputStateStoragePrevious[`key2]) begin inputStateStoragePrevious[`key2] <= 0; currentWriteNote <= 4'd15; end
				else if(!inputStateStorage[`key4] && inputStateStoragePrevious[`key4]) begin inputStateStoragePrevious[`key4] <= 0; currentWriteNote <= 4'd16; end
				else if(!inputStateStorage[`key5] && inputStateStoragePrevious[`key5]) begin inputStateStoragePrevious[`key5] <= 0; currentWriteNote <= 4'd17; end
				else if(!inputStateStorage[`key6] && inputStateStoragePrevious[`key6]) begin inputStateStoragePrevious[`key6] <= 0; currentWriteNote <= 4'd18; end
				else if(!inputStateStorage[`key8] && inputStateStoragePrevious[`key8]) begin inputStateStoragePrevious[`key8] <= 0; currentWriteNote <= 4'd19; end
				else if(!inputStateStorage[`key9] && inputStateStoragePrevious[`key9]) begin inputStateStoragePrevious[`key9] <= 0; currentWriteNote <= 4'd20; end
				else if(!inputStateStorage[`keyMinus] && inputStateStoragePrevious[`keyMinus]) begin inputStateStoragePrevious[`keyMinus] <= 0; currentWriteNote <= 4'd21; end
				else if(!inputStateStorage[`keyEquals] && inputStateStoragePrevious[`keyEquals]) begin inputStateStoragePrevious[`keyEquals] <= 0; currentWriteNote <= 4'd22; end
				else if(!inputStateStorage[`keyBackspace] && inputStateStoragePrevious[`keyBackspace]) begin inputStateStoragePrevious[`keyBackspace] <= 0; currentWriteNote <= 4'd23; end
				
				noteReadAddress	<= mostRecentCompleteWriteAddress;
			end
			`subSCANMEMORYFORWRITEEND: begin
				if (~|retrievedNoteData[28:0] && retrievedNoteData[61:58] == currentWriteNote) begin
					noteWriteAddress <= noteReadAddress;
					memoryWriteEnable <= 1;
					currentNoteData <= {retrievedNoteData, microSecondCounter};
					mostRecentCompleteWriteAddress <= noteReadAddress;
				end
				else noteReadAddress <= noteReadAddress + 1;
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

