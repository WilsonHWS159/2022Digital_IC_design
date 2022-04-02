`timescale 10ns / 1ps
`define CYCLE 10
`define PATTERN_1bit    "./test_data_1bit_ALU.dat"         
`define EXPECT_1bit   "./golden_data_1bit_ALU.dat" 
`define PATTERN_8bit    "./test_data_8bit_ALU.dat"         
`define EXPECT_8bit   "./golden_data_8bit_ALU.dat"    

module ALU_tb;

parameter              TEST_N_PAT_8bit = 458752;
parameter              TEST_L_PAT_8bit = 20;
parameter              GOLDEN_L_PAT_8bit = 10;

parameter              TEST_N_PAT_1bit = 32;
parameter              TEST_L_PAT_1bit = 8;
parameter              GOLDEN_L_PAT_1bit = 4;

reg   [TEST_L_PAT_8bit-1:0] data_mem_8bit [0:TEST_N_PAT_8bit-1];
reg [GOLDEN_L_PAT_8bit-1:0] out_mem_8bit [0:TEST_N_PAT_8bit-1];

reg   [TEST_L_PAT_1bit-1:0] data_mem_1bit [0:TEST_N_PAT_1bit-1];
reg [GOLDEN_L_PAT_1bit-1:0] out_mem_1bit [0:TEST_N_PAT_1bit-1];

// 8 bit ALU input
reg              [3:0] opcode_8bit;
reg signed       [7:0] data_in1_8bit, data_in2_8bit;

// 8 bit ALU output golden
reg              [7:0] result_g_8bit;
reg                    zero_g_8bit;
reg                    overflow_g_8bit;

// 8 bit ALU output
wire             [7:0] result_out_8bit;
wire                   zero_8bit;
wire                   overflow_8bit;

// 1 bit ALU input
reg              [3:0] opcode_1bit;
reg signed             data_in1_1bit, data_in2_1bit;
reg                    less_in_1bit;
reg                    c_in_1bit;

// 1 bit ALU output golden
reg                    result_g_1bit;
reg                    c_out_g_1bit;
reg                    overflow_g_1bit;
reg                    set_out_g_1bit;

// 1 bit ALU output
wire                   result_out_1bit;
wire                   c_out_1bit;
wire                   overflow_1bit;
wire                   set_out_1bit;

integer                pattern_num;
integer                i,j,z;
integer                err;
integer                total_err_1;
integer                total_err_2;
integer                total_err_3;

initial	$readmemb (`PATTERN_8bit, data_mem_8bit);
initial	$readmemb (`EXPECT_8bit, out_mem_8bit);
initial	$readmemb (`PATTERN_1bit, data_mem_1bit);
initial	$readmemb (`EXPECT_1bit, out_mem_1bit);

initial begin
   pattern_num = 0;  
   err = 0;
   total_err_1 = 0;
   total_err_2 = 0;
   total_err_3 = 0;
end

ALU_1bit ALU_1bit(.result(result_out_1bit), .c_out(c_out_1bit), .set(set_out_1bit), .overflow(overflow_1bit), .a(data_in1_1bit), .b(data_in2_1bit), .less(less_in_1bit), .Ainvert(opcode_1bit[3]), .Binvert(opcode_1bit[2]), .c_in(c_in_1bit), .op(opcode_1bit[1:0]));
ALU_8bit ALU_8bit(.result(result_out_8bit), .zero(zero_8bit), .overflow(overflow_8bit), .ALU_src1(data_in1_8bit), .ALU_src2(data_in2_8bit), .Ainvert(opcode_8bit[3]), .Binvert(opcode_8bit[2]), .op(opcode_8bit[1:0]));

