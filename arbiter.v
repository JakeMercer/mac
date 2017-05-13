module round_robin_4
(
    input   wire       clock,
    input   wire       reset,

    input   wire [3:0] request,
    output  wire [3:0] grant
);

reg  [$clog2(4)-1:0]  counter;
wire [3:0]            priority [3:0];

assign grant[0-:1] = priority[0][0-:1] | priority[1][3-:1] | priority[2][2-:1] | priority[3][1-:1] ;
assign grant[1-:1] = priority[0][1-:1] | priority[1][0-:1] | priority[2][3-:1] | priority[3][2-:1] ;
assign grant[2-:1] = priority[0][2-:1] | priority[1][1-:1] | priority[2][0-:1] | priority[3][3-:1] ;
assign grant[3-:1] = priority[0][3-:1] | priority[1][2-:1] | priority[2][1-:1] | priority[3][0-:1] ;

// Ring Counter
always @(posedge clock)
    if (reset)
        counter <= 0;
    else
        counter <= counter + 1;

priority_encoder
#(
    .NO_INPUTS(4)
) U_priority_encoder_0 (
    .enable((counter == 0)),
    .in({request[0],request[1],request[2],request[3]}),
    .out(priority[0])
);

priority_encoder  
#(
    .NO_INPUTS(4)
) U_priority_encoder_1 (
    .enable((counter == 1)),
    .in({request[1],request[2],request[3],request[0]}),
    .out(priority[1])
);

priority_encoder  
#(
    .NO_INPUTS(4)
) U_priority_encoder_2 (
    .enable((counter == 2)),
    .in({request[2],request[3],request[0],request[1]}),
    .out(priority[2])
);

priority_encoder 
#(
    .NO_INPUTS(4)
) U_priority_encoder_3 (
    .enable((counter == 3)),
    .in({request[3],request[0],request[1],request[2]}),
    .out(priority[2])
);

endmodule
