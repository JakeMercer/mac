`timescale 1ns / 1ps

module fifo 
#(
    parameter DATA_IN_WIDTH = 8,
    parameter DATA_OUT_WIDTH = 8,    
    parameter FIFO_DEPTH = 12
)
( 
    input   wire                            reset,    
    output  reg                             count,

    // IN PORT
    input   wire    [DATA_IN_WIDTH-1:0]     data_in,
    input   wire                            data_in_clock,     
    input   wire                            data_in_enable,
    output  reg     [FIFO_DEPTH-1:0]        data_in_address,
    input   wire                            data_in_reset,
    input   wire    [FIFO_DEPTH-1:0]        data_in_reset_address,

    // OUT PORT
    output  reg     [DATA_OUT_WIDTH-1:0]    data_out,
    input   wire                            data_out_clock,     
    input   wire                            data_out_enable,
    output  reg     [FIFO_DEPTH-1:0]        data_out_address,
    input   wire                            data_out_reset,
    input   wire    [FIFO_DEPTH-1:0]        data_out_reset_address
);

integer                     index;

generate
    if (DATA_IN_WIDTH > DATA_OUT_WIDTH && DATA_IN_WIDTH % DATA_OUT_WIDTH != 0)
    begin
        initial
        begin
            $display("ERROR: invalid width.");
        end
    end
    else if (DATA_OUT_WIDTH > DATA_IN_WIDTH && DATA_OUT_WIDTH % DATA_IN_WIDTH != 0)
    begin
        initial
        begin
            $display("ERROR: invalid width.");
        end
    end
    else if (DATA_OUT_WIDTH > DATA_IN_WIDTH)
    begin
        initial
        begin
            $display("OUT > IN");
        end

        reg     [DATA_OUT_WIDTH-1:0] mem[(2**FIFO_DEPTH)-1:0];

        always @(posedge data_in_clock)
        begin
            if( data_in_enable )
            begin
                mem[ data_in_address ][index-:DATA_IN_WIDTH]<= data_in;
            end
        end

        always @(posedge data_in_clock or posedge reset)
        begin
            if( reset )
            begin
                data_in_address <= 0;
                count <= 0;
                index <= DATA_OUT_WIDTH - 1;
            end
            else if (data_in_reset)
            begin
                data_in_address <= data_in_reset_address;
                index <= DATA_OUT_WIDTH - 1;                
            end
            else
            begin
                if( data_in_enable )
                begin
                    count <= count + 1;            
                    index <= index - DATA_IN_WIDTH;
                    if (index <= DATA_IN_WIDTH)
                    begin
                        data_in_address <= data_in_address + 1;
                        index <= DATA_OUT_WIDTH - 1;                
                    end
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
                data_out <= mem[data_out_address];
                data_out_address <= data_out_address + 1;        
            end
        end
    end
    else
    begin
        initial
        begin
            $display("OUT <= IN");
        end

        reg     [DATA_IN_WIDTH-1:0] mem[(2**FIFO_DEPTH)-1:0];

        always @(posedge data_in_clock)
        begin
            if( data_in_enable )
            begin
                mem[ data_in_address ] <= data_in;
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
                data_in_address <= data_in_reset_address;
            end
            else
            begin
                if( data_in_enable )
                begin
                    data_in_address <= data_in_address + 1;
                    count <= count + 1;
                end
            end
        end

        always @(posedge data_out_clock or posedge reset)
        begin
            if (reset)
            begin
                data_out <= 0;
                data_out_address <= 0;
                index <= DATA_IN_WIDTH - 1;
            end
            else if (data_out_reset)
            begin
                data_out_address <= data_out_reset_address;
                index <= DATA_IN_WIDTH - 1;                
            end
            else if (data_out_enable)
            begin
                data_out <= mem[data_out_address][index-:DATA_OUT_WIDTH];
                index <= index - DATA_OUT_WIDTH;
                if (index <= DATA_OUT_WIDTH)
                begin
                    index <= DATA_IN_WIDTH - 1;
                    data_out_address <= data_out_address + 1;
                end
            end
        end
    end
endgenerate

endmodule
