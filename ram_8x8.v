`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:59:52 04/14/2026 
// Design Name: 
// Module Name:    ram_8x8 
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
module ram_8x8(input clk,rst,wr_ena,input [2:0] wr_addr,input [7:0] data_in,input  rd_ena,input [2:0] rd_addr,output reg [7:0] data_out
    );
	 //creating internal memory
	 reg [7:0] mem [7:0];
	 integer i;
	 //reset logic 
	 always@(posedge clk or posedge rst)begin
	 if(rst)begin
	 for(i=0;i<8;i=i+1)
	 mem[i]<=0;
	 end
	 else begin
	 if(wr_ena)
	 mem[wr_addr] <= data_in;
	 else if(rd_ena)
	 data_out <= mem[rd_addr];
	 end
	 end
	 
	
	 


endmodule
