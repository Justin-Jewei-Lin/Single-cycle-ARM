module multi_4(sign_immediate_in, sign_extend_immediate_out);
	input [23:0]sign_immediate_in;
	output [31:0]sign_extend_immediate_out;
	
	assign sign_extend_immediate_out = {{6{sign_immediate_in[23]}}, sign_immediate_in, 2'b00};
endmodule
