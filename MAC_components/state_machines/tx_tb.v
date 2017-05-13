`timescale 1ns / 1ps

module tx_tb();

reg         reset;
reg         clock;

wire [7:0]  tx_data;
wire        tx_enable;
reg         fifo_data_start;
reg         fifo_data_end;
reg  [7:0]  fifo_data;
wire        fifo_data_read;
reg  [7:0]  packet [0:1518];   
reg         data_available;



integer i;

tx_sm U_tx_sm (
    .reset(reset),
    .clock(clock),
    
    .fifo_data(fifo_data),
    .fifo_data_read(fifo_data_read),
    .fifo_data_start(fifo_data_start),
    .fifo_data_end(fifo_data_end),
    .fifo_data_available(data_available),
    .fifo_retry(retry),

    .mode(1'b1),

    .carrier_sense(),
    .collision(),

    .tx_enable(tx_enable),
    .tx_data(tx_data)
);

initial
begin
    $dumpfile("test.vcd");
    $dumpvars(0, tx_tb);
end

initial
begin
    reset = 1;  
    clock = 0;        
    fifo_data = 0;
    data_available = 0;
    $readmemh("packet.hex", packet);

    #15 reset = 0;

    // Send a packet
   
    data_available = 1;
    wait_for_read();

    push(packet[8], 1, 0);

    for(i = 9; i < 99; i = i + 1)
    begin
        push(packet[i], 0, 0);
    end

    push(packet[i], 0, 1);

    #100

    $finish;
end

always
    #2 clock = ~clock;

task push;
    input [7:0] data;
    input       data_start;
    input       data_end;
begin
    fifo_data = data;
    fifo_data_start = data_start;
    fifo_data_end = data_end;
    @(posedge clock);
    #1 fifo_data_start = 0;
    fifo_data_end = 0;
    $display("Pushed: %x Start: %b End: %b",data, data_start, data_end );
end
endtask

task wait_for_read;
begin
    @(posedge fifo_data_read);
end
endtask

endmodule

