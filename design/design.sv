`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2026 13:12:33
// Design Name: 
// Module Name: design
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

`include "defines.sv"
//`include "baudRateGenerator.sv"
`ifdef UART_TX_ONLY
//`include "uart_tx_controller.sv"
`elsif UART_RX_ONLY
//`include "uart_rx_controller.sv"
`else
//`include "uart_tx_controller.sv"
//`include "uart_rx_controller.sv"
`endif


module uart_controller #(parameter CLOCK_RATE = 0,
                         parameter BAUD_RATE = 0,
                         parameter RX_OVERSAMPLE = 1)
    (input logic clk,
     input logic reset_n,
     
     `ifdef UART_TX_ONLY
     input i_tx_ready,
     input [7:0] i_tx_byte,
     output o_tx_active,
     output o_tx_data,
     output o_tx_done
     
     `elsif UART_RX_ONLY
     input i_rx_data,
     output o_rx_done,
     output [7:0] o_rx_byte
     
     `else
     input [7:0] i_tx_byte,
     input i_tx_ready,
     output o_rx_done,
     output [7:0] o_rx_byte
     
     `endif
    );
    
    logic w_rx_clktick, w_tx_clktick;
    logic w_tx_data_to_rx;
    
    `ifdef UART_TX_ONLY
    assign o_tx_data = w_tx_data_to_rx;
    
    `elsif UART_RX_ONLY
    assign w_tx_data_to_rx = i_rx_data;
    
    `endif
    
    
    //baud rate generator instantiation
    baudRateGenerator #(CLOCK_RATE, BAUD_RATE, RX_OVERSAMPLE) brg(
        .clk(clk),
        .reset_n(reset_n),
        .o_rx_clktick(w_rx_clktick),
        .o_tx_clktick(w_tx_clktick)
        );
        
    //tx controller instantiation
    `ifdef UART_TX_ONLY
    uart_tx_controller uart_tx(
        .clk(w_tx_clktick),
        .reset_n(reset_n),
        .i_tx_byte(i_tx_byte),
        .i_tx_ready(i_tx_ready),
        .o_tx_done(o_tx_done),
        .o_tx_active(o_tx_active),
        .o_tx_data(w_tx_data_to_rx)
    );
        
    //rx controller instantiation
    uart_rx_controller #(RX_OVERSAMPLE) uart_rx(
      .clk(w_rx_clktick),
      .reset_n(reset_n),
      .i_rx_data(w_tx_data_to_rx),
      .o_rx_done(o_rx_done),
      .o_rx_byte(o_rx_byte)
    );
    
    
    //both tx and rx instantiation
    `else
    uart_tx_controller uart_txb(
        .clk(w_tx_clktick),
        .reset_n(reset_n),
        .i_tx_byte(i_tx_byte),
        .i_tx_ready(i_tx_ready),
        .o_tx_done(),
        .o_tx_active(),
        .o_tx_data(w_tx_data_to_rx)
    );
    
    uart_rx_controller #(RX_OVERSAMPLE) uart_rxb(
      .clk(w_rx_clktick),
      .reset_n(reset_n),
      .i_rx_data(w_tx_data_to_rx),
      .o_rx_done(o_rx_done),
      .o_rx_byte(o_rx_byte)
    );
    
    `endif
    
    
endmodule
