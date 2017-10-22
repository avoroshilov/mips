`ifndef _def_instr_fields
`define _def_instr_fields

`define R_TYPE_OPCODE 6'b000000

// defines for instruction parts

// Common for all instruction types
`define OPCODE 31:26
`define OPCODE_SIZE 5:0

/* Basic instruction formats */

// Common for I-type and R-type
`define RS 25:21
`define RS_SIZE 4:0
`define RT 20:16
`define RT_SIZE 4:0

// I-type (and FI-type)
`define IMMEDIATE 15:0
`define IMMEDIATE_SIZE 15:0

// R-type
`define RD 15:11
`define RD_SIZE 4:0
`define SHAMT 10:6
`define SHAMT_SIZE 4:0
// R-type (and FR-type)
`define FUNCT 5:0
`define FUNCT_SIZE 5:0

// J-type
`define ADDRESS 25:0
`define ADDRESS_SIZE 25:0

// Mem-related instructions
`define MEM_MODE 27:26
`define MEM_MODE_SIZE 1:0



/* Floating-point instruction formats */

// Common for FI-type and FR-type
`define FMT 25:21
`define FMT_SIZE 4:0
`define FT 20:16
`define FT_SIZE 4:0

// FR-type
`define FS 15:11
`define FS_SIZE 4:0
`define FD 10:6
`define FD_SIZE 4:0

`endif
