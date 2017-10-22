`ifndef _pc
`define _pc

module pc(
	input				reset_i,
	input				enable_i,
	input				clk_i,
	input				stall_i,
	output	[`PC_SIZE]	addr_o,
	input	[`PC_SIZE]	addr_i,
	input				use_new_addr_i
	);

	parameter START_VALUE = 0;
	reg [`PC_SIZE] inner_pc = START_VALUE;

	assign addr_o = inner_pc;

	// TODO: check that
	always @( `EDGE_WRITE clk_i )
	begin
		if ( reset_i == 1)
		begin
			inner_pc <= START_VALUE;
		end
		if ( enable_i == 1 )
		begin
			if ( stall_i != 1 )
			begin
				if ( use_new_addr_i )
				begin
					inner_pc <= addr_i;
				end
				else
				begin
					inner_pc <= inner_pc + 4;
				end
			end
		end
	end

endmodule

`endif
