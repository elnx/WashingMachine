module get_time(
	i_time,
	o_minute,
	o_second,
	o_second_p,
);

input [15:0] i_time;
output [7:0] o_minute;
output [7:0] o_second;
output [3:0] o_second_p;

reg [7:0] o_minute;
reg [7:0] o_second;
reg [3:0] o_second_p;

always @ (i_time) begin
	o_second_p <= i_time % 16'd10;
	o_minute <= i_time / 16'd600; 
	o_second <= (i_time - o_second_p - 10'd600 * o_minute) / 4'd10;
end

endmodule 