`ifndef _cache_rw
`define _cache_rw

//`define GOOD_VERILOG_SIM

`ifndef GOOD_VERILOG_SIM
`define AR2D_ACCESS(x, y, sizeX)	x+y*sizeX
`define AR2D_DEFINE(sizeX, sizeY)	0:sizeX*sizeY-1
`else
`define AR2D_ACCESS(x, y, sizeX)	x][y
`define AR2D_DEFINE(sizeX, sizeY)	0:sizeX-1][0:sizeY-1
`endif

module cache_rw
	(
	input	wire	[`GLOB_CLKCOUNT_SIZE]	GLOB_clk_count_i,
	
	// Cache interface wires
	input	wire	[`ALU_OP_SIZE]		address_i,
	input	wire	[`GPR_SIZE]			data_i,
	input	wire						write_data_i,
	input	wire						read_data_i,
	input	wire						clock_i,
	input	wire						sign_i,
	input	wire	[`MEM_MODE_SIZE]	mem_mode_i,
	output	wire	[`MEM_DATA_SIZE]	read_data_o,
	output	wire						stall_o,
	output	wire						dm_led_o,
	
	// Memory interface wires
	output	wire	[`ALU_OP_SIZE]		MIF_address_o,
	output	wire	[`GPR_SIZE]			MIF_data_o,
	output	wire						MIF_write_data_o,
	output	wire						MIF_read_data_o,
	output	wire						MIF_clock_o,
	output	wire						MIF_sign_o,
	output	wire	[`MEM_MODE_SIZE]	MIF_mem_mode_o,
	input	wire	[`MEM_DATA_SIZE]	MIF_read_data_i,
	input	wire						MIF_stall_i,
	input	wire						MIF_dm_led_i
	);

	parameter ADRESS_SIZE_LOG2			= 5;	// 32 bit
	parameter CACHELINE_SIZE_LOG2		= 5;	// 32 (bytes)
	parameter CACHE_SET_WAYS_LOG2		= 2;	// 4-way assoc
	parameter CACHE_SETS_LOG2			= 3;	// 8 sets
	
	// Default cache size = 32 * 8 * 4 = 1024 KB
	// (not taking into account tag store)
	// Index bits = CACHE_SETS_LOG2
	// Offset bits = CACHELINE_SIZE_LOG2
	// Tag bits = (1<<ADRESS_SIZE_LOG2) - CACHELINE_SIZE_LOG2 - CACHE_SETS_LOG2 = 22

	
	
	
	assign MIF_clock_o = clock_i;
	
`define IHATECONSOLES
	
`ifdef IHATECONSOLES
	assign MIF_address_o = address_i;
	assign MIF_data_o = data_i;
	assign MIF_write_data_o = write_data_i;
	assign MIF_read_data_o = read_data_i;
	assign MIF_sign_o = sign_i;
	assign MIF_mem_mode_o = mem_mode_i;
	
	assign read_data_o = MIF_read_data_i;
	assign stall_o = MIF_stall_i;
	assign dm_led_o = MIF_dm_led_i;
`else

	reg [`GPR_SIZE] reg_out;

	assign read_data_o = reg_out;
	assign stall_o = DBG_isStall;

	// Registers for memory interface
	reg [`ALU_OP_SIZE]		STATE_MIF_address_o = 0;
	reg [`GPR_SIZE]			STATE_MIF_data_o = 0;
	reg						STATE_MIF_write_data_o = 0;
	reg						STATE_MIF_read_data_o = 0;
	reg						STATE_MIF_sign_o = 0;
	reg	[`MEM_MODE_SIZE]	STATE_MIF_mem_mode_o = 0;
	reg	[`MEM_DATA_SIZE]	STATE_MIF_read_data_i = 0;
	reg						STATE_MIF_stall_i = 0;
	reg						STATE_MIF_dm_led_i = 0;
	
	assign MIF_address_o = STATE_MIF_address_o;
	assign MIF_data_o = STATE_MIF_data_o;
	assign MIF_write_data_o = STATE_MIF_write_data_o;
	assign MIF_read_data_o = STATE_MIF_read_data_o;
	assign MIF_sign_o = STATE_MIF_sign_o;
	assign MIF_mem_mode_o = STATE_MIF_mem_mode_o;

	reg is_waiting_mem = 0;
	
