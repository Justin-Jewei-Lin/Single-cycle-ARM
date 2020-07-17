`timescale 1ns / 1ps
`define CYCLE  5
`define PROGRAM  "arm_tb_program_4.txt"
`define MEM_DATA  "arm_tb_mem_data_4.txt"
`define ANSWER  "arm_tb_answer_4.txt"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:38:26 04/25/2014
// Design Name:   ARM
// Module Name:   D:/Copy/NCKU/NCKU_SoC/Digital Logic Experiments/Logic Desing 104/Final project/ARM/tb_ARM.v
// Project Name:  ARM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ARM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_ARM_4;

	// Inputs
	reg clk;
	reg rst;
	
	parameter DATA_MEM_SIZE = 64;
	parameter INS_MEM_SIZE = 32;

	// Instantiate the Unit Under Test (UUT)
	ARM uut (
		.clk(clk), 
		.rst(rst)
	);

 
	integer error, i;
	reg [31:0]tb_answer[DATA_MEM_SIZE-1: 0];

	
	always #(`CYCLE) clk=~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		error = 0;
		#(`CYCLE*2) rst = 0;
		
		$readmemh(`PROGRAM, uut._ins_mem.mem);
		$readmemh(`MEM_DATA, uut._data_mem.mem);
		$readmemh(`ANSWER, tb_answer);
		
	end
	
	always@(posedge clk)
	begin
		#1 if( uut.pc >= INS_MEM_SIZE*4 )
			begin
				for(i=0 ;i<DATA_MEM_SIZE; i=i+1)
				begin
					if( uut._data_mem.mem[i] !=  tb_answer[i] )
						begin
						error = error + 1'b1;
						$display("error at mem[%2d] 0x%h != 0x%h ", i, uut._data_mem.mem[i], tb_answer[i]);
						end
				end
			
			if( error == 32'd0)
				$display("Congratulation!! All data is correct");
			else
				$display("You have %2d fault !!", error);
			
			$finish; 
			end
	end
      
	// dump vcd file during simulation:
	initial begin
		$dumpfile("tb4.vcd");
		$dumpvars(0, tb_ARM_4);
		$monitor("t=%4d, pc=%H, ins=%H; regw=%b, addr=%H, wdata=%H; memw=%b, addr=%H, wdata=%H; nzcv_n=%b", 
		   $time, uut.pc, uut.instruction, uut.reg_write, uut._register_file.write_addr, uut._register_file.write_data, uut._data_mem.mem_write, uut._data_mem.addr, uut._data_mem.write_data, uut.nzcv_n);
	end 
endmodule

