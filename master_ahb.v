`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:05:57 04/22/2026 
// Design Name: 
// Module Name:    master_ahb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module master_ahb(
//AHB signals
input CLK_MASTER,
input RESET_MASTER,
input HREADY,//output for slave and input for master
input [31:0] HRDATA,//output of slave and input fot the master

//user defined signals
input [31:0] data_top,//input to the master given by the tb
input write_top,//if write_top = 1 -> write operation 
                //if control signal write_top = 0 -> read operation
input [3:0] beat_length,//this signal is used to describe the beat of data from the tb
input ena,//if ena = 1 master will start either write or read operation
input [31:0] addr_top,//base addr given from the testbench
input wrap_ena,//if wrap_ena= 1 it'r wraping burst ot incr burst

//AHB output signal
output [31:0] HADDR,//address bus
output reg HWRITE,//write control signal
output reg [2:0] HSIZE,//used for determining the transfer size
output reg [31:0] HWDATA,//databus
output reg [2:0] HBURST,
output reg [1:0] HTRANS,

//user defined signal(fifo)

output fifo_empty,fifo_full
 );
//fsm related signal
reg [1:0] present_state,next_state;
reg [31:0] addr_internal=32'h0000_0000;
integer i = 0;
reg [3:0] count = 4'b0000;
reg hburst_internal;
reg [31:0] internal_data;//for collecting the read data with slave is sending to us
reg [7:0] wrap_base;
reg [7:0] wrap_boundary;
reg [31:0] previous_address;

//fifo signals
reg [3:0] wr_ptr,rd_ptr;
reg [31:0] mem[14:0];
parameter idle = 3'b000;
parameter write_state_address = 3'b001;
parameter read_state_address = 3'b010;
parameter read_state_data = 3'b011;
parameter write_state_data = 3'b100;


assign fifo_empty = (wr_ptr == rd_ptr);
assign fifo_full = (wr_ptr+1)== rd_ptr;

//fifo reset logic 

always@(posedge CLK_MASTER)begin
if(RESET_MASTER)
begin
for(i=0;i<15;i=i+1)begin
mem[i] <= 0;
wr_ptr <= 0;
rd_ptr <= 0;
end
end
else if(write_top)
begin
mem[wr_ptr]<=data_top;
wr_ptr <= wr_ptr+1'b1;
end
end

//present state logic
always@(posedge CLK_MASTER or posedge RESET_MASTER)begin
if(RESET_MASTER)begin
present_state <= idle;
count<=0;
end

else begin
present_state <= next_state;
if((present_state == write_state_data)&&beat_length == 4 && HREADY == 1 && wrap_ena == 0)
begin
count<=count+1'b1;
rd_ptr <= rd_ptr +1'b1;
addr_internal = addr_internal + 'h4;
end
end
end
//next state logic
always@(*)begin
case(present_state)
idle : begin
HSIZE = 'BX;
HBURST = 'BX;
HTRANS = 2'b00;//master is in idle statte
HWDATA = 'bx;
count = 0;
addr_internal = addr_top;

//logic for write operation
//single incr burst
if(write_top && HREADY && beat_length == 1 && ena && wrap_ena == 0)
begin
next_state = write_state_address;
HBURST = 3'b000;
HWRITE = 1;
end
//logic for incr burst
else if(write_top && HREADY && beat_length == 4 && ena && wrap_ena == 0)
begin
next_state = write_state_address;
HBURST = 3'b011;
HWRITE = 1;
end
end


write_state_address : begin

HSIZE = 3'b010; // 4byte
HWRITE = 1'b1;

if(HBURST == 3'b000)begin
HTRANS = 2'b10;//non seq transfer
next_state = write_state_data;
end

//code for incr4 burst
else if(HBURST == 3'b011)begin
HTRANS = 2'b10;//nonsequential transfer
next_state = write_state_data;
end


end

write_state_data : begin
if(HBURST == 3'b000)
begin
if(HREADY)begin
next_state = idle;
HWDATA = data_top;
end
end


else if(HBURST == 3'b011)//incr4
begin
HWDATA = mem[rd_ptr];
HTRANS = 2'b11;//sequenatial in nature
end

if(count == 3)
next_state = idle;
else
next_state = write_state_data;

end

default : next_state = idle;
endcase
end

assign HADDR = addr_internal;


endmodule
