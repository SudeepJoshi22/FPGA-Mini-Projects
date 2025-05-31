`default_nettype none

module top #(
parameter CLK_FREQ = 50000000)(
	input  wire 	clk,
	input  wire 	rst,		// synchronous active high
	input  wire 	ped_NS,		// pedestrian request from North-South
	input  wire 	ped_EW,		// pedestrian request from East-West
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
	reg		rst_downstream;

	always @(posedge clk, posedge rst) begin
		if(rst) begin
			clk_div_counter <= 0;
			clk_div 	<= 0;
			rst_downstream	<= 1;
		end
		else if(clk_div_counter == ((CLK_FREQ/2) - 1)) begin
			clk_div		<= ~clk_div;
			rst_downstream	<= 0;
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

	wire		priority, not_priority;

	assign		reset_for_counter_ns = rst_downstream | reset_pulse_ns;
	assign		reset_for_counter_ew = rst_downstream | reset_pulse_ew;

	// Priority == 1 ---> North-South Lights have the priority
	// Priority == 0 ---> East-West Lights have the priority

	priority_gen #(
	.PRIORITY_TIME(20)
	) priority_inst (
	.clk	    	(clk_div),
	.rst	    	(rst_downstream),
	.priority   	(priority)
	);

	assign not_priority	= 	~priority;

	counter_pulse counter_pulse_inst_NS (
    	.clk        	(clk_div),
    	.rst        	(reset_for_counter_ns),
    	.pulse_10s  	(pulse_10s_signal_ns),
    	.pulse_1s   	(pulse_1s_signal_ns)
	);

	counter_pulse counter_pulse_inst_EW (
    	.clk        	(clk_div),
    	.rst        	(reset_for_counter_ew),
    	.pulse_10s  	(pulse_10s_signal_ew),
    	.pulse_1s   	(pulse_1s_signal_ew)
	);
	
	traffic_FSM #(
	.STATE_ON_RESET(0)
	) traffic_fsm_inst_NS (
    	.clk            (clk_div),
    	.rst            (rst_downstream),
    	.pulse_10s      (pulse_10s_signal_ns),
    	.pulse_1s       (pulse_1s_signal_ns),
	.priority	(priority),
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
    	.rst            (rst_downstream),
    	.pulse_10s      (pulse_10s_signal_ew),
    	.pulse_1s       (pulse_1s_signal_ew),
	.priority	(not_priority),
	.pedestrian	(ped_EW),
    	.reset_counter  (reset_pulse_ew),
    	.red_light      (EW_red),
    	.yellow_light   (EW_yellow),
    	.green_light    (EW_green)
	);	

	// Ped Wait Blinking logic
	reg	ped_NS_pulse, ped_EW_pulse;	

	// Detect the high pulse on the ped_XX signal
	always @(posedge ped_NS, posedge rst) begin
		if(rst | NS_red)
			ped_NS_pulse	<= 0;
		else if(ped_NS) 
			ped_NS_pulse	<= 1;
		else
			ped_NS_pulse	<= 0;
	end

	always @(posedge ped_EW, posedge rst) begin
		if(rst | EW_red)
			ped_EW_pulse	<= 0;
		else if(ped_EW) 
			ped_EW_pulse	<= 1;
		else
			ped_EW_pulse	<= 0;
	end

	// Blink the ped_wait_XX if the ped_XX_pulse is there and the light is green
	assign ped_wait_NS	= (ped_NS_pulse & NS_green) ? clk_div	: 0;
	assign ped_wait_EW	= (ped_EW_pulse & EW_green) ? clk_div	: 0;

endmodule
