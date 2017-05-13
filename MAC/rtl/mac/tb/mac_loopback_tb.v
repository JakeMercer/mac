`timescale 1ns / 1ps

module mac_loopback_tb ();

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
    $dumpvars(0,mac_loopback_tb);
end

initial
begin
    #15 reset = 0;

    $readmemh("packet.hex", packet);

    // Send a packet
    for(i = 0; i < 104; i = i + 1)
    begin
        data_in.sync_write(packet[i]);
    end
 
    #20 
        
    expected_tx_enable = 1;

    data_out.sync_read(tempdata);

    // MAC should then start transmitting
    for (i = 0; i < 104; i = i + 1)
    begin
        data_out.sync_read(tempdata);
        util.assert(tempdata  == packet[i], "Tx Data");
        expected_tx_enable = 1;
        $display("TX: %x", tempdata);
    end
    expected_tx_enable = 0;
   
    util.display();

    $finish;
end

endmodule

