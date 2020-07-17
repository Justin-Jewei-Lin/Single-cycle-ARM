module rotate(immediate_in, rotate_immediate_out);
	input [11:0]immediate_in;
	output [31:0]rotate_immediate_out;
	wire [31:0] tmp;
	assign {tmp, rotate_immediate_out} = {{24'b0, immediate_in[7:0]}, {24'b0, immediate_in[7:0]}} >> {immediate_in[11:8], 1'b0};
endmodule
