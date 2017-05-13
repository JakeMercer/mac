`timescale 1ns / 1ps

module mac_fifo #(
    parameter DATA_IN_WIDTH = 32,
    parameter DATA_OUT_WIDTH = 8,
    parameter FIFO_DEPTH = 12
)(
    input   wire                            reset,    

    // IN PORT
    input   wire    [DATA_IN_WIDTH-1:0]     data_in,
    input   wire                            data_in_clock,     
    input   wire                            data_in_enable,
    input   wire                            data_in_start,
    input   wire                            data_in_end,

    // OUT PORT
    output  wire    [DATA_OUT_WIDTH-1:0]    data_out,
    input   wire                            data_out_clock,     
    input   wire                            data_out_enable,
    output  wire                            data_out_start,
    output  wire                            data_out_end,

    input   wire                            retry,
    input   wire                            error,
    output  reg     [FIFO_DEPTH-6:0]        frame_count
);

    always @(posedge data_in_end or posedge data_out_end or posedge reset)
    begin
        if (reset)
        begin
            frame_count <= 0;
        end
        else if (data_in_end)
        begin
            frame_count <= frame_count + 1;
        end
        else if (data_out_end)
        begin
            frame_count <= frame_count - 1;
        end

    end

    generate if (DATA_IN_WIDTH > DATA_OUT_WIDTH)
    begin
        genvar i;        
        wire [(DATA_IN_WIDTH-1)+(2*(DATA_IN_WIDTH/DATA_OUT_WIDTH)):0]   fifo_data_in;
        wire [DATA_OUT_WIDTH + 1:0]                                     fifo_data_out;
    
        wire [FIFO_DEPTH-1:0]                                           data_in_address;
        reg  [FIFO_DEPTH-1:0]                                           data_in_address_tmp;
        wire [FIFO_DEPTH-1:0]                                           data_out_address;
        reg  [FIFO_DEPTH-1:0]                                           data_out_address_tmp;

        always @(posedge data_out_start or posedge reset)
        begin
            if (reset)
            begin
                data_out_address_tmp <= 0;
            end
            else if (data_out_start)
            begin
                data_out_address_tmp <= data_out_address;
            end
        end

        always @(posedge data_in_start or posedge reset)
        begin
            if (reset)
            begin
                data_in_address_tmp <= 0;
            end
            else if (data_in_start)
            begin
                data_in_address_tmp <= data_in_address;
            end
        end

        for (i = 0; i < DATA_IN_WIDTH/DATA_OUT_WIDTH; i = i + 1)
        begin
            assign fifo_data_in [(DATA_IN_WIDTH-1)+(2*(DATA_IN_WIDTH/DATA_OUT_WIDTH)-(i*(DATA_OUT_WIDTH+2)))-:DATA_OUT_WIDTH] = data_in [((DATA_IN_WIDTH-1)-(i*DATA_OUT_WIDTH))-:DATA_OUT_WIDTH];
            if ( i == 0 )
            begin
                assign fifo_data_in [(DATA_IN_WIDTH-1)+(2*(DATA_IN_WIDTH/DATA_OUT_WIDTH)-(i*(DATA_OUT_WIDTH+2)))-DATA_OUT_WIDTH-:2] = { data_in_start, 1'b0 };
            end
            else if ( i ==  DATA_IN_WIDTH/DATA_OUT_WIDTH - 1)
            begin
                assign fifo_data_in [(DATA_IN_WIDTH-1)+(2*(DATA_IN_WIDTH/DATA_OUT_WIDTH)-(i*(DATA_OUT_WIDTH+2)))-DATA_OUT_WIDTH-:2] = { 1'b0, data_in_end };            
            end
            else
            begin
                assign fifo_data_in [(DATA_IN_WIDTH-1)+(2*(DATA_IN_WIDTH/DATA_OUT_WIDTH)-(i*(DATA_OUT_WIDTH+2)))-DATA_OUT_WIDTH-:2] = { 1'b0, 1'b0 };            
            end
        end

        assign {data_out, data_out_start, data_out_end} = fifo_data_out;

        fifo #(
            .DATA_IN_WIDTH ((DATA_IN_WIDTH)+(2*(DATA_IN_WIDTH/DATA_OUT_WIDTH))),
            .DATA_OUT_WIDTH (DATA_OUT_WIDTH + 2),
            .FIFO_DEPTH (12)
        )
        U_fifo ( 
            .reset(reset),
            .count(),
            // IN PORT
            .data_in(fifo_data_in),
            .data_in_clock(data_in_clock),
            .data_in_enable(data_in_enable),
            .data_in_address(data_in_address),
            .data_in_reset(error),
            .data_in_reset_address(data_in_address_tmp),
            // OUT PORT
            .data_out(fifo_data_out),
            .data_out_clock(data_out_clock),
            .data_out_enable(data_out_enable),
            .data_out_address(data_out_address),
            .data_out_reset(retry),
            .data_out_reset_address(data_out_address_tmp)

        );

    end
    else
    begin
        genvar i;       
        localparam FIFO_DATA_OUT_WIDTH = (DATA_OUT_WIDTH + (2 * (DATA_OUT_WIDTH/DATA_IN_WIDTH)));
        localparam FIFO_DATA_OUT_MAX_INDEX =  (FIFO_DATA_OUT_WIDTH - 1);
        localparam FIFO_DATA_IN_WIDTH = (DATA_IN_WIDTH + 2);
        localparam START_OFFSET = (DATA_IN_WIDTH);
        localparam END_OFFSET = (DATA_IN_WIDTH + 1);

        wire [(DATA_OUT_WIDTH-1)+(2*(DATA_OUT_WIDTH/DATA_IN_WIDTH)):0]  fifo_data_out;
        wire [DATA_IN_WIDTH + 1:0]                                      fifo_data_in;
        wire [(DATA_OUT_WIDTH/DATA_IN_WIDTH)-1:0]                       data_out_start_tmp;
        wire [(DATA_OUT_WIDTH/DATA_IN_WIDTH)-1:0]                       data_out_end_tmp;

        wire [FIFO_DEPTH-1:0]                                           data_in_address;
        reg  [FIFO_DEPTH-1:0]                                           data_in_address_tmp;
        wire [FIFO_DEPTH-1:0]                                           data_out_address;
        reg  [FIFO_DEPTH-1:0]                                           data_out_address_tmp;

        always @(posedge data_out_start or posedge reset)
        begin
            if (reset)
            begin
                data_out_address_tmp <= 0;
            end
            else if (data_out_start)
            begin
                data_out_address_tmp <= data_out_address;
            end
        end

        always @(posedge data_in_start or posedge reset)
        begin
            if (reset)
            begin
                data_in_address_tmp <= 0;
            end
            else if (data_in_start)
            begin
                data_in_address_tmp <= data_in_address;
            end
        end

        for (i = 0; i < DATA_OUT_WIDTH/DATA_IN_WIDTH; i = i + 1)
        begin
            assign data_out [(DATA_OUT_WIDTH-1)-(i*DATA_IN_WIDTH)-:DATA_IN_WIDTH] = fifo_data_out [(DATA_OUT_WIDTH-1)+(2*(DATA_OUT_WIDTH/DATA_IN_WIDTH)-(i*(DATA_IN_WIDTH+2)))-:DATA_IN_WIDTH];
            assign data_out_start_tmp[i-:1] = fifo_data_out [FIFO_DATA_OUT_MAX_INDEX-START_OFFSET-i*FIFO_DATA_IN_WIDTH-:1];
            assign data_out_end_tmp[i-:1] = fifo_data_out [FIFO_DATA_OUT_MAX_INDEX-END_OFFSET-i*FIFO_DATA_IN_WIDTH-:1];
           
            assign data_out_start = | data_out_start_tmp;
            assign data_out_end = | data_out_end_tmp;
        end

        assign fifo_data_in = {data_in, data_in_start, data_in_end};

        fifo #(
            .DATA_IN_WIDTH ((DATA_IN_WIDTH)+2),
            .DATA_OUT_WIDTH (DATA_OUT_WIDTH + 2*(DATA_OUT_WIDTH/DATA_IN_WIDTH)),
            .FIFO_DEPTH (12)
        )
        U_fifo ( 
            .reset(reset),
            .count(),
            
            // IN PORT
            .data_in(fifo_data_in),
            .data_in_clock(data_in_clock),
            .data_in_enable(data_in_enable),
            .data_in_address(data_in_address),
            .data_in_reset(error),
            .data_in_reset_address(data_in_address_tmp),
            // OUT PORT
            .data_out(fifo_data_out),
            .data_out_clock(data_out_clock),
            .data_out_enable(data_out_enable),
            .data_out_address(data_out_address),
            .data_out_reset(retry),
            .data_out_reset_address(data_out_address_tmp)

        );
    end
    endgenerate

endmodule

