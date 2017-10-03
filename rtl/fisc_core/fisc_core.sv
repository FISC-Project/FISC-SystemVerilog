`include "fisc_defines.sv"
`include "microcode.sv"
`include "registers.sv"
`include "alu.sv"

module FISC_Core(
	input clk,     /* Clock signal                          */
	input int_n,   /* Interrupt Request signal (maskable)   */
	input nmi_n,   /* Non-Maskable Interrupt Request Signal */
	input reset_n, /* Reset signal                          */
	input wait_n,  /* Wait signal (Pauses CPU execution)    */

	output reg halt_n,  /* 0: CPU Executed a HALT instruction. 1: CPU is executing */
	output reg ioack_n, /* 0: CPU acknowledges IO request.     1: CPU is either serving an IRQ or is simply executing instructions in normal mode */
	output reg wr_a,    /* 0: CPU writes to memory.            1: CPU is currently executing an instruction (channel a) */
	output reg rd_a,    /* 0: CPU reads from memory.           1: CPU is currently executing an instruction (channel a) */
	output reg wr_b,    /* 0: CPU writes to memory.            1: CPU is currently executing an instruction (channel b) */
	output reg rd_b,    /* 0: CPU reads from memory.           1: CPU is currently executing an instruction (channel b) */

	input      [`FISC_INTEGER_SZ-1:0]      din_bus_a,  /* Data Input Bus  (channel a) */
	output reg [`FISC_INTEGER_SZ-1:0]      dout_bus_a, /* Data Output Bus (channel a) */
	output reg [`FISC_ADDRESS_BOOT_SZ-1:0] addr_bus_a, /* Address Bus     (channel a) */
	
	input      [`FISC_INTEGER_SZ-1:0]      din_bus_b,  /* Data Input Bus  (channel b) */
	output reg [`FISC_INTEGER_SZ-1:0]      dout_bus_b, /* Data Output Bus (channel b) */
	output reg [`FISC_ADDRESS_BOOT_SZ-1:0] addr_bus_b, /* Address Bus     (channel b) */

	/* Debug wires */
	output       dbg_init,
	output [3:0] dbg1,
	output [3:0] dbg2,
	output [3:0] dbg3,
	output [3:0] dbg4,
	/* Debug UART wires */
	output reg [7:0] dbg_uart_din,
	input      [7:0] dbg_uart_dout,
	output reg       dbg_uart_wr_en,
	input            dbg_uart_tx_busy,
	input            dbg_uart_rdy,
	output reg       dbg_uart_rdy_clr
);

