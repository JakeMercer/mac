module utilities #(
    parameter IN_WIDTH  = 8,
    parameter OUT_WIDTH = 8,
    parameter DEBUG     = 0
)(
    output reg  [OUT_WIDTH-1:0]  data_out,
    output reg                   data_out_enable,
    input  wire [IN_WIDTH-1:0]   data_in,
    output reg                   data_in_enable,
    input  wire                  clock
);

integer passes;
integer fails;
initial 
begin
    data_out        = 0;
    data_out_enable = 0;
    data_in_enable  = 0;
    passes = 0;
    fails = 0;
end
task display;
    begin
        $display("PASSES:%d FAILS:%d", passes, fails);
    end
endtask

task sync_assert;
    input condition;
    input [100*8:0] message;
    begin
        @(posedge clock)
        if (condition)
        begin
            $display("ASSERTION PASSED | %0s", message);
            passes = passes + 1;
        end
        else
        begin
            $display("ASSERTION FAILED | %0s", message);
            fails = fails + 1;
        end
    end
endtask

task assert;
    input condition;
    input [100*8:0] message;
    begin
        if (condition)
        begin
            $display("ASSERTION PASSED | %0s", message);
            passes = passes + 1;            
        end
        else
        begin
            $display("ASSERTION FAILED | %0s", message);
            fails = fails + 1;            
        end
    end
endtask

task sync_write;
    input [OUT_WIDTH-1:0] data;
    begin
        data_out = data;
        data_out_enable = 1;
        @(posedge clock);
        #1 data_out_enable = 0;
        data_out = 0;
        if (DEBUG)
            $display("Wrote: 0x%0x | 0b%0b | %0d",data, data, data);
    end
endtask

task sync_read;
    output [IN_WIDTH-1:0]  data;
    begin  
        data_in_enable = 1;
        @(posedge clock);
        #1 data = data_in;
        data_in_enable = 0;
        if (DEBUG)
            $display("Read: 0x%0x | 0b%0b | %0d", data, data, data);
    end
endtask

endmodule


