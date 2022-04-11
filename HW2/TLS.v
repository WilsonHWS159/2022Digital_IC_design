module TLS(
input           clk, reset, Set, Stop, Jump,
input     [3:0] Gin, Yin, Rin,
output reg      Gout, Yout, Rout);
	
	parameter [1:0] G = 2'b00, Y = 2'b01, R = 2'b10;
	reg [3:0] G_time, Y_time, R_time, G_counter, Y_counter, R_counter;
	reg [1:0] state, n_state;
	
	always @(*) begin
		if (Set)
			n_state = G;
		else begin
			case (state)
				default : n_state = G;
				G : n_state = Jump ? R : (!G_counter & ~Stop) ? Y : G;
				Y : n_state = Jump ? R : (!Y_counter & ~Stop) ? R : Y;
				R : n_state = (!R_counter & ~Stop) ? G : R;
			endcase
		end
	end
	
	always @(posedge Set or posedge reset) begin
		if (Set) begin
			G_time <= Gin;
			Y_time <= Yin;
			R_time <= Rin;
		end else begin
			G_time <= G_time;
			Y_time <= Y_time;
			R_time <= R_time;
		end
	end
	
	always @(posedge clk) begin
		state <= n_state;
		if (Set | reset) begin
			G_counter <= G_time - 4'h1;
			Y_counter <= Y_time - 4'h1;
			R_counter <= R_time - 4'h1;
		end else begin
			case (state)
				G : G_counter <= Stop ? G_counter : (!G_counter | Jump) ? G_time - 4'h1 : G_counter - 4'h1;
				Y : Y_counter <= Stop ? Y_counter : (!Y_counter | Jump) ? Y_time - 4'h1 : Y_counter - 4'h1;
				R : R_counter <= Stop ? R_counter : !R_counter ? R_time - 4'h1 : R_counter - 4'h1;
			endcase
		end
	end
	
	always @(*) begin
		case (state)
			G : begin
				Gout = 1'b1;
				Yout = 1'b0;
				Rout = 1'b0;
			end
			Y : begin
				Gout = 1'b0;
				Yout = 1'b1;
				Rout = 1'b0;
			end
			R : begin
				Gout = 1'b0;
				Yout = 1'b0;
				Rout = 1'b1;
			end
			default : begin
				Gout = 1'b0;
				Yout = 1'b0;
				Rout = 1'b0;
			end
		endcase
	end
endmodule