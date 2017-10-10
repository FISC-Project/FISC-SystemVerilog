`include "fisc_defines.sv"

module Registers(
	input       clk,
	input [5:0] rd_reg1, /* Read channel 1 */
	input [5:0] rd_reg2, /* Read channel 2 */
	input [5:0] wr_reg,
	input       wr, /* 1: regfile[wr_reg] = din  | 0: - */
	input  [`FISC_INTEGER_SZ-1:0] din,
	output [`FISC_INTEGER_SZ-1:0] dout1, /* Data output from channel 1 */
	output [`FISC_INTEGER_SZ-1:0] dout2, /* Data output from channel 2 */
	
	/* Flags */
	input set_flags,
	input flag_negative,
	input flag_zero,
	input flag_overflow,
	input flag_carry
);
	
	/* Registers supported */                                     
	reg [`FISC_INTEGER_SZ-1:0] regfile [0:`FISC_REGISTER_GP_COUNT]; /* General purpose registers */
	reg [`FISC_INTEGER_SZ-1:0] pc;   /* Program Counter                   */
	reg [`FISC_INTEGER_SZ-1:0] esr;  /* Exception Syndrome Register       */
	reg [`FISC_INTEGER_SZ-1:0] elr;  /* Exception Link / Return Register  */
	reg [11:0] cpsr;                 /* Current Processor Status Register */
	reg [11:0] spsr [0:6];           /* Saved Processor Status Register   */
	reg [`FISC_INTEGER_SZ-1:0] ivp;  /* Interrupt Vector Pointer          */
	reg [`FISC_INTEGER_SZ-1:0] evp;  /* Exception Vector Pointer          */
	reg [`FISC_INTEGER_SZ-1:0] pdp;  /* Page Directory Pointer            */
	reg [`FISC_INTEGER_SZ-1:0] pfla; /* Page Fault Linear Address         */

	/* Read logic */
	assign dout1 = 
		(rd_reg1 < 32) ? regfile[rd_reg1] /* Read from General Purpose registers */
			/* Read from all other special registers */
			: (rd_reg1 == 32) ? pc
			: (rd_reg1 == 33) ? esr
			: (rd_reg1 == 34) ? elr
			: (rd_reg1 == 35) ? cpsr
			: (rd_reg1 >= 36 && rd_reg1 <= 41) ? spsr[rd_reg1 - 36]
			: (rd_reg1 == 42) ? ivp
			: (rd_reg1 == 43) ? evp
			: (rd_reg1 == 44) ? pdp
			: (rd_reg1 == 45) ? pfla
			: 'bZ;
			
	assign dout2 = 
		(rd_reg2 < 32) ? regfile[rd_reg2] /* Read from General Purpose registers */
			/* Read from all other special registers */
			: (rd_reg2 == 32) ? pc
			: (rd_reg2 == 33) ? esr
			: (rd_reg2 == 34) ? elr
			: (rd_reg2 == 35) ? cpsr
			: (rd_reg2 >= 36 && rd_reg2 <= 41) ? spsr[rd_reg2 - 36]
			: (rd_reg2 == 42) ? ivp
			: (rd_reg2 == 43) ? evp
			: (rd_reg2 == 44) ? pdp
			: (rd_reg2 == 45) ? pfla
			: 'bZ;

	/* Write logic */
	always@(posedge clk) begin
		if(wr) begin
			/* Write from immediate value */
			if(wr_reg < 32)
				regfile[wr_reg] = din;
			else
				case(wr_reg)
					32: pc = din;
					33: esr = din;
					34: elr = din;
					35: cpsr = din[11:0];
					36,37,38,39,40,41: spsr[wr_reg - 36] = din[11:0];
					42: ivp = din;
					43: evp = din;
					44: pdp = din;
					45: pfla = din;
				endcase
				
			if(set_flags)
				cpsr[11:8] <= {flag_negative, flag_zero, flag_overflow, flag_carry};
		end
	end
endmodule
