`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/23 20:36:19
// Design Name: 
// Module Name: ImmExt
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


module ImmExt(
    input ExtOp,
    input LuiOp,
    input [15:0] Imm,
    output wire [31:0] Ext_out,
    output wire [31:0] Lui_out
    );

    assign Ext_out = {(ExtOp)? {16{Imm[15]}}: 16'h0000, Imm};
    assign Lui_out = LuiOp? {Imm, 16'h0000}: Ext_out;

endmodule

