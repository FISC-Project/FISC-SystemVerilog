`include "defines.sv"

module Registers(
	input clk,
	input [5:0] rd_reg,
	input [5:0] wr_reg,
	input wr_fromreg,           /* 1: regfile[wr_reg] = regfile[rd_reg] | 0: dout_reg = regfile[rd_reg] */
	input wr_fromimm,           /* 1: regfile[wr_reg = din_reg          | 0: dout_reg = regfile[rd_reg] */
	input [63:0] din_reg,
	output reg [63:0] dout_reg
);
	
	/***********************************************************/
	/* Registers supported *************************************/                                     
	/***********************************************************/
	reg[63:0] regfile [0:32]; /* General purpose registers         */
	reg[63:0] pc;             /* Program Counter                   */
	reg[63:0] esr;            /* Exception Syndrome Register       */
	reg[63:0] elr;            /* Exception Link / Return Register  */
	reg[11:0] cpsr;           /* Current Processor Status Register */
	reg[11:0] spsr[0:6];      /* Saved Processor Status Register   */
	reg[63:0] ivp;            /* Interrupt Vector Pointer          */
	reg[63:0] evp;            /* Exception Vector Pointer          */
	reg[63:0] pdp;            /* Page Directory Pointer            */
	reg[63:0] pfla;           /* Page Fault Linear Address         */
	/**********************************************************/

	/***********************************************************/
	/* Read logic **********************************************/
	/***********************************************************/
	assign dout_reg = 
		(wr_fromreg == 0 && wr_fromimm == 0) ?
			(rd_reg < 32) ? regfile[rd_reg] /* Read from General Purpose registers */
				/* Read from all other special registers */
				: (rd_reg == 32) ? pc
				: (rd_reg == 33) ? esr
				: (rd_reg == 34) ? elr
				: (rd_reg == 35) ? cpsr
				: (rd_reg >= 36 && rd_reg <= 41) ? spsr[rd_reg - 36]
				: (rd_reg == 42) ? ivp
				: (rd_reg == 43) ? evp
				: (rd_reg == 44) ? pdp
				: (rd_reg == 45) ? pfla
				: 'bZ			
			: 'bZ;
	/**********************************************************/

	/**********************************************************/
	/* Write logic ********************************************/
	/**********************************************************/
	always@(posedge clk) begin
		if(wr_fromreg == 1) begin
			/* Write from another register */
			if(wr_reg < 32)
				regfile[wr_reg] = dout_reg;
			else
				case(wr_reg)
					32: pc = dout_reg;
					33: esr = dout_reg;
					34: elr = dout_reg;
					35: cpsr = dout_reg;
					36,37,38,39,40,41: spsr[wr_reg - 36] = dout_reg;
					42: ivp = dout_reg;
					43: evp = dout_reg;
					44: pdp = dout_reg;
					45: pfla = dout_reg;
				endcase
		end else if(wr_fromimm == 1) begin
			/* Write from immediate value */
			if(wr_reg < 32)
				regfile[wr_reg] = din_reg;
			else
				case(wr_reg)
					32: pc = din_reg;
					33: esr = din_reg;
					34: elr = din_reg;
					35: cpsr = din_reg;
					36,37,38,39,40,41: spsr[wr_reg - 36] = din_reg;
					42: ivp = din_reg;
					43: evp = din_reg;
					44: pdp = din_reg;
					45: pfla = din_reg;
				endcase
		end
	end
	/**********************************************************/
endmodule