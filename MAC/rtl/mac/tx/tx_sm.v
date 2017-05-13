module tx_sm #(
    parameter STATE_DEFER       = 4'h0,
    parameter STATE_IFG         = 4'h1,
    parameter STATE_IDLE        = 4'h2,
    parameter STATE_PREAMBLE    = 4'h3,
    parameter STATE_SFD         = 4'h4,
    parameter STATE_DATA        = 4'h5,
    parameter STATE_PAD         = 4'h6,
    parameter STATE_JAM         = 4'h7,
    parameter STATE_BACKOFF     = 4'h8,
    parameter STATE_FCS         = 4'h9,
    parameter STATE_JAM_DROP    = 4'hA,
    parameter STATE_NEXT        = 4'hB
)(
    input   wire        reset,
    input   wire        clock,
    
    input   wire [7:0]  fifo_data,
    output  reg         fifo_data_read,
    input   wire        fifo_data_start,
    input   wire        fifo_data_end,
    input   wire        fifo_data_available,
    output  reg         fifo_retry,

    input   wire        mode,

    input   wire        carrier_sense,
    input   wire        collision,

    output  reg         tx_enable,
    output  reg  [7:0]  tx_data
);

localparam HALF_DUPLEX      = 0;
localparam FULL_DUPLEX      = 1;
localparam CRC_POLYNOMIAL   = 32'h04C11DB7;
localparam CRC_SEED         = 32'hFFFFFFFF;
localparam MAX_SIZE         = 1518;
localparam MIN_SIZE         = 64;

reg [3:0] state;
reg [3:0] prev_state;
reg [3:0] next_state;
reg [7:0] frame_length_count;
reg [5:0] padding_length_count;
reg [4:0] jam_length_count;
reg [3:0] inter_frame_gap_count;
reg [3:0] preamble_count;
reg [3:0] retry_count;

reg         crc_init;
reg         crc_enable;
wire [31:0] crc_out;
wire [31:0] crc_rev;
integer     crc_index;

reg  random_init;
wire random_trigger;

// State update
always @(posedge clock or posedge reset)
    if (reset)
        state <= STATE_DEFER;
    else
    begin
        prev_state = state;
        state = next_state;    
    end
        
// State Machine
always @ (*)
        case (state)   
            STATE_DEFER:
                if ((mode == FULL_DUPLEX) || (mode == HALF_DUPLEX && !carrier_sense))
                    next_state = STATE_IFG;
                else
                    next_state = STATE_DEFER;
            STATE_IFG:
                if (mode == HALF_DUPLEX && carrier_sense)
                    next_state = STATE_DEFER;
                else if ((mode == FULL_DUPLEX && inter_frame_gap_count == 12 - 4) || (mode == HALF_DUPLEX && !carrier_sense && inter_frame_gap_count == 12 - 4)) // Drop IFG by four to account for state transitions
                    next_state = STATE_IDLE;
                else
                    next_state = STATE_IFG;
            STATE_IDLE:
                if (mode == HALF_DUPLEX && carrier_sense)
                    next_state = STATE_DEFER;       
                else if ((mode == FULL_DUPLEX && fifo_data_available) || (mode == HALF_DUPLEX && !carrier_sense && fifo_data_available))
                    next_state = STATE_PREAMBLE;
                else
                    next_state = STATE_IDLE;
            STATE_PREAMBLE:
                if (mode == HALF_DUPLEX && collision)
                    next_state = STATE_JAM;
                else if ((mode == FULL_DUPLEX && preamble_count == 7) || (mode == HALF_DUPLEX && !collision && preamble_count == 7))
                    next_state = STATE_SFD;
                else
                    next_state = STATE_PREAMBLE;
            STATE_SFD:
                if (mode == HALF_DUPLEX && collision)
                    next_state = STATE_JAM;
                else 
                    next_state = STATE_DATA;
            STATE_DATA:
                if (mode == HALF_DUPLEX && collision)
                    next_state = STATE_JAM;          
                else if (fifo_data_end && frame_length_count >= 59 )
                    next_state = STATE_FCS;
                else if (fifo_data_end)
                    next_state = STATE_PAD;
                else
                    next_state = STATE_DATA;
            STATE_PAD:
                if (mode == HALF_DUPLEX && collision)
                    next_state = STATE_JAM; 
                else if (frame_length_count >= 59)
                    next_state = STATE_FCS; 
                else
                    next_state = STATE_PAD;
            STATE_JAM:
                if (retry_count <= 2 && jam_length_count == 16) 
                    next_state = STATE_BACKOFF;
                else if (retry_count > 2)
                    next_state = STATE_JAM_DROP;
                else
                    next_state = STATE_JAM;
            STATE_BACKOFF:
                if (random_trigger)
                    next_state = STATE_DEFER;
                else
                    next_state = STATE_BACKOFF;
            STATE_FCS:
                if (mode == HALF_DUPLEX && collision)
                    next_state = STATE_JAM;
                else if (crc_index > 24)
                    next_state = STATE_NEXT;
                else
                    next_state = STATE_FCS;
            STATE_JAM_DROP:
                if (fifo_data_end)
                    next_state = STATE_NEXT;
                else
                    next_state = STATE_JAM_DROP;
            STATE_NEXT:
                next_state = STATE_DEFER;
            default:
                next_state = STATE_DEFER;
        endcase

