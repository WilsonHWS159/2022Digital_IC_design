module ALU_1bit(result, c_out, set, overflow, a, b, less, Ainvert, Binvert, c_in, op);
input        a;
input        b;
input        less;
input        Ainvert;
input        Binvert;
input        c_in;
input  [1:0] op;
output       result;
output       c_out;
output       set;                 
output       overflow;      

reg          result;      
wire         a_out, b_out, s;

assign a_out = (Ainvert)? ~a : a;
assign b_out = (Binvert)? ~b : b;
assign overflow = (c_out ^ c_in)? 1 : 0;
assign set = s;

FA FA(.s(s), .c_out(c_out), .x(a_out), .y(b_out), .c_in(c_in));

always@(*) begin
    case(op)
	2'b00: result = a_out & b_out;
	2'b01: result = a_out | b_out;
	2'b10: result = s;
	2'b11: result = less;
	endcase
end

endmodule
