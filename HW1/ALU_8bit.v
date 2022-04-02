module ALU_8bit(
	input Ainvert, Binvert,
	input [7:0] ALU_src1, [7:0] ALU_src2, [1:0] op,
	output zero, overflow,
	output [7:0] result);

wire [7:0] keep_result;
wire [6:0] c_temp;
wire less_temp, overflow_temp, set_temp;
assign zero = ~|(keep_result);
assign result = keep_result;
assign overflow = overflow_temp;
assign less_temp = set_temp ^ overflow_temp;
generate
	genvar i;
	for(i=0;i<8;i=i+1) begin: alu
		if(i == 0) begin
			ALU_1bit ALU(.a(ALU_src1[i]), .b(ALU_src2[i]), .less(less_temp), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(Binvert), .op(op), .result(keep_result[i]), .c_out(c_temp[i]), .set(), .overflow());
		end else if(i == 7) begin
			ALU_1bit ALU(.a(ALU_src1[i]), .b(ALU_src2[i]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_temp[i-1]), .op(op), .result(keep_result[i]), .c_out(), .set(set_temp), .overflow(overflow_temp));
		end else begin
			ALU_1bit ALU(.a(ALU_src1[i]), .b(ALU_src2[i]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_temp[i-1]), .op(op), .result(keep_result[i]), .c_out(c_temp[i]), .set(), .overflow());
		end
	end
endgenerate

endmodule
