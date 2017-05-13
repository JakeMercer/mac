`timescale 1ns / 1ps

module mac_test();

reg                     reset;

wire [31:0]  data_out;
reg          data_out_clock;
reg          data_out_enable;
wire         data_out_start;
wire         data_out_end;
wire [6:0]   frame_count;

reg         rx_clock;
reg         rx_data_valid;
reg         rx_error;
reg  [7:0]  rx_data;
reg  [7:0]  packet [0:1518];   
reg  [31:0] tempdata;    

integer i;
wire [31:0] crc;

mac U_mac ( 
    .reset(reset),

    // OUT PORT
    .data_out(data_out),
    .data_out_clock(data_out_clock),
    .data_out_enable(data_out_enable),
    .data_out_start(data_out_start),
    .data_out_end(data_out_end),
    .frame_count(frame_count),

    .rx_clock(rx_clock),

    .rx_data_valid(rx_data_valid),
    .rx_error(rx_error),

    .rx_data(rx_data)
);

initial
begin
    $dumpfile("test.vcd");
    $dumpvars(0, mac_test, U_mac, U_mac.U_rx_sm, U_mac.U_rx_sm.U_crc);
end

initial
begin
    reset = 1;  
    data_out_clock = 0;
    data_out_enable = 0;    
    rx_clock = 0;        
    rx_data = 0;
    $readmemh("rx.hex", packet);

    
    $monitor("STATE :%0d FRAME_LENGTH: %0d CRC: %0x", U_mac.U_rx_sm.state, U_mac.U_rx_sm.frame_length_counter, U_mac.U_rx_sm.crc_out);

    #15 reset = 0;

    // Send a packet
    for(i = 0; i < 72; i = i + 1)
    begin
        push(packet[i], 1, 0);
    end
  
    for(i = 72; i < 80; i = i + 1)
    begin
        push(packet[i], 0, 0);
    end

    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);
    pop(tempdata);

    $finish;
end

always
    #20 data_out_clock = ~data_out_clock;

always
    #1 rx_clock = ~rx_clock;

task push;
    input [7:0] data;
    input       data_valid;
    input       data_error;
begin
    rx_data = data;
    rx_data_valid = data_valid;
    rx_error = data_error;
    @(posedge rx_clock);
    #1 rx_data_valid = 0;
    rx_error = 0;
    $display("Pushed: %x Valid: %b Error: %b",data, data_valid, data_error );
end
endtask

task pop;
    output [31:0]  data;
begin  
    data_out_enable = 1;
    @(posedge data_out_clock);
    #1 data_out_enable = 0;
    data = data_out;
    $display("Popped %x Start: %b End: %b ", data, data_out_start, data_out_end);
end
endtask

endmodule

