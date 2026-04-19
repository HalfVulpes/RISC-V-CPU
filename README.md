# RISC-V Linux SoC — RIGUKE RK-XCKU5P-F

A RISC-V Linux server running Debian on the **RIGUKE RK-XCKU5P-F V1.2** FPGA board.  
Includes Gigabit Ethernet, MicroSD, UART console, and DDR4 memory — ready to boot out of the box.

![RK-XCKU5P Board](assets/rk_ku5p_board.jpg)

---

## Board Overview

| | |
|---|---|
| **FPGA** | AMD Kintex UltraScale+ XCKU5P-2FFVB676I |
| **Logic Cells** | 475K system logic cells, 217K LUTs, 434K FFs |
| **DSP Slices** | 1,824 |
| **Memory** | 2 GB DDR4 SDRAM (2× Micron MT40A512M16LY-062E, 32-bit bus) |
| **Flash** | 64 MB QSPI NOR (Macronix MX25U51245GZ4I00, 1.8 V) |
| **System Clock** | 200 MHz differential (SG3225VAN, Bank 65) |
| **Ethernet** | Realtek RTL8211F-CG, 10/100/1000 Mbps RGMII |
| **Storage** | MicroSD (4-bit SD mode, up to 50 MHz) |
| **UART/JTAG** | FTDI FT2232HQ via USB Type-C |
| **PCIe** | PCIe 3.0 x4 (x8 slot, electrical x4) |
| **Form Factor** | PCIe card, 131 × 107 mm |
| **Temperature** | Industrial −40 °C to +100 °C |

![Board Dimensions](assets/board_dimensions.png)

---

## RISC-V SoC Configuration

| | |
|---|---|
| **Architecture** | 64-bit RISC-V (RV64GC) |
| **Recommended cores** | 4 (rocket64b4) |
| **Maximum cores** | 4 (limited by LUT budget at practical clock rates) |
| **CPU clock** | 100 MHz (clk_wiz from 200 MHz system clock) |
| **Ethernet MAC clock** | 125 MHz / 125 MHz @90° (for RGMII USE_CLK90) |
| **RAM visible to Linux** | 2 GB (DDR4 at address 0x00000000) |
| **Vivado version** | **2023.2 only** — newer versions lock the QSPI flash |

> **Note on Vivado version:** A hardware design flaw causes the MX25U51245G QSPI flash to lock itself permanently when programmed with Vivado 2024.x or later. Always use **Vivado 2023.2** for this board.

---

## Peripheral Map (as seen by Linux)

| Address | Device | Driver |
|---|---|---|
| `0x60000000` | SD card controller | `riscv,axi-sd-card-1.0` |
| `0x60010000` | UART (console) | `riscv,axi-uart-1.0` |
| `0x60020000` | Gigabit Ethernet DMA | `riscv,axi-ethernet-1.0` |
| `0x00000000` | DDR4 SDRAM (2 GB) | — |

IRQs: UART=1, SD=2, Ethernet=3.  
Ethernet PHY mode: `rgmii-rxid` (RTL8211F default RXDLY=1, no TX delay).  
Default IP: `192.168.1.10` — set your host to `192.168.1.102/24`.

---

## 40-Pin Expansion Connector (J1)

The 2.54 mm 2×20 header exposes 17 differential pairs across Banks 86 and 87 (3.3 V fixed, LVCMOS33).  
**IO17 (pins 35/36) is assigned as the external UART port** for a second serial console or GPIO UART.

```
Pin  Signal      FPGA Pin   Notes
───────────────────────────────────────────────
  1  —            —          (reserved/GND)
  2  +5 V         —          Power output
  3  IO1_N        D10        Bank 86
  4  IO1_P        D11        Bank 86
  5  IO2_N        E10        Bank 86
  6  IO2_P        E11        Bank 86
  7  IO3_N        B11        Bank 86
  8  IO3_P        C11        Bank 86
  9  IO4_N        C9         Bank 86
 10  IO4_P        D9         Bank 86
 11  IO5_N        A9         Bank 86
 12  IO5_P        B9         Bank 86
 13  IO6_N        A10        Bank 86
 14  IO6_P        B10        Bank 86
 15  IO7_N        A12        Bank 87
 16  IO7_P        A13        Bank 87
 17  IO8_N        A14        Bank 87
 18  IO8_P        B14        Bank 87
 19  IO9_N        C13        Bank 87
 20  IO9_P        C14        Bank 87
 21  IO10_N       B12        Bank 87
 22  IO10_P       C12        Bank 87
 23  IO11_N       D13        Bank 87
 24  IO11_P       D14        Bank 87
 25  IO12_N       E12        Bank 87
 26  IO12_P       E13        Bank 87
 27  IO13_N       F13        Bank 87
 28  IO13_P       F14        Bank 87
 29  IO14_N       F12        Bank 87
 30  IO14_P       G12        Bank 87
 31  IO15_N       G14        Bank 87
 32  IO15_P       H14        Bank 87
 33  IO16_N       J14        Bank 87
 34  IO16_P       J15        Bank 87
 35  IO17_N/RX    H13   <-- External UART RX (connect to remote TX)
 36  IO17_P/TX    J13   <-- External UART TX (connect to remote RX)
 37  GND          —
 38  GND          —
 39  +3.3 V       —          Power output
 40  +3.3 V       —          Power output
```

