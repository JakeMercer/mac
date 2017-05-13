`timescale 1ns / 1ps

module crc #(
    parameter POLYNOMIAL    = 5'b00101,
    parameter DATA_WIDTH    = 8,
    parameter CRC_WIDTH     = 5,
    parameter SEED          = 0,
    parameter DEBUG         = 0,
    parameter REVERSE       = 1
)(
    input [DATA_WIDTH-1:0]      data,
    input                       data_enable,
    output reg [CRC_WIDTH-1:0]  crc_out, 
    input                       init,
    input                       clock,
    input                       reset
);

function automatic prev;
    input integer level;
    input integer index;
    input [DATA_WIDTH-1:0]  data;
    input [CRC_WIDTH-1:0]   crc;
    begin
        if (POLYNOMIAL[index])
        begin
            if (level)
            begin
                if (index)
                begin
                    if (DEBUG)
                        $display("LEVEL %0d | crc[%0d] = crc[%0d] ^ crc[%0d] ^ data[%0d]", level, index, (index)?index-1:CRC_WIDTH-1, CRC_WIDTH-1, DATA_WIDTH - 1 - level);                                
                    prev = prev(level-1, (index)?index-1:CRC_WIDTH-1, data, crc) ^ prev(level-1, CRC_WIDTH-1, data, crc) ^ data[DATA_WIDTH-1-level];
                end
                else
                begin
                    if (DEBUG)
                        $display("LEVEL %0d | crc[%0d] = crc[%0d] ^ data[%0d]", level, index, CRC_WIDTH-1, DATA_WIDTH - 1 - level);                                
                    prev = prev(level-1, CRC_WIDTH-1, data, crc) ^ data[DATA_WIDTH-1-level];
                end

            end
            else
            begin
                if (index)
                begin
                    if (DEBUG)
                        $display("LEVEL %0d | crc[%0d] = crc[%0d] ^ crc[%0d] ^ data[%0d] // STOP", level, index, index-1, CRC_WIDTH-1, DATA_WIDTH - 1 - level);                                                
                    prev = crc[index-1-:1] ^ crc[CRC_WIDTH-1-:1] ^ data[DATA_WIDTH-1-level];
                end
                else
                begin
                    if (DEBUG)
                        $display("LEVEL %0d | crc[%0d] = crc[%0d] ^ data[%0d] // STOP", level, index, CRC_WIDTH-1, DATA_WIDTH - 1 - level);                                                
                    prev = crc[CRC_WIDTH-1-:1] ^ data[DATA_WIDTH-1-level];
                end
            end
        end
        else
        begin
            if (level)
            begin
                if (index)
                begin
                    if (DEBUG)
                        $display("LEVEL %0d | crc[%0d] = crc[%0d]", level, index, index - 1);                                                                
                    prev = prev(level-1, index-1, data, crc);
                end
                else
                begin
                    if (DEBUG)
                        $display("LEVEL %0d | crc[%0d] = crc[%0d] ^ data[%0d]", level, index, CRC_WIDTH-1, DATA_WIDTH - 1 - level);                                                                
                    prev = prev(level-1, CRC_WIDTH-1, data, crc) ^ data[DATA_WIDTH-1-level];
                end
            end
            else
            begin
                if (index)
                begin
                    if (DEBUG)
                        $display("LEVEL %0d | crc[%0d] = crc[%0d] // STOP", level, index, index - 1);                                                                                
                    prev = crc[index-1-:1];
                end
                else
                begin
                    if (DEBUG)
                        $display("LEVEL %0d | crc[%0d] = crc[%0d] ^ data[%0d] // STOP", level, index, CRC_WIDTH-1, DATA_WIDTH - 1 - level);                                                                                
                    prev = crc[CRC_WIDTH-1-:1] ^ data[DATA_WIDTH-1-level];
                end
            end
        end
    end
endfunction

wire [DATA_WIDTH-1:0] temp;

genvar j;
generate
if (REVERSE)
begin
    for (j = DATA_WIDTH-1; j >= 0; j = j - 1)
    begin : reverse_loop
        assign temp[DATA_WIDTH-1-j]  = data[j];
    end
end
else
begin
    assign temp = data;
end
endgenerate

genvar i;
generate
for(i = 0; i < CRC_WIDTH; i= i + 1)
begin : loop
    always @(posedge clock)
    begin
        if (reset)
        begin
            crc_out[i+:1] = SEED[i+:1];
        end
        else if (init)
        begin
            crc_out[i+:1] = SEED[i+:1];
        end
        else if (data_enable)
        begin
            if (DEBUG)
                $display("\n\nCRC OUT[%0d]\n***************************************************************************", i); 
            crc_out[i+:1] <= prev(DATA_WIDTH-1,i,temp,crc_out);
        end
    end
end
endgenerate

endmodule


