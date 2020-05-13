`timescale 1ns / 1ps

module dff(
  input      [13:0] data_i,
  input             clk_i,
  input             rstn_i,
  input             en_i,
  output reg [13:0] q_o
    );
wire [13:0] r;
assign r = data_i & data_i - 1;

always @( posedge clk_i or negedge rstn_i ) 
  begin 
    if ( !rstn_i ) q_o <= 0; 
    else
     if ( !en_i )
       begin
        q_o <= r; 
       end
  end 

endmodule
