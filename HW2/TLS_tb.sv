`timescale 1ns/10ps
`define CYCLE      50.0  
`define End_CYCLE  1000000
`define PAT        "./test_data_traffic_light.dat"
`define GOLDEN     "./golden_data_traffic_light.dat"

module testfixture();
integer fd;
integer fg;
integer charcount;
integer stage_1_pass=0;
integer stage_2_pass=0;
integer stage_3_pass=0;
integer stage_1_fail=0;
integer stage_2_fail=0;
integer stage_3_fail=0;
string line;

reg clk = 0;
wire G_out;
wire Y_out;
wire R_out;
reg reset =0;
reg set;
reg stop;
reg jump;
reg [3:0] G_sec;
reg [3:0] Y_sec;
reg [3:0] R_sec;

TLS u_TLS(
        .clk(clk),
        .reset(reset),
		.Set(set),
		.Stop(stop),
		.Jump(jump),
        .Gin(G_sec),
        .Yin(Y_sec),
		.Rin(R_sec),
        .Gout(G_out),
		.Yout(Y_out),
		.Rout(R_out)
        );

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
    $display("----------------------");
    $display("-- Simulation Start --");
    $display("----------------------");
    @(posedge clk);  #2  reset = 1'b1; 
    #(`CYCLE*2);  
    @(posedge clk);  #2  reset = 1'b0;
end

reg [22:0] cycle=0;

always @(posedge clk) begin
    cycle=cycle+1;
    if (cycle > `End_CYCLE) begin
        $display("--------------------------------------------------");
        $display("-- Failed waiting valid signal, Simulation STOP --");
        $display("--------------------------------------------------");
        $fclose(fd);
        $finish;
    end
end

initial begin
    fd = $fopen(`PAT,"r");
    if (fd == 0) begin
        $display ("pattern handle null");
        $finish;
    end
end

initial begin
    fg = $fopen(`GOLDEN,"r");
    if (fg == 0) begin
        $display ("golden handle null");
        $finish;
    end
end

reg get_G_out;
reg get_Y_out;
reg get_R_out;
reg golden_G_out;
reg golden_Y_out;
reg golden_R_out;
reg valid_reg;
integer setnum;
integer pass_reg;
integer fail_reg;
integer reset_flag;

always @(posedge clk ) begin
    if (reset) begin
        setnum = 1;
		fail_reg = 0;
		pass_reg = 0;
		reset_flag = 0; 
    end
    else begin
		if (valid_reg == 1) begin
			get_G_out = G_out;
			get_Y_out = Y_out;
			get_R_out = R_out;
			
			if(reset_flag == 1) begin
			    reset_flag = 0;
				fail_reg = 0;
				pass_reg = 0;
				setnum = setnum + 1;
			end
			
			if((get_G_out !== golden_G_out) || (get_Y_out !== golden_Y_out) || (get_R_out !== golden_R_out)) begin
			    fail_reg = fail_reg + 1;
			end
			else begin
			    pass_reg = pass_reg + 1;
			end
			
			if (set == 1) begin
			    if(setnum % 10 == 1 && setnum != 30) begin
					$display("--stage%0d simulation--\n",(setnum/10) + 1);
				end
				if (fail_reg == 0) begin
				    if(((setnum-1)/10) == 0) begin
					    stage_1_pass = stage_1_pass + 1; 
					end
					else if(((setnum-1)/10) == 1) begin
					    stage_2_pass = stage_2_pass + 1; 
					end
					else begin
					    stage_3_pass = stage_3_pass + 1; 
					end
					$display("Setting%0d: PASS\n",setnum);
				end
				else begin
					if(((setnum-1)/10) == 0) begin
					    stage_1_fail = stage_1_fail + 1; 
					end
					else if(((setnum-1)/10) == 1) begin
					    stage_2_fail = stage_2_fail + 1; 
					end
					else begin
					    stage_3_fail = stage_3_fail + 1; 
					end
					$display("Setting%0d: FAIL\n",setnum);
				end
				reset_flag = 1;
			end
		end
    end
end

always @(posedge clk ) begin
    if (reset) begin
	    valid_reg = 0;
	end
	else begin
	    valid_reg = (set) ? 1 : valid_reg;
	end
end

always @(negedge clk ) begin
    if (reset) begin
	    set = 0;
		stop = 0;
		jump = 0;
		G_sec = 0;
		Y_sec = 0;
		R_sec = 0;
        golden_G_out = 0;
		golden_Y_out = 0;
		golden_R_out = 0;
    end 
    else begin
        if (!$feof(fd)) begin
		    charcount = $fgets (line, fd);
			if (charcount != 0) begin
				charcount = $sscanf(line, "%d %d %d %d %d %d", set, stop, jump, G_sec, Y_sec, R_sec);
			    // $display("%d %d %d %d %d %d", set, stop, jump, G_sec, Y_sec, R_sec);
			end
			charcount = $fgets (line, fg);
			if (charcount != 0) begin
				charcount = $sscanf(line, "%d %d %d", golden_G_out, golden_Y_out, golden_R_out);
			    // $display("%d %d %d", golden_G_out, golden_Y_out, golden_R_out);
			end
        end //if (!$feof(fd)) begin
        else begin
             $fclose(fd);
             $fclose(fg);
             $display ("-------------------------------------------------");
             if(stage_1_fail == 0 && stage_2_fail == 0 && stage_3_fail == 0)
                 $display("--    Simulation finish,  ALL PASS             --");
             else begin
                 $display("--              Simulation finish              --");
				 $display("--       There are %2d errors in stage 1!       --", stage_1_fail);
				 $display("--       There are %2d errors in stage 2!       --", stage_2_fail);
				 $display("--       There are %2d errors in stage 3!       --", stage_3_fail);
		     end
             $display ("-------------------------------------------------");
             $finish;
        end
    end
end
endmodule
