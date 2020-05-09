`timescale 1ns / 1ps

module counter(
  input              clk100_i,
  input      [9:0]   sw_i,
  input      [1:0]   key_i,
  output     [9:0]   ledr_o,
  output reg [6:0]   hex1_o,
  output reg [6:0]   hex0_o
);

dff dff_leds(
  .data_i  ( sw_i[9:0] ),
  .clk_i   ( clk100_i ),
  .rstn_i  ( key_i[1] ),
  .en_i    ( key_i[0] ),
  .q_o     ( ledr_o )
 );

reg sw_event;
always @( sw_i )
begin
  if (( sw_i[0]+sw_i[1]+sw_i[2]+sw_i[3]+sw_i[4]+sw_i[5]+sw_i[6]+sw_i[7]+sw_i[8]+sw_i[9] )> 4'd3)  sw_event <= 1'b1; 
  else sw_event <= 1'b0;
end 

reg [2:0] event_sync_reg; 
 wire bwp;
 always @( posedge clk100_i )
   begin
    event_sync_reg[0] <= key_i[0]; 
    event_sync_reg[1] <= event_sync_reg[0]; 
    event_sync_reg[2] <= event_sync_reg[1]; 
   end
 assign bwp =~event_sync_reg[2]& event_sync_reg[1]; 
 

 reg [7:0] counter;
 always@( posedge clk100_i or negedge key_i[1] )
   begin
   if( !key_i[1] ) counter <= 0;
   else
    if( bwp & sw_event ) counter <= counter + 1;
   end
 

 always @( posedge clk100_i or negedge key_i[1] )
   begin
     if( !key_i[1] ) hex0_o = 7'b1000000;
     case( counter [3:0] )
       4'd0:   hex0_o = 7'b1000000;
       4'd1:   hex0_o = 7'b1111001;
       4'd2:   hex0_o = 7'b0100100;
       4'd3:   hex0_o = 7'b0110000;
       4'd4:   hex0_o = 7'b0011001;
       4'd5:   hex0_o = 7'b0010010;
       4'd6:   hex0_o = 7'b0000010;
       4'd7:   hex0_o = 7'b1111000;
       4'd8:   hex0_o = 7'b0000000;
       4'd9:   hex0_o = 7'b0010000;
       4'd10:  hex0_o = 7'b0001000;
       4'd11:  hex0_o = 7'b0000011;
       4'd12:  hex0_o = 7'b1000110;
       4'd13:  hex0_o = 7'b0100001;
       4'd14:  hex0_o = 7'b0000110;
       4'd15:  hex0_o = 7'b0001110; 
      endcase
  end
 always @( posedge clk100_i or negedge key_i[1] ) 
   begin
     if( !key_i[1] ) hex1_o = 7'b1000000;   
     case( counter [7:4] )
       4'd0:   hex1_o = 7'b1000000;
       4'd1:   hex1_o = 7'b1111001;
       4'd2:   hex1_o = 7'b0100100;
       4'd3:   hex1_o = 7'b0110000;
       4'd4:   hex1_o = 7'b0011001;
       4'd5:   hex1_o = 7'b0010010;
       4'd6:   hex1_o = 7'b0000010;
       4'd7:   hex1_o = 7'b1111000;
       4'd8:   hex1_o = 7'b0000000;
       4'd9:   hex1_o = 7'b0010000;
       4'd10:  hex1_o = 7'b0001000;
       4'd11:  hex1_o = 7'b0000011;
       4'd12:  hex1_o = 7'b1000110;
       4'd13:  hex1_o = 7'b0100001;
       4'd14:  hex1_o = 7'b0000110;
       4'd15:  hex1_o = 7'b0001110; 
      endcase
  end

endmodule
