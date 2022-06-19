module RCA(s, Carry_out, x, y, Carry_in);
input  [7:0] x, y;
output [7:0] s;
input  Carry_in;
output Carry_out;

wire [6:0] c_out;

FA FA_0(.s(s[0]), .Carry_out(c_out[0]), .x(x[0]), .y(y[0]), .Carry_in(Carry_in));
FA FA_1(.s(s[1]), .Carry_out(c_out[1]), .x(x[1]), .y(y[1]), .Carry_in(c_out[0]));
FA FA_2(.s(s[2]), .Carry_out(c_out[2]), .x(x[2]), .y(y[2]), .Carry_in(c_out[1]));
FA FA_3(.s(s[3]), .Carry_out(c_out[3]), .x(x[3]), .y(y[3]), .Carry_in(c_out[2]));
FA FA_4(.s(s[4]), .Carry_out(c_out[4]), .x(x[4]), .y(y[4]), .Carry_in(c_out[3]));
FA FA_5(.s(s[5]), .Carry_out(c_out[5]), .x(x[5]), .y(y[5]), .Carry_in(c_out[4]));
FA FA_6(.s(s[6]), .Carry_out(c_out[6]), .x(x[6]), .y(y[6]), .Carry_in(c_out[5]));
FA FA_7(.s(s[7]), .Carry_out(Carry_out), .x(x[7]), .y(y[7]), .Carry_in(c_out[6]));

endmodule
