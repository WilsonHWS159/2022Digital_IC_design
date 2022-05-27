module interpolate(boundary, a, b, c, d, e, f, result);
input				boundary;
input		[7:0]	a, b, c, d, e, f;
output	reg	[7:0]	result;

	reg		[7:0]	p1, p2, d1, d2, d3, d11, d12, d21, d22, d31, d32;
	reg		[8:0]	tmp;

	always @(*) begin
		d1 = d11 - d12;
		d2 = d21 - d22;
		d3 = d31 - d32;
		tmp = p1 + p2;
		result = tmp[8:1];
	end
	
	always @(*) begin
		if (a > f) begin
			d11 = a;
			d12 = f;
		end else begin
			d11 = f;
			d12 = a;
		end
		
		if (b > e) begin
			d21 = b;
			d22 = e;
		end else begin
			d21 = e;
			d22 = b;
		end
		
		if (c > d) begin
			d31 = c;
			d32 = d;
		end else begin
			d31 = d;
			d32 = c;
		end
	end
	
	always @(*) begin
		if (boundary) begin
			p1 = b;
			p2 = e;
		end else if ((d3 < d1) & (d3 < d2)) begin
			p1 = c;
			p2 = d;
		end else if (d1 < d2) begin
			p1 = a;
			p2 = f;
		end else begin
			p1 = b;
			p2 = e;
		end
	end
	
endmodule