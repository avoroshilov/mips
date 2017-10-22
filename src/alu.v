`ifndef _alu
`define _alu

`include "def_funct_field.v"

//`define NO_DIVISIONS
//`define NO_MULTIPLICATIONS

module alu(
	input	wire	[`ALU_OP_SIZE]	param_1_i,
	input	wire	[`ALU_OP_SIZE]	param_2_i,
	input	wire	[5:0]			alu_op_i,
	input	wire					write_lohi_i,
	input	wire					clock_i,
	output	wire	[`ALU_OP_SIZE]	result_o,
	output	wire					zero_o,
	output	wire					sign_o
	);

	reg [`REG_LOHI_SIZE] reg_lo = 0;
	reg [`REG_LOHI_SIZE] reg_hi = 0;
	reg [`REG_LOHI_SIZE] wire_lo = 0;
	reg [`REG_LOHI_SIZE] wire_hi = 0;
	
	reg [`ALU_OP_SIZE] result_reg = 0;
	assign zero_o = (result_reg == 0);
	assign sign_o = result_reg[`GPR_BITS - 1];
	assign result_o = result_reg;

	wire signed [`ALU_OP_SIZE] param_1_i_sgn;
	wire signed [`ALU_OP_SIZE] param_2_i_sgn;
	assign param_1_i_sgn = param_1_i;
	assign param_2_i_sgn = param_2_i;
	
	always @ ( `EDGE_OPERATE clock_i )
	begin
		case (alu_op_i) 
			`FUNCT_AND : 
					result_reg <= param_1_i & param_2_i;
			`FUNCT_OR : 
					result_reg <= param_1_i | param_2_i;
			`FUNCT_ADD : 
					result_reg <= param_1_i + param_2_i;
			`FUNCT_ADDu : 
					result_reg <= param_1_i + param_2_i;
			`FUNCT_SUB : 
					result_reg <= param_1_i - param_2_i;
			`FUNCT_SUBu : 
					result_reg <= param_1_i - param_2_i;
			`FUNCT_SLT : 
					if (param_1_i_sgn < param_2_i_sgn)
						result_reg <= 1;
					else
						result_reg <= 0;
			`FUNCT_SLTu : 
					if (param_1_i < param_2_i)
						result_reg <= 1;
					else
						result_reg <= 0;
			`FUNCT_XOR : 
					result_reg <= param_1_i ^ param_2_i;
			`FUNCT_NOR : 
					result_reg <= ~(param_1_i | param_2_i);
			`FUNCT_SLL :
					result_reg <= (param_1_i << param_2_i);
			`FUNCT_SRL :
					result_reg <= (param_1_i >> param_2_i);
			`FUNCT_SRA :
					result_reg <= (param_1_i_sgn >>> param_2_i_sgn);
					
			/*
				NOTE: these instructions have param1 and param2 swapped
				since shift instructions actually shift target register by the source register
			*/			
			`FUNCT_SLLv :
					result_reg <= (param_2_i << param_1_i[5:0]);
			`FUNCT_SRLv :
					result_reg <= (param_2_i >> param_1_i[5:0]);
			`FUNCT_SRAv :
					result_reg <= (param_2_i_sgn >>> param_1_i_sgn[5:0]);
					
`ifndef NO_MULTIPLICATIONS
			`FUNCT_MUL :
			begin
					{ wire_hi, wire_lo } <= param_1_i_sgn * param_2_i_sgn;
					// MIPS ISA doesn't use RD in MULT, but it shouldn't hurt
					result_reg <= reg_lo;
			end
			`FUNCT_MULu :
			begin
					{ wire_hi, wire_lo } <= param_1_i * param_2_i;
					// MIPS ISA doesn't use RD in MULT, but it shouldn't hurt
					result_reg <= reg_lo;
			end
`endif
`ifndef NO_DIVISIONS
			`FUNCT_DIV :
			begin
					wire_hi <= param_1_i_sgn % param_2_i_sgn;
					wire_lo <= param_1_i_sgn / param_2_i_sgn;
					// MIPS ISA doesn't use RD in DIV, but it shouldn't hurt
					result_reg <= wire_lo;
			end
			`FUNCT_DIVu :
			begin
					wire_hi <= param_1_i % param_2_i;
					wire_lo <= param_1_i / param_2_i;
					// MIPS ISA doesn't use RD in DIV, but it shouldn't hurt
					result_reg <= wire_lo;
			end
`endif
			`FUNCT_MFHI :
					result_reg <= reg_hi;
			`FUNCT_MFLO :
					result_reg <= reg_lo;
			`FUNCT_MTHI :
					wire_hi <= param_1_i;
			`FUNCT_MTLO :
					wire_lo <= param_1_i;
					
			`FUNCT_NOOP :
					result_reg <= param_1_i;
			
			default :
				begin
				end
		endcase
		//$display("ALU(%x): param1 %x / param2 %x / result %x / zero %x", alu_op_i, param_1_i, param_2_i, result_o, zero_o);
	end

	always @ (`EDGE_WRITE clock_i)
	begin
		if (write_lohi_i)
		begin
			reg_lo <= wire_lo;
			reg_hi <= wire_hi;
		end
	end
	
endmodule

`endif
