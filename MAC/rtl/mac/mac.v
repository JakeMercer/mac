module mac(
    input   wire        reset,

    // IN PORT
    input   wire [31:0] data_in,
    input   wire        data_in_clock,     
    input   wire        data_in_enable,
    input   wire        data_in_start,
    input   wire        data_in_end,

    // OUT PORT
    output  wire [31:0] data_out,
    input   wire        data_out_clock,     
    input   wire        data_out_enable,
    output  wire        data_out_start,
    output  wire        data_out_end,
    output  wire [6:0]  frame_count,

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

    wire [7:0]  tx_fifo_data;
    wire        tx_fifo_data_read;
    wire        tx_fifo_data_start;
    wire        tx_fifo_data_end;
    wire [6:0]  tx_fifo_count;
    wire        tx_fifo_retry;

    wire [7:0]  rx_fifo_data;
    wire        rx_fifo_data_write;
    wire        rx_fifo_data_start;
    wire        rx_fifo_data_end;
    wire        rx_fifo_full;
    wire        rx_fifo_error;

tx_sm U_tx_sm(
    .reset(reset),
    .clock(tx_clock),
    
    .fifo_data(tx_fifo_data),
    .fifo_data_read(tx_fifo_data_read),
    .fifo_data_start(tx_fifo_data_start),
    .fifo_data_end(tx_fifo_data_end),
    .fifo_count(tx_fifo_count),
    .fifo_retry(tx_fifo_retry),

    .mode(1'b1),

    .carrier_sense(carrier_sense),
    .collision(collision),

    .tx_enable(tx_enable),
    .tx_data(tx_data)
);

mac_fifo #(
    .DATA_IN_WIDTH(32),
    .DATA_OUT_WIDTH(8),
    .FIFO_DEPTH(12)
) U_mac_fifo_tx (
    .reset(reset),    
    
    .data_in(data_in),
    .data_in_clock(data_in_clock),     
    .data_in_enable(data_in_enable),
    .data_in_start(data_in_start),
    .data_in_end(data_in_end),
    
    .data_out(tx_fifo_data),
    .data_out_clock(tx_clock),     
    .data_out_enable(tx_fifo_data_read),
    .data_out_start(tx_fifo_data_start),
    .data_out_end(tx_fifo_data_end),

    .retry(tx_fifo_retry),
    .error(1'b0),
    .frame_count(tx_fifo_count)
);

rx_sm U_rx_sm(
    .reset(reset),
    .clock(rx_clock),
    
    .fifo_data(rx_fifo_data),
    .fifo_data_write(rx_fifo_data_write),
    .fifo_data_start(rx_fifo_data_start),
    .fifo_data_end(rx_fifo_data_end),
    .fifo_full(rx_fifo_full),
    .fifo_error(rx_fifo_error),

    .rx_data_valid(rx_data_valid),
    .rx_error(rx_error),

    .rx_data(rx_data)
);

mac_fifo #(
    .DATA_IN_WIDTH(8),
    .DATA_OUT_WIDTH(32),
    .FIFO_DEPTH(12)
) U_mac_fifo_rx (
    .reset(reset),    
    
    .data_in(rx_fifo_data),
    .data_in_clock(rx_clock),     
    .data_in_enable(rx_fifo_data_write),
    .data_in_start(rx_fifo_data_start),
    .data_in_end(rx_fifo_data_end),
    
    .data_out(data_out),
    .data_out_clock(data_out_clock),     
    .data_out_enable(data_out_enable),
    .data_out_start(data_out_start),
    .data_out_end(data_out_end),

    .retry(1'b0),
    .error(rx_fifo_error),
    .frame_count(frame_count)
);

endmodule
