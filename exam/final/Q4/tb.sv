`timescale 1ns/10ps
`define CYCLE      30.0  
`define End_CYCLE  1000000


`define PAT        "./testdata.dat"

module testfixture();

integer linedata;
integer char_count;
string data;
string strdata;
string gold_offset_str;
string gold_match_len_str;
string gold_char_nxt_str;

// ====================================================================
// I/O Pins                                                          //
// ====================================================================
reg clk = 0;
reg reset = 0;
reg code_valid = 0;
reg [3:0] code_pos;
reg [2:0] code_len;
reg [7:0] chardata;
wire valid;
wire encode;
wire busy;
wire [3:0] offset;
wire [2:0] match_len;
wire [7:0] char_nxt_in;
wire [7:0] char_nxt;

reg    encode_flag, chardata_flag;
reg    pos_encode_flag, pos_chardata_flag, pos_chardata_flag2;

assign  offset = (!pos_encode_flag) ? code_pos : 4'hz;
assign  match_len = (!pos_encode_flag) ? code_len : 3'hz;
assign  char_nxt_in = (!pos_chardata_flag) ? chardata : 8'hzz;


LZ77 u_LZE (.clk(clk),
           .reset(reset),
           .valid(valid),
           .encode(encode),
           .busy(busy),
           .offset(offset),
           .match_len(match_len),
           .chardata(char_nxt_in),
           .char_nxt(char_nxt)
           );


// ====================================================================
// Initialize                                                        //
// ====================================================================
always begin #(`CYCLE/2) clk = ~clk; end

initial
begin
    $display("----------------------");
    $display("-- Simulation Start --");
    $display("----------------------");
    @(posedge clk); #1; reset = 1'b1; 
    #(`CYCLE*2);  
    @(posedge clk); #1;   reset = 1'b0;
end

initial
begin
    linedata = $fopen(`PAT,"r");
    if(linedata == 0)
    begin
        $display ("pattern handle null");
        $finish;
    end
end


// ====================================================================
// Handle end-cycle exceeding situation                              //
// ====================================================================
reg [22:0] cycle=0;

always@(posedge clk)
begin
    cycle=cycle+1;
    if (cycle > `End_CYCLE)
    begin
        $display("--------------------------------------------------");
        $display("---------- Time Exceed, Simulation STOP ----------");
        $display("--------------------------------------------------");
        $fclose(linedata);
        $finish;
    end
end

always@(posedge clk) begin
    pos_encode_flag = encode_flag;
    pos_chardata_flag = chardata_flag;
end


// ====================================================================
// Check if answers correct                                          //
// ====================================================================
integer strindex;
integer decode_num;
integer encode_cnt;
integer decode_cnt;

integer pat_num;
integer encode1_err, encode2_err, encode3_err;
integer decode1_err, decode2_err, decode3_err;


reg [3:0] gold_offset;
reg [3:0] gold_match_len;
reg [7:0] gold_char_nxt;
reg [7:0] gold_char_nxt_fin;

reg encode_reg;
reg wait_valid;
reg [3:0] get_offset;
reg [3:0] get_match_len;
reg [7:0] get_char_nxt;
reg [3:0] buff_offset[0:2048];
reg [2:0] buff_match_len[0:2048];
reg [7:0] buff_char_nxt[0:2048];

reg [1:0] state;
reg [1:0] mode;

