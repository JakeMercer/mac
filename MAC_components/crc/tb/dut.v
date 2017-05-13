wire  [DATA_WIDTH-1:0]   data_in;
wire                     data_in_enable;
wire [CRC_WIDTH-1:0]    crc_out;   
reg                     clock;     
reg                     reset;     
reg  [CRC_WIDTH-1:0]    tempdata;

crc #(  .POLYNOMIAL(POLYNOMIAL),
        .DATA_WIDTH(DATA_WIDTH),
        .CRC_WIDTH(CRC_WIDTH),
        .SEED(SEED),
        .DEBUG(0)) 
U_crc(
    .data(data_in),
    .data_enable(data_in_enable),
    .crc_out(crc_out),    
    .init(),
    .clock(clock),
    .reset(reset)
);

utilities #(.OUT_WIDTH (DATA_WIDTH),
            .IN_WIDTH (CRC_WIDTH),
            .DEBUG(1)) 
util (
    .data_in(crc_out),
    .data_in_enable(),
    .data_out(data_in),
    .data_out_enable(data_in_enable),
    .clock(clock)
);

initial
begin
    clock = 0;
    reset = 1;
end

always
    #5 clock = ~clock;
