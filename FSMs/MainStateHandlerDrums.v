`include "../DefineMacros.vh"

module mainStateHandlerDrums(clk, reset, currentState, currentSubState, inputStateStorage, playDrumNote, donePlayingDrumNote, retrievedNoteData);
	input clk, reset;
	input [4:0] currentState;
	input donePlayingDrumNote;
	output reg playDrumNote = 0;
	input [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage; //! Stores the state of the inputs

	reg [30:0] currentNoteData; //! Data to write to memory
	reg [6:0] noteReadAddress = 0, noteWriteAddress = 0; //! Address to read from; Address to write to
	reg [6:0]  earliestEmptyCellinNoteStorage = 0; //! Earliest address that is empty
	reg [3:0] currentWriteNote = 0; //! Current note being written to

	reg memoryWriteEnable = 0, resetTimer = 0;

	output reg [3:0] currentSubState;
	reg [3:0] nextSubState;

	output [30:0] retrievedNoteData; //! Data read from memory || 4 bits - 24 notes, 29 bits - timeStart, 29bits-timeEnd
	reg [30:0] previousRetrievedNoteData = 0;
	reg [6:0] nextReadAddress = 0;


	DrumStorage drumRamStorage(clk, currentNoteData, noteReadAddress, noteWriteAddress, memoryWriteEnable, retrievedNoteData);
	wire [28:0] microSecondCounter;
	timeCounter timecounter(clk, resetTimer, 1'b1, microSecondCounter);
	defparam timecounter.MAXBITSINCOUNT = 29;


	always @(*) begin: nextSubstateLogic
		case(currentSubState)
			`subIDLE: begin // Initial state
				if (currentState == `RECORD && (inputStateStorage[`keySpacebar] && inputStateStorage[`keyReleasePulse])) nextSubState <= `subSTARTNOTERECORDING;
				else nextSubState <= `subIDLE;
			end
			`subSTARTNOTERECORDING: begin // Central state for RECORD state
				if (currentState == `RECORD) begin
					if (|inputStateStorage[`keyJ:`keyF]) nextSubState <= `subWRITESTARTOFNOTE;
					else nextSubState <= `subSTARTNOTERECORDING;
				end 
				else nextSubState <= `subRESETPLAYBACK;
			end
			`subWRITESTARTOFNOTE: nextSubState <= `subAWAITNOTEEND;
			`subAWAITNOTEEND: begin
				if (~|inputStateStorage[`keyJ:`keyF]) nextSubState <= `subSTARTNOTERECORDING;
				else nextSubState <= `subAWAITNOTEEND;
			end
			`subRESETPLAYBACK: begin
				if (retrievedNoteData != 0) nextSubState <= `subPLAYDRUMNOTE;
				else nextSubState <= `subRESETPLAYBACK;
			end
			`subPLAYDRUMNOTE: begin
				if (!retrievedNoteData) nextSubState <= `subRESETPLAYBACK;
				if (currentState == `RECORD) begin
					nextSubState <= `subCLEARMEMORY;
				end
				else nextSubState <= `subPLAYDRUMNOTE;
				end
			`subCLEARMEMORY: begin
				if (noteWriteAddress == earliestEmptyCellinNoteStorage) nextSubState <= `subSTARTNOTERECORDING;
				else nextSubState <= `subCLEARMEMORY;
			end
			default: nextSubState <= `subIDLE;
		endcase
	end
	
	always @(posedge clk) begin
		case(currentSubState)
			`subIDLE: begin 
				resetTimer <= 1;
			end
			`subSTARTNOTERECORDING: begin
				memoryWriteEnable <= 0;
				playDrumNote <= 0;
				noteWriteAddress <= 0;
				noteReadAddress <= 0;
			end
			`subWRITESTARTOFNOTE: begin
				resetTimer <= 0;
				if(inputStateStorage[`keyF]) currentNoteData <= {2'd0, microSecondCounter};
				else if(inputStateStorage[`keyG]) currentNoteData <= {2'd1, microSecondCounter};
				else if(inputStateStorage[`keyH]) currentNoteData <= {2'd3, microSecondCounter};
				else if(inputStateStorage[`keyJ]) currentNoteData <= {2'd4, microSecondCounter};
				
				
				noteWriteAddress <= earliestEmptyCellinNoteStorage;
				memoryWriteEnable <= 1;
				earliestEmptyCellinNoteStorage <= earliestEmptyCellinNoteStorage + 1;
			end
			`subAWAITNOTEEND: begin
				
			end
			`subRESETPLAYBACK: begin
				memoryWriteEnable <= 0;
				noteWriteAddress <= 0;
				noteReadAddress <= 0;
				nextReadAddress <= 0;
				previousRetrievedNoteData <= 0;
				playDrumNote <= 0;
				if (!resetTimer) resetTimer <= 1;
			end
			`subPLAYDRUMNOTE: begin
					
				resetTimer <= 0;
				if (retrievedNoteData[28:0] < microSecondCounter && retrievedNoteData[28:0] > previousRetrievedNoteData[28:0] && !donePlayingDrumNote) begin
					previousRetrievedNoteData <= retrievedNoteData;
					nextReadAddress <= noteReadAddress + 1;
					playDrumNote <= 1;
				end
				else if (retrievedNoteData[28:0] < microSecondCounter && donePlayingDrumNote) begin
					noteReadAddress <= nextReadAddress;
					playDrumNote <= 0;		
				end
			end
			`subCLEARMEMORY: begin
				memoryWriteEnable <= 1;
				currentNoteData <= 0;
				noteWriteAddress <= noteWriteAddress + 1;
			end
			default: begin
				resetTimer <= 1;
			end
		endcase
	end

	always@(posedge clk) begin
		if (reset) currentSubState <= `subIDLE;
		currentSubState <= nextSubState;
	end

endmodule

