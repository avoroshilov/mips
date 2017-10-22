`ifndef _def_mips_isa
`define _def_mips_isa

`include "def_general.v"
`include "def_control_bits.v"

`define SET(PROP) (1 << (PROP))

//NAME TYPE OPCODE/FUNCT ACTION

// * Jump ******************************************************************************************

//# J-type #########################################################################################
//j J 02/- JUMP PC = JumpAddr
`define J_OPCODE					6'b000010 
`define J_ALUOP						`FUNCT_NOOP
`define J_CONTROL_FLAGS				(`SET(`JUMP))
//jal J 03/- JUMP AND LINK R[31] = PC+8; PC=JumpAddr
`define JAL_OPCODE					6'b000011
`define JAL_ALUOP					`FUNCT_NOOP
`define JAL_CONTROL_FLAGS			(`SET(`JUMP) | `SET(`LINK) | `SET(`REG_OUT_RA) | `SET(`REG_WRITE))

//# R-type #########################################################################################
//jr R 0/08 JUMP REGISTER PC=R[rs]
`define JR_OPCODE					6'b000000
`define JR_CONTROL_FLAGS			(`SET(`JUMP_REG))
//jalr R 0/09 JUMP REGISTER AND LINK R[rd] = PC+8; PC=R[rs]
`define JALR_OPCODE					6'b000000
`define JALR_CONTROL_FLAGS			(`SET(`JUMP_REG) | `SET(`LINK) | `SET(`REG_OUT_RD) | `SET(`REG_WRITE))

// *************************************************************************************************


// * Arithmetic/logic ******************************************************************************

//add R 0/20 ADD R[rd] = R[rs] + R[rt]
`define ADD_OPCODE					6'b000000
`define ADD_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//addu R 0/21 ADD UNSIGNED R[rd] = R[rs] + R[rt]
`define ADDU_OPCODE					6'b000000
`define ADDU_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//and R 0/24 AND R[rd] = R[rs] & R[rt]
`define AND_OPCODE					6'b000000
`define AND_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//or R 0/25 OR R[rd] = R[rs] | R[rt]
`define OR_OPCODE					6'b000000
`define OR_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//nor R 0/27 NOR R[rd] = ~ (R[rs] | R[rt])
`define NOR_OPCODE					6'b000000
`define NOR_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//xor R 0/26 XOR R[rd] = R[rs] ^ R[rt]
`define XOR_OPCODE					6'b000000
`define XOR_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//sub R 0/22 SUB R[rd] = R[rs] - R[rt]
`define SUB_OPCODE					6'b000000
`define SUB_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//subu R 0/23 SUB UNSIGNED R[rd] = R[rs] - R[rt]
`define SUBU_OPCODE					6'b000000
`define SUBU_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//sll R 0/00 SHIFT LEFT LOGICAL R[rd] = R[rt] << shamt
`define SLL_OPCODE					6'b000000
`define SLL_CONTROL_FLAGS			(`SET(`KLUDGY_ALU_SWAP) | `SET(`IMM_SHAMT) | `SET(`ALU_SRC_IMM) | `SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//sllv R 0/04 SHIFT LEFT LOGICAL VARIABLE R[rd] = R[rt] << R[rs]
`define SLLV_OPCODE					6'b000000
`define SLLV_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//srl R 0/02 SHIFT RIGHT LOGICAL R[rd] = R[rt] >> shamt
`define SRL_OPCODE					6'b000000
`define SRL_CONTROL_FLAGS			(`SET(`KLUDGY_ALU_SWAP) | `SET(`IMM_SHAMT) | `SET(`ALU_SRC_IMM) | `SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//srlv R 0/06 SHIFT RIGHT LOGICAL VARIABLE R[rd] = R[rt] >> R[rs]
`define SRLV_OPCODE					6'b000000
`define SRLV_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//sra R 0/03 SHIFT RIGHT ARITH R R[rd] = R[rt] >>> shamt
`define SRA_OPCODE					6'b000000
`define SRA_CONTROL_FLAGS			(`SET(`KLUDGY_ALU_SWAP) | `SET(`IMM_SHAMT) | `SET(`ALU_SRC_IMM) | `SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//srav R 0/07 SHIFT RIGHT ARITH VARIABLE R[rd] = R[rt] >>> R[rs]
`define SRAV_OPCODE					6'b000000
`define SRAV_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))

//div R 0/1a DIVIDE Lo=R[rs]/R[rt]; Hi=R[rs]%R[rt]
`define DIV_OPCODE					6'b000000
`define DIV_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`WRITE_LOHI))
//divu R 0/1b DIVIDE UNSIGNED Lo=R[rs]/R[rt]; Hi=R[rs]%R[rt]
`define DIVU_OPCODE					6'b000000
`define DIVU_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`WRITE_LOHI))
//mult R 0/18 MULTIPLY {Hi,Lo} = R[rs] * R[rt]
`define MULT_OPCODE					6'b000000
`define MULT_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`WRITE_LOHI))
//multu R 0/19 MULTIPLY UNSIGNED {Hi,Lo} = R[rs] * R[rt]
`define MULTU_OPCODE				6'b000000
`define MULTU_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`WRITE_LOHI))

// *************************************************************************************************


// * Hi/Lo register ops ****************************************************************************

//mfhi R 0/10 MOVE FROM HI R[rd] = Hi
`define MFHI_OPCODE					6'b000000
`define MFHI_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//mflo R 0/12 MOVE FROM LO R[rd] = Lo
`define MFLO_OPCODE					6'b000000
`define MFLO_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//mthi R 0/11 MOVE TO HI Hi = R[rs]
`define MTHI_OPCODE					6'b000000
`define MTHI_CONTROL_FLAGS			(`SET(`WRITE_LOHI))
//mtlo R 0/13 MOVE TO LO Lo = R[rs]
`define MTLO_OPCODE					6'b000000
`define MTLO_CONTROL_FLAGS			(`SET(`WRITE_LOHI))

// *************************************************************************************************


// * Set on less than ******************************************************************************

//slt R 0/2a SET LESS THAN R[rd] = (R[rs] < R[rt]) ? 1 : 0
`define SLT_OPCODE					6'b000000
`define SLT_ALUOP					`FUNCT_SLTu
`define SLT_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))
//sltu R 0/2b SET LESS THAN UNSIGNED R[rd] = (R[rs] < R[rt]) ? 1 : 0
`define SLTU_OPCODE					6'b000000
`define SLTU_ALUOP					`FUNCT_SLTu
`define SLTU_CONTROL_FLAGS			(`SET(`REG_OUT_RD) | `SET(`REG_WRITE))

//# I-type #########################################################################################
//slti I 0a/- SET LESS THAN IMMEDIATE R[rt] = (R[rs] < SignExtImm)? 1 : 0 (2)
`define SLTI_OPCODE					6'b001010
`define SLTI_ALUOP					`FUNCT_SLT
`define SLTI_CONTROL_FLAGS			(`SET(`ALU_SRC_IMM) | `SET(`REG_WRITE))
//sltiu I 0b/- SET LESS THAN IMMEDIATE UNSIGNED R[rt] = (R[rs] < SignExtImm)? 1 : 0
`define SLTIU_OPCODE				6'b001011
`define SLTIU_ALUOP					`FUNCT_SLTu
`define SLTIU_CONTROL_FLAGS			(`SET(`ALU_SRC_IMM) | `SET(`REG_WRITE))

