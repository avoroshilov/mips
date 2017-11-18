`ifndef _im_tb
`define _im_tb

`include "src/im.v"

module im_tb;
	
	reg [31:0] read_addr = 'b0;
	reg [15:0] counter;
	wire [31:0] out;

	parameter IM_DATA = "./data/im_data.txt";
	parameter IM_LINES = 'd5;
	parameter DUMP_FILE = "./logs/im_tb.vcd";

	initial
	begin
		$dumpfile(DUMP_FILE);
		$dumpvars();
	end

	im #(.IM_DATA(IM_DATA)) IM0
	(
		.addr_i (read_addr),
		.data_o (out)
	);
	
	initial
	begin
		for ( counter = 0; counter < IM_LINES; counter = counter + 1 )
		begin
			$monitor("Line %d, addr %h, data %h", counter, read_addr, out);
			#1 read_addr = read_addr + (1 << 2);
		end
		$stop;
	end

endmodule

`endif
