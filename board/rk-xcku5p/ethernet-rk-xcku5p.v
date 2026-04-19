// RGMII wrapper for RK-XCKU5P (Kintex UltraScale+, Bank 66 HP 1.8V)
// RTL8211F-CG PHY: RXDLY=1 (default), TXDLY=0
//
// Bank 66 HP bank constraints:
//   - No BUFR: use CLOCK_INPUT_STYLE="BUFG"
//   - No ODELAYE3: use USE_CLK90="TRUE" (125 MHz 90deg from clk_wiz)
//   - IDELAYE3 available for RX but omitted (PHY RXDLY handles it)

module ethernet_rk_xcku5p (
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input  wire        reset,

    // Note: FREQ_HZ omitted so BD can infer from upstream (clk_wiz output).
    // In this project clk_wiz is driven from DDR4 UI clock (333.25 MHz),
    // producing ~124.97 MHz instead of exactly 125 MHz. RGMII spec tolerates
    // this (~250 ppm, vs IEEE 802.3 gigabit limit of 100 ppm — still works
    // with the RTL8211F auto-negotiation in practice).
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock125 CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF TX_AXIS:RX_AXIS, ASSOCIATED_RESET reset" *)
    input  wire        clock125,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock125_90 CLK" *)
    input  wire        clock125_90,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TDATA" *)
    input  wire [7:0]  tx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TKEEP" *)
    input  wire [0:0]  tx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TVALID" *)
    input  wire        tx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TREADY" *)
    output wire        tx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TLAST" *)
    input  wire        tx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TUSER" *)
    input  wire        tx_axis_tuser,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TDATA" *)
    output wire [7:0]  rx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TKEEP" *)
    output wire [0:0]  rx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TVALID" *)
    output wire        rx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TREADY" *)
    input  wire        rx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TLAST" *)
    output wire        rx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TUSER" *)
    output wire        rx_axis_tuser,

    output wire [15:0] status_vector,

    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII RD" *)
    input  wire [3:0]  rgmii_rxd,
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII RX_CTL" *)
    input  wire        rgmii_rx_ctl,
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII RXC" *)
    input  wire        rgmii_rxc,
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII TD" *)
    output wire [3:0]  rgmii_txd,
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII TX_CTL" *)
    output wire        rgmii_tx_ctl,
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII TXC" *)
    output wire        rgmii_txc
);

assign status_vector[15:11] = 5'b0;

eth_mac_1g_rgmii_fifo #(
    .TARGET("XILINX"),
    .IODDR_STYLE("IODDR"),
    // BUFG required: HP banks have no BUFR
    .CLOCK_INPUT_STYLE("BUFG"),
    // USE_CLK90=TRUE: drive TX clock from 90-degree phase output (no ODELAYE3 in HP)
    .USE_CLK90("TRUE"),
    .ENABLE_PADDING(1),
    .AXIS_DATA_WIDTH(8),
    .MIN_FRAME_LENGTH(64),
    .TX_FIFO_DEPTH(4096),
    .TX_FRAME_FIFO(1),
    .RX_FIFO_DEPTH(16384),
    .RX_FRAME_FIFO(1),
    .RX_DROP_BAD_FRAME(0),
    .RX_DROP_WHEN_FULL(1)
)
eth_mac_inst (
    .gtx_clk(clock125),
    .gtx_clk90(clock125_90),
    .gtx_rst(reset),
    .logic_clk(clock125),
    .logic_rst(reset),

    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tkeep(tx_axis_tkeep),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),

    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tkeep(rx_axis_tkeep),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tready(rx_axis_tready),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),

    .rgmii_rx_clk(rgmii_rxc),
    .rgmii_rx_ctl(rgmii_rx_ctl),
    .rgmii_rxd(rgmii_rxd),

    .rgmii_tx_clk(rgmii_txc),
    .rgmii_tx_ctl(rgmii_tx_ctl),
    .rgmii_txd(rgmii_txd),

    .tx_fifo_overflow(status_vector[0]),
    .tx_fifo_bad_frame(status_vector[1]),
    .tx_fifo_good_frame(status_vector[2]),
    .tx_error_underflow(status_vector[3]),
    .rx_error_bad_frame(status_vector[4]),
    .rx_error_bad_fcs(status_vector[5]),
    .rx_fifo_overflow(status_vector[6]),
    .rx_fifo_bad_frame(status_vector[7]),
    .rx_fifo_good_frame(status_vector[8]),
    .speed(status_vector[10:9]),

    .cfg_ifg(8'd12),
    .cfg_tx_enable(1'b1),
    .cfg_rx_enable(1'b1)
);

endmodule
