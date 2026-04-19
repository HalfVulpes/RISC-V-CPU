
################################################################
# Block design for RK-XCKU5P-F V1.2
# FPGA: AMD Kintex UltraScale+ XCKU5P-2FFVB676I
# DDR4: 2x MT40A512M16LY-062E (2 GB, 32-bit, DDR4-2400)
# ETH:  RTL8211F-CG RGMII (Bank 66 HP 1.8V)
# Vivado: 2023.2 ONLY
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

set scripts_vivado_version 2023.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}
   return 1
}

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcku5p-ffvb676-2-i
}

variable design_name
set design_name riscv
set errMsg ""
set nRet 0
set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1
} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."
} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2
} else {
   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."
   create_bd_design $design_name
   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name
}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:ddr4:2.2\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
"
   set list_ips_missing ""
   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } { lappend list_ips_missing $ip_vlnv }
   }
   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }
}

set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\
$rocket_module_name\
ethernet\
sdc_controller\
uart\
ethernet_rk_xcku5p\
"
   set list_mods_missing ""
   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } { lappend list_mods_missing $mod_vlnv }
   }
   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# IO hierarchy: UART + SD + Ethernet (RGMII) + interrupts
##################################################################
proc create_hier_cell_IO { parentCell nameHier } {
  variable script_folder
  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_IO() - Empty argument(s)!"}
     return
  }
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }
  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentObj
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI
  create_bd_intf_pin -mode Slave  -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0  RGMII

  # Clock / reset scalar pins
  create_bd_pin -dir I -type clk  axi_clock
  create_bd_pin -dir I -type rst  axi_reset
  create_bd_pin -dir I -type clk  clock_125MHz
  create_bd_pin -dir I -type clk  clock_125MHz_90
  create_bd_pin -dir O -from 7 -to 0 interrupts

  # SD card scalar pins
  create_bd_pin -dir I            sdio_cd
  create_bd_pin -dir O            sdio_clk
  create_bd_pin -dir IO           sdio_cmd
  create_bd_pin -dir IO -from 3 -to 0 sdio_dat
  create_bd_pin -dir O            sdio_reset

  # Ethernet MDC/MDIO
  create_bd_pin -dir O            eth_mdio_clock
  create_bd_pin -dir IO           eth_mdio_data
  create_bd_pin -dir I            eth_mdio_int
  create_bd_pin -dir O            eth_mdio_reset

  # UART
  create_bd_pin -dir I            usb_uart_rxd
  create_bd_pin -dir O            usb_uart_txd

  # --- RGMII wrapper ---
  set block_name ethernet_rk_xcku5p
  set block_cell_name ethernet_stream_0
  if { [catch {set ethernet_stream_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>."}
     return 1
  }

  # --- Ethernet DMA/AXI-Lite controller ---
  set block_name ethernet
  set block_cell_name Ethernet
  if { [catch {set Ethernet [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>."}
     return 1
  }

  # --- SD card controller ---
  set block_name sdc_controller
  set block_cell_name SD
  if { [catch {set SD [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>."}
     return 1
  }
  set_property -dict [list CONFIG.sdio_card_detect_level {0}] $SD

  # --- UART controller ---
  set block_name uart
  set block_cell_name UART
  if { [catch {set UART [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>."}
     return 1
  }

  # AXI slave interconnect: RocketChip IO → UART/SD/Ethernet registers
  set io_axi_s [create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 io_axi_s]
  set_property -dict [list CONFIG.NUM_CLKS {2} CONFIG.NUM_MI {3} CONFIG.NUM_SI {1}] $io_axi_s

  # AXI master interconnect: Ethernet/SD DMA → RocketChip DMA port
  set io_axi_m [create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 io_axi_m]
  set_property -dict [list CONFIG.NUM_CLKS {2} CONFIG.NUM_MI {1} CONFIG.NUM_SI {2}] $io_axi_m

  # Interrupt concatenator
  set xlconcat_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0]
  set_property -dict [list CONFIG.NUM_PORTS {8}] $xlconcat_0

  # Tie unused interrupt inputs to 0
  set xlconst_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconst_0]
  set_property -dict [list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {1}] $xlconst_0

  # --- Interface connections ---
  connect_bd_intf_net [get_bd_intf_pins RGMII]                     [get_bd_intf_pins ethernet_stream_0/RGMII]
  connect_bd_intf_net [get_bd_intf_pins Ethernet/TX_AXIS]          [get_bd_intf_pins ethernet_stream_0/TX_AXIS]
  connect_bd_intf_net [get_bd_intf_pins ethernet_stream_0/RX_AXIS] [get_bd_intf_pins Ethernet/RX_AXIS]
  connect_bd_intf_net [get_bd_intf_pins Ethernet/M_AXI]            [get_bd_intf_pins io_axi_m/S01_AXI]
  connect_bd_intf_net [get_bd_intf_pins SD/M_AXI]                  [get_bd_intf_pins io_axi_m/S00_AXI]
  connect_bd_intf_net [get_bd_intf_pins io_axi_m/M00_AXI]          [get_bd_intf_pins M00_AXI]
  connect_bd_intf_net [get_bd_intf_pins S00_AXI]                   [get_bd_intf_pins io_axi_s/S00_AXI]
  connect_bd_intf_net [get_bd_intf_pins io_axi_s/M00_AXI]          [get_bd_intf_pins UART/S_AXI_LITE]
  connect_bd_intf_net [get_bd_intf_pins io_axi_s/M01_AXI]          [get_bd_intf_pins SD/S_AXI_LITE]
  connect_bd_intf_net [get_bd_intf_pins io_axi_s/M02_AXI]          [get_bd_intf_pins Ethernet/S_AXI_LITE]

  # --- Net connections ---
  # AXI clock (100 MHz) → all AXI interconnects and SD/UART
  connect_bd_net -net IO_axi_clock \
    [get_bd_pins axi_clock]          \
    [get_bd_pins io_axi_s/aclk]      \
    [get_bd_pins io_axi_m/aclk]      \
    [get_bd_pins SD/clock]           \
    [get_bd_pins UART/clock]

  # 125 MHz → Ethernet logic + second SmartConnect clock
  connect_bd_net -net IO_clock_125MHz \
    [get_bd_pins clock_125MHz]         \
    [get_bd_pins Ethernet/clock]       \
    [get_bd_pins ethernet_stream_0/clock125] \
    [get_bd_pins io_axi_s/aclk1]      \
    [get_bd_pins io_axi_m/aclk1]

  # 125 MHz 90° → RGMII TX clock (USE_CLK90)
  connect_bd_net [get_bd_pins clock_125MHz_90] [get_bd_pins ethernet_stream_0/clock125_90]

  # AXI reset (active LOW, from RocketChip/aresetn)
  connect_bd_net -net IO_axi_reset \
    [get_bd_pins axi_reset]          \
    [get_bd_pins io_axi_s/aresetn]   \
    [get_bd_pins io_axi_m/aresetn]   \
    [get_bd_pins Ethernet/async_resetn] \
    [get_bd_pins SD/async_resetn]    \
    [get_bd_pins UART/async_resetn]

  # Ethernet reset (active HIGH from Ethernet module)
  connect_bd_net [get_bd_pins Ethernet/reset] [get_bd_pins ethernet_stream_0/reset]

  # Ethernet status
  connect_bd_net [get_bd_pins Ethernet/status_vector] [get_bd_pins ethernet_stream_0/status_vector]

  # MDIO
  connect_bd_net [get_bd_pins eth_mdio_clock] [get_bd_pins Ethernet/mdio_clock]
  connect_bd_net [get_bd_pins eth_mdio_data]  [get_bd_pins Ethernet/mdio_data]
  connect_bd_net [get_bd_pins eth_mdio_int]   [get_bd_pins Ethernet/mdio_int]
  connect_bd_net [get_bd_pins eth_mdio_reset] [get_bd_pins Ethernet/mdio_reset]

  # SD card
  connect_bd_net [get_bd_pins sdio_cd]    [get_bd_pins SD/sdio_cd]
  connect_bd_net [get_bd_pins sdio_clk]   [get_bd_pins SD/sdio_clk]
  connect_bd_net [get_bd_pins sdio_cmd]   [get_bd_pins SD/sdio_cmd]
  connect_bd_net [get_bd_pins sdio_dat]   [get_bd_pins SD/sdio_dat]
  connect_bd_net [get_bd_pins sdio_reset] [get_bd_pins SD/sdio_reset]

  # UART
  connect_bd_net [get_bd_pins usb_uart_rxd] [get_bd_pins UART/RxD]
  connect_bd_net [get_bd_pins usb_uart_txd] [get_bd_pins UART/TxD]

  # Interrupts: 0=UART, 1=SD, 2=Ethernet, 3-7=unused(0)
  connect_bd_net [get_bd_pins UART/interrupt]     [get_bd_pins xlconcat_0/In0]
  connect_bd_net [get_bd_pins SD/interrupt]       [get_bd_pins xlconcat_0/In1]
  connect_bd_net [get_bd_pins Ethernet/interrupt] [get_bd_pins xlconcat_0/In2]
  connect_bd_net [get_bd_pins xlconst_0/dout]     [get_bd_pins xlconcat_0/In3]
  connect_bd_net [get_bd_pins xlconst_0/dout]     [get_bd_pins xlconcat_0/In4]
  connect_bd_net [get_bd_pins xlconst_0/dout]     [get_bd_pins xlconcat_0/In5]
  connect_bd_net [get_bd_pins xlconst_0/dout]     [get_bd_pins xlconcat_0/In6]
  connect_bd_net [get_bd_pins xlconst_0/dout]     [get_bd_pins xlconcat_0/In7]
  connect_bd_net [get_bd_pins xlconcat_0/dout]    [get_bd_pins interrupts]

  current_bd_instance $oldCurInst
}

##################################################################
# DDR hierarchy: UltraScale+ DDR4-2400, 2 GB
##################################################################
proc create_hier_cell_DDR { parentCell nameHier } {
  variable script_folder
  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_DDR() - Empty argument(s)!"}
     return
  }
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }
  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentObj
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Interface pins
  create_bd_intf_pin -mode Slave  -vlnv xilinx.com:interface:aximm_rtl:1.0      S00_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0       ddr4_sdram_c0
  create_bd_intf_pin -mode Slave  -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ddr4_sys_clk

  # Scalar pins
  create_bd_pin -dir I           axi_clock
  create_bd_pin -dir I           axi_reset
  create_bd_pin -dir O           c0_init_calib_complete
  create_bd_pin -dir O -type clk ui_clk
  create_bd_pin -dir O -type clk addn_clk_200
  create_bd_pin -dir I -type rst sys_reset

  # DDR4 IP: 2x MT40A512M16HA-075E components, 32-bit bus, DDR4-2666, 200 MHz input.
  # Factory-verified parameters from KU5P_DEMO/06_DDR_AXI/ddr4_0.xci. The board ships
  # with MT40A512M16LY-062E silicon, but Vivado 2023.2's IP catalog selects HA-075E as
  # the electrically compatible entry; the LY variants have different refresh/ODT timings
  # and will fail calibration.
  set ddr4_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0]
  set_property -dict [list \
    CONFIG.C0.DDR4_InputClockPeriod        {5000}                 \
    CONFIG.C0.DDR4_TimePeriod              {750}                  \
    CONFIG.C0.DDR4_PhyClockRatio           {4:1}                  \
    CONFIG.C0.DDR4_MemoryType              {Components}           \
    CONFIG.C0.DDR4_MemoryPart              {MT40A512M16HA-075E}   \
    CONFIG.C0.DDR4_MemoryVoltage           {1.2V}                 \
    CONFIG.C0.DDR4_Slot                    {Single}               \
    CONFIG.C0.DDR4_DataWidth               {32}                   \
    CONFIG.C0.DDR4_DataMask                {DM_NO_DBI}            \
    CONFIG.C0.DDR4_CasLatency              {19}                   \
    CONFIG.C0.DDR4_CasWriteLatency         {14}                   \
    CONFIG.C0.DDR4_ChipSelect              {true}                 \
    CONFIG.C0.DDR4_OutputDriverImpedenceControl {RZQ/7}           \
    CONFIG.C0.DDR4_OnDieTermination        {RZQ/6}                \
    CONFIG.C0.DDR4_AxiSelection            {true}                 \
    CONFIG.C0.DDR4_AxiIDWidth              {4}                    \
    CONFIG.C0.DDR4_AxiDataWidth            {256}                  \
    CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ         {200}                  \
  ] $ddr4_0

  # SmartConnect bridges CPU clock (aclk) and DDR4 UI clock (aclk1)
  set smartconnect_1 [create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_1]
  set_property -dict [list CONFIG.NUM_CLKS {2} CONFIG.NUM_SI {1}] $smartconnect_1

  # Invert DDR4 ui_clk_sync_rst (active HIGH) → c0_ddr4_aresetn (active LOW)
  set rst_inv [create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 rst_inv]
  set_property -dict [list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}] $rst_inv

  # --- Interface connections ---
  connect_bd_intf_net [get_bd_intf_pins S00_AXI]            [get_bd_intf_pins smartconnect_1/S00_AXI]
  connect_bd_intf_net [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
  connect_bd_intf_net [get_bd_intf_pins ddr4_sdram_c0]      [get_bd_intf_pins ddr4_0/C0_DDR4]
  connect_bd_intf_net [get_bd_intf_pins ddr4_sys_clk]       [get_bd_intf_pins ddr4_0/C0_SYS_CLK]

  # --- Net connections ---
  # CPU AXI clock → SmartConnect aclk
  connect_bd_net [get_bd_pins axi_clock]  [get_bd_pins smartconnect_1/aclk]

  # DDR4 AXI reset (from RocketChip aresetn) → SmartConnect
  connect_bd_net [get_bd_pins axi_reset]  [get_bd_pins smartconnect_1/aresetn]

  # DDR4 UI clock → SmartConnect aclk1 (clock domain crossing) + exposed to root
  connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] \
    [get_bd_pins smartconnect_1/aclk1] \
    [get_bd_pins ui_clk]

  # DDR4 additional 200 MHz output (VCO=1000 MHz / 5) → exposed to root for clk_wiz_0
  connect_bd_net [get_bd_pins ddr4_0/addn_ui_clkout1] [get_bd_pins addn_clk_200]

  # DDR4 AXI reset: invert sync_rst → aresetn
  connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst] [get_bd_pins rst_inv/Op1]
  connect_bd_net [get_bd_pins rst_inv/Res] [get_bd_pins ddr4_0/c0_ddr4_aresetn]

  # DDR4 system reset (active HIGH)
  connect_bd_net [get_bd_pins sys_reset] [get_bd_pins ddr4_0/sys_rst]

  # Calibration complete signal to root
  connect_bd_net [get_bd_pins ddr4_0/c0_init_calib_complete] [get_bd_pins c0_init_calib_complete]

  current_bd_instance $oldCurInst
}

##################################################################
# Root design
##################################################################
proc create_root_design { parentCell } {
  variable script_folder
  variable design_name

  if { $parentCell eq "" } { set parentCell [get_bd_cells /] }
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }
  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentObj

  # ----------------------------------------------------------------
  # Interface ports
  # ----------------------------------------------------------------

  # 200 MHz system clock → DDR4 MIG (IBUFDS inside MIG); DDR4 UI clock feeds clk_wiz_0
  set sys_diff_clock [create_bd_intf_port -mode Slave \
    -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_diff_clock]
  set_property -dict [list CONFIG.FREQ_HZ {200000000}] $sys_diff_clock

  set ddr4_sdram_c0 [create_bd_intf_port -mode Master \
    -vlnv xilinx.com:interface:ddr4_rtl:1.0 ddr4_sdram_c0]

  set rgmii [create_bd_intf_port -mode Master \
    -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii]

  # ----------------------------------------------------------------
  # Scalar ports
  # ----------------------------------------------------------------
  set resetn [create_bd_port -dir I -type rst resetn]
  set_property -dict [list CONFIG.POLARITY {ACTIVE_LOW}] $resetn

  set eth_mdio_clock [create_bd_port -dir O eth_mdio_clock]
  set eth_mdio_data  [create_bd_port -dir IO eth_mdio_data]
  set eth_mdio_int   [create_bd_port -dir I eth_mdio_int]
  set eth_mdio_reset [create_bd_port -dir O eth_mdio_reset]

  set sdio_cd    [create_bd_port -dir I sdio_cd]
  set sdio_clk   [create_bd_port -dir O sdio_clk]
  set sdio_cmd   [create_bd_port -dir IO sdio_cmd]
  set sdio_dat   [create_bd_port -dir IO -from 3 -to 0 sdio_dat]
  set sdio_reset [create_bd_port -dir O -type rst sdio_reset]

  set usb_uart_rxd [create_bd_port -dir I usb_uart_rxd]
  set usb_uart_txd [create_bd_port -dir O usb_uart_txd]

  # ----------------------------------------------------------------
  # Hierarchy instances
  # ----------------------------------------------------------------
  create_hier_cell_DDR [current_bd_instance .] DDR
  create_hier_cell_IO  [current_bd_instance .] IO

  global rocket_module_name
  set RocketChip [create_bd_cell -type module -reference $rocket_module_name RocketChip]


  # clk_wiz_0: 200 MHz input from DDR4 addn_ui_clkout1 (No_buffer), VCO = 1000 MHz
  #   clk_out1 = 125 MHz         (Ethernet, phase reference for clk_out2)
  #   clk_out2 = 125 MHz @90°   (Ethernet TX USE_CLK90)
  #   clk_out3 = 100 MHz         (CPU/AXI/UART/SD)
  # DDR4 addn_ui_clkout1 = 200 MHz exactly (PLL VCO=1000 MHz / 5, integer division)
  set clk_wiz_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0]
  set_property -dict [list \
    CONFIG.PRIM_SOURCE              {No_buffer}  \
    CONFIG.PRIM_IN_FREQ             {200.000}    \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125.000}  \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125.000}  \
    CONFIG.CLKOUT2_REQUESTED_PHASE  {90.000}     \
    CONFIG.CLKOUT2_USED             {true}       \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {100.000}  \
    CONFIG.CLKOUT3_USED             {true}       \
    CONFIG.NUM_OUT_CLKS             {3}          \
    CONFIG.USE_PHASE_ALIGNMENT      {true}       \
    CONFIG.USE_RESET                {false}      \
    CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {true} \
  ] $clk_wiz_0

  # Invert resetn (active LOW) → sys_reset (active HIGH) for DDR4 sys_rst
  set resetn_inv_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 resetn_inv_0]
  set_property -dict [list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}] $resetn_inv_0

  # ----------------------------------------------------------------
  # Interface connections
  # ----------------------------------------------------------------
  connect_bd_intf_net [get_bd_intf_ports sys_diff_clock] [get_bd_intf_pins DDR/ddr4_sys_clk]
  connect_bd_intf_net [get_bd_intf_ports ddr4_sdram_c0] [get_bd_intf_pins DDR/ddr4_sdram_c0]
  connect_bd_intf_net [get_bd_intf_ports rgmii]         [get_bd_intf_pins IO/RGMII]
  connect_bd_intf_net [get_bd_intf_pins IO/M00_AXI]     [get_bd_intf_pins RocketChip/DMA_AXI4]
  connect_bd_intf_net [get_bd_intf_pins IO/S00_AXI]     [get_bd_intf_pins RocketChip/IO_AXI4]
  connect_bd_intf_net [get_bd_intf_pins DDR/S00_AXI]    [get_bd_intf_pins RocketChip/MEM_AXI4]

  # ----------------------------------------------------------------
  # Net connections
  # ----------------------------------------------------------------

  # DDR4 additional 200 MHz clock → clk_wiz_0 for user/AXI/ETH clocks
  connect_bd_net [get_bd_pins DDR/addn_clk_200] [get_bd_pins clk_wiz_0/clk_in1]

  # 125 MHz: Ethernet clock (clk_out1 = phase reference for clk_out2)
  connect_bd_net -net ETH_clock \
    [get_bd_pins clk_wiz_0/clk_out1] \
    [get_bd_pins IO/clock_125MHz]

  # 125 MHz 90°: Ethernet TX clock (phase-aligned with clk_out1)
  connect_bd_net -net ETH_clock_90 \
    [get_bd_pins clk_wiz_0/clk_out2] \
    [get_bd_pins IO/clock_125MHz_90]

  # 100 MHz: CPU clock, DDR AXI clock, IO AXI clock, UART/SD clocks
  connect_bd_net -net AXI_clock \
    [get_bd_pins clk_wiz_0/clk_out3] \
    [get_bd_pins DDR/axi_clock]       \
    [get_bd_pins IO/axi_clock]        \
    [get_bd_pins RocketChip/clock]

  # PLL locked → clock_ok and io_ok
  connect_bd_net -net clock_ok \
    [get_bd_pins clk_wiz_0/locked]    \
    [get_bd_pins RocketChip/clock_ok] \
    [get_bd_pins RocketChip/io_ok]

  # DDR4 calibration done → mem_ok
  connect_bd_net [get_bd_pins DDR/c0_init_calib_complete] [get_bd_pins RocketChip/mem_ok]

  # System reset: resetn (active LOW) → inverted (active HIGH) → DDR4 + RocketChip
  connect_bd_net [get_bd_ports resetn]           [get_bd_pins resetn_inv_0/Op1]
  connect_bd_net -net sys_reset                  \
    [get_bd_pins resetn_inv_0/Res]               \
    [get_bd_pins DDR/sys_reset]                  \
    [get_bd_pins RocketChip/sys_reset]

  # AXI reset: comes from RocketChip/aresetn (output, active LOW)
  connect_bd_net -net AXI_reset \
    [get_bd_pins RocketChip/aresetn] \
    [get_bd_pins DDR/axi_reset]      \
    [get_bd_pins IO/axi_reset]

  # Interrupts
  connect_bd_net [get_bd_pins IO/interrupts] [get_bd_pins RocketChip/interrupts]

  # IO ports
  connect_bd_net [get_bd_ports eth_mdio_clock] [get_bd_pins IO/eth_mdio_clock]
  connect_bd_net [get_bd_ports eth_mdio_data]  [get_bd_pins IO/eth_mdio_data]
  connect_bd_net [get_bd_ports eth_mdio_int]   [get_bd_pins IO/eth_mdio_int]
  connect_bd_net [get_bd_ports eth_mdio_reset] [get_bd_pins IO/eth_mdio_reset]

  connect_bd_net [get_bd_ports sdio_cd]    [get_bd_pins IO/sdio_cd]
  connect_bd_net [get_bd_ports sdio_clk]   [get_bd_pins IO/sdio_clk]
  connect_bd_net [get_bd_ports sdio_cmd]   [get_bd_pins IO/sdio_cmd]
  connect_bd_net [get_bd_ports sdio_dat]   [get_bd_pins IO/sdio_dat]
  connect_bd_net [get_bd_ports sdio_reset] [get_bd_pins IO/sdio_reset]

  connect_bd_net [get_bd_ports usb_uart_rxd] [get_bd_pins IO/usb_uart_rxd]
  connect_bd_net [get_bd_ports usb_uart_txd] [get_bd_pins IO/usb_uart_txd]

  # ----------------------------------------------------------------
  # Address map
  # ----------------------------------------------------------------
  # SD card registers
  assign_bd_address -offset 0x60000000 -range 0x00010000 \
    -target_address_space [get_bd_addr_spaces RocketChip/IO_AXI4] \
    [get_bd_addr_segs IO/SD/S_AXI_LITE/reg0] -force

  # UART registers
  assign_bd_address -offset 0x60010000 -range 0x00010000 \
    -target_address_space [get_bd_addr_spaces RocketChip/IO_AXI4] \
    [get_bd_addr_segs IO/UART/S_AXI_LITE/reg0] -force

  # Ethernet registers
  assign_bd_address -offset 0x60020000 -range 0x00010000 \
    -target_address_space [get_bd_addr_spaces RocketChip/IO_AXI4] \
    [get_bd_addr_segs IO/Ethernet/S_AXI_LITE/reg0] -force

  # DDR4 memory (2 GB)
  assign_bd_address -offset 0x00000000 -range 0x80000000 \
    -target_address_space [get_bd_addr_spaces RocketChip/MEM_AXI4] \
    [get_bd_addr_segs DDR/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force

  # DMA address space (Ethernet + SD → RocketChip DMA port, 4 GB max)
  assign_bd_address -offset 0x00000000 -range 0x000100000000 \
    -target_address_space [get_bd_addr_spaces IO/Ethernet/M_AXI] \
    [get_bd_addr_segs RocketChip/DMA_AXI4/reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 \
    -target_address_space [get_bd_addr_spaces IO/SD/M_AXI] \
    [get_bd_addr_segs RocketChip/DMA_AXI4/reg0] -force

  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}

##################################################################
# MAIN FLOW
##################################################################

create_root_design ""
