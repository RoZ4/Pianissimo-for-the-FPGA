`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 10;

    reg [9:0] SW;
    //reg [3:0] KEY;
    reg CLOCK_50;
    reg [32:0] delay_cnt;
    reg snd;
    wire [31:0] sound;
    wire [31:0] delay;

	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end

        initial begin
        snd <= 1'b0;
        #2 snd <= 1'b1; // reset

	end 
        
	initial begin
        SW[9:0] <= 10'b0000000000;
        #200 SW[9:0] <= 10'b0000000001;
        #200 SW[9:0] <= 10'b0000000010;
        #200 SW[9:0] <= 10'b0000000100; 
        #200 SW[9:0] <= 10'b0000001000;
        #200 SW[9:0] <= 10'b0000010000;
        #200 SW[9:0] <= 10'b0000100000;
        #200 SW[9:0] <= 10'b0001000000;
        #200 SW[9:0] <= 10'b0010000000;
        #200 SW[9:0] <= 10'b0100000000;

	end // initial
	pianosimpleformodelsim U1 (
	// Inputs
	CLOCK_50,
	SW, sound
);

        //initial begin $monitor("time=%0d, reset=%b, counter=%d, hex=%7b", $time, KEY[0], slowCounterOut, HEX0); end 

endmodule