`define DBG_STALL_CACHE
`define DBG_CACHE_STALL_CYCLES	10

	reg DBG_isStall = 0;
	reg [4:0] DBG_stall_counter = 0;

	reg [`ALU_OP_SIZE]		STATE_address_i;
	reg [`GPR_SIZE]			STATE_data_i;
	reg						STATE_write_data_i;
	reg						STATE_read_data_i;
	reg						STATE_sign_i;
	reg [`MEM_MODE_SIZE]	STATE_mem_mode_i;
	

	localparam CACHE_SETS = (1<<CACHE_SETS_LOG2);
	localparam CACHE_SET_WAYS = (1<<CACHE_SET_WAYS_LOG2);
	
	localparam ADDR_BITS = (1<<ADRESS_SIZE_LOG2);
	localparam IDX_BITS = CACHE_SETS_LOG2;
	localparam OFF_BITS = CACHELINE_SIZE_LOG2;
	localparam TAG_BITS = ADDR_BITS - (OFF_BITS + IDX_BITS);

	// Intermediate info for MEM->Cache reads
	// TODO counterr size could be smaller (we're reading with words)
	reg		[CACHELINE_SIZE_LOG2-1:0] cacheline_mem_reads = 0;
	wire	[5+CACHELINE_SIZE_LOG2-1:0] cacheline_memreads_shft;
	assign cacheline_memreads_shft = { cacheline_mem_reads, 5'b0 };
	
	reg [IDX_BITS-1:0]				STATE_memread_set_id;
	reg [CACHE_SET_WAYS_LOG2-1:0]	STATE_memread_way_id;

	
	// Data store
	reg [(1<<(CACHELINE_SIZE_LOG2+3))-1:0] data_memory [`AR2D_DEFINE(CACHE_SETS, CACHE_SET_WAYS)];//[0:CACHE_SETS-1][0:CACHE_SET_WAYS-1];
	
	reg [(1<<(CACHELINE_SIZE_LOG2+3))-1:0] data_wires [0:CACHE_SET_WAYS-1];
	
	reg [(1<<(CACHELINE_SIZE_LOG2+3))-1:0] chosen_line;
	
	reg [`GPR_SIZE]	cache_word;
	
	reg [CACHE_SET_WAYS_LOG2-1:0]	way_number;
	
	// Tag store
	// TTE = Tag Table Entry
	reg	[CACHE_SET_WAYS-1:0]	TTE_invalid	[0:CACHE_SETS-1];
	reg	[CACHE_SET_WAYS-1:0]	TTE_dirty	[0:CACHE_SETS-1];
	reg	[TAG_BITS-1:0]			TTE_tag		[`AR2D_DEFINE(CACHE_SETS, CACHE_SET_WAYS)];

	// Most Recently Used cache way
	reg	[CACHE_SET_WAYS_LOG2-1:0]	TTE_MRU	[0:CACHE_SETS-1];

	
	wire [31:0] DBG_i;	// TODO: remove this
	initial
	begin
		// Explicit way # (hardcoded)
		TTE_invalid[0] <= 4'b1111;
		TTE_invalid[1] <= 4'b1111;
		TTE_invalid[2] <= 4'b1111;
		TTE_invalid[3] <= 4'b1111;
		
		for (DBG_i = 0; DBG_i < CACHE_SETS; DBG_i = DBG_i + 1)
			TTE_MRU[DBG_i] = 0;
	end
	
	reg [IDX_BITS-1:0] set_idx;
	reg	[TAG_BITS-1:0] tag;

	reg [CACHE_SET_WAYS-1:0]	evicted_idx;

	reg [CACHE_SET_WAYS-1:0]	is_way_invalid;
	reg [CACHE_SET_WAYS-1:0]	is_way_dirty;
	
	reg [CACHE_SET_WAYS-1:0]	is_way_matching;

	always @ ( `EDGE_OPERATE clock_i )
	begin
	
		if ( (DBG_stall_counter == 0) && (read_data_i || write_data_i) )
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
		
		if (DBG_isStall)
		begin
			DBG_stall_counter <= DBG_stall_counter + 1;
		end
		
		if (DBG_isStall && is_waiting_mem && (!MIF_stall_i))
		begin
			// The cache is waiting for mem, and the mem is ready
			if (STATE_write_data_i == 1)
			begin
				// Write was successful (hopefully), release the stage

				// We're done
				DBG_stall_counter <= 0;
				DBG_isStall = 0;
				is_waiting_mem <= 0;
			end
			else if (STATE_read_data_i == 1)
			begin
				if (cacheline_mem_reads == (1<<(CACHELINE_SIZE_LOG2-2)))
				begin	// This was the final read
					tag = STATE_address_i[ADDR_BITS-1:IDX_BITS+OFF_BITS];
				
					// TTE_tag[STATE_memread_set_id][STATE_memread_way_id] <= tag;
					// TTE_invalid[STATE_memread_set_id][STATE_memread_way_id] <= TTE_invalid[STATE_memread_set_id][STATE_memread_way_id] & (~(1<<STATE_memread_way_id));
					// TTE_dirty[STATE_memread_set_id][STATE_memread_way_id] <= TTE_dirty[STATE_memread_set_id][STATE_memread_way_id] & (~(1<<STATE_memread_way_id));

					TTE_invalid[`AR2D_ACCESS(STATE_memread_set_id, STATE_memread_way_id, CACHE_SETS)] <= TTE_invalid[`AR2D_ACCESS(STATE_memread_set_id, STATE_memread_way_id, CACHE_SETS)] & (~(1<<STATE_memread_way_id));
					TTE_dirty[`AR2D_ACCESS(STATE_memread_set_id, STATE_memread_way_id, CACHE_SETS)] <= TTE_dirty[`AR2D_ACCESS(STATE_memread_set_id, STATE_memread_way_id, CACHE_SETS)] & (~(1<<STATE_memread_way_id));

					// TODO: here we need to set the reg_out
					// TODO: join that with already existing read
					cache_word = data_memory[`AR2D_ACCESS(STATE_memread_set_id, STATE_memread_way_id, CACHE_SETS)] [ {STATE_address_i[OFF_BITS-1:0], 3'b0} +: `GPR_BITS ];

					case (STATE_mem_mode_i)
						`MEMMODE_BYTE: reg_out <= (STATE_sign_i == 1) ?
													{ {24{1'b0}}, cache_word[7:0] } :
													{ {24{cache_word[7]}}, cache_word[7:0] };
						`MEMMODE_HALF: reg_out <= (STATE_sign_i == 1) ?
													{ {16{1'b0}}, cache_word[15:0] } :
													{ {16{cache_word[15]}}, cache_word[15:0] };
						`MEMMODE_WORD: reg_out <= cache_word;
						default: reg_out <= 123;
					endcase

					// We're done reading
					DBG_stall_counter <= 0;
					DBG_isStall = 0;
					is_waiting_mem <= 0;
				end
				else
				begin	// We didn't yet read the whole cacheline
					// data_memory[STATE_memread_set_id][STATE_memread_way_id][( (cacheline_mem_reads+1)<<5 ):( (cacheline_mem_reads<<5) )] <= MIF_read_data_i;
					// TODO: investigate why '<=' doesnt work
					data_memory[`AR2D_ACCESS(STATE_memread_set_id, STATE_memread_way_id, CACHE_SETS)] [cacheline_memreads_shft +: `GPR_BITS] <= MIF_read_data_i;

					// We didnt yet read the whole cacheline
					cacheline_mem_reads <= cacheline_mem_reads+1;
					STATE_MIF_read_data_o <= 1;
					STATE_MIF_address_o <= MIF_address_o + 4;
				end
			end
		end
		else if (DBG_stall_counter == `DBG_CACHE_STALL_CYCLES)
		begin
			set_idx = STATE_address_i[IDX_BITS+OFF_BITS-1:OFF_BITS];
			tag = STATE_address_i[ADDR_BITS-1:IDX_BITS+OFF_BITS];

			// Tag lookup
			is_way_invalid = TTE_invalid[set_idx];
			is_way_dirty = TTE_dirty[set_idx];
			
			// Comparators (4 cmp, 4-way assoc)
			// Explicit way # (hardcoded)
			is_way_matching[0] = (TTE_tag[set_idx][0] == tag);
			is_way_matching[1] = (TTE_tag[set_idx][1] == tag);
			is_way_matching[2] = (TTE_tag[set_idx][2] == tag);
			is_way_matching[3] = (TTE_tag[set_idx][3] == tag);
			
			// Do not need to avoid dirty ways, as this only means that the cache is up-to-dates with writes
			// (if the write policy is write-through, the line is also marked as invalid)
			is_way_matching = is_way_matching & (~is_way_invalid);// & (~is_way_dirty);
			
			// Select final line
			// Explicit way # (hardcoded)
			chosen_line =	(is_way_matching[0]) ? data_memory[set_idx][0] :
							(is_way_matching[1]) ? data_memory[set_idx][1] :
							(is_way_matching[2]) ? data_memory[set_idx][2] :
							(is_way_matching[3]) ? data_memory[set_idx][3] :
							128'h0000DEAD0000DEAD0000DEAD0000DEAD;
			
			way_number =	(is_way_matching[0]) ? 0 :
							(is_way_matching[1]) ? 1 :
							(is_way_matching[2]) ? 2 :
						/*	(is_way_matching[3])?*/ 3;
			
			if (is_way_matching)
			begin
				if (STATE_write_data_i == 1)
				begin
					// mark matching line as dirty
					TTE_dirty[set_idx] <= TTE_dirty[set_idx] | is_way_matching;
					
					// Invalidating line where cache was modified too,
					// since for now we have write-through policy
					TTE_invalid[set_idx] <= TTE_invalid[set_idx] | is_way_matching;

/*					
					case (`MEMMODE_i)
						`MEMMODE_BYTE: tmp_reg2 = `DATA_i[7:0];
						`MEMMODE_HALF: tmp_reg2 = `DATA_i[15:0];
						`MEMMODE_WORD: tmp_reg2 = `DATA_i;
						default: tmp_reg2 = 3344;
					endcase

					inner_memory[`ADDRESS_i[(ENTRY_NUM_LOG2-1+2):2]] <= tmp_reg2;
*/					
				end
				else if (STATE_read_data_i == 1)
				begin
					TTE_MRU[set_idx] <= way_number;
				
					// TODO: align read word (should be word-aligned);
					cache_word = chosen_line[{STATE_address_i[OFF_BITS-1:0], 3'b0} +: `GPR_BITS];
				
					case (STATE_mem_mode_i)
						`MEMMODE_BYTE: reg_out <= (STATE_sign_i == 1) ?
													{ {24{1'b0}}, cache_word[7:0] } :
													{ {24{cache_word[7]}}, cache_word[7:0] };
						`MEMMODE_HALF: reg_out <= (STATE_sign_i == 1) ?
													{ {16{1'b0}}, cache_word[15:0] } :
													{ {16{cache_word[15]}}, cache_word[15:0] };
						`MEMMODE_WORD: reg_out <= cache_word;
						default: reg_out <= 123;
					endcase
					
					// We're done
					DBG_stall_counter <= 0;
					DBG_isStall = 0;
				end
			end
			else
			begin
				// Set doesn't contain needed tag
				// it only matters for read at this point
				
				// set memory interface appropriately
				
				if (STATE_read_data_i == 1)
				begin
					// Cache eviction policy
					// Explicit way # (hardcoded)
					if (is_way_invalid[0]) evicted_idx = 0;
					else if (is_way_invalid[1]) evicted_idx = 1;
					else if (is_way_invalid[2]) evicted_idx = 2;
					else if (is_way_invalid[3]) evicted_idx = 3;
					else
					begin
						evicted_idx = ~(TTE_MRU[set_idx]);//GLOB_clk_count_i[CACHE_SET_WAYS_LOG2-1:0];
					end

					STATE_memread_set_id <= set_idx;
					STATE_memread_way_id <= evicted_idx;
					
					// Mark line we're going to evict as invalid
					TTE_invalid[set_idx] <= TTE_invalid[set_idx] | (1<<evicted_idx);
					// Store tag right away
					TTE_tag[`AR2D_ACCESS(STATE_memread_set_id, STATE_memread_way_id, CACHE_SETS)] <= tag;
					TTE_MRU[set_idx] <= evicted_idx;

					// start reading with 0 byte offset
					STATE_MIF_address_o <= STATE_address_i[`ALU_OP_BITS-1:OFF_BITS] << OFF_BITS;
					STATE_MIF_data_o <= 0;
					STATE_MIF_write_data_o <= 0;
					STATE_MIF_read_data_o <= 1;
					STATE_MIF_sign_o <= 0;
					STATE_MIF_mem_mode_o <= `MEMMODE_WORD;
					
					// wait for mem to respond
					is_waiting_mem <= 1;
					cacheline_mem_reads <= 0;
				end
			end
			
			if (STATE_write_data_i == 1)
			begin
				// set memory interface appropriately
				STATE_MIF_address_o <= STATE_address_i;
				STATE_MIF_data_o <= STATE_data_i;
				STATE_MIF_write_data_o <= STATE_write_data_i;
				STATE_MIF_read_data_o <= STATE_read_data_i;
				STATE_MIF_sign_o <= STATE_sign_i;
				STATE_MIF_mem_mode_o <= STATE_mem_mode_i;
				
				// wait for mem to respond
				is_waiting_mem <= 1;
			end
		end
		else
		begin
			//tmp_reg2 <= 5566;
		end

		
	end
	
`endif
	
endmodule

`endif
