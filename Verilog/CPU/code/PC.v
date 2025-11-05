`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/25 10:39:17
// Design Name: 
// Module Name: PC
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


module PC(
    input clk,
    input reset,
    input stall,
    input Branch,
    input [1:0] PCSrc,
    input [31:0] Branch_target,
    input [31:0] Jump_target,
    input [31:0] ID_Databus1,
    output reg [31:0] PC,
    output [31:0] PC_4
    );

    wire [31:0] PC_next = 
        (Branch) ? Branch_target:
        (PCSrc == 2'b01) ? Jump_target:
        (PCSrc == 2'b10) ? ID_Databus1:
        PC_4;

    always @(posedge clk or posedge reset) begin
        if (reset) PC <= 32'h00000000;
        else if (~stall) PC <= PC_next;
    end

    assign PC_4 = PC + 32'd4;

endmodule