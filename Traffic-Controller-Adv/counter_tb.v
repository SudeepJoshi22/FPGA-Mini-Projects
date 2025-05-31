`timescale 1ns / 1ps

module counter_pulse_tb;

    // Testbench signals
    reg clk;
    reg rst;
    wire pulse_10s;
    wire pulse_1s;

    // Instantiate the DUT (Device Under Test)
    counter_pulse uut (
        .clk        (clk),
        .rst        (rst),
        .pulse_10s  (pulse_10s),
        .pulse_1s   (pulse_1s)
    );

    // Clock generation: 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Toggle every 5ns
    end

    // Stimulus
    initial begin
        // Dump waveform
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_pulse_tb);

        // Apply reset
        rst = 1;
        #20;
        rst = 0;

        // Let counter run for a few cycles
        #200;

        $finish;
    end

endmodule

