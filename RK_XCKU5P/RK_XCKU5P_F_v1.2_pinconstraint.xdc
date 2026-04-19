################################################################################
# RK-XCKU5P-F V1.2 Development Board - Master Pin Constraint File
# Board Manufacturer : RIGUKE
# FPGA               : AMD Kintex UltraScale+  XCKU5P-2FFVB676I
# Package            : FFVB676 (fine-pitch BGA, 676 balls)
# Speed Grade        : -2I  (Industrial, -40 C to +100 C)
# Vivado Version     : 2023.2 (use for this project; factory demos use 2023.1)
#
# Sources used to build this file:
#   - RIGUKE factory pin constraint (V0.2, 2025-08-07) for non-DDR peripherals
#   - KU5P_DEMO/06_DDR_AXI/ddr4_0_ex/imports/example_design.xdc for DDR4
#   - RK-XCKU5P-F V1.2 schematic (revision V1.2)
#
# Usage: Add this XDC to your Vivado project as a constraints file, then
#        comment out the blocks you do not use. Rename ports as needed to
#        match your top-level HDL.
#
# ------------------------------------------------------------------------------
# I/O Bank Summary
# ------------------------------------------------------------------------------
#   Bank 64  HP  1.2 V  DDR4 data  (DQ[0:15], DM/DQS for bytes 0-1)
#   Bank 65  HP  1.2 V  DDR4 addr/ctrl/clock, DDR4 DQ[16:31] for bytes 2-3,
#                       SYS_CLK diff, MIPI data lanes, PCIE_PERST_N
#   Bank 66  HP  1.8 V  Gigabit Ethernet RGMII, FMC LA[00-16], MIPI camera ctrl
#   Bank 67  HP  1.8 V  FMC LA[17-33]
#   Bank 84  HD  3.3 V  FT2232 UART, MicroSD card, QSFP28 control signals
#   Bank 86  HD  3.3 V  LED[1-4], KEY[1-4], FAN, FMC SCL/SDA/PWRGD, 40-PIN IO1-6
#   Bank 87  HD  3.3 V  40-PIN IO7-17
#   Bank 224 GTY  --    PCIe 3.0 x4 transceivers
#   Bank 225 GTY  --    QSFP28 x4 transceivers
#   Bank 226 GTY  --    FMC DP0-DP3 transceivers
#   Bank 227 GTY  --    FMC DP4-DP7 transceivers
#
# WARNING: 40-PIN IO banks 86/87 are FIXED at 3.3 V -- DO NOT change VCCO.
# WARNING: HP banks 64/65 are 1.2 V and HP bank 66/67 defaults to 1.8 V (VADJ1).
#          To switch FMC VADJ1 to 1.2 V, change DCDC FB resistor "RA" to 1 kΩ.
# WARNING: LEDs are active-LOW (output 0 = LED on).
# WARNING: Keys are active-LOW with 4.7 kΩ pull-up (input 0 = key pressed).
################################################################################


