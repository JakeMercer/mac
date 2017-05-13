`timescale 1ns / 1ps

module crc_tb #(   
    parameter CRC_WIDTH     = 32,
    parameter DATA_WIDTH    = 8,
    parameter POLYNOMIAL    = 32'h04C11DB7,
    parameter SEED          = 32'hFFFFFFFF
)();

`include "dut.v"

reg  [7:0]  packet [0:95];   
integer i;
integer j;
reg [7:0]   temp;

initial
begin
    #15 reset = 0;

    $readmemh("packet.hex", packet);

    for(i = 0; i < 96; i = i + 1)
    begin
        util.sync_write(packet[i]);
    end

    util.sync_read(tempdata);
   
    util.assert(tempdata == 32'hc704dd7b, "CRC == 0xc704dd7b");

    $finish;
end

endmodule

