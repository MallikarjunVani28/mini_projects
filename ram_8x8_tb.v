`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:21:32 04/14/2026
// Design Name:   ram_8x8
// Module Name:   /home/mallikarjun/Desktop/RAM_8x8/ram_8x8_tb.v
// Project Name:  RAM_8x8
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ram_8x8
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ram_8x8_tb;

	// Inputs
	reg clk;
	reg rst;
	reg wr_ena;
	reg [2:0] wr_addr;
	reg [7:0] data_in;
	reg rd_ena;
	reg [2:0] rd_addr;

	// Outputs
	wire [7:0] data_out;

	// Instantiate the Unit Under Test (UUT)
	ram_8x8 uut (
		.clk(clk), 
		.rst(rst), 
		.wr_ena(wr_ena), 
		.wr_addr(wr_addr), 
		.data_in(data_in), 
		.rd_ena(rd_ena), 
		.rd_addr(rd_addr), 
		.data_out(data_out)
	);

	initial begin
		{clk,rst,wr_ena,wr_addr,data_in,rd_ena,rd_addr}=0;
	end
	always #5 clk = ~clk;
	initial begin
	rst = 1;
	#10;
	rst = 0;
	wr_ena = 1;
	wr_addr = 3'b100;
	data_in = 5;
	#10;
	wr_ena = 1;
	wr_addr = 3'b101;
	data_in = 10;
	#10;
	wr_ena = 0;
	rd_ena = 1;
	
	rd_addr = 3'b100;
	#10;
	rd_addr = 3'b101;
	
	
	$finish;
	end
	
      
endmodule

