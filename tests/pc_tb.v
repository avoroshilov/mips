`ifndef _pc_tb
`define _pc_tb

module pc_tb;
	reg clk = 1'b0;
	reg reset = 1'b0;
	reg enable = 1'b0;
	reg [31:0] addr = 32'b0;
	wire [31:0] out;

	pc #('h100500) PC0 
	(
		.clk_i		(clk),
		.reset_i	(reset),
		.enable_i	(enable),
		.addr_i		(addr),
		.addr_o		(out)
	);

	always
	begin
		#5 clk = !clk;
	end


	always @ (posedge clk)
	begin
		if (enable)
		begin
			addr <= addr + 1;
		end

		if (addr == 'h15)
		begin
			$stop;
		end
	end

	initial $monitor("Time: %t, reset: %d, enable: %d, input: %h, output %h", $time, reset, enable, addr, out);
	
	initial #20 enable = 1'b1;
	initial #115 reset = 1'b1;
	initial #135 reset = 1'b0;

	initial #149 reset = 1'b1;
	initial #156 reset = 1'b0;

//	initial #220 $stop;

endmodule

`endif
