`timescale 1ns / 1ps

module UART(
    input [7:0] data_in,
    input clk,
    input start,
    output reg tx,
    input rx,
    output [7:0] rx_out,
    output tx_done,rx_done);
    
    
 
 parameter clk_value=100000;
 parameter baud=9600;
 parameter wait_count=clk_value/baud;
 reg bit_done=0;        ///will be high only at the end of the bit duration
 integer count=0;
 parameter idle=0,send=1,check=2;
 reg[1:0]state; 
 
 //// trigger generation for Tx
 
 always@(posedge clk) begin
 if(state==idle)begin
 bit_done<=1'b0;
 count<=1'b0;
 end
 if(count==wait_count)begin
    bit_done<=1'b1;
    count<=1'b0;///resetting count
    end
 else begin 
    bit_done<=1'b0;
    count<=count+1;
 end
 end
 
 
 /////Tx block
 
 reg[9:0] tx_data;   ////start bit,data,stop bit
 integer bit_index=0;  /////will keep number of data bit sent so far
 reg [9:0]shift_tx=0;   ////will help in debugging
 
 always@(posedge clk) begin
 case(state)
 idle:
    begin
    tx<=1'b1;
    tx_data<=1'b0;
    bit_index<=1'b0;
    shift_tx<=1'b0;
        if(start)
            begin
            tx_data<={1'b1,data_in,1'b0};
            state<=send;
            end
        else
            state<=idle;
    end
    
 send:
    begin
    tx<=tx_data[bit_index];
    state<=check;
    shift_tx<={tx_data[bit_index],shift_tx[9:1]};
    
    end
 check:
    begin
        if (bit_index<=9)   /////0 to 9 = 10 bits
        begin           
            if(bit_done) begin 
                state<=send;
                bit_index<=bit_index+1;
            end
        end
        else 
            begin 
            state<=idle;
            bit_index<=0;
            end
    end
    default: state<=idle;
 endcase
 end
 assign tx_done= (bit_index==9 && bit_done==1'b1)?1'b1:2'b0;
 
 //////Rx code
 
 integer r_count=0;
 integer r_index=0;
 parameter r_idle=0, r_wait=1, recv=2, r_check=3;
 reg [1:0]r_state;
 reg [9:0]r_data;
 always@(posedge clk) begin
 case(r_state)
 r_idle:
 begin
 r_data<=0;
 r_count<=0;
 r_index<=0;
    if(rx==1'b0) begin
        r_state<=r_wait;
    end
    else
        r_state<=r_idle;
 end
 r_wait:
 begin
 if(r_count==r_wait/2) begin
    r_state<=r_wait;
    r_count<=r_count+1;
 end
 else begin
    r_count<=0;
    r_state<=recv;
    r_data<={rx,r_data[9:1]};
    end
 end
 recv: begin 
 if(r_index<=9)
 begin
    if(bit_done==1'b1) begin
    r_index<=r_index+1;
    r_state<=r_wait;
    end
 end
 else begin
 r_state<=r_idle;
 r_index<=0;
 end
 end
 default:r_state<=r_idle;
 endcase
 
 end
 assign rx_out=r_data[8:1];
 assign rx_done=(r_index==9&&bit_done==1'b1)?1'b1:1'b0;
endmodule
