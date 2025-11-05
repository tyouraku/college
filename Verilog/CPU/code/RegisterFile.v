`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/24 11:27:36
// Design Name: 
// Module Name: RegisterFile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RegisterFile( //复用单周期的RegisterFile
	input  reset, 
	input  clk,
	input  RegWrite,
	input  [4:0] Read_register1, 
	input  [4:0] Read_register2, 
	input  [4:0] Write_register,
	input  [31:0] Write_data,
	output [31:0] Read_data1, 
	output [31:0] Read_data2
);

	// RF_data is an array of 32 32-bit registers
	// here RF_data[0] is not defined because RF_data[0] identically equal to 0
	reg [31:0] RF_data[31:1];
	
	// read data from RF_data as Read_data1 and Read_data2
	assign Read_data1 = (Read_register1 == 5'b00000)? 32'h00000000: 
						(Read_register1 == Write_register)? Write_data:
						RF_data[Read_register1];
	assign Read_data2 = (Read_register2 == 5'b00000)? 32'h00000000: 
						(Read_register2 == Write_register)? Write_data:
						RF_data[Read_register2];
	
	integer i;
	// write Wrtie_data to RF_data at clock posedge
	always @(posedge reset or posedge clk)
		if (reset)
			for (i = 1; i < 32; i = i + 1)
				RF_data[i] <= 32'h00000000;
		else if (RegWrite && (Write_register != 5'b00000))
			RF_data[Write_register] <= Write_data;

endmodule
