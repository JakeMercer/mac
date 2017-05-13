module monitor #(
    parameter WIDTH  = 8
)(
    input  wire [WIDTH-1:0]   data,
    input  wire               expected,
    input  wire               clock
);

always @(posedge clock)
begin
    if (data != expected)
    begin
        $display("MONITOR FAILED");
    end
end

endmodule
