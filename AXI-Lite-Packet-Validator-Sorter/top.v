`default_nettype none

module axi_axi_lite_slave #(
parameter BUFFER_SIZE = 16 
)(
	input	wire		clk,
	input	wire		rst_n,
	// AW (Address Write) Channel (master -> slave)
	input	wire	[7:0]	aw_addr,
	input	wire		aw_valid,
	output	wire		aw_ready,
	// W  (Data Write) Channel (master -> slave)
	input	wire	[31:0]	w_data,
	input	wire		w_valid,
	output	wire		w_ready,
	// B  (Write Response) Channel (slave -> master)
	output	wire		b_response,
	output	wire		b_valid,
	input	wire		b_ready
)


endmodule
