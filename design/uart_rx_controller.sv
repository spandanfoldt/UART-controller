`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2026 13:40:16
// Design Name: 
// Module Name: uart_rx_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx_controller #(parameter RX_OVERSAMPLE = 0)
	(input clk,
	 input reset_n,
	 input i_rx_data,
	 output o_rx_done,
	 output [7:0] o_rx_byte
    );
	
	localparam RX_IDLE = 3'b000,
			   RX_START = 3'b001,
			   RX_DATA = 3'b010,
			   RX_STOP = 3'b011;
	
	logic [7:0] r_rx_data;
	logic [2:0] r_bit_index;
	logic [4:0] r_clk_count;
	logic [2:0] r_state;
	logic r_rx_done;
	
	always_ff @(posedge clk or negedge reset_n) begin
		if(~reset_n) begin
			r_state <= RX_IDLE;
			r_bit_index <= 0;
			r_clk_count <= 0;
			r_rx_done <= 0;
			r_rx_data <= 0;
		end
		
		else begin
			case (r_state)
				RX_IDLE: begin
					r_bit_index <= 0;
					r_clk_count <= 0;
					r_rx_done <= 0;
					if (i_rx_data == 0) r_state <= RX_IDLE;
					else r_state <= RX_START;
				end
				
				RX_START: begin
					if(r_clk_count == RX_OVERSAMPLE/2) begin
						if(i_rx_data == 0) begin
							r_state <= RX_DATA;
							r_clk_count <= 0;
						end
						else begin
							r_state <= RX_IDLE;
						end
					end
					else begin
						r_state <= RX_IDLE;
						r_clk_count <= r_clk_count + 1;
					end
				end
				
				RX_DATA: begin
					if (r_clk_count < RX_OVERSAMPLE) begin
						r_state <= RX_DATA;
						r_clk_count <= r_clk_count + 1;
					end
					else begin
						r_rx_data[r_bit_index] <= i_rx_data;
						r_clk_count <= 0;
						if(r_bit_index < 7) begin
							r_bit_index <= r_bit_index + 1;
							r_state <= RX_DATA;
						end
						else begin
							r_bit_index <= 0;
							r_state <= RX_STOP;
						end
					end
				end
				
				RX_STOP: begin
					if(r_clk_count < RX_OVERSAMPLE) begin
						r_state <= RX_STOP;
						r_clk_count <= r_clk_count + 1;
					end
					else begin
						r_state <= RX_IDLE;
						r_clk_count <= 0;
						r_rx_done <= 1;
					end
				end
				
				default: r_state <= RX_IDLE;
			endcase
		end
	end
	
	assign o_rx_done = r_rx_done;
	assign o_rx_byte = r_rx_done?r_rx_data:8'h00;
	
endmodule
