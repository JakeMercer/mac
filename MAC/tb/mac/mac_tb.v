`timescale 1ns / 1ps

module mac_test();

reg         reset;

reg [31:0]  data_in;
reg         data_in_clock;
reg         data_in_enable;
reg         data_in_start;
reg         data_in_end;

reg         tx_clock;
reg         carrier_sense;
reg         collision;
wire        tx_enable;
wire  [7:0] tx_data;

reg   [31:0]  packet [0:380];   
integer     i;
mac U_mac ( 
    .reset(reset),

    // IN PORT
    .data_in(data_in),
    .data_in_clock(data_in_clock),
    .data_in_enable(data_in_enable),
    .data_in_start(data_in_start),
    .data_in_end(data_in_end),

    .tx_clock(tx_clock),

    .carrier_sense(carrier_sense),
    .collision(collision),

    .tx_enable(tx_enable),
    .tx_data(tx_data)
);

initial
 begin
    $dumpfile("test.vcd");
    $dumpvars(0,mac_test,U_mac,U_mac.U_tx_sm,U_mac.U_tx_sm.U_crc);
 end

initial
begin
    $monitor("TX ENABLE: %b, TX DATA: %x", tx_enable, tx_data);
    reset = 1;  
    data_in = 0;    
    data_in_clock = 0;
    data_in_enable = 0;    
    tx_clock = 0;        
    data_in_start = 0;
   
    $readmemh("tx.hex", packet);

    #15 reset = 0;


    // Send a packet
    
    push(packet[0], 1, 0);
    for(i = 1; i < 14; i = i + 1)
    begin
        push(packet[i], 0, 0);
    end
    push(packet[14], 0, 1);
 
    #120 $finish;
end

always
    #20 data_in_clock = ~data_in_clock;

always
    #1 tx_clock = ~tx_clock;

task push;
    input[31:0] data;
    input               data_start;
    input               data_end;
begin
    data_in = data;
    data_in_enable = 1;
    data_in_start = data_start;
    data_in_end = data_end;
    @(posedge data_in_clock);
    #1 data_in_enable = 0;
    data_in_start = 0;
    data_in_end = 0;
    $display("Pushed: %x Start: %b End: %b",data, data_start, data_end );
end
endtask

endmodule

