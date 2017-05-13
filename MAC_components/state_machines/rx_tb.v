`timescale 1ns / 1ps

module rx_tb();

reg         reset;

wire [7:0]  data_out;
wire        data_out_enable;
wire        data_out_start;
wire        data_out_end;
wire        error;
reg         clock;
reg         rx_data_valid;
reg         rx_error;
reg  [7:0]  rx_data;
reg         fifo_full;
reg  [7:0]  packet [0:1518];   

integer i;

rx U_rx (
    .reset(reset),
    .clock(clock),

    .rx_data_valid(rx_data_valid),
    .rx_data(rx_data),
    .rx_error(rx_error),

    .data_out(data_out),
    .data_out_enable(data_out_enable),
    .data_out_start(data_out_start),
    .data_out_end(data_out_end),
    .fifo_full(fifo_full),
    .error(error)
);

initial
begin
    $dumpfile("test.vcd");
    $dumpvars(0, rx_tb);
end

initial
begin
    reset = 1;  
    clock = 0;        
    rx_data = 0;
    fifo_full = 0;
    $readmemh("packet.hex", packet);

    #15 reset = 0;

    // Send a packet
    for(i = 0; i < 104; i = i + 1)
    begin
        push(packet[i], 1, 0);
    end

    #100

    $finish;
end

always
    #2 clock = ~clock;

task push;
    input [7:0] data;
    input       data_valid;
    input       data_error;
begin
    rx_data = data;
    rx_data_valid = data_valid;
    rx_error = data_error;
    @(posedge clock);
    #1 rx_data_valid = 0;
    rx_error = 0;
    $display("Pushed: %x Valid: %b Error: %b",data, data_valid, data_error );
end
endtask

endmodule

