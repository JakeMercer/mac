`timescale 1ns / 1ps

module tx_sm_tb ();

`include "dut.v"

integer i;

initial
begin
    //$dumpfile("test.vcd");
    //$dumpvars(0,tx_sm_tb,U_tx_sm);
end

initial
begin
    #15 reset = 0;

    // Will initially wait IFG before making any transmissions
    // Set fifo_count to 1 and check IFG delay before tx_enable is asserted
    // Clock flips every 5ns -> 10ns period
    // tx_enable_monitor will take care of these checks
   
    fifo_count = 1;

    #110 
        
    expected_tx_enable = 1;

    // MAC should then start transmitting the preamble
    // 7 bytes
    for (i = 0; i < 7; i = i + 1)
    begin
        data.sync_read(tempdata);
        data.assert(tempdata  == 8'h55, "Preamble");
        expected_tx_enable = 1;
    end

    // Followed by the SFD
    // 1 byte
    data.sync_read(tempdata);
    data.assert(tempdata  == 8'hD5, "SFD");

    // Followed by the frame data we supply
    // 10 Bytes
    fork
        // Data Start
        data.sync_write(8'h00);
        data_start.sync_write(1);
    join
        data.assert(tx_data == 0, "DATA START");        

    for (i = 1; i < 9; i = i + 1)
    begin
        data.sync_write(i);
        data.assert(tx_data == i, "DATA");
    end

    fork
        // Data End
        data.sync_write(8'h09);
        data_end.sync_write(1);
    join
        data.assert(tx_data == 8'h09, "DATA END");        

    // Followed by padding
    // 50 bytes
    for (i = 0; i < 50; i = i + 1)
    begin
        data.sync_read(tempdata);
        data.assert(tempdata == 0, "PADDING");
    end

    // Followed by CRC
    // 4 bytes
    data.sync_read(tempdata);
    data.assert(tempdata == 8'hAA, "CRC");

    data.sync_read(tempdata);
    data.assert(tempdata == 8'hAA, "CRC");

    data.sync_read(tempdata);
    data.assert(tempdata == 8'h91, "CRC");

    data.sync_read(tempdata);
    data.assert(tempdata == 8'h91, "CRC");

    expected_tx_enable = 0;
   
    // Wait IFG and send the same packet again
    #120

    // Assert Carrier Sense - Should have no effect in Full Duplex
    carrier_sense = 1;

    expected_tx_enable = 1;

    // MAC should start transmitting the preamble
    // 7 bytes
    for (i = 0; i < 7; i = i + 1)
    begin
        data.sync_read(tempdata);
        data.assert(tempdata  == 8'h55, "Preamble");
        expected_tx_enable = 1;
    end

    // Followed by the SFD
    // 1 byte
    data.sync_read(tempdata);
    data.assert(tempdata  == 8'hD5, "SFD");

    // Followed by the frame data we supply
    // 10 Bytes
    fork
        // Data Start
        data.sync_write(8'h00);
        data_start.sync_write(1);
    join
        data.assert(tx_data == 0, "DATA START");        

    for (i = 1; i < 9; i = i + 1)
    begin
        data.sync_write(i);
        data.assert(tx_data == i, "DATA");
    end

    fork
        // Data End
        data.sync_write(8'h09);
        data_end.sync_write(1);
    join
        data.assert(tx_data == 8'h09, "DATA END");        

    // Followed by padding
    // 50 bytes
    for (i = 0; i < 50; i = i + 1)
    begin
        data.sync_read(tempdata);
        data.assert(tempdata == 0, "PADDING");
    end

    // Followed by CRC
    // 4 bytes
    data.sync_read(tempdata);
    data.assert(tempdata == 8'hAA, "CRC");

    data.sync_read(tempdata);
    data.assert(tempdata == 8'hAA, "CRC");

    data.sync_read(tempdata);
    data.assert(tempdata == 8'h91, "CRC");

    data.sync_read(tempdata);
    data.assert(tempdata == 8'h91, "CRC");

    expected_tx_enable = 0;

    // Wait IFG and send the same packet again
    #120

    expected_tx_enable = 1;

    // MAC should start transmitting the preamble
    // 7 bytes
    for (i = 0; i < 7; i = i + 1)
    begin
        data.sync_read(tempdata);
        data.assert(tempdata  == 8'h55, "Preamble");
        expected_tx_enable = 1;
    end

    // Followed by the SFD
    // 1 byte
    data.sync_read(tempdata);
    data.assert(tempdata  == 8'hD5, "SFD");

    // Assert a collision - Should have no effect in Full Duplex
    collision = 1;

    // Followed by the frame data we supply
    // 10 Bytes
    fork
        // Data Start
        data.sync_write(8'h00);
        data_start.sync_write(1);
    join
        data.assert(tx_data == 0, "DATA START");        

    for (i = 1; i < 9; i = i + 1)
    begin
        data.sync_write(i);
        data.assert(tx_data == i, "DATA");
    end

    fork
        // Data End
        data.sync_write(8'h09);
        data_end.sync_write(1);
    join
        data.assert(tx_data == 8'h09, "DATA END");        

    // Followed by padding
    // 50 bytes
    for (i = 0; i < 50; i = i + 1)
    begin
        data.sync_read(tempdata);
        data.assert(tempdata == 0, "PADDING");
    end

    // Followed by CRC
    // 4 bytes
    data.sync_read(tempdata);
    data.assert(tempdata == 8'hAA, "CRC");

    data.sync_read(tempdata);
    data.assert(tempdata == 8'hAA, "CRC");

    data.sync_read(tempdata);
    data.assert(tempdata == 8'h91, "CRC");

    data.sync_read(tempdata);
    data.assert(tempdata == 8'h91, "CRC");

    expected_tx_enable = 0;

    $finish;
end

endmodule

