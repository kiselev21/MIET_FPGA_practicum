`timescale 1ns / 1ps

module fin_state_machine (
  input        clk100_i,
  input        rstn_i,
  input        set_i,
  input        change_i,
  input        device_running_i,
  output [2:0] state_value_o,
  output       increm_counter_o,
  output       passed_all
    );
reg [2:0] state;
reg [2:0] next_state;   
reg       increm;

reg    st_over;
assign passed_all = st_over;
assign state_value_o = state;

localparam IDLE      = 3'd0;
localparam CH_HUND   = 3'd1;
localparam CH_TENTHS = 3'd2;
localparam CH_SEC    = 3'd3;
localparam CH_TEN    = 3'd4;   

assign state_value_o = state;

always @( * ) begin
  if ( !rstn_i )
    increm <= 1'b0;
  case ( state )
    IDLE   :    if ( !device_running_i )next_state = CH_TEN;
                else begin                  
                  next_state = IDLE;
                  st_over <= 1'b0;
                end  
                   
  CH_HUND  :      if ( !device_running_i ) begin
                    if ( set_i )begin    
                      next_state = IDLE;
                      st_over <= 1'b1;
                    end
                    if ( change_i )  increm     = 1'b1;
                    else             increm     = 1'b0;
                  end
                else               next_state = IDLE;
 CH_TENTHS :      if ( !device_running_i ) begin
                    if ( set_i )     next_state = CH_HUND;
                    if ( change_i )  increm     = 1'b1;
                    else             increm     = 1'b0;
                  end
                else               next_state = IDLE;    
    CH_SEC :      if ( !device_running_i ) begin
                    if ( set_i )     next_state = CH_TENTHS;
                    if ( change_i )  increm     = 1'b1;
                    else             increm     = 1'b0;
                  end
                 else               next_state = IDLE; 
    CH_TEN :      if ( !device_running_i ) begin
                    if ( set_i )     next_state = CH_SEC;
                    if ( change_i )  increm     = 1'b1;
                    else             increm     = 1'b0;
                    end
                  else               next_state = IDLE;   
   default :                         next_state = IDLE;                                        
  endcase
end

reg [1:0] button_syncroniser;
always @( posedge clk100_i or negedge rstn_i ) begin
  if ( !rstn_i )
    button_syncroniser <= 2'b0;
  else begin
    button_syncroniser[0] <=  increm;
    button_syncroniser[1] <=  button_syncroniser[0];
  end
end

assign increm_counter_o = ~button_syncroniser[1] & button_syncroniser[0];

always @( posedge clk100_i or negedge rstn_i ) begin
  if ( !rstn_i ) begin
    state   <= IDLE;
    increm  <= 1'b0;
    end
  else 
    state <= next_state;
end

endmodule
