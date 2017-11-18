`ifndef _cpu_top_lvl_tb
`define _cpu_top_lvltb

`include "./src/cpu_top_lvl.v"

`ifndef CLK_NUM
`define CLK_NUM 10
`endif

`ifndef VCD_DUMP
`define VCD_DUMP "./logs/cpu.vcd"
`endif

module cpu_tb();

	reg clk = 0;
	reg enable = 0;
	reg reset = 0;
	wire [31:0] out;

	cpu CPU
	(
		.clk_i(clk),
		.reset_i(reset),
		.enable_i(enable)
	);

	assign out = CPU.im_out;

    integer i;
	initial
	begin
		$dumpfile(`VCD_DUMP);
		$dumpvars();
		enable = 1;
		reset = 0;
        for (i = 0; i < `CLK_NUM; i = i + 1)
        begin
            clk = 1;
            #1;
            clk = 0;
            #1;
        end
        
	end

endmodule

`endif
