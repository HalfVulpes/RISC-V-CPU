################################################################################
# RK-XCKU5P-F V1.2 Development Board - Master Pin Constraint File
# Board Manufacturer : RIGUKE
# FPGA               : AMD Kintex UltraScale+  XCKU5P-2FFVB676I
# Package            : FFVB676
# Speed Grade        : -2I  (Industrial)
# Vivado Version     : 2023.1 (used in factory demos)
# Document Version   : V0.2  (2025-08-07)
#
# Usage: Add this XDC to your Vivado project as a constraints file.
#        Uncomment / rename only the ports your design uses.
#        Port names here are templates - match them to your top-level HDL.
#
# IO Bank Summary:
#   Bank 64  HP  1.2 V  DDR4 data  (DQ / DM / DQS)
#   Bank 65  HP  1.2 V  DDR4 addr/ctrl, SYS_CLK diff, MIPI, PCIE_RESET
#   Bank 66  HP  1.8 V  Gigabit Ethernet RGMII, FMC LA[00-16], MIPI camera ctrl
#   Bank 67  HP  1.8 V  FMC LA[17-33]
#   Bank 84  HD  3.3 V  UART, SD card, QSFP28 control signals
#   Bank 86  HD  3.3 V  LED[1-4], KEY[1-4], FAN, FMC SCL/SDA, 40-PIN IO1-6
#   Bank 87  HD  3.3 V  40-PIN IO7-17
#   Bank 224 GTY  --    PCIe 3.0 x4 transceivers  (no IOSTANDARD needed)
#   Bank 225 GTY  --    QSFP28 x4 transceivers     (no IOSTANDARD needed)
#   Bank 226 GTY  --    FMC DP0-DP3 transceivers   (no IOSTANDARD needed)
#   Bank 227 GTY  --    FMC DP4-DP7 transceivers   (no IOSTANDARD needed)
#
# WARNING: 40-PIN IO banks 86/87 are fixed at 3.3 V - DO NOT change VCCO.
# WARNING: FMC bank 66/67 default 1.8 V (VADJ1). Change DCDC FB resistor RA
#          to modify: 1.2 V -> change RA to 1 K ohm.
# WARNING: LEDs are active-LOW (output 0 = LED on).
# WARNING: Keys are active-LOW with pull-up (input 0 = key pressed).
################################################################################


##############################################################################
# BITSTREAM CONFIGURATION
# Compress bitstream + fast configuration rate (63.8 MHz) - from factory demos
##############################################################################
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 63.8 [current_design]


##############################################################################
# SYSTEM CLOCK  --  200 MHz differential oscillator  (Bank 65, HP, 1.2 V)
# Chip: SG3225VAN 200.000000M-KEGA3
# Connector label: SYS CLK / Y2
##############################################################################
set_property PACKAGE_PIN T24 [get_ports sys_clk_p]
set_property PACKAGE_PIN U24 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_n]

# Timing constraint template - adjust frequency to match your PLL output
create_clock -period 5.000 -name sys_clk [get_ports sys_clk_p]

# NOTE: A second single-ended clock pad (PL_CLK) exists on the board but is
#       NOT populated by default (marked "Reserved - not soldered").
#       If populated it connects to an HD-bank pad.


##############################################################################
# SYSTEM RESET  (Bank 86, HD, 3.3 V  -- active LOW)
# KEY1 is used as system reset in most factory demos
##############################################################################
set_property PACKAGE_PIN K9  [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]


##############################################################################
# USER KEYS  (Bank 86, HD, 3.3 V  -- active LOW, 4.7 K pull-up)
# KEY1 = K9  (also used as reset in most demos)
# KEY2 = K10
# KEY3 = J10
# KEY4 = J11
##############################################################################
set_property PACKAGE_PIN K9  [get_ports {key[0]}]
set_property PACKAGE_PIN K10 [get_ports {key[1]}]
set_property PACKAGE_PIN J10 [get_ports {key[2]}]
set_property PACKAGE_PIN J11 [get_ports {key[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[*]}]

# NOTE: KEY1 (K9) is shared with sys_rst_n above.
#       Use only one definition per project.


##############################################################################
# USER LEDs  (Bank 86, HD, 3.3 V  -- active LOW, drive through MMBT3904)
# LED1 = H9   LED2 = J9   LED3 = G11   LED4 = H11
##############################################################################
set_property PACKAGE_PIN H9  [get_ports {led[0]}]
set_property PACKAGE_PIN J9  [get_ports {led[1]}]
set_property PACKAGE_PIN G11 [get_ports {led[2]}]
set_property PACKAGE_PIN H11 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]