// *************************************************************************************************


// * Arithmetic/logic IMMEDIATE ********************************************************************

//addi I 08/- ADD IMMEDIATE R[rt] = R[rs] = SignExtImm
`define ADDI_OPCODE					6'b001000
`define ADDI_ALUOP					`FUNCT_ADD
`define ADDI_CONTROL_FLAGS			(`SET(`ALU_SRC_IMM) | `SET(`REG_WRITE))
//addiu I 09/- ADD IMMEDIATE UNSIGNED R[rt] = R[rs] = SignExtImm
`define ADDIU_OPCODE				6'b001001
`define ADDIU_ALUOP					`FUNCT_ADDu
`define ADDIU_CONTROL_FLAGS			(`SET(`ALU_SRC_IMM) | `SET(`REG_WRITE))
//andi I 0c/- AND IMMEDIATE R[rt] = R[rs] & ZeroExtImm
`define ANDI_OPCODE					6'b001100
`define ANDI_ALUOP					`FUNCT_AND
`define ANDI_CONTROL_FLAGS			(`SET(`ALU_SRC_IMM) | `SET(`REG_WRITE) | `SET(`ZERO_EXT))
//ori I 0d/- OR IMMEDIATE R[rt] = R[rs] | ZeroExtImm
`define ORI_OPCODE					6'b001101
`define ORI_ALUOP					`FUNCT_OR
`define ORI_CONTROL_FLAGS			(`SET(`ALU_SRC_IMM) | `SET(`REG_WRITE) | `SET(`ZERO_EXT))
//xori I 0e/- OR IMMEDIATE R[rt] = R[rs] ^ ZeroExtImm
`define XORI_OPCODE					6'b001110
`define XORI_ALUOP					`FUNCT_XOR
`define XORI_CONTROL_FLAGS			(`SET(`ALU_SRC_IMM) | `SET(`REG_WRITE) | `SET(`ZERO_EXT))

