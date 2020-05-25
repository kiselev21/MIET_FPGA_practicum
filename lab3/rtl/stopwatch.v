module stopwatch #(
  parameter PULSE_MAX  =  259999,
            COUNT_MAX  = 9
)

(
    input        clk100_i,
    input        rstn_i,
    input        start_stop_i,
    input        set_i,
    input        change_i,
    output [6:0] hex0_o,
    output [6:0] hex1_o,
    output [6:0] hex2_o,
    output [6:0] hex3_o
);

wire [2:0] state_value;
wire       increm_counter;
fin_state_machine fsm(
  .clk100_i              ( clk100_i ),
  .rstn_i                ( rstn_i ),
  .set_i                 ( b_set_was_pressed ),
  .change_i              ( b_change_was_pressed ),
  .device_running_i      ( device_running ),
  .state_value_o         ( state_value ),
  .increm_counter_o      ( increm_counter ),
  .passed_all            ( passed_all )
);


 reg [1:0] button_syncroniser; 
 wire button_was_pressed;
 always @( posedge clk100_i or negedge rstn_i ) begin 
   if( !rstn_i ) button_syncroniser <= 2'b0;
   else 
     begin
       button_syncroniser[0] <= start_stop_i; 
       button_syncroniser[1] <= button_syncroniser[0]; 
     end
  end  
 assign button_was_pressed = ~ button_syncroniser[1] && button_syncroniser[0];
 
 wire b_set_was_pressed;
 reg [1:0] sync_set;
 always @( posedge clk100_i or negedge rstn_i ) begin 
   if( !rstn_i ) sync_set <= 2'b0;
   else 
     begin
       sync_set[0] <= set_i; 
       sync_set[1] <=sync_set[0]; 
     end
  end  
 assign b_set_was_pressed = ~ sync_set[1] && sync_set[0];
 
 wire b_change_was_pressed;
 reg [1:0] sync_change;
 always @( posedge clk100_i or negedge rstn_i ) begin 
   if( !rstn_i ) sync_change <= 2'b0;
   else 
     begin
      sync_change[0] <= change_i; 
      sync_change[1] <= sync_change[0]; 
     end
  end  
 assign b_change_was_pressed = ~ sync_change[1] && sync_change[0];
 
localparam IDLE      = 3'd0;
localparam CH_HUND   = 3'd1;
localparam CH_TENTHS = 3'd2;
localparam CH_SEC    = 3'd3;
localparam CH_TEN    = 3'd4;
 
wire passed_all;
 
 reg device_running; 
 
 always@( posedge clk100_i or negedge rstn_i )begin
   if( !rstn_i ) device_running <= 1'b0;
   else if ( passed_all )
     device_running <= 1'b1;
   else if( state_value == IDLE )
     if ( button_was_pressed  )
     device_running <= ~device_running;
 end
 
 wire device_stopped;
 assign device_stopped = ~ device_running;
 
 
 reg [16:0] pulse_counter = 17'd0; 
 wire hundredth_of_second_passed;
 assign hundredth_of_second_passed = ( pulse_counter == PULSE_MAX );
 always @( posedge clk100_i or negedge rstn_i ) begin 
   if ( !rstn_i ) pulse_counter <= 0;  
   else if ( device_running | hundredth_of_second_passed )
     if ( hundredth_of_second_passed ) pulse_counter <= 0; 
     else pulse_counter <= pulse_counter + 1; 
 end 
 
 
 reg [3:0] hundredths_counter = 4'd0; 
 wire  tenth_of_second_passed;
 assign tenth_of_second_passed = ( ( hundredths_counter == COUNT_MAX ) &  hundredth_of_second_passed );
 always @( posedge clk100_i or negedge rstn_i ) begin
   if ( !rstn_i )
     hundredths_counter <= 0;
   else if ( hundredth_of_second_passed )begin
     if ( tenth_of_second_passed )
       hundredths_counter <= 0;
     else 
       hundredths_counter <= hundredths_counter + 1;
   end    
     else if ( state_value == CH_HUND && increm_counter  )
         hundredths_counter <= hundredths_counter + 1;
 end
 
 reg [3:0] tenths_counter = 4'd0; 
 wire second_passed;
 assign second_passed = ( ( tenths_counter == COUNT_MAX ) & tenth_of_second_passed );
 always @( posedge clk100_i or negedge rstn_i ) begin
   if ( !rstn_i ) 
     tenths_counter <= 0;
   else if ( tenth_of_second_passed )begin
     if ( second_passed ) 
       tenths_counter <= 0;
     else 
       tenths_counter <= tenths_counter + 1;
   end  
   else if ( state_value == CH_TENTHS && increm_counter )
     tenths_counter <= tenths_counter + 1;  
 end
 
 reg [3:0] seconds_counter = 4'd0;
 wire ten_seconds_passed;
 assign ten_seconds_passed = ( ( seconds_counter == COUNT_MAX ) & second_passed );
 always @( posedge clk100_i or negedge rstn_i ) begin
   if ( !rstn_i )
     seconds_counter <= 0;
   else if ( second_passed )begin
     if ( ten_seconds_passed ) 
       seconds_counter <= 0;
     else 
       seconds_counter <= seconds_counter + 1;
   end
   else if ( state_value == CH_SEC && increm_counter )
     seconds_counter <= seconds_counter + 1;    
 end
 
 
 reg [3:0] ten_seconds_counter = 4'd0;
 always @( posedge clk100_i or negedge rstn_i ) begin
   if ( !rstn_i ) 
     ten_seconds_counter <= 0;
   else if ( ten_seconds_passed )begin
     if ( ten_seconds_counter == COUNT_MAX )
       ten_seconds_counter <= 0;
     else 
       ten_seconds_counter <= ten_seconds_counter + 1;
     end
     else if ( state_value == CH_TEN && increm_counter )
       ten_seconds_counter <= ten_seconds_counter + 1;  
 end


