module HA(s, c, x, y);
input x, y;
output s, c;

xor (s, x, y);
and (c, x, y);
  
endmodule
