//-------------------------------------------------------------------
// Title       : timer
// Author      : WANG Zhenghe
// Created     : 2015-10-16 10:29:40
// Modified    : 2015-10-16 11:20:46
// Description : The time counter module for the washing machine.
//-------------------------------------------------------------------  

module timer(
	clk,
	rst_n,
	i_start,
	i_acc,
	i_state,
	i_step,
	o_response,
	o_time
);

input clk;
input rst_n;
input i_acc;
input [1:0] i_step;
input i_start;
input [15:0] i_state; // time to count
output [3:0] o_response;
output [15:0] o_time;

reg [3:0] o_response;
reg [15:0] temp_time;
reg [15:0] o_time;
reg [31:0] counter;
reg [31:0] counter_end;
reg clk_reg;

reg [31:0] clk_10Hz_count;
reg [31:0] clk_100Hz_count;
reg clk_100Hz;
reg clk_10Hz;

always @ (posedge clk) begin
	if (i_acc) begin
		clk_reg <= clk_100Hz;
	end else begin
		clk_reg <= clk_10Hz;
	end
end

always @ (posedge clk_reg or negedge rst_n) begin
	if (!rst_n) begin
		o_time <= 0;
		o_response <= 4'b0;
	end else begin
		if (i_start) begin
			o_time <= o_time + 16'd1;
			temp_time <= temp_time + 16'd1;
			if (temp_time < i_state) begin	
				temp_time <= temp_time + 16'd1;
			end else begin
				temp_time <= 16'd0;
				o_time <= 0;
				o_response[i_step] <= 1'b1;
			end
		end else begin
			o_time <= 0;
			temp_time <= 16'd0;
		end
	end

end

always @ (posedge clk) begin
	clk_10Hz_count <= clk_10Hz_count + 1;
	if (clk_10Hz_count == 32'd1199999) 
		clk_10Hz <= 1'b1;
	else if (clk_10Hz_count == 32'd2399999) begin
		clk_10Hz <= 1'b0;
		clk_10Hz_count <= 0;
	end

end


always @ (posedge clk) begin
	clk_100Hz_count <= clk_100Hz_count + 1;
	if (clk_100Hz_count == 32'd119999) 
		clk_100Hz <= 1;
	else if (clk_100Hz_count == 32'd239999) begin
		clk_100Hz <= 0;
		clk_100Hz_count <= 0;
	end
end

endmodule 