module station_management 
#(
    parameter STATE_IDLE            = 4'd0,
    parameter STATE_PREAMBLE        = 4'd1,
    parameter STATE_START_OF_FRAME  = 4'd2,
    parameter STATE_OPCODE          = 4'd3,
    parameter STATE_PHY_ADDRESS     = 4'd4,
    parameter STATE_REG_ADDRESS     = 4'd5,
    parameter STATE_TURNAROUND      = 4'd6,
    parameter STATE_DATA            = 4'd7,
    parameter STATE_OK              = 4'd8,    
    parameter READ                  = 1'b0,
    parameter WRITE                 = 1'b1
)(
    input   wire reset,
    input   wire clock,
    
    output  wire mdc,
    inout   wire mdio,
    
    input   wire mode,

    input   wire begin_transaction,
    input   wire [4:0] phy_address,
    input   wire [4:0] reg_address,
    input   wire [15:0] data_in,
    output  reg  [15:0] data_out
);

localparam start_of_frame   = 2'b01;
localparam turnaround       = 2'b10;

reg [3:0] state;
reg [3:0] next_state;

reg mdio_data;
reg writing;

reg [1:0] opcode;
reg [15:0] data_read;

reg [4:0] preamble_counter;
reg       start_of_frame_counter;
reg       opcode_counter;
reg [2:0] phy_address_counter;
reg [2:0] reg_address_counter;
reg       turnaround_counter;
reg [3:0] data_counter;

// MDC
assign mdc = clock;

// MDIO - if reading present high impedance.
assign mdio = (writing) ? mdio_data : 1'bz;

// State Update
always @(posedge mdc)
    if (reset)
        state <= STATE_IDLE;
    else
        state <= next_state;

// State Machine
always @(*)
    case(state)
        STATE_IDLE:
            if ( begin_transaction )
                next_state <= STATE_PREAMBLE;
            else
                next_state <= STATE_IDLE;
        STATE_PREAMBLE:
            if (preamble_counter == 5'b0)
                next_state <= STATE_START_OF_FRAME;
            else
                next_state <= STATE_PREAMBLE;
        STATE_START_OF_FRAME:
            if (start_of_frame_counter == 0)
                next_state <= STATE_OPCODE;
            else
                next_state <= STATE_START_OF_FRAME;
        STATE_OPCODE:
            if (opcode_counter == 0)
                next_state <= STATE_PHY_ADDRESS;
            else
                next_state <= STATE_OPCODE;
        STATE_PHY_ADDRESS:
            if (phy_address_counter == 0)
                next_state <= STATE_REG_ADDRESS;
            else
                next_state <= STATE_PHY_ADDRESS;
        STATE_REG_ADDRESS:
            if (reg_address_counter == 0)
                next_state <= STATE_TURNAROUND;
            else
                next_state <= STATE_REG_ADDRESS;
        STATE_TURNAROUND:
            if (turnaround_counter == 0)
                next_state <= STATE_DATA;
            else
                next_state <= STATE_TURNAROUND;
        STATE_DATA:
            if (data_counter == 0)
                next_state <= STATE_OK;
            else
                next_state <= STATE_DATA;
        STATE_OK:
            next_state <= STATE_IDLE;
        default:
            next_state <= STATE_IDLE;
    endcase

// State Outputs
always @(*)
    case(state)
        STATE_IDLE:
            mdio_data <= 0;
        STATE_PREAMBLE:
            mdio_data <= 1;
        STATE_START_OF_FRAME:
            mdio_data <= start_of_frame[start_of_frame_counter-:1];
        STATE_OPCODE:
            mdio_data <= opcode[opcode_counter-:1];
        STATE_PHY_ADDRESS:
            mdio_data <= phy_address[phy_address_counter-:1];
        STATE_REG_ADDRESS:
            mdio_data <= reg_address[reg_address_counter-:1];
        STATE_TURNAROUND:
            mdio_data <= turnaround[turnaround_counter-:1];
        STATE_DATA:
            mdio_data <= data_in[data_counter-:1];
        default:
            mdio_data <= 0;
    endcase

always @(posedge mdc)
    if (state == STATE_DATA && mode == READ)
        data_read[data_counter-:1] <= mdio;

always @(*)
    if (state == STATE_OK)
    begin
        data_out <= data_read;
    end

always @(*)
    if ((state == STATE_TURNAROUND && mode == READ) ||
        (state == STATE_DATA       && mode == READ))
        writing <= 0;
    else
        writing <= 1;

always @(*)
    if (mode == READ)
        opcode <= 2'b10;
    else
        opcode <= 2'b01;

// Counters

// Preamble
always @(posedge mdc)
    if (reset)
        preamble_counter <= 5'd31;
    else if (state == STATE_PREAMBLE)
        preamble_counter <= preamble_counter - 1;
    else
        preamble_counter <= 5'd31;

// Start of Frame
always @(posedge mdc)
    if (reset)
        start_of_frame_counter <= 1'b1;
    else if (state == STATE_START_OF_FRAME)
        start_of_frame_counter <= 1'b0;
    else
        start_of_frame_counter <= 1'b1;

// Opcode
always @(posedge mdc)
    if (reset)
        opcode_counter <= 1'b1;
    else if (state == STATE_OPCODE)
        opcode_counter <= 1'b0;
    else
        opcode_counter <= 1'b1;

// PHY Address
always @(posedge mdc)
    if (reset)
        phy_address_counter <= 3'd4;
    else if (state == STATE_PHY_ADDRESS)
        phy_address_counter <= phy_address_counter - 1;
    else
        phy_address_counter <= 3'd4;

// Register Address
always @(posedge mdc)
    if (reset)
        reg_address_counter <= 3'd4;
    else if (state == STATE_REG_ADDRESS)
        reg_address_counter <= reg_address_counter - 1;
    else
        reg_address_counter <= 3'd4;

// Turnaround
always @(posedge mdc)
    if (reset)
        turnaround_counter <= 1'b1;
    else if (state == STATE_TURNAROUND)
        turnaround_counter <= 1'b0;
    else
        turnaround_counter <= 1'b1;

// Data
always @(posedge mdc)
    if (reset)
        data_counter <= 4'd15;
    else if (state == STATE_DATA)
        data_counter <= data_counter - 1;
    else
        data_counter <= 4'd15;

endmodule