genvar j;
generate 
    for (j = 31; j >= 0; j = j - 1)
    begin : crc_reverse
        assign crc_rev[31-j] = crc_out[j];
    end
endgenerate

// Counts

// Frame Length
always @(posedge clock or posedge reset)
    if (reset)
        frame_length_count <= 0;
    else if (state == STATE_DEFER)
        frame_length_count <= 0;    
    else if (state == STATE_DATA || state == STATE_PAD)
        frame_length_count <= frame_length_count+1;

// Padding Length
always @(posedge clock or posedge reset)
    if (reset)
        padding_length_count <=0;
    else if (state != STATE_PAD)
        padding_length_count <= 0;
    else
        padding_length_count <= padding_length_count + 1;

// Jam Length
always @ (posedge clock or posedge reset)
    if (reset)
        jam_length_count <= 0;
    else if (state == STATE_JAM || next_state == STATE_JAM)
        jam_length_count <= jam_length_count + 1;
    else
        jam_length_count <= 0;

// Inter-Frame Gap
always @ (posedge clock or posedge reset)
    if (reset)
        inter_frame_gap_count <= 0;
    else if (state != STATE_IFG)
        inter_frame_gap_count <= 0;
    else 
        inter_frame_gap_count <= inter_frame_gap_count + 1;

// Preamble
always @ (posedge clock or posedge reset)
    if (reset)
        preamble_count <= 0;
    else if (state != STATE_PREAMBLE)
        preamble_count <= 0;
    else
        preamble_count <= preamble_count + 1;

// Retry Counter
always @ (posedge clock or posedge reset)
    if (reset)
        retry_count <= 0;
    else if (state == STATE_NEXT)
        retry_count <= 0;
    else if (state == STATE_JAM && next_state == STATE_BACKOFF)
        retry_count <= retry_count + 1;

// State Output Actions

// FIFO
always @ (*)
    if ((state == STATE_DATA ||
         state == STATE_SFD  ||
         state == STATE_JAM_DROP ) && 
         next_state != STATE_FCS)
        fifo_data_read = 1;
    else
        fifo_data_read = 0; 
        
always @ (state)
    if (state == STATE_JAM)        
        fifo_retry = 1;
    else
        fifo_retry = 0;

// Transmit Enable
always @(prev_state)
    if (prev_state == STATE_PREAMBLE ||
        prev_state == STATE_SFD      ||
        prev_state == STATE_DATA     ||
        prev_state == STATE_FCS      ||
        prev_state == STATE_PAD      ||
        prev_state == STATE_JAM      )
        tx_enable <= 1;
    else
        tx_enable <= 0;

reg [7:0] tx_data_tmp;

// Transmit Data
always @(posedge clock)
    case (state)
        STATE_PREAMBLE:
            tx_data_tmp <= 8'h55;
        STATE_SFD:
            tx_data_tmp <= 8'hD5;
        STATE_DATA:
            tx_data_tmp <= fifo_data;
        STATE_PAD:
            tx_data_tmp <= 8'h00; 
        STATE_JAM:
            tx_data_tmp <= 8'h01;
        STATE_FCS:
            $display("CRC: %x", ~crc_rev);
            //tx_data <= ~crc_rev[crc_index+:8];
        default:
            tx_data_tmp <= 8'b00;
    endcase

always @(posedge clock)
    if (prev_state == STATE_FCS)
        tx_data <= ~crc_rev[crc_index+:8];
    else
        tx_data <= tx_data_tmp;

always @(posedge clock)
    if(prev_state == STATE_FCS)
        crc_index <= crc_index + 8;
    else
        crc_index <= 0;

// CRC
always @(state)
    if (state == STATE_SFD)
        crc_init = 1;
    else
        crc_init = 0;

reg crc_enable_tmp;

always @(state)
    if (state == STATE_DATA || state == STATE_PAD)
        crc_enable_tmp = 1;
    else
        crc_enable_tmp = 0;
        
always @ (posedge clock)
    crc_enable <= crc_enable_tmp;

// Random Calculation for Backoff
always @(state or next_state)
    if (state == STATE_JAM && next_state == STATE_BACKOFF)
        random_init = 1;
    else
        random_init = 0; 

// Submodule Initialisation

// CRC
crc #(  .POLYNOMIAL(CRC_POLYNOMIAL),
        .DATA_WIDTH(8),
        .CRC_WIDTH(32),
        .SEED(CRC_SEED)) 
U_crc(
    .reset(reset),
    .clock(clock),
    .init(crc_init),
    .data(tx_data_tmp),
    .data_enable(crc_enable),
    .crc_out(crc_out)
);

random_gen U_random_gen(
    .reset(reset),
    .clock(clock),
    .init(random_init),
    .retry_count(retry_count),
    .trigger(random_trigger)
);

endmodule
