`timescale 1ns / 1ps

module rx_sm_tb ();

`include "dut.v"

integer i;
integer j;

reg  [7:0]  packet [0:1518];   
reg  [7:0]  tempdata;
reg         tempstart;
reg         tempend;

initial
begin
    $dumpfile("test.vcd");
    $dumpvars(0,rx_sm_tb,U_rx_sm);
end

initial
begin
    #15 reset = 0;

    $readmemh("packet.hex", packet);

    util.assert(data_available == 0, "Data available not set");

    // Send a packet
    for(i = 0; i < 104; i = i + 1)
    begin
        data.sync_write(packet[i]);
    end
 
    #1000

    util.assert(data_available == 1, "Data available set");

    // Read the packet out
    fork
        data_out.sync_read(tempdata);
        data_out_start.sync_read(tempstart);
        data_out_end.sync_read(tempend);        
    join

    util.assert(tempdata == packet[8], "Reading FIFO Data");
    util.assert(tempstart == 1, "Reading FIFO Start");
    util.assert(tempend == 0, "Reading FIFO End");

    for ( i = 9; i < 99; i = i + 1)
    begin
        fork
            data_out.sync_read(tempdata);
            data_out_start.sync_read(tempstart);
            data_out_end.sync_read(tempend);        
        join
        util.assert(tempdata == packet[i], "Reading FIFO Data");
        util.assert(tempstart == 0, "Reading FIFO Start");
        util.assert(tempend == 0, "Reading FIFO End");
    end

    fork
        data_out.sync_read(tempdata);
        data_out_start.sync_read(tempstart);
        data_out_end.sync_read(tempend);        
    join

    util.assert(tempdata == packet[99], "Reading FIFO Data");
    util.assert(tempstart == 0, "Reading FIFO Start");
    util.assert(tempend == 1, "Reading FIFO End");

    util.assert(data_available == 0, "Data available not set");

    /*
    // Send a packet
    for(i = 0; i < 104; i = i + 1)
    begin
        data.sync_write(packet[i]);
    end
 
    #1000
    
    util.assert(data_available == 1, "Data available set");

    // Read the packet out
    fork
        data_out.sync_read(tempdata);
        data_out_start.sync_read(tempstart);
        data_out_end.sync_read(tempend);        
    join

    util.assert(tempdata == packet[8], "Reading FIFO Data");
    util.assert(tempstart == 1, "Reading FIFO Start");
    util.assert(tempend == 0, "Reading FIFO End");

    for ( i = 9; i < 99; i = i + 1)
    begin
        fork
            data_out.sync_read(tempdata);
            data_out_start.sync_read(tempstart);
            data_out_end.sync_read(tempend);        
        join
        util.assert(tempdata == packet[i], "Reading FIFO Data");
        util.assert(tempstart == 0, "Reading FIFO Start");
        util.assert(tempend == 0, "Reading FIFO End");
    end

    fork
        data_out.sync_read(tempdata);
        data_out_start.sync_read(tempstart);
        data_out_end.sync_read(tempend);        
    join

    util.assert(tempdata == packet[99], "Reading FIFO Data");
    util.assert(tempstart == 0, "Reading FIFO Start");
    util.assert(tempend == 1, "Reading FIFO End");

    util.assert(data_available == 0, "Data available not set");

    // Send a packet with error
    for(i = 0; i < 103; i = i + 1)
    begin
        data.sync_write(packet[i]);
    end
 
    data.sync_write(8'hFF);

    #1000
    
    util.assert(data_available == 0, "Data available not set");

    // Send a packet
    for(i = 0; i < 104; i = i + 1)
    begin
        data.sync_write(packet[i]);
    end
 
    #1000
    
    util.assert(data_available == 1, "Data available set");

    // Send a packet
    for(i = 0; i < 104; i = i + 1)
    begin
        data.sync_write(packet[i]);
    end
 
    #1000
    
    util.assert(data_available == 1, "Data available set");

    // Read the packets out
    fork
        data_out.sync_read(tempdata);
        data_out_start.sync_read(tempstart);
        data_out_end.sync_read(tempend);        
    join

    util.assert(tempdata == packet[8], "Reading FIFO Data");
    util.assert(tempstart == 1, "Reading FIFO Start");
    util.assert(tempend == 0, "Reading FIFO End");

    for ( i = 9; i < 99; i = i + 1)
    begin
        fork
            data_out.sync_read(tempdata);
            data_out_start.sync_read(tempstart);
            data_out_end.sync_read(tempend);        
        join
        util.assert(tempdata == packet[i], "Reading FIFO Data");
        util.assert(tempstart == 0, "Reading FIFO Start");
        util.assert(tempend == 0, "Reading FIFO End");
    end

    fork
        data_out.sync_read(tempdata);
        data_out_start.sync_read(tempstart);
        data_out_end.sync_read(tempend);        
    join

    util.assert(tempdata == packet[99], "Reading FIFO Data");
    util.assert(tempstart == 0, "Reading FIFO Start");
    util.assert(tempend == 1, "Reading FIFO End");

    util.assert(data_available == 1, "Data available set");

    // Read the packets out
    fork
        data_out.sync_read(tempdata);
        data_out_start.sync_read(tempstart);
        data_out_end.sync_read(tempend);        
    join

    util.assert(tempdata == packet[8], "Reading FIFO Data");
    util.assert(tempstart == 1, "Reading FIFO Start");
    util.assert(tempend == 0, "Reading FIFO End");

    for ( i = 9; i < 99; i = i + 1)
    begin
        fork
            data_out.sync_read(tempdata);
            data_out_start.sync_read(tempstart);
            data_out_end.sync_read(tempend);        
        join
        util.assert(tempdata == packet[i], "Reading FIFO Data");
        util.assert(tempstart == 0, "Reading FIFO Start");
        util.assert(tempend == 0, "Reading FIFO End");
    end

    fork
        data_out.sync_read(tempdata);
        data_out_start.sync_read(tempstart);
        data_out_end.sync_read(tempend);        
    join

    util.assert(tempdata == packet[99], "Reading FIFO Data");
    util.assert(tempstart == 0, "Reading FIFO Start");
    util.assert(tempend == 1, "Reading FIFO End");

    util.assert(data_available == 0, "Data available not set");

    // Send lots of packets to fill the FIFO
    for(j = 0; j <= 11; j = j + 1)
    begin
        #1000 for(i = 0; i < 104; i = i + 1)
        begin
            data.sync_write(packet[i]);
        end
    end

    for(j = 0; j <= 10; j = j + 1)
    begin
        util.assert(data_available == 1, "Data available set");
        // Read the packets out
        fork
            data_out.sync_read(tempdata);
            data_out_start.sync_read(tempstart);
            data_out_end.sync_read(tempend);        
        join

        util.assert(tempdata == packet[8], "Reading FIFO Data");
        util.assert(tempstart == 1, "Reading FIFO Start");
        util.assert(tempend == 0, "Reading FIFO End");

        for ( i = 9; i < 99; i = i + 1)
        begin
            fork
                data_out.sync_read(tempdata);
                data_out_start.sync_read(tempstart);
                data_out_end.sync_read(tempend);        
            join
            util.assert(tempdata == packet[i], "Reading FIFO Data");
            util.assert(tempstart == 0, "Reading FIFO Start");
            util.assert(tempend == 0, "Reading FIFO End");
        end

        fork
            data_out.sync_read(tempdata);
            data_out_start.sync_read(tempstart);
            data_out_end.sync_read(tempend);        
        join

        util.assert(tempdata == packet[99], "Reading FIFO Data");
        util.assert(tempstart == 0, "Reading FIFO Start");
        util.assert(tempend == 1, "Reading FIFO End");
    end

    util.assert(data_available == 0, "Data available not set");
*/
    util.display();

    $finish;
end

endmodule

