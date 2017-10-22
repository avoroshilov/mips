`ifndef _cpu_top_lvl
`define _cpu_top_lvl

`include "def_general.v"
`include "def_funct_field.v"
`include "def_instr_fields.v"
`include "alu.v"
`include "dm.v"
`include "im.v"
`include "pc.v"
`include "cache_rw.v"
`include "reg_file.v"
`include "new_control.v"

`define STAGE_IF		0
`define STAGE_ID		1
`define STAGE_EX		2
`define STAGE_MEM		3
`define STAGE_WB		4
`define STAGE_LASTVAL	`STAGE_WB

//`define DIFFERENT_PATHS

`ifndef DIFFERENT_PATHS

	`ifndef DATA_MEM_IN
	`define DATA_MEM_IN "./data/data_memory.txt"
	`endif

	`ifndef DATA_MEM_OUT
	`define DATA_MEM_OUT "./data/data_memory_out.txt"
	`endif

	`ifndef INSTRUCTION_MEM_OUT
	`define INSTRUCTION_MEM_OUT "./data/im_data_out.txt"
	`endif

	`ifndef INSTRUCTION_MEM_IN
	`define INSTRUCTION_MEM_IN "./data/im_data.txt"
	`endif

	`ifndef REGISTER_DATA_IN
	`define REGISTER_DATA_IN "./data/reg_file_data.txt"
	`endif

	`ifndef REGISTER_DATA_OUT
	`define REGISTER_DATA_OUT "./data/reg_file_data_out.txt"
	`endif

`else

	`ifndef DATA_MEM_IN
	`define DATA_MEM_IN "../data/data_memory.txt"
	`endif

	`ifndef DATA_MEM_OUT
	`define DATA_MEM_OUT "../data/data_memory_out.txt"
	`endif

	`ifndef INSTRUCTION_MEM_OUT
	`define INSTRUCTION_MEM_OUT "../data/im_data_out.txt"
	`endif

	`ifndef INSTRUCTION_MEM_IN
	`define INSTRUCTION_MEM_IN "../data/im_data.txt"
	`endif

	`ifndef REGISTER_DATA_IN
	`define REGISTER_DATA_IN "../data/reg_file_data.txt"
	`endif

	`ifndef REGISTER_DATA_OUT
	`define REGISTER_DATA_OUT "../data/reg_file_data_out.txt"
	`endif

