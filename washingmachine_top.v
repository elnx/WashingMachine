//-------------------------------------------------------------------
// Title       : washingmachine
// Author      : WANG Zhenghe
// Created     : 2015-10-16 09:37:53
// Modified    : 2015-10-16 12:38:53
// Description : A FPGA implement of a washing machine for my EE lab.
//-------------------------------------------------------------------  

`timescale 1 ns / 1 ps

module washingmachine_top (
	clk, 
	rst_n,
	i_start_n, 
	i_water_full_n, 
	i_acc_n,
	o_state,
	o_index_n,
	o_seg_n,
	o_lsb
);

input clk, rst_n; 
input i_start_n;
input i_acc_n;
input i_water_full_n;
output [5:0] o_state;
output [3:0] o_index_n;
output [7:0] o_seg_n;
output [6:0] o_lsb;

parameter IDLE	= 6'b000001;
parameter WATER	= 6'b000010;
parameter RINSE	= 6'b000100; 
parameter DRAIN	= 6'b001000; 
parameter DRY	= 6'b010000; 
parameter ALERT = 6'b100000;

parameter RINSE_TIME	= 16'd6000; // 10min -> 5min
parameter DRAIN_TIME	= 16'd300; // 30sec
parameter DRY_TIME		= 16'd3000; // 5min
parameter ALERT_TIME	= 16'd100; //10sec

reg [5:0] state;
reg timer_start;
reg [15:0] timer_state;
reg twinkle_start;
reg [1:0] step;
wire acc_wire;

wire [3:0] timer_done;
wire [15:0] time_wire;
wire [7:0] minute_wire;
wire [7:0] second_wire;
wire [3:0] second_p_wire;

assign o_state = ~state;
assign acc_wire = ~i_acc_n;

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		state <= IDLE;
		timer_start <= 1'b0;
		timer_state <= 0;
	end else begin
		case (state)
			IDLE: begin
				twinkle_start <= 1'b0;
				if (!i_start_n) begin
					state <= WATER;
					timer_start <= 0;
					timer_state <= 0;
				end else begin
					state <= IDLE;
					timer_start <= 0;
					timer_state <= 0;
				end
			end
			
			WATER: begin
				//twinkle_start <= 1'b0;
				if (!i_water_full_n) begin
					state <= RINSE;
					timer_start <= 1;
					timer_state <= RINSE_TIME;
					step <= 2'b00;
				end 
			end
			
			RINSE: begin
				//twinkle_start <= 1'b0;
				if (timer_done[0]) begin
					state <= DRAIN;
					timer_start <= 1;
					timer_state <= DRAIN_TIME;
					step <= 2'b01;
				end
			end
			
			DRAIN: begin
				//twinkle_start <= 1'b0;
				if (timer_done[1]) begin
					state <= DRY;
					timer_start <= 1;
					timer_state <= DRY_TIME;
					step <= 2'b10;
				end
			end
			
			DRY: begin
				//twinkle_start <= 1'b0;
				if (timer_done[2]) begin
					state <= ALERT;
					timer_start <= 1;
					timer_state <= ALERT_TIME;
					step <= 2'b11;
					
				end
			end
			
			ALERT: begin
				if (timer_done[3]) begin
					state <= IDLE;
					timer_start <= 0;
					timer_state <= 0;
				end else begin
					twinkle_start <= 1'b1;
				end
			end
			
			default: begin
				state <= IDLE;
				timer_start <= 0;
				timer_state <= 0;
			end
			
		endcase
	end
end		

timer t (
	.clk(clk),
	.rst_n(rst_n),
	.i_acc(acc_wire),
	.i_start(timer_start),
	.i_state(timer_state),
	.i_step(step),
	.o_response(timer_done),
	.o_time(time_wire)
);

get_time g (
	.i_time(time_wire),
	.o_minute(minute_wire),
	.o_second(second_wire),
	.o_second_p(second_p_wire),
);

display_time d (
	.clk(clk),
	.i_minute(minute_wire),
	.i_second(second_wire),
	.i_second_p(second_p_wire),
	.i_twinkle(twinkle_start),
	.o_index_n(o_index_n), 
	.o_seg_n(o_seg_n),
	.o_lsb(o_lsb)
);

endmodule 