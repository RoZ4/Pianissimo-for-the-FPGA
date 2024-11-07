module MasterFSM (clk, resetn, inputStateStorage, currentState, timerEnable);
	parameter key0 = 0, key1 = 1, key2 = 2, key3 = 3, key4 = 4, key5 = 5, key6 = 6, key7 = 7, key8 = 8, key9 = 9, keyTilda = 10, keyMinus = 11, keyEquals = 12, keyBackspace = 13, keyTab = 14, keyQ = 15, keyW = 16, keyE = 17, keyR = 18, keyT = 19, keyY = 20, keyU = 21, keyI = 22, keyO = 23, keyP = 24, keyLSquareBracket = 25, keyRSquareBracket = 26, keyBackslash = 27, keySpacebar = 28;
	input clk, resetn;
	input [27:0] inputStateStorage;
	output reg timerEnable;
	output reg [2:0] currentState;

	reg [2:0] nextState;

	localparam STARTSCREEN = 3'd0, RECORD = 3'd1, PLAYBACK = 3'd2, RESTARTPLAYBACK = 3'd3;
	always @(*) begin: nextStateLogic
		case (currentState)
			STARTSCREEN: nextState <= inputStateStorage[keySpacebar] ? RECORD : STARTSCREEN;
			RECORD: nextState <= inputStateStorage[keySpacebar] ? PLAYBACK : RECORD;
			PLAYBACK: begin
				if (inputStateStorage[keyR]) nextState <= RESTART;
				else if (inputStateStorage[keySpacebar]) nextState <= RECORD;
				else nextState <= PLAYBACK;
			end
			RESTARTPLAYBACK: nextState <= PLAYBACK;
			default: nextState <= IDLE;
		endcase
	end

	always @(*) begin: Logic
		timerEnable <= 0;
		case(currentState)
			STARTSCREEN: begin
				timerEnable <= 0;
			end
			RECORD: begin
				timerEnable <= 1;
			end
			PLAYBACK: begin
				timerEnable <= 0;
			end
			RESTARTPLAYBACK begin
				timerEnable <= 0;
			end
		endcase
	end

	always @(posedge clk) begin
		currentState <= nextState;
	end

endmodule