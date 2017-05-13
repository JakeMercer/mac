module priority_encoder
# (
    parameter NO_INPUTS = 4
)(
    input   wire                    enable,
    input   wire [NO_INPUTS-1:0]    in,
    output  reg  [NO_INPUTS-1:0]    out
);

integer i;

always @(*)
    if (enable)
    begin
        for (i = 0; i < NO_INPUTS; i = i + 1)
        begin
            if(in[i] && !out)
                out = 1 << i;
        end
    end
    else
        out = 0;

endmodule
