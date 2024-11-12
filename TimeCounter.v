module timeCounter (clk, reset, timerEnable, microSecondCounter);
	input clk, reset, timerEnable;
	output [28:0] microSecondCounter; // 5 minute == 300,000,000 us
	wire [28:0] microSecondEnable;

	upLoopCounter_29b clockCount (clk, reset, timerEnable, 29'd1000000, microSecondEnable);
	upLoopCounter_29b outputCount (clk, reset, ~|microSecondEnable && timerEnable, 29'd300000000, microSecondCounter);
endmodule


module upLoopCounter_29b(clk, resetn, enable, maxCount, regOut);
	input clk, resetn, enable;
	input [28:0] maxCount;
	output reg [28:0] regOut;
	
	always @(posedge clk, posedge resetn) begin
		if (resetn)
			regOut <= 29'd0;
			
		else if(enable) begin
			if (regOut == maxCount) // Time for update
				regOut <= 29'd0;
			else
				regOut <= regOut+1;
		end
		
	end
endmodule

module downCounter_9b(clk, resetn, enable, maxCount, regOut);
	input clk, resetn, enable;
	input [8:0] maxCount;
	output reg [8:0] regOut;
	
	always @(posedge clk, posedge resetn) begin
		if (resetn)
			regOut <= maxCount;
			
		else if(enable) begin
			regOut <= regOut-1;
		end
		
	end
endmodule

module upLoopCounterVariableBits(clk, resetn, enable, maxCount, regOut);
	parameter outputBits = 29;

	input clk, resetn, enable;
	input [outputBits-1:0] maxCount;
	output reg [outputBits-1:0] regOut;
	
	always @(posedge clk, posedge resetn) begin
		if (resetn)
			regOut <= 29'd0;
			
		else if(enable) begin
			if (regOut == maxCount) // Time for update
				regOut <= 29'd0;
			else
				regOut <= regOut+1;
		end
		
	end
endmodule