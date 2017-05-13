reg reset;
reg tx_clock;
reg rx_clock;
reg carrier_sense;
reg collision;
wire tx_enable;
wire [7:0] tx_data;
wire rx_data_valid;
wire [7:0] rx_data;
wire rx_error;
reg expected_tx_enable;

mac_loopback U_mac_loopback(
    .reset(reset),

    .tx_clock(tx_clock),
    .rx_clock(rx_clock),

    .carrier_sense(carrier_sense),
    .collision(collision),

    .tx_enable(tx_enable),
    .tx_data(tx_data),

    .rx_data_valid(rx_data_valid),       
    .rx_data(rx_data),         
    .rx_error(rx_error)
);

utilities #(.OUT_WIDTH (1),
            .IN_WIDTH (1)) 
util (
    .data_in(1'b0),
    .data_in_enable(),
    .data_out(),
    .data_out_enable(),
    .clock()
);

utilities #(.OUT_WIDTH (8),
            .IN_WIDTH (8))
data_in (
    .data_in(),
    .data_in_enable(),
    .data_out(rx_data),
    .data_out_enable(rx_data_valid),
    .clock(rx_clock)
);

utilities #(.OUT_WIDTH (8),
            .IN_WIDTH (8))
data_out (
    .data_in(tx_data),
    .data_in_enable(),
    .data_out(),
    .data_out_enable(),
    .clock(tx_clock)
);

monitor #(.WIDTH(1))
tx_enable_monitor(
    .data(tx_enable),
    .expected(expected_tx_enable),
    .clock(tx_clock));

initial
begin
    rx_clock        = 0;
    tx_clock        = 0;    
    reset           = 1;
    collision       = 0;
    carrier_sense   = 0;
    expected_tx_enable = 0;
end

always
    #5 rx_clock = ~rx_clock;

always
    #5 
        tx_clock = ~tx_clock;
