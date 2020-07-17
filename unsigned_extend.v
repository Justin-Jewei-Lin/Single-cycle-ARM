module unsigned_extend(unsign_immediate_in, unsign_extend_immediate_out);
	input [11:0]unsign_immediate_in;
	output [31:0]unsign_extend_immediate_out;
	assign unsign_extend_immediate_out = {20'b0, unsign_immediate_in};
endmodule