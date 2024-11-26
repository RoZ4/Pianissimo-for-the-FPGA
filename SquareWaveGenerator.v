`include "../DefineMacros.vh"

module squareWaveGeneratorPiano(clk, inputStateStorage, outputSound);
	
	input clk;
	input [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage;
	output reg [31:0] outputSound;

	wire signed [2:0] c4Wave, d4Wave, e4Wave, f4Wave, g4Wave, a4Wave, b4Wave, c5Wave, d5Wave, e5Wave, f5Wave, g5Wave, a5Wave, b5Wave, cS4Wave, dS4Wave, fS4Wave, gS4Wave, aS4Wave, cS5Wave, dS5Wave, fS5Wave, gS5Wave, aS5Wave;
	wire signed [6:0] addingWire;

	delayCounter delayc4(clk, inputStateStorage[`keyTab], 17'd95555, c4Wave);
	delayCounter delayd4(clk, inputStateStorage[`keyQ], 17'd85132, d4Wave);
	delayCounter delaye4(clk, inputStateStorage[`keyW], 17'd75842, e4Wave);
	delayCounter delayf4(clk, inputStateStorage[`keyE], 17'd71586, f4Wave);
	delayCounter delayg4(clk, inputStateStorage[`keyR], 17'd63775, g4Wave);
	delayCounter delaya4(clk, inputStateStorage[`keyT], 17'd56818, a4Wave);
	delayCounter delayb4(clk, inputStateStorage[`keyY], 17'd50620, b4Wave);
	delayCounter delayc5(clk, inputStateStorage[`keyU], 17'd47778, c5Wave);
	delayCounter delayd5(clk, inputStateStorage[`keyI], 17'd42568, d5Wave);
	delayCounter delaye5(clk, inputStateStorage[`keyO], 17'd37922, e5Wave);
	delayCounter delayf5(clk, inputStateStorage[`keyP], 17'd35793, f5Wave);
	delayCounter delayg5(clk, inputStateStorage[`keyLSquareBracket], 17'd31888, g5Wave);
	delayCounter delaya5(clk, inputStateStorage[`keyRSquareBracket], 17'd28409, a5Wave);
	delayCounter delayb5(clk, inputStateStorage[`keyBackslash], 17'd25309, b5Wave);
	delayCounter delaycS4(clk, inputStateStorage[`key1], 17'd90194, cS4Wave);
	delayCounter delaydS4(clk, inputStateStorage[`key2], 17'd80352, dS4Wave);
	delayCounter delayfS4(clk, inputStateStorage[`key4], 17'd67569, fS4Wave);
	delayCounter delaygS4(clk, inputStateStorage[`key5], 17'd60197, gS4Wave);
	delayCounter delayaS4(clk, inputStateStorage[`key6], 17'd53630, aS4Wave);
	delayCounter delaycS5(clk, inputStateStorage[`key8], 17'd45096, cS5Wave);
	delayCounter delaydS5(clk, inputStateStorage[`key9], 17'd40177, dS5Wave);
	delayCounter delayfS5(clk, inputStateStorage[`keyMinus], 17'd33784, fS5Wave);
	delayCounter delaygS5(clk, inputStateStorage[`keyEquals], 17'd30098, gS5Wave);
	delayCounter delayaS5(clk, inputStateStorage[`keyBackspace], 17'd26814, aS5Wave);

	assign addingWire = c4Wave + d4Wave + e4Wave + f4Wave + g4Wave + a4Wave + b4Wave + c5Wave + d5Wave + e5Wave + f5Wave + g5Wave + a5Wave + b5Wave + cS4Wave + dS4Wave + fS4Wave + gS4Wave + aS4Wave + cS5Wave + dS5Wave + fS5Wave + gS5Wave + aS5Wave;
	always @(*) begin
		if (|inputStateStorage[`keyBackslash:0]) begin
			if (addingWire > 0) outputSound <= 32'd100_000_000;
			else if (addingWire < 0) outputSound <= -32'd100_000_000;
			else outputSound = 0;
		end
		else outputSound = 0;
	end
endmodule

module squareWaveGeneratorDrums(clk, retrievedNoteDataNote, currentState, inputStateStorage, playDrumNote, outputSound);
	
	input clk;
	input playDrumNote;
	input [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage;
	input [2:0] retrievedNoteDataNote;
	input [4:0] currentState;
	output reg [31:0] outputSound;

	wire signed [2:0] bassWave, middleDrumWave, topLeftDrumWave, cymbelWave;
	wire signed [6:0] addingWire;

	delayCounterDrums delayTopLeft(clk, (retrievedNoteDataNote == 0 && currentState == `PLAYBACK ) || inputStateStorage[`keyF], 19'd125000, topLeftDrumWave); // (1/f)*(50_000_000/2)
	delayCounterDrums delayBass(clk, (retrievedNoteDataNote == 1 && currentState == `PLAYBACK ) || inputStateStorage[`keyG], 19'd312500, bassWave);
	delayCounterDrums delayMiddle(clk, (retrievedNoteDataNote == 2 && currentState == `PLAYBACK ) || inputStateStorage[`keyH], 19'd50_000, middleDrumWave);
	delayCounterDrums delayCymbel(clk, (retrievedNoteDataNote == 3 && currentState == `PLAYBACK ) || inputStateStorage[`keyJ], 19'd5000, cymbelWave);

	assign addingWire = bassWave + middleDrumWave + topLeftDrumWave + cymbelWave;
	always @(*) begin
		if (playDrumNote || inputStateStorage[`keyJ:`keyF]) begin
			if (addingWire > 0) outputSound <= 32'd100_000_000;
			else if (addingWire < 0) outputSound <= -32'd100_000_000;
			else outputSound = 0;
		end
		else outputSound = 0;
	end
endmodule

module delayCounterDrums(clk, enable, maxDelay, highOrLow);
	input clk, enable;
	input [18:0] maxDelay;
	output signed [2:0] highOrLow;

	reg [18:0] delay_cnt = 0;
	reg snd = 0;

	always @(posedge clk) begin
		if(delay_cnt == maxDelay) begin
			delay_cnt <= 0;
			snd <= !snd;
		end else delay_cnt <= delay_cnt + 1;
	end

	assign highOrLow = enable ? (snd ? 1'b1 : -1'b1) : 0;
endmodule

module delayCounter(clk, enable, maxDelay, highOrLow);
	input clk, enable;
	input [16:0] maxDelay;
	output signed [2:0] highOrLow;

	reg [16:0] delay_cnt = 0;
	reg snd = 0;

	always @(posedge clk) begin
		if(delay_cnt == maxDelay) begin
			delay_cnt <= 0;
			snd <= !snd;
		end else delay_cnt <= delay_cnt + 1;
	end

	assign highOrLow = enable ? (snd ? 1'b1 : -1'b1) : 0;
endmodule