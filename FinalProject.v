module FinalProject (CLOCK_50,
                	VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
					PS2_CLK, PS2_DAT
					);

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

	// Define storage elements for state of keys
	reg keySpacebar, keyEnter;

	//- - - - - - PS2 Take Inputs From Keyboard - - - - - -
	PS2_Controller ps2 (CLOCK_50, commandToSend, sendCommand, PS2_CLK, PS2_DAT, commandWasSent, 
					    errorCommunicationTimedOut, recievedData, recievedNewData);

	always @(posedge recievedDataEnable) begin: PS2Controller
		if (recievedData == 8'hf0) begin
			keyEnter <= 0;
			keySpacebar <= 0;
		end
		if (recievedData == 8'h5a) keyEnter <= 1;
		else if (recievedData == 8'h29) keySpacebar <= 1;
	end
	//-----------------------------------------------------

	// -------------------- STATES ------------------------
	localparam STARTSCREEN = 5'd0, PLACE = 5'd1, DRAW = 5'd2, PAUSE = 5'd3; 

	wire [4:0] currentState; // Connects to current state in MasterFSM.v
	// ----------------------------------------------------



	
    reg [2:0] colour;
    reg [8:0] screenX, screenY;
	reg plotWriteEnable; 					// Feeds .plot() on the VGA adapter; tells when to draw pixels to screen
	wire [8:0] backgroundX, backgroundY; 	// Coordinates on .mif background texture
	reg [16:0] rdAddress, wrAddress; 		// Pointer to address for individual pixels in memory
	wire [16:0] nextAddress;				// Connected to the drawing module; stores the next address with the next pixel colour
	wire masterResetAddress;				// Signal to reset address pointer to 0
	wire masterClearScreen;
	wire CLOCK_25, doneDrawing; 
	wire [2:0] VWRData, VRDData;

    wire resetn;
	assign resetn = KEY[3]; // Reset on key 3 downpress

	vga_pll clockHalf50(CLOCK_50, CLOCK_25);

	vga_adapter VGA (
        .resetn(resetn),
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
        defparam VGA.RESOLUTION = "320x240";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
        defparam VGA.BACKGROUND_IMAGE = "./images/start_screen.mif";
	
	
	// read and write to memory on opposite clock cycles: Write on HIGH, Read on LOW
	VideoBuffer VBuff (.data(VWRData), .rdaddress(rdAddress), .rdclock(~CLOCK_50), .wraddress(wrAddress), .wrclock(CLOCK_50), .wren(plotWriteEnable), .q(VRDData));
	drawPixels drawScanner(CLOCK_50, nextAddress, doneDrawing, backgroundX, backgroundY);

	wire blitCircleEnable; // Blit refers to copying data into the video buffer: VBuff
	reg [8:0] circleCenterX, circleCenterY;
	initial begin
		circleCenterX = 9'd160;
		circleCenterY = 9'd120;
	end
	wire [2:0] blankScreenColour;
	//drawCircle circleDrawer(CLOCK_50, blitCircleEnable, circleCenterX, circleCenterY, nextAddress, VWRData);
	blank_screen bScreen(rdAddress, CLOCK_50, blankScreenColour);

	wire drawStateHandlerResetAddress, drawStateHandlerClearScreen, drawStateWREnable;
	assign masterResetAddress = drawStateHandlerResetAddress;
	assign masterClearScreen = drawStateHandlerClearScreen;
	wire [2:0] simulateScreenColour;
	drawStatePartialRegFSM stateHandlerDraw(CLOCK_50, resetn, simulateScreenColour, rdAddress, doneDrawing, circleCenterX, circleCenterY, drawStateHandlerClearScreen, resetAddress, drawStateWREnable);

	
	always @* begin
		if (masterResetAddress) begin
			wrAddress <= 0;
			rdAddress <= 0;
		end
		else begin
			rdAddress <= nextAddress;

			if (currentState == STARTSCREEN) begin
				plotWriteEnable <= 1;
				screenX <= backgroundX;
				screenY <= backgroundY;
			end

			else if (currentState == PLACE) begin
				if (masterClearScreen && !doneDrawing) begin
					colour <= blankScreenColour;
				end
				plotWriteEnable <= 1;
				blitCircleEnable <= 1;
				screenX <= backgroundX;
				screenY <= backgroundY;
			end
			else if (currentState == DRAW) begin
				if (masterClearScreen && !doneDrawing) begin
					colour <= blankScreenColour;
				end
				colour <= simulateScreenColour
				plotWriteEnable <= drawStateWREnable;
				blitCircleEnable <= 0;
				screenX <= backgroundX;
				screenY <= backgroundY;
			end
			else if (currentState == PAUSE) begin
				plotWriteEnable <= 0;
			end
		end
	end

	MasterFSM masterFSM(CLOCK_50, resetn, keyEnter, keySpacebar, currentState);
	
endmodule