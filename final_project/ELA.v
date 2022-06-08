`timescale 1ns/10ps

module ELA(clk, rst, ready, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input				ready;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output 				req;
	output 				wen;
	output 		[12:0]	addr;
	output 		[7:0]	data_wr;
	output 				done;


	/*-------------------------------------/
	/		Write your code here~		   /
	/-------------------------------------*/
	

endmodule