##############################################################################
# FAN  (Bank 86, HD, 3.3 V  -- 2-wire fan, no PWM speed control)
##############################################################################
set_property PACKAGE_PIN G9  [get_ports fan_ctrl]
set_property IOSTANDARD LVCMOS33 [get_ports fan_ctrl]


##############################################################################
# FPGA DONE LED indicator is driven by FPGA configuration hardware
# (not a user IO pin; shown here for reference only)
##############################################################################


##############################################################################
# UART via FT2232HQ  (Bank 84, HD, 3.3 V)
# FT2232HQ provides one JTAG + one UART channel over a single USB Type-C cable
# JTAG download speed: up to 30 Mb/s
##############################################################################
set_property PACKAGE_PIN AD13 [get_ports uart_rx]
set_property PACKAGE_PIN AC14 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]


##############################################################################
# SD CARD  (MicroSD, Bank 84, HD, 3.3 V)
# Supports SPI mode and SD mode
# sd_miso has an on-board PULLUP resistor
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
set_property PULLUP true [get_ports sd_d0]

# SPI mode aliases (same physical pins):
# sd_miso = sd_d0  (AB14)
# sd_mosi = sd_cmd (AA15)
# sd_ncs  = sd_d3  (AB15)


##############################################################################
# GIGABIT ETHERNET  (Bank 66, HP, 1.8 V)
# PHY: Realtek RTL8211F-CG  (10/100/1000 Mbps, RGMII interface)
# Default board IP in factory test image: 192.168.1.10
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


##############################################################################
# MIPI CSI-2 Camera Interface  (Data lanes: Bank 65, HP, 1.2 V)
# (Camera control signals: Bank 66, HP, 1.8 V)
# 4-lane MIPI CSI-2 D-PHY connector (J3, 22-pin)
# Compatible with Zhengdian Atom IMX415 camera module (4K60 via FH1159 card)
#
# NOTE: MIPI D-PHY differential pairs require a MIPI RX IP core.
#       IOSTANDARD is set automatically by the Xilinx MIPI IP.
#       Pins listed here for reference / IO planning only.
#
# NOTE (V0.2 update): Use the on-board oscillator clock to IMX415 camera.
#       DO NOT output FPGA-generated clock to camera IIC - causes anomaly.
##############################################################################
# -- MIPI data/clock lanes (differential, Bank 65, HP 1.2 V)
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

# -- Camera control signals (single-ended, Bank 66, HP 1.8 V)
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
# QSFP28  (Bank 225, GTY transceivers  +  Bank 84 control, HD, 3.3 V)
# 1x QSFP28 port -- supports 100G optical module
# Each TX/RX lane: up to 25 Gb/s
# Reference clock: 156.25 MHz differential (GT_CLK156P25, Bank 225)
#
# NOTE: GTY transceiver pins (RX/TX data and reference clock) are configured
#       through the GT Wizard IP -- do NOT add PACKAGE_PIN / IOSTANDARD here.
# Reference clock pins:  V7 (P) / V6 (N) -- connect to MGTREFCLK0_225
##############################################################################
# -- QSFP28 control signals  (Bank 84, HD, 3.3 V)
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

# -- GTY transceiver pin reference (Bank 225, no IOSTANDARD required)
# QSFP Lane 0:  RX Y2/Y1   TX AA5/AA4   (MGTYRXP0_225 / MGTYTXP0_225)
# QSFP Lane 1:  RX V2/V1   TX W5/W4
# QSFP Lane 2:  RX T2/T1   TX U5/U4
# QSFP Lane 3:  RX P2/P1   TX R5/R4
# GT RefClk 0P: V7   GT RefClk 0N: V6   (156.25 MHz)


##############################################################################
# PCIe 3.0 x4  (Bank 224, GTY transceivers  +  Bank 65 reset)
# Physical connector: PCIe x8 form factor (x4 electrical)
# Per-lane bandwidth: up to 8 Gb/s
#
# NOTE: GTY transceiver data pins are configured via PCIe IP -- no IOSTANDARD.
# Reference clock pins: AB7 (P) / AB6 (N) -- connect to MGTREFCLK0_224
##############################################################################
# -- PCIe reset (active LOW, Bank 65, HP, 1.2 V)
set_property PACKAGE_PIN T19 [get_ports pcie_perst_n]
set_property IOSTANDARD LVCMOS12 [get_ports pcie_perst_n]

