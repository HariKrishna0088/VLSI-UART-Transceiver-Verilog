//=============================================================================
// Module: uart_rx
// Description: UART Receiver with configurable baud rate
// Author: Daggolu Hari Krishna
//
// Parameters:
//   CLK_FREQ  - System clock frequency (default 50 MHz)
//   BAUD_RATE - Desired baud rate (default 9600)
//
// Protocol: 1 Start bit, 8 Data bits, 1 Stop bit (8N1)
// Sampling: Mid-bit sampling for noise immunity
//=============================================================================

module uart_rx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,           // UART RX line
    output reg  [7:0] rx_data,      // Received data byte
    output reg        rx_valid,     // Pulses high when data is valid
    output reg        rx_error      // Frame error flag
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // FSM States
    localparam [2:0]
        IDLE  = 3'b000,
        START = 3'b001,
        DATA  = 3'b010,
        STOP  = 3'b011;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  rx_shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            rx_data      <= 8'd0;
            rx_valid     <= 1'b0;
            rx_error     <= 1'b0;
            clk_count    <= 16'd0;
            bit_index    <= 3'd0;
            rx_shift_reg <= 8'd0;
        end else begin
            rx_valid <= 1'b0; // Default: deassert valid
            rx_error <= 1'b0;

            case (state)
                IDLE: begin
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (rx == 1'b0) begin // Start bit detected
                        state <= START;
                    end
                end

                START: begin
                    // Sample at mid-point of start bit
                    if (clk_count == (CLKS_PER_BIT - 1) / 2) begin
                        if (rx == 1'b0) begin
                            // Valid start bit confirmed
                            clk_count <= 16'd0;
                            state     <= DATA;
                        end else begin
                            // False start — return to idle
                            state <= IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        rx_shift_reg[bit_index] <= rx; // LSB first
                        if (bit_index == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        if (rx == 1'b1) begin
                            // Valid stop bit
                            rx_data  <= rx_shift_reg;
                            rx_valid <= 1'b1;
                        end else begin
                            // Frame error — stop bit not high
                            rx_error <= 1'b1;
                        end
                        state <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
