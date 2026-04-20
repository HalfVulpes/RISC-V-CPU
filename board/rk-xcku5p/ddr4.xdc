# DDR4 SDRAM pin placement for RK-XCKU5P-F V1.2
# Authoritative source: KU5P_DEMO/06_DDR_AXI/Constraint/Phy_Pin.xdc
# (This is the board-level XDC the factory demo actually uses; do NOT use
# ddr4_0_ex/imports/example_design.xdc — that file contains MIG's standalone
# example-design placeholder pins, not the real board wiring.)

# --- Address [0:16] ---
# Per the schematic + factory XDC, ADR[14:16] multiplex the legacy
# WE_B / CAS_B / RAS_B commands when ACT_N is high (DDR4 command encoding).
set_property PACKAGE_PIN Y22  [get_ports {ddr4_sdram_c0_adr[0]}]
set_property PACKAGE_PIN Y25  [get_ports {ddr4_sdram_c0_adr[1]}]
set_property PACKAGE_PIN W23  [get_ports {ddr4_sdram_c0_adr[2]}]
set_property PACKAGE_PIN V26  [get_ports {ddr4_sdram_c0_adr[3]}]
set_property PACKAGE_PIN R26  [get_ports {ddr4_sdram_c0_adr[4]}]
set_property PACKAGE_PIN U26  [get_ports {ddr4_sdram_c0_adr[5]}]
set_property PACKAGE_PIN R21  [get_ports {ddr4_sdram_c0_adr[6]}]
set_property PACKAGE_PIN W25  [get_ports {ddr4_sdram_c0_adr[7]}]
set_property PACKAGE_PIN R20  [get_ports {ddr4_sdram_c0_adr[8]}]
set_property PACKAGE_PIN Y26  [get_ports {ddr4_sdram_c0_adr[9]}]
set_property PACKAGE_PIN R25  [get_ports {ddr4_sdram_c0_adr[10]}]
set_property PACKAGE_PIN V23  [get_ports {ddr4_sdram_c0_adr[11]}]
set_property PACKAGE_PIN AA24 [get_ports {ddr4_sdram_c0_adr[12]}]
set_property PACKAGE_PIN W26  [get_ports {ddr4_sdram_c0_adr[13]}]
set_property PACKAGE_PIN P23  [get_ports {ddr4_sdram_c0_adr[14]}] ;# WE_B
set_property PACKAGE_PIN AA25 [get_ports {ddr4_sdram_c0_adr[15]}] ;# CAS_B
set_property PACKAGE_PIN T25  [get_ports {ddr4_sdram_c0_adr[16]}] ;# RAS_B

# --- Bank address ---
set_property PACKAGE_PIN P21 [get_ports {ddr4_sdram_c0_ba[0]}]
set_property PACKAGE_PIN P26 [get_ports {ddr4_sdram_c0_ba[1]}]

# --- Bank group (x16 parts: only BG[0] used) ---
set_property PACKAGE_PIN R22 [get_ports {ddr4_sdram_c0_bg[0]}]

# --- Memory clock ---
set_property PACKAGE_PIN V24 [get_ports {ddr4_sdram_c0_ck_t[0]}]
set_property PACKAGE_PIN W24 [get_ports {ddr4_sdram_c0_ck_c[0]}]

# --- Control ---
set_property PACKAGE_PIN P24 [get_ports ddr4_sdram_c0_act_n]
set_property PACKAGE_PIN P20 [get_ports {ddr4_sdram_c0_cke[0]}]
set_property PACKAGE_PIN P25 [get_ports {ddr4_sdram_c0_cs_n[0]}]
set_property PACKAGE_PIN R23 [get_ports {ddr4_sdram_c0_odt[0]}]
set_property PACKAGE_PIN P19 [get_ports ddr4_sdram_c0_reset_n]

# --- Data mask (DM_NO_DBI mode) ---
set_property PACKAGE_PIN AE25 [get_ports {ddr4_sdram_c0_dm_n[0]}]
set_property PACKAGE_PIN AE22 [get_ports {ddr4_sdram_c0_dm_n[1]}]
set_property PACKAGE_PIN AD20 [get_ports {ddr4_sdram_c0_dm_n[2]}]
set_property PACKAGE_PIN Y20  [get_ports {ddr4_sdram_c0_dm_n[3]}]

