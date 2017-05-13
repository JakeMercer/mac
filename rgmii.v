module rgmii 
(
    input   wire        reset,
    input   wire        generated_clk,

    // PHY Interface
    output  wire [3:0]  phy_txd_rising,
    output  wire [3:0]  phy_txd_falling,    
    output  wire        phy_tx_ctl_rising,
    output  wire        phy_tx_ctl_falling,    
    output  wire        phy_gtx_clk,
    input   wire [3:0]  phy_rxd_rising,
    input   wire [3:0]  phy_rxd_falling,
    input   wire        phy_rx_ctl_rising,
    input   wire        phy_rx_ctl_falling,    
    input   wire        phy_rx_clk,

    // MAC Interface
    input   wire        mac_tx_er,
    input   wire [7:0]  mac_txd,
    input   wire        mac_tx_en,
    output  wire        mac_tx_clk,
    output  wire        mac_col,
    output  wire [7:0]  mac_rxd,
    output  wire        mac_rx_er,
    output  wire        mac_rx_clk,
    output  wire        mac_crs,
    output  wire        mac_rx_dv
);

assign phy_txd_rising       = mac_txd[3:0];
assign phy_txd_falling      = mac_txd[7:4];
assign phy_tx_ctl_rising    = mac_tx_en;
assign phy_tx_ctl_falling   = mac_tx_en ^ mac_tx_er;
assign phy_gtx_clk          = generated_clk;
assign mac_col              = (mac_crs & mac_tx_en) | (mac_rx_dv & mac_tx_en);
assign mac_rxd [3:0]        = phy_rxd_rising;
assign mac_rxd [7:4]        = phy_rxd_falling;
assign mac_rx_er            = phy_rx_ctl_falling ^ phy_rx_ctl_rising;
assign mac_rx_clk           = phy_rx_clk;
assign mac_crs              = mac_rx_dv | ( mac_rx_er && mac_rxd == 8'hFF ) | ( mac_rx_er && mac_rxd == 8'h0E ) | ( mac_rx_er && mac_rxd == 8'h0F ) | ( mac_rx_er && mac_rxd == 8'h1F );
assign mac_rx_dv            = phy_rx_ctl_rising;
assign mac_tx_clk           = generated_clk;

endmodule
