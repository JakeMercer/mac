
module station_management_tb ();

reg reset;
reg clock;

wire mdc;
reg  mdi;
wire mdo;

reg mode;

reg begin_transaction;
reg [4:0] phy_address;
reg [4:0] reg_address;
reg [15:0] data_in;
wire [15:0] data_out;

station_management U_station_management
(
    .reset(reset),
    .clock(clock),
    
    .mdc(mdc),
    .mdi(mdi),
    .mdo(mdo),
    
    .mode(mode),

    .begin_transaction(begin_transaction),
    .phy_address(phy_address),
    .reg_address(reg_address),
    .data_in(data_in),
    .data_out(data_out)
);

integer i;

initial
begin
    $dumpfile("test.vcd");
    $dumpvars(0,station_management_tb);
end

initial
begin
    mdi = 0;
    reset = 1;
    clock = 1;
    mode  = 0;
    begin_transaction = 0;
    phy_address = 5'b00001;
    reg_address = 5'b00010;
    data_in = 16'hFEDC;

    #20 reset = 0;

    #20 begin_transaction = 1;
    #10 begin_transaction = 0;
  
    #490

    for (i=0; i<16; i = i + 1)
    begin
        reading_bit((i%2)? 1'b1 : 1'b0);
    end
    mdi = 0;

    #50

    $finish();
end

always
    #5 clock = ~clock;

task reading_bit;
    input bit;
    begin
        mdi = bit;
        @(posedge mdc);
    end
endtask

task writing_bit;
    begin
        @(posedge mdc);
    end
endtask
endmodule
