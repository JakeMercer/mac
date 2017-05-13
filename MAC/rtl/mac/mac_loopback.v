module mac_loopback(
    input   wire        reset,

    input   wire        tx_clock,
    input   wire        rx_clock,

    input   wire        carrier_sense,
    input   wire        collision,

    output  wire        tx_enable,
    output  wire [7:0]  tx_data,

    input   wire        rx_data_valid,       
    input   wire [7:0]  rx_data,         
    input   wire        rx_error
);

wire [7:0]  data_out;
wire        data_out_start;
wire        data_out_end;
reg         data_out_clock;
wire        data_out_enable;
wire        data_available;

tx_sm U_tx_sm(
    .reset(reset),
    .clock(tx_clock),
    
    .fifo_data(data_out),
    .fifo_data_read(data_out_enable),
    .fifo_data_start(data_out_start),
    .fifo_data_end(data_out_end),
    .fifo_data_available(data_available),

    .mode(1'b1),

    .carrier_sense(carrier_sense),
    .collision(collision),

    .tx_enable(tx_enable),
    .tx_data(tx_data)
);

rx_sm #(.FIFO_DEPTH(10)) U_rx_sm(
    .reset(reset),
    .clock(rx_clock),
   
    .data_out(data_out),
    .data_out_clock(tx_clock),     
    .data_out_enable(data_out_enable),
    .data_out_start(data_out_start),
    .data_out_end(data_out_end),
    .data_available(data_available),

    .rx_data_valid(rx_data_valid),
    .rx_data(rx_data),
    .rx_error(rx_error)
);
endmodule
