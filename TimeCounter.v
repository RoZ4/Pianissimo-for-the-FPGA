module timeCounter (clk, timerEnable, microSecondCounter)
	input clk, timerEnable;
	output [28:0] microSecondCounter; // 5 minute == 300,000,000 us
	wire [28:0] microSecondEnable;

	upLoopCounter_29b clockCount (clk, 1'b0, timerEnable, 29'd1000000, microSecondEnable);
	upLoopCounter_29b clockCount (clk, 1'b0, ~|microSecondEnable && timerEnable, 29'd300000000, microSecondCounter);
endmodule


module upLoopCounter_29b(clk, resetn, enable, maxCount, regOut);
	input clk, rstn, enable;
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