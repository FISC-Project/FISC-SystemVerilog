/* Generic UART module fetched from: https://github.com/jamieiles/uart */

`include "baud_rate_generator.sv"
`include "transmitter.sv"
`include "receiver.sv"

module uart(
	input  [7:0] din,
	output [7:0] dout,
	
	input clk_50m,

	output tx,
	input  wr_en,
	output tx_busy,
	
	input  rx,
	output rdy,
	input  rdy_clr
);

	wire rxclk_en, txclk_en;

	uart_baud_rate_gen uart_baud(
		.clk_50m(clk_50m),
		.rxclk_en(rxclk_en),
		.txclk_en(txclk_en)
	);

	uart_transmitter uart_tx(
		.din(din),
		.wr_en(wr_en),
		.clk_50m(clk_50m),
		.clken(txclk_en),
		.tx(tx),
		.tx_busy(tx_busy)
	);

	uart_receiver uart_rx(
		.rx(rx),
		.rdy(rdy),
		.rdy_clr(rdy_clr),
		.clk_50m(clk_50m),
		.clken(rxclk_en),
		.data(dout)
	);

endmodule
