// sync_fifo_tb.v
`timescale 1ns/1ps

module sync_fifo_tb;
  parameter DATA_WIDTH = 32;
  parameter FIFO_DEPTH = 16;
  localparam MAX_OPS   = 32;

  reg                     clk, rst_n;
  reg  [DATA_WIDTH-1:0]   wr_data;
  reg                     wr_en, rd_en;
  wire [DATA_WIDTH-1:0]   rd_data;
  wire                    full, empty;

  // DUT instantiation
  sync_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH)
  ) dut (
    .clk    (clk),
    .rst_n  (rst_n),
    .wr_data(wr_data),
    .wr_en  (wr_en),
    .rd_en  (rd_en),
    .rd_data(rd_data),
    .full   (full),
    .empty  (empty)
  );

  reg [DATA_WIDTH-1:0] expected [0:MAX_OPS-1];
  integer write_cnt, read_cnt, i;

  // Clock: 10 ns period
  always #5 clk = ~clk;

  initial begin
    // Init
    clk       = 0;
    rst_n     = 0;
    wr_en     = 0;
    rd_en     = 0;
    wr_data   = 0;
    write_cnt = 0;
    read_cnt  = 0;

    // Release reset
    #20 rst_n = 1;

    // WRITE phase
    for (i = 0; i < MAX_OPS; i = i + 1) begin
      @(posedge clk);
      if (!full) begin
        wr_en     = 1;
        wr_data   = i;
        expected[write_cnt] = wr_data;
        write_cnt = write_cnt + 1;
      end else begin
        wr_en = 0;
      end
    end
    wr_en = 0;

    // Small pause
    repeat (5) @(posedge clk);

    // READ & DISPLAY phase
    for (i = 0; i < write_cnt; i = i + 1) begin
      @(posedge clk);
      if (!empty) begin
        rd_en = 1;
        @(posedge clk);
        $display("Read @%0t: %0h", $time, rd_data);
        read_cnt = read_cnt + 1;
      end else begin
        rd_en = 0;
      end
    end
    rd_en = 0;

    #20;
    $display("Test complete: wrote %0d, read %0d", write_cnt, read_cnt);
    $finish;
  end

  // Waveform dump
  initial begin
    $dumpfile("sync_fifo_tb.vcd");
    $dumpvars(0, sync_fifo_tb);
  end

endmodule
