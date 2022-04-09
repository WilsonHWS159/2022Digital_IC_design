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

reg [7:0] cmp_result[8:0];
reg [7:0] v_result;

generate
	genvar j;
	for (j=0; j<9; j=j+1) begin: CMP
		cmp Cmp(.buff1({buff[16-j], buff[15-j], buff[14-j], buff[13-j], buff[12-j], buff[11-j], buff[10-j], buff[9-j]}), .buff2({buff[7], buff[6], buff[5], buff[4], buff[3], buff[2], buff[1], buff[0]}), .result(cmp_result[8-j]));
	end
endgenerate
/*
always @(posedge clk) begin
	if (!hold & buff_BM[7]) begin
		hold <= hold;
		valid <= 1'b1;
		if (buff_BM[16] & ) begin
			offset <= 4'h8;
			v_result <= cmp_result[8];
		end else if (buff_BM[15] & ) begin
			offset <= 4'h7;
			v_result <= cmp_result[7];
		end else if (buff_BM[14] & ) begin
			offset <= 4'h6;
			v_result <= cmp_result[6];
		end else if (buff_BM[13] & ) begin
			offset <= 4'h5;
			v_result <= cmp_result[5];
		end else if (buff_BM[12] & ) begin
			offset <= 4'h4;
			v_result <= cmp_result[4];
		end else if (buff_BM[11] & ) begin
			offset <= 4'h3;
			v_result <= cmp_result[3];
		end else if (buff_BM[10] & ) begin
			offset <= 4'h2;
			v_result <= cmp_result[2];
		end else if (buff_BM[9] & ) begin
			offset <= 4'h1;
			v_result <= cmp_result[1];
		end else if (buff_BM[8] & ) begin
			offset <= 4'h0;
			v_result <= cmp_result[0];
		end else begin
			offset <= 4'h0;
			v_result <= 8'hFF;
		end
	end else if (~buff_BM[7]) begin
		valid <= 1'b0;
		offset <= 4'h0;
		match_len <= 3'h0;
		char_nxt <= 8'h00;
	end else
		hold <= hold - 1;
end
*/
endmodule

