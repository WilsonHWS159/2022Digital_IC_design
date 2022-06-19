module LZ77_Decoder(clk,reset,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input 		[3:0] 	code_pos;
input 		[2:0] 	code_len;
input 		[7:0] 	chardata;
output reg 			encode;
output reg 			finish;
output reg 	[7:0] 	char_nxt;

	reg [7:0] buff[6:0];
	reg [1:0] hold;
	reg complete;
	
	integer i;
	always @(posedge clk) begin
		if (reset) begin
			hold <= 2'h0;
		end else if (finish) begin
		end else begin
			if (!code_len) begin
				buff[0] <= chardata;
				char_nxt <= chardata;
			end else if (!hold) begin
				hold <= code_len;
				buff[0] <= buff[code_pos];
				char_nxt <= buff[code_pos];
			end else if (hold == 2'h1) begin
				hold <= 2'h0;
				buff[0] <= chardata;
				char_nxt <= chardata;
			end else begin
				hold <= hold - 2'h1;
				buff[0] <= buff[code_pos];
				char_nxt <= buff[code_pos];
			end
			for (i=0; i<6;i=i+1)
				buff[i+1] <= buff[i];
		end
	end
	
	always @(posedge clk) begin
		if (reset)
			finish <= 1'b0;
		else if (chardata == 8'h24)
			if ((!hold & !code_len) | (hold == 2'h1))
				finish <= 1'b1;
			else
				finish <= finish;
		else
			finish <= finish;
	end
	
	always @(negedge reset) begin
		encode <= 1'b0;
	end

endmodule
