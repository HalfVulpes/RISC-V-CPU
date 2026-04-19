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

### 1. Build Everything

Three separate targets build the FPGA bitstream, Linux kernel, and bootloader. Run them in order:

```bash
# FPGA bitstream (~45 min on a modern 8-core machine)
make BOARD=rk-xcku5p CONFIG=rocket64b4 bitstream

# Linux kernel Image (~15 min first time)
make CROSS_COMPILE=riscv64-linux-gnu- linux

# OpenSBI + U-Boot → workspace/boot.elf (the "BOOT.ELF" the bootrom loads)
make CROSS_COMPILE=riscv64-linux-gnu- bootloader
```

Artifacts produced:

| File | Purpose |
|---|---|
| `workspace/rocket64b4/rk-xcku5p-riscv.mcs` | SPI flash image for QSPI (bitstream only) |
| `workspace/rocket64b4/vivado-rk-xcku5p-riscv/rk-xcku5p-riscv.runs/impl_1/riscv_wrapper.bit` | Raw bitstream for JTAG load |
| `workspace/boot.elf` | OpenSBI + U-Boot payload — **rename to `BOOT.ELF`** on SD |
| `linux-stable/arch/riscv/boot/Image` | Linux 6.x kernel (~19 MB) |
| `workspace/rocket64b4/system-rk-xcku5p.dts` | Device tree source for the SoC |

For a 2-core build (faster synthesis, less LUT pressure):
```bash
make BOARD=rk-xcku5p CONFIG=rocket64b2 bitstream
```

### 2. Prepare the MicroSD Card

The bootrom embedded in the FPGA bitstream loads `BOOT.ELF` from a **FAT16/32 partition**. Linux then runs from an **ext4 rootfs**. So the card needs **two partitions**:

| Partition | FS | Contents |
|---|---|---|
| 1 (~200 MB) | FAT32 | `BOOT.ELF`, `Image`, `system.dtb`, `extlinux/extlinux.conf` |
| 2 (rest)    | ext4  | Debian rootfs |

Download the Debian RISC-V rootfs tarball:

```bash
make debian-riscv64/rootfs.tar.gz
```

Compile the device tree:

```bash
dtc -O dtb -o workspace/rocket64b4/system.dtb workspace/rocket64b4/system-rk-xcku5p.dts
```

Partition the card (replace `/dev/sdX` with your device — check `lsblk` first!):

```bash
sudo sgdisk --zap-all /dev/sdX
sudo sgdisk --new=1:0:+200M --typecode=1:EF00 --change-name=1:BOOT /dev/sdX
sudo sgdisk --new=2:0:0     --typecode=2:8300 --change-name=2:rootfs /dev/sdX
sudo mkfs.vfat -F 32 -n BOOT /dev/sdX1
sudo mkfs.ext4 -L rootfs /dev/sdX2
```

Populate the FAT boot partition:

```bash
sudo mkdir -p /mnt/boot
sudo mount /dev/sdX1 /mnt/boot
sudo cp workspace/boot.elf                                /mnt/boot/BOOT.ELF
sudo cp linux-stable/arch/riscv/boot/Image                /mnt/boot/Image
sudo cp workspace/rocket64b4/system.dtb                   /mnt/boot/system.dtb
sudo mkdir -p /mnt/boot/extlinux
sudo tee /mnt/boot/extlinux/extlinux.conf > /dev/null <<'EOF'
DEFAULT linux
LABEL linux
    KERNEL /Image
    FDT    /system.dtb
    APPEND earlycon console=ttyAU0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait locale.LANG=en_US.UTF-8
EOF
sudo umount /mnt/boot
```

Populate the ext4 rootfs:

```bash
sudo mkdir -p /mnt/rootfs
sudo mount /dev/sdX2 /mnt/rootfs
sudo tar -xzf debian-riscv64/rootfs.tar.gz -C /mnt/rootfs
sudo umount /mnt/rootfs
sync
```

### 3. Program the QSPI Flash

Plug the board into USB-C and verify detection:

```bash
lsusb | grep 0403:6010
# Bus 001 Device 002: ID 0403:6010 Future Technology Devices International, Ltd FT2232C/D/H Dual UART/FIFO IC
```

Start the Xilinx hardware server in a **separate terminal** (leave it running):

```bash
sudo /tools/Xilinx/Vitis/2023.2/bin/hw_server
```

> If you don't want to run `hw_server` as root every time, install the Digilent/Xilinx udev rules:
> ```bash
> sudo /tools/Xilinx/Vivado/2023.2/data/xicom/cable_drivers/lin64/install_script/install_drivers/install_drivers
> sudo usermod -aG plugdev $USER
> # log out and back in
> ```
> Afterward you can run `hw_server` without sudo.

Then in your working terminal, program the QSPI flash:

```bash
make BOARD=rk-xcku5p CONFIG=rocket64b4 flash
```

This takes ~5 minutes to erase, program, and verify the MX25U51245G flash.

For a volatile JTAG-only load (bitstream lost on power-off — useful for iteration):

```bash
make BOARD=rk-xcku5p CONFIG=rocket64b4 vivado-flash
```

> **Warning:** Only use Vivado 2023.2. Using 2024.x or later will permanently lock the QSPI flash chip.

---

## Boot Sequence

