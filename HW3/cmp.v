module cmp(buff1, buff2, result, len);
input		[63:0]	buff1;
input 		[63:0]	buff2;
output reg	[7:0]	result;
output reg	[3:0]	len;

always @(*) begin
	result[0] = |(buff1[7:0] - buff2[7:0]);
	result[1] = |(buff1[15:8] - buff2[15:8]);
	result[2] = |(buff1[23:16] - buff2[23:16]);
	result[3] = |(buff1[31:24] - buff2[31:24]);
	result[4] = |(buff1[39:32] - buff2[39:32]);
	result[5] = |(buff1[47:40] - buff2[47:40]);
	result[6] = |(buff1[55:48] - buff2[55:48]);
	result[7] = |(buff1[63:56] - buff2[63:56]);
end

always @(*) begin
	casez (result)
		default: len = 4'h00;
		8'b00000000: len = 4'h8;
		8'b00000001: len = 4'h7;
		8'b0000001z: len = 4'h6;
		8'b000001zz: len = 4'h5;
		8'b00001zzz: len = 4'h4;
		8'b0001zzzz: len = 4'h3;
		8'b001zzzzz: len = 4'h2;
		8'b01zzzzzz: len = 4'h1;
	endcase
end

endmodule