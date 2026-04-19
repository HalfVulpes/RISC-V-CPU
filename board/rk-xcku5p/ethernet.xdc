# Gigabit Ethernet RGMII - Bank 66 HP 1.8V (RTL8211F-CG)
# NOTE: Bank 66 is HP - no BUFR, no ODELAYE3.
# Use CLOCK_INPUT_STYLE=BUFG and USE_CLK90=TRUE in the RGMII wrapper.
# BD wrapper uses rgmii_rd/td (not rxd/txd) per Vivado RGMII interface naming.

set_property -dict {PACKAGE_PIN K22 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxc}]
set_property -dict {PACKAGE_PIN K23 IOSTANDARD LVCMOS18} [get_ports {rgmii_rx_ctl}]
set_property -dict {PACKAGE_PIN L24 IOSTANDARD LVCMOS18} [get_ports {rgmii_rd[0]}]
set_property -dict {PACKAGE_PIN L25 IOSTANDARD LVCMOS18} [get_ports {rgmii_rd[1]}]
set_property -dict {PACKAGE_PIN K25 IOSTANDARD LVCMOS18} [get_ports {rgmii_rd[2]}]
set_property -dict {PACKAGE_PIN K26 IOSTANDARD LVCMOS18} [get_ports {rgmii_rd[3]}]

set_property -dict {PACKAGE_PIN M25 IOSTANDARD LVCMOS18} [get_ports {rgmii_txc}]
set_property -dict {PACKAGE_PIN M26 IOSTANDARD LVCMOS18} [get_ports {rgmii_tx_ctl}]
set_property -dict {PACKAGE_PIN L23 IOSTANDARD LVCMOS18} [get_ports {rgmii_td[0]}]
set_property -dict {PACKAGE_PIN L22 IOSTANDARD LVCMOS18} [get_ports {rgmii_td[1]}]
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS18} [get_ports {rgmii_td[2]}]
set_property -dict {PACKAGE_PIN K20 IOSTANDARD LVCMOS18} [get_ports {rgmii_td[3]}]

set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS18} [get_ports eth_mdio_clock]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS18} [get_ports eth_mdio_data]

# RGMII RX timing (RTL8211F default: RXDLY=1, so add ~2 ns input delay)
create_clock -period 8.000 -name eth_rx_clk [get_ports rgmii_rxc]
set_input_delay -clock eth_rx_clk -max 1.0 [get_ports {rgmii_rd[*] rgmii_rx_ctl}]
set_input_delay -clock eth_rx_clk -min -0.5 [get_ports {rgmii_rd[*] rgmii_rx_ctl}]

# RGMII TX timing
set_output_delay -clock [get_clocks -of_objects [get_ports sys_diff_clock_clk_p]] -max 1.0 [get_ports {rgmii_td[*] rgmii_tx_ctl rgmii_txc}]
set_output_delay -clock [get_clocks -of_objects [get_ports sys_diff_clock_clk_p]] -min -1.0 [get_ports {rgmii_td[*] rgmii_tx_ctl rgmii_txc}]
