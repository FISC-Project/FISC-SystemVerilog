`timescale 1ns/1ps

module fisc_core_tb();

	reg clk, en;
	wire q;
	
	fisc_core fisc(clk, en, q);

	initial begin
		clk = 0;
		en = 0;
		
		#50;
		en = 1;
		
		#50;
		en = 0;
		
		#50;
		en = 1;
		
		#50;
		en = 0;
		
		#100;
	end

endmodule