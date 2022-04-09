module find_max(data_0, data_1, data_2, data_3, data_4, data_5, data_6, data_7, data_8, result);
input [4:0]	data_0, data_1, data_2, data_3, data_4, data_5, data_6, data_7, data_8;
output [4:0] result;

wire [4:0] tmp[6:0];

assign tmp[0] = (data_0 > data_1) ? data_0 : data_1;
assign tmp[1] = (data_2 > data_3) ? data_2 : data_3;
assign tmp[2] = (data_4 > data_5) ? data_4 : data_5;
assign tmp[3] = (data_6 > data_7) ? data_6 : data_7;
assign tmp[4] = (tmp[0] > tmp[1]) ? tmp[0] : tmp[1];
assign tmp[5] = (tmp[2] > tmp[3]) ? tmp[2] : tmp[3];
assign tmp[6] = (tmp[4] > tmp[5]) ? tmp[4] : tmp[5];
assign result = (tmp[6] > data_8) ? tmp[6] : data_8;

endmodule