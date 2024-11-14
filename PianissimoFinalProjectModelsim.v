`include "DefineMacros.vh"


module PianissimoFinalProjectModelsim (CLOCK_50, VGA_COLOR, VGA_X, VGA_Y, plot, PS2_CLK, PS2_DAT, KEY);

	input [3:0] KEY;
	//--------------------- VGA IO ------------------------
	input			CLOCK_50;				//	50 MHz	
	output	[23:0]	VGA_COLOR;
    reg	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	reg	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	reg	[7:0]	VGA_B;
 
    output [7:0] VGA_X;
    output [6:0] VGA_Y;
    output plot;

    assign VGA_COLOR = {VGA_R, VGA_G, VGA_B};
	//-----------------------------------------------------

	//--------------------- PS2 IO ------------------------
	inout PS2_CLK;							// Connected to DE1_SOC board pins
	inout PS2_DAT;							// Connected to DE1_SOC board pins

	wire [7:0] commandToSend;				// 8-bit command to send
	wire sendCommand;						// Initiate send of command stored in {commandToSend}
	wire commandWasSent;					// Confirmation of command send
	wire errorCommunicationTimedOut;		// Unable to communicate with PS2 device

	reg [7:0] recievedData;				// Data recieved from PS2 Device
	reg recievedNewData;					// Driven high for one clock cycle when new data is recieved

	//- - - - - - PS2 Take Inputs From Keyboard - - - - - -
	// Define storage elements for state of keys
	reg [`NUMBEROFKEYBOARDINPUTS-1:0] inputStateStorage;
	initial inputStateStorage[`NUMBEROFKEYBOARDINPUTS-1:0] = 1'b0;
	//PS2_Controller ps2 (CLOCK_50, ~KEY[0], commandToSend, sendCommand, PS2_CLK, PS2_DAT, commandWasSent, 
	//				    errorCommunicationTimedOut, recievedData, recievedNewData);

	integer i;
	always @(posedge recievedNewData) begin: PS2Controller
		if (recievedData == 8'hF0) begin
			for (i = 0; i < `NUMBEROFKEYBOARDINPUTS-1; i = i+1) begin
				inputStateStorage[i] = 1'b0;
			end
			inputStateStorage[`noPress] <= 1'b1;
		end
		else inputStateStorage[`noPress] <= 1'b0;
		
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

    assign VGA_X = screenX;
    assign VGA_Y = screenY[6:0];
    assign plot = plotWriteEnable;
	
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
	
endmodule