`endif

`define USE_MEM_WB 0
`define FIRST_OPND_FORWARD 1
`define SECOND_OPND_FORWARD 2
`define NEED_FORWARD 3

module stall_unit(
	input	wire	[`GPR_IDX_SIZE]		reg_wr_addr_ID_EX_i,
	input	wire	[`GPR_IDX_SIZE]		reg_wr_addr_EX_MEM_i,
	input	wire	[`GPR_IDX_SIZE]		reg_wr_addr_MEM_WB_i,

	input	wire	[`GPR_IDX_SIZE]		ID_EX_rt_i,
	input	wire	[`GPR_IDX_SIZE]		ID_EX_rs_i,
	input	wire	[`GPR_IDX_SIZE]		IF_ID_rt_i,
	input	wire	[`GPR_IDX_SIZE]		IF_ID_rs_i,
	input	wire	[0:0]				ID_EX_mem_read_i,
	input	wire	[0:0]				EX_MEM_mem_read_i,
	input	wire	[0:0]				ID_EX_write_reg_i,
	input	wire	[0:0]				ID_jump_reg_i,
	
	input	wire						DM_stall_i,
	
	output	wire	[`STAGE_LASTVAL:0]	stall_o
	);
	
	reg [`STAGE_LASTVAL:0] stall = `STAGE_LASTVAL'b0;
	assign stall_o = stall;
	
//if (ID/EX.MemRead and
//((ID/EX.RegisterRt = IF/ID.RegisterRs) or
 //(ID/EX.RegisterRt = IF/ID.RegisterRt)))
  //stall the pipeline
	
	always @ ( * )
	begin
		// Stall if ..
		stall[`STAGE_MEM] = DM_stall_i;
		
		/* EX Stage stalls */
		// .. we're waiting for MEM outputs on the EX stage (LD $t0 followed by op consuming $t0)
		if ((reg_wr_addr_EX_MEM_i != 0) && EX_MEM_mem_read_i && ((reg_wr_addr_EX_MEM_i == ID_EX_rt_i) || (reg_wr_addr_EX_MEM_i == ID_EX_rs_i)))
		begin
			stall[`STAGE_EX] = 1;
		end
		else
		begin
			stall[`STAGE_EX] = 0;
		end
		
		/* ID Stage stalls */
		// .. we're willing to jump register, but the register is not yet ready in MEM
		if ((reg_wr_addr_EX_MEM_i != 0) && ID_jump_reg_i && EX_MEM_mem_read_i && ((reg_wr_addr_EX_MEM_i == IF_ID_rt_i) || (reg_wr_addr_EX_MEM_i == IF_ID_rs_i)))
		begin
			stall[`STAGE_ID] = 1;
		end
		else
		// .. we're willing to jump register, but the register is not yet ready in EX
		if ((reg_wr_addr_ID_EX_i != 0) && ((ID_EX_write_reg_i && ID_jump_reg_i) || (ID_EX_mem_read_i)) && ((reg_wr_addr_ID_EX_i == IF_ID_rt_i) || (reg_wr_addr_ID_EX_i == IF_ID_rs_i)))
		begin
			stall[`STAGE_ID] = 1;
		end
		else
		begin
			stall[`STAGE_ID] = 0;
		end
	end
	
endmodule

`define USE_DEFAULT 2'b00
`define USE_EX 2'b01
`define USE_MEM 2'b10
`define USE_FULL_IMM 2'b11

module forward_unit(
	input	wire	[`GPR_IDX_SIZE]		MEM_WB_rd_i,
	input	wire	[`GPR_IDX_SIZE]		EX_MEM_rd_i,
	input	wire	[`GPR_IDX_SIZE]		ID_EX_rd_i,
	input	wire	[`GPR_IDX_SIZE]		ID_EX_rs_i,
	input	wire	[`GPR_IDX_SIZE]		ID_EX_rt_i,
	input	wire	[0:0]				is_rt_input_i,
	input	wire	[0:0]				is_imm_to_reg_i,
	input	wire	[0:0]				MEM_WB_reg_write_i,
	input	wire	[0:0]				EX_MEM_reg_write_i,
	
	output	wire	[1:0]				EX_first_operand_control_o,
	output	wire	[1:0]				EX_second_operand_control_o,
	output	wire	[1:0]				ID_jump_reg_control_o
	);
	
	//reg [3:0] control = 0;
	//assign EX_comm_contol_o = control;
	reg [1:0] first_operand_contol = 0;
	reg [1:0] second_operand_contol = 0;
	reg [1:0] jump_reg_contol = 0;
	assign EX_first_operand_control_o = first_operand_contol;
	assign EX_second_operand_control_o = second_operand_contol;
	assign ID_jump_reg_control_o = jump_reg_contol;

//if (EX/MEM.RegWrite
//and (EX/MEM.RegisterRd ≠ 0)
//and (EX/MEM.RegisterRd = ID/EX.RegisterRs)) ForwardA = 10

//if (EX/MEM.RegWrite
//and (EX/MEM.RegisterRd ≠ 0)
//and (EX/MEM.RegisterRd = ID/EX.RegisterRt)) ForwardB = 10


//if (MEM/WB.RegWrite
//and (MEM/WB.RegisterRd ≠ 0)
//and not(EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0))
//and (EX/MEM.RegisterRd ≠ ID/EX.RegisterRs)
//and (MEM/WB.RegisterRd = ID/EX.RegisterRs)) ForwardA = 01

//if (MEM/WB.RegWrite
//and (MEM/WB.RegisterRd ≠ 0)
//and not(EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0))
//and (EX/MEM.RegisterRd ≠ ID/EX.RegisterRt)
//and (MEM/WB.RegisterRd = ID/EX.RegisterRt)) ForwardB = 01
	
	always @ ( * )
	begin
		if ( EX_MEM_reg_write_i && EX_MEM_rd_i != 0 && EX_MEM_rd_i == ID_EX_rs_i )
		begin
			first_operand_contol <= `USE_EX;
		end
		else if ( MEM_WB_reg_write_i && MEM_WB_rd_i != 0 && MEM_WB_rd_i == ID_EX_rs_i )
		begin
			first_operand_contol <= `USE_MEM;
		end
		else if ( is_imm_to_reg_i )
		begin
			first_operand_contol <= `USE_FULL_IMM;
		end
		else
		begin
			first_operand_contol <= `USE_DEFAULT;
		end
		
		if ( is_rt_input_i && EX_MEM_reg_write_i && EX_MEM_rd_i != 0 && EX_MEM_rd_i == ID_EX_rt_i )
		begin
			second_operand_contol <= `USE_EX;
		end
		else if ( is_rt_input_i && MEM_WB_reg_write_i && MEM_WB_rd_i != 0 && MEM_WB_rd_i == ID_EX_rt_i )
		begin
			second_operand_contol <= `USE_MEM;
		end
		else
		begin
			second_operand_contol <= `USE_DEFAULT;
		end
		
		// TODO: check if jump_reg could be a linear combination of the above two
		if ( EX_MEM_reg_write_i && EX_MEM_rd_i != 0 && ((EX_MEM_rd_i == ID_EX_rt_i) || (EX_MEM_rd_i == ID_EX_rs_i)) )
		begin
			jump_reg_contol <= `USE_EX;
		end
		else if ( MEM_WB_reg_write_i && MEM_WB_rd_i != 0 && (MEM_WB_rd_i == ID_EX_rt_i || MEM_WB_rd_i == ID_EX_rs_i) )
		begin
			jump_reg_contol <= `USE_MEM;
		end
		else
		begin
			jump_reg_contol <= `USE_DEFAULT;
		end
	end

