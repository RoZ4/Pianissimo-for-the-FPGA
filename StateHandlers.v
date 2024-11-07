module startScreenHandler(clk, inputGetAtAddress, outputColour);
	input clk;
	input [14:0] inputGetAtAddress;
	output [23:0] outputColour;

	StartScreen startScreenMemoryController (inputGetAtAddress, clk, outputColour);
endmodule

module recordStateHandler(clk, screenX, screenY, inputStateStorage, outputColour);
	input clk;
	input [8:0] screenX, screenY;
	input [28:0] inputStateStorage;
	output [23:0] outputColour;

	reg [32:0] currentNoteData;
	reg [6:0] noteReadAddress, noteWriteAddress;
	reg memoryWriteEnable, timerEnable;
	initial memoryWriteEnable = 0;
	wire [32:0] retrievedNoteData;
	wire [28:0] microSecondCounter;


	NoteStorage noteRamStorage(clk, currentNoteData, noteReadAddress, noteWriteAddress, memoryWriteEnable, retrievedNoteData);
	timeCounter timecounter(clk, timerEnable, microSecondCounter);
	
	parameter key0 = 0, key1 = 1, key2 = 2, key3 = 3, key4 = 4, key5 = 5, key6 = 6, key7 = 7, key8 = 8, key9 = 9, keyTilda = 10, keyMinus = 11, keyEquals = 12, keyBackspace = 13, keyTab = 14, keyQ = 15, keyW = 16, keyE = 17, keyR = 18, keyT = 19, keyY = 20, keyU = 21, keyI = 22, keyO = 23, keyP = 24, keyLSquareBracket = 25, keyRSquareBracket = 26, keyBackslash = 27, keySpacebar = 28;
	always @(posedge clk) begin
		if(inputStateStorage[key0]) 


endmodule