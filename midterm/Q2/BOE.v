module BOE(clk, rst, data_num, data_in, result);
input clk;
input rst;
input [2:0] data_num;
input [7:0] data_in;
output reg [10:0] result;

	reg [1:0] state, n_state;
	reg [7:0] series[5:0];
	reg [5:0] valid;
	reg [2:0] cnt, s_cnt;
	reg [2:0] num;
	reg [7:0] min;
	reg [10:0] sum;
	parameter [1:0] receive = 2'b00, o_min = 2'b01, o_sum = 2'b10, o_sort = 2'b11;

	always @(*) begin
		if (rst) begin
			n_state = receive;
		end else begin
			case (state)
				default : n_state = receive;
				receive : begin
					n_state = (cnt == num) ? o_min : receive;
				end
				o_min : begin
					n_state = o_sum;
				end
				o_sum : begin
					n_state = o_sort;
				end
				o_sort : begin
					n_state = (s_cnt == num) ? receive : o_sort;
				end
			endcase
		end
	end
	
	always @(posedge rst) begin
		cnt <= 3'h1;
		s_cnt <= 3'h1;
		num <= 3'h0;
		sum <= 11'h000;
	end
	
	always @(posedge clk) begin
		state <= n_state;
		if ((state == receive) & ~rst) begin
			if (data_num) begin
				num <= data_num;
				min <= data_in;
			end else begin
				cnt <= cnt + 3'h1;
			end
		end else begin
			cnt <= 3'h1;
		end
	end
	
	always @(negedge clk) begin
		if ((min >= data_in) && (state == receive))
			min <= data_in;
		else 
			min <= min;
	end
	
	always @(posedge clk) begin
		if (state == o_sort) begin
			s_cnt <= s_cnt + 3'h1;
		end else
			s_cnt <= 3'h1;
	end

	
	// Output
	
	always @(*) begin
		case (state)
			default : result = 11'h000;
			o_min : result = {3'h0, min};
			o_sum : result = sum;
			o_sort : begin
			end
		endcase
	end

endmodule