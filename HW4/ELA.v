`timescale 1ns/10ps

module ELA(clk, rst, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output reg			req;
	output reg			wen;
	output reg	[9:0]	addr;
	output		[7:0]	data_wr;
	output reg			done;

	reg [7:0] image[31:0][15:0];
	reg [7:0] i_image[31:0][14:0];
	reg [15:0] image_bm;
	reg [4:0] col_id;
	reg [3:0] row_id, i_row_id;
	parameter [1:0] executing = 2'b00, output_image = 2'b01, finish = 2'b11;
	reg [1:0] n_state, state;
	reg r_done, flag, hold, sel;
	
	always @(*) begin
		if (rst)
			n_state = executing;
		else begin
			case (state)
				executing : n_state = (~|(i_row_id ^ 4'hE) & (&col_id)) ? output_image : executing;
				output_image : n_state = ~|(addr ^ 10'h3DF) ? finish : output_image;
				finish : n_state = finish;
				default : n_state = n_state;
			endcase
		end
	end

	always @(posedge clk) begin
		state <= n_state;
		if (rst) begin
			image_bm <= 16'h0000;
			req <= 1'b0;
			wen <= 1'b0;
			done <= 1'b0;
			row_id <= 4'hF;
			col_id <= 5'h00;
			r_done <= 1'b0;
			addr <= 10'h000;
			flag <= 1'b0;
		end else begin
			case (state)
				executing : begin
					if (r_done) begin
						col_id <= flag ? col_id + 5'h01 : col_id;
						flag <= 1'b1;
					end else if (~(|col_id) & ~req) begin
						row_id <= row_id + 4'h1;
						req <= 1'b1;
					end else begin
						req <= 1'b0;
						image[col_id][row_id] <= in_data;
						col_id <= col_id + 5'h01;
						image_bm[row_id] <= (&col_id) ? 1'b1 : 1'b0;
						r_done <= ((&row_id) & (&col_id)) ? 1'b1 : 1'b0;
					end
				end
				output_image : begin
					if (hold) begin
						addr <= addr + 10'h001;
						col_id <= col_id + 5'h01;
						if (&(col_id)) begin
							sel <= sel ^ 1'b1;
							row_id <= sel ? row_id : row_id + 4'h1;
						end
					end else begin
						row_id <= 4'h0;
						col_id <= 5'h00;
						sel <= 1'b1;
						wen <= 1'b1;
					end
				end
				finish : begin
					done <= 1'b1;
					wen <= 1'b0;
				end
			endcase
		end
	end
	
	wire [7:0] a, b, c, d , e, f, result;
	wire boundary;
	interpolate itp(.boundary(boundary), .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .result(result));
	assign a = image[col_id - 5'h01][i_row_id];
	assign b = image[col_id][i_row_id];
	assign c = image[col_id + 5'h01][i_row_id];
	assign d = image[col_id - 5'h01][i_row_id + 4'h1];
	assign e = image[col_id][i_row_id + 4'h1];
	assign f = image[col_id + 5'h01][i_row_id + 4'h1];
	assign boundary = (~|col_id) | (&col_id);
	assign data_wr = (sel) ? image[col_id][row_id] : i_image[col_id][row_id];
	
	always @(posedge clk) begin
		if (rst) begin
			i_row_id <= 4'hF;
			hold <= 1'b0;
		end else begin
			case(state)
				executing : begin
					if ((image_bm[4'h0]) & (image_bm[4'h1])) begin
						if (~|col_id & ~hold) begin
							hold <= 1'b1;
							i_row_id <= i_row_id + 4'h1;
						end else begin
							hold <= 1'b0;
							i_image[col_id][i_row_id] <= result;
						end
					end
				end
				output_image : hold <= hold ? hold : 1'b1;
			endcase
		end
	end

endmodule