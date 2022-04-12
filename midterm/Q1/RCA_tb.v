`timescale 10ns / 1ps
`define CYCLE 1.4

module RCA_tb;
reg  [7:0] x, y;
wire [7:0] s;
reg  c_in;
wire c_out;

reg [7:0] result;
reg c;
integer num = 0;
integer i, j;
integer err = 0;
integer ans;

RCA RCA(.s(s), .Carry_out(c_out), .x(x), .y(y), .Carry_in(c_in));

initial begin
  for(i=0;i<512;i=i+1)
    for(j=0;j<256;j=j+1)
    begin
      #`CYCLE x = i[7:0]; y = j; c_in = i[8];
      
      #`CYCLE {c, result} = i[7:0] + j + i[8];
      
      if((c == c_out) && (result == s))
        $display("%d data is correct", num);
      else begin
        $display("%d data is error !! your data is %b, correct data is %b", num, {c_out, s}, {c, result});
        err = err + 1;
      end
      num = num + 1;
    end
  
  
  if(err == 0) begin
    $display("-------------------PASS-------------------");
    $display("All data have been generated successfully!");    
  end else begin
    $display("-------------------ERROR-------------------");
    $display("There are %d errors!", err);
  end
    
  #10 $finish;
  
end
endmodule
