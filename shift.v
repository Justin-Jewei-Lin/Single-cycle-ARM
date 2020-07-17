module shift(reg_data, shift_type, shift_number, shift_out);
	input [1:0]shift_type;
	input [4:0]shift_number;
	input [31:0]reg_data;
	output  [31:0]shift_out;
	
	reg signed [31:0]shift_out;
	reg [31:0] tmp;
	
	always@(*) begin
		case(shift_type)
			2'b00: shift_out = reg_data << shift_number;
			2'b01: shift_out = reg_data >> shift_number;
			2'b10: shift_out = reg_data >>> shift_number;
//			2'b11: shift_out = {reg_data, reg_data}[63-shift_number:32-shift_number];
			2'b11: {tmp, shift_out} = {reg_data, reg_data} >> shift_number;	// right rotate
		endcase
	end
endmodule
