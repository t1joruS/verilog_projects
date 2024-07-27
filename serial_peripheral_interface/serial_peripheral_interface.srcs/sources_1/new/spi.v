`timescale 1ns / 1ps

module spi(input clk,start,
input [11:0]din,
output reg cs,mosi,done,
output sclk);
integer count=0;
reg sclkt=0;

always@(posedge clk) begin
if (count<10)          ////count =n/2; where n=onboard_freq/dac_freq
    count<=count+1;
    else begin
        sclkt<=~sclkt;
        count<=0;
    end
end


////MOSI Tx block

parameter idle=0,start_st=1,send=2,end_st=3;
reg [1:0]state;
reg [11:0] temp; ///we take this so that our changes are only reflected after we make the Tx
integer bit_count=0;
always@(posedge sclkt)

case(state)
idle:
begin
mosi<=1'b0;
cs<=1'b1;
done<=1'b0;

if(start)begin
state<=start_st;
end
    else
        state<=idle;
        end
start_st:
begin
cs<=1'b0;
temp<=din;
state<=send;
end        
send:
begin
if (bit_count<=11)
begin
bit_count<=bit_count+1;
mosi <= temp[bit_count];
state<=send;
end
    else
    begin
        state<=end_st;
        bit_count<=0;
        mosi<=1'b0;
        end
end
end_st:
begin

cs<=1'b1;
state<=idle;
done<=1'b1;


end
default: state<=idle;


endcase
assign sclk=sclkt;
endmodule
