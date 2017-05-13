module random_gen( 
    input           reset,
    input           clock,
    input           init,
    input   [3:0]   retry_count,
    output reg      trigger
);

reg [9:0]       random_sequence;
reg [9:0]       random;
reg [9:0]       random_counter;
reg [7:0]       slot_time_counter; //256*2=512bit=1 slot time

always @ (posedge clock or posedge reset)
    if (reset)
        random_sequence <= 0;
    else
        random_sequence <= {random_sequence[8:0],~(random_sequence[2]^random_sequence[9])};
        
always @ (retry_count or random_sequence)
    case (retry_count)
        4'h0    : random = {9'b0, random_sequence[0]};
        4'h1    : random = {8'b0, random_sequence[1:0]};     
        4'h2    : random = {7'b0, random_sequence[2:0]};
        4'h3    : random = {6'b0, random_sequence[3:0]};
        4'h4    : random = {5'b0, random_sequence[4:0]};
        4'h5    : random = {4'b0, random_sequence[5:0]};
        4'h6    : random = {3'b0, random_sequence[6:0]};
        4'h7    : random = {2'b0, random_sequence[7:0]};
        4'h8    : random = {1'b0, random_sequence[8:0]};
        4'h9    : random = {      random_sequence[9:0]};  
        default : random = {      random_sequence[9:0]};
    endcase

always @ (posedge clock or posedge reset)
    if (reset)
        slot_time_counter <= 0;
    else if(init)
        slot_time_counter <= 0;
    else if(!trigger)
        slot_time_counter <= slot_time_counter + 1;
    
always @ (posedge clock or posedge reset)
    if (reset)
        random_counter <= 0;
    else if (init)
        random_counter <= random;
    else if (random_counter != 0 && slot_time_counter == 255)
        random_counter <= random_counter - 1;
        
always @ (posedge clock or posedge reset)
    if (reset)
        trigger <= 1;
    else if (init)
        trigger <= 0;
    else if (random_counter == 0)
        trigger <= 1;
        
endmodule


