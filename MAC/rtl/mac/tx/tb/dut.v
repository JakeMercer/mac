reg         reset;
reg         clock;

wire [7:0]  fifo_data;
wire        fifo_data_read;
wire        fifo_data_start;
wire        fifo_data_end;
reg         fifo_data_available;
wire        fifo_retry;

reg         mode;

reg         carrier_sense;
reg         collision;

wire        tx_enable;
wire [7:0]  tx_data;

reg  [7:0]  tempdata;
reg         expected_tx_enable;

tx_sm U_tx_sm(
    .reset(reset),
    .clock(clock),
    
    .fifo_data(fifo_data),
    .fifo_data_read(fifo_data_read),
    .fifo_data_start(fifo_data_start),
    .fifo_data_end(fifo_data_end),
    .fifo_data_available(fifo_data_available),
    .fifo_retry(fifo_retry),

    .mode(mode),

    .carrier_sense(carrier_sense),
    .collision(collision),

    .tx_enable(tx_enable),
    .tx_data(tx_data)
);

utilities #(.OUT_WIDTH (1),
            .IN_WIDTH (1)) 
util (
    .data_in(1'b0),
    .data_in_enable(),
    .data_out(),
    .data_out_enable(),
    .clock(clock)
);

utilities #(.OUT_WIDTH (8),
            .IN_WIDTH (8))
data (
    .data_in(tx_data),
    .data_in_enable(),
    .data_out(fifo_data),
    .data_out_enable(),
    .clock(clock)
);

utilities #(.OUT_WIDTH (1),
            .IN_WIDTH (1))
data_start (
    .data_in(),
    .data_in_enable(),
    .data_out(fifo_data_start),
    .data_out_enable(),
    .clock(clock)
);

utilities #(.OUT_WIDTH (1),
            .IN_WIDTH (1))
data_end (
    .data_in(),
    .data_in_enable(),
    .data_out(fifo_data_end),
    .data_out_enable(),
    .clock(clock)
);

monitor #(.WIDTH(1))
tx_enable_monitor(
    .data(tx_enable),
    .expected(expected_tx_enable),
    .clock(clock));
initial
begin
    clock           = 0;
    reset           = 1;
    mode            = 1;
    collision       = 0;
    carrier_sense   = 0;
    fifo_count      = 0;
    expected_tx_enable = 0;
end

always
    #5 clock = ~clock;
