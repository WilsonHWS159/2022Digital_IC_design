module ALU_1bit(
	input a, b, less, Ainvert, Binvert, c_in,
	input [1:0] op,
	output c_out, set, overflow,
	output reg result);

wire adder, out, a1, b1;

assign a1 = (Ainvert) ? ~a : a;
assign b1 = (Binvert) ? ~b : b;
assign overflow = c_in ^ c_out;

FA FA_1(.s(set), .carry_out(c_out), .x(a1), .y(b1), .carry_in(c_in));
	always @(*) begin
		case (op)
				2'b00:result = a1 & b1;
				2'b01:result = a1 | b1; 
				2'b10:result = set;
				2'b11:result = less;
		endcase
	end

endmodule