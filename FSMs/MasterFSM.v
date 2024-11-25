`include "../DefineMacros.vh"

module MasterFSM (clk, resetn, inputStateStorage, currentState, timerEnable);
	input clk, resetn;
	input [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage;
	output reg timerEnable;
	output reg [4:0] currentState;
	initial currentState = 5'd0;
	reg [4:0] nextState;
	initial nextState = 5'd0;

	always @(*) begin: nextStateLogic
		case (currentState)
			`STARTSCREEN: begin
				if (inputStateStorage[`keySpacebar]) nextState = `RECORD;
				else nextState = `STARTSCREEN;
			end
			`RECORD: begin
				if (inputStateStorage[`keyEnter]) nextState = `PLAYBACK;
				else nextState = `RECORD;
			end
			`PLAYBACK: begin
				if (inputStateStorage[`keyR]) nextState = `RESTARTPLAYBACK;
				else if (inputStateStorage[`keySpacebar]) nextState = `RECORD;
				else nextState = `PLAYBACK;
			end
			`RESTARTPLAYBACK: nextState = `PLAYBACK;
			default: nextState = `STARTSCREEN;
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
			default: timerEnable <= 0;
		endcase
	end

	always @(posedge clk) begin
		if (resetn) currentState <= `STARTSCREEN;
		else currentState <= nextState;
	end

endmodule