`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/28 12:18:29
// Design Name: 
// Module Name: test_cpu
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


module test_cpu();
	
	reg reset   ;
	reg clk     ;
    wire [6:0] BCD;
    wire [3:0] AN;
    
    top mytop(
        .clk   	(clk    ),
        .reset 	(reset  ),
        .BCD   	(BCD    ),
        .AN    	(AN     )
    );
    
	
	initial begin
		reset   = 1;
		clk     = 1;
		#100 reset = 0;
	end
	
	always #5 clk = ~clk;
		
endmodule
