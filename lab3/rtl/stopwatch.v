module stopwatch #(
  parameter PULSE_MAX  =  259999,
            COUNT_MAX  =       9
)

(
    input         clk100_i,
    input         rstn_i,
    input         start_stop_i,
    input         set_i,
    input         change_i,
    output  [6:0] hex0_o,
    output  [6:0] hex1_o,
    output  [6:0] hex2_o,
    output  [6:0] hex3_o
);
//Подключаем finite_state_machine

localparam IDLE      = 3'd0;
localparam CH_HUND   = 3'd1;
localparam CH_TENTHS = 3'd2;
localparam CH_SEC    = 3'd3;
localparam CH_TEN    = 3'd4;

wire passed_all;
wire [2:0] state_value;
wire       increm_counter;

fin_state_machine fsm(
  .clk100_i              ( clk100_i ),
  .rstn_i                ( rstn_i ),
  .set_i                 ( set_was_pressed ),
  .change_i              ( change_was_pressed ),
  .device_running_i      ( device_running ),
  .state_value_o         ( state_value ),
  .increm_counter_o      ( increm_counter ),
  .passed_all            ( passed_all )
);
///////////////////////////////////////////////////

//Подключаем Debounce
wire start_was_pressed;
Debounce deb_start(
  .clk_i        ( clk100_i ),
  .rst_i        ( rstn_i ),
  .en_i         ( !start_stop_i ),
  .en_down_o    ( start_was_pressed ) 
);
 
 wire set_was_pressed;
 Debounce deb_set(
  .clk_i        ( clk100_i ),
  .rst_i        ( rstn_i ),
  .en_i         ( !set_i ),
  .en_down_o    ( set_was_pressed ) 
);
 
 wire change_was_pressed;
 Debounce deb_change(
  .clk_i        ( clk100_i ),
  .rst_i        ( rstn_i ),
  .en_i         ( !change_i ),
  .en_down_o    ( change_was_pressed ) 
);
////////////////////////////////////////////////////////

 wire device_stopped;
 assign device_stopped = ~ device_running;
 
 reg device_running; 
 
 always@( posedge clk100_i or negedge rstn_i )
   begin
     if( !rstn_i ) device_running <= 1'b0;
     else if ( passed_all )
       device_running <= 1'b1;
     else if ( start_was_pressed && state_value == IDLE )
       device_running <= ~device_running;
   end
 ///////////////////////////////////////////////////////////
 
 reg [16:0] pulse_counter = 17'd0; 
 
 wire hundredth_of_second_passed;
 assign hundredth_of_second_passed = ( pulse_counter == PULSE_MAX );
 
 always @( posedge clk100_i or negedge rstn_i )
   begin 
     if ( !rstn_i ) pulse_counter <= 0;  
     else if ( device_running | hundredth_of_second_passed )
       if ( hundredth_of_second_passed ) pulse_counter <= 0; 
       else pulse_counter <= pulse_counter + 1; 
   end 
////////////////////////////////////////////////////////////// 
 
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

 decoder dec_ten(
   .data_i ( ten_seconds_counter ),
   .hex_o  ( hex3_o )  
 );

 decoder dec_sec(
   .data_i ( seconds_counter ),
   .hex_o  ( hex2_o )  
 );
 
 decoder dec_tenths(
   .data_i ( tenths_counter ),
   .hex_o  ( hex1_o )  
 );

 decoder dec_hund(
   .data_i ( hundredths_counter  ),
   .hex_o  ( hex0_o )  
 );

endmodule