module controller(nzcv, opfunc, reg_write, alu_src, alu_op, mem_to_reg, mem_write, pc_src, update_nzcv, link);
	input [3:0]nzcv;
	input [11:0]opfunc;
	output reg reg_write, mem_to_reg, mem_write, pc_src, update_nzcv, link;
	output reg [1:0]alu_src;
	output reg [3:0]alu_op;

	assign {n, z, c, v} = nzcv[3:0];
    wire condition =
      ((opfunc[11:8] == 4'b0000) &  z) |				// EQ, Z=1
      ((opfunc[11:8] == 4'b0001) & ~z) |				// NE, Z=0
      ((opfunc[11:8] == 4'b0010) &  c) |				// CS, C=1
      ((opfunc[11:8] == 4'b0011) & ~c) |				// CC, C=0
      ((opfunc[11:8] == 4'b0100) &  n) |				// MI, N=1
      ((opfunc[11:8] == 4'b0101) & ~n) |				// PL, N=0
      ((opfunc[11:8] == 4'b0110) &  v) |				// VS, V=1
      ((opfunc[11:8] == 4'b0111) & ~v) |				// VC, V=0 
      ((opfunc[11:8] == 4'b1000) & (c & ~z)) |			// HI, C=1 & Z=0
      ((opfunc[11:8] == 4'b1001) & (~c | z)) |			// LS, C=0 | Z=1
      ((opfunc[11:8] == 4'b1010) & (n ~^ v)) |			// GE, N = V
      ((opfunc[11:8] == 4'b1011) & (n ^  v)) |			// LT, N ≠V
      ((opfunc[11:8] == 4'b1100) & (~z & (n ~^ v))) |	// GT, Z=0 & N = V
      ((opfunc[11:8] == 4'b1101) & ( z | (n ^  v))) |	// LE, Z=1 | N ≠V
       (opfunc[11:8] == 4'b1110);			// AL, always (nzcv ignored)
	
	always@(*) begin
		casex({condition, opfunc[7:5]})
			4'b1101: begin // branch
				reg_write = 1'b0;
				alu_src = 2'b00;
				alu_op = 4'b0000;
				mem_to_reg = 1'b0;
				mem_write = 1'b0;
				pc_src = 1'b1;
				update_nzcv = 1'b0;
				link = opfunc[4];
			end
			4'b100x: begin // data processing
				reg_write = (opfunc[4:3] == 2'b10)? 1'b0 : 1'b1;
				alu_src = (opfunc[5])? 2'b01 : 2'b00;
				alu_op = opfunc[4:1];
				mem_to_reg = 1'b0;
				mem_write = 1'b0;
				pc_src = 1'b0;
				update_nzcv = opfunc[0];
				link = 1'b0;
			end
			4'b101x: begin // data transfer
				reg_write = opfunc[0];
				alu_src = (opfunc[5])? 2'b10 : 2'b11;
				alu_op = (opfunc[3])? 4'b0100 : 4'b0010;
				mem_to_reg = 1'b1;
				mem_write = ~opfunc[0];
				pc_src = 1'b0;
				update_nzcv = 1'b0;
				link = 1'b0;
			end
			default: begin // fail
				reg_write = 1'b0;
				alu_src = 2'b00;
				alu_op = 4'b0000;
				mem_to_reg = 1'b0;
				mem_write = 1'b0;
				pc_src = 1'b0;
				update_nzcv = 1'b0;
				link = 1'b0;
			end
		endcase
	end
endmodule


// branch 101
// data processing 00x
// data transfer 01x