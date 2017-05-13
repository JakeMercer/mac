`timescale 1ns / 1ps

module fifo_test();

parameter IN_WIDTH = 32;
parameter OUT_WIDTH = 4;

reg                     reset;

reg     [IN_WIDTH-1:0]  data_in;
reg                     data_in_clock;
reg                     data_in_enable;

wire    [OUT_WIDTH-1:0] data_out;
reg                     data_out_clock;
reg                     data_out_enable;

reg     [OUT_WIDTH-1:0]    tempdata;

integer i;

fifo #(
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

    // OUT PORT
    .data_out(data_out),
    .data_out_clock(data_out_clock),
    .data_out_enable(data_out_enable)
);

initial
begin
    reset = 1;  
    data_in = 0;    
    data_in_clock = 0;
    data_in_enable = 0;    
    data_out_clock = 0;        
    data_out_enable = 0;
    tempdata = 0;

    #15 reset = 0;

    if (OUT_WIDTH > IN_WIDTH)
    begin
        for ( i = 0; i < (OUT_WIDTH/IN_WIDTH); i = i + 1)
        begin
            push(i);
        end

        pop(tempdata);
    end
    else
    begin
        push(1);

        for ( i = 0; i < (IN_WIDTH/OUT_WIDTH); i = i + 1)
        begin
            pop(tempdata);
        end
    end

    $finish;
end

always
    #5 data_in_clock = ~data_in_clock;

always
    #40 data_out_clock = ~data_out_clock;

task push;
    input[IN_WIDTH-1:0] data;
begin
    data_in = data;
    data_in_enable = 1;
    @(posedge data_in_clock);
    #1 data_in_enable = 0;
    $display("Pushed %x",data );
end
endtask

task pop;
    output [OUT_WIDTH-1:0] data;
begin  
    data_out_enable = 1;
    @(posedge data_out_clock);
    #1 data_out_enable = 0;
    data = data_out;
    $display("Popped %x", data);
end
endtask

endmodule

