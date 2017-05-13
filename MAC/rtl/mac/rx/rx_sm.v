module rx_sm #(
    parameter       STATE_IDLE          = 3'h0,
    parameter       STATE_PREAMBLE      = 3'h1,
    parameter       STATE_DATA          = 3'h2,
    parameter       STATE_OK            = 3'h3,
    parameter       STATE_DROP          = 3'h4,
    parameter       STATE_ERROR         = 3'h5,
    parameter       FIFO_DEPTH          = 12
)(
    input           reset,
    input           clock,

    input           rx_data_valid,
    input   [7:0]   rx_data,
    input           rx_error,

    // OUT PORT
    output  wire    [7:0]               data_out,
    input   wire                        data_out_clock,     
    input   wire                        data_out_enable,
    output  wire                        data_out_start,
    output  wire                        data_out_end,
    output  wire    [FIFO_DEPTH-1:0]    data_out_address,
    input   wire                        data_out_reset,
    input   wire    [FIFO_DEPTH-1:0]    data_out_reset_address,
    output  reg                         data_available,
    output  wire                        fifo_full
);

localparam CRC_RESIDUE      = 32'hC704DD7B;
localparam CRC_POLYNOMIAL   = 32'h04C11DB7;
localparam CRC_SEED         = 32'hFFFFFFFF;
localparam MAX_SIZE         = 1518;
localparam MIN_SIZE         = 64;
   
wire [FIFO_DEPTH:0] fifo_count;
wire [FIFO_DEPTH-1:0] data_in_address;
reg [FIFO_DEPTH-1:0] data_in_reset_address;
reg start_of_frame;
reg end_of_frame;
reg error;

reg [2:0]  state;
reg [2:0]  next_state;
reg [15:0] frame_length_counter;
reg [15:0] data_counter;
reg         data_write_enable;
reg        too_long;
reg        too_short;

reg        crc_init;
reg        data_enable;
wire [31:0] crc_out;

reg [39:0] data;

// RX State Machine
always @ (posedge reset or posedge clock)
    if (reset)
        state <= STATE_IDLE;
    else
        state <= next_state;

always @ (*)
    case (state)
        STATE_IDLE:
                if (rx_data_valid && rx_data == 8'h55)
                    next_state = STATE_PREAMBLE;
                else
                    next_state = STATE_IDLE;
        STATE_PREAMBLE:
                if (!rx_data_valid)
                    next_state = STATE_ERROR;
                else if (rx_error)
                    next_state = STATE_DROP;
                else if (rx_data == 8'hd5)
                    next_state = STATE_DATA;
                else if (rx_data == 8'h55)
                    next_state = STATE_PREAMBLE;
                else
                    next_state = STATE_DROP;
        STATE_DATA:
                if (!rx_data_valid && !too_short && !too_long && crc_out == CRC_RESIDUE)
                    next_state = STATE_OK;
                else if ((!rx_data_valid && (too_short || too_long)) || (!rx_data_valid && crc_out != CRC_RESIDUE))
                    next_state = STATE_ERROR;
                else if (fifo_full)
                    next_state = STATE_DROP;
                else if (rx_error || too_long)
                    next_state = STATE_DROP;
                else
                    next_state = STATE_DATA;
        STATE_DROP:
                if (!rx_data_valid)
                    next_state = STATE_ERROR;
                else
                    next_state = STATE_DROP;
        STATE_OK:
                    next_state = STATE_IDLE;
        STATE_ERROR:
                    next_state = STATE_IDLE;
        default:
                    next_state = STATE_IDLE;
    endcase


always @(posedge clock or posedge reset)
begin
    if (reset)
    begin
        data <= 32'h00000000;
    end
    else if (state == STATE_IDLE)
    begin
        data <= 32'h00000000;
    end
    else
    begin
        data[39-:8] <= data[31-:8];        
        data[31-:8] <= data[23-:8];
        data[23-:8] <= data[15-:8];
        data[15-:8] <= data[7-:8];
        data[7-:8]  <= rx_data;
    end
end

always @ ( state or fifo_count )
begin
    if (fifo_count && state == STATE_OK)
    begin
        data_available <= 1;
    end
    else if (!fifo_count)
    begin
        data_available <= 0;
    end
end

always @ (posedge clock or posedge reset)
    if (reset)
        data_counter <= 0;
    else if (state == STATE_DATA)
        data_counter = data_counter + 1;
    else
        data_counter = 0;

always @ (data_counter or state)
    if (data_counter > 4 && state == STATE_DATA && next_state == STATE_DATA)
        data_write_enable = 1;
    else
        data_write_enable = 0;

always @(data_counter)
    if (data_counter == 5)
        start_of_frame = 1;
    else
        start_of_frame = 0;

always @(state or next_state)
    if (state == STATE_DATA && next_state != STATE_DATA)
        end_of_frame = 1;
    else
        end_of_frame = 0;

always @(state)
    if  (state == STATE_ERROR)
        error = 1;
    else
        error = 0;

// CRC Interface
always @(state)
    if (state == STATE_DATA)
        data_enable = 1;
    else
        data_enable = 0;

always @(state or next_state)
    if (state == STATE_PREAMBLE && next_state == STATE_DATA)
    begin
        crc_init <= 1;
        data_in_reset_address <= data_in_address;
    end
    else
        crc_init = 0;

always @ (posedge clock or posedge reset)
    if (reset)
        frame_length_counter <= 0;
    else if (state == STATE_DATA)
        frame_length_counter = frame_length_counter + 1;
    else
        frame_length_counter = 0;

always @ (frame_length_counter)
    if (frame_length_counter < MIN_SIZE)
        too_short = 1;
    else
        too_short = 0;

always @ (frame_length_counter)
    if (frame_length_counter > MAX_SIZE)
        too_long = 1;
    else
        too_long = 0;

// CRC
crc #(  .POLYNOMIAL(CRC_POLYNOMIAL),
        .DATA_WIDTH(8),
        .CRC_WIDTH(32),
        .SEED(CRC_SEED))
U_crc(
    .reset(reset),
    .clock(clock),
    .init(crc_init),
    .data(rx_data),
    .data_enable(data_enable),
    .crc_out(crc_out)
);

// FIFO
fifo #(
    .DATA_WIDTH (8),
    .FIFO_DEPTH (FIFO_DEPTH)
)
U_fifo ( 
    .reset(reset),
    .count(fifo_count),
    .full(fifo_full),

    // IN PORT
    .data_in(data[39-:8]),
    .data_in_start(start_of_frame),
    .data_in_end(end_of_frame),    
    .data_in_clock(clock),
    .data_in_enable(data_write_enable),
    .data_in_address(data_in_address),
    .data_in_reset(error),
    .data_in_reset_address(data_in_reset_address),
    // OUT PORT
    .data_out(data_out),
    .data_out_start(data_out_start),
    .data_out_end(data_out_end),
    .data_out_clock(data_out_clock),
    .data_out_enable(data_out_enable),
    .data_out_address(data_out_address),
    .data_out_reset(data_out_reset),
    .data_out_reset_address(data_out_reset_address)
);

endmodule
