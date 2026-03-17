<p align="center">
  <img src="https://img.shields.io/badge/Language-Verilog-blue?style=for-the-badge&logo=v&logoColor=white" alt="Verilog"/>
  <img src="https://img.shields.io/badge/Protocol-UART-ff6600?style=for-the-badge" alt="UART"/>
  <img src="https://img.shields.io/badge/Category-VLSI%20Design-green?style=for-the-badge" alt="VLSI"/>
  <img src="https://img.shields.io/badge/Simulation-Icarus%20Verilog-purple?style=for-the-badge" alt="Icarus"/>
</p>

# ðŸ“¡ UART Transceiver â€” Verilog HDL

> A complete, synthesizable UART (Universal Asynchronous Receiver-Transmitter) implementation with configurable baud rate, loopback testbench, and industry-standard 8N1 protocol.

---

## ðŸ“‹ Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [UART Protocol](#-uart-protocol)
- [Module Hierarchy](#-module-hierarchy)
- [Features](#-features)
- [File Structure](#-file-structure)
- [Simulation Guide](#-simulation-guide)
- [Applications](#-applications)
- [Author](#-author)

---

## ðŸ” Overview

**UART** is the most fundamental serial communication protocol used in embedded systems, FPGA boards, and SoC designs. This project implements a **full-duplex UART transceiver** with separate transmitter and receiver modules, supporting configurable baud rates.

### Key Highlights
- ðŸ“¡ **Full Duplex** â€” Independent TX and RX channels
- âš¡ **Configurable Baud Rate** â€” Parameterized for 9600, 19200, 115200, etc.
- ðŸ”„ **Loopback Testing** â€” TX output wired to RX input for self-verification
- ðŸ›¡ï¸ **Error Detection** â€” Frame error flag for invalid stop bits
- ðŸŽ¯ **Mid-bit Sampling** â€” Noise-immune RX sampling at bit center
- âœ… **Self-Checking TB** â€” Automated PASS/FAIL with 10 test vectors

---

## ðŸ—ï¸ Architecture

```
                         UART TOP MODULE
    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
    â”‚                                                 â”‚
    â”‚   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
    â”‚   â”‚   UART TX        â”‚   â”‚   UART RX        â”‚    â”‚
    â”‚   â”‚                 â”‚   â”‚                 â”‚    â”‚
    â”‚   â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚   â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚    â”‚
    â”‚   â”‚  â”‚  Baud Gen  â”‚  â”‚   â”‚  â”‚  Baud Gen  â”‚  â”‚    â”‚
    â”‚   â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚   â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚    â”‚
    â”‚   â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚   â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚    â”‚
    â”‚   â”‚  â”‚  TX FSM    â”‚  â”‚   â”‚  â”‚  RX FSM    â”‚  â”‚    â”‚
    â”‚   â”‚  â”‚ IDLEâ†’START â”‚  â”‚   â”‚  â”‚ IDLEâ†’START â”‚  â”‚    â”‚
    â”‚   â”‚  â”‚ â†’DATAâ†’STOP â”‚  â”‚   â”‚  â”‚ â†’DATAâ†’STOP â”‚  â”‚    â”‚
    â”‚   â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚   â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚    â”‚
    â”‚   â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚   â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚    â”‚
    â”‚   â”‚  â”‚ Shift Reg  â”‚â”€â”€â”¼â”€â”€â”€â”¼â”€â–ºâ”‚ Shift Reg  â”‚  â”‚    â”‚
    â”‚   â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚   â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚    â”‚
    â”‚   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## ðŸ“¶ UART Protocol (8N1)

```
        â”Œâ”€â”€â”€â”€â”€â”     â”Œâ”€â”€â”€â”¬â”€â”€â”€â”¬â”€â”€â”€â”¬â”€â”€â”€â”¬â”€â”€â”€â”¬â”€â”€â”€â”¬â”€â”€â”€â”¬â”€â”€â”€â”     â”Œâ”€â”€â”€â”€â”€â”
IDLE    â”‚     â”‚STARTâ”‚ D0â”‚ D1â”‚ D2â”‚ D3â”‚ D4â”‚ D5â”‚ D6â”‚ D7â”‚STOP â”‚     â”‚ IDLE
(HIGH)  â”‚  1  â”‚  0  â”‚   â”‚   â”‚   â”‚   â”‚   â”‚   â”‚   â”‚   â”‚  1  â”‚  1  â”‚
        â””â”€â”€â”€â”€â”€â”˜     â””â”€â”€â”€â”´â”€â”€â”€â”´â”€â”€â”€â”´â”€â”€â”€â”´â”€â”€â”€â”´â”€â”€â”€â”´â”€â”€â”€â”´â”€â”€â”€â”˜     â””â”€â”€â”€â”€â”€â”˜
               â—„â”€â”€â”€â”€â”€ 1 bit â”€â”€â”€â”€â”€â–º                   â—„â”€â”€ 1 bit â”€â”€â–º
```

| Parameter | Value |
|-----------|-------|
| Start Bits | 1 (Logic LOW) |
| Data Bits | 8 (LSB first) |
| Parity | None |
| Stop Bits | 1 (Logic HIGH) |

---

## ðŸ§© Module Hierarchy

```
uart_top
â”œâ”€â”€ uart_tx          # Transmitter module
â”‚   â”œâ”€â”€ Baud rate generator
â”‚   â”œâ”€â”€ TX FSM (IDLE â†’ START â†’ DATA â†’ STOP)
â”‚   â””â”€â”€ Parallel-to-serial shift register
â”‚
â””â”€â”€ uart_rx          # Receiver module
    â”œâ”€â”€ Baud rate generator
    â”œâ”€â”€ RX FSM (IDLE â†’ START â†’ DATA â†’ STOP)
    â”œâ”€â”€ Mid-bit sampling logic
    â””â”€â”€ Serial-to-parallel shift register
```

---

## âœ¨ Features

| Feature | Description |
|---------|-------------|
| **Parameterized Design** | CLK_FREQ and BAUD_RATE as module parameters |
| **FSM-Based Control** | Clean 4-state FSM for both TX and RX |
| **Mid-Bit Sampling** | RX samples at center of each bit period for noise immunity |
| **Frame Error Detection** | Flags frames with invalid stop bits |
| **Loopback Testbench** | TX â†’ RX loopback for comprehensive self-testing |
| **Synthesizable RTL** | Ready for FPGA implementation |

---

## ðŸ“ File Structure

```
VLSI-UART-Transceiver-Verilog/
â”œâ”€â”€ src/
â”‚   â”œâ”€â”€ uart_tx.v           # UART Transmitter
â”‚   â”œâ”€â”€ uart_rx.v           # UART Receiver
â”‚   â””â”€â”€ uart_top.v          # Top-level integration
â”œâ”€â”€ testbench/
â”‚   â””â”€â”€ uart_tb.v           # Loopback testbench
â”œâ”€â”€ docs/
â”œâ”€â”€ .gitignore
â”œâ”€â”€ LICENSE
â””â”€â”€ README.md
```

---

## ðŸš€ Simulation Guide

### Using Icarus Verilog

```bash
# Compile all source + testbench
iverilog -o uart_sim src/uart_tx.v src/uart_rx.v src/uart_top.v testbench/uart_tb.v

# Run simulation
vvp uart_sim

# View waveforms
gtkwave uart_tb.vcd
```

### Using ModelSim / QuestaSim

```bash
vlib work
vlog src/uart_tx.v src/uart_rx.v src/uart_top.v testbench/uart_tb.v
vsim -run -all uart_tb
```

### Expected Output

```
============================================================
    UART TRANSCEIVER TESTBENCH - Daggolu Hari Krishna
    Baud Rate: 115200 | Clock: 50 MHz
============================================================

--- Test: Alternating Pattern ---
[PASS] Test 1: Sent=0x55, Received=0x55
[PASS] Test 2: Sent=0xaa, Received=0xaa
--- Test: Boundary Values ---
[PASS] Test 3: Sent=0x00, Received=0x00
[PASS] Test 4: Sent=0xff, Received=0xff
...
============================================================
  TEST SUMMARY: 10 PASSED, 0 FAILED out of 10 tests
============================================================
  >>> ALL TESTS PASSED! <<<
```

---

## ðŸ’¡ Applications

- ðŸ”Œ **FPGA-to-PC Communication** â€” Debug interfaces via USB-UART
- ðŸ­ **SoC Peripherals** â€” Standard UART IP core in ASIC designs
- ðŸ“¡ **Sensor Interfaces** â€” GPS, Bluetooth, WiFi module communication
- ðŸ”§ **Debugging** â€” Serial console output from embedded processors

---

## ðŸ‘¨â€ðŸ’» Author

**Daggolu Hari Krishna**
B.Tech ECE | JNTUA College of Engineering, Kalikiri

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/contacthari88/)
[![Email](https://img.shields.io/badge/Email-Contact-red?style=flat-square&logo=gmail)](mailto:haridaggolu@gmail.com)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-black?style=flat-square&logo=github)](https://github.com/HariKrishna0088)

---

<p align="center">
  â­ If you found this project helpful, please give it a star! â­
</p>
