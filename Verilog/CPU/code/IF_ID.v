`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/23 20:12:03
// Design Name: 
// Module Name: IF_ID
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


module IF_ID(
    input reset,
    input clk,
    input flush,
    input stall,
    input [31:0] instr_in,
    input [31:0] PC_4_in,
    output reg [31:0] instr_out,
    output reg [31:0] PC_4_out
);
    
    always @(posedge reset or posedge clk) begin //整体代码优先级：重置reset>清空flush>阻塞stall>正常执行
        //重置reset
        if(reset) begin
            instr_out <= 32'd0;
            PC_4_out <= 32'd0;
        end
        //清空flush
        else if(flush) begin
            instr_out <= 32'd0;
            PC_4_out <= 32'd0;
        end
        //阻塞stall
        else if(stall) begin
            instr_out <= instr_out;
            PC_4_out <= PC_4_out;
        end
        //正常执行
        else begin
            instr_out <= instr_in;
            PC_4_out <= PC_4_in;
        end
    end

endmodule
