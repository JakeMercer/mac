`timescale 1ns / 1ps

module mac_fifo_test();

parameter IN_WIDTH = 32;
parameter OUT_WIDTH = 8;

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
reg                     retry;

reg     [OUT_WIDTH-1:0]    tempdata;

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
    .retry(retry)
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
    retry = 0;
    tempdata = 0;
    
    #15 reset = 0;
    /*
    if (OUT_WIDTH > IN_WIDTH)
    begin
        for ( i = 0; i < (OUT_WIDTH/IN_WIDTH); i = i + 1)
        begin
            push(i,0,1);
        end

        pop(tempdata,0);
    end
    else
    begin
        push(1,1,1);

        for ( i = 0; i < (IN_WIDTH/OUT_WIDTH); i = i + 1)
        begin
            pop(tempdata,0);
        end
    end
    */

    push(1,1,0);
    push(2,0,0);
    push(3,0,1);

    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);

    pop(tempdata, 1);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
    pop(tempdata, 0);
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

task pop;
    output [OUT_WIDTH-1:0]  data;
    input                   frame_retry;
begin  
    data_out_enable = 1;
    retry = frame_retry;
    @(posedge data_out_clock);
    #1 data_out_enable = 0;
    retry = 0;
    data = data_out;
    $display("Popped %x Start: %b End: %b Retry:%b", data, data_out_start, data_out_end, frame_retry);
end
endtask

endmodule

