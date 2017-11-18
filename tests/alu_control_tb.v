`ifndef _alu_control_tb
`define _alu_control_tb

`include "./src/alu_control.v"

module alu_control_tb();

	reg [1:0] alu_op;
	reg [5:0] funct_field;
	wire [3:0] alu_control_out;

	reg [15:0] counter;

	alu_control #() ALU_CONTROL_0
	(
		.alu_op_i(alu_op),
		.funct_field_i(funct_field),
		.operation_o(alu_control_out)
	);

	initial
	begin
		$dumpfile("./logs/alu_control_tb.vcd");
		$dumpvars();
		for (counter = 0; counter < 4; counter = counter + 1)
		begin
			alu_op <= counter;
			funct_field <= 4'b0000;
			#1;
			funct_field <= 4'b0010;
			#1;
			funct_field <= 4'b0100;
			#1;
			funct_field <= 4'b0101;
			#1;
			funct_field <= 4'b1010;
			#1;
			funct_field <= 4'b1111;
			#1;
		end
	end

endmodule

`endif
