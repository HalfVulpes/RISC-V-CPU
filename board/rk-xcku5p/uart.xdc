# UART via FT2232HQ - Bank 84 HD 3.3V
set_property -dict {PACKAGE_PIN AD13 IOSTANDARD LVCMOS33} [get_ports usb_uart_rxd]
set_property -dict {PACKAGE_PIN AC14 IOSTANDARD LVCMOS33} [get_ports usb_uart_txd]

# External UART on 40-pin connector (J1)
# EXT_RX: pin 35 = io_n[17] = H13  (connect external TX here)
# EXT_TX: pin 36 = io_p[17] = J13  (connect external RX here)
set_property -dict {PACKAGE_PIN H13 IOSTANDARD LVCMOS33} [get_ports ext_uart_rxd]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports ext_uart_txd]