// *************************************************************************************************


// * Branch ****************************************************************************************

//beq I 04/- BRANCH ON EQUAL if(R[rs]==R[rt]) PC=PC+4+BranchAddr
`define BEQ_OPCODE					6'b000100
`define BEQ_ALUOP					`FUNCT_SUB
`define BEQ_CONTROL_FLAGS			(`SET(`BRANCH) | `SET(`EQ_ZERO) | `SET(`REG_IN_RT))
//bne I 05/- BRANCH ON NOT EQUAL if(R[rs]!=R[rt]) PC=PC+4+BranchAddr
`define BNE_OPCODE					6'b000101
`define BNE_ALUOP					`FUNCT_SUB
`define BNE_CONTROL_FLAGS			(`SET(`BRANCH) | `SET(`LESS_ZERO) | `SET(`GREATER_ZERO) | `SET(`REG_IN_RT))
//bgez Branch on greater than or equal to zero
`define BGEZ_OPCODE					6'b000001
`define BGEZ_ALUOP					`FUNCT_SUBu
`define BGEZ_CONTROL_FLAGS			(`SET(`BRANCH) | `SET(`EQ_ZERO) | `SET(`GREATER_ZERO))
`define	BGEZ_BRN_FIELD				5'b00001
//bgezal Branch on greater than or equal to zero and link
`define BGEZAL_OPCODE				6'b000001
`define BGEZAL_ALUOP				`FUNCT_NOOP
`define BGEZAL_CONTROL_FLAGS		(`SET(`BRANCH) | `SET(`LINK) | `SET(`EQ_ZERO) | `SET(`GREATER_ZERO) | `SET(`REG_OUT_RA) | `SET(`REG_WRITE))
`define	BGEZAL_BRN_FIELD			5'b10001
//bltz Branch on less than zero
`define BLTZ_OPCODE					6'b000001
`define BLTZ_ALUOP					`FUNCT_NOOP
`define BLTZ_CONTROL_FLAGS			(`SET(`BRANCH) | `SET(`LESS_ZERO))
`define	BLTZ_BRN_FIELD				5'b00000
//bltzal  Branch on less than zero and link
`define BLTZAL_OPCODE				6'b000001
`define BLTZAL_ALUOP				`FUNCT_NOOP
`define BLTZAL_CONTROL_FLAGS		(`SET(`BRANCH) | `SET(`LINK) | `SET(`LESS_ZERO) | `SET(`REG_OUT_RA) | `SET(`REG_WRITE))
`define	BLTZAL_BRN_FIELD			5'b10000
//blez Branch on less than or equal to zero
`define BLEZ_OPCODE					6'b000110
`define BLEZ_ALUOP					`FUNCT_NOOP
`define BLEZ_CONTROL_FLAGS			(`SET(`BRANCH) | `SET(`EQ_ZERO) | `SET(`LESS_ZERO))
`define	BLEZ_BRN_FIELD				5'b00000
//bgtz Branch on greater than zero
`define BGTZ_OPCODE					6'b000111
`define BGTZ_ALUOP					`FUNCT_NOOP
`define BGTZ_CONTROL_FLAGS			(`SET(`BRANCH) | `SET(`GREATER_ZERO))
`define	BGTZ_BRN_FIELD				5'b00000

// *************************************************************************************************


// * Memory ****************************************************************************************

//lbu I 24/- LOAD BYTE UNSIGNED  R[rt]={24’b0,M[R[rs]+SignExtImm](7:0)}
`define LBU_OPCODE					6'b100100
`define LBU_ALUOP					`FUNCT_ADD
`define LBU_CONTROL_FLAGS			(`SET(`MEM_TO_REG) | `SET(`MEM_READ) | `SET(`REG_WRITE) | `SET(`ALU_SRC_IMM) | `SET(`ZERO_EXT_MEM))
//lhu I 25/- LOAD HALFWORD UNSIGNED R[rt]={16’b0,M[R[rs]+SignExtImm](15:0)}
`define LHU_OPCODE					6'b100101
`define LHU_ALUOP					`FUNCT_ADD
`define LHU_CONTROL_FLAGS			(`SET(`MEM_TO_REG) | `SET(`MEM_READ) | `SET(`REG_WRITE) | `SET(`ALU_SRC_IMM) | `SET(`ZERO_EXT_MEM))
//lb I 24/- LOAD BYTE  R[rt]={24’bSgn,M[R[rs]+SignExtImm](7:0)}
`define LB_OPCODE					6'b100000
`define LB_ALUOP					`FUNCT_ADD
`define LB_CONTROL_FLAGS			(`SET(`MEM_TO_REG) | `SET(`MEM_READ) | `SET(`REG_WRITE) | `SET(`ALU_SRC_IMM))
//lh I 25/- LOAD HALFWORD R[rt]={16’bSgn,M[R[rs]+SignExtImm](15:0)}
`define LH_OPCODE					6'b100001
`define LH_ALUOP					`FUNCT_ADD
`define LH_CONTROL_FLAGS			(`SET(`MEM_TO_REG) | `SET(`MEM_READ) | `SET(`REG_WRITE) | `SET(`ALU_SRC_IMM))
//ll I 30/- LOAD LINKED R[rt] = M[R[rs]+SignExtImm]
`define LL_OPCODE					6'b110000
`define LL_FLAGS					7'b1000010
//lui I 0f/- LOAD UPPER IMMEDIATE R[rt] = {imm, 16’b0}
`define LUI_OPCODE					6'b001111
`define LUI_ALUOP					`FUNCT_NOOP
`define LUI_CONTROL_FLAGS			(`SET(`IMM_SHIFT) | `SET(`IMM_TO_REG) | `SET(`REG_WRITE))
//lw I 23/- LOAD WORD R[rt] = M[R[rs]+SignExtImm]
`define LW_OPCODE					6'b100011
`define LW_ALUOP					`FUNCT_ADD
`define LW_CONTROL_FLAGS			(`SET(`MEM_TO_REG) | `SET(`MEM_READ) | `SET(`REG_WRITE) | `SET(`ALU_SRC_IMM))
//sb I 28/- STORE BYTE M[R[rs]+SignExtImm](7:0) = R[rt](7:0)
`define SB_OPCODE					6'b101000
`define SB_ALUOP					`FUNCT_ADD
`define SB_CONTROL_FLAGS			(`SET(`MEM_WRITE) | `SET(`ALU_SRC_IMM))
//sc I 38/- STORE CONDITIONAL M[R[rs]+SignExtImm] = R[rt]; R[rt] = ( atomic ) ? 1 : 0
`define SC_OPCODE					6'b111000
`define SC_FLAGS					7'b1000010
//sh I 29/- STORE HALFWORD M[R[rs]+SignExtImm](15:0) = R[rt](15:0)
`define SH_OPCODE					6'b101001
`define SH_ALUOP					`FUNCT_ADD
`define SH_CONTROL_FLAGS			(`SET(`MEM_WRITE) | `SET(`ALU_SRC_IMM))
//sw I 2b/- STORE WORD M[R[rs]+SignExtImm] = R[rt]
`define SW_OPCODE					6'b101011
`define SW_ALUOP					`FUNCT_ADD
`define SW_CONTROL_FLAGS			(`SET(`MEM_WRITE) | `SET(`ALU_SRC_IMM))