endmodule

module WB_comm(
	input	wire	[`CONTROL_SIZE]		control_i,
	input	wire	[`ALU_OP_SIZE]		alu_result_i,
	input	wire	[`MEM_DATA_SIZE]	data_mem_i,
	input	wire	[`PC_SIZE]			pc_i,

	output	wire	[`GPR_SIZE]			reg_write_data_o
	);
	
	/*
		Data Fed to the Output Register:
		* MEM_TO_REG: memory to register instruction feeds mem output to the output register
		* LINK: link operations [e.g. JAL/BGEZAL], feed ProgramCounter+8 (pc_addr_out_inc already contains PC+4)
		* IMM_TO_REG: LUI operation feeds 32-bit full immediate (shifted 16-bit immediate) to the register
	*/
	assign reg_write_data_o = (control_i[`MEM_TO_REG]) ? data_mem_i	:
								(control_i[`LINK]) ? (pc_i + 8) : alu_result_i;
	
endmodule


module EX_comm(
	input	wire	[`CONTROL_SIZE]		control_i,
	input	wire	[`GPR_SIZE]			reg_data1_i,
	input	wire	[`GPR_SIZE]			reg_data2_i,
	input	wire	[`GPR_SIZE]			full_imm_i,
	input	wire	[1:0]				first_operand_contol_i,
	input	wire	[1:0]				second_operand_contol_i,
	input	wire	[`GPR_SIZE]			forward_data_EX_i,
	input	wire	[`GPR_SIZE]			forward_data_MEM_i,

	output	wire	[`GPR_SIZE]			alu_op1_o,
	output	wire	[`GPR_SIZE]			alu_op2_o
	);
	
	
	reg [`GPR_SIZE] alu_op2_reg_o;
	reg [`GPR_SIZE] alu_op1_reg_o;
	assign alu_op1_o = alu_op1_reg_o;
	assign alu_op2_o = alu_op2_reg_o;
	//assign alu_op2_o = test;
	/*
		2nd ALU Operand
		* ALU_SRC_IMM: I-type operations, R-type immediate shifts and many others require full 32-bit immediate
		  as the second ALU operator, while e.g. typical R-type operation require RT as the second op
	*/
	//assign alu_op2_o = (second_operand_contol_i != `USE_DEFAULT) ? (second_operand_contol_i == `USE_MEM) ? forward_data_MEM_i : forward_data_EX_i : (control_i[`ALU_SRC_IMM] == 0) ? reg_data2_i : full_imm_i;
	always @ ( * )
	begin
		if ( second_operand_contol_i == `USE_DEFAULT ) 
		begin
			if ( control_i[`ALU_SRC_IMM] == 0 )
				alu_op2_reg_o = reg_data2_i;
			else
				alu_op2_reg_o = full_imm_i;
		end
		else if ( second_operand_contol_i == `USE_MEM )
		begin
			alu_op2_reg_o = forward_data_MEM_i;
		end
		else if ( second_operand_contol_i == `USE_EX )
		begin
			alu_op2_reg_o = forward_data_EX_i;
		end
		else
		begin
			alu_op2_reg_o = 32'hDEADBEEF;
			$display("WRONG SECOND PARAMETER");
		end
	end
	//assign alu_op2_o = (control_i[`ALU_SRC_IMM] == 0) ? reg_data2_i : full_imm_i;
	
	/*
		ALU Operand Swap parameter:
		* KLUDGY_ALU_SWAP: in the R-type immediate shift instructions, RT is shifted instead of RS,
		  RS is not used; so output of the second register should actually go to the first ALU slot
	*/
	//assign alu_op1_o = (first_operand_contol_i != `USE_DEFAULT) ? 
													//(first_operand_contol_i == `USE_MEM) ? forward_data_MEM_i : forward_data_EX_i
													 //: (control_i[`KLUDGY_ALU_SWAP] == 1) ? reg_data2_i : reg_data1_i;
	//case (first_operand_contol_i)
	always @ ( * )
	begin
		if ( first_operand_contol_i == `USE_DEFAULT)
		begin
			if (control_i[`KLUDGY_ALU_SWAP] == 1)
				alu_op1_reg_o = reg_data2_i;
			else
				alu_op1_reg_o = reg_data1_i;
		end
		else if ( first_operand_contol_i == `USE_MEM )
		begin
			alu_op1_reg_o = forward_data_MEM_i;
		end
		else if ( first_operand_contol_i == `USE_EX )
		begin
			alu_op1_reg_o = forward_data_EX_i;
		end
		else if ( first_operand_contol_i == `USE_FULL_IMM )
		begin
			alu_op1_reg_o = full_imm_i;
		end
		else
		begin
			alu_op1_reg_o = 32'hDEADBEEF;
			$display("WRONG FIRST PARAMETER");
		end
	end
		
		
	//assign alu_op1_o = (control_i[`KLUDGY_ALU_SWAP] == 1) ? reg_data2_i : reg_data1_i;
	
