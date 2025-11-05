`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/23 21:38:20
// Design Name: 
// Module Name: ID_EX
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


module ID_EX(
    input reset,
    input clk,
    input flush,
    input [31:0] PC_4_in,
    input [31:0] instr_in,
    input [31:0] Imm_in,
    input Branch_in,
    input [1:0] BranchOp_in,
    input RegWrite_in,
    input [1:0] RegDst_in,
    input MemRead_in,
    input MemWrite_in,
    input [1:0] MemtoReg_in,
    input ALUSrcA_in,
    input ALUSrcB_in,
    input [3:0] ALUOp_in,
    input [31:0] DatabusA_in,
    input [31:0] DatabusB_in,
    output reg [31:0] PC_4_out,
    output reg [31:0] instr_out,
    output reg [31:0] Imm_out,
    output reg Branch_out,
    output reg [1:0] BranchOp_out,
    output reg RegWrite_out,
    output reg [1:0] RegDst_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg [1:0] MemtoReg_out,
    output reg ALUSrcA_out,
    output reg ALUSrcB_out,
    output reg [3:0] ALUOp_out,
    output reg [31:0] DatabusA_out,
    output reg [31:0] DatabusB_out
);

    always @(posedge reset or posedge clk) begin //整体代码优先级：重置reset>清空flush>阻塞stall>正常执行
        //重置reset
        if(reset) begin
            PC_4_out <= 32'd0;
            instr_out <= 32'd0;
            Imm_out <= 32'd0;
            Branch_out <= 1'd0;
            BranchOp_out <= 2'b11;
            RegWrite_out <= 1'd0;
            RegDst_out <= 2'd0;
            MemRead_out <= 1'd0;
            MemWrite_out <= 1'd0;
            MemtoReg_out <= 2'd0;
            ALUSrcA_out <= 1'd0;
            ALUSrcB_out <= 1'd0;
            ALUOp_out <= 4'd0;
            DatabusA_out <= 32'd0;
            DatabusB_out <= 32'd0;
        end
        //清空flush
        else if(flush) begin
            PC_4_out <= 32'd0;
            instr_out <= 32'd0;
            Imm_out <= 32'd0;
            Branch_out <= 1'd0;
            BranchOp_out <= 2'b11;
            RegWrite_out <= 1'd0;
            RegDst_out <= 2'd0;
            MemRead_out <= 1'd0;
            MemWrite_out <= 1'd0;
            MemtoReg_out <= 2'd0;
            ALUSrcA_out <= 1'd0;
            ALUSrcB_out <= 1'd0;
            ALUOp_out <= 4'd0;
            DatabusA_out <= 32'd0;
            DatabusB_out <= 32'd0;
        end
       //正常执行
        else begin
            PC_4_out <= PC_4_in;
            instr_out <= instr_in;
            Imm_out <= Imm_in;
            Branch_out <= Branch_in;
            BranchOp_out <= BranchOp_in;
            RegWrite_out <= RegWrite_in;
            RegDst_out <= RegDst_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            MemtoReg_out <= MemtoReg_in;
            ALUSrcA_out <= ALUSrcA_in;
            ALUSrcB_out <= ALUSrcB_in;
            ALUOp_out <= ALUOp_in;
            DatabusA_out <= DatabusA_in;
            DatabusB_out <= DatabusB_in;
        end
    end
                        
endmodule
