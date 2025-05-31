`default_nettype none

module priority_gen #(
parameter PRIORITY_TIME = 20		// Will be in the units of clk time period
)(
	input	wire	clk,
	input	wire	rst,
	output	reg	priority	// Will alternate between high and low for the given PRIORITY_TIMEs the unit of clk
);
	parameter N = $clog2(PRIORITY_TIME);

	reg	[N-1:0]	counter;

	always @(posedge clk, posedge rst) begin
		if(rst) begin
			counter 	<= 	0;
			priority	<= 	0;
		end
		else if(counter == PRIORITY_TIME -1) begin
			priority	<=	~priority; 
			counter 	<= 	0;
		end
		else
			counter 	<= 	counter + 1;
	end

endmodule
