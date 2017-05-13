module arbiter_tb();

reg clock;
reg reset;
reg [3:0] request;
wire [3:0] grant;

round_robin_4 rr
(
    .clock(clock),
    .reset(reset),
    .request(request),
    .grant(grant)
);

initial
begin
    $dumpfile("test.vcd");
    $dumpvars(0,arbiter_tb);
end

initial
begin
    clock = 0;
    reset = 1;
    request = 0;

    #20 reset = 0;

    request = 5;

    #20 $finish();

end

always
    #5 clock = ~clock;

endmodule
