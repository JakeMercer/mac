reg         reset;
reg         clock;

wire [7:0]  rx_data;
wire        rx_data_valid;
reg         rx_error;

wire [7:0]  data_out_sig;
wire        data_out_start_sig;
wire        data_out_end_sig;
reg         data_out_clock;
wire        data_out_enable;
wire        data_available;
wire        fifo_full;

rx_sm #(.FIFO_DEPTH(10)) U_rx_sm(
    .reset(reset),
    .clock(clock),
   
    // OUT PORT
    .data_out(data_out_sig),
    .data_out_clock(data_out_clock),     
    .data_out_enable(data_out_enable),
    .data_out_start(data_out_start_sig),
    .data_out_end(data_out_end_sig),
    .data_available(data_available),
    .fifo_full(fifo_full),

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
    .clock(clock)
);

utilities #(.OUT_WIDTH (8),
            .IN_WIDTH (8))
data (
    .data_in(),
    .data_in_enable(),
    .data_out(rx_data),
    .data_out_enable(rx_data_valid),
    .clock(clock)
);

utilities #(.OUT_WIDTH (8),
            .IN_WIDTH (8),
            .DEBUG(1)) 
data_out (
    .data_in(data_out_sig),
    .data_in_enable(data_out_enable),
    .data_out(),
    .data_out_enable(),
    .clock(data_out_clock)
);

utilities #(.OUT_WIDTH (1),
            .IN_WIDTH (1))
data_out_start (
    .data_in(data_out_start_sig),
    .data_in_enable(),
    .data_out(),
    .data_out_enable(),
    .clock(data_out_clock)
);

utilities #(.OUT_WIDTH (1),
            .IN_WIDTH (1))
data_out_end (
    .data_in(data_out_end_sig),
    .data_in_enable(),
    .data_out(),
    .data_out_enable(),
    .clock(data_out_clock)
);

initial
begin
    clock           = 0;
    reset           = 1;
    rx_error        = 0;
    data_out_clock  = 0;
end

always
    #5 clock = ~clock;

always
    #5 data_out_clock = ~data_out_clock;
