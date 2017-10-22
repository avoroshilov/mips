`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////

`include "def_general.v"

`include "im.v"
`include "dm.v"
`include "reg_file.v"

`ifdef 0
`define BYPASS_ENABLED		20
`define MODE				19:18
`define DM_REG_ADDR			17:10
`define DM_MODE				2'b00
`define IM_REG_ADDR			17:10
`define IM_MODE				2'b01
`define REGFILE_REG_ADDR	14:10
`define REGFILE_MODE		2'b10
`define PC_REG_ADDR			10:10
`define PC_MODE				2'b11
`endif

`define NO_STATE			0
`define WRITE_STATE			1
`define READ_STATE			2
`define PUT_DATA_STATE		3
`define CLEAR_STATUS		4
`define SET_STATUS			5


`define ADDR_STATUS			24'hffffff // reads status register / RO
`define ADDR_ACTION			24'hfffffe // writes action to execute: read or write / WO
`define ADDR_TEST		24'hfffffd // by writing to this address we activate action / WO
//`define ADDR_TEST		24'h0 // by writing to this address we activate action / WO
`define ADDR_RESET			24'hfffffc // sets to 0 all inner registers / WO
`define ADDR_MODE			24'hfffffb // sets mode: IM, DM, REG, RAM, NONE, etd / WO
`define ADDR_ADDRESS_HI		24'hfffffa // sets high part of address / WO
`define ADDR_ADDRESS_LO		24'hfffff9 // sets low part of address / WO
`define ADDR_DATA_HI		24'hfffff8 // sets high part of data / WO
`define ADDR_DATA_LO		24'hfffff7 // sets low part of data / WO
`define ADDR_RUN			24'hfffff6 // runs the read routine / WO
`define ADDR_CPU_STATUS		24'hfffff5 // sets cpu status: enable, reset, etc / WR
`define ADDR_DATA_READ_HI	24'hfffff4 // reads high half of data / RO
`define ADDR_DATA_READ_LO	24'hfffff3 // reads low half of data / RO

`define ADDR_WRONG			24'h0081ff
//`define ADDR_WRONG			24'h0101ff

`define ACTION_NONE			0 // no action selected
`define ACTION_READ			1 // read data
`define ACTION_WRITE		2 // write data

`define MODE_NONE			0 // no 
`define MODE_IM				1 // choose im
`define MODE_DM				2 // choose dm
`define MODE_REG			3 // choose reg file
`define MODE_RAM			4 // choose ram

`define STATUS_BUSY			0 // 
`define STATUS_DONE			1 // 
`define STATUS_ERROR		2 //

`define SIZE_HALF	15:0
`define SIZE_WORD	31:0
`define SIZE_BYTE	7:0


