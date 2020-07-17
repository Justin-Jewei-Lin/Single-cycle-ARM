iverilog -o tb1 alu.v controller.v data_mem.v ins_mem.v multi_4.v register_file.v rotate.v shift.v unsigned_extend.v ARM.v tb_ARM_1.v
iverilog -o tb2 alu.v controller.v data_mem.v ins_mem.v multi_4.v register_file.v rotate.v shift.v unsigned_extend.v ARM.v tb_ARM_2.v
iverilog -o tb3 alu.v controller.v data_mem.v ins_mem.v multi_4.v register_file.v rotate.v shift.v unsigned_extend.v ARM.v tb_ARM_3.v
iverilog -o tb4 alu.v controller.v data_mem.v ins_mem.v multi_4.v register_file.v rotate.v shift.v unsigned_extend.v ARM.v tb_ARM_4.v


vvp tb1 > log1.txt
vvp tb2 > log2.txt
vvp tb3 > log3.txt
vvp tb4 > log4.txt