endmodule


module ID_comm(
	input	wire	[`CONTROL_SIZE]		control_i,
	input	wire	[`INSTR_SIZE]		im_out_i,
	output	wire	[`GPR_IDX_SIZE]		reg_write_addr_o,
	output	wire	[`ALU_OP_SIZE]		full_imm_o
	);
	
	/*
		Register Write Address setup
		* REG_OUT_RA: in most link operations [e.g. JAL/BGEZAL] we need to force output register to $ra($31)
		* REG_OUT_RD: I-type operations store output register in the RT field,
					  R-type operations	use RD as an output register
	*/
	assign reg_write_addr_o = (control_i[`REG_OUT_RA] == 1) ? `GPR_IDX_RA : (control_i[`REG_OUT_RD] == 0) ? im_out_i[`RT] : im_out_i[`RD]; 
	
	/*
		Full 32-bit Immediate value setup
		* IMM_SHAMT: Immediate shift (R-types using SHAMT e.g. SLL) need to store SHAMT in the immediate
		* IMM_SHIFT: LUI operation needs to store shifted immediate
		* ZERO_EXT: some I-type operation requires zero extended immediate, while others require sign extension
	*/
	assign full_imm_o = (control_i[`IMM_SHAMT] == 1) ? { 26'b0, im_out_i[`SHAMT] } : 
						(control_i[`IMM_SHIFT] == 1) ? { im_out_i[`IMMEDIATE], 16'b0 } :
						(control_i[`ZERO_EXT] == 0) ? { {16{im_out_i[15]}}, im_out_i[`IMMEDIATE] } : { {16{1'b0}}, im_out_i[`IMMEDIATE] };

endmodule



module cpu(
	input	wire		clk_i,
	input	wire		reset_i,
	input	wire		enable_i,
	output	wire	[`PC_SIZE]	current_pc_o
	);

	reg is_cpu_enabled = 0;
	reg is_reset = 0;
	
	reg [`GLOB_CLKCOUNT_SIZE] GLOBAL_cyclecount = 0;

	/*
	Pipeline stages:
		IF - instruction fetch: Instr Mem, Prog Counter
		ID - instruction decode: Control Unit, Reg File
		EX - execute: ALU, Branch Decision
		MEM - memory: Data Mem
		WB - writeback: routing data to reg file
	*/
	
// * IF ******************************************************************************************
	wire [`PC_SIZE] pc_addr_in;
	
	wire [`PC_SIZE] pc_addr_out;
	wire [`INSTR_SIZE] im_out;
	wire new_addr;
	
	
	
	pc #(.START_VALUE(0)) PC
	(
		.clk_i(clk_i),
		.reset_i(reset_i),
		.enable_i(is_cpu_enabled),
		.addr_o(pc_addr_out),
		.addr_i(pc_addr_in),
		.use_new_addr_i(new_addr),
		.stall_i(stall_flag[`STAGE_IF])
	);

	im #(128, `INSTRUCTION_MEM_IN) IM
	(
		.clk_i(clk_i),
		.enable_i(is_cpu_enabled),
		.addr_i(pc_addr_out),
		.data_o(im_out),
		.read_i(1'b1),
		.write_i(1'b0)
	);

	// fix for iverolog 1.0
reg [`GPR_SIZE] alu_result_EX_MEM = 0;
wire [1:0] first_operand_contol;
wire [1:0] second_operand_contol;


// * ID ******************************************************************************************
	// IF to ID stage registers
	reg [`INSTR_SIZE] instruction_IF_ID = 0;
	reg [`ALU_OPCODE_SIZE] alu_op_IF_ID = 0;
	reg [`PC_SIZE] pc_IF_ID = 0;
	//

	// ID-specific wiring
	wire [`CONTROL_SIZE] control_unit_out;
	wire [`ALU_OPCODE_SIZE] alu_opcode_out;
	wire [`GPR_SIZE] register_1_data_out;
	wire [`GPR_SIZE] register_2_data_out;
	wire [`GPR_IDX_SIZE] reg_write_addr;
	wire [`ALU_OP_SIZE] full_imm;
	wire [`GPR_IDX_SIZE] reg_wr_addr;
	wire [`GPR_SIZE] register_write_data;
	wire [`PC_SIZE] pc_wire_ID;
	wire [`PC_SIZE] pc_addr_ID;
	// JumpAddr = { PC+4[31:28], address, 2’b0 }
	wire [`PC_SIZE] pc_IF_ID_inc;
	assign pc_IF_ID_inc = pc_IF_ID + 4;
	assign pc_wire_ID = {pc_IF_ID_inc[31:28], instruction_IF_ID[`ADDRESS], 2'h0};
	/*
		Deciding where to jump
		JUMP_REG: jump register instruction [JR/JALR] sets PC to the RS contents
		JUMP: J-type instruction [J/JAL] sets PC to concatenated immediate: { PC+4[31:28], address, 2’b0 }
	*/
	assign pc_addr_ID = (control_unit_out[`JUMP_REG]) ? (jump_reg_contol == `USE_MEM) ? register_write_data : (jump_reg_contol == `USE_EX) ? alu_result_EX_MEM : register_1_data_out : (control_unit_out[`JUMP]) ? pc_wire_ID : pc_IF_ID_inc;
	assign current_pc_o = pc_addr_ID;
	
	mips_control CONTROL_UNIT
	(
		.opcode_i(instruction_IF_ID[`OPCODE]),
		.funct_i(instruction_IF_ID[`FUNCT]),
		.branch_type_i(instruction_IF_ID[`RT]),
		.clk_i(clk_i),
		.control_o(control_unit_out),
		.alu_opcode_o(alu_opcode_out),
		.reset_i(is_reset)
	);

	ID_comm ID_COMM_UNIT(
		.control_i(control_unit_out),
		.im_out_i(instruction_IF_ID),
		.reg_write_addr_o(reg_write_addr),
		.full_imm_o(full_imm)
	);



	register_file #(32, `REGISTER_DATA_IN, `REGISTER_DATA_OUT) REGISTER_FILE
	(
		.register_1_read_addr_i(instruction_IF_ID[`RS]),
		.register_2_read_addr_i(instruction_IF_ID[`RT]),
		.register_write_addr_i(reg_wr_addr),				// from WB stage
		.register_write_data_i(register_write_data),		// from WB stage
		.register_write_i(control_MEM_WB[`REG_WRITE]),		// from WB stage
		.clock_i(clk_i),
		.reset_i(is_reset),
		.register_read_i(1'b1),
		
		.register_1_data_o(register_1_data_out),
		.register_2_data_o(register_2_data_out)
	);

// * EX ******************************************************************************************
	// ID to EX stage registers
	reg [`GPR_SIZE] reg_1_data_ID_EX = 0;
	reg [`GPR_SIZE] reg_2_data_ID_EX = 0;
	reg [`GPR_IDX_SIZE] reg_wr_addr_ID_EX = 0;
	reg [`CONTROL_SIZE] control_ID_EX = 0;
	reg [`ALU_OPCODE_SIZE] alu_op_ID_EX = 0;
	reg [`ALU_OP_SIZE] full_imm_ID_EX = 0;
	reg [`PC_SIZE] pc_ID_EX = 0;
	reg [`INSTR_SIZE] instruction_ID_EX = 0;
	
	// EX-specific wiring
	wire [`GPR_SIZE] KLUDGE_alu_1_operand;
	wire [`GPR_SIZE] alu_2_operand;
	wire [`GPR_SIZE] alu_result;
	wire alu_zero;
	wire alu_sign;
	
	EX_comm EX_COMM_UNIT(
		.control_i(control_ID_EX),
		.reg_data1_i(reg_1_data_ID_EX),
		.reg_data2_i(reg_2_data_ID_EX),
		.full_imm_i(full_imm_ID_EX),
		.first_operand_contol_i(first_operand_contol),
		.second_operand_contol_i(second_operand_contol),
		.forward_data_EX_i(alu_result_EX_MEM),
		.forward_data_MEM_i(register_write_data),
		.alu_op1_o(KLUDGE_alu_1_operand),
		.alu_op2_o(alu_2_operand)
	);

	alu ALU
	(
		.param_1_i(KLUDGE_alu_1_operand),
		.param_2_i(alu_2_operand),
		.alu_op_i(alu_op_ID_EX),
		.write_lohi_i(control_ID_EX[`WRITE_LOHI]),
		.clock_i(clk_i),
		.result_o(alu_result),
		.zero_o(alu_zero),
		.sign_o(alu_sign)
	);

	wire [`PC_SIZE] pc_wire_EX;
	assign pc_wire_EX = pc_ID_EX + 4 + ({ {16{instruction_ID_EX[15]}}, instruction_ID_EX[`IMMEDIATE] } << 2);
	
	assign branch_decision = (control_ID_EX[`LESS_ZERO] && alu_sign) ||
							 (control_ID_EX[`GREATER_ZERO] && !alu_sign && !alu_zero) ||
							 (control_ID_EX[`EQ_ZERO] && alu_zero);
		
	
							 
	wire [`PC_SIZE] pc_addr_EX;
	assign pc_addr_EX = (branch_decision == 0) ? pc_ID_EX + 4 : pc_wire_EX;
	
// * MEM *****************************************************************************************
	// EX to MEM stage registers
	
	reg alu_zero_EX_MEM = 0;
	reg alu_sign_EX_MEM = 0;
	reg [`CONTROL_SIZE] control_EX_MEM = 0;
	reg [`GPR_IDX_SIZE] reg_wr_addr_EX_MEM = 0;
	reg [`GPR_SIZE] reg_2_data_EX_MEM = 0;
	reg [`PC_SIZE] pc_EX_MEM = 0;
	reg [`INSTR_SIZE] instruction_EX_MEM = 0;
	reg branch_decision_EX_MEM = 0;
	//

	// MEM-specific wiring
	wire [`MEM_DATA_SIZE] data_memory_out;

	data_memory #(128, 7, `DATA_MEM_IN, `DATA_MEM_OUT) DATA_MEMORY
	(
	);

	cache_rw DATA_CACHE_RW
	(
		.GLOB_clk_count_i(GLOBAL_cyclecount),
	
		// Cache interface wires
		.address_i(alu_result_EX_MEM),
		.data_i(reg_2_data_EX_MEM),
		.write_data_i(control_EX_MEM[`MEM_WRITE]),
		.read_data_i(control_EX_MEM[`MEM_READ]),
		.clock_i(clk_i),
		.mem_mode_i(instruction_EX_MEM[`MEM_MODE]),
		.sign_i(control_EX_MEM[`ZERO_EXT_MEM]),
		.read_data_o(data_memory_out),
		
		// Memory InterFace wires
		.MIF_address_o(DATA_MEMORY.address_i),
		.MIF_data_o(DATA_MEMORY.data_i),
		.MIF_write_data_o(DATA_MEMORY.write_data_i),
		.MIF_read_data_o(DATA_MEMORY.read_data_i),
		.MIF_clock_o(DATA_MEMORY.clock_i),
		.MIF_mem_mode_o(DATA_MEMORY.mem_mode_i),
		.MIF_sign_o(DATA_MEMORY.sign_i),
		.MIF_read_data_i(DATA_MEMORY.read_data_o),
		.MIF_stall_i(DATA_MEMORY.stall_o),
		.MIF_dm_led_i(DATA_MEMORY.dm_led_o)
	);
	
// * WB *****************************************************************************************
	// MEM TO WB stage registers
	reg [`MEM_DATA_SIZE] data_mem_out_MEM_WB = 0;
	reg [`GPR_IDX_SIZE] reg_wr_addr_MEM_WB = 0;
	reg [`GPR_SIZE] alu_result_MEM_WB = 0;
	reg [`CONTROL_SIZE] control_MEM_WB = 0;
	reg [`PC_SIZE] pc_MEM_WB = 0;
	reg [`INSTR_SIZE] instruction_MEM_WB = 0; // for sim debug purpose
	//

	// WB-specific wiring
	assign reg_wr_addr = reg_wr_addr_MEM_WB;
	
	WB_comm WB_COMM_UNIT(
		.control_i(control_MEM_WB),
		.alu_result_i(alu_result_MEM_WB),
		.data_mem_i(data_mem_out_MEM_WB),
		.pc_i(pc_MEM_WB),
		.reg_write_data_o(register_write_data)
	);

// * Logic beyond stages ************************************************************************
	wire [`STAGE_LASTVAL:0] stall_signal;
	stall_unit STALL_UNIT(
		.reg_wr_addr_ID_EX_i(reg_wr_addr_ID_EX),
		.reg_wr_addr_EX_MEM_i(reg_wr_addr_EX_MEM),
		.reg_wr_addr_MEM_WB_i(reg_wr_addr_MEM_WB),
	
		.ID_EX_rt_i(instruction_ID_EX[`RT]),
		.ID_EX_rs_i(instruction_ID_EX[`RS]),
		.IF_ID_rt_i(instruction_IF_ID[`RT]),
		.IF_ID_rs_i(instruction_IF_ID[`RS]),
		.ID_EX_mem_read_i(control_ID_EX[`MEM_READ]),
		.stall_o(stall_signal),
		
		.EX_MEM_mem_read_i(control_EX_MEM[`MEM_READ]),
		.ID_EX_write_reg_i(control_ID_EX[`REG_WRITE]),
		.ID_jump_reg_i(control_unit_out[`JUMP_REG]),
		
		.DM_stall_i(DATA_CACHE_RW.stall_o)
	);
	
	
	wire [1:0] jump_reg_contol;
	forward_unit FORWARD_UNIT(
		.MEM_WB_rd_i(reg_wr_addr_MEM_WB),
		.EX_MEM_rd_i(reg_wr_addr_EX_MEM),
		.ID_EX_rd_i(reg_wr_addr_ID_EX),
		.ID_EX_rs_i(instruction_ID_EX[`RS]),
		.ID_EX_rt_i(instruction_ID_EX[`RT]),
		.is_rt_input_i(control_ID_EX[`REG_OUT_RD] | control_ID_EX[`REG_IN_RT]),
		.is_imm_to_reg_i(control_ID_EX[`IMM_TO_REG]),
		.MEM_WB_reg_write_i(control_MEM_WB[`REG_WRITE]),
		.EX_MEM_reg_write_i(control_EX_MEM[`REG_WRITE]),
		
		.EX_first_operand_control_o(first_operand_contol),
		.EX_second_operand_control_o(second_operand_contol),
		.ID_jump_reg_control_o(jump_reg_contol)
	);

//`define NO_STALLS
`ifndef NO_STALLS
	// Do we need to stall the stage
	wire [`STAGE_LASTVAL:0] stall_flag;
	assign stall_flag[`STAGE_IF]  = (stall_signal[`STAGE_MEM] || stall_signal[`STAGE_EX] || stall_signal[`STAGE_ID]);
	assign stall_flag[`STAGE_ID]  = (stall_signal[`STAGE_MEM] || stall_signal[`STAGE_EX] || stall_signal[`STAGE_ID]);
	assign stall_flag[`STAGE_EX]  = (stall_signal[`STAGE_MEM] || stall_signal[`STAGE_EX]);
	assign stall_flag[`STAGE_MEM] = (stall_signal[`STAGE_MEM]) && is_cpu_enabled;
	assign stall_flag[`STAGE_WB]  = (0);
	
	// Do we need to drop results of the stage
	wire [`STAGE_LASTVAL:0] flush_flag;
	assign flush_flag[`STAGE_IF]  = branch_decision;
	assign flush_flag[`STAGE_ID]  = stall_signal[`STAGE_ID] && (!stall_signal[`STAGE_EX]) && (!stall_signal[`STAGE_MEM]);
	assign flush_flag[`STAGE_EX]  = stall_signal[`STAGE_EX] && (!stall_signal[`STAGE_MEM]);
	assign flush_flag[`STAGE_MEM] = stall_signal[`STAGE_MEM];
	assign flush_flag[`STAGE_WB]  = 0;
`else
	// Do we need to stall the stage
	wire [`STAGE_LASTVAL:0] stall_flag;
	assign stall_flag[`STAGE_IF]  = 0;
	assign stall_flag[`STAGE_ID]  = 0;
	assign stall_flag[`STAGE_EX]  = 0;
	assign stall_flag[`STAGE_MEM] = 0;
	assign stall_flag[`STAGE_WB]  = 0;
	
	// Do we need to drop results of the stage
	wire [`STAGE_LASTVAL:0] flush_flag;
	assign flush_flag[`STAGE_IF]  = branch_decision;
	assign flush_flag[`STAGE_ID]  = 0;
	assign flush_flag[`STAGE_EX]  = 0;
	assign flush_flag[`STAGE_MEM] = 0;
	assign flush_flag[`STAGE_WB]  = 0;
`endif

	assign new_addr = (control_unit_out[`JUMP] || control_unit_out[`JUMP_REG] || branch_decision) && !stall_flag[`STAGE_IF];

	/* Calculate Program Counter */
	
	// If we're stalling in IF => do nothing
	// If we're branching => take pc_addr_EX
	// If we're jumping => take pc_addr_ID
	// otherwise => increment PC
	assign pc_addr_in = stall_flag[`STAGE_IF] ? pc_addr_in : (
													control_ID_EX[`BRANCH] ? pc_addr_EX : (
																			(control_unit_out[`JUMP] || control_unit_out[`JUMP_REG]) ? pc_addr_ID : 123
																			)
													);

	always @ ( `EDGE_WRITE clk_i )
	begin
		if ( is_reset == 0 )
		begin
			GLOBAL_cyclecount <= GLOBAL_cyclecount + 1;
			
			/* Pass values within interstage registers */
		
			/* IF->ID */
			if (!stall_flag[`STAGE_ID])
			begin
				// new
				instruction_IF_ID	<= (stall_flag[`STAGE_IF]) ? instruction_IF_ID : (
																flush_flag[`STAGE_IF] ? 0 : im_out
																);
				pc_IF_ID			<= pc_addr_out;
			end
			
			/* ID->EX */
			if (!stall_flag[`STAGE_EX])
			begin
				// new
				reg_1_data_ID_EX	<= register_1_data_out;
				reg_2_data_ID_EX	<= register_2_data_out;
				full_imm_ID_EX		<= full_imm;
				reg_wr_addr_ID_EX	<= reg_write_addr;

				// transfer
				control_ID_EX		<= (flush_flag[`STAGE_ID]) ? 0 : control_unit_out;
				alu_op_ID_EX		<= alu_opcode_out;
				pc_ID_EX			<= pc_IF_ID;
				instruction_ID_EX	<= instruction_IF_ID;
			end
				
			/* EX->MEM */
			if (!stall_flag[`STAGE_MEM])
			begin
				// new
				alu_zero_EX_MEM		<= alu_zero;
				alu_sign_EX_MEM		<= alu_sign;
				alu_result_EX_MEM	<= alu_result;
				branch_decision_EX_MEM <= branch_decision;
				// transfer
				control_EX_MEM		<= (flush_flag[`STAGE_EX]) ? 0 : control_ID_EX;
				reg_wr_addr_EX_MEM	<= reg_wr_addr_ID_EX;
				reg_2_data_EX_MEM	<= reg_2_data_ID_EX;
				pc_EX_MEM			<= pc_ID_EX;
				instruction_EX_MEM	<= instruction_ID_EX;
			end
			
			/* MEM->WB */
			if (!stall_flag[`STAGE_WB])
			begin
				// new
				data_mem_out_MEM_WB	<= data_memory_out;
				// transfer
				control_MEM_WB		<= (flush_flag[`STAGE_MEM]) ? 0 : control_EX_MEM;
				reg_wr_addr_MEM_WB	<= reg_wr_addr_EX_MEM;
				alu_result_MEM_WB	<= alu_result_EX_MEM;
				pc_MEM_WB			<= pc_EX_MEM;
				instruction_MEM_WB	<= instruction_EX_MEM;
			end
		end
		else
		begin
			GLOBAL_cyclecount <= 0;
			
			/* Pass values within interstage registers */
		
			/* IF->ID */
				instruction_IF_ID	<= 0;
				pc_IF_ID			<= 0;
			
			
			/* ID->EX */

				// new
				reg_1_data_ID_EX	<= 0;
				reg_2_data_ID_EX	<= 0;
				full_imm_ID_EX		<= 0;
				reg_wr_addr_ID_EX	<= 0;

				// transfer
				control_ID_EX		<= 0;
				alu_op_ID_EX		<= 0;
				pc_ID_EX			<= 0;
				instruction_ID_EX	<= 0;

				
			/* EX->MEM */
			
				// new
				alu_zero_EX_MEM		<= 0;
				alu_sign_EX_MEM		<= 0;
				alu_result_EX_MEM	<= 0;
				branch_decision_EX_MEM <= 0;
				// transfer
				control_EX_MEM		<= 0;
				reg_wr_addr_EX_MEM	<= 0;
				reg_2_data_EX_MEM	<= 0;
				pc_EX_MEM			<= 0;
				instruction_EX_MEM	<= 0;
		
			
			/* MEM->WB */
			
				// new
				data_mem_out_MEM_WB	<= 0;
				// transfer
				control_MEM_WB		<= 0;
				reg_wr_addr_MEM_WB	<= 0;
				alu_result_MEM_WB	<= 0;
				pc_MEM_WB			<= 0;
				instruction_MEM_WB	<= 0;
		end
	end
	
	always @ ( enable_i )
	begin
		is_cpu_enabled = enable_i;
	end
	
	always @ ( reset_i )
	begin
		is_reset = reset_i;
	end

endmodule

`endif
