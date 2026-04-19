# RK-XCKU5P-F V1.2 - Bitstream and clock configuration
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 63.8 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property CFGBVS GND [current_design]

# 200 MHz system clock - Bank 65 HP 1.2V (SG3225VAN)
# Used for clk_wiz_0 (user/AXI/ETH clocks)
set_property -dict {PACKAGE_PIN T24 IOSTANDARD DIFF_SSTL12} [get_ports sys_diff_clock_clk_p]
set_property -dict {PACKAGE_PIN U24 IOSTANDARD DIFF_SSTL12} [get_ports sys_diff_clock_clk_n]
create_clock -period 5.000 -name sys_clk [get_ports sys_diff_clock_clk_p]

# Reset - KEY1, Bank 86 HD 3.3V, active LOW
set_property -dict {PACKAGE_PIN K9 IOSTANDARD LVCMOS33} [get_ports resetn]
set_false_path -from [get_ports resetn]
set_input_delay 0 [get_ports resetn]