1. Insert MicroSD card prepared with the Debian rootfs
2. Connect the USB Type-C cable (FT2232HQ provides JTAG + UART)
3. Open a serial terminal on the FT2232 **Channel B** (see below)
4. Power on via the barrel jack or PCIe slot
5. FPGA loads bitstream from QSPI flash, then OpenSBI → U-Boot → Linux → Debian

### Opening the Serial Console

The FT2232HQ exposes two USB-serial devices when the board is plugged in:

- `/dev/ttyUSB0` → Channel A (JTAG — used by `hw_server`)
- `/dev/ttyUSB1` → **Channel B (UART console)**

Confirm the device appeared:

```bash
dmesg | tail -20 | grep ttyUSB
# [...] usb 1-1: FTDI USB Serial Device converter now attached to ttyUSB0
# [...] usb 1-1: FTDI USB Serial Device converter now attached to ttyUSB1
```

Open the console at **115200 8N1** with any of these tools (pick one you already have):

```bash
# picocom — recommended, lightweight
sudo apt install picocom
picocom -b 115200 /dev/ttyUSB1

# screen
screen /dev/ttyUSB1 115200

# minicom
minicom -D /dev/ttyUSB1 -b 115200

# tio — modern alternative
tio -b 115200 /dev/ttyUSB1
```

Exit keys: `Ctrl-A Ctrl-X` (picocom), `Ctrl-A K` (screen), `Ctrl-A Q` (minicom), `Ctrl-T Q` (tio).

> If you get `Permission denied` on `/dev/ttyUSB1`, add yourself to the `dialout` group:
> ```bash
> sudo usermod -aG dialout $USER
> ```
> Then log out and back in.

### Login

Once Linux boots you will see a `debian login:` prompt on the serial console. Default credentials:

| User | Password |
|---|---|
| `root` | `root` |
| `debian` | `debian` |

After login, verify the system:

```bash
uname -a               # should report riscv64 GNU/Linux
cat /proc/cpuinfo      # shows 4 rv64imafdc harts
df -h /                # rootfs on /dev/mmcblk0p2 (SD card ext4 partition)
ip addr show eth0      # default 192.168.1.10
```

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

## Troubleshooting

### No output on the serial console

Work through these checks in order:

**1. Is the board powered and is the bitstream loaded?**
- The "DONE" LED (white, near the FPGA) should light up a few seconds after power-on. If it's off, the QSPI flash does not contain a valid bitstream.
- The on-board fan should spin and the power LED should be on.

**2. Is the FT2232 USB actually connecting?**

```bash
lsusb | grep 0403:6010          # must show the FT2232H
dmesg | tail -20 | grep ttyUSB  # confirms /dev/ttyUSB0 (JTAG) + /dev/ttyUSB1 (console)
```

If you only see `ttyUSB1`, that's normal when `hw_server` has grabbed Channel A exclusively. Channel B (`ttyUSB1`) is the console.

**3. Did `hw_server` actually start?**

```bash
ss -tln | grep 3121             # must show LISTEN on :3121
pgrep -af hw_server             # must show a running process
```

If not, start it in a **separate terminal** and **leave it running** (don't Ctrl-C):

```bash
sudo /tools/Xilinx/Vitis/2023.2/bin/hw_server
```

Running it foreground without `&` and then closing the terminal will kill it. Either use a dedicated terminal or prefix with `nohup ... &`.

**4. Did the QSPI flash actually program?**

After `make flash` completes, you must **power-cycle** (full power-off, not just reset) for the FPGA to re-read QSPI. Then check the DONE LED.

Verify the flash content via `xsdb`:

```bash
env HW_SERVER_URL=tcp:localhost:3121 xsdb -quiet board/jtag-freq.tcl
```

**5. Is the SD card layout correct?**

The bootrom (embedded in the bitstream) loads `BOOT.ELF` from the **first FAT partition**. The filename is case-sensitive — it must be exactly `BOOT.ELF`. Confirm:

```bash
sudo mount /dev/sdX1 /mnt/boot
ls -la /mnt/boot/
# Must contain: BOOT.ELF, Image, system.dtb, extlinux/extlinux.conf
sudo umount /mnt/boot
```

If the bitstream loads (DONE LED on) but `BOOT.ELF` is missing, you'll see nothing on the console because the bootrom prints its error message *after* it initializes the UART — but if the UART clock isn't configured yet, the error is silent.

**6. Still nothing?** Try loading everything via JTAG (bypasses QSPI + SD FAT):

```bash
# Build the initrd ramdisk (needed for jtag-boot)
make debian-riscv64/ramdisk

# Load bitstream + kernel + ramdisk directly via JTAG
make BOARD=rk-xcku5p CONFIG=rocket64b4 JTAG_BOOT=1 jtag-boot
```

This streams the bitstream, boot.elf, Image, and ramdisk over JTAG into FPGA memory, then releases reset. You should immediately see OpenSBI banner text. If this works but `make flash` boot does not, the issue is in the SD card or QSPI contents, not the bitstream itself.

### Permission denied on `/dev/ttyUSB1`

```bash
sudo usermod -aG dialout $USER
# log out and back in
```

### `xsdb: command not found` with sudo

`sudo` strips the Vivado PATH. Either use `sudo -E`, or install the udev rules (see step 3 above) and run `hw_server` without sudo.

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
