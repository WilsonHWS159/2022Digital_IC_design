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

	reg out_complete;
	reg [7:0] tmp_char[2049:0];
	reg [11:0] id, id2;
	// 0~7 is look-ahead buffer, 8-16 is search buffer
	reg [7:0] buff[16:0];
	reg [2:0] hold;
	reg [16:0] buff_BM;
	wire [6:0] cmp_result[8:0];
	wire [2:0] cmp_len[8:0];
	wire [2:0] max_len;
	// FSM
	parameter [1:0] recieving_data = 2'b00, encoding = 2'b01, done = 2'b10;
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
					if (id == 12'h801)
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
			id <= 12'h000;
			id2 <= 12'h000;
			buff_BM <= 17'h00000;
		end else begin
			case (state)
				recieving_data : begin
					tmp_char[id] <= chardata;
					id <= id + 12'h001;
				end
				encoding : begin
					buff[0] <= tmp_char[id2];
					buff_BM[0] <= 1'b1;
					if (id2 == 2048)
						id2 <= id2;
					else
						id2 <= id2 + 12'h001;
					for (i=0;i<16;i=i+1) begin
						buff[i+1] <= buff[i];
						buff_BM[i+1] <= buff_BM[i];
					end
				end
				endcase
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
	
	always @(negedge clk) begin
		if (buff_BM[8]) begin
			match_len <= max_len;
			char_nxt <= buff[7-max_len];
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
			else
				offset <= 4'h0;
		end else begin
			match_len <= 3'h0;
			char_nxt <= buff[7];
			offset <= 4'h0;
		end
	end
	
	always @(negedge clk) begin
		if (buff_BM[7] & (state != done)) begin
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
	
	always @(negedge clk) begin
		if ((char_nxt == 8'h24) & valid)
			out_complete <= 1'b1;
		else
			out_complete <= 1'b0;
	end

endmodule

module cmp(buff1, buff2, result, len);
input		[55:0]	buff1;
input 		[55:0]	buff2;
output reg	[6:0]	result;
output reg	[2:0]	len;

always @(*) begin
	result[0] = |(buff1[7:0] ^ buff2[7:0]);
	result[1] = |(buff1[15:8] ^ buff2[15:8]);
	result[2] = |(buff1[23:16] ^ buff2[23:16]);
	result[3] = |(buff1[31:24] ^ buff2[31:24]);
	result[4] = |(buff1[39:32] ^ buff2[39:32]);
	result[5] = |(buff1[47:40] ^ buff2[47:40]);
	result[6] = |(buff1[55:48] ^ buff2[55:48]);
end

always @(*) begin
	casez (result)
		default: len = 3'h00;
		7'b0000000: len = 3'h7;
		7'b0000001: len = 3'h6;
		7'b000001z: len = 3'h5;
		7'b00001zz: len = 3'h4;
		7'b0001zzz: len = 3'h3;
		7'b001zzzz: len = 3'h2;
		7'b01zzzzz: len = 3'h1;
	endcase
end

endmodule