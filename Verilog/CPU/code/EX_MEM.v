`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/24 10:30:26
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(
    input clk,
    input reset,
    input RegWrite_in,
    input [1:0] RegDst_in,
    input MemWrite_in,
    input MemRead_in,
    input [1:0] MemtoReg_in,
    input [4:0] rt_in,
    input [4:0] rd_in,
    input [31:0] ALUout_in,
    input [31:0] Regdata_in,
    input [31:0] PC_4_in,
    output reg RegWrite_out,
    output reg [1:0] RegDst_out, 
    output reg MemWrite_out,
    output reg MemRead_out,
    output reg [1:0] MemtoReg_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,
    output reg [31:0] ALUout_out,
    output reg [31:0] Regdata_out ,
    output reg [31:0] PC_4_out
    );

    always @(posedge clk or posedge reset) begin //整体代码优先级：重置reset>正常执行
        if(reset) begin //重置reset
            //Control
            RegWrite_out <= 1'b0;
            RegDst_out <= 2'b00;
            MemWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemtoReg_out <= 2'b00;
            //Data
            rt_out <= 5'd0;
            rd_out <= 5'd0;
            ALUout_out <= 32'd0;
            Regdata_out <= 32'd0;
            PC_4_out <= 32'd0;
        end
        //正常执行
        else begin
            //Control
            RegWrite_out <= RegWrite_in;
            RegDst_out <= RegDst_in;
            MemWrite_out <= MemWrite_in;
            MemRead_out <= MemRead_in;
            MemtoReg_out <= MemtoReg_in;
            //Data
            rt_out <= rt_in;
            rd_out <= rd_in;
            ALUout_out <= ALUout_in;
            Regdata_out <= Regdata_in;
            PC_4_out <= PC_4_in;
        end
    end
endmodule
