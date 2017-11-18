`ifndef _control_tb
`define _control_tb

`include "./src/control.v"

module control_tb();

	reg [5:0] opcode;
	wire [8:0] out;

	control #() CONTROL_0
	(
		.opcode_i(opcode),
		.control_o(out)
	);

	initial
	begin
		$dumpfile("./logs/control_tb.vcd");
		$dumpvars();
		opcode <= 6'b000000;
		#1;
		opcode <= 6'b100011;
		#1;
		opcode <= 6'b101011;
		#1;
		opcode <= 6'b000100;
		#1;
		opcode <= 6'b111111;
		#1;
	end

endmodule

`endif
