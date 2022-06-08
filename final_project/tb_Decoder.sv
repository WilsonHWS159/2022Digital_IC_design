`timescale 1ns/10ps
`define	CYCLE      5.0				// Modify your clock period here
`define	End_CYCLE  10000000			// Modify cycle times once your design need more cycle times!

`define	PAT		       "./img0/testdata_decoder.dat"
`define DECODE_OUT     "./img0/decode_result.raw"
`define INTERP_OUT     "./img0/interp_result.raw"

module testfixture_decoder;

reg clk;
reg reset;
reg decode_ready;
reg interp_ready;

reg [7:0] pat_mem [0:4095];
integer pat_cnt;

integer f_decode;
integer f_interp;
integer out_index;

initial begin
	#0;
	clk	= 1'b0;
	reset = 1'b0;
end

always begin
	#(`CYCLE/2) clk = ~clk;
end

initial
begin
    $display("----------------------------------------------------");
    $display("-                 Simulation Start                 -");
    $display("----------------------------------------------------");
    @(posedge clk); #1; reset = 1'b1; 
    #(`CYCLE*2);  
    @(posedge clk); #1; reset = 1'b0;
end

// ====================================================================
//  Decoder                                                           
// ====================================================================
reg [4:0] code_pos;
reg [4:0] code_len;
reg [7:0] chardata;
wire encode;
wire finish;
wire [7:0] char_nxt;

LZ77_Decoder u_LZ77_Decoder ( 
    .clk(clk),
    .reset(reset),
    .ready(decode_ready),
    .code_pos(code_pos),
    .code_len(code_len),
    .chardata(chardata),
    .encode(encode),
    .finish(finish),
    .char_nxt(char_nxt)
    );

integer linedata;
integer char_count;
string data;
string strdata;

// Open file of encoded image data
initial
begin
    linedata = $fopen(`PAT,"r");
    if(linedata == 0)
    begin
        $display ("pattern handle null");
        $finish;
    end
    pat_cnt = 0;
    decode_ready = 1;
    interp_ready = 0;
end

// Check the decoding results
integer strindex;
integer decode_num;
integer decode_cnt;
integer decode_err;

reg [7:0] gold_char_nxt;
reg [7:0] gold_char_nxt_fin;
reg wait_valid;
reg [7:0] get_char_nxt;

integer allpass = 1;
always@(negedge clk)
begin

    if(reset) begin
        wait_valid=0;
        decode_err = 0;
    end
    else
    begin
        if(wait_valid && !finish)
        begin
            decode_num = decode_num + 1;
            if(decode_num == strdata.len())
                wait_valid = 0;

            get_char_nxt = char_nxt;
            if(!(gold_char_nxt_fin==8'h24 && code_pos==0 && code_len==0) && !finish) begin
                if (!encode)
                begin
                    if(get_char_nxt !== gold_char_nxt)
                    begin
                        allpass = 0;
                        decode_err = decode_err+1;
                        $display("cycle %5h, failed to decode %s, expect %h, get %h >> Fail",cycle,strdata,gold_char_nxt[3:0],get_char_nxt[3:0]);
                    end
                    else begin
                        $display("cycle %5h, expect %h, get %h >> Pass",cycle,gold_char_nxt[3:0],get_char_nxt[3:0]); 
                    end

                    // Save decoded image data to pattern memory
                    if(pat_cnt[0]) // Lower part
                    begin
                        pat_mem[pat_cnt[12:1]][3:0] = get_char_nxt;
                    end
                    else // Higher part
                    begin
                        pat_mem[pat_cnt[12:1]][7:4] = get_char_nxt;
                    end
                    pat_cnt = pat_cnt + 1;
                end
                else begin
                    allpass = 0;
                    decode_err = decode_err+1;
                    $display("cycle %5h, expect decoding, but encode signal not low >> Fail",cycle);
                end
                
                strindex = strindex + 1;
                gold_char_nxt = strdata.substr(strindex, strindex).atohex();
            end
            else begin
                wait_valid = 0;
            end
        end
        else if(wait_valid && finish)begin
            if(gold_char_nxt_fin==8'h24 && code_pos==0 && code_len==0) begin
                wait_valid = 0;
            end
        end
    end

end

// Read encoded image data
always @(negedge clk ) begin
    if (reset) begin
        char_count = 0;
    end 
    else begin
        if (!wait_valid && decode_ready)
        begin
            if (!$feof(linedata))
            begin
                if (!finish)
                begin
                    char_count = $fgets(data, linedata);
                end
                else
                begin
                    char_count = $fgets(data, linedata);
                    char_count = 0;
                end

                if (char_count !== 0)
                begin
                    if (data.substr(0,6) == "decode:")
                    begin
                        wait_valid = 1;
                        strindex = 0;
                        decode_num = 0;
                        //strdata = data.substr(13,data.len() - 2);
                        //gold_char_nxt = strdata.substr(strindex, strindex).atohex();

                        if(data.getc(8)==8'h3A) begin
                            if(data.getc(10)==8'h3A) begin
                                strdata = data.substr(13,data.len() - 2);
                                gold_char_nxt = strdata.substr(strindex, strindex).atohex();

                                code_pos = data.substr(7,7).atoi();
                                code_len = data.substr(9,9).atoi();
                                gold_char_nxt_fin = data.getc(11);
                                chardata = data.substr(11, 11).atohex();
                            end
                            else begin
                                strdata = data.substr(14,data.len() - 2);
                                gold_char_nxt = strdata.substr(strindex, strindex).atohex();

                                code_pos = data.substr(7,7).atoi();
                                code_len = data.substr(9,10).atoi();
                                gold_char_nxt_fin = data.getc(12);
                                chardata = data.substr(12, 12).atohex();
                            end
                        end
                        else begin
                            if(data.getc(11)==8'h3A) begin
                                strdata = data.substr(14,data.len() - 2);
                                gold_char_nxt = strdata.substr(strindex, strindex).atohex();

                                code_pos = data.substr(7,8).atoi();
                                code_len = data.substr(10,10).atoi();
                                gold_char_nxt_fin = data.getc(12);
                                chardata = data.substr(12, 12).atohex();
                            end
                            else begin
                                strdata = data.substr(15,data.len() - 2);
                                gold_char_nxt = strdata.substr(strindex, strindex).atohex();

                                code_pos = data.substr(7,8).atoi();
                                code_len = data.substr(10,11).atoi();
                                gold_char_nxt_fin = data.getc(13);
                                chardata = data.substr(13, 13).atohex();
                            end
                        end

                        decode_cnt = decode_cnt + 1;

                        if(gold_char_nxt_fin==8'h24) begin
                            chardata = gold_char_nxt_fin;
                        end

                        if(!(gold_char_nxt_fin==8'h24 && code_pos==0 && code_len==0)) begin
                            // chardata = gold_char_nxt_fin;
                            $display("  == Decoding string \"%s\"", strdata);
                        end
                    end

                end

            end
            else
            begin
                if(finish) begin
                    if(allpass == 1) begin
                        $display("---------------------------------------------------------");
                        // $display("-- Simulation finish, ALL PASS  --");
                        if(decode_err == 0) begin
                            $display("-------------- Decoding finished, ALL PASS --------------"); 
                        end
                        $display("---------------------------------------------------------");
                    end
                    else begin
                        $display("-----------------------------------------------");
                        $display("-- Simulation finish");
                        
                        if(decode_err != 0) begin
                            $display("----- Decoding failed, There are %d errors", decode_err); 
                        end
                        $display("-----------------------------------------------");
                        $finish;
                    end
                    $fclose(linedata);
                    decode_ready = 0;
                    interp_ready = 1;
                    pat_cnt = 0;
                    f_decode = $fopen(`DECODE_OUT, "wb");
                    for(out_index = 0; out_index < 4096; out_index = out_index + 1)
                    begin
                        $fwrite(f_decode, "%c", pat_mem[out_index]);
                    end
                    $fclose(f_decode);
                end
            end
        end

    end
