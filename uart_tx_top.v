`timescale 1ns / 1ps

module uart_tx_top #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx,
    output wire       tx_active,
    output wire       tx_done
);

    wire baud_tick;

    // Khoi tao Baud Rate Generator
    baud_rate_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen_inst (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick)
    );

    // Khoi tao UART Transmitter
    uart_tx tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .baud_tick(baud_tick),
        .tx(tx),
        .tx_active(tx_active),
        .tx_done(tx_done)
    );

endmodule
