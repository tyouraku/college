`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/23 20:35:55
// Design Name: 
// Module Name: Forwarding
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


module Forwarding(
    input [4:0] WB_target,
    input [4:0] MEM_rt,
    input WB_RegWrite,
    input [4:0] EX_rs,
    input [4:0] EX_rt,
    input [4:0] MEM_target,
    input MEM_RegWrite,
    output Forwarding_MEM,
    output [1:0] Forwarding_EX_1,
    output [1:0] Forwarding_EX_2
    );
    
    assign Forwarding_MEM = (WB_target == MEM_rt) && WB_RegWrite;
    assign Forwarding_EX_1 = (EX_rs == 5'b00000) ? 2'b00 :
                             (MEM_RegWrite && EX_rs == MEM_target) ? 2'b01 : 
                             (WB_RegWrite && EX_rs == WB_target) ? 2'b10 : 
                             2'b00;
    assign Forwarding_EX_2 = (EX_rt == 5'b00000) ? 2'b00 :
                             (MEM_RegWrite && EX_rt == MEM_target) ? 2'b01 : 
                             (WB_RegWrite && EX_rt == WB_target) ? 2'b10 : 
                             2'b00;

endmodule
