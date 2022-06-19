module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);

input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output reg 			valid;
output  			encode;
output reg 			finish;
output reg 	[3:0] 	offset;
output reg 	[2:0] 	match_len;
output reg 	[7:0] 	char_nxt;


reg			[2:0]	current_state, next_state;
reg			[11:0]	counter;
reg			[3:0]	search_index;
reg			[2:0]	lookahead_index;
reg			[3:0]	str_buffer	[2047:0];
reg			[3:0]	search_buffer	[8:0];

wire				equal	[7:0];
wire		[11:0]	current_encode_len;
wire		[2:0]	curr_lookahead_index;
wire		[3:0]	match_char [6:0];

parameter [2:0] IN=3'b000, ENCODE_NOT_MATCH=3'b001, ENCODE_MATCH=3'b010, ENCODE_OUT=3'b011, SHIFT_ENCODE=3'b100;

integer i;

assign	encode = 1'b1;


assign	match_char[0] = search_buffer[search_index];
assign	match_char[1] = (search_index >= 1) ? search_buffer[search_index-1] : str_buffer[search_index];
assign	match_char[2] = (search_index >= 2) ? search_buffer[search_index-2] : str_buffer[1-search_index];
assign	match_char[3] = (search_index >= 3) ? search_buffer[search_index-3] : str_buffer[2-search_index];
assign	match_char[4] = (search_index >= 4) ? search_buffer[search_index-4] : str_buffer[3-search_index];
assign	match_char[5] = (search_index >= 5) ? search_buffer[search_index-5] : str_buffer[4-search_index];
assign	match_char[6] = (search_index >= 6) ? search_buffer[search_index-6] : str_buffer[5-search_index];

assign	equal[0] = (search_index <= 8) ? (match_char[0]==str_buffer[0]) ? 1'b1 : 1'b0 : 1'b0;
assign	equal[1] = (search_index <= 8) ? (match_char[1]==str_buffer[1]) ? equal[0] : 1'b0 : 1'b0;
assign	equal[2] = (search_index <= 8) ? (match_char[2]==str_buffer[2]) ? equal[1] : 1'b0 : 1'b0;
assign	equal[3] = (search_index <= 8) ? (match_char[3]==str_buffer[3]) ? equal[2] : 1'b0 : 1'b0;
assign	equal[4] = (search_index <= 8) ? (match_char[4]==str_buffer[4]) ? equal[3] : 1'b0 : 1'b0;
assign	equal[5] = (search_index <= 8) ? (match_char[5]==str_buffer[5]) ? equal[4] : 1'b0 : 1'b0;
assign	equal[6] = (search_index <= 8) ? (match_char[6]==str_buffer[6]) ? equal[5] : 1'b0 : 1'b0;
assign	equal[7] = 1'b0;

assign	current_encode_len = counter+match_len+1;
assign	curr_lookahead_index = lookahead_index+1;


always @(posedge clk or posedge reset)
begin
	if(reset)
	begin
		current_state <= IN;
		counter <= 12'd0;
		search_index <= 4'd0;
		lookahead_index <= 3'd0;
		valid <= 1'b0;
		finish <= 1'b0;
		offset <= 4'd0;
		match_len <= 3'd0;
		char_nxt <= 8'd0;

		search_buffer[0] <= 4'd0;
		search_buffer[1] <= 4'd0;
		search_buffer[2] <= 4'd0;
		search_buffer[3] <= 4'd0;
		search_buffer[4] <= 4'd0;
		search_buffer[5] <= 4'd0;
		search_buffer[6] <= 4'd0;
		search_buffer[7] <= 4'd0;
		search_buffer[8] <= 4'd0;
	end
	else
	begin
		current_state <= next_state;
		
		case(current_state)
			IN:
			begin
				str_buffer[counter] <= chardata[3:0];
				counter <= (counter==2047) ? 0 : counter+1;
			end
			ENCODE_NOT_MATCH:
			begin
				search_index 	<= /* fill in here */;
			end
			ENCODE_MATCH:
			begin
				char_nxt 		<= /* fill in here */;
				match_len 		<= /* fill in here */;
				offset 			<= /* fill in here */;
				lookahead_index <= /* fill in here */;
			end
			ENCODE_OUT:
			begin
				valid <= 1;
				// offset <= offset;
				// match_len <= match_len;
				char_nxt <= (current_encode_len==2049) ? 8'h24 : (match_len==0) ? str_buffer[0] : char_nxt;
				counter <= current_encode_len;
			end
			SHIFT_ENCODE:
			begin
				finish <= (counter==2049) ? 1 : 0;
				offset <= 0;
				valid <= 0;
				match_len <= 0;
				search_index <= 8;
				lookahead_index <= (lookahead_index==0) ? 0 : lookahead_index-1;

				search_buffer[8] <= search_buffer[7];
				search_buffer[7] <= search_buffer[6];
				search_buffer[6] <= search_buffer[5];
				search_buffer[5] <= search_buffer[4];
				search_buffer[4] <= search_buffer[3];
				search_buffer[3] <= search_buffer[2];
				search_buffer[2] <= search_buffer[1];
				search_buffer[1] <= search_buffer[0];
				search_buffer[0] <= str_buffer[0];

				for (i=0; i<2047; i=i+1) begin
					str_buffer[i] <= str_buffer[i+1];
				end
			end
		endcase
	end
end



always @(*)
begin
	case(current_state)
		IN:
		begin
			next_state = /* fill in here */;
		end
		ENCODE_NOT_MATCH:
		begin
			next_state = /* fill in here */;
		end
		ENCODE_MATCH:
		begin
			next_state = /* fill in here */;
		end
		ENCODE_OUT:
		begin
			next_state = /* fill in here */;
		end
		SHIFT_ENCODE:
		begin
			next_state = /* fill in here */;
		end
		default:
		begin
			next_state = /* fill in here */;
		end
	endcase
end


endmodule
