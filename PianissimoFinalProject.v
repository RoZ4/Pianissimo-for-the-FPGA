`include "DefineMacros.vh"

module PianissimoFinalProject (CLOCK_50,
                	VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK,
					PS2_CLK, PS2_DAT, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
					AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK
					
					);
	

	input [0:0] KEY;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
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
	initial inputStateStorage[`NUMBEROFKEYBOARDINPUTS-1:0] = 1'b0;
	PS2_Controller ps2 (CLOCK_50, ~KEY[0], commandToSend, sendCommand, PS2_CLK, PS2_DAT, commandWasSent, 
					    errorCommunicationTimedOut, recievedData, recievedNewData);

	reg prevWasRelease; //Tracks whether a key was released. Required because recievedNewData is clocked twice, one for break command 8'hF0 and one for the lifting of the key
	always @(posedge recievedNewData) begin: PS2Controller
		if (recievedData == 8'hF0) begin
			prevWasRelease <= 1;
			inputStateStorage[`keyReleasePulse] <= 1'b1;
		end
		else if (prevWasRelease) begin
			prevWasRelease <= 0;
			inputStateStorage[`keyReleasePulse] <= 1'b0;
			case (recievedData)
				8'h0E: inputStateStorage[`keyTilda] <= 1'b0;
				8'h16: inputStateStorage[`key1] <= 1'b0;
				8'h1E: inputStateStorage[`key2] <= 1'b0;
				8'h26: inputStateStorage[`key3] <= 1'b0;
				8'h25: inputStateStorage[`key4] <= 1'b0;
				8'h2E: inputStateStorage[`key5] <= 1'b0;
				8'h36: inputStateStorage[`key6] <= 1'b0;
				8'h3D: inputStateStorage[`key7] <= 1'b0;
				8'h3E: inputStateStorage[`key8] <= 1'b0;
				8'h46: inputStateStorage[`key9] <= 1'b0;
				8'h45: inputStateStorage[`key0] <= 1'b0;
				8'h4E: inputStateStorage[`keyMinus] <= 1'b0;
				8'h55: inputStateStorage[`keyEquals] <= 1'b0;
				8'h66: inputStateStorage[`keyBackspace] <= 1'b0;

				8'h0D: inputStateStorage[`keyTab] <= 1'b0;
				8'h15: inputStateStorage[`keyQ] <= 1'b0;
				8'h1D: inputStateStorage[`keyW] <= 1'b0;
				8'h24: inputStateStorage[`keyE] <= 1'b0;
				8'h2D: inputStateStorage[`keyR] <= 1'b0;
				8'h2C: inputStateStorage[`keyT] <= 1'b0;
				8'h35: inputStateStorage[`keyY] <= 1'b0;
				8'h3C: inputStateStorage[`keyU] <= 1'b0;
				8'h43: inputStateStorage[`keyI] <= 1'b0;
				8'h44: inputStateStorage[`keyO] <= 1'b0;
				8'h4D: inputStateStorage[`keyP] <= 1'b0;
				8'h54: inputStateStorage[`keyLSquareBracket] <= 1'b0;
				8'h5B: inputStateStorage[`keyRSquareBracket] <= 1'b0;
				8'h5D: inputStateStorage[`keyBackslash] <= 1'b0;

				8'h2B: inputStateStorage[`keyF] <= 1'b0;
				8'h34: inputStateStorage[`keyG] <= 1'b0;
				8'h33: inputStateStorage[`keyH] <= 1'b0;
				8'h3B: inputStateStorage[`keyJ] <= 1'b0;


				8'h29: inputStateStorage[`keySpacebar] <= 1'b0;
				8'h5A: inputStateStorage[`keyEnter] <= 1'b0;
			endcase
		end
		else begin
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

				8'h2B: inputStateStorage[`keyF] <= 1'b1;
				8'h34: inputStateStorage[`keyG] <= 1'b1;
				8'h33: inputStateStorage[`keyH] <= 1'b1;
				8'h3B: inputStateStorage[`keyJ] <= 1'b1;

				8'h29: inputStateStorage[`keySpacebar] <= 1'b1;		
				8'h5A: inputStateStorage[`keyEnter] <= 1'b1;
			endcase
		end
	end

	reg pressPulsereg = 0;

	always @(posedge CLOCK_50) begin
		if (recievedNewData && !prevWasRelease && recievedData != 8'hF0) pressPulsereg <= 1;
		if (pressPulsereg) pressPulsereg <= 0;
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
	assign masterResetAddress = resetn;

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
        defparam VGA.BACKGROUND_IMAGE = "./images/StartScreenNew.mif";
	
	wire drawScannerDoneDrawing, noteBlocksDoneDrawing;
	wire [23:0] resetScreenColour;
	wire playDrumNote;
	wire [31:0] retrievedNoteData;
	drawToScreen drawScanner(CLOCK_50, nextAddress, inputStateStorage, drawScannerDoneDrawing, backgroundX, backgroundY, currentState);
	resetScreen screenReseter(CLOCK_50, noteBlocksDoneDrawing, currentState, backgroundX, backgroundY, inputStateStorage, retrievedNoteData[31:29], playDrumNote, resetScreenColour);

	wire randomTimerEnable;
	MasterFSM masterFSM(CLOCK_50, resetn, inputStateStorage, currentState, randomTimerEnable);

	wire [23:0] mainStateColour; // startScreenColour
	//startScreenHandler startScreenController(CLOCK_50, nextAddress, startScreenColour);
			
	

	// wire [7:0] mainStateOutputScreenX, mainStateOutputScreenY;
	wire [3:0] currentSubState;
	
	reg donePlayingDrumNote;
	
	// wire [61:0] retrievedNoteData;
	// mainStateHandler mainStateController(CLOCK_50, resetn, drawScannerDoneDrawing, mainStateOutputScreenX, mainStateOutputScreenY, currentState, currentSubState, inputStateStorage, mainStateColour, noteBlocksDoneDrawing, retrievedNoteData);
	mainStateHandlerDrums mainStateDrumsController(CLOCK_50, resetn, currentState, currentSubState, inputStateStorage, playDrumNote, donePlayingDrumNote, retrievedNoteData);

	always @* begin
		if (masterResetAddress) begin
			rdAddress <= 0;
			
		end
		else begin
			rdAddress <= nextAddress;

			if (currentState == `STARTSCREEN) begin
				plotWriteEnable <= 0;
				// colour <= startScreenColour;
				// screenX <= backgroundX;
				// screenY <= backgroundY;
			end

			else if (currentState == `RECORD) begin
				colour <= resetScreenColour;

				plotWriteEnable <= 1;
				screenX <= backgroundX;
				screenY <= backgroundY;
			end
			else if (currentState == `PLAYBACK) begin
				colour <= resetScreenColour;

				plotWriteEnable <= 1;
				screenX <= backgroundX;
				screenY <= backgroundY;
			end
		end
	end

	displayStateHEX debugDisplayState(currentState, currentSubState, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

	
	
	assign LEDR[9] = inputStateStorage[`keyTilda];
	assign LEDR[8] = inputStateStorage[`keySpacebar];

	assign LEDR[2] = recievedNewData;
	assign LEDR[1] = recievedData == 8'hf0;
	assign LEDR[0] = pressPulsereg;
	assign LEDR[7] = ~|inputStateStorage[27:0];


	// --------AUDIO CONTROLLER HERE ---------

	input				AUD_ADCDAT;

	inout				AUD_BCLK;
	inout				AUD_ADCLRCK;
	inout				AUD_DACLRCK;
	inout				FPGA_I2C_SDAT;

	output				AUD_XCK;
	output				AUD_DACDAT;
	output				FPGA_I2C_SCLK;


	wire				audio_out_allowed;
	wire		[31:0]	left_channel_audio_out;
	wire		[31:0]	right_channel_audio_out;
	wire				write_audio_out;

	//not used (for taking audio input used in controller)
	wire				audio_in_available;
	wire		[31:0]	left_channel_audio_in;
	wire		[31:0]	right_channel_audio_in;
	wire				read_audio_in;

	/*
	reg [11:0] bassAddress = 0;
	wire [7:0] bassAmplitude;
	reg [12:0] samplesPerSecondCounter = 0;
	DrumNoteROM bass(bassAddress, CLOCK_50, bassAmplitude);

	always @(posedge CLOCK_50) begin
		if (bassAddress == `DRUMNOTEADDRESSLENGTH) bassAddress <= 0;
		if (inputStateStorage[`keyF]) begin
			if (samplesPerSecondCounter == 6250) begin 
				bassAddress <= bassAddress + 1;
				samplesPerSecondCounter <= 0;
			end
			else samplesPerSecondCounter <= samplesPerSecondCounter + 1;
		end
	end

	wire [32:0] outputSound = inputStateStorage[`keyF] ? bassAmplitude * 262144 : 0;
	*/
	
	/*
	wire signed [31:0] squareWaveOutputPiano, squareWaveOutputDrums;
	squareWaveGeneratorPiano genP(.clk(CLOCK_50), .inputStateStorage(inputStateStorage), .outputSound(squareWaveOutputPiano));
	//squareWaveGeneratorDrums genD(.clk(CLOCK_50), .currentState(currentState), .retrievedNoteDataNote(retrievedNoteData[31:29]), .inputStateStorage(inputStateStorage), .playDrumNote(playDrumNote), .outputSound(squareWaveOutputDrums));

	wire signed [7:0] bassAmplitude, leftDrumAmplitude, middleDrumAmplitude, cymbelAmplitude;
	reg signed [7:0] outputAmplitude;
	reg [11:0] bassAddress = 0, leftDrumAddress = 0, middleDrumAddress = 0, cymbelAddress = 0;
	reg [12:0] samplesPerSecondCounter = 0;

	//DrumNoteROM bass(bassAddress, CLOCK_50, bassAmplitude);
	//DrumNoteROM leftDrum(leftDrumAddress, CLOCK_50, leftDrumAmplitude);
	//DrumNoteROM middleDrum(middleDrumAddress, CLOCK_50, middleDrumAmplitude);
	DrumNoteROM cymbel(cymbelAddress, CLOCK_50, cymbelAmplitude);
	defparam cymbel.INITFILE = "./AudioMifs/cymbel.mif";
			//leftDrum.INITFILE = "./AudioMifs/topLeftDrum.mif",
			//bass.INITFILE = "./AudioMifs/Bassdrum.mif",
			//middleDrum.INITFILE = "./AudioMifs/middleDrum.mif",
			

	always @(posedge CLOCK_50) begin
		if ((currentState == `PLAYBACK && !playDrumNote) || (currentState == `RECORD && ~|inputStateStorage[`keyJ:`keyF])) begin 
			bassAddress <= 0;
			leftDrumAddress <= 0;
			middleDrumAddress <= 0;
			cymbelAddress <= 0;
			donePlayingDrumNote <= 0;
		end
		else if (playDrumNote || currentState == `RECORD) begin
			if (samplesPerSecondCounter == 13'd6250) begin
				samplesPerSecondCounter <= 0;
				
				if ((retrievedNoteData[31:29] == 0 || inputStateStorage[`keyF]) && leftDrumAddress != `DRUMNOTEADDRESSLENGTH) begin 
					donePlayingDrumNote <= 0;
					leftDrumAddress <= leftDrumAddress + 1;
				end
				
				
				else if ((retrievedNoteData[31:29] == 1 || inputStateStorage[`keyG]) && bassAddress != `DRUMNOTEADDRESSLENGTH) begin
					donePlayingDrumNote <= 0;
					bassAddress <= bassAddress + 1;
				end
				else if ((retrievedNoteData[31:29] == 2 || inputStateStorage[`keyH]) && middleDrumAddress != `DRUMNOTEADDRESSLENGTH) begin
					donePlayingDrumNote <= 0;
					middleDrumAddress <= middleDrumAddress + 1;
				end
				
				if ((retrievedNoteData[31:29] == 3 || inputStateStorage[`keyJ]) && cymbelAddress != `DRUMNOTEADDRESSLENGTH) begin
					donePlayingDrumNote <= 0;
					cymbelAddress <= cymbelAddress + 1;
				end
				
				
			end
			else samplesPerSecondCounter <= samplesPerSecondCounter + 1;
		end

	

		//if (bassAddress == `DRUMNOTEADDRESSLENGTH) donePlayingDrumNote <= 1;
		if (leftDrumAddress == `DRUMNOTEADDRESSLENGTH) donePlayingDrumNote <= 1;
		if (middleDrumAddress == `DRUMNOTEADDRESSLENGTH) donePlayingDrumNote <= 1;
		if (cymbelAddress == `DRUMNOTEADDRESSLENGTH) donePlayingDrumNote <= 1;
	end

	always@(*) begin
		if ((retrievedNoteData[31:29] == 0 && currentState == `PLAYBACK) || inputStateStorage[`keyF]) outputAmplitude <= leftDrumAmplitude;
		else if ((retrievedNoteData[31:29] == 1 && currentState == `PLAYBACK)|| inputStateStorage[`keyG]) outputAmplitude <= bassAmplitude;
		else if ((retrievedNoteData[31:29] == 2 && currentState == `PLAYBACK)|| inputStateStorage[`keyH]) outputAmplitude <= middleDrumAmplitude;
		else if ((retrievedNoteData[31:29] == 3 && currentState == `PLAYBACK) || inputStateStorage[`keyJ]) outputAmplitude <= cymbelAmplitude;
		else outputAmplitude <= 0;
	end

	//FROM FILE
	wire [31:0] outputSound = (|inputStateStorage[27:0] || (playDrumNote && retrievedNoteData[31:29] != 4) || (|inputStateStorage[`keyJ:`keyF] && currentState == `RECORD)) ? squareWaveOutputPiano + (outputAmplitude) : 0; //262144

	*/
	
	wire signed [31:0] squareWaveOutputPiano, squareWaveOutputDrums;
	squareWaveGeneratorPiano genP(.clk(CLOCK_50), .inputStateStorage(inputStateStorage), .outputSound(squareWaveOutputPiano));
	squareWaveGeneratorDrums genD(.clk(CLOCK_50), .currentState(currentState), .retrievedNoteDataNote(retrievedNoteData[31:29]), .inputStateStorage(inputStateStorage), .playDrumNote(playDrumNote), .outputSound(squareWaveOutputDrums));

	
	reg [24:0] timerCounter = 0;
	wire timerReset = 0;

	always @(posedge CLOCK_50) begin
		if ((currentState == `PLAYBACK && !playDrumNote) || (currentState == `RECORD && ~|inputStateStorage[`keyJ:`keyF])) begin 
			donePlayingDrumNote <= 0;
			timerCounter <= 0;
		end

		if ((playDrumNote && !donePlayingDrumNote && currentState == `PLAYBACK) || (|inputStateStorage[`keyJ:`keyF] && currentState == `RECORD && timerCounter != 25'd10_000_000)) timerCounter <= timerCounter + 1;
		if (timerCounter == 25'd10_000_000) begin
			if (currentState == `PLAYBACK) donePlayingDrumNote <= 1;
		end

	end

	wire [31:0] outputSound = (|inputStateStorage[27:0] || (playDrumNote && retrievedNoteData[31:29] != 4) || (|inputStateStorage[`keyJ:`keyF] && currentState == `RECORD && timerCounter != 25'd10_000_000)) ? squareWaveOutputPiano + squareWaveOutputDrums : 0;
	




	assign read_audio_in			= audio_in_available & audio_out_allowed;
	assign left_channel_audio_out	= outputSound;
	assign right_channel_audio_out	= outputSound;
	assign write_audio_out			= audio_in_available & audio_out_allowed;

	Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

	);

	avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50						(CLOCK_50),
	.reset							(~KEY[0])
	);
	
endmodule

module displayStateHEX (currentStateDisplay, currentSubStateDisplay, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	output reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input [4:0] currentStateDisplay;
	input [3:0] currentSubStateDisplay;

	always @(*) begin
		case(currentStateDisplay)
			`STARTSCREEN: begin
				HEX2 = ~(7'b1101101); //S
				HEX1 = ~(7'b1111000); //t
				HEX0 = ~(7'b1010000); //r
			end
			`RECORD: begin
				HEX2 = ~(7'b1010000); //R 
				HEX1 = ~(7'b1111001); //E
				HEX0 = ~(7'b0111001); //C
			end
			`PLAYBACK: begin
				HEX2 = ~(7'b1110011); //P 
				HEX1 = ~(7'b0111000); //l
				HEX0 = ~(7'b1101110); //y
			end
			`RESTARTPLAYBACK: begin
				HEX2 = ~(7'b1010000); //r
				HEX1 = ~(7'b1111000); //t
				HEX0 = ~(7'b1111001); //t
			end
			default: begin
				HEX2 = ~(7'b0111111); //0
				HEX1 = ~(7'b0111111); //0
				HEX0 = ~(7'b0111111); //0
			end
		endcase
		case(currentSubStateDisplay)
			`subIDLE: begin
				HEX5 = ~(7'b0000110); //i
				HEX4 = ~(7'b1011110); //d
				HEX3 = ~(7'b0111000); //l
			end
			`subSTARTNOTERECORDING: begin
				HEX5 = ~(7'b1010000); //R 
				HEX4 = ~(7'b1111001); //E
				HEX3 = ~(7'b0111001); //C
			end
			`subWRITESTARTOFNOTE: begin
				HEX5 = ~(7'b1010000); //R 
				HEX4 = ~(7'b0000110); //s
				HEX3 = ~(7'b1111000); //n
			end
			`subAWAITNOTEEND: begin
				HEX5 = ~(7'b1110110); //A 
				HEX4 = ~(7'b0111110); //U
				HEX3 = ~(7'b1111000); //t
			end
			`subPLAYDRUMNOTE: begin
				HEX5 = ~(7'b1110011); //p
				HEX4 = ~(7'b1011110); //d
				HEX3 = ~(7'b1010000); //r
			end
			`subCLEARMEMORY: begin
				HEX5 = ~(7'b0111001); //d
				HEX4 = ~(7'b0111001); //n
				HEX3 = ~(7'b1010000); //E
			end
			default: begin
				HEX5 = ~(7'b0111111); //0
				HEX4 = ~(7'b0111111); //0
				HEX3 = ~(7'b0111111); //0
			end
		endcase
	end

endmodule