`include "debug.sv"

	enum logic[3:0] {
		ST_COLDSTART,
		ST_FETCH1_MEMBLOCK,
		ST_FETCH2_INSTRUCTION,
		ST_DECODE,
		ST_EXECUTE,
		ST_MEMACCESS,
		ST_WRITEBACK
	} cpu_state;

	/* Latched memory block */
	reg [`FISC_INTEGER_SZ-1:0] memory_data;
	
	/* Latched instruction */
	reg [`FISC_INSTRUCTION_SZ-1:0] instruction = 'b0;
	
	/* Is CPU initialized */
	logic initialized = 0;

	/* Is CPU currently initializing */
	logic initializing = 0;

	/* Debug signals */
	assign dbg_init = initialized;
	assign dbg1 = dbg_regs[0];
	assign dbg2 = dbg_regs[1];
	assign dbg3 = dbg_regs[2];
	assign dbg4 = dbg_regs[3];

	reg [32:0] ctr = 0;

	/* Microcode instantiation and wires */
	wire microcode_clk_div = ctr == 7500000 ? 1'b1 : 1'b0;
	wire microcode_sos = cpu_state == ST_DECODE ? 1'b1 : 1'b0;
	wire microcode_eos = ~microcode_ctrl[0]; /* Microcode's End of Segment */
	wire [`R_FMT_OPCODE_SZ-1:0] microcode_opcode = instruction[`FISC_INSTRUCTION_SZ-1:`FISC_INSTRUCTION_SZ-`R_FMT_OPCODE_SZ];
	wire [`CTRL_WIDTH-1:0] microcode_ctrl;
	
	wire microcode_debug_en;
	wire [3:0] microcode_dbg1;
	wire [3:0] microcode_dbg2;
	wire [3:0] microcode_dbg3;
	wire [3:0] microcode_dbg4;
	
	Microcode microcode(
		.clk(microcode_clk_div),
		.sos(microcode_sos),
		.microcode_opcode(microcode_opcode),
		.microcode_ctrl(microcode_ctrl),
		.debug_en(microcode_debug_en),
		.dbg1(microcode_dbg1),
		.dbg2(microcode_dbg2),
		.dbg3(microcode_dbg3),
		.dbg4(microcode_dbg4)
	);

	/* Registers instantiation and wires */
	reg  [5:0] rd_reg;
	reg  [5:0] wr_reg;
	reg  wr_fromreg;
	reg  wr_fromimm;
	reg  [`FISC_INTEGER_SZ-1:0] din_reg;
	wire [`FISC_INTEGER_SZ-1:0] dout_reg;

	Registers registers(
		.clk(clk),
		.rd_reg(rd_reg),
		.wr_reg(wr_reg),
		.wr_fromreg(wr_fromreg),
		.wr_fromimm(wr_fromimm),
		.din_reg(din_reg),
		.dout_reg(dout_reg)
	);
	
	task write_register(input [5:0] regno, input [`FISC_INTEGER_SZ-1:0] din);
		/* Write immediate value into register */
		wr_reg <= regno;
		din_reg <= din;
		wr_fromimm <= 1;
	endtask
	
	task copy_register(input [5:0] regno_src, input [5:0] regno_dst);
		/* Write a register's value into another register */
		wr_reg <= regno_dst;
		rd_reg <= regno_src;
		wr_fromreg <= 1;
	endtask
	
	function [`FISC_INTEGER_SZ-1:0] read_register(input [5:0] regno);
		rd_reg = regno;
		return dout_reg;
	endfunction

	/* ALU instantiation and wires */
	wire [`FISC_INTEGER_SZ-1:0] alu_opA;
	wire [`FISC_INTEGER_SZ-1:0] alu_opB;
	wire [`ALU_F_SZ-1:0]        alu_f;
	wire [`FISC_INTEGER_SZ-1:0] alu_y;
	wire alu_flag_negative;
	wire alu_flag_zero;
	wire alu_flag_overflow;
	wire alu_flag_carry;

	ALU alu(
		.opA(alu_opA),
		.opB(alu_opB),
		.f(alu_f),
		.y(alu_y),
		.flag_negative(alu_flag_negative),
		.flag_zero(alu_flag_zero),
		.flag_overflow(alu_flag_overflow),
		.flag_carry(alu_flag_carry)
	);

	/* Main memory controls */
	task write_memory(logic channel, input [`FISC_ADDRESS_BOOT_SZ-1:0] address, input [`FISC_INTEGER_SZ-1:0] din);
		if(!channel) begin
			addr_bus_a <= address;
			dout_bus_a <= din;
			wr_a <= 1;
		end else begin
			addr_bus_b <= address;
			dout_bus_b <= din;
			wr_b <= 1;
		end
	endtask
	
	task enable_read_memory(logic channel, input [`FISC_ADDRESS_BOOT_SZ-1:0] address);
		if(!channel) begin
			addr_bus_a <= address;
			rd_a <= 1;
		end else begin
			addr_bus_b <= address;
			rd_b <= 1;
		end
	endtask

	function [`FISC_INTEGER_SZ-1:0] read_memory(logic channel);
		return !channel ? din_bus_a : din_bus_b;
	endfunction

	task reset_control_wires;
		/* Memory controls */
		wr_a = 0;
		wr_b = 0;
		rd_a = 0;
		rd_b = 0;
		
		/* Register controls */
		wr_reg = 0;
		wr_fromimm = 0;
		wr_fromreg = 0;
		
		/* Debug UART */
		debug_uart_stop();		
		
		fetch_word_tophalf <= 0;
		ctr <= 0;
	endtask
	
	/******************/
	/* Main CPU tasks */
	/******************/
	reg [`FISC_INTEGER_SZ-1:0] memory_block = 0;
	logic fetch_word_tophalf = 0;
	
	task coldstart;
		/* Resetting all controls before setting
		   up data buses for initialization */
		reset_control_wires();
		
		/* Reset CPU:
		 * 1- Set PC to address 0
		 * 2- Set state to fetch */
		write_register(32, 0);
		
		/* All done */
		initialized = 1;
		initializing = 0;
		cpu_state <= ST_FETCH1_MEMBLOCK;
	endtask
	
	task fetch1_memblock;
		logic [`FISC_INTEGER_SZ-1:0] current_pc = read_register(32);
		
		/* Fetch memory block by first enabling read and setting the address */
		enable_read_memory(0, !current_pc ? current_pc : current_pc / 8);
		
		cpu_state <= ST_FETCH2_INSTRUCTION;
	endtask

	task fetch2_instruction;
		/* This task actually fetches the 
		   instruction from the local memory block */
	
		/* Now we can latch the memory block */
		memory_block = read_memory(0);
		
		/* Grab instruction from fetched memory block */
		if(fetch_word_tophalf == 0) begin
			instruction = memory_block[`FISC_INSTRUCTION_SZ-1:0];			
			fetch_word_tophalf <= 1;
		end else begin
			instruction = memory_block[`FISC_INTEGER_SZ-1:`FISC_INSTRUCTION_SZ];		
			fetch_word_tophalf <= 0;
		end
		
		debug(instruction);
		
		/* Decode Instruction */
		cpu_state <= ST_DECODE;
	endtask
	
	task decode_instruction;
		if(microcode_debug_en) begin
			debugDigit(0, microcode_dbg1);
			debugDigit(1, microcode_dbg2);
			debugDigit(2, microcode_dbg3);
			debugDigit(3, microcode_dbg4);
		end
		
		if(microcode_eos == 1) begin
			/* Request next instruction to be fetched */
			// TODO: UNCOMMENT THE TWO LINES BELOW
			//cpu_state <= fetch_word_tophalf ? ST_FETCH2_INSTRUCTION : ST_FETCH1_MEMBLOCK;
			//write_register(32, read_register(32) + 4);
		end
		/* Else the Microcode unit is still driving the control wires */
	endtask
	
	always@(posedge clk) begin
		if(!initialized)
			debugInit();
			
		if(!wait_n) begin
			ctr <= 0;
			debug_uart_tx(109);
		end else begin
			debug_uart_tx_stop();
		end
			
		if(!reset_n) begin
			/* Trigger reset cycle */
			cpu_state <= ST_COLDSTART;
			initializing <= 1;
			initialized <= 0;

		end else begin
			/* Algorithm:
			 * 1- Fetch
			 * 2- Decode
			 * 3- Execute
			 * 4- Memory Access
			 * 5- Writeback */
			 
			if((initializing | initialized) & wait_n)
				if(ctr >= 7500000) begin
					ctr <= 0;
					
					case(cpu_state)
						ST_COLDSTART:
							coldstart();
						ST_FETCH1_MEMBLOCK:
							fetch1_memblock();
						ST_FETCH2_INSTRUCTION:
							fetch2_instruction();
						ST_DECODE:
							decode_instruction();
					endcase
				end else begin
					ctr <= ctr + 1;
				end
		end
	end

endmodule
