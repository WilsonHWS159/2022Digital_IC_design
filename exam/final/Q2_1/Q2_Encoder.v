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
	// 0~2 is look-ahead buffer, 3-9 is search buffer
	reg [7:0] buff[9:0];
	reg [1:0] hold;
	reg [9:0] buff_BM;
	wire [6:0] cmp_result[6:0];
	wire [1:0] cmp_len[6:0];
	wire [1:0] max_len;
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
					n_state = (id == 12'h801) ? encoding : recieving_data;
				end
				encoding : begin
					finish = 1'b0;
					n_state = out_complete ? done : encoding;
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
			buff_BM <= 10'h000;
		end else begin
			case (state)
				recieving_data : begin
					tmp_char[id] <= chardata;
					id <= id + 12'h001;
				end
				encoding : begin
					buff[0] <= tmp_char[id2];
					buff_BM[0] <= 1'b1;
					id2 <= (id2 == 12'h800) ? id2 : id2 + 12'h001;
					for (i=0;i<9;i=i+1) begin
						buff[i+1] <= buff[i];
						buff_BM[i+1] <= buff_BM[i];
					end
				end
			endcase
		end
	end

	generate
		genvar j;
		for (j=0; j<7; j=j+1) begin: CMP
			cmp Cmp(.buff1({buff[9-j], buff[8-j]}), .buff2({buff[2], buff[1]}), .result(cmp_result[6-j]), .len(cmp_len[6-j]));
		end
	endgenerate
	
	wire [1:0] tmp[4:0];
	assign tmp[0] = buff_BM[4] ? ((cmp_len[0] > cmp_len[1]) ? cmp_len[0] : cmp_len[1]) : buff_BM[3] ? cmp_len[0] : 4'h0;
	assign tmp[1] = buff_BM[6] ? ((cmp_len[2] > cmp_len[3]) ? cmp_len[2] : cmp_len[3]) : buff_BM[5] ? cmp_len[2] : 4'h0;
	assign tmp[2] = buff_BM[8] ? ((cmp_len[4] > cmp_len[5]) ? cmp_len[4] : cmp_len[5]) : buff_BM[7] ? cmp_len[4] : 4'h0;
	assign tmp[3] = (tmp[0] > tmp[1]) ? tmp[0] : tmp[1];
	assign tmp[4] = buff_BM[9] ? ((tmp[2] > cmp_len[6]) ? tmp[2] : cmp_len[6]) : tmp[2];
	assign max_len = (tmp[3] > tmp[4]) ? tmp[3] : tmp[4];
	
	always @(posedge clk) begin
		if (buff_BM[3]) begin
			match_len <= max_len;
			char_nxt <= buff[2-max_len];
			if (!max_len)
				offset <= 4'h0;
			else if ((cmp_len[6] == max_len) & buff_BM[9])
				offset <= 4'h6;
			else if ((cmp_len[5] == max_len) & buff_BM[8])
				offset <= 4'h5;
			else if ((cmp_len[4] == max_len) & buff_BM[7])
				offset <= 4'h4;
			else if ((cmp_len[3] == max_len) & buff_BM[6])
				offset <= 4'h3;
			else if ((cmp_len[2] == max_len) & buff_BM[5])
				offset <= 4'h2;
			else if ((cmp_len[1] == max_len) & buff_BM[4])
				offset <= 4'h1;
			else
				offset <= 4'h0;
		end else begin
			match_len <= 3'h0;
			char_nxt <= buff[2];
			offset <= 4'h0;
		end
	end
	
	always @(posedge clk) begin
		if (buff_BM[2] & (state != done)) begin
			if (!hold) begin
				valid <= 1'b1;
				hold <= max_len;
			end else begin
				valid <= 1'b0;
				hold <= hold - 2'h1;
			end
		end else begin
			hold <= 2'h0;
			valid <= 1'b0;
		end
	end
	
	always @(negedge clk) begin
		out_complete <= ((char_nxt == 8'h24) & valid) ? 1'b1 : 1'b0;
	end

endmodule

module cmp(buff1, buff2, result, len);
input		[15:0]	buff1;
input 		[15:0]	buff2;
output reg	[1:0]	result;
output reg	[1:0]	len;

always @(*) begin
	result[0] = |(buff1[7:0] ^ buff2[7:0]);
	result[1] = |(buff1[15:8] ^ buff2[15:8]);
end

always @(*) begin
	case(result)
		2'b00 : len = 2'h2;
		2'b01 : len = 2'h1;
		default : len = 2'h0;
	endcase
end

endmodule