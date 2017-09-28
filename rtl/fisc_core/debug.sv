reg [3:0] dbg_regs [0:4];

task debugDigit(bit[1:0] digit, bit[3:0] value);
	dbg_regs[digit] <= value;
endtask

task debug2Digits(bit[3:0] value, logic left_side);
	if(left_side) begin
		dbg_regs[2] <= value[3:0];
		dbg_regs[3] <= value[7:4];
	end else begin
		dbg_regs[0] <= value[3:0];
		dbg_regs[1] <= value[7:4];
	end
endtask

task debug3Digits(bit[3:0] value, logic left_side);
	if(left_side) begin
		dbg_regs[1] <= value[3:0];
		dbg_regs[2] <= value[7:4];
		dbg_regs[3] <= value[11:8];
	end else begin
		dbg_regs[0] <= value[3:0];
		dbg_regs[1] <= value[7:4];
		dbg_regs[2] <= value[11:8];	
	end
endtask

task debug(bit[15:0] value);
	dbg_regs[0] <= value[3:0];
	dbg_regs[1] <= value[7:4];
	dbg_regs[2] <= value[11:8];
	dbg_regs[3] <= value[15:12];
endtask

task debug_uart_tx(bit[7:0] data);
	dbg_uart_din <= data;
	dbg_uart_wr_en <= 1;
endtask

task debug_uart_tx_stop;
	dbg_uart_wr_en <= 0;
endtask

function [7:0] debug_uart_rx;
	/* TODO */
endfunction

task debug_uart_rx_stop;
	dbg_uart_rdy_clr <= 0;
endtask

task debug_uart_stop;
	debug_uart_tx_stop();
	debug_uart_rx_stop();
endtask

task debugInit;
	/* Initialize 7 segment display */
	debug('hFFFF);

	/* Initialize UART wires */
	dbg_uart_din <= 0;
	debug_uart_stop();
endtask
