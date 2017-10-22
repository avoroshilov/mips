`ifndef _dm
`define _dm

`include "def_mips_isa.v"
`include "def_instr_fields.v"

`define	MEMMODE_BYTE	2'b00
`define	MEMMODE_HALF	2'b01
`define	MEMMODE_WORD	2'b11

module data_memory(
	input	wire	[`ALU_OP_SIZE]		address_i,
	input	wire	[`GPR_SIZE]			data_i,
	input	wire						write_data_i,
	input	wire						read_data_i,
	input	wire						clock_i,
	input	wire						sign_i,
	input	wire	[`MEM_MODE_SIZE]	mem_mode_i,
	output	wire	[`MEM_DATA_SIZE]	read_data_o,
	output	wire						stall_o,
	output	wire						dm_led_o
	);

	parameter ENTRY_NUM = 128;
	parameter ENTRY_NUM_LOG2 = 7;
	parameter DATA_MEMORY_IN = "./data/data_memory.txt";
	parameter DATA_MEMORY_OUT = "./data/data_memory_new.txt";

	reg dm_led_reg = 0;
	assign dm_led_o = dm_led_reg;

	reg [31:0] inner_memory [0:ENTRY_NUM-1];
	reg [31:0] reg_out = 0;
	assign read_data_o = reg_out;

	reg [31:0] tmp_reg;
	reg [31:0] tmp_reg2;

	
	//
//`define DBG_STALL_DM
`define DBG_STALL_CYCLES	10

	reg [`ALU_OP_SIZE]		STATE_address_i;
	reg [`GPR_SIZE]			STATE_data_i;
	reg						STATE_write_data_i;
	reg						STATE_read_data_i;
	reg						STATE_sign_i;
	reg [`MEM_MODE_SIZE]	STATE_mem_mode_i;
	
`ifdef DBG_STALL_DM
	`define ADDRESS_i	STATE_address_i
	`define DATA_i		STATE_data_i
	`define WR_FLAG_i	STATE_write_data_i
	`define RD_FLAG_i	STATE_read_data_i
	`define SIGN_i		STATE_sign_i
	`define MEMMODE_i	STATE_mem_mode_i
`else
	`define ADDRESS_i	address_i
	`define DATA_i		data_i
	`define WR_FLAG_i	write_data_i
	`define RD_FLAG_i	read_data_i
	`define SIGN_i		sign_i
	`define MEMMODE_i	mem_mode_i
`endif
	
	reg DBG_isStall = 0;
	reg [4:0] DBG_stall_counter = 0;
	
	assign stall_o = DBG_isStall;
	
	initial
	begin
		$readmemh(DATA_MEMORY_IN, inner_memory, 0, ENTRY_NUM - 1);	
	end
	
	always @ ( address_i, read_data_i, mem_mode_i, sign_i, tmp_reg )
	begin
	
`ifdef DBG_STALL_DM
		// TODO: unify this state retention with the on in write
		if ( (DBG_stall_counter == 0) && read_data_i )
		begin
			STATE_address_i <= address_i;
			STATE_data_i <= data_i;
			STATE_write_data_i <= write_data_i;
			STATE_read_data_i <= read_data_i;
			STATE_sign_i <= sign_i;
			STATE_mem_mode_i <= mem_mode_i;

			DBG_isStall = 1;
			DBG_stall_counter <= 1;
		end
`else
		tmp_reg <= inner_memory[address_i[(ENTRY_NUM_LOG2-1+2):2]];

		if ( read_data_i )
		begin
			case (mem_mode_i)
					`MEMMODE_BYTE: reg_out <= (sign_i == 1) ?
												{ {24{1'b0}}, tmp_reg[7:0] } :
												{ {24{tmp_reg[7]}}, tmp_reg[7:0] };
					`MEMMODE_HALF: reg_out <= (sign_i == 1) ?
												{ {16{1'b0}}, tmp_reg[15:0] } :
												{ {16{tmp_reg[15]}}, tmp_reg[15:0] };
					`MEMMODE_WORD: reg_out <= tmp_reg;
					default: reg_out <= 123;
			endcase
		end
		else
		begin
			reg_out <= 321;
		end
`endif
	end
	
	// TODO: check that
	always @ ( `EDGE_OPERATE clock_i )
	begin
		tmp_reg2 = inner_memory[`ADDRESS_i[(ENTRY_NUM_LOG2-1+2):2]];
		
`ifdef DBG_STALL_DM

		if (DBG_isStall)
		begin
			DBG_stall_counter <= DBG_stall_counter + 1;
		end
		
		// TODO: unify this state retention with the on in read
		if ( (DBG_stall_counter == 0) && write_data_i )
		begin
			STATE_address_i <= address_i;
			STATE_data_i <= data_i;
			STATE_write_data_i <= write_data_i;
			STATE_read_data_i <= read_data_i;
			STATE_sign_i <= sign_i;
			STATE_mem_mode_i <= mem_mode_i;

			DBG_isStall = 1;
			DBG_stall_counter <= 1;
		end
		else if (DBG_stall_counter == `DBG_STALL_CYCLES)
		begin
			if (STATE_write_data_i == 1)
			begin
				dm_led_reg <= tmp_reg2[0];	

				case (`MEMMODE_i)
					`MEMMODE_BYTE: tmp_reg2 = `DATA_i[7:0];
					`MEMMODE_HALF: tmp_reg2 = `DATA_i[15:0];
					`MEMMODE_WORD: tmp_reg2 = `DATA_i;
					default: tmp_reg2 = 3344;
				endcase

				inner_memory[`ADDRESS_i[(ENTRY_NUM_LOG2-1+2):2]] <= tmp_reg2;
			end
			else
			begin
				case (`MEMMODE_i)
					`MEMMODE_BYTE: reg_out <= (`SIGN_i == 1) ?
												{ {24{1'b0}}, tmp_reg2[7:0] } :
												{ {24{tmp_reg2[7]}}, tmp_reg2[7:0] };
					`MEMMODE_HALF: reg_out <= (`SIGN_i == 1) ?
												{ {16{1'b0}}, tmp_reg2[15:0] } :
												{ {16{tmp_reg2[15]}}, tmp_reg2[15:0] };
					`MEMMODE_WORD: reg_out <= tmp_reg2;
					default: reg_out <= 123;
				endcase
			end

			DBG_stall_counter <= 0;
			DBG_isStall = 0;
		end
`else
		case (`MEMMODE_i)
			`MEMMODE_BYTE: tmp_reg2 = `DATA_i[7:0];
			`MEMMODE_HALF: tmp_reg2 = `DATA_i[15:0];
			`MEMMODE_WORD: tmp_reg2 = `DATA_i;
			default: tmp_reg2 = 3344;
		endcase

		if (write_data_i == 1)
		begin
			dm_led_reg <= tmp_reg2[0];	
			inner_memory[address_i[(ENTRY_NUM_LOG2-1+2):2]] <= tmp_reg2;
		end
`endif		
		else
		begin
			tmp_reg2 = 5566;
		end
		`ifdef DUMP_DM
			$writememh(DATA_MEMORY_OUT, inner_memory);
		`endif
	end

endmodule

`endif

