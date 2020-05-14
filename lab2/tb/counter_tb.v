`timescale 1ns / 1ps

module counter_tb();

reg  [13:0]   sw;
reg  [1:0]   key;
reg          clk100;
wire [13:0]   ledr;
wire [6:0]   hex0;
wire [6:0]   hex1;

counter DUT(
 .sw_i     ( sw  [13:0] ),
 .key_i    ( key [1:0] ),
 .clk100_i ( clk100 ),
 .ledr_o   ( ledr[13:0] ),
 .hex0_o   ( hex0[6:0] ),
 .hex1_o   ( hex1[6:0] )
);

initial begin 
  clk100 <= 1'b1;
  forever #5 clk100 <= ~clk100;
end

initial begin
  key[1] <= 1'b0;
  #11
  key[1] <= 1'b1;
end

initial begin 
  sw[13:0] <= 14'd0;
  repeat(15)
  begin
    #50;
    sw[13:0] = $random();
  end
end
 
initial begin
  key[0] <= 1'b0;
  forever #22 key[0] <= ~key[0];   
end 

endmodule