end

// ====================================================================
//  Line Interpolation Module                                                           
// ====================================================================
wire req;
reg	[7:0] in_data;
wire wen; // 0 read 1 write
wire [12:0] addr;
wire [7:0] data_wr;
reg	[7:0] data_rd;
wire interp_finish;
reg	startInput;

integer     p0, p1, p2;
integer     err_odd, err_even_edge, err_even_middle;
integer     i, j;

ELA u_ela(
    .clk(clk),
	.rst(reset),
    .ready(interp_ready),
	.req(req),
	.in_data(in_data),
    .wen(wen),
	.addr(addr),
    .data_wr(data_wr),
    .data_rd(data_rd),
    .done(interp_finish)
    );

reg	[7:0] result_image_mem[0:8063];

initial begin
    #0;
    in_data         = 8'hzz;
    data_rd         = 8'hzz;
    err_odd         = 0;
    err_even_edge   = 0;
    err_even_middle = 0;
    startInput      = 1'b0;

    i               = 0;
    j               = 0;
end

// Input decoded pattern to ELA module
always @ (*) begin
    if(interp_ready) begin
        startInput = (req) ? 1'b1: (pat_cnt[6:0] == 0) ? 1'b0:1'b1;
    end
    else begin
        startInput = 1'b0;
    end
        
end

always @ (negedge clk) begin
    if(interp_ready && !reset) begin
        if (startInput) begin
            in_data <= pat_mem[pat_cnt];
            pat_cnt <= pat_cnt + 1;
        end
        else begin
            in_data <= 8'hx;            
        end
    end
end

// Control Read/Write operations of result memory
always @ (posedge clk) begin
    if (wen == 1) begin
        result_image_mem[addr] <= data_wr; 
    end
end
always @ (negedge clk) begin
    if (wen == 0) begin
        data_rd <= result_image_mem[addr] ;
    end
end

// Write out interpolation result after done signal is pulled up
initial begin
    wait(interp_ready);
    wait(interp_finish);
    f_interp = $fopen(`INTERP_OUT, "wb");
    for(out_index = 0; out_index < 8064; out_index = out_index + 1)
    begin
        $fwrite(f_interp, "%c", result_image_mem[out_index]);
    end
    $fclose(f_interp);
    $display("---------------------------------------------------------");
    $display("----- Interpolation finished, result is written out -----");
    $display("---------------------------------------------------------");
            
    #(`CYCLE/2);
    $finish;
end

// Handle end-cycle exceeding situation
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

endmodule