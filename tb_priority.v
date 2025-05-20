`timescale 1ns/1ps

module priority_gen_tb;

  // Parameters
  localparam PRIORITY_TIME = 20;
  localparam CLK_PERIOD = 10; // 10 ns => 100 MHz clock

  // Testbench signals
  reg clk;
  reg rst;
  wire priority;

  // Instantiate DUT
  priority_gen #(
    .PRIORITY_TIME(PRIORITY_TIME)
  ) dut (
    .clk      (clk),
    .rst      (rst),
    .priority (priority)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Stimulus
  initial begin
    // Initialize reset
    rst = 1;
    // Hold reset for a few clock cycles
    repeat (1) @(posedge clk);
    rst = 0;

    // Let simulation run for some time to observe multiple toggles
    #(PRIORITY_TIME * CLK_PERIOD * 4);

    // Finish simulation
    $finish;
  end

  // Monitor
  initial begin
    $display("Time(ns)\tclk\trst\tcounter\tpriority");
  end

  // Dump waveforms
  initial begin
    $dumpfile("priority_gen_tb.vcd");
    $dumpvars(0, priority_gen_tb);
  end

endmodule

