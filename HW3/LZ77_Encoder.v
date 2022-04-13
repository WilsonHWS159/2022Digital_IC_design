module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);

input 				clk;
input 				reset;
input  [7:0]	 	chardata;
output reg 			valid;
output reg 			encode;
output reg 			finish;
output reg [3:0]	offset;
output reg [2:0]	match_len;
output reg [7:0]	char_nxt;

	// 0~7 is look-ahead buffer, 8-16 is search buffer
	reg [7:0] buff[16:0];
	reg [2:0] hold;
	reg [16:0] buff_BM;
	wire [6:0] cmp_result[8:0];
	wire [2:0] cmp_len[8:0];
	wire [2:0] max_len;

	always @(posedge reset) begin
		encode <= 1'b1;
		finish <= 1'b0;
	end
	
	always @(posedge clk) begin
		if (char_nxt == 8'h24) begin
			finish <= 1'b1;
		end
	end
	
	// data stream
	integer i;
	always @(posedge clk) begin
		if (~reset) begin
			buff[0] <= chardata;
			buff_BM[0] <= 1'b1;
			for (i=0;i<16;i=i+1) begin
				buff[i+1] <= buff[i];
				buff_BM[i+1] <= buff_BM[i];
			end
		end else begin
			buff_BM <= 17'h00000;
		end
	end

	generate
		genvar j;
		for (j=0; j<9; j=j+1) begin: CMP
			cmp Cmp(.buff1({buff[16-j], buff[15-j], buff[14-j], buff[13-j], buff[12-j], buff[11-j], buff[10-j]}), .buff2({buff[7], buff[6], buff[5], buff[4], buff[3], buff[2], buff[1]}), .result(cmp_result[8-j]), .len(cmp_len[8-j]));
		end
	endgenerate
	
	
	wire [2:0] tmp[6:0];
	assign tmp[0] = buff_BM[9] ? ((cmp_len[0] > cmp_len[1]) ? cmp_len[0] : cmp_len[1]) : buff_BM[8] ? cmp_len[0] : 4'h0;
	assign tmp[1] = buff_BM[11] ? ((cmp_len[2] > cmp_len[3]) ? cmp_len[2] : cmp_len[3]) : buff_BM[10] ? cmp_len[2] : 4'h0;
	assign tmp[2] = buff_BM[13] ? ((cmp_len[4] > cmp_len[5]) ? cmp_len[4] : cmp_len[5]) : buff_BM[12] ? cmp_len[4] : 4'h0;
	assign tmp[3] = buff_BM[15] ? ((cmp_len[6] > cmp_len[7]) ? cmp_len[6] : cmp_len[7]) : buff_BM[14] ? cmp_len[6] : 4'h0;
	assign tmp[4] = (tmp[0] > tmp[1]) ? tmp[0] : tmp[1];
	assign tmp[5] = (tmp[2] > tmp[3]) ? tmp[2] : tmp[3];
	assign tmp[6] = (tmp[4] > tmp[5]) ? tmp[4] : tmp[5];
	assign max_len = buff_BM[16] ? ((tmp[6] > cmp_len[8]) ? tmp[6] : cmp_len[8]) : tmp[6];
	
	// output
	always @(*) begin
		if (buff_BM[8]) begin
			match_len = max_len;
			char_nxt = buff[7-match_len];
			if (!max_len)
				offset <= 4'h0;
			else if (cmp_len[8] == max_len)
				offset <= 4'h8;
			else if (cmp_len[7] == max_len)
				offset <= 4'h7;
			else if (cmp_len[6] == max_len)
				offset <= 4'h6;
			else if (cmp_len[5] == max_len)
				offset <= 4'h5;
			else if (cmp_len[4] == max_len)
				offset <= 4'h4;
			else if (cmp_len[3] == max_len)
				offset <= 4'h3;
			else if (cmp_len[2] == max_len)
				offset <= 4'h2;
			else if (cmp_len[1] == max_len)
				offset <= 4'h1;
		end else begin
			match_len = 3'h0;
			char_nxt = buff[7];
			offset = 4'h0;
		end
	end
	
	always @(negedge clk) begin
		if (buff_BM[7]) begin
			if (!hold) begin
				valid <= 1'b1;
				hold <= max_len;
			end else begin
				valid <= 1'b0;
				hold <= hold - 4'h1;
			end
		end else begin
			hold <= 4'h0;
			valid <= 1'b0;
		end
	end

endmodule

