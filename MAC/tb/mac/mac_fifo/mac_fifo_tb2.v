`timescale 1ns / 1ps

module mac_fifo_test();

parameter IN_WIDTH = 8;
parameter OUT_WIDTH = 32;

reg                     reset;

reg     [IN_WIDTH-1:0]  data_in;
reg                     data_in_clock;
reg                     data_in_enable;
reg                     data_in_start;
reg                     data_in_end;

wire    [OUT_WIDTH-1:0] data_out;
reg                     data_out_clock;
reg                     data_out_enable;

wire                    data_out_start;
wire                    data_out_end;

reg                     error;
reg                     retry;
reg     [OUT_WIDTH-1:0] tempdata;

integer i;

mac_fifo #(
    .DATA_IN_WIDTH (IN_WIDTH),
    .DATA_OUT_WIDTH (OUT_WIDTH),
    .FIFO_DEPTH (12)
)
ff ( 
    .reset(reset),

    // IN PORT
    .data_in(data_in),
    .data_in_clock(data_in_clock),
    .data_in_enable(data_in_enable),
    .data_in_start(data_in_start),
    .data_in_end(data_in_end),

    // OUT PORT
    .data_out(data_out),
    .data_out_clock(data_out_clock),
    .data_out_enable(data_out_enable),
    .data_out_start(data_out_start),
    .data_out_end(data_out_end),

    .retry(retry),
    .error(error)
);

initial
begin
    reset = 1;  
    data_in = 0;    
    data_in_clock = 0;
    data_in_enable = 0;    
    data_out_clock = 0;        
    data_out_enable = 0;
    data_in_start = 0;
    data_in_end = 0;
    error = 0;
    retry = 0;
    tempdata = 0;
    
    #15 reset = 0;

    push(8'h01,1,0,0);
    push(8'h02,0,0,0);
    push(8'h03,0,0,0);
    push(8'h04,0,0,0);
    push(8'h05,0,0,0);
    push(8'h06,0,0,0);
    push(8'h07,0,0,0);
    push(8'h08,0,0,0);
    push(8'h09,0,0,0);
    push(8'h0A,0,0,0);
    push(8'h0B,0,0,0);
    push(8'h0C,0,0,0);
    push(8'h0D,0,0,0);
    push(8'h0E,0,0,0);
    push(8'h0F,0,0,0);
    push(8'h10,0,0,0);
    push(8'h11,0,0,0);
    push(8'h12,0,0,0);
    push(8'h13,0,0,0);
    push(8'h14,0,1,0);

    push(8'h11,1,0,0);
    push(8'h22,0,0,0);
    push(8'h33,0,0,0);
    push(8'h44,0,0,1);

    push(8'h55,1,0,0);
    push(8'h66,0,0,0);
    push(8'h77,0,0,0);
    push(8'h88,0,0,0);
    push(8'h99,0,0,0);
    push(8'hAA,0,0,0);
    push(8'hBB,0,0,0);
    push(8'hCC,0,0,0);
    push(8'hDD,0,0,0);
    push(8'hEE,0,0,0);
    push(8'hFF,0,1,0);

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
    #5 data_in_clock = ~data_in_clock;

always
    #40 data_out_clock = ~data_out_clock;

task push;
    input[IN_WIDTH-1:0] data;
    input               data_start;
    input               data_end;
    input               frame_error;
begin
    data_in = data;
    data_in_enable = 1;
    data_in_start = data_start;
    data_in_end = data_end;
    error = frame_error;
    @(posedge data_in_clock);
    #1 data_in_enable = 0;
    data_in_start = 0;
    data_in_end = 0;
    error = 0;
    $display("Pushed: %x Start: %b End: %b",data, data_start, data_end );
end
endtask

task pop;
    output [OUT_WIDTH-1:0] data;
begin  
    data_out_enable = 1;
    @(posedge data_out_clock);
    #1 data_out_enable = 0;
    data = data_out;
    $display("Popped %x Start: %b End: %b", data, data_out_start, data_out_end);
end
endtask

endmodule