# -- GTY transceiver pin reference (Bank 224, no IOSTANDARD required)
# PCIe Lane 0:  RX AB2/AB1   TX AC5/AC4
# PCIe Lane 1:  RX AD2/AD1   TX AD7/AD6
# PCIe Lane 2:  RX AE4/AE3   TX AE9/AE8
# PCIe Lane 3:  RX AF2/AF1   TX AF7/AF6
# GT RefClk 0P: AB7   GT RefClk 0N: AB6


##############################################################################
# DDR4 SDRAM  (Bank 64 + 65, HP, 1.2 V)
# Two chips: Micron MT40A512M16LY-062E  (1 GB each, 32-bit bus, 2 GB total)
# Interface: HP bank, 32-bit data width
# Max speed: 2666 Mb/s
#
# IMPORTANT: These pins are managed by the Xilinx MIG IP core.
#            DO NOT add manual constraints -- let MIG generate the XDC.
#            Pin locations are listed here for IO planning / reference only.
##############################################################################
# Address / Control  (Bank 65)
# set_property PACKAGE_PIN Y22  [get_ports {ddr4_addr[0]}]   ; DDR4_A0
# set_property PACKAGE_PIN Y25  [get_ports {ddr4_addr[1]}]   ; DDR4_A1
# set_property PACKAGE_PIN W23  [get_ports {ddr4_addr[2]}]   ; DDR4_A2
# set_property PACKAGE_PIN V26  [get_ports {ddr4_addr[3]}]   ; DDR4_A3
# set_property PACKAGE_PIN R26  [get_ports {ddr4_addr[4]}]   ; DDR4_A4
# set_property PACKAGE_PIN U26  [get_ports {ddr4_addr[5]}]   ; DDR4_A5
# set_property PACKAGE_PIN R21  [get_ports {ddr4_addr[6]}]   ; DDR4_A6
# set_property PACKAGE_PIN W25  [get_ports {ddr4_addr[7]}]   ; DDR4_A7
# set_property PACKAGE_PIN R20  [get_ports {ddr4_addr[8]}]   ; DDR4_A8
# set_property PACKAGE_PIN Y26  [get_ports {ddr4_addr[9]}]   ; DDR4_A9
# set_property PACKAGE_PIN R25  [get_ports {ddr4_addr[10]}]  ; DDR4_A10
# set_property PACKAGE_PIN V23  [get_ports {ddr4_addr[11]}]  ; DDR4_A11
# set_property PACKAGE_PIN AA24 [get_ports {ddr4_addr[12]}]  ; DDR4_A12
# set_property PACKAGE_PIN W26  [get_ports {ddr4_addr[13]}]  ; DDR4_A13
# set_property PACKAGE_PIN AA25 [get_ports ddr4_cas_b]       ; DDR4_CAS_B
# set_property PACKAGE_PIN T25  [get_ports ddr4_ras_b]       ; DDR4_RAS_B
# set_property PACKAGE_PIN P23  [get_ports ddr4_we_b]        ; DDR4_WE_B
# set_property PACKAGE_PIN P24  [get_ports ddr4_act_n]       ; DDR4_ACT_N
# set_property PACKAGE_PIN U25  [get_ports ddr4_alert_n]     ; DDR4_ALERT_N
# set_property PACKAGE_PIN P21  [get_ports {ddr4_ba[0]}]     ; DDR4_BA0
# set_property PACKAGE_PIN P26  [get_ports {ddr4_ba[1]}]     ; DDR4_BA1
# set_property PACKAGE_PIN R22  [get_ports {ddr4_bg[0]}]     ; DDR4_BG0
# set_property PACKAGE_PIN P20  [get_ports {ddr4_cke[0]}]    ; DDR4_CKE
# set_property PACKAGE_PIN V24  [get_ports {ddr4_ck_t[0]}]   ; DDR4_CLK_P
# set_property PACKAGE_PIN W24  [get_ports {ddr4_ck_c[0]}]   ; DDR4_CLK_N
# set_property PACKAGE_PIN P25  [get_ports {ddr4_cs_n[0]}]   ; DDR4_CS_N
# set_property PACKAGE_PIN R23  [get_ports {ddr4_odt[0]}]    ; DDR4_ODT
# set_property PACKAGE_PIN Y23  [get_ports ddr4_parity]      ; DDR4_PARITY
# set_property PACKAGE_PIN P19  [get_ports ddr4_reset_n]     ; DDR4_RESET_N
#
# Data (Bank 64)
# set_property PACKAGE_PIN AE25 [get_ports {ddr4_dm_n[0]}]   ; DDR4_DM0
# set_property PACKAGE_PIN AE22 [get_ports {ddr4_dm_n[1]}]   ; DDR4_DM1
# set_property PACKAGE_PIN AD20 [get_ports {ddr4_dm_n[2]}]   ; DDR4_DM2
# set_property PACKAGE_PIN Y20  [get_ports {ddr4_dm_n[3]}]   ; DDR4_DM3
# set_property PACKAGE_PIN AC26 [get_ports {ddr4_dqs_t[0]}]  ; DDR4_DQS0_P
# set_property PACKAGE_PIN AD26 [get_ports {ddr4_dqs_c[0]}]  ; DDR4_DQS0_N
# set_property PACKAGE_PIN AA22 [get_ports {ddr4_dqs_t[1]}]  ; DDR4_DQS1_P
# set_property PACKAGE_PIN AB22 [get_ports {ddr4_dqs_c[1]}]  ; DDR4_DQS1_N
# set_property PACKAGE_PIN AC18 [get_ports {ddr4_dqs_t[2]}]  ; DDR4_DQS2_P
# set_property PACKAGE_PIN AD18 [get_ports {ddr4_dqs_c[2]}]  ; DDR4_DQS2_N
# set_property PACKAGE_PIN AB17 [get_ports {ddr4_dqs_t[3]}]  ; DDR4_DQS3_P
# set_property PACKAGE_PIN AC17 [get_ports {ddr4_dqs_c[3]}]  ; DDR4_DQS3_N
# set_property PACKAGE_PIN AF24 [get_ports {ddr4_dq[0]}]
# set_property PACKAGE_PIN AF25 [get_ports {ddr4_dq[1]}]
# set_property PACKAGE_PIN AD24 [get_ports {ddr4_dq[2]}]
# set_property PACKAGE_PIN AB26 [get_ports {ddr4_dq[3]}]
# set_property PACKAGE_PIN AC24 [get_ports {ddr4_dq[4]}]
# set_property PACKAGE_PIN AB25 [get_ports {ddr4_dq[5]}]
# set_property PACKAGE_PIN AD25 [get_ports {ddr4_dq[6]}]
# set_property PACKAGE_PIN AB24 [get_ports {ddr4_dq[7]}]
# set_property PACKAGE_PIN AC21 [get_ports {ddr4_dq[8]}]
# set_property PACKAGE_PIN AD23 [get_ports {ddr4_dq[9]}]
# set_property PACKAGE_PIN AD21 [get_ports {ddr4_dq[10]}]
# set_property PACKAGE_PIN AC22 [get_ports {ddr4_dq[11]}]
# set_property PACKAGE_PIN AB21 [get_ports {ddr4_dq[12]}]
# set_property PACKAGE_PIN AE23 [get_ports {ddr4_dq[13]}]
# set_property PACKAGE_PIN AE21 [get_ports {ddr4_dq[14]}]
# set_property PACKAGE_PIN AC23 [get_ports {ddr4_dq[15]}]
# set_property PACKAGE_PIN AE16 [get_ports {ddr4_dq[16]}]
# set_property PACKAGE_PIN AD19 [get_ports {ddr4_dq[17]}]
# set_property PACKAGE_PIN AD16 [get_ports {ddr4_dq[18]}]
# set_property PACKAGE_PIN AF17 [get_ports {ddr4_dq[19]}]
# set_property PACKAGE_PIN AC19 [get_ports {ddr4_dq[20]}]
# set_property PACKAGE_PIN AF19 [get_ports {ddr4_dq[21]}]
# set_property PACKAGE_PIN AF18 [get_ports {ddr4_dq[22]}]
# set_property PACKAGE_PIN AE17 [get_ports {ddr4_dq[23]}]
# set_property PACKAGE_PIN AA20 [get_ports {ddr4_dq[24]}]
# set_property PACKAGE_PIN AA18 [get_ports {ddr4_dq[25]}]
# set_property PACKAGE_PIN AA19 [get_ports {ddr4_dq[26]}]
# set_property PACKAGE_PIN Y18  [get_ports {ddr4_dq[27]}]
# set_property PACKAGE_PIN AB20 [get_ports {ddr4_dq[28]}]
# set_property PACKAGE_PIN Y17  [get_ports {ddr4_dq[29]}]
# set_property PACKAGE_PIN AB19 [get_ports {ddr4_dq[30]}]
# set_property PACKAGE_PIN AA17 [get_ports {ddr4_dq[31]}]