reg [6:0] decoder_ten_seconds;

always @(*) begin
  case (ten_seconds_counter)
    4'd0: decoder_ten_seconds = 7'b0000001;
    4'd1: decoder_ten_seconds = 7'b1001111;
    4'd2: decoder_ten_seconds = 7'b0010010;
    4'd3: decoder_ten_seconds = 7'b0000110;
    4'd4: decoder_ten_seconds = 7'b1001100;
    4'd5: decoder_ten_seconds = 7'b0100100;
    4'd6: decoder_ten_seconds = 7'b0100000;
    4'd7: decoder_ten_seconds = 7'b0001111;
    4'd8: decoder_ten_seconds = 7'b0000000;
    4'd9: decoder_ten_seconds = 7'b0000100;
    default: decoder_ten_seconds = 7'b1111111;
  endcase
end
assign hex3_o = decoder_ten_seconds;

reg [6:0] decoder_seconds;

always @(*) begin
  case (seconds_counter)
    4'd0: decoder_seconds = 7'b0000001;
    4'd1: decoder_seconds = 7'b1001111;
    4'd2: decoder_seconds = 7'b0010010;
    4'd3: decoder_seconds = 7'b0000110;
    4'd4: decoder_seconds = 7'b1001100;
    4'd5: decoder_seconds = 7'b0100100;
    4'd6: decoder_seconds = 7'b0100000;
    4'd7: decoder_seconds = 7'b0001111;
    4'd8: decoder_seconds = 7'b0000000;
    4'd9: decoder_seconds = 7'b0000100;
    default: decoder_seconds = 7'b1111111;
  endcase
end

assign hex2_o = decoder_seconds;

reg [6:0] decoder_tenths;

always @(*) begin
  case (tenths_counter)
    4'd0: decoder_tenths = 7'b0000001;
    4'd1: decoder_tenths = 7'b1001111;
    4'd2: decoder_tenths = 7'b0010010;
    4'd3: decoder_tenths = 7'b0000110;
    4'd4: decoder_tenths = 7'b1001100;
    4'd5: decoder_tenths = 7'b0100100;
    4'd6: decoder_tenths = 7'b0100000;
    4'd7: decoder_tenths = 7'b0001111;
    4'd8: decoder_tenths = 7'b0000000;
    4'd9: decoder_tenths = 7'b0000100;
    default: decoder_tenths = 7'b1111111;
  endcase
end

assign hex1_o = decoder_tenths;

reg [6:0] decoder_hundredths;

always @(*) begin
  case (hundredths_counter)
    4'd0: decoder_hundredths = 7'b0000001;
    4'd1: decoder_hundredths = 7'b1001111;
    4'd2: decoder_hundredths = 7'b0010010;
    4'd3: decoder_hundredths = 7'b0000110;
    4'd4: decoder_hundredths = 7'b1001100;
    4'd5: decoder_hundredths = 7'b0100100;
    4'd6: decoder_hundredths = 7'b0100000;
    4'd7: decoder_hundredths = 7'b0001111;
    4'd8: decoder_hundredths = 7'b0000000;
    4'd9: decoder_hundredths = 7'b0000100;
    default: decoder_hundredths = 7'b1111111;
  endcase
end

assign hex0_o = decoder_hundredths;


endmodule