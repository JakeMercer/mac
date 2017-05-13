reg                 reset;

wire     [WIDTH-1:0] data_in_sig;
reg                  data_in_clock;
wire                 data_in_enable;
wire                 data_in_start_sig;
wire                 data_in_end_sig;

wire    [WIDTH-1:0] data_out_sig;
wire                data_out_start_sig;
wire                data_out_end_sig;
reg                 data_out_clock;
wire                data_out_enable;

fifo #(
    .DATA_WIDTH (WIDTH),
    .FIFO_DEPTH (DEPTH)
)
ff ( 
    .reset(reset),

    // IN PORT
    .data_in(data_in_sig),
    .data_in_clock(data_in_clock),
    .data_in_enable(data_in_enable),
    .data_in_start(data_in_start_sig),
    .data_in_end(data_in_end_sig),

    // OUT PORT
    .data_out(data_out_sig),
    .data_out_clock(data_out_clock),
    .data_out_enable(data_out_enable),
    .data_out_start(data_out_start_sig),
    .data_out_end(data_out_end_sig)
);

utilities #(.OUT_WIDTH (1),
            .IN_WIDTH (1)) 
util (
    .data_in(),
    .data_in_enable(),
    .data_out(),
    .data_out_enable(),
    .clock(clock)
);
utilities #(.OUT_WIDTH (WIDTH),
            .IN_WIDTH (WIDTH),
            .DEBUG(1)) 
data_in (
    .data_in(),
    .data_in_enable(),
    .data_out(data_in_sig),
    .data_out_enable(data_in_enable),
    .clock(data_in_clock)
);

utilities #(.OUT_WIDTH (1),
            .IN_WIDTH (1))
data_in_start (
    .data_in(),
    .data_in_enable(),
    .data_out(data_in_start_sig),
    .data_out_enable(),
    .clock(data_in_clock)
);

utilities #(.OUT_WIDTH (1),
            .IN_WIDTH (1))
data_in_end (
    .data_in(),
    .data_in_enable(),
    .data_out(data_in_end_sig),
    .data_out_enable(),
    .clock(data_in_clock)
);

utilities #(.OUT_WIDTH (WIDTH),
            .IN_WIDTH (WIDTH),
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
    data_in_clock = 0;
    data_out_clock = 0;    
    reset = 1;
end

always
    #5 data_in_clock = ~data_in_clock;

always
    #5 data_out_clock = ~data_out_clock;