integer allpass=1;
always@(negedge clk)
begin

    if(reset) begin
        wait_valid=0;
        encode1_err = 0;
        encode2_err = 0;
        encode3_err = 0;
        decode1_err = 0;
        decode2_err = 0;
        decode3_err = 0;
    end
    else
    begin

        if(wait_valid && valid && busy)
        begin

            if(encode_reg) // Check encoding answer
            begin

                wait_valid = 0;
                get_offset = offset;
                get_match_len = match_len;
                get_char_nxt = char_nxt_in;
                // get_char_nxt = char_nxt;

                buff_offset[encode_cnt] = offset;
                buff_match_len[encode_cnt] = match_len;
                buff_char_nxt[encode_cnt] = char_nxt_in;
                // buff_char_nxt[encode_cnt] = char_nxt;
                encode_cnt = encode_cnt + 1;

                if (encode==1)
                begin
                    if ((get_offset === gold_offset) && (get_match_len === gold_match_len) && ((get_char_nxt === gold_char_nxt) || (gold_char_nxt_fin==8'h24 && get_char_nxt==8'h24))) begin
                        if(gold_char_nxt_fin == 8'h24 && get_char_nxt==8'h24) begin
                            $display("cycle %5h, expect(%h,%h,%c) , get(%h,%h,%c) >> Pass",cycle,gold_offset,gold_match_len,gold_char_nxt_fin,get_offset,get_match_len,get_char_nxt);
                        end
                        else begin
                            $display("cycle %5h, expect(%h,%h,%h) , get(%h,%h,%h) >> Pass",cycle,gold_offset,gold_match_len,gold_char_nxt[3:0],get_offset,get_match_len,get_char_nxt[3:0]);
                        end
                    end
                    else
                    begin
                        allpass = 0;
                        if(pat_num==1) begin
                            encode1_err = encode1_err+1;
                        end
                        else if(pat_num==2) begin
                            encode2_err = encode2_err+1;
                            
                        end
                        else if(pat_num==3) begin
                            encode3_err = encode3_err+1;
                        end
                        // encode_err = encode_err+1;
                        if(gold_char_nxt_fin == 8'h24 && get_char_nxt!=8'h24) begin
                            $display("cycle %5h, expect(%h,%h,%c) , get(%h,%h,%h) >> Fail",cycle,gold_offset,gold_match_len,gold_char_nxt_fin,get_offset,get_match_len,get_char_nxt[3:0]); 
                        end
                        else if(gold_char_nxt_fin != 8'h24 && get_char_nxt==8'h24) begin
                            $display("cycle %5h, expect(%h,%h,%h) , get(%h,%h,%c) >> Fail",cycle,gold_offset,gold_match_len,gold_char_nxt[3:0],get_offset,get_match_len,get_char_nxt); 
                        end
                        else begin
                            $display("cycle %5h, expect(%h,%h,%h) , get(%h,%h,%h) >> Fail",cycle,gold_offset,gold_match_len,gold_char_nxt[3:0],get_offset,get_match_len,get_char_nxt[3:0]); 
                        end
                    end
                end
                else begin
                    allpass = 0;
                    if(pat_num==1) begin
                        encode1_err = encode1_err+1;
                    end
                    else if(pat_num==2) begin
                        encode2_err = encode2_err+1;
                        
                    end
                    else if(pat_num==3) begin
                        encode3_err = encode3_err+1;
                    end
                    // encode_err = encode_err+1;
                    $display("cycle %5h, expect encoding, but encode signal is not high >> Fail",cycle);
                end

            end
            else // Check decoding answer
            begin                
                code_valid = 0;
                decode_num = decode_num + 1;
                
                if(decode_num == strdata.len()) begin
                    wait_valid = 0;
                end

                get_char_nxt = char_nxt;

                if (!encode)
                begin
                    if(get_char_nxt !== gold_char_nxt)
                    begin
                        allpass = 0;
                        // decode_err = decode_err+1;
                        if(pat_num==1) begin
                            decode1_err = decode1_err+1;
                        end
                        else if(pat_num==2) begin
                            decode2_err = decode2_err+1;
                            
                        end
                        else if(pat_num==3) begin
                            decode3_err = decode3_err+1;
                        end
                        $display("cycle %5h, failed to decode %s, expect %h, get %h >> Fail",cycle,strdata,gold_char_nxt[3:0],get_char_nxt[3:0]);
                    end
                    else begin
                        $display("cycle %5h, expect %h, get %h >> Pass",cycle,gold_char_nxt[3:0],get_char_nxt[3:0]); 
                    end
                end
                else begin
                    allpass = 0;
                    if(pat_num==1) begin
                        decode1_err = decode1_err+1;
                    end
                    else if(pat_num==2) begin
                        decode2_err = decode2_err+1;
                        
                    end
                    else if(pat_num==3) begin
                        decode3_err = decode3_err+1;
                    end
                    // decode_err = decode_err+1;
                    $display("cycle %5h, expect decoding, but encode signal not low >> Fail",cycle);
                end

                strindex = strindex + 1;
                gold_char_nxt = strdata.substr(strindex, strindex).atohex();
            end

        end

    end

end


