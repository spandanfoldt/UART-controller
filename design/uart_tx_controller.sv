`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2026 13:40:16
// Design Name: 
// Module Name: uart_tx_controller
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


module uart_tx_controller(input clk,
						  input reset_n,
						  input logic [7:0] i_tx_byte,
						  input i_tx_ready,
						  output o_tx_done,
						  output o_tx_active,
						  output o_tx_data
    );
	
	localparam TX_IDLE = 3'b000,
			   TX_START = 3'b001,
			   TX_DATA = 3'b010,
			   TX_STOP = 3'b011;
			   
	logic [2:0] r_bit_index;
	logic r_tx_done;
	logic [2:0] r_state;
	logic r_tx_active;
	logic r_tx_data;
	
	always_ff @(posedge clk or negedge reset_n) begin
		if(~reset_n) begin
			r_state <= TX_IDLE;
			r_bit_index <= 0;
			r_tx_done <= 0;
			r_tx_data <= 1;
			r_tx_active <= 0;
		end
		
		else begin
			case (r_state)
				TX_IDLE: begin
					r_bit_index <= 0;
					r_tx_done <= 0;
					r_tx_data <= 1;
					if (i_tx_ready) begin
						r_state <= TX_START;
						r_tx_active <= 1;
					end
					else
						r_state <= TX_IDLE;
				end
				
				TX_START: begin
					r_state <= TX_DATA;
					r_tx_data <= 0;
				end
				
				TX_DATA: begin
					r_tx_data <= i_tx_byte[r_bit_index];
					if(r_bit_index < 7) begin
						r_bit_index <= r_bit_index + 1;
						r_state <= TX_DATA;
					end
					else begin
						r_bit_index <= 0;
						r_state <= TX_STOP;
					end
				end
				
				TX_STOP: begin
					r_state <= TX_IDLE;
					r_tx_done <= 1;
					r_tx_active <= 0;
					r_tx_data <= 1;
				end
				
				default: r_state <= TX_IDLE;
			endcase
		end
	end
	
	assign o_tx_done = r_tx_done;
	assign o_tx_data = r_tx_data;
	assign o_tx_active = r_tx_active;
		
endmodule
