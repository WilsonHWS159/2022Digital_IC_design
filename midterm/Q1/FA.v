module FA(s, Carry_out, x, y, Carry_in);
input x, y, Carry_in;
output s, Carry_out;
wire s1, c1, c2;

HA HA_1(.s(s1), .c(c1), .x(x), .y(y));
HA HA_2(.s(s), .c(c2), .x(Carry_in), .y(s1));
or (Carry_out, c1, c2);
  
endmodule