// ====================================================================
// Read input string                                                 //
// ====================================================================
always @(negedge clk ) begin
    if (reset) begin
        encode_flag = 0;
        chardata_flag = 0;
        encode_reg = 1;
        pat_num = 0;
        state = 0;
        mode = 0;
    end 
    else begin

        if (!wait_valid)
        begin

            if (strindex < strdata.len() - 1)
            begin
                strindex = strindex + 1;
                if(strindex==strdata.len()-1) begin
                    chardata = strdata.getc(strindex);
                end
                else begin
                    chardata = strdata.substr(strindex, strindex).atohex();
                end
            end 
            else
            begin
                if (!$feof(linedata))
                begin

                    if (((decode_cnt != encode_cnt) && !((decode_cnt == encode_cnt - 1) && (buff_match_len[encode_cnt - 1] == 0) && (buff_char_nxt[encode_cnt - 1] == 8'h24))) || !busy)
                    begin
                        state = 1;
                        code_valid = 1;
                        char_count = $fgets(data, linedata);
                    end
                    else if ((decode_cnt == encode_cnt - 1) && (buff_match_len[encode_cnt - 1] == 0) && (buff_char_nxt[encode_cnt - 1] == 8'h24))
                    begin
                        state = 2;
                        code_valid = 1;
                        code_pos = 4'd0;
                        code_len = 4'd0;
                        chardata = 8'h24;
                        decode_cnt = decode_cnt + 1;
                        char_count = 0;
                    end
                    else
                    begin
                        state = 3;
                        code_valid = 0;
                        char_count = 0;
                    end

                    if (char_count !== 0)
                    begin

                        if(data.substr(0,6) == "images:")
                        begin
                            mode = 1;
                            encode_flag = 0;
                            chardata_flag = 0;
                            pat_num = pat_num+1;
                            code_valid = 1;
                            strindex = 0;
                            encode_cnt = 0;
                            decode_cnt = 0;
                            strdata = data.substr(7,data.len() - 2);
                            // $display("  __________________________________________________________");
                            $display("\n\n== Encoding Image %2d : \"%s\"\n", pat_num, strdata);
                            chardata = strdata.substr(strindex, strindex).atohex();
                            $display("== Encoding start ==",);
                        end 
                        else if (data.substr(0,6) == "encode:")
                        begin
                            mode = 2;
                            encode_flag = 1;
                            chardata_flag = 1;
                            wait_valid = 1;
                            code_valid = 0;
                            encode_reg = 1;
                            chardata = 8'h24; // String ending character
                            gold_offset = data.substr(7,7).atoi();
                            gold_match_len = data.substr(9,9).atoi();
                            gold_char_nxt = data.substr(11, 11).atohex();
                            gold_char_nxt_fin = data.getc(11);
                        end
                        else if (data.substr(0,6) == "decode:")
                        begin
                            mode = 3;
                            encode_flag = 0;
                            chardata_flag = 0;
                            wait_valid = 1;
                            encode_reg = 0;
                            strindex = 0;
                            decode_num = 0;
                            strdata = data.substr(7,data.len() - 2);
                            gold_char_nxt = strdata.substr(strindex, strindex).atohex();

                            code_valid = 1;
                            code_pos = buff_offset[decode_cnt];
                            code_len = buff_match_len[decode_cnt];
                            chardata = buff_char_nxt[decode_cnt];
                            decode_cnt = decode_cnt + 1;
                            $display("  == Decoding string \"%s\"", strdata);

                            // if(!(chardata==8'h24 && code_pos==0 && code_len==0)) begin
                            //     // chardata = gold_char_nxt_fin;
                            //     $display("  == Decoding string \"%s\"", strdata);
                            // end
                        end

                    end

                end
                else
                begin
                    if(allpass == 1) begin
                        $display("-----------------------------------------------");                        
                        $display("--             Simulation finish             --");
                        $display("--             IMAGES 1 All PASS             --"); 
                        $display("--             IMAGES 2 All PASS             --"); 
                        $display("--             IMAGES 3 All PASS             --"); 
                        $display("-----------------------------------------------");                        

                    end
                    else begin
                        $display("-----------------------------------------------");                        
                        // $display("-- Simulation finish                         --");
                        if(encode1_err==0) begin
                            $display("-- Simulation finish,  IMAGE 1 encoder pass  --"); 
                        end
                        else begin
                            $display("-- IMAGE 1 encoder has %11d errors    --", encode1_err); 
                        end

                        if(decode1_err==0) begin
                            $display("-- Simulation finish,  IMAGE 1 decoder pass  --"); 
                        end
                        else begin
                            $display("-- IMAGE 1 decoder has %11d errors    --", decode1_err); 
                        end

                        if(encode2_err==0) begin
                            $display("-- Simulation finish,  IMAGE 2 encoder pass  --"); 
                        end
                        else begin
                            $display("-- IMAGE 2 encoder has %11d errors    --", encode2_err); 
                        end

                        if(decode2_err==0) begin
                            $display("-- Simulation finish,  IMAGE 2 decoder pass  --"); 
                        end
                        else begin
                            $display("-- IMAGE 2 decoder has %11d errors    --", decode2_err); 
                        end

                        if(encode3_err==0) begin
                            $display("-- Simulation finish,  IMAGE 3 encoder pass  --"); 
                        end
                        else begin
                            $display("-- IMAGE 3 encoder has %11d errors    --", encode3_err); 
                        end  

                        if(decode3_err==0) begin
                            $display("-- Simulation finish,  IMAGE 3 decoder pass  --"); 
                        end
                        else begin
                            $display("-- IMAGE 3 decoder has %11d errors    --", decode3_err); 
                        end
                        $display("-----------------------------------------------");                        
                    end
                    $fclose(linedata);
                    $finish;
                end

            end

        end

    end
end

endmodule

