`include "defines.sv"
`include "microcode.sv"
`include "registers.sv"
`include "alu.sv"

module fisc_core(
	input clk,            /* Clock signal                          */
	input int_n,          /* Interrupt Request signal (maskable)   */
	input nmi_n,          /* Non*Maskable Interrupt Request Signal */
	input reset_n,        /* Reset signal                          */
	input wait_n,         /* Wait signal (Pauses CPU execution)    */

	output reg halt_n,    /* 0: CPU Executed a HALT instruction.         1: CPU is executing                                */
	output reg opcycle_n, /* 0: CPU is fetching Instruction from Memory. 1: CPU is executing an already fetched instruction */
	output reg ioack_n,   /* 0: CPU acknowledges IO request.             1: CPU is either serving an IRQ or is simply executing instructions in normal mode */
	output reg wr_n,      /* 0: CPU writes to memory.                    1: CPU is currently executing an instruction */
	output reg rd_n,      /* 0: CPU reads from memory.                   1: CPU is currently executing an instruction */

	inout      [63:0] d,  /* Data Bus    */
	output reg [63:0] a   /* Address Bus */
);

	enum logic[2:0] {
		ST_COLDSTART,
		ST_FETCH,
		ST_DECODE,
		ST_EXECUTE,
		ST_MEMACCESS,
		ST_WRITEBACK
	} cpu_state;

	/* Latched instruction */
	reg [31:0] instruction = 'b0;

	/***********************************************************/
	/* Microcode instantiation *********************************/
	/***********************************************************/
	/* TODO */
	/***********************************************************/

	/***********************************************************/
	/* Registers instantiation and wires ***********************/
	/***********************************************************/
	reg [5:0] rd_reg;
	reg [5:0] wr_reg;
	reg wr_fromreg;
	reg wr_fromimm;
	reg [63:0] din_reg;
	reg [63:0] dout_reg;

	Registers registers(
		.clk(clk),
		.rd_reg(rd_reg),
		.wr_reg(wr_reg),
		.wr_fromreg(wr_fromreg),
		.wr_fromimm(wr_fromimm),
		.din_reg(din_reg),
		.dout_reg(dout_reg)
	);
	/***********************************************************/
	
	/***********************************************************/
	/* ALU instantiation ***************************************/
	/***********************************************************/
	/* TODO */
	/***********************************************************/

	always@(clk or reset_n) begin
		if(reset_n == 0) begin
			/* Reset CPU:
			 * 1- Set PC to address 0
			 * 2- Set state to fetch */
			cpu_state <= ST_COLDSTART;
			
		end else if(clk == 1) begin
			/* Algorithm:
			 * 1- Fetch
			 * 2- Decode
			 * 3- Execute
			 * 4- Memory Access
			 * 5- Writeback */

			case(cpu_state)
				ST_COLDSTART: cpu_state <= ST_FETCH;
				ST_FETCH:     cpu_state <= ST_FETCH; /* TODO */
			endcase
		end
	end

endmodule