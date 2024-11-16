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

wire [31:0] sound;

sineWaveGenerator hiRobertsboss (.Clk(CLOCK_50), .noteSelector(SW[9:0]), .sound(sound));


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


module squareWaveGenerator(Clk, noteSelector, sound);
input Clk;
input [9:0] noteSelector;
output [31:0] sound;
reg [18:0] delay_cnt;
reg [18:0] delay;
reg snd;
reg Enable;


//generates square wave!! 
always @(posedge Clk)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;
	
//selects tone
 always @(*) begin
        case (noteSelector)
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

	assign sound = Enable ? (snd ? 32'd10_000_000 : -32'd10_000_000) : 0;
	
endmodule

//sine lookup taken from fpga4fun.com
module sine_lookup(input clk, input [10:0] addr, output reg [16:0] value);

wire [15:0] sine_1sym;  // sine with 1 symmetry
wire [9:0] LUT_output;
reg [15:0] cnt;
always @(posedge clk) cnt <= cnt + 16'h1;
blockram512x10bit_2clklatency my_DDS_LUT(.rdclock(clk), .rdaddress(cnt[8:0]), .q(LUT_output));
blockram512x16bit_2clklatency my_quarter_sine_LUT(     // the LUT contains only one quarter of the sine wave
    .rdclock(clk),
    .rdaddress(addr[9] ? ~addr[8:0] : addr[8:0]),   // first symmetry
    .q(sine_1sym)
);

// now for the second symmetry, we need to use addr[10]
// but since our blockram has 2 clock latencies on reads
// we need a two-clock delayed version of addr[10]
reg addr10_delay1; always @(posedge clk) addr10_delay1 <= addr[10];
reg addr10_delay2; always @(posedge clk) addr10_delay2 <= addr10_delay1;

wire [15:0] sine_2sym = addr10_delay2 ? {1'b0,-sine_1sym} : {1'b1,sine_1sym};  // second symmetry

// add a third latency to the module output for best performance
always @(posedge clk) value <= sine_2sym;
endmodule

module sineWaveGenerator(Clk, noteSelector, sound);

input Clk;
input [9:0] noteSelector;
output [31:0] sound;
reg [18:0] delay;
reg Enable;

reg [31:0] phase_acc;
always @(posedge clk) phase_acc <= phase_acc + delay; 

sine_lookup my_sine(.clk(clk), .addr(phase_acc[14:4]), .value(sine_lookup_output));

//selects tone
 always @(*) begin
        case (noteSelector)
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
	 
	 assign sound = Enable ? sine_lookup_output : 0;

endmodule


module badSineWaveGenerator(Clk, noteSelector, sound);
input Clk;
input [9:0] noteSelector;
output [31:0] sound;
reg [18:0] delay_cnt;
reg [18:0] delay;
reg [4:0] soundWaveInput;
reg Enable;
wire [14:0] phaseSeg;
reg [15:0] inputAmplitude;


assign phaseSeg = delay / 20;

always@(posedge Clk) 
if (delay_cnt == delay) begin
		delay_cnt <= 0;
		soundWaveInput <= 0;
	end else begin 
	delay_cnt <= delay_cnt + 1;
	if (delay_cnt % phaseSeg == 0) begin
	soundWaveInput <= soundWaveInput + 1;
	end
	end

//selects tone
 always @(*) begin
        case (noteSelector)
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
	 
	 always@(*)
	 begin
	 case (soundWaveInput)
		5'd0: inputAmplitude = 0;
		5'd1: inputAmplitude = 20;
		5'd2: inputAmplitude = 40;
		5'd3: inputAmplitude = 60;
		5'd4: inputAmplitude = 80;
		5'd5: inputAmplitude = 100;
		5'd6: inputAmplitude = 80;
		5'd7: inputAmplitude = 60;
		5'd8: inputAmplitude = 40;
		5'd9: inputAmplitude = 20;
		5'd10: inputAmplitude = 0;
		5'd11: inputAmplitude = -20;
		5'd12: inputAmplitude = -40;
		5'd13: inputAmplitude = -60;
		5'd14: inputAmplitude = -80;
		5'd15: inputAmplitude = -100;
		5'd16: inputAmplitude = -80;
		5'd17: inputAmplitude = -60;
		5'd18: inputAmplitude = -40;
		5'd19: inputAmplitude = -20;
	 endcase
	 end
	 
	 assign sound = Enable ? inputAmplitude * 10_000 : 0;
endmodule

/*
module timeCounterSine (clk, maxCount, timerEnable, outputCount);
	input clk, timerEnable, maxCount;
	output [24:0] outputCount; // 5 minute == 300,000,000 us
	wire [24:0] slowCOunterEnable;

	upLoopCounter_29bSine clockCount (clk, timerEnable, maxCount, slowSecondEnable);
	upLoopCounter_29bSine outputCount (clk, ~|slowCounterEnable && timerEnable, 25'd31_415_926, outputCount);
endmodule


module upLoopCounter_29bSine (clk, enable, maxCount, regOut);
	input clk, enable;
	input [28:0] maxCount;
	output reg [28:0] regOut;
	
	always @(posedge clk) begin
		if(enable) begin
			if (regOut == maxCount) // Time for update
				regOut <= 29'd0;
			else
				regOut <= regOut+1;
		end
		
	end
endmodule

*/


