//=============================================================================
// Testbench: uart_tb
// Description: Loopback testbench for UART Transceiver
// Author: Daggolu Hari Krishna
//
// Transmits data bytes via TX, loops back to RX, and verifies received data.
//=============================================================================

`timescale 1ns / 1ps

module uart_tb;

    // Parameters — use smaller clock for faster simulation
    localparam CLK_FREQ  = 50_000_000;
    localparam BAUD_RATE = 115200; // Faster baud for simulation
    localparam CLK_PERIOD = 20;    // 50 MHz = 20 ns period

    // Signals
    reg        clk;
    reg        rst_n;
    reg  [7:0] tx_data;
    reg        tx_start;
    wire       tx_line;
    wire       tx_busy;
    wire [7:0] rx_data;
    wire       rx_valid;
    wire       rx_error;

    // Loopback wire (TX output connects to RX input)
    wire loopback;
    assign loopback = tx_line;

    // Test tracking
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_num   = 0;

    // Instantiate UART top module
    uart_top #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) uut (
        .clk      (clk),
        .rst_n    (rst_n),
        .tx_data  (tx_data),
        .tx_start (tx_start),
        .tx_line  (tx_line),
        .tx_busy  (tx_busy),
        .rx_line  (loopback), // Loopback connection
        .rx_data  (rx_data),
        .rx_valid (rx_valid),
        .rx_error (rx_error)
    );

    // Clock generation
    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Task: Send a byte and verify reception
    task send_and_verify;
        input [7:0] data;
    begin
        test_num = test_num + 1;

        // Initiate transmission
        @(posedge clk);
        tx_data  = data;
        tx_start = 1'b1;
        @(posedge clk);
        tx_start = 1'b0;

        // Wait for reception
        @(posedge rx_valid or posedge rx_error);
        #(CLK_PERIOD);

        if (rx_valid && rx_data === data && !rx_error) begin
            $display("[PASS] Test %0d: Sent=0x%h, Received=0x%h", test_num, data, rx_data);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: Sent=0x%h, Received=0x%h, Error=%b",
                     test_num, data, rx_data, rx_error);
            fail_count = fail_count + 1;
        end

        // Wait for TX to finish completely
        wait (!tx_busy);
        #(CLK_PERIOD * 10);
    end
    endtask

    // Main test sequence
    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

        $display("============================================================");
        $display("    UART TRANSCEIVER TESTBENCH - Daggolu Hari Krishna");
        $display("    Baud Rate: %0d | Clock: %0d MHz", BAUD_RATE, CLK_FREQ/1_000_000);
        $display("============================================================");
        $display("");

        // Reset
        rst_n    = 1'b0;
        tx_start = 1'b0;
        tx_data  = 8'd0;
        #(CLK_PERIOD * 10);
        rst_n = 1'b1;
        #(CLK_PERIOD * 5);

        // Test 1: Send 0x55 (alternating bits: 01010101)
        $display("--- Test: Alternating Pattern ---");
        send_and_verify(8'h55);

        // Test 2: Send 0xAA (alternating bits: 10101010)
        send_and_verify(8'hAA);

        // Test 3: Send 0x00 (all zeros)
        $display("--- Test: Boundary Values ---");
        send_and_verify(8'h00);

        // Test 4: Send 0xFF (all ones)
        send_and_verify(8'hFF);

        // Test 5: Send ASCII 'H' (0x48)
        $display("--- Test: ASCII Characters ---");
        send_and_verify(8'h48); // 'H'

        // Test 6: Send ASCII 'K' (0x4B)
        send_and_verify(8'h4B); // 'K'

        // Test 7: Random data
        $display("--- Test: Random Data ---");
        send_and_verify(8'h3C);
        send_and_verify(8'hC3);
        send_and_verify(8'h96);
        send_and_verify(8'h69);

        // Summary
        $display("");
        $display("============================================================");
        $display("  TEST SUMMARY: %0d PASSED, %0d FAILED out of %0d tests",
                 pass_count, fail_count, test_num);
        $display("============================================================");
        if (fail_count == 0)
            $display("  >>> ALL TESTS PASSED! <<<");
        else
            $display("  >>> SOME TESTS FAILED! <<<");
        $display("");
        $finish;
    end

    // Timeout watchdog
    initial begin
        #(100_000_000); // 100 ms timeout
        $display("[ERROR] Simulation timeout!");
        $finish;
    end

endmodule
