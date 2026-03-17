//=============================================================================
// Module: uart_tx
// Description: UART Transmitter with configurable baud rate
// Author: Daggolu Hari Krishna
//
// Parameters:
//   CLK_FREQ  - System clock frequency (default 50 MHz)
//   BAUD_RATE - Desired baud rate (default 9600)
//
// Protocol: 1 Start bit, 8 Data bits, 1 Stop bit (8N1)
//=============================================================================

module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] tx_data,     // Data byte to transmit
    input  wire       tx_start,    // Pulse high to begin transmission
    output reg        tx,          // UART TX line
    output reg        tx_busy      // High while transmitting
);

    // Baud rate generator
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
    reg [7:0]  tx_shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            tx           <= 1'b1; // Idle high
            tx_busy      <= 1'b0;
            clk_count    <= 16'd0;
            bit_index    <= 3'd0;
            tx_shift_reg <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        tx_shift_reg <= tx_data;
                        state        <= START;
                        tx_busy      <= 1'b1;
                        clk_count    <= 16'd0;
                    end
                end

                START: begin
                    tx <= 1'b0; // Start bit = 0
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        bit_index <= 3'd0;
                        state     <= DATA;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA: begin
                    tx <= tx_shift_reg[bit_index]; // LSB first
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
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
                    tx <= 1'b1; // Stop bit = 1
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        state     <= IDLE;
                        tx_busy   <= 1'b0;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
