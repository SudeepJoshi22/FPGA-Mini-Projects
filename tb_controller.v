`timescale 1ns / 1ps

module controller_tb;

    // Parameters
    parameter CLK_FREQ = 5;

    // DUT Signals
    reg clk;
    reg rst;
    reg ped_NS;
    reg ped_EW;
    wire NS_red, NS_yellow, NS_green;
    wire EW_red, EW_yellow, EW_green;
    wire ped_wait_NS, ped_wait_EW;

    // Instantiate the DUT
    controller #(
        .CLK_FREQ(CLK_FREQ)
    ) uut (
        .clk(clk),
        .rst(rst),
        .ped_NS(ped_NS),
        .ped_EW(ped_EW),
        .NS_red(NS_red),
        .NS_yellow(NS_yellow),
        .NS_green(NS_green),
        .EW_red(EW_red),
        .EW_yellow(EW_yellow),
        .EW_green(EW_green),
        .ped_wait_NS(ped_wait_NS),
        .ped_wait_EW(ped_wait_EW)
    );

    // Clock generation: 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Random pedestrian requests and reset sequence
    initial begin
        // Dump waveform
        $dumpfile("waves.vcd");
        $dumpvars(0, controller_tb);

        // Initial values
        rst = 1;
        ped_NS = 0;
        ped_EW = 0;

        // Hold reset for a few cycles
        #20;
        rst = 0;

        // Random pedestrian request generation
	repeat (100) begin
	  // wait some random number of cycles between pulses
	  repeat ($urandom_range(5, 20)) @(posedge clk);
	
	  // generate a one-cycle pulse
	  ped_NS = $urandom_range(0,1);
	  ped_EW = $urandom_range(0,1);
	  @(posedge clk);
	  ped_NS = 0;
	  ped_EW = 0;
	end

        // Wait some time after last request
        #200;
        $finish;
    end

endmodule
