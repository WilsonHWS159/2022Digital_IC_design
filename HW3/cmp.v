module cmp(buff1, buff2, result, len);
input		[55:0]	buff1;
input 		[55:0]	buff2;
output reg	[6:0]	result;
output reg	[2:0]	len;

always @(*) begin
	result[0] = |(buff1[7:0] - buff2[7:0]);
	result[1] = |(buff1[15:8] - buff2[15:8]);
	result[2] = |(buff1[23:16] - buff2[23:16]);
	result[3] = |(buff1[31:24] - buff2[31:24]);
	result[4] = |(buff1[39:32] - buff2[39:32]);
	result[5] = |(buff1[47:40] - buff2[47:40]);
	result[6] = |(buff1[55:48] - buff2[55:48]);
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