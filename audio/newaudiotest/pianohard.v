module pianosimple (CLOCK_50, KEY, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK, SW);
input				CLOCK_50;
input		[3:0]	KEY;
input		[9:0]	SW;
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

reg [18:0] delay;
reg Enable;

wire [31:0] sound;


wire [31:0] sound0;
wire [31:0] sound1;
wire [31:0] sound2;
wire [31:0] sound3;
wire [31:0] sound4;
wire [31:0] sound5;
wire [31:0] sound6;
wire [31:0] sound7;
wire [31:0] sound8;
wire [31:0] sound9;

	wire [31:0] wave0;
	wire [31:0] wave1;
	wire [31:0] wave2;
	wire [31:0] wave3;
	wire [31:0] wave4;
	wire [31:0] wave5;
	wire [31:0] wave6;
	wire [31:0] wave7;
	wire [31:0] wave8;
	wire [31:0] wave9;

sineWaveGenerator zero_sine (.Clk(Clk), .frequencyVal(delay), .wave(wave0); 

muxxywuxxy zero (.a(SW[0]), .b(wave0), .c(sound0));

sineWaveGenerator sophia_OG (.Clk(Clk), .frequencyVal(delay), .wave(wave);

initial Enable = 0;
//selects tone
 always @(*) begin
	 case (SW[9:0])
                //white notes
                    4'd0: delay <= 32'd95554;  // C4 (261.63 Hz) //middle C
					4'd1: delay <= 32'd85132; // D4 (293.66 Hz)
					4'd2: delay <= 32'd75842;  // E4 (329.63 Hz)
					4'd3: delay <= 32'd71586;  // F4 (349.23 Hz)
					4'd4: delay <= 32'd63775;  // G4 (392.00 Hz)
					4'd5: delay <= 32'd56818; // A4 (440.00 Hz)
					4'd6: delay <= 32'd50620;  // B4 (493.88 Hz)


					4'd7: delay <= 32'd47778;  // C5 (523.25 Hz) //next octave
					4'd8: delay <= 32'd42568;  // D5 (587.33 Hz)
					4'd9: delay <= 32'd37922;  // E5 (659.25 Hz)
/*
                    //no calculated values yet, awaiting testing
				    4'd10: delay <= 32'd35793; //F5 (698.46 Hz)
					4'd11: delay <= 32'd31888; // G5 (783.99 Hz)
					4'd12: delay <= 32'd28409; // A5 (880 Hz)
					4'd13: delay <= 32'd25309; // B5 (987.77 Hz)
					
                    //black notes
					4'd14: delay <= 32'd90194; //C#4 (277.18 Hz)
					4'd15: delay <= 32'd80352; //D#4 (311.13 Hz)
					4'd16: delay <= 32'd67569; //F#4 (369.99 Hz)
					4'd17: delay <= 32'd60197; //G#4 (415.30 Hz)
					4'd18: delay <= 32'd53629; //A#4 (466.16 Hz)

					4'd19: delay <= 32'd45096; //C#5 (554.37 Hz) //next octave
					4'd20: delay <= 32'd40176; //D#5 (622.25 Hz)
					4'd21: delay <= 32'd33784; //F#5 (739.99 Hz)
					4'd22: delay <= 32'd30098; //G#5 (830.61 Hz)
					4'd23: delay <= 32'd26814; //A#5 (932.33 Hz)
     */
		 default: begin delay <= 32'd0; Enable <= 1'd0; end// Default to no sound
        endcase
    end

assign sound = (Enable) ? wave*1000 : 0;

assign read_audio_in			= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	= sound;
assign right_channel_audio_out	= sound;
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

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
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

endmodule

module sineWaveGenerator(Clk, frequencyVal, wave);
input Clk;
input [18:0] frequencyVal;
output [31:0] wave;
reg [9:0] counter;
reg [31:0] phase;

reg [31:0] lookuptable [0:1023];
initial	$readmemh("realsintable.hex", lookuptable);

	always @(posedge Clk) begin
		if (counter == 10'd1024) begin
			counter <= 10'd0;
			phase <= 32'd0;
		end
		else begin
			phase <= phase + frequencyVal;
			counter <= counter + 10'd1;
			wave <= lookuptable[phase[31:24]];
		end
	end
endmodule

module muxxywuxxy(a, b, c);
input a;
input [31:0] b;
output wire [31:0] c;

	if (a) begin
		assign c = b;
	end else begin
		assign c = 32'd0;
	end
                
endmodule


	
			