##############################################################################
# BITSTREAM CONFIGURATION
# Compress bitstream and use the factory-recommended 63.8 MHz SPI clock rate.
##############################################################################
set_property BITSTREAM.GENERAL.COMPRESS    TRUE   [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE   63.8   [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4      [current_design]
set_property CONFIG_VOLTAGE                1.8    [current_design]
set_property CONFIG_MODE                   SPIx4  [current_design]
set_property CFGBVS                        GND    [current_design]


##############################################################################
# SYSTEM CLOCK  (Bank 65, HP, 1.2 V)
# 200 MHz differential oscillator, reference Y2 (SG3225VAN 200.000000M-KEGA3)
##############################################################################
set_property PACKAGE_PIN T24 [get_ports sys_clk_p]
set_property PACKAGE_PIN U24 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_n]

create_clock -period 5.000 -name sys_clk [get_ports sys_clk_p]

# NOTE: A reserved single-ended clock pad (PL_CLK, reference Y4) is not soldered
#       by default. It connects to an HD-bank pad if populated.


##############################################################################
# SYSTEM RESET  (Bank 86, HD, 3.3 V  --  active LOW)
# KEY1 is reused as system reset in most factory demos.
##############################################################################
set_property PACKAGE_PIN K9  [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]


##############################################################################
# USER KEYS  (Bank 86, HD, 3.3 V  --  active LOW, 4.7 kΩ pull-up + 100 nF debounce)
# KEY1 = K9   KEY2 = K10   KEY3 = J10   KEY4 = J11
##############################################################################
set_property PACKAGE_PIN K9  [get_ports {key[0]}]
set_property PACKAGE_PIN K10 [get_ports {key[1]}]
set_property PACKAGE_PIN J10 [get_ports {key[2]}]
set_property PACKAGE_PIN J11 [get_ports {key[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[*]}]

# NOTE: K9 is shared with sys_rst_n above. Use only one definition per project.


##############################################################################
# USER LEDs  (Bank 86, HD, 3.3 V  --  active LOW, driven via MMBT3904 NPN)
# LED1 = H9   LED2 = J9   LED3 = G11   LED4 = H11
##############################################################################
set_property PACKAGE_PIN H9  [get_ports {led[0]}]
set_property PACKAGE_PIN J9  [get_ports {led[1]}]
set_property PACKAGE_PIN G11 [get_ports {led[2]}]
set_property PACKAGE_PIN H11 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]


##############################################################################
# FAN  (Bank 86, HD, 3.3 V  --  2-wire fan, no PWM speed control)
##############################################################################
set_property PACKAGE_PIN G9  [get_ports fan_ctrl]
set_property IOSTANDARD LVCMOS33 [get_ports fan_ctrl]


##############################################################################
# UART via FT2232HQ  (Bank 84, HD, 3.3 V)
# FT2232HQ provides JTAG (Channel A, MPSSE) and UART (Channel B, VCP) on the
# same USB Type-C cable. Channel A does NOT enumerate as /dev/ttyUSB*.
##############################################################################
set_property PACKAGE_PIN AD13 [get_ports uart_rx]
set_property PACKAGE_PIN AC14 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]


##############################################################################
# MicroSD CARD  (Bank 84, HD, 3.3 V)
# Supports 4-bit SD mode and SPI mode. sd_d0 has an on-board pull-up.
##############################################################################
set_property PACKAGE_PIN Y16  [get_ports sd_cd]
set_property PACKAGE_PIN Y15  [get_ports sd_clk]
set_property PACKAGE_PIN AA15 [get_ports sd_cmd]
set_property PACKAGE_PIN AB14 [get_ports sd_d0]
set_property PACKAGE_PIN AA14 [get_ports sd_d1]
set_property PACKAGE_PIN AB16 [get_ports sd_d2]
set_property PACKAGE_PIN AB15 [get_ports sd_d3]

set_property IOSTANDARD LVCMOS33 [get_ports sd_cd]
set_property IOSTANDARD LVCMOS33 [get_ports sd_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sd_cmd]
set_property IOSTANDARD LVCMOS33 [get_ports sd_d0]
set_property IOSTANDARD LVCMOS33 [get_ports sd_d1]
set_property IOSTANDARD LVCMOS33 [get_ports sd_d2]
set_property IOSTANDARD LVCMOS33 [get_ports sd_d3]
set_property PULLUP true         [get_ports sd_d0]

# SPI-mode aliases (same physical pins):
#   sd_miso = sd_d0  (AB14)   -- has pull-up
#   sd_mosi = sd_cmd (AA15)
#   sd_ncs  = sd_d3  (AB15)
#
# NOTE: The RTL8211F PHY's PHYRSTB/INTB and any sd_reset / sd_power signals
#       are NOT routed to FPGA GPIO on this board. PHY reset is handled by the
#       board power-on reset circuit.


##############################################################################
# GIGABIT ETHERNET  (Bank 66, HP, 1.8 V)
# PHY: Realtek RTL8211F-CG  (10/100/1000 Mbps, RGMII)
# Factory default board IP: 192.168.1.10
##############################################################################
set_property PACKAGE_PIN K22 [get_ports eth_rxck]
set_property PACKAGE_PIN K23 [get_ports eth_rxctl]
set_property PACKAGE_PIN L24 [get_ports {eth_rxd[0]}]
set_property PACKAGE_PIN L25 [get_ports {eth_rxd[1]}]
set_property PACKAGE_PIN K25 [get_ports {eth_rxd[2]}]
set_property PACKAGE_PIN K26 [get_ports {eth_rxd[3]}]

set_property PACKAGE_PIN M25 [get_ports eth_txck]
set_property PACKAGE_PIN M26 [get_ports eth_txctl]
set_property PACKAGE_PIN L23 [get_ports {eth_txd[0]}]
set_property PACKAGE_PIN L22 [get_ports {eth_txd[1]}]
set_property PACKAGE_PIN L20 [get_ports {eth_txd[2]}]
set_property PACKAGE_PIN K20 [get_ports {eth_txd[3]}]

