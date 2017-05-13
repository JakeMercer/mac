module rx #(
    parameter       STATE_IDLE          = 3'h0,
    parameter       STATE_PREAMBLE      = 3'h1,
    parameter       STATE_DATA          = 3'h2,
    parameter       STATE_OK            = 3'h3,
    parameter       STATE_DROP          = 3'h4,
    parameter       STATE_ERROR         = 3'h5
)(
    input           reset,
    input           clock,

    input           rx_data_valid,
    input   [7:0]   rx_data,
    input           rx_error,

    output  reg     [7:0]   data_out,
    output  reg             data_out_enable,
    output  reg             data_out_start,
    output  reg             data_out_end,
    input   wire            fifo_full,
    output  reg             error
);

localparam CRC_RESIDUE      = 32'hC704DD7B;
localparam CRC_POLYNOMIAL   = 32'h04C11DB7;
localparam CRC_SEED         = 32'hFFFFFFFF;
localparam MAX_SIZE         = 1518;
localparam MIN_SIZE         = 64;

reg [2:0]  state;
reg [2:0]  next_state;
reg [15:0] frame_length_counter;
reg [15:0] data_counter;
reg        too_long;
reg        too_short;

reg        crc_init;
reg        data_enable;
wire [31:0] crc_out;

reg [39:0] data;

// RX State Machine
always @ (posedge clock)
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

always @(posedge clock)
    data_out <= data[39-:8];

always @(posedge clock) 
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

always @ (posedge clock)
    if (reset)
        data_counter <= 0;
    else if (state == STATE_DATA)
        data_counter = data_counter + 1;
    else
        data_counter = 0;

always @ (*)
    if (data_counter > 5 && (state == STATE_DATA || state == STATE_OK || state == STATE_ERROR))
        data_out_enable = 1;
    else
        data_out_enable = 0;

always @(*)
    if (data_counter == 6)
        data_out_start = 1;
    else
        data_out_start = 0;

always @(*)
    if (state == STATE_OK || state == STATE_ERROR)
        data_out_end = 1;
    else
        data_out_end = 0;

always @(*)
    if  (state == STATE_ERROR)
        error = 1;
    else
        error = 0;

// CRC Interface
always @(*)
    if (state == STATE_DATA)
        data_enable = 1;
    else
        data_enable = 0;

always @(*)
    if (state == STATE_PREAMBLE && next_state == STATE_DATA)
        crc_init = 1;
    else
        crc_init = 0;

always @ (posedge clock)
    if (reset)
        frame_length_counter <= 0;
    else if (state == STATE_DATA)
        frame_length_counter = frame_length_counter + 1;
    else
        frame_length_counter = 0;

always @ (*)
    if (frame_length_counter < MIN_SIZE)
        too_short = 1;
    else
        too_short = 0;

always @ (*)
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

endmodule
