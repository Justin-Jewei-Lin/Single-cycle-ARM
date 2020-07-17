`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:42:07 05/26/2014 
// Design Name: 
// Module Name:    ARM2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ARM(clk,rst);
	input clk,rst;
	
	//register
	reg [31:0] pc;
	
	//wire
	wire [31:0]pc_add_4, mem_read_data, instruction;
	wire [1:0] alu_src;
	wire [31:0] alu_out;
	wire [31:0] read_data_1, read_data_2,  read_data_3;
	wire [31:0] sign_extend_out, rotate_out, shift_out, unsign_extend_out;
	wire [3:0] alu_op;
	wire [3:0] nzcv;
	reg [3:0] nzcv_n; 

	//adder
	assign pc_add_4 = pc + 32'd4;
	wire [31:0] pc_branch = sign_extend_out + pc_add_4;

	wire [31:0] reg_write_data = mem_to_reg? (mem_read_data):(alu_out);
	wire [31:0] pc_next = pc_write? ( pc_src? alu_out:alu_out ):( pc_src? pc_branch:pc_add_4 );
	wire [31:0] alu_operation_2 = alu_src[1]? ( alu_src[0]? unsign_extend_out:shift_out ):( alu_src[0]? rotate_out:shift_out );

	ins_mem _ins_mem( .pc(pc), .ins(instruction) );

	data_mem _data_mem( .clk(clk), .rst(rst), .mem_write(mem_write), .addr(alu_out), .write_data(read_data_3), .read_data(mem_read_data));
	
	register_file _register_file(
		.clk(clk), .rst(rst), .reg_write(reg_write), .link(link),
		.read_addr_1(instruction[19:16]), .read_addr_2(instruction[3:0]), .read_addr_3(instruction[15:12]),
		.write_addr(instruction[15:12]), .write_data(reg_write_data), .pc_content(pc_add_4),
		.pc_write(pc_write),
		.read_data_1(read_data_1), .read_data_2(read_data_2), .read_data_3(read_data_3));

	multi_4 _multi_4(.sign_immediate_in(instruction[23:0]), .sign_extend_immediate_out(sign_extend_out));

	rotate _rotate(.immediate_in(instruction[11:0]), .rotate_immediate_out(rotate_out));

	shift _shift(.shift_type(instruction[6:5]), .shift_number(instruction[11:7]), .reg_data(read_data_2), .shift_out(shift_out));

	unsigned_extend _unsigned_extend(.unsign_immediate_in(instruction[11:0]), .unsign_extend_immediate_out(unsign_extend_out));

	alu _alu(.source_1(read_data_1), .source_2(alu_operation_2), .alu_op(alu_op), .c_in(nzcv_n[1]), .nzcv(nzcv), .alu_out(alu_out));

	controller _controller(.nzcv(nzcv_n), .opfunc(instruction[31:20]), .reg_write(reg_write), .alu_src(alu_src), .alu_op(alu_op),
		.mem_to_reg(mem_to_reg), .mem_write(mem_write), .pc_src(pc_src), .update_nzcv(update_nzcv), .link(link));

	always@(posedge clk or posedge rst)
		if (rst)
			nzcv_n <= 4'b0;
		else
			nzcv_n <= (update_nzcv)? nzcv:nzcv_n; 

	always@(posedge clk or posedge rst)
	begin
		if( rst == 1'b1 )
			pc <= 32'd0;
		else
//			pc = pc_add_4;
			pc <= pc_next;
	end
endmodule
