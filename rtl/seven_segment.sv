////////////////////////////
//			  (0)
//		   -------
//		   |		|
//		(5)| (6)	|(1)
//		   -------
//		  	|		|
//		(4)|		|(2)
//		   -------
//			  (3)
////////////////////////////
module seven_segment(
	//Clock Input:48M
	input	    clk,
	input  [3:0]num1,
	input  [3:0]num2,
	input  [3:0]num3,
	input  [3:0]num4,
	output reg [3:0]en,
	output reg [6:0]out_reg
);

parameter [6:0]NUM_0=7'b0111111;
parameter [6:0]NUM_1=7'b0000110;
parameter [6:0]NUM_2=7'b1011011;
parameter [6:0]NUM_3=7'b1001111;
parameter [6:0]NUM_4=7'b1100110;
parameter [6:0]NUM_5=7'b1101101;
parameter [6:0]NUM_6=7'b1111101;
parameter [6:0]NUM_7=7'b0000111;
parameter [6:0]NUM_8=7'b1111111;
parameter [6:0]NUM_9=7'b1101111;
parameter [6:0]NUM_A=7'b1110111;
parameter [6:0]NUM_B=7'b1111100;
parameter [6:0]NUM_C=7'b1011000;
parameter [6:0]NUM_D=7'b1011110;
parameter [6:0]NUM_E=7'b1111001;
parameter [6:0]NUM_F=7'b1110001;
parameter [6:0]NUM_BLK=7'b0000000;

parameter [3:0]EN_1=4'b1110;
parameter [3:0]EN_2=4'b1101;
parameter [3:0]EN_3=4'b1011;
parameter [3:0]EN_4=4'b0111;
parameter [3:0]EN_A=4'b0000;

reg [31:0]cnt;
always @(posedge clk)
	begin
		cnt = cnt + 1'b1;
	end

always @(posedge clk)
	begin
		if(cnt[16:15] == 2'b00)
			case (num1)
			4'h0 :   begin out_reg = NUM_0; en=EN_1;end
			4'h1 :   begin out_reg = NUM_1; en=EN_1;end
			4'h2 :   begin out_reg = NUM_2; en=EN_1;end
			4'h3 :   begin out_reg = NUM_3; en=EN_1;end
			4'h4 :   begin out_reg = NUM_4; en=EN_1;end
			4'h5 :   begin out_reg = NUM_5; en=EN_1;end
			4'h6 :   begin out_reg = NUM_6; en=EN_1;end
			4'h7 :   begin out_reg = NUM_7; en=EN_1;end
			4'h8 :   begin out_reg = NUM_8; en=EN_1;end
			4'h9 :   begin out_reg = NUM_9; en=EN_1;end
			4'ha :   begin out_reg = NUM_A; en=EN_1;end
			4'hb :   begin out_reg = NUM_B; en=EN_1;end
			4'hc :   begin out_reg = NUM_C; en=EN_1;end
			4'hd :   begin out_reg = NUM_D; en=EN_1;end
			4'he :   begin out_reg = NUM_E; en=EN_1;end
			4'hf :   begin out_reg = NUM_F; en=EN_1;end
			default: begin out_reg = NUM_BLK; en=EN_1;end
			endcase  
		if(cnt[16:15] == 2'b01)
			case (num2)
			4'h0 :   begin out_reg = NUM_0; en=EN_2;end
			4'h1 :   begin out_reg = NUM_1; en=EN_2;end
			4'h2 :   begin out_reg = NUM_2; en=EN_2;end
			4'h3 :   begin out_reg = NUM_3; en=EN_2;end
			4'h4 :   begin out_reg = NUM_4; en=EN_2;end
			4'h5 :   begin out_reg = NUM_5; en=EN_2;end
			4'h6 :   begin out_reg = NUM_6; en=EN_2;end
			4'h7 :   begin out_reg = NUM_7; en=EN_2;end
			4'h8 :   begin out_reg = NUM_8; en=EN_2;end
			4'h9 :   begin out_reg = NUM_9; en=EN_2;end
			4'ha :   begin out_reg = NUM_A; en=EN_2;end
			4'hb :   begin out_reg = NUM_B; en=EN_2;end
			4'hc :   begin out_reg = NUM_C; en=EN_2;end
			4'hd :   begin out_reg = NUM_D; en=EN_2;end
			4'he :   begin out_reg = NUM_E; en=EN_2;end
			4'hf :   begin out_reg = NUM_F; en=EN_2;end
			default: begin out_reg = NUM_BLK; en=EN_2;end
			endcase  
		if(cnt[16:15] == 2'b10)
			case (num3)
			4'h0 :   begin out_reg = NUM_0; en=EN_3;end
			4'h1 :   begin out_reg = NUM_1; en=EN_3;end
			4'h2 :   begin out_reg = NUM_2; en=EN_3;end
			4'h3 :   begin out_reg = NUM_3; en=EN_3;end
			4'h4 :   begin out_reg = NUM_4; en=EN_3;end
			4'h5 :   begin out_reg = NUM_5; en=EN_3;end
			4'h6 :   begin out_reg = NUM_6; en=EN_3;end
			4'h7 :   begin out_reg = NUM_7; en=EN_3;end
			4'h8 :   begin out_reg = NUM_8; en=EN_3;end
			4'h9 :   begin out_reg = NUM_9; en=EN_3;end
			4'ha :   begin out_reg = NUM_A; en=EN_3;end
			4'hb :   begin out_reg = NUM_B; en=EN_3;end
			4'hc :   begin out_reg = NUM_C; en=EN_3;end
			4'hd :   begin out_reg = NUM_D; en=EN_3;end
			4'he :   begin out_reg = NUM_E; en=EN_3;end
			4'hf :   begin out_reg = NUM_F; en=EN_3;end
			default: begin out_reg = NUM_BLK; en=EN_3;end
			endcase  
		if(cnt[16:15] == 2'b11)
			case (num4)
			4'h0 :   begin out_reg = NUM_0; en=EN_4;end
			4'h1 :   begin out_reg = NUM_1; en=EN_4;end
			4'h2 :   begin out_reg = NUM_2; en=EN_4;end
			4'h3 :   begin out_reg = NUM_3; en=EN_4;end
			4'h4 :   begin out_reg = NUM_4; en=EN_4;end
			4'h5 :   begin out_reg = NUM_5; en=EN_4;end
			4'h6 :   begin out_reg = NUM_6; en=EN_4;end
			4'h7 :   begin out_reg = NUM_7; en=EN_4;end
			4'h8 :   begin out_reg = NUM_8; en=EN_4;end
			4'h9 :   begin out_reg = NUM_9; en=EN_4;end
			4'ha :   begin out_reg = NUM_A; en=EN_4;end
			4'hb :   begin out_reg = NUM_B; en=EN_4;end
			4'hc :   begin out_reg = NUM_C; en=EN_4;end
			4'hd :   begin out_reg = NUM_D; en=EN_4;end
			4'he :   begin out_reg = NUM_E; en=EN_4;end
			4'hf :   begin out_reg = NUM_F; en=EN_4;end
			default: begin out_reg = NUM_BLK; en=EN_4;end
			endcase  
	end 

endmodule
