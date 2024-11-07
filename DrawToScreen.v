module drawToSreen (clk, nextAddress, doneDrawing, outputDrawScreenPosX, outputDrawScreenPosY);
	input clk;
	output reg doneDrawing;
	output reg [14:0] nextAddress;
	output reg [8:0] outputDrawScreenPosX, outputDrawScreenPosY;

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

		if (outputDrawScreenPosX == 8'd159 && localDrawScreenPosY == 8'119) begin
			doneDrawing <= 1;
			nextAddress <= 0;
		end
	end
endmodule