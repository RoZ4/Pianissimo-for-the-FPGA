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

reg [18:0] delay_cnt;
reg [18:0] delay;
reg snd;
reg Enable = 1;

//generates square wave
always @(posedge CLOCK_50)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;



//selects tone
 always @(*) begin
        case (SW)
	    10'd1: begin delay <= 32'd95554; Enable <= 1; end // C4 (261.63 Hz) //middle C
	    10'd2: begin delay <= 32'd85132; Enable <= 1; end// D4 (293.66 Hz)
	    10'd4: begin delay <= 32'd75842; Enable <= 1; end// E4 (329.63 Hz)
            10'd8: begin delay <= 32'd71586; Enable <= 1; end// F4 (349.23 Hz)
            10'd16: begin delay <= 32'd63775; Enable <= 1; end // G4 (392.00 Hz)
            10'd32: begin delay <= 32'd56818; Enable <= 1; end// A4 (440.00 Hz)
            10'd64: begin delay <= 32'd50620; Enable <= 1; end// B4 (493.88 Hz)
            10'd128: begin delay <= 32'd47778; Enable <= 1; end// C5 (523.25 Hz)
            10'd256: begin delay <= 32'd42568; Enable <= 1; end// D5 (587.33 Hz)
            10'd512: begin delay <= 32'd37922; Enable <= 1; end// E5 (659.25 Hz)
    default: begin delay <= 32'd0; Enable <= 0; end // Default to no sound
        endcase
    end

	wire [31:0] sound = Enable ? snd ? 32'd10000000 : -31'd10000000: 0;

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
