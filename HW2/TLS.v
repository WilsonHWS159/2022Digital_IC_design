module TLS(clk, reset, Set, Stop, Jump, Gin, Yin, Rin, Gout, Yout, Rout);
input           clk;
input           reset;
input           Set;
input           Stop;
input           Jump;
input     [3:0] Gin;
input     [3:0] Yin;
input     [3:0] Rin;
output reg      Gout;
output reg      Yout;
output reg      Rout;

	reg [3:0] G_time, Y_time, R_time, Time, counter;
	reg [1:0] state;
	
	always @(posedge Set) begin
		G_time = Gin;
		Y_time = Yin;
		R_time = Rin;
	end
	/*
	always @(posedge Jump) begin
		Time = R_time;
		state = 2'b10;
	end
	*/
	always @(posedge clk) begin
		if (Stop) 
			counter <= counter;
		else if (Jump)
			counter <= Time - 1;
		else if (counter)
			counter <= counter - 1;
		else
			counter <= Time - 1;
	end
	
	always @(posedge clk) begin
		if (~Stop) begin
			case (state)
				default: state = 2'b00;
				2'b00: begin
					Gout = 1'b1;
					Yout = 1'b0;
					Rout = 1'b0;
				end
				2'b01: begin
					Gout = 1'b0;
					Yout = 1'b1;
					Rout = 1'b0;
				end
				2'b10: begin
					Gout = 1'b0;
					Yout = 1'b0;
					Rout = 1'b1;
				end
			endcase
		end
	end
	
	always @(*) begin
		if (Set | reset) begin
			Time = G_time;
			state = 2'b00;
		end else if (Jump) begin
			state = 2'b10;
			Time = R_time;
		end else if (!counter) begin
			case (state)
				default: state = 2'b00;
				2'b00: begin
					state = 2'b01;
					Time = Y_time;
				end
				2'b01: begin
					state = 2'b10;
					Time = R_time;
				end
				2'b10: begin
					state = 2'b00;
					Time = G_time;
				end
			endcase
		end
	end
	
	

endmodule