`ifndef _def_general
`define _def_general

`define EDGE_OPERATIONAL_POS
`ifdef EDGE_OPERATIONAL_POS
	`define EDGE_OPERATE	posedge
	`define EDGE_WRITE		negedge
`else
	`define EDGE_OPERATE	negedge
	`define EDGE_WRITE		posedge
`endif

`define R_TYPE_OPCODE		6'b000000
`define BRANCH_COMP_OPCODE	6'b000001

`define ALU_OP_BITS		32
`define ALU_OP_SIZE		(`ALU_OP_BITS-1):0
`define PC_BITS			32
`define PC_SIZE			(`PC_BITS-1):0
`define MEM_DATA_SIZE	31:0
`define INSTR_SIZE		31:0

`define REG_LOHI_BITS	32
`define REG_LOHI_SIZE	(`REG_LOHI_BITS-1):0

`define GPR_NUM			32
`define GPR_BITS		32
`define GPR_SIZE		(`GPR_BITS-1):0
`define GPR_IDX_BITS	5
`define GPR_IDX_SIZE	(`GPR_IDX_BITS-1):0

`define GPR_IDX_RA		`GPR_IDX_BITS'd31
`define STOP_INSTRUCTION 32'hdffc0000

`define STOP_ADDR		32'hDEADE17D

`define GLOB_CLKCOUNT_BITS	32
`define GLOB_CLKCOUNT_SIZE	(`GLOB_CLKCOUNT_BITS-1):0


`endif