##############################################################################
# FMC HPC CONNECTOR  (LA pairs: Bank 66/67, HP, 1.8 V default; COM: Bank 86)
# 34 differential LA pairs + 8 GTY DP lanes + I2C + power good
# GTY lanes: Bank 226 (DP0-3) and Bank 227 (DP4-7), up to 25 Gb/s each
# Reference clocks:
#   GBTCLK0 M2C: P7 (P) / P6 (N)  -- Bank 226 MGTREFCLK0
#   GBTCLK1 M2C: K7 (P) / K6 (N)  -- Bank 227 MGTREFCLK0
##############################################################################
# -- Clock pairs  (Bank 66, HP, 1.8 V)
set_property PACKAGE_PIN H23 [get_ports fmc_clk0_p]
set_property PACKAGE_PIN H24 [get_ports fmc_clk0_n]
set_property PACKAGE_PIN B19 [get_ports fmc_clk1_p]
set_property PACKAGE_PIN B20 [get_ports fmc_clk1_n]
set_property IOSTANDARD LVDS [get_ports fmc_clk0_p]
set_property IOSTANDARD LVDS [get_ports fmc_clk0_n]
set_property IOSTANDARD LVDS [get_ports fmc_clk1_p]
set_property IOSTANDARD LVDS [get_ports fmc_clk1_n]

