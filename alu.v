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

/*module alu(source_1, source_2, alu_op, c_in, nzcv, alu_out);
	input [31:0]source_1, source_2;
	input [3:0]alu_op;
	input c_in;
	output reg [3:0]nzcv;
	output reg [31:0]alu_out;
	reg c;
	
    wire [32:0] source_1_ext = {source_1[31], source_1};	// sign extended
    wire [32:0] source_2_ext = {source_2[31], source_2};	// sign extended
    //wire [32:0] source_1_ext = {1'b0, source_1};	// zero extended
    //wire [32:0] source_2_ext = {1'b0, source_2};	// zero extended
   

    /*always@(alu_op or source_1 or source_2 or source_1_ext or source_2_ext)
        case(alu_op)
			4'b0000: {c, alu_out} = source_1_ext & source_2_ext;							// AND: Operand1 and Operand2		
			4'b0001: {c, alu_out} = source_1_ext ^ source_2_ext;							// EOR: Operand1 xor Operand2		
			4'b0010: {c, alu_out} = source_1_ext - source_2_ext; 							// SUB: Operand1 - Operand2			
			4'b0011: {c, alu_out} = source_2_ext - source_1_ext;							// RSB: Operand2 - Operand1			
			4'b0100: {c, alu_out} = source_1_ext + source_2_ext;							// ADD: Operand1 + Operand2			
			4'b0101: {c, alu_out} = source_1_ext + source_2_ext + {32'b0, c_in};			// ADC: Operand1 + Operand2 + carry		
			4'b0110: {c, alu_out} = source_1_ext - source_2_ext + {32'b0, c_in} - 33'b1;	// SBC: Operand1 - Operand2 + carry -1	
			4'b0111: {c, alu_out} = source_2_ext - source_1_ext + {32'b0, c_in} - 33'b1;	// RSC: Operand2 - Operand1 + carry -1	
			4'b1000: {c, alu_out} = source_1_ext & source_2_ext;							// TST: As AND, but result is not written	
			4'b1001: {c, alu_out} = source_1_ext ^ source_2_ext;							// TEQ: As XOR, but result is not written	
			4'b1010: {c, alu_out} = source_1_ext - source_2_ext;							// CMP: As SUB, but result is not written	
			4'b1011: {c, alu_out} = source_1_ext + source_2_ext;							// CMN: As ADD, but result is not written	
			4'b1100: {c, alu_out} = source_1_ext | source_2_ext;							// OR : Operand1 or Operand2			
			4'b1101: {c, alu_out} = source_2_ext;											// MOV: Operand2 (Operand1 is ignored)	
			4'b1110: {c, alu_out} = source_1_ext & ~source_2_ext;							// BIC: Operand1 and not Operand2 (Bit clear)
			4'b1111: {c, alu_out} = ~source_2_ext;											// MVN: not Operand2 (Operand1 is ignored)	
			default: {c, alu_out} = 33'bx;
        endcase
		
    always@(alu_op or source_1 or source_2 or source_1_ext or source_2_ext)
        case(alu_op)
			4'b0000: begin alu_out = source_1 & source_2;	c = 1'b0; end			// AND: Operand1 and Operand2
			4'b0001: begin alu_out = source_1 ^ source_2;	c = 1'b0; end			// EOR: Operand1 xor Operand2
			4'b0010: {c, alu_out} = source_1_ext + ~source_2_ext + 33'b1; 		// SUB: Operand1 - Operand2	
			4'b0011: {c, alu_out} = source_2_ext + ~source_1_ext + 33'b1;		// RSB: Operand2 - Operand1	
			4'b0100: {c, alu_out} = source_1_ext + source_2_ext;				// ADD: Operand1 + Operand2
			4'b0101: {c, alu_out} = source_1_ext + source_2_ext + {32'b0, c_in};// ADC: Operand1 + Operand2 + carry
			4'b0110: {c, alu_out} = source_1_ext + ~source_2_ext + {32'b0, c_in};// SBC: Operand1 - Operand2 + carry -1
			4'b0111: {c, alu_out} = source_2_ext + ~source_1_ext + {32'b0, c_in};// RSC: Operand2 - Operand1 + carry -1
			4'b1000: begin alu_out = source_1 & source_2;	c = 1'b0; end			// TST: As AND, but result is not written
			4'b1001: begin alu_out = source_1 ^ source_2;	c = 1'b0; end			// TEQ: As XOR, but result is not written
			4'b1010: {c, alu_out} = source_1_ext + ~source_2_ext + 33'b1;		// CMP: As SUB, but result is not written
			4'b1011: {c, alu_out} = source_1_ext + source_2_ext;				// CMN: As ADD, but result is not written
			4'b1100: begin alu_out = source_1 | source_2;	c = 1'b0; end			// OR : Operand1 or Operand2
			4'b1101: begin alu_out = source_2;				c = 1'b0; end				// MOV: Operand2 (Operand1 is ignored)
			4'b1110: begin alu_out = source_1 & ~source_2;	c = 1'b0; end			// BIC: Operand1 and not Operand2 (Bit clear)
			4'b1111: begin alu_out = ~source_2;				c = 1'b0; end				// MVN: not Operand2 (Operand1 is ignored)
			default: {c, alu_out} = 33'bx;
        endcase
		
		

    //assign nzcv = {alu_out[31], ~|alu_out[31:0], c, (c ^ alu_out[31])};
    //assign nzcv[3:1] = {alu_out[31], ~|alu_out[31:0], c};
	always@(alu_op or alu_out or source_1_ext or source_2_ext) begin
		//nzcv[3:1] = {alu_out[31], ~|alu_out[31:0], c};
		casex(alu_op)
			4'bx00x, 4'b11xx: nzcv[3:1] = {alu_out[31], ~|alu_out[31:0], 1'b0};
			default: nzcv[3:1] = {alu_out[31], ~|alu_out[31:0], c};
		endcase
		casex(alu_op)
			// When source_1 is the operand of SUB: 0011 0111		=> 0x11
			// When source_2 is the operand of SUB: 0010 0110 1010	=> 0x10 1010
			// Logic operation: 0000 0001 1000 1001 1100 1101 1110 1111 => x00x 11xx
			// Simple adding: 0100 0101 1011 => 010x 1011
			4'b0x11: nzcv[0] = ~alu_out[31] & ~source_1_ext[31] &  source_2_ext[31] | alu_out[31] &  source_1_ext[31] & ~source_2_ext[31];
			4'bxx10: nzcv[0] = ~alu_out[31] &  source_1_ext[31] & ~source_2_ext[31] | alu_out[31] & ~source_1_ext[31] &  source_2_ext[31];
			4'bx00x, 4'b11xx: nzcv[0] = 0;
			default: nzcv[0] = ~alu_out[31] &  source_1_ext[31] &  source_2_ext[31] | alu_out[31] & ~source_1_ext[31] & ~source_2_ext[31];
		endcase
	end
    /*assign nzcv[0]	 = (~alu_out[31])&(source_1_ext[31])&(source_2_ext[31])
	 				  |(alu_out[31])&(~source_1_ext[31])&(~source_2_ext[31]);
endmodule*/