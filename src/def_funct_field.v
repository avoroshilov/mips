`ifndef _def_funct_field
`define _def_funct_field

`define FUNCT_SLL	6'b000000
`define FUNCT_SRL	6'b000010
`define FUNCT_SRA	6'b000011
`define FUNCT_SLLv	6'b000100
`define FUNCT_SRLv	6'b000110
`define FUNCT_SRAv	6'b000111
`define FUNCT_JMP	6'b001000
`define FUNCT_JALR	6'b001001

`define FUNCT_MFHI	6'b010000
`define FUNCT_MTHI	6'b010001
`define FUNCT_MFLO	6'b010010
`define FUNCT_MTLO	6'b010011

`define FUNCT_MUL	6'b011000
`define FUNCT_MULu	6'b011001
`define FUNCT_DIV	6'b011010
`define FUNCT_DIVu	6'b011011

`define FUNCT_ADD	6'b100000
`define FUNCT_ADDu	6'b100001
`define FUNCT_SUB	6'b100010
`define FUNCT_SUBu	6'b100011
`define FUNCT_AND	6'b100100
`define FUNCT_OR	6'b100101
`define FUNCT_XOR	6'b100110
`define FUNCT_NOR	6'b100111
`define FUNCT_SLT	6'b101010
`define FUNCT_SLTu	6'b101011

// Since we don't actually use FUNCT_JMP in ALU
// and jump instructions don't care about ALU result
// we can re-use JUMP slot for operand pass-through
`define FUNCT_NOOP	`FUNCT_JMP

`endif
