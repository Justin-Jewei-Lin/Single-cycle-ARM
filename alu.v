module alu(source_1, source_2, alu_op, c_in, nzcv, alu_out);
	input [31:0] source_1, source_2;
	input [3:0] alu_op;
	input c_in;
	output [3:0] nzcv;
	output reg [31:0] alu_out;
	reg c, v;

	// A carry occurs:
	//  if the result of an addition is greater than or equal to 2^32
	//  if the result of a subtraction is positive or zero (*)
	//  as the result of an inline barrel shifter operation in a move or logical instruction.

	always@(*)
		case (alu_op)
			4'b0000: {c, alu_out} = {1'b0, source_1 & source_2};								// AND
			4'b0001: {c, alu_out} = {1'b0, source_1 ^ source_2};								// EOR
			4'b0010: {c, alu_out} = {1'b1, source_1} - {1'b0, source_2}; 						// SUB
			4'b0011: {c, alu_out} = {1'b1, source_2} - {1'b0, source_1};						// RSB
			4'b0100: {c, alu_out} = {1'b0, source_1} + {1'b0, source_2};						// ADD
			4'b0101: {c, alu_out} = {1'b0, source_1} + {1'b0, source_2} + {32'b0, c_in};		// ADC
			4'b0110: {c, alu_out} = {1'b1, source_1} - {1'b0, source_2} + {32'b0, c_in} - 33'b1;// SBC
			4'b0111: {c, alu_out} = {1'b1, source_2} - {1'b0, source_1} + {32'b0, c_in} - 33'b1;// RSC
			4'b1000: {c, alu_out} = {1'b0, source_1 & source_2};								// TST
			4'b1001: {c, alu_out} = {1'b0, source_1 ^ source_2};								// TEQ
			4'b1010: {c, alu_out} = {1'b1, source_1} - {1'b0, source_2};						// CMP
			4'b1011: {c, alu_out} = {1'b0, source_1} + {1'b0, source_2};						// CMN
			4'b1100: {c, alu_out} = {1'b0, source_1 | source_2};								// OR
			4'b1101: {c, alu_out} = {1'b0, source_2};											// MOV
			4'b1110: {c, alu_out} = {1'b0, source_1 & ~source_2};								// BIC
			4'b1111: {c, alu_out} = {1'b0, ~source_2};											// MVN
        endcase

    always@(*)
        casex(alu_op)
			// Operand1 + Operand2: 0100 0101 1011				=> 010x 1011
			// Operand1 - Operand2: 0010 0110 1010				=> 0x10 1010
			// Operand2 - Operand1: 0011 0111					=> 0x11
			// Logic: 0000 0001 1000 1001 1100 1101 1110 1111 	=> x00x 11xx (default)
			4'b010x, 4'b1011: v = (source_1[31] ^ alu_out[31]) & (source_1[31] ^~ source_2[31]);
			4'b0x10, 4'b1010: v = (source_1[31] ^ alu_out[31]) & (source_1[31] ^  source_2[31]);
			4'b0x11:		  v = (source_2[31] ^ alu_out[31]) & (source_2[31] ^  source_1[31]);
			default: v = 1'b0;
        endcase
		
    assign nzcv = {alu_out[31], ~(|alu_out), c, v};
endmodule