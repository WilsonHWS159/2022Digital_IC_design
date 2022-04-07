module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);


input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output reg			valid;
output reg			encode;
output reg 			finish;
output reg	[3:0] 	offset;
output reg	[2:0] 	match_len;
output reg	[7:0] 	char_nxt;

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
	if (l_full & !hold)	begin
		case (s_cnt)
			default: begin
				valid <= 1'b0;
				offset <= 4'h0;
				match_len <= 3'h0;
				char_nxt <= 8'h00;
				hold <= 4'h0;
			end
			4'h0: begin
				valid <= 1'b1;
				offset <= 4'h0;
				match_len <= 3'h0;
				char_nxt <= buff[7];
				hold <= 4'h0;
			end
			4'h1: begin
				if (buff[7] == buff[8]) begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h1;
					char_nxt <= buff[6];
					hold <= 4'h0;
				end else begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h0;
					char_nxt <= buff[7];
					hold <= 4'h0;
				end
			end
			4'h2: begin
				if (buff[7] == buff[9]) begin
					if (buff[6] == buff[8]) begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h2;
						char_nxt <= buff[5];
						hold <= 4'h1;
					end else begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[8]) begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h1;
					char_nxt <= buff[6];
					hold <= 4'h0;
				end else begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h0;
					char_nxt <= buff[7];
					hold <= 4'h0;
				end
			end
			4'h3: begin
				if (buff[7] == buff[10]) begin
					if (buff[6] == buff[9]) begin
						if (buff[5] == buff[8]) begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h3;
							char_nxt <= buff[4];
							hold <= 4'h2;
						end else begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h2;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[9]) begin
					if (buff[6] == buff[8]) begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h2;
						char_nxt <= buff[5];
						hold <= 4'h1;
					end else begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[8]) begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h1;
					char_nxt <= buff[6];
					hold <= 4'h0;
				end else begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h0;
					char_nxt <= buff[7];
					hold <= 4'h0;
				end
			end
			4'h4: begin
				if (buff[7] == buff[11]) begin
					if (buff[6] == buff[10]) begin
						if (buff[5] == buff[9]) begin
							if (buff[4] == buff[8]) begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h4;
								char_nxt <= buff[3];
								hold <= 4'h3;
							end else begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h3;
								char_nxt <= buff[4];
								hold <= 4'h2;
							end
						end else begin
							valid <= 1'b1;
							offset <= 4'h3;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h3;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[10]) begin
					if (buff[6] == buff[9]) begin
						if (buff[5] == buff[8]) begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h3;
							char_nxt <= buff[4];
							hold <= 4'h2;
						end else begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h2;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[9]) begin
					if (buff[6] == buff[8]) begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h2;
						char_nxt <= buff[5];
						hold <= 4'h1;
					end else begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[8]) begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h1;
					char_nxt <= buff[6];
					hold <= 4'h0;
				end else begin
					valid <= 1'b0;
					offset <= 4'h0;
					match_len <= 3'h0;
					char_nxt <= 8'h00;
					hold <= 4'h0;
				end
			end
			4'h5: begin
				if (buff[7] == buff[12]) begin
					if (buff[6] == buff[11]) begin
						if (buff[5] == buff[10]) begin
							if (buff[4] == buff[9]) begin
								if (buff[3] == buff[8]) begin
									valid <= 1'b1;
									offset <= 4'h4;
									match_len <= 3'h5;
									char_nxt <= buff[2];
									hold <= 4'h4;
								end else begin
									valid <= 1'b1;
									offset <= 4'h4;
									match_len <= 3'h4;
									char_nxt <= buff[3];
									hold <= 4'h3;
								end
							end else begin
								valid <= 1'b1;
								offset <= 4'h4;
								match_len <= 3'h3;
								char_nxt <= buff[4];
								hold <= 4'h2;
							end
						end else begin
							valid <= 1'b1;
							offset <= 4'h4;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h4;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[11]) begin
					if (buff[6] == buff[10]) begin
						if (buff[5] == buff[9]) begin
							if (buff[4] == buff[8]) begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h4;
								char_nxt <= buff[3];
								hold <= 4'h3;
							end else begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h3;
								char_nxt <= buff[4];
								hold <= 4'h2;
							end
						end else begin
							valid <= 1'b1;
							offset <= 4'h3;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h3;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[10]) begin
					if (buff[6] == buff[9]) begin
						if (buff[5] == buff[8]) begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h3;
							char_nxt <= buff[4];
							hold <= 4'h2;
						end else begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h2;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[9]) begin
					if (buff[6] == buff[8]) begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h2;
						char_nxt <= buff[5];
						hold <= 4'h1;
					end else begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[8]) begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h1;
					char_nxt <= buff[6];
					hold <= 4'h0;
				end else begin
					valid <= 1'b0;
					offset <= 4'h0;
					match_len <= 3'h0;
					char_nxt <= 8'h00;
					hold <= 4'h0;
				end
			end
			4'h6: begin
				if (buff[7] == buff[13]) begin
					if (buff[6] == buff[12]) begin
						if (buff[5] == buff[11]) begin
							if (buff[4] == buff[10]) begin
								if (buff[3] == buff[9]) begin
									if (buff[2] == buff[8]) begin
										valid <= 1'b1;
										offset <= 4'h5;
										match_len <= 3'h6;
										char_nxt <= buff[1];
										hold <= 4'h5;
									end else begin
										valid <= 1'b1;
										offset <= 4'h5;
										match_len <= 3'h6;
										char_nxt <= buff[1];
										hold <= 4'h5;
									end
								end else begin
								end
							end else begin
							end
						end else begin
						end
					end else begin
					end
				end else if (buff[7] == buff[12]) begin
					if (buff[6] == buff[11]) begin
						if (buff[5] == buff[10]) begin
							if (buff[4] == buff[9]) begin
								if (buff[3] == buff[8]) begin
									valid <= 1'b1;
									offset <= 4'h4;
									match_len <= 3'h5;
									char_nxt <= buff[2];
									hold <= 4'h4;
								end else begin
									valid <= 1'b1;
									offset <= 4'h4;
									match_len <= 3'h4;
									char_nxt <= buff[3];
									hold <= 4'h3;
								end
							end else begin
								valid <= 1'b1;
								offset <= 4'h4;
								match_len <= 3'h3;
								char_nxt <= buff[4];
								hold <= 4'h2;
							end
						end else begin
							valid <= 1'b1;
							offset <= 4'h4;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h4;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[11]) begin
					if (buff[6] == buff[10]) begin
						if (buff[5] == buff[9]) begin
							if (buff[4] == buff[8]) begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h4;
								char_nxt <= buff[3];
								hold <= 4'h3;
							end else begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h3;
								char_nxt <= buff[4];
								hold <= 4'h2;
							end
						end else begin
							valid <= 1'b1;
							offset <= 4'h3;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h3;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[10]) begin
					if (buff[6] == buff[9]) begin
						if (buff[5] == buff[8]) begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h3;
							char_nxt <= buff[4];
							hold <= 4'h2;
						end else begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h2;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[9]) begin
					if (buff[6] == buff[8]) begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h2;
						char_nxt <= buff[5];
						hold <= 4'h1;
					end else begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[8]) begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h1;
					char_nxt <= buff[6];
					hold <= 4'h0;
				end else begin
					valid <= 1'b0;
					offset <= 4'h0;
					match_len <= 3'h0;
					char_nxt <= 8'h00;
					hold <= 4'h0;
				end
			end
			4'h7: begin
				if (buff[7] == buff[14]) begin
				end else if (buff[7] == buff[13]) begin
				end else if (buff[7] == buff[12]) begin
					if (buff[6] == buff[11]) begin
						if (buff[5] == buff[10]) begin
							if (buff[4] == buff[9]) begin
								if (buff[3] == buff[8]) begin
									valid <= 1'b1;
									offset <= 4'h4;
									match_len <= 3'h5;
									char_nxt <= buff[2];
									hold <= 4'h4;
								end else begin
									valid <= 1'b1;
									offset <= 4'h4;
									match_len <= 3'h4;
									char_nxt <= buff[3];
									hold <= 4'h3;
								end
							end else begin
								valid <= 1'b1;
								offset <= 4'h4;
								match_len <= 3'h3;
								char_nxt <= buff[4];
								hold <= 4'h2;
							end
						end else begin
							valid <= 1'b1;
							offset <= 4'h4;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h4;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[11]) begin
					if (buff[6] == buff[10]) begin
						if (buff[5] == buff[9]) begin
							if (buff[4] == buff[8]) begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h4;
								char_nxt <= buff[3];
								hold <= 4'h3;
							end else begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h3;
								char_nxt <= buff[4];
								hold <= 4'h2;
							end
						end else begin
							valid <= 1'b1;
							offset <= 4'h3;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h3;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[10]) begin
					if (buff[6] == buff[9]) begin
						if (buff[5] == buff[8]) begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h3;
							char_nxt <= buff[4];
							hold <= 4'h2;
						end else begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h2;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[9]) begin
					if (buff[6] == buff[8]) begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h2;
						char_nxt <= buff[5];
						hold <= 4'h1;
					end else begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[8]) begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h1;
					char_nxt <= buff[6];
					hold <= 4'h0;
				end else begin
					valid <= 1'b0;
					offset <= 4'h0;
					match_len <= 3'h0;
					char_nxt <= 8'h00;
					hold <= 4'h0;
				end
			end
			4'h8: begin
				if (buff[7] == buff[15]) begin
				end else if (buff[7] == buff[14]) begin
				end else if (buff[7] == buff[13]) begin
				end else if (buff[7] == buff[12]) begin
					if (buff[6] == buff[11]) begin
						if (buff[5] == buff[10]) begin
							if (buff[4] == buff[9]) begin
								if (buff[3] == buff[8]) begin
									valid <= 1'b1;
									offset <= 4'h4;
									match_len <= 3'h5;
									char_nxt <= buff[2];
									hold <= 4'h4;
								end else begin
									valid <= 1'b1;
									offset <= 4'h4;
									match_len <= 3'h4;
									char_nxt <= buff[3];
									hold <= 4'h3;
								end
							end else begin
								valid <= 1'b1;
								offset <= 4'h4;
								match_len <= 3'h3;
								char_nxt <= buff[4];
								hold <= 4'h2;
							end
						end else begin
							valid <= 1'b1;
							offset <= 4'h4;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h4;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[11]) begin
					if (buff[6] == buff[10]) begin
						if (buff[5] == buff[9]) begin
							if (buff[4] == buff[8]) begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h4;
								char_nxt <= buff[3];
								hold <= 4'h3;
							end else begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h3;
								char_nxt <= buff[4];
								hold <= 4'h2;
							end
						end else begin
							valid <= 1'b1;
							offset <= 4'h3;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h3;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[10]) begin
					if (buff[6] == buff[9]) begin
						if (buff[5] == buff[8]) begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h3;
							char_nxt <= buff[4];
							hold <= 4'h2;
						end else begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h2;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[9]) begin
					if (buff[6] == buff[8]) begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h2;
						char_nxt <= buff[5];
						hold <= 4'h1;
					end else begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[8]) begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h1;
					char_nxt <= buff[6];
					hold <= 4'h0;
				end else begin
					valid <= 1'b0;
					offset <= 4'h0;
					match_len <= 3'h0;
					char_nxt <= 8'h00;
					hold <= 4'h0;
				end
			end
			4'h9: begin
				if (buff[7] == buff[16]) begin
				end else if (buff[7] == buff[15]) begin
				end else if (buff[7] == buff[14]) begin
				end else if (buff[7] == buff[13]) begin
				end else if (buff[7] == buff[12]) begin
					if (buff[6] == buff[11]) begin
						if (buff[5] == buff[10]) begin
							if (buff[4] == buff[9]) begin
								if (buff[3] == buff[8]) begin
									valid <= 1'b1;
									offset <= 4'h4;
									match_len <= 3'h5;
									char_nxt <= buff[2];
									hold <= 4'h4;
								end else begin
									valid <= 1'b1;
									offset <= 4'h4;
									match_len <= 3'h4;
									char_nxt <= buff[3];
									hold <= 4'h3;
								end
							end else begin
								valid <= 1'b1;
								offset <= 4'h4;
								match_len <= 3'h3;
								char_nxt <= buff[4];
								hold <= 4'h2;
							end
						end else begin
							valid <= 1'b1;
							offset <= 4'h4;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h4;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[11]) begin
					if (buff[6] == buff[10]) begin
						if (buff[5] == buff[9]) begin
							if (buff[4] == buff[8]) begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h4;
								char_nxt <= buff[3];
								hold <= 4'h3;
							end else begin
								valid <= 1'b1;
								offset <= 4'h3;
								match_len <= 3'h3;
								char_nxt <= buff[4];
								hold <= 4'h2;
							end
						end else begin
							valid <= 1'b1;
							offset <= 4'h3;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h3;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[10]) begin
					if (buff[6] == buff[9]) begin
						if (buff[5] == buff[8]) begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h3;
							char_nxt <= buff[4];
							hold <= 4'h2;
						end else begin
							valid <= 1'b1;
							offset <= 4'h2;
							match_len <= 3'h2;
							char_nxt <= buff[5];
							hold <= 4'h1;
						end
					end else begin
						valid <= 1'b1;
						offset <= 4'h2;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[9]) begin
					if (buff[6] == buff[8]) begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h2;
						char_nxt <= buff[5];
						hold <= 4'h1;
					end else begin
						valid <= 1'b1;
						offset <= 4'h1;
						match_len <= 3'h1;
						char_nxt <= buff[6];
						hold <= 4'h0;
					end
				end else if (buff[7] == buff[8]) begin
					valid <= 1'b1;
					offset <= 4'h0;
					match_len <= 3'h1;
					char_nxt <= buff[6];
					hold <= 4'h0;
				end else begin
					valid <= 1'b0;
					offset <= 4'h0;
					match_len <= 3'h0;
					char_nxt <= 8'h00;
					hold <= 4'h0;
				end
			end
		endcase
	end else begin
		valid <= 1'b0;
		offset <= 4'h0;
		match_len <= 3'h0;
		char_nxt <= 8'h00;
		if (!hold)
			hold <= hold;
		else
			hold = hold - 1;
	end
end

endmodule