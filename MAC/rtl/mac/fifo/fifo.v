`timescale 1ns / 1ps

module fifo 
#(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 12
)
( 
    input   wire                            reset,    
    output  reg     [FIFO_DEPTH:0]          count,
    output  reg                             full,

    // IN PORT
    input   wire    [DATA_WIDTH-1:0]        data_in,
    input   wire                            data_in_clock,     
    input   wire                            data_in_enable,
    input   wire                            data_in_start,
    input   wire                            data_in_end,
    output  reg     [FIFO_DEPTH-1:0]        data_in_address,
    input   wire                            data_in_reset,
    input   wire    [FIFO_DEPTH-1:0]        data_in_reset_address,

    // OUT PORT
    output  reg     [DATA_WIDTH-1:0]        data_out,
    input   wire                            data_out_clock,     
    input   wire                            data_out_enable,
    output  reg                             data_out_start,
    output  reg                             data_out_end,
    output  reg     [FIFO_DEPTH-1:0]        data_out_address,
    input   wire                            data_out_reset,
    input   wire    [FIFO_DEPTH-1:0]        data_out_reset_address
);

reg     [DATA_WIDTH + 1:0] mem[(2**FIFO_DEPTH) - 1:0]; // 2 bits added to data to facilitate start and stop bits.

always @(posedge data_in_clock)
begin
    if ( count && (data_in_address == data_out_address - 1 ))
    begin
        full <= 1;
    end
    else
    begin
        full <= 0;
    end
end

always @(posedge data_in_clock)
begin
    if( data_in_enable )
    begin
        if ( data_out_address != data_in_address || (data_out_address == data_in_address && !count))
            mem[ data_in_address ]<= { data_in, data_in_start, data_in_end };
    end
end

always @(posedge data_in_clock or posedge reset)
begin
    if( reset )
    begin
        data_in_address <= 0;
        count <= 0;
    end
    else if (data_in_reset)
    begin
        count = count - (data_in_address - data_in_reset_address);
        data_in_address = data_in_reset_address;
    end
    else
    begin
        if( data_in_enable )
        begin
            count <= count + 1;            
            data_in_address <= data_in_address + 1;
        end
    end
end

always @(posedge data_out_clock or posedge reset)
begin
    if (reset)
    begin
        data_out <= 0;
        data_out_address <= 0;
    end
    else if (data_out_reset)
    begin
        data_out_address <= data_out_reset_address;
    end
    else if (data_out_enable)
    begin
        { data_out, data_out_start, data_out_end } <= mem[data_out_address];
        data_out_address <= data_out_address + 1;  
        count <= count - 1;
    end
end

endmodule
