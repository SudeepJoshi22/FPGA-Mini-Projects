`default_nettype none

module counter_pulse(
	input	wire	clk,
	input	wire	rst,
	output	wire	pulse_10s,
	output	wire	pulse_1s
);
	reg	[3:0] 	counter;

	always @(posedge clk) begin
		if(rst)
			counter <= 0;
		else
			counter <= counter + 1;
	end

	assign pulse_10s = 	(counter == 4'hA);
	assign pulse_1s	 =	(counter == 4'h1);

endmodule
