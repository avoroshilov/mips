`ifndef _alu_tb
`define _alu_tb

`include "./src/alu.v"

module alu_tb();

	reg	[31:0]	param_1 = 0;
	reg	[31:0]	param_2 = 0;
	wire[31:0]	result;
	reg	[3:0]	alu_cmd = 0;

	alu #() ALU_0
	(
		.param_1_i(param_1),
		.param_2_i(param_2),
		.result_o(result),
		.alu_op_i(alu_cmd)
	);

	initial
	begin
		$dumpfile("./logs/alu_tb.vcd");
		$dumpvars();
		#10;
		param_1 = 32'd17;
		param_2 = 32'd17;
		#1;
		alu_cmd = `ALUOP_NOR;
		#1;
		alu_cmd = `ALUOP_OR;
		#1;
		alu_cmd = `ALUOP_ADD;
		#1;
		alu_cmd = `ALUOP_SUB;
		#1;
		alu_cmd = `ALUOP_SLT;
		#1;
		alu_cmd = `ALUOP_AND;
		#1;
	end

endmodule

`endif
