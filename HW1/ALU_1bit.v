module ALU_1bit(
	input a, b, less, Ainvert, Binvert, c_in,
	input [1:0] op,
	output reg result, c_out, set, overflow);

reg a1, b1;
wire adder, out;
FA FA_1(.s(adder), .carry_out(out), .x(a1), .y(b1), .carry_in(c_in));
	always @(*) begin
		a1 = (Ainvert) ? ~a : a;
		b1 = (Binvert) ? ~b : b;
		set = adder;
		c_out = out;
		overflow = c_in ^ out;
		case (op)
				2'b00:result = a1 & b1;
				2'b01:result = a1 | b1; 
				2'b10:result = adder;
				2'b11:result = less;
		endcase
	end

endmodule