> **Warning:** Banks 86/87 are fixed at 3.3 V. Do not apply voltages above 3.3 V. Do not connect 3.3 V signals to HP bank pins.

---

## Build Instructions

### Prerequisites

- **OS:** Ubuntu 20.04 or 24.04 LTS (min 32 GB RAM)
- **Vivado:** 2023.2 with a device license for Kintex UltraScale+

Clone the repository with submodules:

```bash
git clone --recurse-submodules https://github.com/HalfVulpes/vivado-risc-v.git
cd vivado-risc-v
```

### Build the FPGA Bitstream

```bash
make BOARD=rk-xcku5p CONFIG=rocket64b4 bitstream
```

This generates `workspace/rk-xcku5p/rocket64b4/vivado/system.bit`.

For a 2-core build (faster synthesis):
```bash
make BOARD=rk-xcku5p CONFIG=rocket64b2 bitstream
```

### Build the SD Card Image

```bash
make BOARD=rk-xcku5p CONFIG=rocket64b4 debian-riscv64-micro.img
```

Flash to a MicroSD card (replace `/dev/sdX` with your device):

```bash
sudo dd if=debian-riscv64-micro.img of=/dev/sdX bs=4M status=progress
sync
```

### Program the FPGA

Via JTAG (one-time, volatile):
```bash
make BOARD=rk-xcku5p CONFIG=rocket64b4 vivado-flash
```

To program the QSPI flash for persistent boot:
```bash
make BOARD=rk-xcku5p CONFIG=rocket64b4 flash
```

> **Warning:** Only use Vivado 2023.2. Using 2024.x or later will permanently lock the QSPI flash chip.

---

## Boot Sequence

1. Insert MicroSD card with the Debian image
2. Connect the USB Type-C cable (FT2232HQ provides JTAG + UART)
3. Open a serial terminal: `115200 8N1` — the FT2232 Channel B is the console
4. Power on via the barrel jack or PCIe slot
5. FPGA loads bitstream from QSPI flash, then OpenSBI → U-Boot → Linux → Debian

Default login: `root` / `root`

---

## Ethernet

Connect a Cat5e/Cat6 cable to the RJ45 port.  
The RTL8211F PHY negotiates 10/100/1000 Mbps automatically.

Default IP: `192.168.1.10`  
Set your host: `192.168.1.102`, netmask `255.255.255.0`

```bash
ssh root@192.168.1.10
```

---

## External UART (40-Pin Connector)

A second UART is exposed on J1 pins 35/36 for use with external devices (3.3 V logic only):

| J1 Pin | Signal | FPGA | Connect to |
|---|---|---|---|
| 35 | EXT_RX (IO17_N) | H13 | Remote device TX |
| 36 | EXT_TX (IO17_P) | J13 | Remote device RX |
| 38 | GND | — | Remote device GND |

In the device tree this appears as `serial1`. Use at 115200 baud, 8N1.

---

## Board Files

All board support files are in [`board/rk-xcku5p/`](board/rk-xcku5p/):

| File | Description |
|---|---|
| `Makefile.inc` | Part number, flash config, 2 GB memory size |
| `top.xdc` | Bitstream config, 200 MHz diff clock, reset |
| `uart.xdc` | FT2232HQ UART + 40-pin external UART |
| `sdc.xdc` | MicroSD card pins |
| `ethernet.xdc` | RGMII pins and timing (Bank 66, 1.8 V) |
| `bootrom.dts` | Linux device tree for SoC peripherals |
| `ethernet-rk-xcku5p.v` | UltraScale+ RGMII MAC wrapper (BUFG + USE_CLK90) |
| `ethernet-rk-xcku5p.tcl` | Vivado source/constraint file adder |
| `riscv-2023.2.tcl` | Complete IPI block design (Vivado 2023.2) |

---

## Technical Notes

**HP Bank RGMII (Bank 66):**  
HP banks lack BUFR and ODELAYE3. The RGMII wrapper uses `CLOCK_INPUT_STYLE="BUFG"` and `USE_CLK90="TRUE"` — the 90° TX clock is supplied by clk_wiz_0 output 3.

**Single 200 MHz clock for DDR4 and user logic:**  
The block design uses two separate BD interface ports (`sys_diff_clock` and `ddr4_sys_clk`) both mapped to pins T24/U24. Vivado merges the IBUFDS at implementation.

**DDR4 reset:**  
The UltraScale+ DDR4 IP exposes `c0_ddr4_ui_clk_sync_rst` (active high). A `util_vector_logic` NOT gate converts it to `aresetn` for AXI peripherals. The 7-series `mem_reset_control` module is not used.

**Maximum core count:**  
4 cores (rocket64b4) fits within the LUT budget at 100 MHz. More cores are possible at lower clock frequencies, but 4 cores is the recommended maximum for reliable timing closure.
