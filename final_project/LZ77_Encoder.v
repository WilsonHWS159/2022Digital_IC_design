module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);

input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output	reg 		valid;
output  reg			encode;
output  reg			finish;
output  reg	[4:0] 	offset;
output  reg	[4:0] 	match_len;
output  reg	[7:0] 	char_nxt;

	reg out_complete;
	reg [7:0] tmp_char[8192:0];
	reg [13:0] id, id2;
	// 0~24 is look-ahead buffer, 25~54 is search buffer
	reg [7:0] buff[54:0];
	reg [4:0] hold;
	reg [54:0] buff_BM;
	wire [23:0] cmp_result[29:0];
	wire [4:0] cmp_len[29:0];
	wire [4:0] max_len;
	
	// FSM
	parameter [1:0] recieving_data = 2'b00, encoding = 2'b01, done = 2'b11;
	reg [1:0] state, n_state;
	always @(*) begin
		if (reset) begin
			n_state = recieving_data;
			encode = 1'b1;
			finish = 1'b0;
		end else begin
			case (state)
				default : n_state = recieving_data;
				recieving_data : begin
					finish = 1'b0;
					if (id == 14'h2000)
						n_state = encoding;
					else
						n_state = recieving_data;
				end
				encoding : begin
					finish = 1'b0;
					if (out_complete)
						n_state = done;
					else
						n_state = encoding;
				end
				done : begin
					n_state = done;
					encode = 1'b0;
					finish = 1'b1;
				end
			endcase
		end
	end
	
	integer i;
	always @(posedge clk) begin
		state <= n_state;
		if (reset) begin
			id <= 13'h0000;
			id2 <= 13'h0000;
			buff_BM <= 54'h00000000000000;
		end else begin
			case (state)
				recieving_data : begin
					tmp_char[id] <= chardata;
					id <= id + 14'h001;
				end
				encoding : begin
					buff[0] <= tmp_char[id2];
					buff_BM[0] <= 1'b1;
					if (id2 == 14'h2000)
						id2 <= id2;
					else
						id2 <= id2 + 14'h001;
					for (i=0;i<54;i=i+1) begin
						buff[i+1] <= buff[i];
						buff_BM[i+1] <= buff_BM[i];
					end
				end
				endcase
		end
	end

	generate
		genvar j;
		for (j=0; j<30; j=j+1) begin: CMP
			cmp Cmp(
				.buff1({
					buff[54-j], buff[53-j], buff[52-j], buff[51-j], buff[50-j], buff[49-j],
					buff[48-j], buff[47-j], buff[46-j], buff[45-j], buff[44-j], buff[43-j],
					buff[42-j], buff[41-j], buff[40-j], buff[39-j], buff[38-j], buff[37-j],
					buff[36-j], buff[35-j], buff[34-j], buff[33-j], buff[32-j], buff[31-j]}),
				.buff2({
					buff[24], buff[23], buff[22], buff[21], buff[20], buff[19],
					buff[18], buff[17], buff[16], buff[15], buff[14], buff[13],
					buff[12], buff[11], buff[10], buff[9], buff[8], buff[7],
					buff[6], buff[5], buff[4], buff[3], buff[2], buff[1]}),
				.result(cmp_result[29-j]), .len(cmp_len[29-j]));
		end
	endgenerate
	
	wire [4:0] tmp[26:0];
	assign tmp[0] = buff_BM[26] ? ((cmp_len[0] > cmp_len[1]) ? cmp_len[0] : cmp_len[1]) : buff_BM[25] ? cmp_len[0] : 5'h0;
	assign tmp[1] = buff_BM[28] ? ((cmp_len[2] > cmp_len[3]) ? cmp_len[2] : cmp_len[3]) : buff_BM[27] ? cmp_len[2] : 5'h0;
	assign tmp[2] = buff_BM[30] ? ((cmp_len[4] > cmp_len[5]) ? cmp_len[4] : cmp_len[5]) : buff_BM[29] ? cmp_len[4] : 5'h0;
	assign tmp[3] = buff_BM[32] ? ((cmp_len[6] > cmp_len[7]) ? cmp_len[6] : cmp_len[7]) : buff_BM[31] ? cmp_len[6] : 5'h0;
	assign tmp[4] = buff_BM[34] ? ((cmp_len[8] > cmp_len[9]) ? cmp_len[8] : cmp_len[9]) : buff_BM[33] ? cmp_len[8] : 5'h0;
	assign tmp[5] = buff_BM[36] ? ((cmp_len[10] > cmp_len[11]) ? cmp_len[10] : cmp_len[11]) : buff_BM[35] ? cmp_len[10] : 5'h0;
	assign tmp[6] = buff_BM[38] ? ((cmp_len[12] > cmp_len[13]) ? cmp_len[12] : cmp_len[13]) : buff_BM[37] ? cmp_len[12] : 5'h0;
	assign tmp[7] = buff_BM[40] ? ((cmp_len[14] > cmp_len[15]) ? cmp_len[14] : cmp_len[15]) : buff_BM[39] ? cmp_len[14] : 5'h0;
	assign tmp[8] = buff_BM[42] ? ((cmp_len[16] > cmp_len[17]) ? cmp_len[16] : cmp_len[17]) : buff_BM[41] ? cmp_len[16] : 5'h0;
	assign tmp[9] = buff_BM[44] ? ((cmp_len[18] > cmp_len[19]) ? cmp_len[18] : cmp_len[19]) : buff_BM[43] ? cmp_len[18] : 5'h0;
	assign tmp[10] = buff_BM[46] ? ((cmp_len[20] > cmp_len[21]) ? cmp_len[20] : cmp_len[21]) : buff_BM[45] ? cmp_len[20] : 5'h0;
	assign tmp[11] = buff_BM[48] ? ((cmp_len[22] > cmp_len[23]) ? cmp_len[22] : cmp_len[23]) : buff_BM[47] ? cmp_len[22] : 5'h0;
	assign tmp[12] = buff_BM[50] ? ((cmp_len[24] > cmp_len[25]) ? cmp_len[24] : cmp_len[25]) : buff_BM[49] ? cmp_len[24] : 5'h0;
	assign tmp[13] = buff_BM[52] ? ((cmp_len[26] > cmp_len[27]) ? cmp_len[26] : cmp_len[27]) : buff_BM[51] ? cmp_len[26] : 5'h0;
	assign tmp[14] = buff_BM[54] ? ((cmp_len[28] > cmp_len[29]) ? cmp_len[28] : cmp_len[29]) : buff_BM[53] ? cmp_len[28] : 5'h0;
	
	assign tmp[15] = (tmp[0] > tmp[1]) ? tmp[0] : tmp[1];
	assign tmp[16] = (tmp[2] > tmp[3]) ? tmp[2] : tmp[3];
	assign tmp[17] = (tmp[4] > tmp[5]) ? tmp[4] : tmp[5];
	assign tmp[18] = (tmp[6] > tmp[7]) ? tmp[6] : tmp[7];
	assign tmp[19] = (tmp[8] > tmp[9]) ? tmp[8] : tmp[9];
	assign tmp[20] = (tmp[10] > tmp[11]) ? tmp[10] : tmp[11];
	assign tmp[21] = (tmp[12] > tmp[13]) ? tmp[12] : tmp[13];
	
	assign tmp[22] = (tmp[15] > tmp[16]) ? tmp[15] : tmp[16];
	assign tmp[23] = (tmp[17] > tmp[18]) ? tmp[17] : tmp[18];
	assign tmp[24] = (tmp[19] > tmp[20]) ? tmp[19] : tmp[20];
	
	assign tmp[25] = (tmp[22] > tmp[23]) ? tmp[22] : tmp[23];
	assign tmp[26] = (tmp[21] > tmp[14]) ? tmp[21] : tmp[14];
	
	assign max_len = (tmp[25] > tmp[26]) ? ((tmp[25] > tmp[24]) ? tmp[25] : tmp[24] ) : ((tmp[26] > tmp[24]) ? tmp[26] : tmp[24] );
	
	always @(posedge clk) begin
		if (buff_BM[25]) begin
			match_len <= max_len;
			char_nxt <= buff[5'h18-max_len];
			if (max_len == 5'h00)
				offset <= 5'h00;
			else if ((cmp_len[29] == max_len) & buff_BM[54])
				offset <= 5'h1D;
			else if ((cmp_len[28] == max_len) & buff_BM[53])
				offset <= 5'h1C;
			else if ((cmp_len[27] == max_len) & buff_BM[52])
				offset <= 5'h1B;
			else if ((cmp_len[26] == max_len) & buff_BM[51])
				offset <= 5'h1A;
			else if ((cmp_len[25] == max_len) & buff_BM[50])
				offset <= 5'h19;
			else if ((cmp_len[24] == max_len) & buff_BM[49])
				offset <= 5'h18;
			else if ((cmp_len[23] == max_len) & buff_BM[48])
				offset <= 5'h17;
			else if ((cmp_len[22] == max_len) & buff_BM[47])
				offset <= 5'h16;
			else if ((cmp_len[21] == max_len) & buff_BM[46])
				offset <= 5'h15;
			else if ((cmp_len[20] == max_len) & buff_BM[45])
				offset <= 5'h14;
			else if ((cmp_len[19] == max_len) & buff_BM[44])
				offset <= 5'h13;
			else if ((cmp_len[18] == max_len) & buff_BM[43])
				offset <= 5'h12;
			else if ((cmp_len[17] == max_len) & buff_BM[42])
				offset <= 5'h11;
			else if ((cmp_len[16] == max_len) & buff_BM[41])
				offset <= 5'h10;
			else if ((cmp_len[15] == max_len) & buff_BM[40])
				offset <= 5'h0F;
			else if ((cmp_len[14] == max_len) & buff_BM[39])
				offset <= 5'h0E;
			else if ((cmp_len[13] == max_len) & buff_BM[38])
				offset <= 5'h0D;
			else if ((cmp_len[12] == max_len) & buff_BM[37])
				offset <= 5'h0C;
			else if ((cmp_len[11] == max_len) & buff_BM[36])
				offset <= 5'h0B;
			else if ((cmp_len[10] == max_len) & buff_BM[35])
				offset <= 5'h0A;
			else if ((cmp_len[9] == max_len) & buff_BM[34])
				offset <= 5'h09;
			else if ((cmp_len[8] == max_len) & buff_BM[33])
				offset <= 5'h08;
			else if ((cmp_len[7] == max_len) & buff_BM[32])
				offset <= 5'h07;
			else if ((cmp_len[6] == max_len) & buff_BM[31])
				offset <= 5'h06;
			else if ((cmp_len[5] == max_len) & buff_BM[30])
				offset <= 5'h05;
			else if ((cmp_len[4] == max_len) & buff_BM[29])
				offset <= 5'h04;
			else if ((cmp_len[3] == max_len) & buff_BM[28])
				offset <= 5'h03;
			else if ((cmp_len[2] == max_len) & buff_BM[27])
				offset <= 5'h02;
			else if ((cmp_len[1] == max_len) & buff_BM[26])
				offset <= 5'h01;
			else
				offset <= 5'h0;
		end else begin
			match_len <= 5'h0;
			char_nxt <= buff[24];
			offset <= 5'h0;
		end
	end
	
	always @(posedge clk) begin
		if (buff_BM[24] & (state != done)) begin
			if (!hold) begin
				valid <= 1'b1;
				hold <= max_len;
			end else begin
				valid <= 1'b0;
				hold <= hold - 5'h01;
			end
		end else begin
			hold <= 5'h00;
			valid <= 1'b0;
		end
	end
	
	always @(negedge clk) begin
		if ((char_nxt == 8'h24) & valid)
			out_complete <= 1'b1;
		else
			out_complete <= 1'b0;
	end

endmodule

module cmp(buff1, buff2, result, len);
input		[191:0]	buff1;
input 		[191:0]	buff2;
output reg	[23:0]	result;
output reg	[4:0]	len;
	
	always @(*) begin
		result[0] = |(buff1[7:0] ^ buff2[7:0]);
		result[1] = |(buff1[15:8] ^ buff2[15:8]);
		result[2] = |(buff1[23:16] ^ buff2[23:16]);
		result[3] = |(buff1[31:24] ^ buff2[31:24]);
		result[4] = |(buff1[39:32] ^ buff2[39:32]);
		result[5] = |(buff1[47:40] ^ buff2[47:40]);
		result[6] = |(buff1[55:48] ^ buff2[55:48]);
		result[7] = |(buff1[63:56] ^ buff2[63:56]);
		result[8] = |(buff1[71:64] ^ buff2[71:64]);
		result[9] = |(buff1[79:72] ^ buff2[79:72]);
		result[10] = |(buff1[87:80] ^ buff2[87:80]);
		result[11] = |(buff1[95:88] ^ buff2[95:88]);
		result[12] = |(buff1[103:96] ^ buff2[103:96]);
		result[13] = |(buff1[111:104] ^ buff2[111:104]);
		result[14] = |(buff1[119:112] ^ buff2[119:112]);
		result[15] = |(buff1[127:120] ^ buff2[127:120]);
		result[16] = |(buff1[135:128] ^ buff2[135:128]);
		result[17] = |(buff1[143:136] ^ buff2[143:136]);
		result[18] = |(buff1[151:144] ^ buff2[151:144]);
		result[19] = |(buff1[159:152] ^ buff2[159:152]);
		result[20] = |(buff1[167:160] ^ buff2[167:160]);
		result[21] = |(buff1[175:168] ^ buff2[175:168]);
		result[22] = |(buff1[183:176] ^ buff2[183:176]);
		result[23] = |(buff1[191:184] ^ buff2[191:184]);
		
	end

	always @(*) begin
		casez (result)
			default: len = 5'h00;
			24'b000000000000000000000000: len = 5'h18;
			24'b000000000000000000000001: len = 5'h17;
			24'b00000000000000000000001z: len = 5'h16;
			24'b0000000000000000000001zz: len = 5'h15;
			24'b000000000000000000001zzz: len = 5'h14;
			24'b00000000000000000001zzzz: len = 5'h13;
			24'b0000000000000000001zzzzz: len = 5'h12;
			24'b000000000000000001zzzzzz: len = 5'h11;
			24'b00000000000000001zzzzzzz: len = 5'h10;
			24'b0000000000000001zzzzzzzz: len = 5'h0F;
			24'b000000000000001zzzzzzzzz: len = 5'h0E;
			24'b00000000000001zzzzzzzzzz: len = 5'h0D;
			24'b0000000000001zzzzzzzzzzz: len = 5'h0C;
			24'b000000000001zzzzzzzzzzzz: len = 5'h0B;
			24'b00000000001zzzzzzzzzzzzz: len = 5'h0A;
			24'b0000000001zzzzzzzzzzzzzz: len = 5'h09;
			24'b000000001zzzzzzzzzzzzzzz: len = 5'h08;
			24'b00000001zzzzzzzzzzzzzzzz: len = 5'h07;
			24'b0000001zzzzzzzzzzzzzzzzz: len = 5'h06;
			24'b000001zzzzzzzzzzzzzzzzzz: len = 5'h05;
			24'b00001zzzzzzzzzzzzzzzzzzz: len = 5'h04;
			24'b0001zzzzzzzzzzzzzzzzzzzz: len = 5'h03;
			24'b001zzzzzzzzzzzzzzzzzzzzz: len = 5'h02;
			24'b01zzzzzzzzzzzzzzzzzzzzzz: len = 5'h01;
		endcase
	end

endmodule