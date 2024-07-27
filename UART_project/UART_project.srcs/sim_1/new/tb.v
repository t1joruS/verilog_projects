`timescale 1ns / 1ps
module tb;
 
    reg clk = 0;
    reg start = 0;
    reg [7:0] data_in;
    wire [7:0] rx_out;
    wire rx_done, tx_done;
 
   wire txrx;
   
 UART dut (data_in,clk, start, txrx,txrx, rx_out, tx_done, rx_done );
 integer i = 0;
 
 initial 
 begin
 start = 1;
 for(i = 0; i < 10; i = i + 1) begin
 data_in = $urandom_range(10 , 200);
 @(posedge rx_done);
 @(posedge tx_done);
 end
 $stop; 
 end
 
 always #5 clk = ~clk;
 
 endmodule
