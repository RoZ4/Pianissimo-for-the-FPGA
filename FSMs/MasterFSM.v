`include "DefineMacros.vh"

module MasterFSM (clk, resetn, inputStateStorage, currentState, timerEnable);
	parameter key0 = 0, key1 = 1, key2 = 2, key3 = 3, key4 = 4, key5 = 5, key6 = 6, key7 = 7, key8 = 8, key9 = 9, keyTilda = 10, keyMinus = 11, keyEquals = 12, keyBackspace = 13, keyTab = 14, keyQ = 15, keyW = 16, keyE = 17, keyR = 18, keyT = 19, keyY = 20, keyU = 21, keyI = 22, keyO = 23, keyP = 24, keyLSquareBracket = 25, keyRSquareBracket = 26, keyBackslash = 27, keySpacebar = 28, noPress = 29;
	input clk, resetn;
	input [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage;
	output reg timerEnable;
	output reg [4:0] currentState;

	reg [4:0] nextState;

	always @(*) begin: nextStateLogic
		case (currentState)
			`STARTSCREEN: nextState <= inputStateStorage[keySpacebar] ? `RECORD : `STARTSCREEN;
			`RECORD: nextState <= inputStateStorage[keySpacebar] ? `PLAYBACK : `RECORD;
			`PLAYBACK: begin
				if (inputStateStorage[keyR]) nextState <= `RESTARTPLAYBACK;
				else if (inputStateStorage[keySpacebar]) nextState <= `RECORD;
				else nextState <= `PLAYBACK;
			end
			`RESTARTPLAYBACK: nextState <= `PLAYBACK;
			default: nextState <= `STARTSCREEN;
		endcase
	end

	always @(*) begin: Logic
		timerEnable <= 0;
		case(currentState)
			`STARTSCREEN: begin
				timerEnable <= 0;
			end
			`RECORD: begin
				timerEnable <= 1;
			end
			`PLAYBACK: begin
				timerEnable <= 1;
			end
			`RESTARTPLAYBACK: begin
				timerEnable <= 0;
			end
		endcase
	end

	always @(posedge clk) begin
		currentState <= nextState;
	end

endmodule