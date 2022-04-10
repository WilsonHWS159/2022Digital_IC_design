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
reg [7:0] buff[16:0];
reg [3:0] hold;
reg [16:0] buff_BM;

always @(posedge reset) begin
	buff_BM <= 17'h00000;
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
	buff_BM[0] <= 1'b1;
	for (i=0; i<16; i=i+1) begin
		buff[i+1] <= buff[i];
		buff_BM[i+1] <= buff_BM[i];
	end
end

wire [7:0] cmp_result[8:0];
wire [4:0] cmp_len[8:0];
wire [4:0] max_len;

generate
	genvar j;
	for (j=0; j<9; j=j+1) begin: CMP
		cmp Cmp(.buff1({buff[16-j], buff[15-j], buff[14-j], buff[13-j], buff[12-j], buff[11-j], buff[10-j], buff[9-j]}), .buff2({buff[7], buff[6], buff[5], buff[4], buff[3], buff[2], buff[1], buff[0]}), .result(cmp_result[8-j]), .len(cmp_len[8-j]));
	end
endgenerate

find_max FM(.data_0(cmp_len[0]), .data_1(cmp_len[1]), .data_2(cmp_len[2]), .data_3(cmp_len[3]), .data_4(cmp_len[4]), .data_5(cmp_len[5]), .data_6(cmp_len[6]), .data_7(cmp_len[7]), .data_8(cmp_len[8]), .result(max_len));

always @(posedge clk) begin
	if (!hold & buff_BM[7]) begin
		valid <= 1'b1;
		hold <= max_len;
		if (!max_len) begin
			match_len <= max_len;
			char_nxt <= buff[7];
			offset <= 4'h0;
		end else if (buff_BM[16] & (cmp_len[8] == max_len)) begin
			match_len <= max_len;
			char_nxt <= buff[7-max_len];
			offset <= 4'h8;
		end else if (buff_BM[15] & (cmp_len[7] == max_len)) begin
			match_len <= max_len;
			char_nxt <= buff[7-max_len];
			offset <= 4'h7;
		end else if (buff_BM[14] & (cmp_len[6] == max_len)) begin
			match_len <= max_len;
			char_nxt <= buff[7-max_len];
			offset <= 4'h6;
		end else if (buff_BM[13] & (cmp_len[5] == max_len)) begin
			match_len <= max_len;
			char_nxt <= buff[7-max_len];
			offset <= 4'h5;
		end else if (buff_BM[12] & (cmp_len[4] == max_len)) begin
			match_len <= max_len;
			char_nxt <= buff[7-max_len];
			offset <= 4'h4;
		end else if (buff_BM[11] & (cmp_len[3] == max_len)) begin
			match_len <= max_len;
			char_nxt <= buff[7-max_len];
			offset <= 4'h3;
		end else if (buff_BM[10] & (cmp_len[2] == max_len)) begin
			match_len <= max_len;
			char_nxt <= buff[7-max_len];
			offset <= 4'h2;
		end else if (buff_BM[9] & (cmp_len[1] == max_len)) begin
			match_len <= max_len;
			char_nxt <= buff[7-max_len];
			offset <= 4'h1;
		end else begin
			match_len <= max_len;
			char_nxt <= buff[7-max_len];
			offset <= 4'h0;
		end
	end else if (~buff_BM[7]) begin
		valid <= 1'b0;
		offset <= 4'h0;
		match_len <= 3'h0;
		char_nxt <= 8'h00;
		hold <= hold;
	end else
		hold <= hold - 1;
end

endmodule