initial begin
    $display("-------------Stage 1 : 1-bit ALU Simulation-------------\n");
	$display("--And Operation--\n");
	for(i=0;i<2;i=i+1) begin
		for(j=0;j<2;j=j+1) begin
			#`CYCLE opcode_1bit = data_mem_1bit[pattern_num][7:4];c_in_1bit = data_mem_1bit[pattern_num][3];data_in1_1bit = data_mem_1bit[pattern_num][2];data_in2_1bit = data_mem_1bit[pattern_num][1];less_in_1bit = data_mem_1bit[pattern_num][0];
			#`CYCLE result_g_1bit = out_mem_1bit[pattern_num][3];c_out_g_1bit = out_mem_1bit[pattern_num][2];overflow_g_1bit = out_mem_1bit[pattern_num][1];set_out_g_1bit = out_mem_1bit[pattern_num][0];
			// $display("%b,%b \n", data_in1_1bit, data_in2_1bit);
			// $display("%b,%b,%b,%b \n", result_g_1bit, c_out_g_1bit, overflow_g_1bit, set_out_g);
			pattern_num = pattern_num + 1;
  
			if(result_out_1bit == result_g_1bit) begin
			    // err = err + 1;
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %2d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_1 = total_err_1 + err;
	err = 0;
	
	$display("--Or Operation--\n");
	for(i=0;i<2;i=i+1) begin
		for(j=0;j<2;j=j+1) begin
			#`CYCLE opcode_1bit = data_mem_1bit[pattern_num][7:4];c_in_1bit = data_mem_1bit[pattern_num][3];data_in1_1bit = data_mem_1bit[pattern_num][2];data_in2_1bit = data_mem_1bit[pattern_num][1];less_in_1bit = data_mem_1bit[pattern_num][0];
			#`CYCLE result_g_1bit = out_mem_1bit[pattern_num][3];c_out_g_1bit = out_mem_1bit[pattern_num][2];overflow_g_1bit = out_mem_1bit[pattern_num][1];set_out_g_1bit = out_mem_1bit[pattern_num][0];
			// $display("%b,%b \n", data_in1_1bit, data_in2_1bit);
			// $display("%b,%b,%b,%b \n", result_g_1bit, c_out_g_1bit, overflow_g_1bit, set_out_g);
			pattern_num = pattern_num + 1;
  
			if(result_out_1bit == result_g_1bit) begin
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %2d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_1 = total_err_1 + err;
	err = 0;
	
	$display("--Nand Operation--\n");
	for(i=0;i<2;i=i+1) begin
		for(j=0;j<2;j=j+1) begin
			#`CYCLE opcode_1bit = data_mem_1bit[pattern_num][7:4];c_in_1bit = data_mem_1bit[pattern_num][3];data_in1_1bit = data_mem_1bit[pattern_num][2];data_in2_1bit = data_mem_1bit[pattern_num][1];less_in_1bit = data_mem_1bit[pattern_num][0];
			#`CYCLE result_g_1bit = out_mem_1bit[pattern_num][3];c_out_g_1bit = out_mem_1bit[pattern_num][2];overflow_g_1bit = out_mem_1bit[pattern_num][1];set_out_g_1bit = out_mem_1bit[pattern_num][0];
			// $display("%b,%b \n", data_in1_1bit, data_in2_1bit);
			// $display("%b,%b,%b,%b \n", result_g_1bit, c_out_g_1bit, overflow_g_1bit, set_out_g);
			pattern_num = pattern_num + 1;
  
			if(result_out_1bit == result_g_1bit) begin
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %2d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_1 = total_err_1 + err;
	err = 0;
	
	$display("--Nor Operation--\n");
	for(i=0;i<2;i=i+1) begin
		for(j=0;j<2;j=j+1) begin
			#`CYCLE opcode_1bit = data_mem_1bit[pattern_num][7:4];c_in_1bit = data_mem_1bit[pattern_num][3];data_in1_1bit = data_mem_1bit[pattern_num][2];data_in2_1bit = data_mem_1bit[pattern_num][1];less_in_1bit = data_mem_1bit[pattern_num][0];
			#`CYCLE result_g_1bit = out_mem_1bit[pattern_num][3];c_out_g_1bit = out_mem_1bit[pattern_num][2];overflow_g_1bit = out_mem_1bit[pattern_num][1];set_out_g_1bit = out_mem_1bit[pattern_num][0];
			// $display("%b,%b \n", data_in1_1bit, data_in2_1bit);
			// $display("%b,%b,%b,%b \n", result_g_1bit, c_out_g_1bit, overflow_g_1bit, set_out_g);
			pattern_num = pattern_num + 1;
  
			if(result_out_1bit == result_g_1bit) begin
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %2d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_1 = total_err_1 + err;
	err = 0;
	
	$display("--Add Operation--\n");
	for(i=0;i<2;i=i+1) begin
		for(j=0;j<2;j=j+1) begin
			#`CYCLE opcode_1bit = data_mem_1bit[pattern_num][7:4];c_in_1bit = data_mem_1bit[pattern_num][3];data_in1_1bit = data_mem_1bit[pattern_num][2];data_in2_1bit = data_mem_1bit[pattern_num][1];less_in_1bit = data_mem_1bit[pattern_num][0];
			#`CYCLE result_g_1bit = out_mem_1bit[pattern_num][3];c_out_g_1bit = out_mem_1bit[pattern_num][2];overflow_g_1bit = out_mem_1bit[pattern_num][1];set_out_g_1bit = out_mem_1bit[pattern_num][0];
			// $display("%b,%b \n", data_in1_1bit, data_in2_1bit);
			// $display("%b,%b,%b,%b \n", result_g_1bit, c_out_g_1bit, overflow_g_1bit, set_out_g_1bit);
			// $display("%b,%b,%b,%b \n", result_out_1bit, c_out_1bit, overflow_1bit, set_out_1bit);
			pattern_num = pattern_num + 1;
  
			if((result_out_1bit == result_g_1bit) && (c_out_1bit == c_out_g_1bit) && (overflow_1bit == overflow_g_1bit)) begin
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %2d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_1 = total_err_1 + err;
	err = 0;
	
	$display("--Sub Operation--\n");
	for(i=0;i<2;i=i+1) begin
		for(j=0;j<2;j=j+1) begin
			#`CYCLE opcode_1bit = data_mem_1bit[pattern_num][7:4];c_in_1bit = data_mem_1bit[pattern_num][3];data_in1_1bit = data_mem_1bit[pattern_num][2];data_in2_1bit = data_mem_1bit[pattern_num][1];less_in_1bit = data_mem_1bit[pattern_num][0];
			#`CYCLE result_g_1bit = out_mem_1bit[pattern_num][3];c_out_g_1bit = out_mem_1bit[pattern_num][2];overflow_g_1bit = out_mem_1bit[pattern_num][1];set_out_g_1bit = out_mem_1bit[pattern_num][0];
			// $display("%b,%b \n", data_in1_1bit, data_in2_1bit);
			// $display("%b,%b,%b,%b \n", result_g_1bit, c_out_g_1bit, overflow_g_1bit, set_out_g_1bit);
			// $display("%b,%b,%b,%b \n", result_out_1bit, c_out_1bit, overflow_1bit, set_out_1bit);
			pattern_num = pattern_num + 1;
  
			if((result_out_1bit == result_g_1bit) && (c_out_1bit == c_out_g_1bit) && (overflow_1bit == overflow_g_1bit)) begin
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %2d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_1 = total_err_1 + err;
	err = 0;
	
	$display("--Slt Operation--\n");
	for(i=0;i<2;i=i+1) begin
		for(j=0;j<2;j=j+1) begin
		    for(z=0;z<2;z=z+1) begin
				#`CYCLE opcode_1bit = data_mem_1bit[pattern_num][7:4];c_in_1bit = data_mem_1bit[pattern_num][3];data_in1_1bit = data_mem_1bit[pattern_num][2];data_in2_1bit = data_mem_1bit[pattern_num][1];less_in_1bit = data_mem_1bit[pattern_num][0];
				#`CYCLE result_g_1bit = out_mem_1bit[pattern_num][3];c_out_g_1bit = out_mem_1bit[pattern_num][2];overflow_g_1bit = out_mem_1bit[pattern_num][1];set_out_g_1bit = out_mem_1bit[pattern_num][0];
				// $display("%b,%b,%b \n", data_in1_1bit, data_in2_1bit, less_in_1bit);
				// $display("%b,%b,%b,%b \n", result_g_1bit, c_out_g_1bit, overflow_g_1bit, set_out_g_1bit);
				// $display("%b,%b,%b,%b \n", result_out_1bit, c_out_1bit, overflow_1bit, set_out_1bit);
				pattern_num = pattern_num + 1;
	  
				if((result_out_1bit == result_g_1bit) && (c_out_1bit == c_out_g_1bit) && (overflow_1bit == overflow_g_1bit) && (set_out_1bit == set_out_g_1bit)) begin
				end
				else begin
					err = err + 1;
				end
			end
		end
	end
	if(err != 0) begin
		$display("There are %2d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_1 = total_err_1 + err;
    
	err = 0;
	pattern_num = 0;
	
	//================================================================================================
	
	$display("-------------Stage 2 : 8-bit ALU bitwise operation Simulation-------------\n");
	$display("--And Operation--\n");
	for(i=0;i<256;i=i+1) begin
		for(j=0;j<256;j=j+1) begin
			#`CYCLE opcode_8bit = data_mem_8bit[pattern_num][19:16];data_in1_8bit = data_mem_8bit[pattern_num][15:8];data_in2_8bit = data_mem_8bit[pattern_num][7:0];
			#`CYCLE result_g_8bit = out_mem_8bit[pattern_num][9:2];zero_g_8bit = out_mem_8bit[pattern_num][1];overflow_g_8bit = out_mem_8bit[pattern_num][0];

			pattern_num = pattern_num + 1;
  
			if((result_out_8bit == result_g_8bit) && (zero_8bit == zero_g_8bit)) begin
			    // err = err + 1;
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %5d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_2 = total_err_2 + err;
	err = 0;
	
	$display("--Or Operation--\n");
	for(i=0;i<256;i=i+1) begin
		for(j=0;j<256;j=j+1) begin
			#`CYCLE opcode_8bit = data_mem_8bit[pattern_num][19:16];data_in1_8bit = data_mem_8bit[pattern_num][15:8];data_in2_8bit = data_mem_8bit[pattern_num][7:0];
			#`CYCLE result_g_8bit = out_mem_8bit[pattern_num][9:2];zero_g_8bit = out_mem_8bit[pattern_num][1];overflow_g_8bit = out_mem_8bit[pattern_num][0];
			
			pattern_num = pattern_num + 1;
  
			if((result_out_8bit == result_g_8bit) && (zero_8bit == zero_g_8bit)) begin
			    // err = err + 1;
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %5d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_2 = total_err_2 + err;
	err = 0;
	
	$display("--Nand Operation--\n");
	for(i=0;i<256;i=i+1) begin
		for(j=0;j<256;j=j+1) begin
			#`CYCLE opcode_8bit = data_mem_8bit[pattern_num][19:16];data_in1_8bit = data_mem_8bit[pattern_num][15:8];data_in2_8bit = data_mem_8bit[pattern_num][7:0];
			#`CYCLE result_g_8bit = out_mem_8bit[pattern_num][9:2];zero_g_8bit = out_mem_8bit[pattern_num][1];overflow_g_8bit = out_mem_8bit[pattern_num][0];
			
			pattern_num = pattern_num + 1;
  
			if((result_out_8bit == result_g_8bit) && (zero_8bit == zero_g_8bit)) begin
			    // err = err + 1;
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %5d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_2 = total_err_2 + err;
	err = 0;
	
	$display("--Nor Operation--\n");
	for(i=0;i<256;i=i+1) begin
		for(j=0;j<256;j=j+1) begin
			#`CYCLE opcode_8bit = data_mem_8bit[pattern_num][19:16];data_in1_8bit = data_mem_8bit[pattern_num][15:8];data_in2_8bit = data_mem_8bit[pattern_num][7:0];
			#`CYCLE result_g_8bit = out_mem_8bit[pattern_num][9:2];zero_g_8bit = out_mem_8bit[pattern_num][1];overflow_g_8bit = out_mem_8bit[pattern_num][0];
	
			pattern_num = pattern_num + 1;
  
			if((result_out_8bit == result_g_8bit) && (zero_8bit == zero_g_8bit)) begin
			    // err = err + 1;
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %5d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_2 = total_err_2 + err;
	err = 0;
	
	//================================================================================================
	$display("-------------Stage 3 : 8-bit ALU arithmetic operation Simulation-------------\n");
	$display("--Add Operation--\n");
	for(i=0;i<256;i=i+1) begin
		for(j=0;j<256;j=j+1) begin
			#`CYCLE opcode_8bit = data_mem_8bit[pattern_num][19:16];data_in1_8bit = data_mem_8bit[pattern_num][15:8];data_in2_8bit = data_mem_8bit[pattern_num][7:0];
			#`CYCLE result_g_8bit = out_mem_8bit[pattern_num][9:2];zero_g_8bit = out_mem_8bit[pattern_num][1];overflow_g_8bit = out_mem_8bit[pattern_num][0];
			
			pattern_num = pattern_num + 1;
  
			if((result_out_8bit == result_g_8bit) && (zero_8bit == zero_g_8bit) && (overflow_8bit == overflow_g_8bit)) begin
			    // err = err + 1;
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %5d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_3 = total_err_3 + err;
	err = 0;
	
	$display("--Sub Operation--\n");
	for(i=0;i<256;i=i+1) begin
		for(j=0;j<256;j=j+1) begin
			#`CYCLE opcode_8bit = data_mem_8bit[pattern_num][19:16];data_in1_8bit = data_mem_8bit[pattern_num][15:8];data_in2_8bit = data_mem_8bit[pattern_num][7:0];
			#`CYCLE result_g_8bit = out_mem_8bit[pattern_num][9:2];zero_g_8bit = out_mem_8bit[pattern_num][1];overflow_g_8bit = out_mem_8bit[pattern_num][0];
			
			pattern_num = pattern_num + 1;
  
			if((result_out_8bit == result_g_8bit) && (zero_8bit == zero_g_8bit) && (overflow_8bit == overflow_g_8bit)) begin
			    // err = err + 1;
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %5d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_3 = total_err_3 + err;
	err = 0;
	
	$display("--Slt Operation--\n");
	for(i=0;i<256;i=i+1) begin
		for(j=0;j<256;j=j+1) begin
			#`CYCLE opcode_8bit = data_mem_8bit[pattern_num][19:16];data_in1_8bit = data_mem_8bit[pattern_num][15:8];data_in2_8bit = data_mem_8bit[pattern_num][7:0];
			#`CYCLE result_g_8bit = out_mem_8bit[pattern_num][9:2];zero_g_8bit = out_mem_8bit[pattern_num][1];overflow_g_8bit = out_mem_8bit[pattern_num][0];
			
			pattern_num = pattern_num + 1;
  
			if((result_out_8bit == result_g_8bit) && (zero_8bit == zero_g_8bit) && (overflow_8bit == overflow_g_8bit)) begin
			    // err = err + 1;
			end
			else begin
			    err = err + 1;
		    end
		end
	end
	if(err != 0) begin
		$display("There are %5d errors!\n", err);
	end
	else begin
		$display("Pass!\n");
	end
	total_err_3 = total_err_3 + err;
	err = 0;
	
    if(total_err_1 != 0) begin
	    $display("-------------There are %2d errors in stage 1!-------------\n", total_err_1);
	end
	else begin
	    $display("-------------Stage 1 : Pass!-------------\n");
	end
	if(total_err_2 != 0) begin
	    $display("-------------There are %2d errors in stage 2!-------------\n", total_err_2);
	end
	else begin
	    $display("-------------Stage 2 : Pass!-------------\n");
	end
	if(total_err_3 != 0) begin
	    $display("-------------There are %2d errors in stage 3!-------------\n", total_err_3);
	end
	else begin
	    $display("-------------Stage 3 : Pass!-------------\n");
	end
	
	#10 $finish;
end

endmodule
