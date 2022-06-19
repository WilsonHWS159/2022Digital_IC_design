`timescale 1ns/10ps

module ELA(clk, rst, ready, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input				ready;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output reg			req;
	output reg			wen;
	output reg	[12:0]	addr;
	output reg	[7:0]	data_wr;
	output reg			done;
	
	parameter	[2:0]	init = 3'h0, r_first = 3'h1, r_second = 3'h2, bound = 3'h3, not_bound = 3'h4, write_out = 3'h5, r_next = 3'h6, finish = 3'h7;
	reg	[2:0]	state, n_state;
	reg	[7:0]	d1, d2, d3;
	reg	[7:0]	line1[127:0];
	reg	[7:0]	line2[127:0];
	reg	[7:0]	count;
	
	//FSM
	always @(*) begin
		case(state)
			init : n_state = r_first;
			r_first : n_state = (count == 8'h80) ? r_second : r_first;
			r_second : n_state = (addr >= 13'h1F7F) ? finish : (((count == 8'h80) & (addr[7:0] == 8'h7F)) ? bound : ((count == 8'h80) ? not_bound : r_second));
			bound : n_state = (addr[7:0] == 8'hFE) ? r_next : not_bound;
			not_bound : n_state = write_out;
			write_out : n_state = (addr >= 13'h1F7F) ? finish : (((addr[7:0] == 8'h7F) | (addr[7:0] == 8'hFD)) ? bound : not_bound);
			r_next : n_state = (count == 8'h80) ? r_second : r_next;
			finish : n_state = finish;
		endcase
	end
	
	always @(posedge clk) begin
		state <= (rst) ? init : (ready) ? n_state : state;
	end
	
	always @(posedge clk) begin
		if (rst) begin
			count <= 8'h00;
			req <= 1'b1;
			addr <= 13'h1FFF;
			done <= 1'b0;
			wen <= 1'b0;
		end else if (ready) begin
			case(state)
				r_first : begin
					line1[count] <= in_data;
					data_wr <= in_data;
					count <= (count == 8'h80) ? 8'h00 : count + 8'h01;
					wen <= (count == 8'h80) ? 1'b0 : 1'b1;
					req <= (count == 8'h80) ? 1'b1 : 1'b0;
					addr <= (count < 8'h80) ? addr + 13'h0001 : addr;
				end
				r_second : begin
					req <= 1'b0;
					line2[count] <= in_data;
					count <= (count == 8'h80) ? 8'h00 : count + 8'h01;
				end
				bound : begin
					wen <= 1'b1;
					addr <= addr + 13'h0001;
					data_wr <= (({1'b0, line1[addr[7:0] - 8'h7F]} + {1'b0, line2[addr[7:0] - 8'h7F]}) >> 1);
				end
				not_bound : begin
					d1 <= (line1[addr[7:0] - 8'h80] >= line2[addr[7:0] - 8'h7E]) ? line1[addr[7:0] - 8'h80] - line2[addr[7:0] - 8'h7E] : line2[addr[7:0] - 8'h7E] - line1[addr[7:0] - 8'h80];
					d2 <= (line1[addr[7:0] - 8'h7F] >= line2[addr[7:0] - 8'h7F]) ? line1[addr[7:0] - 8'h7F] - line2[addr[7:0] - 8'h7F] : line2[addr[7:0] - 8'h7F] - line1[addr[7:0] - 8'h7F];
					d3 <= (line1[addr[7:0] - 8'h7E] >= line2[addr[7:0] - 8'h80]) ? line1[addr[7:0] - 8'h7E] - line2[addr[7:0] - 8'h80] : line2[addr[7:0] - 8'h80] - line1[addr[7:0] - 8'h7E];
				end
				write_out : begin
					wen <= 1'b1;
					addr <= addr + 13'h0001;
					if ((d2 <= d1) & (d2 <= d3))
						data_wr <= (({1'b0, line1[addr[7:0] - 8'h7F]} + {1'b0, line2[addr[7:0] - 8'h7F]}) >> 1);
					else if ((d1 <= d2) & (d1 <= d3))
						data_wr <= (({1'b0, line1[addr[7:0] - 8'h80]} + {1'b0, line2[addr[7:0] - 8'h7E]}) >> 1);
					else
						data_wr <= (({1'b0, line1[addr[7:0] - 8'h7E]} + {1'b0, line2[addr[7:0] - 8'h80]}) >> 1);
				end
				r_next : begin
					line1[count] <= line2[count];
					data_wr <= line2[count];
					count <= (count == 8'h80) ? 8'h00 : count + 8'h01;
					wen <= (count == 8'h80) ? 1'b0 : 1'b1;
					req <= (count == 8'h80) ? 1'b1 : 1'b0;
					addr <= (count < 8'h80) ? addr + 13'h0001 : addr;
				end
				finish : begin
					wen <= 1'b0;
					done <= 1'b1;
				end
			endcase
		end
	end

endmodule