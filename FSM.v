module traffic_FSM #(
parameter STATE_ON_RESET = 1			// To Indicate the State on Reset, 1 - Red, 0 - Green
)(
	input 	wire	clk,
	input 	wire	rst,
	input 	wire 	pulse_10s,		// Pulse to indicate 10 seconds
	input 	wire 	pulse_1s,		// Pulse to indicate 1 seconds
	input	wire	pedestrian,
	output 	reg	reset_counter,		// Reset the counter on every state change
	output	reg	red_light,
	output 	reg 	yellow_light,
	output	reg	green_light
);
	parameter RED 		= 	2'h0;	// State for Red Light
	parameter YELLOW0	=	2'h1;	// State for Yellow light transition from Red to Green
	parameter GREEN		=	2'h2;	// State for Green Light
	parameter YELLOW1	=	2'h3;	// State for Yellow light transition from Green to Red

	reg 	[1:0] 	PS, NS;			// Registers to indicate present and next state

	// Reset logic
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			if(STATE_ON_RESET == 1)
				PS <= RED;
			else
				PS <= GREEN;
		end
		else begin
			PS <= NS;
		end		
	end

	// State change logic
	always @(PS, pulse_10s, pulse_1s) begin
		case(PS) 
			RED:		begin
						if(pulse_10s) begin
							NS 		<= 	YELLOW0;
							reset_counter 	<= 	1;
						end
						else begin
							NS		<= 	RED;
							reset_counter	<= 	0;
						end
					end
			YELLOW0:	begin
						if(pulse_1s) begin
							NS 		<= 	GREEN;
							reset_counter 	<= 	1;
						end
						else begin
							NS		<= 	YELLOW0;
							reset_counter	<= 	0;
						end
					end
			GREEN:		begin
						if(pulse_10s | pedestrian) begin
							NS 		<= 	YELLOW1;
							reset_counter 	<= 	1;
						end
						else begin
							NS		<= 	GREEN;
							reset_counter	<= 	0;
						end
					end
			YELLOW1:	begin
						if(pulse_1s) begin
							NS 		<= 	RED;
							reset_counter 	<= 	1;
						end
						else begin
							NS		<= 	YELLOW1;
							reset_counter	<= 	0;
						end
					end
		endcase
	end

	// Output Logic
	always @(PS) begin
		case(PS) 
			RED:		begin
						red_light	<= 	1;
						yellow_light	<= 	0;
						green_light	<=	0;
					end

			YELLOW0:	begin
						red_light	<= 	0;
						yellow_light	<= 	1;
						green_light	<=	0;
					end
			GREEN:		begin
						red_light	<= 	0;
						yellow_light	<= 	0;
						green_light	<=	1;
					end
			YELLOW1:	begin
						red_light	<= 	0;
						yellow_light	<= 	1;
						green_light	<=	0;
					end
		endcase
	end

endmodule
