`timescale 1ns/10ps
`define CYCLE      50.0  
`define End_CYCLE  1000000
`define PAT        "./test_data.dat"
`define GOLDEN     "./golden_data.dat"

module testfixture();
integer fd;
integer fg;
integer charcount;
integer stage_1_pass=0;   // max
integer stage_2_pass=0;   // min
integer stage_3_pass=0;   // sort
integer stage_1_fail=0;
integer stage_2_fail=0;
integer stage_3_fail=0;
string line;

reg clk = 0;
reg reset = 0;
reg [2:0] value_num;
reg [7:0] value_in;
wire [10:0] result_out;

BOE u_BOE(
        .clk(clk),
		.rst(reset),
		.data_num(value_num),
		.data_in(value_in),
		.result(result_out)
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
		$fclose(fg);
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

reg [10:0] get_result_out;
reg [10:0] golden_out;
reg output_valid;
integer group_num;
integer group_cycle;
integer group_end_cycle;
integer count_out;
integer max_pass_reg;
integer max_fail_reg;
integer sum_pass_reg;
integer sum_fail_reg;
integer sort_pass_reg;
integer sort_fail_reg;
integer reset_flag;

always @(posedge clk ) begin
    if (reset) begin
        group_num = 1;
		group_cycle = 1;
		count_out = 1;
		max_fail_reg = 0;
		max_pass_reg = 0;
		sum_fail_reg = 0;
		sum_pass_reg = 0;
		sort_fail_reg = 0;
		sort_pass_reg = 0;
		reset_flag = 0; 
		group_end_cycle = 0;
    end
    else begin
		if(reset_flag == 1) begin
			reset_flag = 0;
			max_fail_reg = 0;
			max_pass_reg = 0;
			sum_fail_reg = 0;
			sum_pass_reg = 0;
			sort_fail_reg = 0;
			sort_pass_reg = 0;
			count_out = 1;
			group_num = group_num + 1;
			group_cycle = 1;
		end
		if (output_valid == 1) begin
			get_result_out = result_out;
			
			if((get_result_out !== golden_out)) begin
			    if(count_out == 1) begin
				    max_fail_reg = max_fail_reg + 1;
			    end
				else if(count_out == 2) begin
				    sum_fail_reg = sum_fail_reg + 1;
				end
				else begin
				    sort_fail_reg = sort_fail_reg + 1;
				end
			end
			else begin
			    if(count_out == 1) begin
				    max_pass_reg = max_pass_reg + 1;
			    end
				else if(count_out == 2) begin
				    sum_pass_reg = sum_pass_reg + 1;
				end
				else begin
				    sort_pass_reg = sort_pass_reg + 1;
				end
			end
			
			count_out = count_out + 1;
			
			if (group_cycle == group_end_cycle) begin
				if ((max_fail_reg == 0) && (sum_fail_reg == 0) && (sort_fail_reg == 0)) begin
					stage_1_pass = stage_1_pass + 1; 
					stage_2_pass = stage_2_pass + 1; 
					stage_3_pass = stage_3_pass + 1; 
					$display("Series %0d: PASS\n",group_num);
				end
				else begin
					if(max_fail_reg != 0) begin
					    stage_1_fail = stage_1_fail + 1;
					end
					else begin
					    stage_1_pass = stage_1_pass + 1;
                    end					
					if(sum_fail_reg != 0) begin
					    stage_2_fail = stage_2_fail + 1;
					end
					else begin
					    stage_2_pass = stage_2_pass + 1;
                    end	
					if(sort_fail_reg != 0) begin
					    stage_3_fail = stage_3_fail + 1;
					end
					else begin
					    stage_3_pass = stage_3_pass + 1;
                    end	
					$display("Series %0d: FAIL\n",group_num);
				end
				reset_flag = 1;
			end
			group_cycle = group_cycle + 1;
		end
		if (value_num != 0) begin
		    group_end_cycle = 2 + value_num;
		end
    end
end

always @(negedge clk ) begin
    if (reset) begin
	    value_num = 0;
		value_in  = 0;
        golden_out = 0;
		output_valid = 0;
    end 
    else begin
        if (!$feof(fd)) begin
		    charcount = $fgets (line, fd);
			if (charcount != 0) begin
				charcount = $sscanf(line, "%d %d", value_num, value_in);
			end
			charcount = $fgets (line, fg);
			if (charcount != 0) begin
				charcount = $sscanf(line, "%d %d", golden_out, output_valid);
			end
        end //if (!$feof(fd)) begin
        else begin
            $fclose(fd);
            $fclose(fg);
            $display ("-------------------------------------------------");
			$display("--          Stage 1 Simulation finish          --");
			if(stage_1_fail == 0) $display("--               stage 1  : PASS!              --");
			else $display("--       There are %2d errors in stage 1!       --", stage_1_fail);
			$display ("-------------------------------------------------");
			$display("--          Stage 2 Simulation finish          --");
			if(stage_2_fail == 0) $display("--               stage 2  : PASS!              --");
			else $display("--       There are %2d errors in stage 2!       --", stage_2_fail);
			$display ("-------------------------------------------------");
			$display("--          Stage 3 Simulation finish          --");
			if(stage_3_fail == 0) $display("--               stage 3  : PASS!              --");
			else $display("--       There are %2d errors in stage 3!       --", stage_3_fail);
            $display ("-------------------------------------------------");
            $finish;
        end
    end
end
endmodule
