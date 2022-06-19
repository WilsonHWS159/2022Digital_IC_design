module BOE(clk, rst, data_num, data_in, result);
input clk;
input rst;
input [2:0] data_num;
input [7:0] data_in;
output reg [10:0] result;

	reg [1:0] state, n_state;
	reg [7:0] series [5:0];
	reg [2:0] cnt, s_cnt;
	reg [7:0] min;
	reg [10:0] sum;
	parameter [1:0] receive = 2'b00, o_sum = 2'b01, o_min = 2'b11, o_sort = 2'b10;

	always @(*) begin
		case (state)
			receive : n_state = (cnt == s_cnt) ? o_sum : receive;
			o_sum : n_state = o_min;
			o_min : n_state = o_sort;
			o_sort : n_state = (cnt == s_cnt) ? receive : o_sort;
		endcase
	end
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= receive;
			sum <= 11'h000;
			min <= 8'hFF;
			cnt <= 3'h7;
			s_cnt <= 3'h0;
			series[0] <= 8'h00;
			series[1] <= 8'h00;
			series[2] <= 8'h00;
			series[3] <= 8'h00;
			series[4] <= 8'h00;
			series[5] <= 8'h00;
		end else begin
			state <= n_state;
			case (state)
				receive : begin
					cnt <= (data_num == 0) ? cnt : data_num - 3'h1;
					s_cnt <= (cnt == s_cnt) ? 0 : s_cnt + 3'h1;
					sum <= sum + data_in;
					if (data_in < min) begin
						min <= data_in;
					end
					
					if (data_in >= series[0]) begin
						series[0] <= data_in;
						series[1] <= series[0];
						series[2] <= series[1];
						series[3] <= series[2];
						series[4] <= series[3];
						series[5] <= series[4];
					end else if (data_in >= series[1]) begin
						series[0] <= series[0];
						series[1] <= data_in;
						series[2] <= series[1];
						series[3] <= series[2];
						series[4] <= series[3];
						series[5] <= series[4];
					end else if (data_in >= series[2]) begin
						series[0] <= series[0];
						series[1] <= series[1];
						series[2] <= data_in;
						series[3] <= series[2];
						series[4] <= series[3];
						series[5] <= series[4];
					end else if (data_in >= series[3]) begin
						series[0] <= series[0];
						series[1] <= series[1];
						series[2] <= series[2];
						series[3] <= data_in;
						series[4] <= series[3];
						series[5] <= series[4];
					end else if (data_in >= series[4]) begin
						series[0] <= series[0];
						series[1] <= series[1];
						series[2] <= series[2];
						series[3] <= series[3];
						series[4] <= data_in;
						series[5] <= series[4];
					end else begin
						series[0] <= series[0];
						series[1] <= series[1];
						series[2] <= series[2];
						series[3] <= series[3];
						series[4] <= series[5];
						series[5] <= data_in;
					end
				end
				o_min : result <= min;
				o_sum : result <= sum;
				o_sort : begin
					result <= series[s_cnt];
					s_cnt <= (s_cnt == cnt) ? 3'h0 : s_cnt + 3'h1;
					series[0] <= (s_cnt == cnt) ? 8'h00 : series[0];
					series[1] <= (s_cnt == cnt) ? 8'h00 : series[1];
					series[2] <= (s_cnt == cnt) ? 8'h00 : series[2];
					series[3] <= (s_cnt == cnt) ? 8'h00 : series[3];
					series[4] <= (s_cnt == cnt) ? 8'h00 : series[4];
					series[5] <= (s_cnt == cnt) ? 8'h00 : series[5];
					sum <= 11'h000;
					min <= 8'hFF;
				end
			endcase
		end
	end

endmodule