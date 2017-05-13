`timescale 1ns / 1ps

module crc_tb #(   
    parameter CRC_WIDTH     = 5,
    parameter DATA_WIDTH    = 8,
    parameter POLYNOMIAL    = 5'b00101,
    parameter SEED          = 0
)();

`include "dut.v"

initial
begin
    #15 reset = 0;

    util.sync_write(8'hAA);
    util.sync_read(tempdata);
    util.assert(tempdata == 5'b11000, 1);
    util.sync_write(8'hAA);
    util.sync_read(tempdata);    
    util.assert(tempdata == 5'b10001, 2);

    $finish;
end

endmodule

