`ifndef _reg_file
`define _reg_file

module register_file(
	input	wire	[`GPR_IDX_SIZE]	register_1_read_addr_i,
	input	wire	[`GPR_IDX_SIZE]	register_2_read_addr_i,
	input	wire	[`GPR_IDX_SIZE]	register_write_addr_i,
	input	wire	[`GPR_SIZE]		register_write_data_i,
	input	wire					register_write_i,
	input	wire					register_read_i,
	input	wire					clock_i,
	output	wire	[`GPR_SIZE]		register_1_data_o,
	output	wire	[`GPR_SIZE]		register_2_data_o,
	input wire reset_i
	);

	parameter REG_NUM = `GPR_NUM;

	reg [`GPR_SIZE] inner_registers [0:REG_NUM-1];

	reg [`GPR_SIZE] reg_1_data = 0;
	reg [`GPR_SIZE] reg_2_data = 0;

	parameter REGISTERS_IN = "./data/reg_file_data.txt";	
	parameter REGISTERS_OUT = "./data/reg_file_data_out.txt";
	
	initial
	begin
		$readmemh(REGISTERS_IN, inner_registers, 0, `GPR_NUM - 1);
	end
	
	assign register_1_data_o = reg_1_data;
	assign register_2_data_o = reg_2_data;

	// TODO: check that
	always @ ( `EDGE_OPERATE clock_i )
	begin
		if ( !reset_i )
		begin
			//$display("Reg 1 addr %d %x / reg 2 addr %d %x", register_1_read_addr_i, inner_registers[register_1_read_addr_i], register_2_read_addr_i, inner_registers[register_2_read_addr_i]);
			`ifdef DUMP_REG
				$writememh(REGISTERS_OUT, inner_registers);
			`endif
			if (register_write_i)
			begin
				if (register_write_addr_i != `GPR_IDX_BITS'b0)
				begin
					inner_registers[register_write_addr_i] <= register_write_data_i;
				end
			end
			
			if ( register_read_i )
			begin
				if (register_2_read_addr_i == `GPR_IDX_BITS'b0)
				begin
					reg_2_data <= `GPR_BITS'b0;
				end
				else if (register_2_read_addr_i == register_write_addr_i)
				begin
					reg_2_data <= register_write_data_i;
				end
				else
				begin
					reg_2_data <= inner_registers[register_2_read_addr_i];
				end
				
				if (register_1_read_addr_i == `GPR_IDX_BITS'b0)
				begin
					reg_1_data <= `GPR_BITS'b0;
				end
				else if (register_1_read_addr_i == register_write_addr_i)
				begin
					reg_1_data <= register_write_data_i;
				end
				else
				begin
					reg_1_data <= inner_registers[register_1_read_addr_i];
				end	
			end
			else
			begin
				reg_1_data <= 0;
				reg_2_data <= 0;
			end
		end
		else
		begin
			reg_1_data <= 0;
			reg_2_data <= 0;
		end
	end

endmodule

`endif
