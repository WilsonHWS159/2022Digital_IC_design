`timescale 1ns/10ps

// 2022 Digital IC Design
// Homework 4: Edge-Based Line Average interpolation

module ELA(clk, rst, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output				req;
	output				wen;
	output		[9:0]	addr;
	output		[7:0]	data_wr;
	output				done;
	reg  wen;
	reg  req;
	reg  done;
	reg [7:0]  data_wr;
	reg [9:0]  addr;

	reg [2:0]  curt_state;
	reg [2:0]  next_state;

	// two buffer to store the data
	reg [7:0]  data_line_1 [31:0];
	reg [7:0]  data_line_2 [31:0];
	reg [5:0]  counter_32;

	reg [7:0]  d1,d2,d3;

	// State Machine
	always @( * ) begin
		case ( curt_state )
			// initial			
			0 : 
			begin  
				next_state = 1;
			end
			// read first row
			1 : 
			begin            
				if ( counter_32 == 32 )          
					next_state = 2;
				else
					next_state = 1;
			end
			// read next row
			2 : 
			begin
				if( addr >= 991 )
					next_state = 6;
				else if ( counter_32 == 32 && addr[5:0] == 31)          
					next_state = 5;
				else if ( counter_32 == 32 )          
					next_state = 3;
				else
					next_state = 2;
			end
			// not boundary
			3 :
			begin
				next_state = 4;				
			end
			// write out data 
			4 :
			begin
				if( addr >= 991 )
					next_state = 6;
				else if( addr[5:0] == 31 || addr[5:0] == 61 )
					next_state = 5;
				else
					next_state = 3;
			end
			// boundary
			5 :
			begin				
				if( addr[5:0] == 62)
					next_state = 7;
				else
					next_state = 3;
			end
			// finish
			6 :
			begin
				next_state = 6;
			end
			//read next row
			7 :
			begin
				if ( counter_32 == 32 )          
					next_state = 2;
				else
					next_state = 7;
			end	
		endcase   
	end
	// Reset Signal
	always @(posedge clk or posedge rst ) begin
		if ( rst )
			curt_state <= 0;
		else
			curt_state <= next_state;  
	end
	// Datapath & Controlpath
	always @(posedge clk or posedge rst ) begin
		if ( rst )
		begin
			counter_32 <= 0;
			req <= 1;
			addr <= -1;
			done <= 0;
			wen  <= 0;
		end
		else
		begin
			case ( curt_state )
				// read first row
				1 : 
				begin    					 
					data_line_1[counter_32] <= in_data;					
					data_wr <= in_data;
					if ( counter_32 == 32 )
					begin
						counter_32 <= 0;
						wen <= 0; 
						req <= 1;
					end
					else
					begin
						counter_32 <= counter_32 + 1;
						wen <= 1; 
						req <= 0; 
					end					
					if ( counter_32 < 32 )
						addr <= addr + 1;
				end				
				// read next row			
				2 : 
				begin
					req <= 0;  
					data_line_2[counter_32] <= in_data;
					
					if ( counter_32 == 32 )
						counter_32 <= 0;
					else
						counter_32 <= counter_32 + 1;
				end
				// not boundary,calculate diff
				3 : 
				begin
					d1 <= data_line_1[addr[5:0] - 32] >= data_line_2[addr[5:0] - 30] ? data_line_1[addr[5:0] - 32] - data_line_2[addr[5:0] - 30] : data_line_2[addr[5:0] - 30] - data_line_1[addr[5:0] - 32];
					d2 <= data_line_1[addr[5:0] - 31] >= data_line_2[addr[5:0] - 31] ? data_line_1[addr[5:0] - 31] - data_line_2[addr[5:0] - 31] : data_line_2[addr[5:0] - 31] - data_line_1[addr[5:0] - 31];
					d3 <= data_line_1[addr[5:0] - 30] >= data_line_2[addr[5:0] - 32] ? data_line_1[addr[5:0] - 30] - data_line_2[addr[5:0] - 32] : data_line_2[addr[5:0] - 32] - data_line_1[addr[5:0] - 30];
				end
				// write out data 
				4 : 
				begin
					wen <= 1; 
					addr <= addr + 1;
					// the condition has priority，D2 > D1 > D3
					if ( ( d2 <= d1 ) & ( d2 <= d3 ) )
					begin
						data_wr  <= (( {1'b0,data_line_1[addr[5:0] - 31]} + {1'b0,data_line_2[addr[5:0] - 31]} ) >> 1);
					end
					else if ( ( d1 <= d2 ) & ( d1 <= d3 ) )
					begin
						data_wr  <= (( {1'b0,data_line_1[addr[5:0] - 32]} + {1'b0,data_line_2[addr[5:0] - 30]} ) >> 1);
					end					
					else
					// else if ( ( d3 <= d2 ) & ( d3 <= d1 ) )
					begin
						data_wr  <= (( {1'b0,data_line_1[addr[5:0] - 30]} + {1'b0,data_line_2[addr[5:0] - 32]} ) >> 1);						
					end		
				end
				// boundary
				5 :
				begin
					wen <= 1; 
					addr <= addr + 1;
					data_wr <= (( {1'b0,data_line_1[addr[5:0] - 31]} + {1'b0,data_line_2[addr[5:0] - 31]} ) >> 1 );
				end	
				// finish			
				6 :
				begin
					wen <= 0;					
					done <= 1;
				end
				//read next row
				7 : 
				begin
					
					data_line_1[counter_32] <= data_line_2[counter_32];
					data_wr <= data_line_2[counter_32];
					if ( counter_32 == 32 )
					begin
						counter_32 <= 0;
						wen <= 0; 
						req <= 1;
					end
					else
					begin
						req <= 0;  
						wen <= 1; 
						counter_32 <= counter_32 + 1;
					end
					
					if ( counter_32 < 32 )
						addr <= addr + 1;
				end	
			endcase  
		end
	end
endmodule