module LZ77(clk,reset,chardata,valid,encode,busy,offset,match_len,char_nxt);

input 				clk;
input 				reset;
output  			valid;
output  			encode;
output  			busy;
output  	[7:0] 	char_nxt;

inout		[3:0] 	offset;
inout		[2:0] 	match_len;
inout 		[7:0] 	chardata;

wire		[3:0]	o_offset;
wire		[2:0]	o_match_len;
wire		[7:0]	o_chardata;


LZ77_Encoder en(.clk(clk), .reset(), .valid(), .encode(), .finish(), .offset(o_offset), .match_len(o_match_len), .char_nxt(char_nxt));
LZ77_Decoder de(.clk(clk), .reset(), .code_pos(), .code_len(), .chardata,encode(), .finish(), .char_nxt());

endmodule
