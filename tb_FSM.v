`timescale 1ns/1ps
`default_nettype none

module tb_traffic_FSM();

  // Signals
  reg clk;
  reg rst;
  reg pedestrian;

  wire pulse_1s;
  wire pulse_10s;

  wire reset_counter;
  wire red_light;
  wire yellow_light;
  wire green_light;

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset pulse
  initial begin
    rst = 1;
    #20;
    rst = 0;
  end

  // Pedestrian toggle
  initial begin
    pedestrian = 0;
    forever begin
      #150 pedestrian = $urandom_range(0, 1);
    end
  end

  wire reset_for_counter;
  assign reset_for_counter = rst | reset_counter;

  // Instantiate counter_pulse
  counter_pulse counter_inst (
    .clk(clk),
    .rst(reset_for_counter),
    .pulse_10s(pulse_10s),
    .pulse_1s(pulse_1s)
  );

  // Instantiate traffic_FSM
  traffic_FSM #(
    .STATE_ON_RESET(1)
  ) fsm_inst (
    .clk(clk),
    .rst(rst),
    .pulse_10s(pulse_10s),
    .pulse_1s(pulse_1s),
    .pedestrian(pedestrian),
    .reset_counter(reset_counter),
    .red_light(red_light),
    .yellow_light(yellow_light),
    .green_light(green_light)
  );

  // VCD waveform dump
  initial begin
    $dumpfile("traffic_FSM.vcd");
    $dumpvars(0, tb_traffic_FSM);
    #2000;  // Run long enough to see transitions
    $finish;
  end

endmodule
