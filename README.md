<p align="center">
  <img src="https://img.shields.io/badge/Language-Verilog-blue?style=for-the-badge&logo=v&logoColor=white" alt="Verilog"/>
  <img src="https://img.shields.io/badge/Protocol-UART-ff6600?style=for-the-badge" alt="UART"/>
  <img src="https://img.shields.io/badge/Category-VLSI%20Design-green?style=for-the-badge" alt="VLSI"/>
  <img src="https://img.shields.io/badge/Simulation-Icarus%20Verilog-purple?style=for-the-badge" alt="Icarus"/>
</p>

# 📡 UART Transceiver — Verilog HDL

> A complete, synthesizable UART (Universal Asynchronous Receiver-Transmitter) implementation with configurable baud rate, loopback testbench, and industry-standard 8N1 protocol.

---

## 📋 Table of Contents

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

## 🔍 Overview

**UART** is the most fundamental serial communication protocol used in embedded systems, FPGA boards, and SoC designs. This project implements a **full-duplex UART transceiver** with separate transmitter and receiver modules, supporting configurable baud rates.

### Key Highlights
- 📡 **Full Duplex** — Independent TX and RX channels
- ⚡ **Configurable Baud Rate** — Parameterized for 9600, 19200, 115200, etc.
- 🔄 **Loopback Testing** — TX output wired to RX input for self-verification
- 🛡️ **Error Detection** — Frame error flag for invalid stop bits
- 🎯 **Mid-bit Sampling** — Noise-immune RX sampling at bit center
- ✅ **Self-Checking TB** — Automated PASS/FAIL with 10 test vectors

---

## 🏗️ Architecture

```
                         UART TOP MODULE
    ┌─────────────────────────────────────────────────┐
    │                                                 │
    │   ┌─────────────────┐   ┌─────────────────┐    │
    │   │   UART TX        │   │   UART RX        │    │
    │   │                 │   │                 │    │
    │   │  ┌───────────┐  │   │  ┌───────────┐  │    │
    │   │  │  Baud Gen  │  │   │  │  Baud Gen  │  │    │
    │   │  └───────────┘  │   │  └───────────┘  │    │
    │   │  ┌───────────┐  │   │  ┌───────────┐  │    │
    │   │  │  TX FSM    │  │   │  │  RX FSM    │  │    │
    │   │  │ IDLE→START │  │   │  │ IDLE→START │  │    │
    │   │  │ →DATA→STOP │  │   │  │ →DATA→STOP │  │    │
    │   │  └───────────┘  │   │  └───────────┘  │    │
    │   │  ┌───────────┐  │   │  ┌───────────┐  │    │
    │   │  │ Shift Reg  │──┼───┼─►│ Shift Reg  │  │    │
    │   │  └───────────┘  │   │  └───────────┘  │    │
    │   └─────────────────┘   └─────────────────┘    │
    └─────────────────────────────────────────────────┘
```

---

## 📶 UART Protocol (8N1)

```
        ┌─────┐     ┌───┬───┬───┬───┬───┬───┬───┬───┐     ┌─────┐
IDLE    │     │START│ D0│ D1│ D2│ D3│ D4│ D5│ D6│ D7│STOP │     │ IDLE
(HIGH)  │  1  │  0  │   │   │   │   │   │   │   │   │  1  │  1  │
        └─────┘     └───┴───┴───┴───┴───┴───┴───┴───┘     └─────┘
               ◄───── 1 bit ─────►                   ◄── 1 bit ──►
```

| Parameter | Value |
|-----------|-------|
| Start Bits | 1 (Logic LOW) |
| Data Bits | 8 (LSB first) |
| Parity | None |
| Stop Bits | 1 (Logic HIGH) |

---

## 🧩 Module Hierarchy

```
uart_top
├── uart_tx          # Transmitter module
│   ├── Baud rate generator
│   ├── TX FSM (IDLE → START → DATA → STOP)
│   └── Parallel-to-serial shift register
│
└── uart_rx          # Receiver module
    ├── Baud rate generator
    ├── RX FSM (IDLE → START → DATA → STOP)
    ├── Mid-bit sampling logic
    └── Serial-to-parallel shift register
```

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Parameterized Design** | CLK_FREQ and BAUD_RATE as module parameters |
| **FSM-Based Control** | Clean 4-state FSM for both TX and RX |
| **Mid-Bit Sampling** | RX samples at center of each bit period for noise immunity |
| **Frame Error Detection** | Flags frames with invalid stop bits |
| **Loopback Testbench** | TX → RX loopback for comprehensive self-testing |
| **Synthesizable RTL** | Ready for FPGA implementation |

---

## 📁 File Structure

```
VLSI-UART-Transceiver-Verilog/
├── src/
│   ├── uart_tx.v           # UART Transmitter
│   ├── uart_rx.v           # UART Receiver
│   └── uart_top.v          # Top-level integration
├── testbench/
│   └── uart_tb.v           # Loopback testbench
├── docs/
├── .gitignore
├── LICENSE
└── README.md
```

---

## 🚀 Simulation Guide

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

## 💡 Applications

- 🔌 **FPGA-to-PC Communication** — Debug interfaces via USB-UART
- 🏭 **SoC Peripherals** — Standard UART IP core in ASIC designs
- 📡 **Sensor Interfaces** — GPS, Bluetooth, WiFi module communication
- 🔧 **Debugging** — Serial console output from embedded processors

---

## 👨‍💻 Author

**Daggolu Hari Krishna**
B.Tech ECE | JNTUA College of Engineering, Kalikiri

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat-square&logo=linkedin)](https://linkedin.com/in/harikrishnadaggolu)
[![Email](https://img.shields.io/badge/Email-Contact-red?style=flat-square&logo=gmail)](mailto:haridaggolu@gmail.com)

---

<p align="center">
  ⭐ If you found this project helpful, please give it a star! ⭐
</p>
