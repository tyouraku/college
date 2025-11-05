`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/24 11:07:13
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(
    input clk,
    input reset,
    input [1:0] MemtoReg_in,
    input RegWrite_in,
    input [31:0] ALUout_in,
    input [31:0] Readdata_in,
    input [31:0] PC_4_in,
    input [4:0] Write_reg_in,
    output reg [1:0] MemtoReg_out,
    output reg RegWrite_out,
    output reg [31:0] ALUout_out,
    output reg [31:0] Readdata_out,
    output reg [31:0] PC_4_out,
    output reg [4:0] Write_reg_out
    );
    
    always @ (posedge clk or posedge reset) begin
        if(reset) begin
            RegWrite_out <= 1'b0;
            MemtoReg_out <= 2'b00; //11?
            ALUout_out <= 32'd0;
            Readdata_out <= 32'd0;
            PC_4_out <= 32'd0;
            Write_reg_out <= 5'd0;
        end
        else begin
            RegWrite_out <= RegWrite_in;
            MemtoReg_out <= MemtoReg_in;
            ALUout_out <= ALUout_in;
            Readdata_out <= Readdata_in;
            PC_4_out <= PC_4_in;
            Write_reg_out <= Write_reg_in;
        end
    end

endmodule
