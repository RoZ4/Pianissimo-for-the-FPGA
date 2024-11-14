module pianosimpleformodelsim (
	// Inputs
	CLOCK_50,
	SW, sound
);

// Inputs
input				CLOCK_50;
input		[9:0]	SW;

//outputs
output [31:0] sound;

// Internal Registers

reg [18:0] delay_cnt;
reg [18:0] delay;

reg snd;

//generates wave
always @(posedge CLOCK_50)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;

//selects note
 always @(*) begin
        case (SW)
            10'd1: delay <= 32'd3;  // C4 (261.63 Hz) //middle C
            10'd2: delay <= 32'd3; // D4 (293.66 Hz)
            10'd4: delay <= 32'd3;  // E4 (329.63 Hz)
            10'd8: delay <= 32'd2;  // F4 (349.23 Hz)
            10'd16: delay <= 32'd2;  // G4 (392.00 Hz)
            10'd32: delay <= 32'd2; // A4 (440.00 Hz)
            10'd64: delay <= 32'd2;  // B4 (493.88 Hz)
            10'd128: delay <= 32'd2;  // C5 (523.25 Hz)
            10'd256: delay <= 32'd2;  // D5 (587.33 Hz)
            10'd512: delay <= 32'd2;  // E5 (659.25 Hz)
    default: delay <= 32'd0; // Default to no sound
        endcase
    end

assign sound = snd ? 32'd10000000 : -32'd10000000;

endmodule