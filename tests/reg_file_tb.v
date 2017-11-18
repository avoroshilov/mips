`ifndef _reg_file_tb
`define _reg_file_tb

`include "src/reg_file.v"

module reg_file_tb;

	reg [15:0] counter = 0;
	reg [4:0] reg_1_addr = 0;
	reg [4:0] reg_2_addr = 0;
	reg [4:0] reg_w_addr = 0;
	reg [31:0] reg_w_data = 0;
	reg reg_wr = 0;
	reg clk = 0;
	reg [2:0] status = 0;
	reg [31:0] rand_data [0:31];
	wire [31:0] reg_1_data;
	wire [31:0] reg_2_data;
	

	parameter REG_NUM = 32;
	parameter REG_FILE = "./data/reg_file_data.txt";

	register_file #(.REG_NUM(REG_NUM)) REG_FILE_0
	(
		.register_1_read_addr_i(reg_1_addr),
		.register_2_read_addr_i(reg_2_addr),
		.register_write_addr_i(reg_w_addr),
		.register_write_data_i(reg_w_data),
		.register_write_i(reg_wr),
		.clock_i(clk),
		.register_1_data_o(reg_1_data),
		.register_2_data_o(reg_2_data)
	);


	`ifdef LOAD_INIT_STATE_REG_FILE
	initial
	begin
		$readmemh(REG_FILE, REG_FILE_0.inner_registers, 0, REG_NUM-1);
	end
	`endif

	initial
	begin
		$dumpfile("./logs/reg_tb.vcd");
		$dumpvars();
		`ifdef DUMP_INNER_REG
		for (counter = 0; counter < REG_NUM; counter = counter + 1)
		begin
			$dumpvars(0, REG_FILE_0.inner_registers[counter]);
		end
		`endif
		#10;
		for (counter = 0; counter < REG_NUM; counter = counter + 1)
		begin
			reg_w_addr = counter;
			rand_data[counter] = $random;
			reg_w_data = rand_data[counter];
			reg_1_addr = counter;
			if (counter == 0)
			begin
				reg_2_addr = 0;
			end
			else
			begin
				reg_2_addr = counter - 1;
			end
			clk = !clk;
			reg_wr = 1;
			#1;
			clk = !clk;
			reg_wr = 0;
			#1;
			`ifdef DUMP_REG
				$writememh(REG_FILE, REG_FILE_0.inner_registers, 0, REG_NUM-1);
			`endif
		end
	end

endmodule


`endif
