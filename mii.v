module mii 
(
    input   wire        reset,
    
    // PHY Interface
    output  wire        phy_tx_er,
    output  reg  [3:0]  phy_txd,
    output  wire        phy_tx_en,
    input   wire        phy_tx_clk,
    input   wire        phy_col,
    input   wire [3:0]  phy_rxd,
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
    output  reg  [7:0]  mac_rxd,
    output  wire        mac_rx_er,
    output  wire        mac_rx_clk,
    output  wire        mac_crs,
    output  wire        mac_rx_dv
);
reg tx_index;
reg rx_index;

assign phy_tx_er    = mac_tx_er;
assign phy_tx_en    = mac_tx_en;
assign mac_col      = phy_col;
assign mac_rx_er    = phy_rx_er;
assign mac_crs      = phy_crs;
assign mac_rx_dv    = phy_rx_dv;

clock_divider #(.DIVIDER(2)) clk_div_tx
(
    .reset(reset),
    .clock_in(phy_tx_clk),
    .clock_out(mac_tx_clk)
);

clock_divider #(.DIVIDER(2)) clk_div_rx
(
    .reset(reset),
    .clock_in(phy_rx_clk),
    .clock_out(mac_rx_clk)
);

always @(posedge phy_tx_clk)
begin
    if (reset)
    begin
        tx_index <= 0;
    end
    else
    begin
        tx_index <= ~tx_index;
    end
end

always @(posedge phy_tx_clk)
begin
    if (reset)
    begin
        phy_txd <= 0;
    end
    else
    begin
        phy_txd <= mac_txd[tx_index*4+:4];
    end
end

always @(posedge phy_rx_clk)
begin
    if (reset)
    begin
        rx_index <= 0;
    end
    else
    begin
        rx_index <= ~rx_index;
    end
end

always @(posedge phy_rx_clk)
begin
    if (reset)
    begin
        mac_rxd <= 0;
    end
    else
    begin
        mac_rxd[rx_index*4+:4] <= phy_rxd;
    end
end

endmodule
