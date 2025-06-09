`timescale 1ns/1ps

module axi_lite_slave_tb;
  parameter BUFFER_SIZE = 16;
  parameter TIMEOUT_CYCLES = 10;

  reg         clk;
  reg         rst_n;
  reg  [7:0]  aw_addr;
  reg         aw_valid;
  wire        aw_ready;
  reg  [31:0] w_data;
  reg         w_valid;
  wire        w_ready;
  wire        b_response;
  wire        b_valid;
  reg         b_ready;

  integer     i, timeout;

  axi_lite_slave #(
    .BUFFER_SIZE(BUFFER_SIZE)
  ) uut (
    .clk(clk),
    .rst_n(rst_n),
    .aw_addr(aw_addr),
    .aw_valid(aw_valid),
    .aw_ready(aw_ready),
    .w_data(w_data),
    .w_valid(w_valid),
    .w_ready(w_ready),
    .b_response(b_response),
    .b_valid(b_valid),
    .b_ready(b_ready)
  );

  always #5 clk = ~clk;

  initial begin
    clk      = 0;
    rst_n    = 0;
    aw_addr  = 0;
    aw_valid = 0;
    w_data   = 0;
    w_valid  = 0;
    b_ready  = 1;

    #20 rst_n = 1;

    // Packet write and commit task
    for (i = 0; i < 2; i = i + 1) begin
      // Write address phase
      @(posedge clk);
      aw_addr  = 8'h00 + (i * 8);
      aw_valid = 1;
      @(posedge clk);
      aw_valid = 0;

      // Write data phase
      @(posedge clk);
      if (i == 0)
        w_data = {8'hA5, 24'h001122};
      else
        w_data = {8'hFF, 24'h334455};
      w_valid = 1;
      @(posedge clk);
      w_valid = 0;

      // Commit address phase
      @(posedge clk);
      aw_addr  = 8'h04;
      aw_valid = 1;
      @(posedge clk);
      aw_valid = 0;

      // Commit data phase
      @(posedge clk);
      w_data  = 32'h00000000;
      w_valid = 1;
      @(posedge clk);
      w_valid = 0;

      // Response read with timeout
      b_ready = 1;
      timeout = 0;
      while (!b_valid && timeout < TIMEOUT_CYCLES) begin
        @(posedge clk);
        timeout = timeout + 1;
      end
      if (b_valid)
        $display("Packet %0d response: %0b at time %0t", i+1, b_response, $time);
      else
        $display("Packet %0d response timeout at time %0t", i+1, $time);
      b_ready = 0;

      @(posedge clk);
    end

    #20;
    $finish;
  end

  initial begin
    $dumpfile("axi_lite_slave_tb.vcd");
    $dumpvars(0, axi_lite_slave_tb);
  end

endmodule
