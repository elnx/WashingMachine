module display_time (
	clk,
	i_minute,
	i_second,
	i_second_p,
	i_twinkle,
	o_index_n, // select one from 4 dynamic dig
	o_seg_n, // 7 seg to show the number
	o_lsb // 7 seg to show the lsb 
);

input i_twinkle;
input clk;
input [7:0] i_minute;
input [7:0] i_second;
input [3:0] i_second_p;
output [3:0] o_index_n; // 5 numbers from left to rignt
output [7:0] o_seg_n; // 7 segments and 1 point to show the number
output [6:0] o_lsb;

reg [31:0] clk_1Hz_count;
reg [7:0] twinkle_count;
reg [2:0] scan_count;
reg [3:0] number;
reg [7:0] seg; // a,b,c,d,e,f,g,p 
reg [3:0] index;
reg [6:0] lsb;
reg [31:0] clk_50Hz_count;
reg clk_50Hz;

assign o_lsb = ~lsb;
assign o_seg_n = ~seg;
assign o_index_n = ~index;

always @ (i_second_p) begin
	case (i_second_p)
		4'd0: lsb = 7'b1111110; // 0
		4'd1: lsb = 7'b0110000; // 1
		4'd2: lsb = 7'b1101101; // 2
		4'd3: lsb = 7'b1111001; // 3
		4'd4: lsb = 7'b0110011; // 4
		4'd5: lsb = 7'b1011011; // 5
		4'd6: lsb = 7'b1011111; // 6
		4'd7: lsb = 7'b1110000; // 7
		4'd8: lsb = 7'b1111111; // 8
		4'd9: lsb = 7'b1111011; // 9
		default: lsb = 7'b0000000;
	endcase
end

always @ (posedge clk_50Hz) begin

	if (scan_count == 3'd3) begin
		scan_count <= 3'd0;
	end else begin
		scan_count <= scan_count + 3'd1;
	end

	case (scan_count) 
		3'd0: begin
			index <= 4'b0001;
			number <= i_second % 8'd10; 
		end
		3'd1: begin
			index <= 4'b0010;
			number <= i_second / 8'd10;
		end
		3'd2: begin
			index <= 4'b0100;
			number <= i_minute % 8'd10;
		end
		3'd3: begin
			index <= 4'b1000;
			number <= i_minute / 8'd10;
		end
	endcase
	
	
end

always @ (index) begin
	case (number)
		4'd0: seg[7:1] = 7'b1111110; // 0
		4'd1: seg[7:1] = 7'b0110000; // 1
		4'd2: seg[7:1] = 7'b1101101; // 2
		4'd3: seg[7:1] = 7'b1111001; // 3
		4'd4: seg[7:1] = 7'b0110011; // 4
		4'd5: seg[7:1] = 7'b1011011; // 5
		4'd6: seg[7:1] = 7'b1011111; // 6
		4'd7: seg[7:1] = 7'b1110000; // 7
		4'd8: seg[7:1] = 7'b1111111; // 8
		4'd9: seg[7:1] = 7'b1111011; // 9
	endcase
	if (!i_twinkle)
		seg[0] = index[0] ? 1'b1: 1'b0;
	else 
		seg[0] = index[0] ? clk_1Hz: 1'b0;
end


always @ (posedge clk) begin
	clk_50Hz_count <= clk_50Hz_count + 1;
	if (clk_50Hz_count == 32'd47999) 
		clk_50Hz <= 1;
	else if (clk_50Hz_count == 32'd95999) begin
		clk_50Hz <= 0;
		clk_50Hz_count <= 0;
	end

end

always @ (posedge clk) begin
	clk_1Hz_count <= clk_1Hz_count + 1;
	if (clk_1Hz_count == 32'd1199999) 
		clk_1Hz <= 1'b1;
	else if (clk_1Hz_count == 32'd2399999) begin
		clk_1Hz <= 1'b0;
		clk_1Hz_count <= 0;
	end
end
reg clk_1Hz;

endmodule 