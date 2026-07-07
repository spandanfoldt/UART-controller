`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2026 13:40:16
// Design Name: 
// Module Name: baudRateGenerator
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


module baudRateGenerator #(parameter CLOCK_RATE = 25000000,
                           parameter BAUD_RATE = 115200,
                           parameter RX_OVERSAMPLE = 16)
    (input clk,
     input reset_n,
     
     output logic o_rx_clktick,
     output logic o_tx_clktick
    );
    
    parameter tx_cnt = CLOCK_RATE/(2*BAUD_RATE);
    parameter rx_cnt = CLOCK_RATE/(2*BAUD_RATE*RX_OVERSAMPLE);
    parameter tx_cnt_width = $clog2(tx_cnt);
    parameter rx_cnt_width = $clog2(rx_cnt);
    
    logic [tx_cnt_width-1:0] r_tx_counter;
    logic [rx_cnt_width-1:0] r_rx_counter;
    
    //rx baud rate
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            o_rx_clktick <= 1'b0;
            r_rx_counter <= 0;
        end
        else if (r_rx_counter == rx_cnt-1) begin
            o_rx_clktick <= ~o_rx_clktick;
            r_rx_counter <= 0;
        end
        else
            r_rx_counter <= r_rx_counter+1;
    end
    
    //tx baud rate
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            o_tx_clktick <= 1'b0;
            r_tx_counter <= 0;
        end
        else if (r_tx_counter == tx_cnt-1) begin
            o_tx_clktick <= ~o_tx_clktick;
            r_tx_counter <= 0;
        end
        else
            r_tx_counter <= r_tx_counter+1;
    end
    
    
    
    
endmodule