# -- LA pairs  (Bank 66, HP, 1.8 V  for LA00-LA16)
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

set_property IOSTANDARD LVDS [get_ports fmc_la00_cc_p]
set_property IOSTANDARD LVDS [get_ports fmc_la00_cc_n]
set_property IOSTANDARD LVDS [get_ports fmc_la01_cc_p]
set_property IOSTANDARD LVDS [get_ports fmc_la01_cc_n]
set_property IOSTANDARD LVDS [get_ports fmc_la02_p]
set_property IOSTANDARD LVDS [get_ports fmc_la02_n]
set_property IOSTANDARD LVDS [get_ports fmc_la03_p]
set_property IOSTANDARD LVDS [get_ports fmc_la03_n]
set_property IOSTANDARD LVDS [get_ports fmc_la04_p]
set_property IOSTANDARD LVDS [get_ports fmc_la04_n]
set_property IOSTANDARD LVDS [get_ports fmc_la05_p]
set_property IOSTANDARD LVDS [get_ports fmc_la05_n]
set_property IOSTANDARD LVDS [get_ports fmc_la06_p]
set_property IOSTANDARD LVDS [get_ports fmc_la06_n]
set_property IOSTANDARD LVDS [get_ports fmc_la07_p]
set_property IOSTANDARD LVDS [get_ports fmc_la07_n]
set_property IOSTANDARD LVDS [get_ports fmc_la08_p]
set_property IOSTANDARD LVDS [get_ports fmc_la08_n]
set_property IOSTANDARD LVDS [get_ports fmc_la09_p]
set_property IOSTANDARD LVDS [get_ports fmc_la09_n]
set_property IOSTANDARD LVDS [get_ports fmc_la10_p]
set_property IOSTANDARD LVDS [get_ports fmc_la10_n]
set_property IOSTANDARD LVDS [get_ports fmc_la11_p]
set_property IOSTANDARD LVDS [get_ports fmc_la11_n]
set_property IOSTANDARD LVDS [get_ports fmc_la12_p]
set_property IOSTANDARD LVDS [get_ports fmc_la12_n]
set_property IOSTANDARD LVDS [get_ports fmc_la13_p]
set_property IOSTANDARD LVDS [get_ports fmc_la13_n]
set_property IOSTANDARD LVDS [get_ports fmc_la14_p]
set_property IOSTANDARD LVDS [get_ports fmc_la14_n]
set_property IOSTANDARD LVDS [get_ports fmc_la15_p]
set_property IOSTANDARD LVDS [get_ports fmc_la15_n]
set_property IOSTANDARD LVDS [get_ports fmc_la16_p]
set_property IOSTANDARD LVDS [get_ports fmc_la16_n]

# -- LA pairs  (Bank 67, HP, 1.8 V  for LA17-LA33)
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

