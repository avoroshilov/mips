`ifndef _def_control_bits
`define _def_control_bits

`define LAST_PROPERTY_BIT 23
`define	REG_IN_RT	23		// For instructions where Rt is input register, not output
`define	GREATER_ZERO	22
`define	LESS_ZERO	21
`define	EQ_ZERO		20		
`define EXCEPTION	19		//can generate exception
`define ATOMIC		18		//is atomic operation
`define WRITE_LOHI	17		//do we need to write into internal ALU reg lo/hi (mul/div ops only)
`define KLUDGY_ALU_SWAP	16	//BUTTHURT! kludge, needed in order for shifts to work in the core MIPS ISA (they do rt << shamt, instead of rs which is first ALU parameter by default) 
`define IMM_SHAMT	15		//set imm to shamt
`define IMM_SHIFT	14		//shift imm by 16
`define LINK		13		//writes PC+8 into output register
`define ZERO_EXT	12		//zero extend imm
`define ZERO_EXT_MEM	11		//zero extend data from memory
`define JUMP_REG	10		//determines if it should jump to the im_out[`RS]
`define JUMP		9		//inst is jump J-type
`define BRANCH		8		//inst is branch
`define REG_OUT_RA	7		//forces output register idx to $ra ($31)
`define REG_OUT_RD	6		//control_o[`REG_OUT_RD] == 0 ? im_out[`RT] : im_out[`RD] - RT used for immediates mostly
`define ALU_SRC_IMM	5		//uses 16 bit of opcode as second operand
`define IMM_TO_REG	4		//select output the register should be written from [if 1 then from immediate]
`define MEM_TO_REG	3		//select output the register should be written from [if 1 then from memory]
`define REG_WRITE	2		//writes register
`define MEM_READ	1		//reads mem
`define MEM_WRITE	0		//writes mem

`define CONTROL_NOOP	0	// Which flags should be set for NOP

`endif
