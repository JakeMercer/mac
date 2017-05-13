`timescale 1ns / 1ps

module crc_tb #(   
    parameter CRC_WIDTH     = 32,
    parameter DATA_WIDTH    = 8,
    parameter POLYNOMIAL    = 32'h04C11DB7,
    parameter SEED          = 32'hFFFFFFFF
)();

`include "dut.v"

reg  [7:0]  packet [0:91];   
integer i;
integer j;
reg [7:0]   temp;
reg [31:0]   temp2;
reg [31:0]   temp3;

initial
begin
    #15 reset = 0;

    $readmemh("packet.hex", packet);

    for(i = 0; i < 92; i = i + 1)
    begin
        util.sync_write(packet[i]);
    end

    util.sync_read(tempdata);
  
    for (j = 31; j >= 0; j = j - 1)
    begin
        temp2[31-j]  = tempdata[j];
    end

    $display("Normal: %x",tempdata);
    $display("Reversed: %x",temp2);
    $display("Reversed & Inverted: %x",~temp2);

    tempdata = ~tempdata;
    $display("Inverted: %x",tempdata);

    for (j = 4; j > 0; j = j - 1)
    begin
        temp3[(j*8)-1-:8]  = ~temp2[((4-j)*8)+:8];
    end

    $display("Reversed & Inverted & Byte Re-order: %x",temp3);

    util.assert(temp3 == 32'hc0f447ca, "CRC == 0xc0f447ca");

    $finish;
end

endmodule