set_property IOSTANDARD LVDS [get_ports fmc_la17_cc_p]
set_property IOSTANDARD LVDS [get_ports fmc_la17_cc_n]
set_property IOSTANDARD LVDS [get_ports fmc_la18_cc_p]
set_property IOSTANDARD LVDS [get_ports fmc_la18_cc_n]
set_property IOSTANDARD LVDS [get_ports fmc_la19_p]
set_property IOSTANDARD LVDS [get_ports fmc_la19_n]
set_property IOSTANDARD LVDS [get_ports fmc_la20_p]
set_property IOSTANDARD LVDS [get_ports fmc_la20_n]
set_property IOSTANDARD LVDS [get_ports fmc_la21_p]
set_property IOSTANDARD LVDS [get_ports fmc_la21_n]
set_property IOSTANDARD LVDS [get_ports fmc_la22_p]
set_property IOSTANDARD LVDS [get_ports fmc_la22_n]
set_property IOSTANDARD LVDS [get_ports fmc_la23_p]
set_property IOSTANDARD LVDS [get_ports fmc_la23_n]
set_property IOSTANDARD LVDS [get_ports fmc_la24_p]
set_property IOSTANDARD LVDS [get_ports fmc_la24_n]
set_property IOSTANDARD LVDS [get_ports fmc_la25_p]
set_property IOSTANDARD LVDS [get_ports fmc_la25_n]
set_property IOSTANDARD LVDS [get_ports fmc_la26_p]
set_property IOSTANDARD LVDS [get_ports fmc_la26_n]
set_property IOSTANDARD LVDS [get_ports fmc_la27_p]
set_property IOSTANDARD LVDS [get_ports fmc_la27_n]
set_property IOSTANDARD LVDS [get_ports fmc_la28_p]
set_property IOSTANDARD LVDS [get_ports fmc_la28_n]
set_property IOSTANDARD LVDS [get_ports fmc_la29_p]
set_property IOSTANDARD LVDS [get_ports fmc_la29_n]
set_property IOSTANDARD LVDS [get_ports fmc_la30_p]
set_property IOSTANDARD LVDS [get_ports fmc_la30_n]
set_property IOSTANDARD LVDS [get_ports fmc_la31_p]
set_property IOSTANDARD LVDS [get_ports fmc_la31_n]
set_property IOSTANDARD LVDS [get_ports fmc_la32_p]
set_property IOSTANDARD LVDS [get_ports fmc_la32_n]
set_property IOSTANDARD LVDS [get_ports fmc_la33_p]
set_property IOSTANDARD LVDS [get_ports fmc_la33_n]

# -- FMC I2C and power good  (Bank 86, HD, 3.3 V)
set_property PACKAGE_PIN F10 [get_ports fmc_scl]
set_property PACKAGE_PIN F9  [get_ports fmc_sda]
set_property PACKAGE_PIN G10 [get_ports fmc_pwrgd]
set_property IOSTANDARD LVCMOS33 [get_ports fmc_scl]
set_property IOSTANDARD LVCMOS33 [get_ports fmc_sda]
set_property IOSTANDARD LVCMOS33 [get_ports fmc_pwrgd]

# -- FMC DP GTY transceiver reference (no IOSTANDARD required)
# DP0 C2M: N5/N4  DP0 M2C: M2/M1  (Bank 226 MGTYTXP/MGTYRXP)
# DP1 C2M: L5/L4  DP1 M2C: K2/K1
# DP2 C2M: J5/J4  DP2 M2C: H2/H1
# DP3 C2M: G5/G4  DP3 M2C: F2/F1
# DP4 C2M: F7/F6  DP4 M2C: D2/D1  (Bank 227)
# DP5 C2M: E5/E4  DP5 M2C: C4/C3
# DP6 C2M: D7/D6  DP6 M2C: B2/B1
# DP7 C2M: B7/B6  DP7 M2C: A4/A3
# GBTCLK0 M2C: P7(P)/P6(N)   GBTCLK1 M2C: K7(P)/K6(N)


##############################################################################
# 40-PIN EXPANSION IO  (Bank 86 and 87, HD, 3.3 V -- FIXED, NOT changeable)
# 2.54 mm pitch HDR2X20 connector (J1)
# 34 signal lines (17 differential pairs), 1x 5V, 2x 3.3V, 3x GND
# All traces are length-matched at 2880.464 mil
# Compatible with Heijin (Hei Jin) expansion modules
##############################################################################
# Bank 86 (IO1-IO6, pins 3-14 odd=N, even=P)
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
