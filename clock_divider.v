module clock_divider #(
    parameter DIVIDER = 2
)(
    input   wire    reset,
    input   wire    clock_in,
    output  reg     clock_out
);

integer count;

always @(posedge clock_in)
begin
    if (reset)
    begin
        count <= 0;
    end
    else if (count == DIVIDER - 1)
    begin
        count <= 0;
    end
    else
    begin
        count <= count + 1;
    end
end

always @(posedge clock_in)
begin
    if (reset)
    begin
        clock_out <= 0;
    end
    else if (count == DIVIDER - 1)
    begin
        clock_out <= ~clock_out;
    end
end

endmodule