set_property PACKAGE_PIN L19 [get_ports eth_mdc]
set_property PACKAGE_PIN M19 [get_ports eth_mdio]

set_property IOSTANDARD LVCMOS18 [get_ports eth_rxck]
set_property IOSTANDARD LVCMOS18 [get_ports eth_rxctl]
set_property IOSTANDARD LVCMOS18 [get_ports {eth_rxd[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports eth_txck]
set_property IOSTANDARD LVCMOS18 [get_ports eth_txctl]
set_property IOSTANDARD LVCMOS18 [get_ports {eth_txd[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports eth_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports eth_mdio]

# NOTE: RTL8211F PHYRSTB and INTB pins are tied to board-level pull-ups only;
#       they are NOT routed to FPGA I/O. Do not attempt to constrain them.


##############################################################################
# MIPI CSI-2 Camera Interface
# Data lanes: Bank 65 (HP 1.2 V)  --  require Xilinx MIPI RX subsystem IP
# Camera control: Bank 66 (HP 1.8 V)  --  LVCMOS18
#
# NOTE: MIPI lane pins are commented out -- they must be configured via the
#       MIPI IP wizard, which sets IOSTANDARD automatically.
# NOTE (V0.2 update): Use the on-board oscillator as the IMX415 camera clock.
#       DO NOT drive an FPGA-generated clock to the camera (known hardware bug).
##############################################################################
# -- MIPI data/clock lanes (commented; configure via MIPI IP)
# set_property PACKAGE_PIN U19 [get_ports mipi_clk_p]
# set_property PACKAGE_PIN V19 [get_ports mipi_clk_n]
# set_property PACKAGE_PIN T22 [get_ports {mipi_data_p[0]}]
# set_property PACKAGE_PIN T23 [get_ports {mipi_data_n[0]}]
# set_property PACKAGE_PIN U21 [get_ports {mipi_data_p[1]}]
# set_property PACKAGE_PIN U22 [get_ports {mipi_data_n[1]}]
# set_property PACKAGE_PIN T20 [get_ports {mipi_data_p[2]}]
# set_property PACKAGE_PIN U20 [get_ports {mipi_data_n[2]}]
# set_property PACKAGE_PIN V21 [get_ports {mipi_data_p[3]}]
# set_property PACKAGE_PIN V22 [get_ports {mipi_data_n[3]}]
#
# WARNING: Most of the MIPI data-lane pins above (T20/T22/T23/U19/U20/U21/U22
#          /V21/V22) overlap with DDR4 Byte 2/3 DQ/DQS. Using MIPI and DDR4
#          simultaneously is NOT possible on this board.

# -- Camera control signals (Bank 66, LVCMOS18)
set_property PACKAGE_PIN K21 [get_ports cam_clk]
set_property PACKAGE_PIN J21 [get_ports cam_rst]
set_property PACKAGE_PIN M21 [get_ports cam_pwdn]
set_property PACKAGE_PIN J25 [get_ports cam_scl]
set_property PACKAGE_PIN J26 [get_ports cam_sda]
set_property IOSTANDARD LVCMOS18 [get_ports cam_clk]
set_property IOSTANDARD LVCMOS18 [get_ports cam_rst]
set_property IOSTANDARD LVCMOS18 [get_ports cam_pwdn]
set_property IOSTANDARD LVCMOS18 [get_ports cam_scl]
set_property IOSTANDARD LVCMOS18 [get_ports cam_sda]


##############################################################################
# QSFP28  (GTY Bank 225 + Bank 84 control signals, HD 3.3 V)
# 1x QSFP28 port, up to 25 Gb/s per lane, 100 Gb/s aggregate.
# Reference clock: 156.25 MHz differential (GT_CLK156P25, MGTREFCLK0_225)
##############################################################################
# QSFP control signals (Bank 84, LVCMOS33)
set_property PACKAGE_PIN Y13  [get_ports qsfp_intl]
set_property PACKAGE_PIN W14  [get_ports qsfp_lpmode]
set_property PACKAGE_PIN AA13 [get_ports qsfp_modprsl]
set_property PACKAGE_PIN W13  [get_ports qsfp_modsell]
set_property PACKAGE_PIN W12  [get_ports qsfp_resetl]
set_property PACKAGE_PIN AE15 [get_ports qsfp_scl]
set_property PACKAGE_PIN AE13 [get_ports qsfp_sda]
set_property IOSTANDARD LVCMOS33 [get_ports qsfp_intl]
set_property IOSTANDARD LVCMOS33 [get_ports qsfp_lpmode]
set_property IOSTANDARD LVCMOS33 [get_ports qsfp_modprsl]
set_property IOSTANDARD LVCMOS33 [get_ports qsfp_modsell]
set_property IOSTANDARD LVCMOS33 [get_ports qsfp_resetl]
set_property IOSTANDARD LVCMOS33 [get_ports qsfp_scl]
set_property IOSTANDARD LVCMOS33 [get_ports qsfp_sda]

# QSFP GTY transceiver pin reference (configured via GT Wizard, no IOSTANDARD)
#   Lane 0:  RX Y2/Y1     TX AA5/AA4   (MGTYRXP0_225 / MGTYTXP0_225)
#   Lane 1:  RX V2/V1     TX W5/W4
#   Lane 2:  RX T2/T1     TX U5/U4
#   Lane 3:  RX P2/P1     TX R5/R4
#   RefClk0: V7 (P) / V6 (N)


##############################################################################
# PCIe 3.0 x4  (GTY Bank 224 + Bank 65 reset)
# Physical x8 slot, electrical x4. Up to 8 Gb/s per lane.
# Reference clock: AB7 (P) / AB6 (N), MGTREFCLK0_224
##############################################################################
# PCIe reset (Bank 65, HP 1.2 V, active LOW)
set_property PACKAGE_PIN T19 [get_ports pcie_perst_n]
set_property IOSTANDARD LVCMOS12 [get_ports pcie_perst_n]

# PCIe GTY transceiver pin reference (configured via PCIe IP, no IOSTANDARD)
#   Lane 0:  RX AB2/AB1   TX AC5/AC4
#   Lane 1:  RX AD2/AD1   TX AD7/AD6
#   Lane 2:  RX AE4/AE3   TX AE9/AE8
#   Lane 3:  RX AF2/AF1   TX AF7/AF6
#   RefClk0: AB7 (P) / AB6 (N)


##############################################################################
# DDR4 SDRAM  (Banks 64 + 65, HP, 1.2 V)
# Two chips: Micron MT40A512M16LY-062E
#   -  512 Mrows × 16-bit × 2 chips = 2 GB total, 32-bit bus
#   -  Speed grade -062E = DDR4-3200 capable; run at DDR4-2666 (750 ps, CL19)
#   -  x16 parts have ONE bank group line only (BG[0]); no BG[1].
#
# FACTORY-VERIFIED pinout (from KU5P_DEMO/06_DDR_AXI/ddr4_0_ex/imports/
# example_design.xdc). DQs split across Bank 64 (bytes 0/1) and Bank 65
# (bytes 2/3). Reset signal at AC16, not P19 (earlier reference material
# was stale/aspirational).
#
# MIG IP CONFIGURATION:
#   C0.DDR4_MemoryPart = MT40A512M16HA-075E   -- NOT "-LY-075"; the HA silicon
#                                                timing set matches the LY chips
#                                                on this board at DDR4-2666.
#   C0.DDR4_InputClockPeriod = 5000 (200 MHz input)
#   C0.DDR4_TimePeriod       = 750 (DDR4-2666)
#   C0.DDR4_DataWidth        = 32
#   C0.DDR4_CasLatency       = 19
#   C0.DDR4_CasWriteLatency  = 14
#   C0.DDR4_PhyClockRatio    = 4:1
#   C0.DDR4_DataMask         = DM_NO_DBI
#   C0.DDR4_OutputDriverImpedenceControl = RZQ/7
#   C0.DDR4_OnDieTermination = RZQ/6
#
# The pin assignments below can be let MIG auto-generate, OR supplied explicitly
# (uncomment to use). MIG uses the exact same pinout either way because of the
# byte-group constraints imposed by the UltraScale+ architecture.
##############################################################################
# -- Address [0:16], Bank 65
# set_property PACKAGE_PIN AE22 [get_ports {ddr4_adr[0]}]
# set_property PACKAGE_PIN AF22 [get_ports {ddr4_adr[1]}]
# set_property PACKAGE_PIN AD23 [get_ports {ddr4_adr[2]}]
# set_property PACKAGE_PIN AE23 [get_ports {ddr4_adr[3]}]
# set_property PACKAGE_PIN AC22 [get_ports {ddr4_adr[4]}]
# set_property PACKAGE_PIN AC23 [get_ports {ddr4_adr[5]}]
# set_property PACKAGE_PIN AB21 [get_ports {ddr4_adr[6]}]
# set_property PACKAGE_PIN AC21 [get_ports {ddr4_adr[7]}]
# set_property PACKAGE_PIN AF20 [get_ports {ddr4_adr[8]}]
# set_property PACKAGE_PIN AD20 [get_ports {ddr4_adr[9]}]
# set_property PACKAGE_PIN AE20 [get_ports {ddr4_adr[10]}]
# set_property PACKAGE_PIN AC19 [get_ports {ddr4_adr[11]}]
# set_property PACKAGE_PIN AD19 [get_ports {ddr4_adr[12]}]
# set_property PACKAGE_PIN AF18 [get_ports {ddr4_adr[13]}]
# set_property PACKAGE_PIN AF19 [get_ports {ddr4_adr[14]}]
# set_property PACKAGE_PIN AC18 [get_ports {ddr4_adr[15]}]
# set_property PACKAGE_PIN AD18 [get_ports {ddr4_adr[16]}]
# -- Control
# set_property PACKAGE_PIN Y21  [get_ports ddr4_act_n]
# set_property PACKAGE_PIN AE16 [get_ports {ddr4_cs_n[0]}]
# set_property PACKAGE_PIN AE18 [get_ports {ddr4_cke[0]}]
# set_property PACKAGE_PIN AE26 [get_ports {ddr4_odt[0]}]
# set_property PACKAGE_PIN AC16 [get_ports ddr4_reset_n]
# -- Bank address / group (x16: BG has 1 bit)
# set_property PACKAGE_PIN AE17 [get_ports {ddr4_ba[0]}]
# set_property PACKAGE_PIN AF17 [get_ports {ddr4_ba[1]}]
# set_property PACKAGE_PIN AD16 [get_ports {ddr4_bg[0]}]
# -- Memory clock
# set_property PACKAGE_PIN AA22 [get_ports {ddr4_ck_t[0]}]
# set_property PACKAGE_PIN AB22 [get_ports {ddr4_ck_c[0]}]
# -- DQS pairs
# set_property PACKAGE_PIN AC26 [get_ports {ddr4_dqs_t[0]}]
# set_property PACKAGE_PIN AD26 [get_ports {ddr4_dqs_c[0]}]
# set_property PACKAGE_PIN AB17 [get_ports {ddr4_dqs_t[1]}]
# set_property PACKAGE_PIN AC17 [get_ports {ddr4_dqs_c[1]}]
# set_property PACKAGE_PIN V21  [get_ports {ddr4_dqs_t[2]}]
# set_property PACKAGE_PIN V22  [get_ports {ddr4_dqs_c[2]}]
# set_property PACKAGE_PIN W25  [get_ports {ddr4_dqs_t[3]}]
# set_property PACKAGE_PIN W26  [get_ports {ddr4_dqs_c[3]}]
# -- Data mask (DM_NO_DBI mode)
# set_property PACKAGE_PIN AE25 [get_ports {ddr4_dm_n[0]}]
# set_property PACKAGE_PIN Y20  [get_ports {ddr4_dm_n[1]}]
# set_property PACKAGE_PIN U19  [get_ports {ddr4_dm_n[2]}]
# set_property PACKAGE_PIN Y22  [get_ports {ddr4_dm_n[3]}]
# -- Data byte 0 (Bank 64)
# set_property PACKAGE_PIN AB25 [get_ports {ddr4_dq[0]}]
# set_property PACKAGE_PIN AB26 [get_ports {ddr4_dq[1]}]
# set_property PACKAGE_PIN AF24 [get_ports {ddr4_dq[2]}]
# set_property PACKAGE_PIN AF25 [get_ports {ddr4_dq[3]}]
# set_property PACKAGE_PIN AD24 [get_ports {ddr4_dq[4]}]
# set_property PACKAGE_PIN AD25 [get_ports {ddr4_dq[5]}]
# set_property PACKAGE_PIN AB24 [get_ports {ddr4_dq[6]}]
# set_property PACKAGE_PIN AC24 [get_ports {ddr4_dq[7]}]
# -- Data byte 1 (Bank 64)
# set_property PACKAGE_PIN AA19 [get_ports {ddr4_dq[8]}]
# set_property PACKAGE_PIN AB19 [get_ports {ddr4_dq[9]}]
# set_property PACKAGE_PIN AA20 [get_ports {ddr4_dq[10]}]
# set_property PACKAGE_PIN AB20 [get_ports {ddr4_dq[11]}]
# set_property PACKAGE_PIN Y17  [get_ports {ddr4_dq[12]}]
# set_property PACKAGE_PIN AA17 [get_ports {ddr4_dq[13]}]
# set_property PACKAGE_PIN Y18  [get_ports {ddr4_dq[14]}]
# set_property PACKAGE_PIN AA18 [get_ports {ddr4_dq[15]}]
# -- Data byte 2 (Bank 65)
# set_property PACKAGE_PIN U21  [get_ports {ddr4_dq[16]}]
# set_property PACKAGE_PIN U22  [get_ports {ddr4_dq[17]}]
# set_property PACKAGE_PIN T20  [get_ports {ddr4_dq[18]}]
# set_property PACKAGE_PIN U20  [get_ports {ddr4_dq[19]}]
# set_property PACKAGE_PIN T22  [get_ports {ddr4_dq[20]}]
# set_property PACKAGE_PIN T23  [get_ports {ddr4_dq[21]}]
# set_property PACKAGE_PIN W19  [get_ports {ddr4_dq[22]}]
# set_property PACKAGE_PIN W20  [get_ports {ddr4_dq[23]}]
# -- Data byte 3 (Bank 65)
# set_property PACKAGE_PIN Y25  [get_ports {ddr4_dq[24]}]
# set_property PACKAGE_PIN Y26  [get_ports {ddr4_dq[25]}]
# set_property PACKAGE_PIN AA24 [get_ports {ddr4_dq[26]}]
# set_property PACKAGE_PIN AA25 [get_ports {ddr4_dq[27]}]
# set_property PACKAGE_PIN V23  [get_ports {ddr4_dq[28]}]
# set_property PACKAGE_PIN W23  [get_ports {ddr4_dq[29]}]
# set_property PACKAGE_PIN V24  [get_ports {ddr4_dq[30]}]
# set_property PACKAGE_PIN W24  [get_ports {ddr4_dq[31]}]


##############################################################################
# FMC HPC CONNECTOR  (LA pairs: Banks 66/67, HP 1.8 V default; COM: Bank 86)
# 34 differential LA pairs + 8 GTY DP lanes + I2C + power good
# GTY lanes: Bank 226 (DP0-3) / Bank 227 (DP4-7), up to 25 Gb/s each.
# Reference clocks:
#   GBTCLK0 M2C: P7 (P) / P6 (N)  --  Bank 226 MGTREFCLK0
#   GBTCLK1 M2C: K7 (P) / K6 (N)  --  Bank 227 MGTREFCLK0
##############################################################################
# Clock pairs (Bank 66, LVDS)
set_property PACKAGE_PIN H23 [get_ports fmc_clk0_p]
set_property PACKAGE_PIN H24 [get_ports fmc_clk0_n]
set_property PACKAGE_PIN B19 [get_ports fmc_clk1_p]
set_property PACKAGE_PIN B20 [get_ports fmc_clk1_n]
set_property IOSTANDARD LVDS [get_ports fmc_clk0_p]
set_property IOSTANDARD LVDS [get_ports fmc_clk0_n]
set_property IOSTANDARD LVDS [get_ports fmc_clk1_p]
set_property IOSTANDARD LVDS [get_ports fmc_clk1_n]

# LA pairs (Bank 66) -- LA00-LA16
set_property PACKAGE_PIN G24 [get_ports fmc_la00_cc_p]
set_property PACKAGE_PIN G25 [get_ports fmc_la00_cc_n]
set_property PACKAGE_PIN J23 [get_ports fmc_la01_cc_p]
set_property PACKAGE_PIN J24 [get_ports fmc_la01_cc_n]
set_property PACKAGE_PIN H21 [get_ports fmc_la02_p]
set_property PACKAGE_PIN H22 [get_ports fmc_la02_n]
set_property PACKAGE_PIN J19 [get_ports fmc_la03_p]
set_property PACKAGE_PIN J20 [get_ports fmc_la03_n]
set_property PACKAGE_PIN H26 [get_ports fmc_la04_p]
set_property PACKAGE_PIN G26 [get_ports fmc_la04_n]
set_property PACKAGE_PIN F24 [get_ports fmc_la05_p]
set_property PACKAGE_PIN F25 [get_ports fmc_la05_n]
set_property PACKAGE_PIN G20 [get_ports fmc_la06_p]
set_property PACKAGE_PIN G21 [get_ports fmc_la06_n]
set_property PACKAGE_PIN D24 [get_ports fmc_la07_p]
set_property PACKAGE_PIN D25 [get_ports fmc_la07_n]
set_property PACKAGE_PIN D26 [get_ports fmc_la08_p]
set_property PACKAGE_PIN C26 [get_ports fmc_la08_n]
set_property PACKAGE_PIN E25 [get_ports fmc_la09_p]
set_property PACKAGE_PIN E26 [get_ports fmc_la09_n]
set_property PACKAGE_PIN B25 [get_ports fmc_la10_p]
set_property PACKAGE_PIN B26 [get_ports fmc_la10_n]
set_property PACKAGE_PIN A24 [get_ports fmc_la11_p]
set_property PACKAGE_PIN A25 [get_ports fmc_la11_n]
set_property PACKAGE_PIN D23 [get_ports fmc_la12_p]
set_property PACKAGE_PIN C24 [get_ports fmc_la12_n]
set_property PACKAGE_PIN F23 [get_ports fmc_la13_p]
set_property PACKAGE_PIN E23 [get_ports fmc_la13_n]
set_property PACKAGE_PIN C23 [get_ports fmc_la14_p]
set_property PACKAGE_PIN B24 [get_ports fmc_la14_n]
set_property PACKAGE_PIN H18 [get_ports fmc_la15_p]
set_property PACKAGE_PIN H19 [get_ports fmc_la15_n]
set_property PACKAGE_PIN E21 [get_ports fmc_la16_p]
set_property PACKAGE_PIN D21 [get_ports fmc_la16_n]

# LA pairs (Bank 67) -- LA17-LA33
set_property PACKAGE_PIN C18 [get_ports fmc_la17_cc_p]
set_property PACKAGE_PIN C19 [get_ports fmc_la17_cc_n]
set_property PACKAGE_PIN D19 [get_ports fmc_la18_cc_p]
set_property PACKAGE_PIN D20 [get_ports fmc_la18_cc_n]
set_property PACKAGE_PIN A22 [get_ports fmc_la19_p]
set_property PACKAGE_PIN A23 [get_ports fmc_la19_n]
set_property PACKAGE_PIN F20 [get_ports fmc_la20_p]
set_property PACKAGE_PIN E20 [get_ports fmc_la20_n]
set_property PACKAGE_PIN C21 [get_ports fmc_la21_p]
set_property PACKAGE_PIN B21 [get_ports fmc_la21_n]
set_property PACKAGE_PIN H16 [get_ports fmc_la22_p]
set_property PACKAGE_PIN G16 [get_ports fmc_la22_n]
set_property PACKAGE_PIN C22 [get_ports fmc_la23_p]
set_property PACKAGE_PIN B22 [get_ports fmc_la23_n]
set_property PACKAGE_PIN A17 [get_ports fmc_la24_p]
set_property PACKAGE_PIN A18 [get_ports fmc_la24_n]
set_property PACKAGE_PIN E18 [get_ports fmc_la25_p]
set_property PACKAGE_PIN D18 [get_ports fmc_la25_n]
set_property PACKAGE_PIN A19 [get_ports fmc_la26_p]
set_property PACKAGE_PIN A20 [get_ports fmc_la26_n]
set_property PACKAGE_PIN F18 [get_ports fmc_la27_p]
set_property PACKAGE_PIN F19 [get_ports fmc_la27_n]
set_property PACKAGE_PIN C17 [get_ports fmc_la28_p]
set_property PACKAGE_PIN B17 [get_ports fmc_la28_n]
set_property PACKAGE_PIN E16 [get_ports fmc_la29_p]
set_property PACKAGE_PIN E17 [get_ports fmc_la29_n]
set_property PACKAGE_PIN D16 [get_ports fmc_la30_p]
set_property PACKAGE_PIN C16 [get_ports fmc_la30_n]
set_property PACKAGE_PIN G15 [get_ports fmc_la31_p]
set_property PACKAGE_PIN F15 [get_ports fmc_la31_n]
set_property PACKAGE_PIN B15 [get_ports fmc_la32_p]
set_property PACKAGE_PIN A15 [get_ports fmc_la32_n]
set_property PACKAGE_PIN E15 [get_ports fmc_la33_p]
set_property PACKAGE_PIN D15 [get_ports fmc_la33_n]

# LVDS IOSTANDARD for all LA pairs
set_property IOSTANDARD LVDS [get_ports {fmc_la*_p fmc_la*_n}]

# FMC I2C and power good (Bank 86, LVCMOS33)
set_property PACKAGE_PIN F10 [get_ports fmc_scl]
set_property PACKAGE_PIN F9  [get_ports fmc_sda]
set_property PACKAGE_PIN G10 [get_ports fmc_pwrgd]
set_property IOSTANDARD LVCMOS33 [get_ports fmc_scl]
set_property IOSTANDARD LVCMOS33 [get_ports fmc_sda]
set_property IOSTANDARD LVCMOS33 [get_ports fmc_pwrgd]

# FMC DP GTY transceiver reference (configured via GT Wizard, no IOSTANDARD)
#   DP0  C2M: N5/N4    M2C: M2/M1     (Bank 226 MGTYTXP0/RXP0)
#   DP1  C2M: L5/L4    M2C: K2/K1
#   DP2  C2M: J5/J4    M2C: H2/H1
#   DP3  C2M: G5/G4    M2C: F2/F1
#   DP4  C2M: F7/F6    M2C: D2/D1     (Bank 227)
#   DP5  C2M: E5/E4    M2C: C4/C3
#   DP6  C2M: D7/D6    M2C: B2/B1
#   DP7  C2M: B7/B6    M2C: A4/A3
#   GBTCLK0 M2C: P7/P6   GBTCLK1 M2C: K7/K6


##############################################################################
# 40-PIN EXPANSION IO  (Banks 86 and 87, HD, 3.3 V FIXED)
# 2.54 mm HDR2×20 connector (J1)
# 17 differential pairs total; all traces length-matched to 2880.464 mil.
#
# Pin layout (pin 1 = GND/reserved, pin 2 = +5 V, pins 37/38 = GND, 39/40 = +3.3 V)
##############################################################################
# Bank 86 (IO1-IO6)
set_property PACKAGE_PIN D10 [get_ports {io_n[1]}]
set_property PACKAGE_PIN D11 [get_ports {io_p[1]}]
set_property PACKAGE_PIN E10 [get_ports {io_n[2]}]
set_property PACKAGE_PIN E11 [get_ports {io_p[2]}]
set_property PACKAGE_PIN B11 [get_ports {io_n[3]}]
set_property PACKAGE_PIN C11 [get_ports {io_p[3]}]
set_property PACKAGE_PIN C9  [get_ports {io_n[4]}]
set_property PACKAGE_PIN D9  [get_ports {io_p[4]}]
set_property PACKAGE_PIN A9  [get_ports {io_n[5]}]
set_property PACKAGE_PIN B9  [get_ports {io_p[5]}]
set_property PACKAGE_PIN A10 [get_ports {io_n[6]}]
set_property PACKAGE_PIN B10 [get_ports {io_p[6]}]

# Bank 87 (IO7-IO17)
set_property PACKAGE_PIN A12 [get_ports {io_n[7]}]
set_property PACKAGE_PIN A13 [get_ports {io_p[7]}]
set_property PACKAGE_PIN A14 [get_ports {io_n[8]}]
set_property PACKAGE_PIN B14 [get_ports {io_p[8]}]
set_property PACKAGE_PIN C13 [get_ports {io_n[9]}]
set_property PACKAGE_PIN C14 [get_ports {io_p[9]}]
set_property PACKAGE_PIN B12 [get_ports {io_n[10]}]
set_property PACKAGE_PIN C12 [get_ports {io_p[10]}]
set_property PACKAGE_PIN D13 [get_ports {io_n[11]}]
set_property PACKAGE_PIN D14 [get_ports {io_p[11]}]
set_property PACKAGE_PIN E12 [get_ports {io_n[12]}]
set_property PACKAGE_PIN E13 [get_ports {io_p[12]}]
set_property PACKAGE_PIN F13 [get_ports {io_n[13]}]
set_property PACKAGE_PIN F14 [get_ports {io_p[13]}]
set_property PACKAGE_PIN F12 [get_ports {io_n[14]}]
set_property PACKAGE_PIN G12 [get_ports {io_p[14]}]
set_property PACKAGE_PIN G14 [get_ports {io_n[15]}]
set_property PACKAGE_PIN H14 [get_ports {io_p[15]}]
set_property PACKAGE_PIN J14 [get_ports {io_n[16]}]
set_property PACKAGE_PIN J15 [get_ports {io_p[16]}]
set_property PACKAGE_PIN H13 [get_ports {io_n[17]}]
set_property PACKAGE_PIN J13 [get_ports {io_p[17]}]

set_property IOSTANDARD LVCMOS33 [get_ports {io_n[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {io_p[*]}]

# NOTE: IO17_N/P (H13/J13) is used as an external UART in this project
# (J1 pins 35/36). If you reassign, remove the uart_xdc constraints first.