# --- DQS differential strobes ---
set_property PACKAGE_PIN AC26 [get_ports {ddr4_sdram_c0_dqs_t[0]}]
set_property PACKAGE_PIN AD26 [get_ports {ddr4_sdram_c0_dqs_c[0]}]
set_property PACKAGE_PIN AA22 [get_ports {ddr4_sdram_c0_dqs_t[1]}]
set_property PACKAGE_PIN AB22 [get_ports {ddr4_sdram_c0_dqs_c[1]}]
set_property PACKAGE_PIN AC18 [get_ports {ddr4_sdram_c0_dqs_t[2]}]
set_property PACKAGE_PIN AD18 [get_ports {ddr4_sdram_c0_dqs_c[2]}]
set_property PACKAGE_PIN AB17 [get_ports {ddr4_sdram_c0_dqs_t[3]}]
set_property PACKAGE_PIN AC17 [get_ports {ddr4_sdram_c0_dqs_c[3]}]

# --- Data byte 0 (Bank 64, DQ[0:7]) ---
set_property PACKAGE_PIN AF24 [get_ports {ddr4_sdram_c0_dq[0]}]
set_property PACKAGE_PIN AF25 [get_ports {ddr4_sdram_c0_dq[1]}]
set_property PACKAGE_PIN AD24 [get_ports {ddr4_sdram_c0_dq[2]}]
set_property PACKAGE_PIN AB26 [get_ports {ddr4_sdram_c0_dq[3]}]
set_property PACKAGE_PIN AC24 [get_ports {ddr4_sdram_c0_dq[4]}]
set_property PACKAGE_PIN AB25 [get_ports {ddr4_sdram_c0_dq[5]}]
set_property PACKAGE_PIN AD25 [get_ports {ddr4_sdram_c0_dq[6]}]
set_property PACKAGE_PIN AB24 [get_ports {ddr4_sdram_c0_dq[7]}]

# --- Data byte 1 (Bank 64, DQ[8:15]) ---
set_property PACKAGE_PIN AC21 [get_ports {ddr4_sdram_c0_dq[8]}]
set_property PACKAGE_PIN AD23 [get_ports {ddr4_sdram_c0_dq[9]}]
set_property PACKAGE_PIN AD21 [get_ports {ddr4_sdram_c0_dq[10]}]
set_property PACKAGE_PIN AC22 [get_ports {ddr4_sdram_c0_dq[11]}]
set_property PACKAGE_PIN AB21 [get_ports {ddr4_sdram_c0_dq[12]}]
set_property PACKAGE_PIN AE23 [get_ports {ddr4_sdram_c0_dq[13]}]
set_property PACKAGE_PIN AE21 [get_ports {ddr4_sdram_c0_dq[14]}]
set_property PACKAGE_PIN AC23 [get_ports {ddr4_sdram_c0_dq[15]}]

# --- Data byte 2 (Bank 64, DQ[16:23]) ---
set_property PACKAGE_PIN AE16 [get_ports {ddr4_sdram_c0_dq[16]}]
set_property PACKAGE_PIN AD19 [get_ports {ddr4_sdram_c0_dq[17]}]
set_property PACKAGE_PIN AD16 [get_ports {ddr4_sdram_c0_dq[18]}]
set_property PACKAGE_PIN AF17 [get_ports {ddr4_sdram_c0_dq[19]}]
set_property PACKAGE_PIN AC19 [get_ports {ddr4_sdram_c0_dq[20]}]
set_property PACKAGE_PIN AF19 [get_ports {ddr4_sdram_c0_dq[21]}]
set_property PACKAGE_PIN AF18 [get_ports {ddr4_sdram_c0_dq[22]}]
set_property PACKAGE_PIN AE17 [get_ports {ddr4_sdram_c0_dq[23]}]

# --- Data byte 3 (Bank 64, DQ[24:31]) ---
set_property PACKAGE_PIN AA20 [get_ports {ddr4_sdram_c0_dq[24]}]
set_property PACKAGE_PIN AA18 [get_ports {ddr4_sdram_c0_dq[25]}]
set_property PACKAGE_PIN AA19 [get_ports {ddr4_sdram_c0_dq[26]}]
set_property PACKAGE_PIN Y18  [get_ports {ddr4_sdram_c0_dq[27]}]
set_property PACKAGE_PIN AB20 [get_ports {ddr4_sdram_c0_dq[28]}]
set_property PACKAGE_PIN Y17  [get_ports {ddr4_sdram_c0_dq[29]}]
set_property PACKAGE_PIN AB19 [get_ports {ddr4_sdram_c0_dq[30]}]
set_property PACKAGE_PIN AA17 [get_ports {ddr4_sdram_c0_dq[31]}]
