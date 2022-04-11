module ALU_8bit(
	input Ainvert, Binvert,
	input [7:0] ALU_src1, [7:0] ALU_src2, [1:0] op,
	output zero, overflow,
	output [7:0] result);

wire [6:0] c_temp;
wire less, set;
assign zero = ~|result;
assign less = set ^ overflow;
generate
	genvar i;
	for(i=0;i<8;i=i+1) begin: alu
		if(i == 0) begin
			ALU_1bit ALU(.a(ALU_src1[i]), .b(ALU_src2[i]), .less(less), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(Binvert), .op(op), .result(result[i]), .c_out(c_temp[i]), .set(), .overflow());
		end else if(i == 7) begin
			ALU_1bit ALU(.a(ALU_src1[i]), .b(ALU_src2[i]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_temp[i-1]), .op(op), .result(result[i]), .c_out(), .set(set), .overflow(overflow));
		end else begin
			ALU_1bit ALU(.a(ALU_src1[i]), .b(ALU_src2[i]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_temp[i-1]), .op(op), .result(result[i]), .c_out(c_temp[i]), .set(), .overflow());
		end
	end
endgenerate

endmodule
