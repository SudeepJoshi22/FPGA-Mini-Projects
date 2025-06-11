`default_nettype none

module axi_lite_slave #(
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
);
	

	//// AW Channel ////
	
	reg	[7:0]	ir_aw_addr;
	wire		is_commit, is_addr_0;

	assign	aw_ready	= 	rst_n; 		// AW channel is ready when there is no reset

	// Register the write address when both valid and ready are high
	always @(posedge clk) begin
		if(!rst_n) begin
			ir_aw_addr 		<= 	'd0;
		end
		else if(aw_valid && aw_ready) begin
			ir_aw_addr 		<=	aw_addr;
		end
	end
	
	assign 	is_commit 	= 	(ir_aw_addr == 8'd4);
	assign	is_addr_0 	= 	(ir_aw_addr == 8'd0);	

	//// W Channel ////

	reg	[31:0]	ir_w_data;
	reg		ir_data_registered;

	wire		is_pkt_valid;

	assign	w_ready		=	rst_n;		// W channel is ready when there is no reset

	// Register the write data when both valid and ready are high
	always @(posedge clk) begin
		if(!rst_n) begin
			ir_w_data 		<=	'd0;
			ir_data_registered 	<=	1'b0;
		end
		else if(w_valid && w_ready) begin
			ir_w_data 		<=	w_data;
			ir_data_registered	<=	1'b1;
		end
		else begin
			ir_data_registered	<=	1'b0;
		end
	end

	assign	is_pkt_valid	=	(ir_w_data[31:24] == 8'hA5);
	
	//// R Channel ////
	reg		ir_send_response, ir_b_valid;

	// Send the response if the data is registered and hold the valid until ready is deasserted
	always @(posedge clk) begin
		if(!rst_n) begin
			ir_b_valid		<= 	1'b0;
			ir_send_response	<=	1'b0;
		end
		else if(ir_data_registered) begin
			ir_b_valid	<=	1'b1;
			ir_send_response <=	1'b1;
		end
		else begin
			ir_b_valid	<=	1'b0;
			ir_send_response <=	1'b0;
		end
	end
	
	assign		b_valid		=	ir_b_valid;
	assign		b_response	=	ir_send_response;

	//// Sort the valid and invalid packets between Valid and Invalid FIFOs ////
	wire	[31:0]	valid_pkt_data, invalid_pkt_data;
	wire		wr_valid, wr_invalid;

	assign	wr_valid	=	is_pkt_valid;
	assign	wr_invalid	=	~is_pkt_valid;

	assign	valid_pkt_data	= 	is_pkt_valid	? 	ir_data_registered	:	32'dZ;
	assign 	invalid_pkt_data =	is_pkt_valid	? 	32'dZ			: 	ir_data_registered;
	
	sync_fifo #(
    		.DATA_WIDTH(32),
    		.FIFO_DEPTH(BUFFER_SIZE)
	) valid_fifo_inst (
	    .clk(clk),
	    .rst_n(rst_n),
	    .wr_data(valid_pkt_data),
	    .wr_en(wr_valid),
	    .rd_data(),
	    .rd_en(),
	    .full(),
	    .empty()
	);

	sync_fifo #(
    		.DATA_WIDTH(32),
    		.FIFO_DEPTH(BUFFER_SIZE)
	) invalid_fifo_inst (
	    .clk(clk),
	    .rst_n(rst_n),
	    .wr_data(invalid_pkt_data),
	    .wr_en(wr_invalid),
	    .rd_data(),
	    .rd_en(),
	    .full(),
	    .empty()
	);

endmodule
