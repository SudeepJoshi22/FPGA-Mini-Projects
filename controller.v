`default_nettype none

module controller #(
parameter CLK_FREQ = 50000000)(
	input wire 	clk,
	input wire 	rst,		// synchronous active high
	input wire 	ped_NS,		// pedestrian request from North-South
	input wire 	ped_EW,		// pedestrian request from East-West
	output wire 	NS_red,
	output wire 	NS_yellow,
	output wire 	NS_green,	// North-South Traffic signals
	output wire 	EW_red,
	output wire 	EW_yellow,
	output wire 	EW_green,	// East-West Traffic signals
	output wire	ped_wait_NS, 	// blinking light to show pedestrian waiting in NS
	output wire	ped_wait_EW	// blinking light to show pedestrian waiting in EW
);

	// Clock Divider
	parameter N	= $clog2(CLK_FREQ);

	reg	[N-1:0]	clk_div_counter;
	reg		clk_div;

	always @(posedge clk) begin
		if(rst) begin
			clk_div_counter <= 0;
			clk_div 	<= 0;
		end
		else if(clk_div_counter == ((CLK_FREQ/2) - 1)) begin
			clk_div		<= ~clk_div;
		end
		else begin
			clk_div_counter <= clk_div_counter + 1;
		end
	end
	
	// Module Instantiations
	
	wire 		reset_pulse_ns, reset_pulse_ew;
	wire 		pulse_10s_signal_ns, pulse_1s_signal_ns;
	wire		pulse_10s_signal_ew, pulse_1s_signal_ew;
	
	wire		reset_for_counter_ns, reset_for_counter_ew;

	assign		reset_for_counter_ns = rst | reset_pulse_ns;
	assign		reset_for_counter_ew = rst | reset_pulse_ew;

	counter_pulse counter_pulse_inst_NS (
    	.clk        (clk_div),
    	.rst        (reset_for_counter_ns),
    	.pulse_10s  (pulse_10s_signal_ns),
    	.pulse_1s   (pulse_1s_signal_ns)
	);

	counter_pulse counter_pulse_inst_EW (
    	.clk        (clk_div),
    	.rst        (reset_for_counter_ew),
    	.pulse_10s  (pulse_10s_signal_ew),
    	.pulse_1s   (pulse_1s_signal_ew)
	);
	
	traffic_FSM #(
	.STATE_ON_RESET(0)
	) traffic_fsm_inst_NS (
    	.clk            (clk_div),
    	.rst            (rst),
    	.pulse_10s      (pulse_10s_signal_ns),
    	.pulse_1s       (pulse_1s_signal_ns),
	.pedestrian	(ped_NS),
    	.reset_counter  (reset_pulse_ns),
    	.red_light      (NS_red),
    	.yellow_light   (NS_yellow),
    	.green_light    (NS_green)
	);	
	
	traffic_FSM #(
	.STATE_ON_RESET(1)
	) traffic_fsm_inst_EW (
    	.clk            (clk_div),
    	.rst            (rst),
    	.pulse_10s      (pulse_10s_signal_ew),
    	.pulse_1s       (pulse_1s_signal_ew),
	.pedestrian	(ped_EW),
    	.reset_counter  (reset_pulse_ew),
    	.red_light      (EW_red),
    	.yellow_light   (EW_yellow),
    	.green_light    (EW_green)
	);	
	
	// Pedestrian Crossing Logic
	reg		ped_wait_NS_reg;
	reg		ped_wait_EW_reg;

	always @(ped_NS) begin
		if(ped_NS) begin
			if(NS_red)
				ped_wait_NS_reg		<= 	0;
			else if(NS_green)
				ped_wait_NS_reg		<= 	clk_div;
			else
				ped_wait_NS_reg		<=	0;
		end
	end
	
	always @(ped_EW) begin
		if(ped_EW) begin
			if(EW_red)
				ped_wait_EW_reg		<= 	0;
			else if(EW_green)
				ped_wait_EW_reg		<= 	clk_div;
			else
				ped_wait_EW_reg		<= 	0;
		end
	end

	assign ped_wait_NS	= ped_wait_NS_reg;
	assign ped_wait_EW	= ped_wait_EW_reg;

endmodule
