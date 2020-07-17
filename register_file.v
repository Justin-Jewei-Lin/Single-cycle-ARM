module register_file(clk, rst, reg_write, link,
					read_addr_1, read_addr_2, read_addr_3, write_addr,
					write_data, pc_content,
					pc_write, read_data_1, read_data_2, read_data_3);
	
	input clk, rst, reg_write, link;
	input [3:0]read_addr_1, read_addr_2, read_addr_3, write_addr;
	input [31:0]write_data, pc_content;
	output pc_write;
	output [31:0]read_data_1, read_data_2, read_data_3;
	
	//reg pc_write;
	reg [31:0]memory[14:0];
	//reg [31:0]read_data_1, read_data_2, read_data_3;
	integer i;
	
	always@(posedge clk or posedge rst) begin
		if (rst) begin
			for (i = 0; i < 15; i = i + 1)
				memory[i] <= 0;
		end
		else begin
			if (reg_write & (write_addr < 4'b1110)) memory[write_addr] <= write_data; 
//			if (reg_write) memory[write_addr] <= write_data;
			else if (link) memory[14] <= pc_content;
		end
	end
	
//	assign pc_write = (write_addr == 15) & reg_write;
	
	assign pc_write = (&write_addr) & reg_write;
	assign read_data_1 = (&read_addr_1)? pc_content : memory[read_addr_1];
	assign read_data_2 = (&read_addr_2)? pc_content : memory[read_addr_2];
	assign read_data_3 = (&read_addr_3)? pc_content : memory[read_addr_3];
	
  	/*always@(*) begin
  		if ((write_addr == 15) & reg_write)
			pc_write <= 1;
  		else pc_write <= 0;
  	end
	
	always@(*) begin
		if (read_addr_1 == 15) read_data_1 <= pc_content;
		else read_data_1 <= memory[read_addr_1];
	end
	
	always@(*) begin
		if (read_addr_2 == 15) read_data_2 <= pc_content;
		else read_data_2 <= memory[read_addr_2];
	end
	
	always@(*) begin
		if (read_addr_3 == 15) read_data_3 <= pc_content;
		else read_data_3 <= memory[read_addr_3];
	end*/
endmodule
