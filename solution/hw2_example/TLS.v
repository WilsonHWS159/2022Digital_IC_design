module TLS(clk, reset, set, stop, jump, G_in, Y_in, R_in, G_out, Y_out, R_out);
input           clk;
input           reset;
input           set;
input           stop;
input           jump;
input     [3:0] G_in;
input     [3:0] Y_in;
input     [3:0] R_in;
output reg      G_out;
output reg      Y_out;
output reg      R_out;

reg       [2:0] curt_state;
reg       [2:0] next_state;
reg       [3:0] G_sec;
reg       [3:0] Y_sec;
reg       [3:0] R_sec;
reg       [3:0] count_G;
reg       [3:0] count_Y;
reg       [3:0] count_R;
parameter [1:0] green = 0, yellow = 1, red = 2;

// next state logic
always@(*) begin
    if(set) begin
	    next_state = green;
	end
	else begin
	    case(curt_state)
			green  : next_state = (jump)? red : ((count_G == G_sec) && (stop == 0))? yellow : green;
			yellow : next_state = (jump)? red : ((count_Y == Y_sec) && (stop == 0))? red    : yellow;
			red    : next_state = ((count_R == R_sec) && (stop == 0))? green  : red;
			default: next_state = green;
	    endcase
	end
end

always@(posedge clk or posedge reset) begin
    if(reset) begin
		curt_state <= green;
	    count_G <= 1;
		count_Y <= 1;
		count_R <= 1;
	end
	else begin
		curt_state <= next_state;
		if(set) begin
			G_sec <= G_in;
			Y_sec <= Y_in;
			R_sec <= R_in;
			count_G <= 1;
			count_Y <= 1;
			count_R <= 1;
		end			
		else begin
		    case(curt_state)
				green  : count_G <= (stop == 1)? count_G : ((count_G == G_sec) || (jump == 1))? 1 : count_G + 1;
				yellow : count_Y <= (stop == 1)? count_Y : ((count_Y == Y_sec) || (jump == 1))? 1 : count_Y + 1;
				red    : count_R <= (stop == 1)? count_R : ((count_R == R_sec))? 1 : count_R + 1;
			endcase
		end
	end
end

// output logic
always@(*) begin
    case(curt_state)
		green  : begin
		    G_out = 1;
			Y_out = 0;
			R_out = 0;
        end		
		yellow : begin
		    G_out = 0;
			Y_out = 1;
			R_out = 0;
        end		
		red    : begin
		    G_out = 0;
			Y_out = 0;
			R_out = 1;
        end		
		default: begin
		    G_out = 0;
			Y_out = 0;
			R_out = 0;
		end
	endcase
end

endmodule