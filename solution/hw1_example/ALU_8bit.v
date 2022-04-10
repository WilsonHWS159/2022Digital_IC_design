module ALU_8bit(result, zero, overflow, ALU_src1, ALU_src2, Ainvert, Binvert, op);
input  [7:0] ALU_src1;
input  [7:0] ALU_src2;
input        Ainvert;
input        Binvert;
input  [1:0] op;
output [7:0] result;
output       zero;
output       overflow;

wire         c_out0, c_out1, c_out2, c_out3, c_out4, c_out5, c_out6, c_out7;
wire         set0, set1, set2, set3, set4, set5, set6, set7, Set;
wire         overflow0, overflow1, overflow2, overflow3, overflow4, overflow5, overflow6;

assign zero = ~| result;
assign Set = (overflow)? ~set7 : set7;

ALU_1bit ALU_1bit_0(.result(result[0]), .c_out(c_out0), .set(set0), .overflow(overflow0), .a(ALU_src1[0]), .b(ALU_src2[0]), .less(Set),  .Ainvert(Ainvert), .Binvert(Binvert), .c_in(Binvert),.op(op));
ALU_1bit ALU_1bit_1(.result(result[1]), .c_out(c_out1), .set(set1), .overflow(overflow1), .a(ALU_src1[1]), .b(ALU_src2[1]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out0), .op(op));
ALU_1bit ALU_1bit_2(.result(result[2]), .c_out(c_out2), .set(set2), .overflow(overflow2), .a(ALU_src1[2]), .b(ALU_src2[2]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out1), .op(op));
ALU_1bit ALU_1bit_3(.result(result[3]), .c_out(c_out3), .set(set3), .overflow(overflow3), .a(ALU_src1[3]), .b(ALU_src2[3]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out2), .op(op));
ALU_1bit ALU_1bit_4(.result(result[4]), .c_out(c_out4), .set(set4), .overflow(overflow4), .a(ALU_src1[4]), .b(ALU_src2[4]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out3), .op(op));
ALU_1bit ALU_1bit_5(.result(result[5]), .c_out(c_out5), .set(set5), .overflow(overflow5), .a(ALU_src1[5]), .b(ALU_src2[5]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out4), .op(op));
ALU_1bit ALU_1bit_6(.result(result[6]), .c_out(c_out6), .set(set6), .overflow(overflow6), .a(ALU_src1[6]), .b(ALU_src2[6]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out5), .op(op));
ALU_1bit ALU_1bit_7(.result(result[7]), .c_out(c_out7), .set(set7), .overflow(overflow),  .a(ALU_src1[7]), .b(ALU_src2[7]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out6), .op(op));


endmodule
