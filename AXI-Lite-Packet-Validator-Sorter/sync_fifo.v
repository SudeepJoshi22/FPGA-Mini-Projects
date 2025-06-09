`default_nettype none

module sync_fifo #(
parameter DATA_WIDTH = 32,
parameter FIFO_DEPTH  = 16	
)(
	input	wire				clk,
	input	wire				rst_n,
	// Write Interface
	input	wire	[DATA_WIDTH-1:0]	wr_data,
	input	wire				wr_en,
	// Read Interface
	output	reg	[DATA_WIDTH-1:0]	rd_data,
	input	wire				rd_en,
	// FIFO flags
	output	wire				full,
	output	wire				empty	
);
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

    reg [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];  // FIFO memory
    reg [ADDR_WIDTH:0]   wr_ptr;                // Write pointer
    reg [ADDR_WIDTH:0]   rd_ptr;                // Read pointer

    wire [ADDR_WIDTH:0]  fifo_count;

    assign fifo_count = wr_ptr - rd_ptr;
    assign full  = (fifo_count == FIFO_DEPTH);
    assign empty = (fifo_count == 0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            rd_data <= 0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
            rd_ptr <= rd_ptr + 1;
        end
    end

endmodule
