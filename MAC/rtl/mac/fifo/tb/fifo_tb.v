`timescale 1ns / 1ps

module fifo_test();

parameter WIDTH = 8;
parameter DEPTH = 12;

`include "dut.v"

integer i;
reg [WIDTH-1:0] tempdata;
reg tempstart;
reg tempend;

initial
begin
    #15 reset = 0;

    fork
        data_in.sync_write(8'hAA);
        data_in_start.sync_write(1);
    join

    for ( i = 1; i < 100; i = i + 1)
    begin
        data_in.sync_write(i);
    end

    fork
        data_in.sync_write(8'hAB);
        data_in_end.sync_write(1);
    join

    fork
        data_out.sync_read(tempdata);
        data_out_start.sync_read(tempstart);
        data_out_end.sync_read(tempend);        
    join

    util.assert(tempdata == 8'hAA, "Reading FIFO Data");
    util.assert(tempstart == 1, "Reading FIFO Start");
    util.assert(tempend == 0, "Reading FIFO End");

    for ( i = 1; i < 100; i = i + 1)
    begin
        fork
            data_out.sync_read(tempdata);
            data_out_start.sync_read(tempstart);
            data_out_end.sync_read(tempend);        
        join
        util.assert(tempdata == i, "Reading FIFO Data");
        util.assert(tempstart == 0, "Reading FIFO Start");
        util.assert(tempend == 0, "Reading FIFO End");
    end

    fork
        data_out.sync_read(tempdata);
        data_out_start.sync_read(tempstart);
        data_out_end.sync_read(tempend);        
    join

    util.assert(tempdata == 8'hAB, "Reading FIFO Data");
    util.assert(tempstart == 0, "Reading FIFO Start");
    util.assert(tempend == 1, "Reading FIFO End");

    $finish;
end

endmodule
