module cmp(buff1, buff2, result);
input		[63:0]	buff1;
input 		[63:0]	buff2;
output reg	[7:0]	result;

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

endmodule