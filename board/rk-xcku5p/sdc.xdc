# MicroSD card - Bank 84 HD 3.3V
set_property -dict {PACKAGE_PIN Y16  IOSTANDARD LVCMOS33} [get_ports sdio_cd]
set_property -dict {PACKAGE_PIN Y15  IOSTANDARD LVCMOS33} [get_ports sdio_clk]
set_property -dict {PACKAGE_PIN AA15 IOSTANDARD LVCMOS33} [get_ports sdio_cmd]
set_property -dict {PACKAGE_PIN AB14 IOSTANDARD LVCMOS33} [get_ports {sdio_dat[0]}]
set_property -dict {PACKAGE_PIN AA14 IOSTANDARD LVCMOS33} [get_ports {sdio_dat[1]}]
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS33} [get_ports {sdio_dat[2]}]
set_property -dict {PACKAGE_PIN AB15 IOSTANDARD LVCMOS33} [get_ports {sdio_dat[3]}]
set_property PULLUP true [get_ports {sdio_dat[0]}]
