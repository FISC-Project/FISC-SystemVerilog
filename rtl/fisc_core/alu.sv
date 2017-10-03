`include "fisc_defines.sv"

module ALU(
	input  [`FISC_INTEGER_SZ-1:0] opA, /* Operand A    */
	input  [`FISC_INTEGER_SZ-1:0] opB, /* Operand B    */
	input  [`ALU_F_SZ-1:0]        f,   /* ALU Function */
	output [`FISC_INTEGER_SZ-1:0] y,   /* ALU output   */
	
	/* ALU Flags */
	output flag_negative,
	output flag_zero,
	output flag_overflow,
	output flag_carry
);

	assign y = 
		f == `ALU_F_SZ'b0000 ? opA & opB : 
		f == `ALU_F_SZ'b0001 ? opA | opB :
		f == `ALU_F_SZ'b0010 ? opA + opB :
		f == `ALU_F_SZ'b0110 ? opA - opB :
		f == `ALU_F_SZ'b0111 ? (opA < opB ? 1 : 0) :
		f == `ALU_F_SZ'b1100 ? ~(opA | opB) : 'hX;
	
	assign flag_negative = 0; /* TODO */
	assign flag_zero = !y ? 1'b1 : 1'b0;
	assign flag_overflow = 0; /* TODO */
	assign flag_carry = 0; /* TODO */
	
endmodule
