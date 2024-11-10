module drawToScreen (clk, nextAddress, doneDrawing, outputDrawScreenPosX, outputDrawScreenPosY);
	input clk;
	output reg doneDrawing;
	output reg [14:0] nextAddress;
	output reg [7:0] outputDrawScreenPosX, outputDrawScreenPosY;

	initial doneDrawing = 0;
	initial nextAddress = 0;

	always @(posedge clk) begin
		if (doneDrawing) doneDrawing <= 0;

		else begin
			if (outputDrawScreenPosX < 8'd160) begin
				outputDrawScreenPosX <= outputDrawScreenPosX + 1;
			end
			else if (outputDrawScreenPosX == 8'd160 && outputDrawScreenPosY < 8'd120) begin
				outputDrawScreenPosY <= outputDrawScreenPosY + 1;
				outputDrawScreenPosX <= 0;
				
			end

			nextAddress <= nextAddress + 1;
		end

		if (outputDrawScreenPosX == 8'd159 && outputDrawScreenPosY == 8'd119) begin
			doneDrawing <= 1;
			nextAddress <= 0;
		end
	end
endmodule

module resetScreen (clk, noteBlocksDoneDrawing, inputDrawScreenPosX, inputDrawScreenPosY, outputColour);
	input clk, noteBlocksDoneDrawing;
	input [7:0] inputDrawScreenPosX, inputDrawScreenPosY;
	output reg [23:0] outputColour;
	
	wire [23:0] pianoColour;
	reg [12:0] internalPianoAddress;
	initial internalPianoAddress = 0;
	PianoROM pianoImage(internalPianoAddress, clk, pianoColour);

	always @(posedge clk) begin
		if (noteBlocksDoneDrawing) begin
			if (internalPianoAddress >= 13'd4480) internalPianoAddress <= 0;
			else if (inputDrawScreenPosY >= 8'd92) begin
				internalPianoAddress <= internalPianoAddress + 1;
			end
		end

	end

	always @(*) begin
		if (inputDrawScreenPosY < 8'd92) begin
			outputColour <= 24'b0000_0000_0000;
		end
		else begin
			outputColour <= pianoColour;
		end
	end
endmodule