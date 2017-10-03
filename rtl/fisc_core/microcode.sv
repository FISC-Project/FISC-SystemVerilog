`include "fisc_defines.sv"

/* Opcode format: */
/* 0 1 2 3 4      5 6 7 8 9 10  */
/*   OP CAT   |  SPECIFIC INSTR */

module Microcode(
	input clk, /* Clock signal     */
	input sos, /* Start Of Segment */
	input [`R_FMT_OPCODE_SZ-1:0] microcode_opcode, /* Opcode of the Microcode/segment  */
	output [`CTRL_WIDTH:0] microcode_ctrl,         /* Microcode's output control wires */
	
	/* Debug wires */
	output debug_en,
	output [3:0] dbg1,
	output [3:0] dbg2,
	output [3:0] dbg3,
	output [3:0] dbg4
);

	reg debug_en_reg = 0;
	reg [3:0] dbg1_reg = 0;
	reg [3:0] dbg2_reg = 0;
	reg [3:0] dbg3_reg = 0;
	reg [3:0] dbg4_reg = 0;
	
	assign debug_en = debug_en_reg;
	assign dbg1 = dbg1_reg;
	assign dbg2 = dbg2_reg;
	assign dbg3 = dbg3_reg;
	assign dbg4 = dbg4_reg;
	
	task debug(bit[15:0] value);
		debug_en_reg <= 1;
		dbg1_reg <= value[3:0];
		dbg2_reg <= value[7:4];
		dbg3_reg <= value[11:8];
		dbg4_reg <= value[15:12];
	endtask

	reg [`FUNC_WIDTH + `CTRL_WIDTH:0] microcode_ctrl_reg = 1;
	wire microcode_eos = microcode_ctrl_reg[0];

	assign microcode_ctrl = microcode_ctrl_reg[`CTRL_WIDTH:0];
	
	/* Internal Microcode Unit "variables" */
	reg [`CTRL_DEPTH_ENC-1:0] code_ip = 0; /* Microcode instruction pointer */
	/*
	-------------------------------------------------
		TODO TODO TODO TODO
	-------------------------------------------------
	reg [`CTRL_DEPTH_ENC-1:0]         call_stack[`CALLSTACK_SIZE];
	reg [`CTRL_DEPTH_ENC-1:0]         stack_ptr = 0;
	-------------------------------------------------
		TODO TODO TODO TODO
	-------------------------------------------------
	*/
	
	enum logic[2:0] {
		ST_WAITING,
		ST_DECODING1,
		ST_DECODING2,
		ST_DECODING3,
		ST_DONE
	} microcode_state = ST_WAITING;
	
	/* Microcode's Code ROM instantiation and wires */
	reg [7:0] code_rom_address;
	wire [`FUNC_WIDTH + `CTRL_WIDTH:0] code_rom_q;
	
	onchip_rom_microcode onchip_rom_microcode_inst(
		.address(code_rom_address),
		.clock(clk),
		.q(code_rom_q)
	);
	
	function [`FUNC_WIDTH + `CTRL_WIDTH:0] code_rom_read(input [`CTRL_DEPTH_ENC-1:0] address);
		code_rom_address = address;
		return code_rom_q;
	endfunction
	
	/* Microcode's Segment ROM instantiation and wires */
	wire [`SEGMENT_MAXCOUNT_ENC-1:0] seg_rom_address = microcode_opcode[`SEGMENT_MAXCOUNT_ENC-1:0];
	wire [`CTRL_DEPTH_ENC-1:0] seg_rom_q;
	
	onchip_mem_microcode_segment onchip_mem_microcode_segment_inst(
		.address(seg_rom_address),
		.clock(clk),
		.q(seg_rom_q)
	);
	
	/************************/
	/* Main Microcode tasks */
	/************************/
	task microcode_decode;
		case(microcode_state)
		ST_DECODING2:
			begin
				microcode_ctrl_reg = code_rom_read(seg_rom_q);
				microcode_state = microcode_eos ? ST_DONE : ST_DECODING3;
				code_ip <= seg_rom_q + 1'b1;
			end
		ST_DECODING3:
			begin
				microcode_ctrl_reg = code_rom_read(code_ip);
				microcode_state = microcode_eos ? ST_DONE : microcode_state;
				code_ip <= code_ip + 1'b1;
			end
		endcase
		
		debug(seg_rom_q);	
	endtask
	
	task microcode_finish;
		/* Important: LSB of control wire is eos */
		microcode_ctrl_reg[0] <= 0;
		microcode_state <= ST_WAITING;
	endtask
	
	task microcode_idle;
		/* Important: LSB of control wire is eos */
		microcode_ctrl_reg[0] <= 1;
	endtask

	always@(posedge clk) begin
		debug_en_reg <= 0;
		
		if(sos && microcode_state == ST_WAITING)
			microcode_state = ST_DECODING1;
			
		case(microcode_state)
		ST_WAITING:
			microcode_idle(); /* Stay idle */
		ST_DECODING1: 
			microcode_state = ST_DECODING2; /* Decode on the next clock cycle */
		ST_DECODING2, ST_DECODING3: 
			microcode_decode(); /* Decode instruction */
		ST_DONE:
			microcode_finish(); /* Acknowledge microcode's decoding completion to the CPU datapath */
		endcase
	end

endmodule
