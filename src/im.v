`ifndef _im
`define _im

module im(
	input						enable_i,
	input	wire				clk_i,
	input	wire [`PC_SIZE]		addr_i,
	input	wire				read_i,
	input	wire				write_i,
	input	wire [`INSTR_SIZE]	data_i,
	output	wire [`INSTR_SIZE]	data_o
	);
	
	parameter MEM_ENTRIES = 128; 
	parameter IM_DATA = "./data/im_data.txt";

	reg [`INSTR_SIZE] inner_mem [0:MEM_ENTRIES-1];
	
	initial 
	begin
		$readmemh(IM_DATA, inner_mem, 0, MEM_ENTRIES-1);
	end

	reg [`INSTR_SIZE] data = 0;
	assign data_o = data;
	
	// TODO: check that
	always @ ( `EDGE_OPERATE clk_i )
	begin
		if ( enable_i )
		begin
			if ( read_i )
			begin
				if (addr_i < MEM_ENTRIES)
					data <= inner_mem[addr_i[8:2]][`INSTR_SIZE];
				else
					data <= 0;
			end
			if ( write_i )
			begin
				inner_mem[addr_i[8:2]] <= data_i;
			end
		end
		else
		begin
			data <= 0;
		end
	end

endmodule
`endif
