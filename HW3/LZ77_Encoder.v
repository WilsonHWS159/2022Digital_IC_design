module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);


input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output reg 			valid;
output reg 			encode;
output reg 			finish;
output reg	[3:0] 	offset;
output reg	[2:0] 	match_len;
output reg 	[7:0] 	char_nxt;

// 0~7 is look-ahead buffer, 8-16 is search buffer
reg [16:0] buff[7:0];
reg [3:0] slide_cnt, s_cnt, l_cnt, hold;
reg [8:0] cmp[7:0];
wire l_full, s_full;

always @(posedge reset) begin
	s_cnt <= 0;
	l_cnt <= 0;
	slide_cnt <= 0;
	
	valid <= 1'b0;
	encode <= 1'b1;
	finish <= 1'b0;
	offset <= 4'h0;
	match_len <= 3'h0;
	char_nxt <= 8'h00;
end

// data stream
integer i;
always @(posedge clk) begin
	buff[0] <= chardata;
	for(i=0; i<16; i=i+1)
		buff[i+1] <= buff[i];
end

assign l_full = l_cnt == 4'h8;
assign s_full = s_cnt == 4'h9;

always @(posedge clk) begin
	if (l_full) begin
		l_cnt <= l_cnt;
		if (s_full)
			s_cnt <= s_cnt;
		else
			s_cnt <= s_cnt + 1;
	end else
		l_cnt <= l_cnt + 1;
end

always @(posedge clk) begin
	if (l_full & !hold) begin
	end else begin
	end
end

endmodule

