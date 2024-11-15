module pianosimple (CLOCK_50, KEY, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK, SW, retrievedNoteData);
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

reg [18:0] delay_cnt;
wire [18:0] delay;
reg snd;
reg [57:0] noteLength = retrievedNoteData[28:0] - retrievedNoteData[57:29];
wire [31:0] sound;

//generates wave

if (noteLength >= 0) begin
   always @(posedge CLOCK_50)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
    end else begin delay_cnt <= delay_cnt + 1; 
    noteLength <= noteLength - 1;
    end
end else assign sound = 32'd0;


//selects tone
 always @(*) begin
        case (retrievedNoteData[61:58])
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

                    //no calculated values yet, awaiting testing
				    4'd10: delay <= 8'd116; //F5 (698.46 Hz)
					4'd11: delay <= 8'd128; // G5 (783.99 Hz)
					4'd12: delay <= 8'd139; // A5 (880 Hz)
					4'd13: delay <= 8'd151; // B5 (987.77 Hz)
					
                    //black notes
					4'd14: delay <= 8'd5; //C#4 (277.18 Hz)
					4'd15: delay <= 8'd19; //D#4 (311.13 Hz)
					4'd16: delay <= 8'd40; //F#4 (369.99 Hz)
					4'd17: delay <= 8'd53; //G#4 (415.30 Hz)
					4'd18: delay <= 8'd66; //A#4 (466.16 Hz)

					4'd19: delay <= 8'd87; //C#5 (554.37 Hz) //next octave
					4'd20: delay <= 8'd101; //D#5 (622.25 Hz)
					4'd21: delay <= 8'd122; //F#5 (739.99 Hz)
					4'd22: delay <= 8'd135; //G#5 (830.61 Hz)
					4'd23: delay <= 8'd148; //A#5 (932.33 Hz)
				default: delay <= 32'd0; // Default to no sound
        endcase
    end

assign sound = snd ? 32'd10000000 : -32'd10000000;

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