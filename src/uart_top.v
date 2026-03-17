//=============================================================================
// Module: uart_top
// Description: UART Top-Level Module (TX + RX Loopback)
// Author: Daggolu Hari Krishna
//
// Integrates UART transmitter and receiver for full-duplex communication.
// Can be configured for loopback testing.
//=============================================================================

module uart_top #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst_n,

    // Transmitter interface
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output wire       tx_line,
    output wire       tx_busy,

    // Receiver interface
    input  wire       rx_line,
    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       rx_error
);

    // UART Transmitter Instance
    uart_tx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_tx (
        .clk      (clk),
        .rst_n    (rst_n),
        .tx_data  (tx_data),
        .tx_start (tx_start),
        .tx       (tx_line),
        .tx_busy  (tx_busy)
    );

    // UART Receiver Instance
    uart_rx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_rx (
        .clk      (clk),
        .rst_n    (rst_n),
        .rx       (rx_line),
        .rx_data  (rx_data),
        .rx_valid (rx_valid),
        .rx_error (rx_error)
    );

endmodule
