`timescale 1ns / 1ps

module crc_tb #(   
    parameter CRC_WIDTH     = 32,
    parameter DATA_WIDTH    = 8,
    parameter POLYNOMIAL    = 32'h04C11DB7,
    parameter SEED          = 32'h00000000
)();

`include "dut.v"

initial
begin
    #15 reset = 0;

    util.sync_write(8'hAA);
    util.sync_read(tempdata);
    util.assert(tempdata == 32'hdea580d8, "CRC == 0xdea580d8");
    util.sync_write(8'hAA);
    util.sync_read(tempdata);    
    util.assert(tempdata == 32'h5630b33b, "CRC == 0x5630b33b");

    $finish;
end

endmodule

