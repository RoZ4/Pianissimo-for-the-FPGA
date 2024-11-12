`include "DefineMacros.vh"

module PianissimoFinalProject (CLOCK_50,
                	VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK,
					PS2_CLK, PS2_DAT, KEY, LEDR
					);
	

	input [0:0] KEY;
	output [9:0] LEDR;
	//--------------------- VGA IO ------------------------
	input			CLOCK_50;				//	50 MHz	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;
	//-----------------------------------------------------

	//--------------------- PS2 IO ------------------------
	inout PS2_CLK;							// Connected to DE1_SOC board pins
	inout PS2_DAT;							// Connected to DE1_SOC board pins

	wire [7:0] commandToSend;				// 8-bit command to send
	wire sendCommand;						// Initiate send of command stored in {commandToSend}
	wire commandWasSent;					// Confirmation of command send
	wire errorCommunicationTimedOut;		// Unable to communicate with PS2 device

	wire [7:0] recievedData;				// Data recieved from PS2 Device
	wire recievedNewData;					// Driven high for one clock cycle when new data is recieved

	//- - - - - - PS2 Take Inputs From Keyboard - - - - - -
	// Define storage elements for state of keys
	reg [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage;
	PS2_Controller ps2 (CLOCK_50, ~KEY[0], commandToSend, sendCommand, PS2_CLK, PS2_DAT, commandWasSent, 
					    errorCommunicationTimedOut, recievedData, recievedNewData);
	integer i;
	always @(posedge recievedNewData) begin: PS2Controller
		if (recievedData == 8'hf0) begin
			for (i = 0; i < 29; i = i+1) begin
				inputStateStorage[i] = 1'b0;
			end
		end
		case (recievedData)
			8'h0E: inputStateStorage[`keyTilda] <= 1'b1;
			8'h16: inputStateStorage[`key1] <= 1'b1;
			8'h1E: inputStateStorage[`key2] <= 1'b1;
			8'h26: inputStateStorage[`key3] <= 1'b1;
			8'h25: inputStateStorage[`key4] <= 1'b1;
			8'h2E: inputStateStorage[`key5] <= 1'b1;
			8'h36: inputStateStorage[`key6] <= 1'b1;
			8'h3D: inputStateStorage[`key7] <= 1'b1;
			8'h3E: inputStateStorage[`key8] <= 1'b1;
			8'h46: inputStateStorage[`key9] <= 1'b1;
			8'h45: inputStateStorage[`key0] <= 1'b1;
			8'h4E: inputStateStorage[`keyMinus] <= 1'b1;
			8'h55: inputStateStorage[`keyEquals] <= 1'b1;
			8'h66: inputStateStorage[`keyBackspace] <= 1'b1;

			8'h0D: inputStateStorage[`keyTab] <= 1'b1;
			8'h15: inputStateStorage[`keyQ] <= 1'b1;
			8'h1D: inputStateStorage[`keyW] <= 1'b1;
			8'h24: inputStateStorage[`keyE] <= 1'b1;
			8'h2D: inputStateStorage[`keyR] <= 1'b1;
			8'h2C: inputStateStorage[`keyT] <= 1'b1;
			8'h35: inputStateStorage[`keyY] <= 1'b1;
			8'h3C: inputStateStorage[`keyU] <= 1'b1;
			8'h43: inputStateStorage[`keyI] <= 1'b1;
			8'h44: inputStateStorage[`keyO] <= 1'b1;
			8'h4D: inputStateStorage[`keyP] <= 1'b1;
			8'h54: inputStateStorage[`keyLSquareBracket] <= 1'b1;
			8'h5B: inputStateStorage[`keyRSquareBracket] <= 1'b1;
			8'h5D: inputStateStorage[`keyBackslash] <= 1'b1;

			8'h29: inputStateStorage[`keySpacebar] <= 1'b1;		
		endcase
	end
	//-----------------------------------------------------

	// -------------------- STATES ------------------------
	wire [4:0] currentState; // Connects to current state in MasterFSM.v
	// ----------------------------------------------------


    reg [23:0] colour;
    reg [7:0] screenX, screenY;
	reg plotWriteEnable; 					// Feeds .plot() on the VGA adapter; tells when to draw pixels to screen
	wire [7:0] backgroundX, backgroundY; 	// Coordinates on .mif background texture
	reg [14:0] rdAddress;			 		// Pointer to address for individual pixels in memory
	wire [14:0] nextAddress;				// Connected to the drawing module; stores the next address with the next pixel colour
	wire masterResetAddress;				// Signal to reset address pointer to 0
	wire masterClearScreen;

    wire resetn;
	assign resetn = ~KEY[0]; // Reset on key 0 downpress

	vga_adapter VGA (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .colour(colour),
        .x(screenX),
        .y(screenY),
        .plot(plotWriteEnable),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
        defparam VGA.BACKGROUND_IMAGE = "./images/StartScreen.mif";
	
	wire drawScannerDoneDrawing, noteBlocksDoneDrawing;
	wire [23:0] resetScreenColour;
	drawToScreen drawScanner(CLOCK_50, nextAddress, drawScannerDoneDrawing, backgroundX, backgroundY);
	resetScreen screenReseter(CLOCK_50, noteBlocksDoneDrawing, backgroundX, backgroundY, resetScreenColour);

	wire randomTimerEnable;
	MasterFSM masterFSM(CLOCK_50, resetn, inputStateStorage, currentState, randomTimerEnable);

	wire [23:0] startScreenColour, mainStateColour;
	startScreenHandler startScreenController(CLOCK_50, nextAddress, startScreenColour);

	wire [7:0] mainStateOutputScreenX, mainStateOutputScreenY;
	mainStateHandler mainStateController(CLOCK_50, drawScannerDoneDrawing, mainStateOutputScreenX, mainStateOutputScreenY, currentState, inputStateStorage, mainStateColour, noteBlocksDoneDrawing);


	always @* begin
		if (masterResetAddress) begin
			rdAddress <= 0;
		end
		else begin
			rdAddress <= nextAddress;

			if (currentState == `STARTSCREEN) begin
				plotWriteEnable <= 1;
				colour <= startScreenColour;
				screenX <= backgroundX;
				screenY <= backgroundY;
			end

			else if (currentState == `RECORD) begin
				if (noteBlocksDoneDrawing)
				plotWriteEnable <= 1;
				screenX <= backgroundX;
				screenY <= backgroundY;
			end
			else if (currentState == `PLAYBACK) begin
				if (noteBlocksDoneDrawing & !drawScannerDoneDrawing) begin
					colour <= resetScreenColour;
				end
				else begin
					colour <= mainStateColour;
				end

				plotWriteEnable <= 1;
				screenX <= mainStateOutputScreenX;
				screenY <= mainStateOutputScreenY;
			end
		end
	end

	assign LEDR[0] = currentState == `STARTSCREEN;
	assign LEDR[1] = currentState == `RECORD;
	assign LEDR[2] = currentState == `PLAYBACK;

	wire [20:0] drawScannerCount;
	upLoopCounterVariableBits drawScannerCounter (CLOCK_50, resetn, drawScannerDoneDrawing, 20'd100, drawScannerCount);
	defparam drawScannerCounter.outputBits = 20;
	assign LEDR[9] = ~|drawScannerCount;
	assign LEDR[8] = inputStateStorage[`keySpacebar];
	
endmodule