module top(
	inout wire [15:0] data_io,
	
	input wire [24:0] addr_i,
	input wire read_i,
	input wire write_i,
	input wire cs_i,
	input wire clk_i,
	
	output wire cs_o,
	output wire dm_led_o,
	output wire irq_o			// IRQ pin
	
	//output wire [31:0] data_o,
	//output wire [31:0] address_o,
	//output wire [15:0] control_o,
	//output wire [31:0] result_o
	);
	
	reg testOut = 0;
	assign cs_o = testOut;
	reg busy = 0;
	
	// latches to avoid metastability
	reg stage_1 = 0;
	reg stage_2 = 0;
	reg stage_3 = 0;
	
	//signal which controls tristate iobuf
	wire disable_io;
	assign disable_io = (read_i);
	
	wire [15:0] data_write;
	reg [15:0] data_read = 0;	
	
	
	reg	[`SIZE_WORD] counter = 0;
	reg [`SIZE_HALF] action_reg = 0;
	reg [`SIZE_HALF] status_reg = 0;
	reg [`SIZE_HALF] mode_reg = 0;
	reg [`SIZE_HALF] addr_hi_reg = 0;
	reg [`SIZE_HALF] addr_lo_reg = 0;
	reg [`SIZE_HALF] data_hi_reg = 0;
	reg [`SIZE_HALF] data_lo_reg = 0;
	reg [`SIZE_HALF] data_read_hi_reg = 16'h1234;
	reg [`SIZE_HALF] data_read_lo_reg = 16'habcd;
	reg sys_read_en = 0;
	reg sys_write_en = 0;
	reg work_in_progress = 0;
	
	wire [`SIZE_WORD] data_full_i = {data_hi_reg, data_lo_reg};
	wire [`SIZE_WORD] addr_full_i = {addr_hi_reg, data_lo_reg};
	wire [`SIZE_WORD] data_full_o;
	
	reg irq;
	assign irq_o = irq;
	
	
	// iobuf instance
	genvar y;
	generate
	for(y = 0; y < 16; y = y + 1 ) 
	begin : iobuf_generation
		IOBUF io_y (
			.I( data_read[y] ),
			.O( data_write[y] ),
			.IO( data_io[y] ),
			.T ( disable_io )
		);
	end
	endgenerate

	wire dm_read;
	wire dm_write;
	wire [`SIZE_WORD] dm_data_o;
	
	wire dm_led;
	assign dm_led_o = dm_led;
	
	data_memory DATA_MEMORY(
		.address_i(addr_full_i),
		.data_i(data_full_i),
		.write_data_i(dm_write),
		.read_data_i(dm_read),
		.clock_i(clk_i),
		.sign_i(0),
		.mem_mode_i(2'b11),
		.read_data_o(dm_data_o),
		.dm_led_o(dm_led)
	);
	
	wire reg_read;
	wire reg_write;
	wire reg_data_o;

	register_file REG_FILE(
		.register_1_read_addr_i(addr_full_i[4:0]),
		.register_2_read_addr_i(0),
		.register_write_addr_i(addr_full_i[4:0]),
		.register_write_data_i(data_full_i),
		.register_write_i(reg_write),
		.register_read_i(reg_read),
		.clock_i(clk_i),
		.register_1_data_o(reg_data_o),
		.register_2_data_o()
	);
	
	wire im_read;
	wire im_write;
	wire [`SIZE_WORD] im_data_o;
	
	im INSTRUCTION_MEMORY(
		.enable_i(1),
		.clk_i(clk_i),
		.addr_i(addr_full_i),
		.read_i(im_read),
		.write_i(im_write),
		.data_i(data_full_i),
		.data_o(im_data_o)
	);

	assign im_read =	(mode_reg == `MODE_IM) ? sys_read_en : 1'b0;
	assign im_write =	(mode_reg == `MODE_IM) ? sys_write_en : 1'b0;
	assign dm_read =	(mode_reg == `MODE_DM) ? sys_read_en : 1'b0;
	assign dm_write =	(mode_reg == `MODE_DM) ? sys_write_en : 1'b0;
	assign reg_read =	(mode_reg == `MODE_REG) ? sys_read_en : 1'b0;
	assign reg_write =	(mode_reg == `MODE_REG) ? sys_write_en : 1'b0;

	assign data_full_o =(mode_reg == `MODE_REG) ? reg_data_o :
							(
								(mode_reg == `MODE_IM) ? im_data_o : 
									( (mode_reg == `MODE_DM) ? dm_data_o : 1'b0 )
							);

	always @ (posedge clk_i)
	begin
		//testOut <= testOut + 1;
	
		// store chipselect stuff into latches
		stage_3 <= stage_2;
		stage_2 <= stage_1;
		stage_1 <= cs_i;

		if ({stage_2, stage_3} == 2'b01)
		begin
			if (!read_i)
			begin
				//testOut <= 1;	    
				// reading status register
				case ( addr_i[24:1] )
					`ADDR_STATUS:
					begin
						data_read <= status_reg;
						irq <= 0;
					end
					`ADDR_DATA_READ_HI:
					begin
						data_read <= data_read_hi_reg;
					end
					`ADDR_DATA_READ_LO:
					begin
						data_read <= data_read_lo_reg;
					end
					`ADDR_TEST:
					begin
						data_read <= 16'hBEAF;
					end
					`ADDR_ACTION:
					begin
						data_read <= action_reg;
					end
					`ADDR_MODE:
					begin
						data_read <= mode_reg;
					end
					`ADDR_DATA_HI:
					begin
						data_read <= data_hi_reg;					
					end
					`ADDR_DATA_LO:
					begin
						data_read <= data_lo_reg;					
					end
					`ADDR_ADDRESS_HI:
					begin
						data_read <= addr_hi_reg;					
					end
					`ADDR_ADDRESS_LO:
					begin
						data_read <= addr_lo_reg;					
					end
					default:
					begin
						data_read <= `ADDR_WRONG;
					end
				endcase
			end
			if (!write_i)
			begin
				case ( addr_i[24:1] )
					`ADDR_ACTION:
					begin
						action_reg <= data_write;
					end
					`ADDR_MODE:
					begin
						mode_reg <= data_write;
					end
					`ADDR_DATA_HI:
					begin
						data_hi_reg <= data_write;
					end
					`ADDR_DATA_LO:
					begin
						data_lo_reg <= data_write;
					end
					`ADDR_ADDRESS_HI:
					begin
						addr_hi_reg <= data_write;
					end
					`ADDR_ADDRESS_LO:
					begin
						addr_lo_reg <= data_write;
					end
					`ADDR_RESET:
					begin
						counter <= 0;
						status_reg <= 0;
						action_reg <= `ACTION_NONE;
						mode_reg <= `MODE_NONE;
						addr_hi_reg <= 0;
						addr_lo_reg <= 0;
						data_hi_reg <= 0;
						data_lo_reg <= 0;
						sys_read_en <= 0;
						sys_write_en <= 0;
						data_read_hi_reg <= 0;
						data_read_lo_reg <= 0;
						irq <= 0;
						busy <= 0;
					end
					`ADDR_RUN:
					begin
						//testOut <= 1;
						//if ( action_reg != `ACTION_NONE && mode_reg != `MODE_NONE && !status_reg[`STATUS_BUSY] )
						if ( action_reg != `ACTION_NONE && mode_reg != `MODE_NONE && !busy )
						begin
							status_reg[`STATUS_DONE] <= 0;
							status_reg[`STATUS_BUSY] <= 1;
							busy <= 1;
							counter <= 0;
							
							if ( action_reg == `ACTION_READ )
							begin
								//testOut <= 1;
								sys_read_en <= 1;
							end
							else if ( action_reg == `ACTION_WRITE)
							begin
								//testOut <= 1;
								sys_write_en <= 1;
							end
							else
							begin
							end
							//testOut <= 1;
						end
						else
						begin
							status_reg[`STATUS_ERROR] <= 1;
							irq <= 1;
							//testOut <= 1;
							// something is not set or we're busy; report error?
						end
					end
					default:
					begin
					end
				endcase
			end
		end
		if ( busy == 1 )
		begin
			counter <= counter + 1;
			if ( action_reg == `ACTION_READ && counter == 2 )
			begin
				{data_read_hi_reg, data_read_lo_reg} <= data_full_o;
				sys_read_en <= 0;
			end					
			else if ( action_reg == `ACTION_WRITE && counter == 2 )
			begin
				testOut <= 1;
				sys_write_en <= 0;
			end
			else
			begin
			end
			if (  counter == 2 )
			begin
				status_reg[`STATUS_BUSY] <= 0;
				status_reg[`STATUS_DONE] <= 1;
				busy <= 0;
				irq <= 1;
			end
		end
	end
endmodule


