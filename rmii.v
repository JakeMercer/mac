module rmii 
(
    input   wire        reset,
    
    // PHY Interface
    input   wire        phy_ref_clk,
    output  reg  [1:0]  phy_txd,
    output  wire        phy_tx_en,
    input   wire [1:0]  phy_rxd,
    input   wire        phy_rx_er,
    input   wire        phy_crs_dv,

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
reg [1:0] tx_index;
reg [1:0] rx_index;

assign phy_tx_er    = mac_tx_er;
assign phy_tx_en    = mac_tx_en;
assign mac_col      = phy_crs_dv & mac_tx_en;
assign mac_rx_er    = phy_rx_er;
assign mac_crs      = phy_crs_dv;
assign mac_rx_dv    = phy_crs_dv;

clock_divider #(.DIVIDER(4)) clk_div
(
    .reset(reset),
    .clock_in(phy_ref_clk),
    .clock_out(mac_tx_clk)
);

assign mac_rx_clk = mac_tx_clk;

always @(posedge phy_ref_clk)
begin
    if (reset)
    begin
        tx_index <= 0;
    end
    else if (mac_tx_en && tx_index < 3)
    begin
        tx_index <= tx_index + 1;
    end
    else
    begin
        tx_index <= 0;
    end

end

always @(posedge phy_ref_clk)
begin
    if (reset)
    begin
        phy_txd <= 0;
    end
    else
    begin
        phy_txd <= mac_txd[tx_index*2+:2];
    end
end

always @(posedge phy_ref_clk)
begin
    if (reset)
    begin
        rx_index <= 0;
    end
    else if (phy_crs_dv && rx_index < 3)
    begin
        rx_index <= rx_index + 1;
    end
    else
    begin
        rx_index <= 0;
    end

end

always @(posedge phy_ref_clk)
begin
    if (reset)
    begin
        mac_rxd <= 0;
    end
    else
    begin
        mac_rxd[rx_index*2+:2] <= phy_rxd;
    end
end

endmodule