// *************************************************************************************************


//NAME TYPE OPCODE/FMT/FT/FUNCT ACTION

// #fp #############################################################################################
//mfc0 R 10/00/-/00 MOVE FROM CONTROL R[rd] = CR[rs]
`define MFC0_OPCODE					6'b010000
`define MFC0_FMT					5'b00000
`define MFC0_FT						UNDEFINED
//bclt FI 11/08/01/- BRANCH ON FP TRUE if(FPcond)PC=PC+4+BranchAddr
`define BCLT_OPCODE					6'b010001
`define BCLT_FMT					5'b01000
`define BCLT_FT						5'b00001
//bclf FI 11/08/00/- BRANCH ON FP FALSE f(!FPcond)PC=PC+4+BranchAddr
`define BCLF_OPCODE					6'b010001
`define BCLF_FMT					5'b01000
`define BCLF_FT						5'b00000
//add.s FR 11/10/-/00 FP ADD SINGLE F[fd ]= F[fs] + F[ft]
`define ADDS_OPCODE					6'b010001
`define ADDS_FMT					5'b10000
`define ADDS_FT						UNDEFINED
//add.d FR 11/11/-/00 FP ADD DOUBLE {F[fd],F[fd+1]} = {F[fs],F[fs+1]} + {F[ft],F[ft+1]}
`define ADDD_OPCODE					6'b010001
`define ADDD_FMT					5'b10001
`define ADDD_FT						UNDEFINED
//c.x.s FR 11/10/-/y COMPARE FP SINGLE Pcond = (F[fs] op F[ft]) ? 1 : 0
//( x is eq , lt , or le ) ( op is ==, <, or <=) ( y is 32, 3c, or 3e)
`define CXS_OPCODE					6'b010001
`define CXS_FMT						5'b10000
`define CXS_FT						UNDEFINED
//c.x.d FR 11/11/-/y COMPARE FP DOUBLE FPcond = ({F[fs],F[fs+1]} op {F[ft],F[ft+1]}) ? 1 : 0
//( x is eq , lt , or le ) ( op is ==, <, or <=) ( y is 32, 3c, or 3e)
`define CXD_OPCODE					6'b010001
`define CXD_FMT						5'b10001
`define CXD_FT						UNDEFINED
//div.s FR 11/10/-/03 DIVIDE SINGLE F[fd] = F[fs] / F[ft]
`define DIVS_OPCODE					6'b010001
`define DIVS_FMT					5'b10000
`define DIVS_FT						UNDEFINED
//div.d FR 11/11/-/03 DIVIDE DOUBLE {F[fd],F[fd+1]} = {F[fs],F[fs+1]} / {F[ft],F[ft+1]}
`define DIVD_OPCODE					6'b010001
`define DIVD_FMT					5'b10001
`define DIVD_FT						UNDEFINED
//mul.s FR 11/10/-/02 MULTIPLY SINGLE F[fd] = F[fs] * F[ft]
`define MULS_OPCODE					6'b010001
`define MULS_FMT					5'b10000
`define MULS_FT						UNDEFINED
//mul.d FR 11/11/-/02 MULTIPLY DOUBLE {F[fd],F[fd+1]} = {F[fs],F[fs+1]} * {F[ft],F[ft+1]}
`define MULD_OPCODE					6'b010001
`define MULD_FMT					5'b10001
`define MULD_FT						UNDEFINED
//sub.s FR 11/10/-/01 SUBSTRACT SINGLE F[fd]=F[fs] - F[ft]
`define SUBS_OPCODE					6'b010001
`define SUBS_FMT					5'b10000
`define SUBS_FT						UNDEFINED
//sub.d FR 11/11/-/01 SUBSTRACT DOUBLE {F[fd],F[fd+1]} = {F[fs],F[fs+1]} - {F[ft],F[ft+1]}
`define SUBD_OPCODE					6'b010001
`define SUBD_FMT					5'b10001
`define SUBD_FT						UNDEFINED
//lwcl I 31/-/-/- LOAD FP SINGLE F[rt]=M[R[rs]+SignExtImm]
`define LWCL_OPCODE					6'b110001
`define LWCL_FMT					UNDEFINED
`define LWCL_FT						UNDEFINED
//ldcl I 35/-/-/- LOAD FP DOUBLE F[rt]=M[R[rs]+SignExtImm]; F[rt+1]=M[R[rs]+SignExtImm+4]
`define LDCL_OPCODE					6'b110101
`define LDCL_FMT					UNDEFINED
`define LDCL_FT						UNDEFINED
//swcl I 39/-/-/- STORE FP SINGLE M[R[rs]+SignExtImm] = F[rt]
`define SWCL_OPCODE					6'b111001
`define SWCL_FMT					UNDEFINED
`define SWCL_FT						UNDEFINED
//sdcl I 3d/-/-/- STORE FP DOUBLE M[R[rs]+SignExtImm] = F[rt]; M[R[rs]+SignExtImm+4] = F[rt+1]
`define SDCL_OPCODE					6'b111101
`define SDCL_FMT					UNDEFINED
`define SDCL_FT						UNDEFINED

`endif
