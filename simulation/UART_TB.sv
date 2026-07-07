`timescale 1ns / 1ps

`include "defines.sv"

module UART_TB;

    parameter c_CLOCK_PERIOD_NS = 40;

    logic Clock = 0;
    logic reset_n = 0;

`ifdef UART_TX_ONLY

    logic        Tx_Ready = 0;
    logic [7:0]  Tx_Byte  = 0;

    logic Tx_Done;
    logic Tx_Active;
    logic Tx_Data;

`elsif UART_RX_ONLY

    logic UART_Rx = 1;

    logic Rx_Done;
    logic [7:0] Rx_Byte;

`else

    logic        Tx_Ready = 0;
    logic [7:0]  Tx_Byte  = 0;

    logic        Rx_Done;
    logic [7:0]  Rx_Byte;

    logic [7:0] DataToSend [0:7];
    logic [7:0] DataReceived [0:7];

    integer ii;

`endif

    always #(c_CLOCK_PERIOD_NS/2)
        Clock = ~Clock;

`ifdef UART_TX_ONLY

    uart_controller #(
        .CLOCK_RATE(25000000),
        .BAUD_RATE(115200)
    ) DUT (
        .clk(Clock),
        .reset_n(reset_n),
        .i_tx_ready(Tx_Ready),
        .i_tx_byte(Tx_Byte),
        .o_tx_active(Tx_Active),
        .o_tx_data(Tx_Data),
        .o_tx_done(Tx_Done)
    );

    initial begin
        #100;
        reset_n = 1;

        @(posedge Clock);

        Tx_Byte  = 8'h55;
        Tx_Ready = 1;

        @(posedge Clock);
        Tx_Ready = 0;

        @(posedge Tx_Done);

        #1000;
        $finish;
    end

`elsif UART_RX_ONLY

    uart_controller #(
        .CLOCK_RATE(25000000),
        .BAUD_RATE(115200),
        .RX_OVERSAMPLE(16)
    ) DUT (
        .clk(Clock),
        .reset_n(reset_n),
        .i_rx_data(UART_Rx),
        .o_rx_done(Rx_Done),
        .o_rx_byte(Rx_Byte)
    );

    localparam BIT_TIME = 8680;

    task send_byte(input [7:0] data);
        integer i;
        begin
            UART_Rx = 0;
            #(BIT_TIME);

            for (i = 0; i < 8; i = i + 1) begin
                UART_Rx = data[i];
                #(BIT_TIME);
            end

            UART_Rx = 1;
            #(BIT_TIME);
        end
    endtask

    initial begin
        UART_Rx = 1;

        #100;
        reset_n = 1;

        #10000;

        send_byte(8'h55);

        @(posedge Rx_Done);

        $display("Received = %h", Rx_Byte);

        #1000;
        $finish;
    end

`else

    uart_controller #(
        .CLOCK_RATE(25000000),
        .BAUD_RATE(115200),
        .RX_OVERSAMPLE(16)
    ) DUT (
        .clk(Clock),
        .reset_n(reset_n),
        .i_tx_byte(Tx_Byte),
        .i_tx_ready(Tx_Ready),
        .o_rx_done(Rx_Done),
        .o_rx_byte(Rx_Byte)
    );

    initial begin
        DataToSend[0] = 8'h01;
        DataToSend[1] = 8'h10;
        DataToSend[2] = 8'h22;
        DataToSend[3] = 8'h32;
        DataToSend[4] = 8'h55;
        DataToSend[5] = 8'hAA;
        DataToSend[6] = 8'hAB;
        DataToSend[7] = 8'h88;

        #100;
        reset_n = 1;

        @(posedge Clock);

        for (ii = 0; ii < 8; ii = ii + 1) begin

            Tx_Byte  = DataToSend[ii];
            Tx_Ready = 1;

            @(posedge Clock);
            Tx_Ready = 0;

            @(posedge Rx_Done);

            DataReceived[ii] = Rx_Byte;

            if (DataReceived[ii] == DataToSend[ii])
                $display("PASS : Sent = %h Received = %h",
                         DataToSend[ii], DataReceived[ii]);
            else
                $display("FAIL : Sent = %h Received = %h",
                         DataToSend[ii], DataReceived[ii]);

            repeat (20)
                @(posedge Clock);
        end

        #1000;
        $finish;
    end

`endif

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, UART_TB);
    end

endmodule