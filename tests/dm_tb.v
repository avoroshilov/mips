`ifndef _dm_tb
`define _dm_tb

`include "./src/dm.v"

module data_memory_tb();

	reg	[31:0]	data_addr = 0;
	reg	[31:0]	data = 0;
	reg		rd = 0;
	reg		wr = 0;
	reg		clk = 0;
	wire	[31:0]	data_out;

	parameter MEM_ENTRY_NUM = 8;
	parameter MEM_ENTRY_NUM_LOG2 = 3;
	parameter MEM_FILE = "./data/data_memory.txt";

//	parameter MEM_ENTRY_NUM = 128;
//	parameter MEM_ENTRY_NUM_LOG2 = 7;
//	parameter MEM_FILE = "./data/data_memory.txt";

	reg [15:0] counter = 0;

	data_memory #(.ENTRY_NUM(MEM_ENTRY_NUM),
		.ENTRY_NUM_LOG2(MEM_ENTRY_NUM_LOG2),
		.DATA_MEMORY(MEM_FILE)) DATA_MEM_0
	(
		.address_i(data_addr),
		.data_i(data),
		.write_data_i(wr),
		.read_data_i(rd),
		.clock_i(clk),
		.read_data_o(data_out)
	);

	initial
	begin
		$dumpfile("./logs/dm.vcd");
		$dumpvars();
		`ifdef DUMP_INNER_REG
			for (counter = 0; counter < MEM_ENTRY_NUM; counter = counter + 1)
			begin
				$dumpvars(0, DATA_MEM_0.inner_memory[counter]);
			end
		`endif
		#10;
		//read whole memory
		for (counter = 0; counter < MEM_ENTRY_NUM; counter = counter + 1)
		begin
			data_addr = counter << 2;
			rd = 1;
			clk = !clk;
			#1;
			rd = 0;
			clk = !clk;
			#1;
		end
		//
		//write counter to mem
		for (counter = 0; counter < MEM_ENTRY_NUM; counter = counter + 1)
		begin
			data_addr = counter << 2;
			data = counter;
			wr = 1;
			clk = !clk;
			#1;
			wr = 0;
			clk = !clk;
			#1;
			`ifdef DUMP_DM
				$writememh(MEM_FILE, DATA_MEM_0.inner_memory, 0, MEM_ENTRY_NUM-1);
			`endif
		end
		//
		//read and write simultaniously
		for (counter = 0; counter < MEM_ENTRY_NUM; counter = counter + 1)
		begin
			data_addr = counter << 2;
			data = counter << 4;
			wr = 1;
			rd = 1;
			clk = !clk;
			#1;
			wr = 0;
			rd = 0;
			clk = !clk;
			#1;
			`ifdef DUMP_DM
				$writememh(MEM_FILE, DATA_MEM_0.inner_memory, 0, MEM_ENTRY_NUM-1);
			`endif
		end
		//
	end

endmodule
`endif
