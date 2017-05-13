module gmii 
(
    input   wire        reset,
    input   wire        clock_125MHz,

    // PHY Interface
    output  wire        phy_tx_er,
    output  wire [7:0]  phy_txd,
    output  wire        phy_tx_en,
    output  wire        phy_gtx_clk,
    input   wire        phy_col,
    input   wire [7:0]  phy_rxd,
    input   wire        phy_rx_er,
    input   wire        phy_rx_clk,
    input   wire        phy_crs,
    input   wire        phy_rx_dv,

    // MAC Interface
    input   wire        mac_tx_er,
    input   wire [7:0]  mac_txd,
    input   wire        mac_tx_en,
    output  wire        mac_tx_clk,
    output  wire        mac_col,
    output  wire  [7:0] mac_rxd,
    output  wire        mac_rx_er,
    output  wire        mac_rx_clk,
    output  wire        mac_crs,
    output  wire        mac_rx_dv
);

assign phy_tx_er    = mac_tx_er;
assign phy_txd      = mac_txd;
assign phy_tx_en    = mac_tx_en;
assign phy_gtx_clk  = clock_125MHz;
assign mac_col      = phy_col;
assign mac_rxd      = phy_rxd;
assign mac_rx_er    = phy_rx_er;
assign mac_rx_clk   = phy_rx_clk;
assign mac_crs      = phy_crs;
assign mac_rx_dv    = phy_rx_dv;
assign mac_tx_clk   = clock_125MHz;

endmodule
