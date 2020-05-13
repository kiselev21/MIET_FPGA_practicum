`timescale 1ns / 1ps

module counter(
  input              clk100_i,
  input      [13:0]  sw_i,
  input      [1:0]   key_i,
  output     [13:0]  ledr_o,
  output reg [6:0]   hex1_o,
  output reg [6:0]   hex0_o
);

dff dff_leds(
  .data_i  ( sw_i[13:0] ),
  .clk_i   ( clk100_i ),
  .rstn_i  ( key_i[1] ),
  .en_i    ( key_i[0] ),
  .q_o     ( ledr_o )
 );

wire bwp;
Debounce deb(
  .clk_i        ( clk100_i ),
  .rst_i        ( key_i[1] ),
  .en_i         ( !key_i[0] ),
  .en_down_o    ( bwp ) 
);

 reg [7:0] counter;
 
 always@( posedge clk100_i or negedge key_i[1] )
   begin
   if( !key_i[1] ) counter <= 0;
   else
    if( bwp ) counter <= counter + sw_i[13:10];
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
