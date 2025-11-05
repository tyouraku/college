`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/24 09:49:09
// Design Name: 
// Module Name: Control
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


module Control(
	input  [5:0] OpCode,
	input  [5:0] Funct,
	output [1:0] PCSrc ,
	output Branch,
	output [1:0] BranchOp,
	output Jump,
	output Jr,
	output RegWrite,
	output [1:0] RegDst,
	output MemRead,
	output MemWrite,
	output [1:0] MemtoReg,
	output ALUSrcA,
	output ALUSrcB,
	output ExtOp,
	output LuiOp,
	output [3:0] ALUOp
);
	
	assign PCSrc = 
		(OpCode == 6'h02 || OpCode == 6'h03)? 2'b01: //j or jal
		(OpCode == 6'h00 && Funct == 6'h08)? 2'b10: //jr
		2'b00; //others
	
	assign Branch = (OpCode == 6'b000100 ||  // beq
                OpCode == 6'b000101 ||  // bne
                OpCode == 6'b000110 ||  // blez
                OpCode == 6'b000111 ||  // bgtz
                OpCode == 6'h0d); // bltz

	// 分支类型编码
	assign BranchOp = (OpCode == 6'b000100) ? 2'b00 :  // beq
                 (OpCode == 6'b000101) ? 2'b01 :  // bne
                 2'b10;                           // blez/bgtz/bltz

	assign Jump = (OpCode == 6'b000010 ||  // j
              OpCode == 6'b000011);   // jal

	assign Jr = (OpCode == 6'b000000 &&   // R-type
            (Funct == 6'b001000 ||   // jr
             Funct == 6'b001001));    // jalr

	assign RegWrite = 
		(OpCode == 6'h2b || OpCode == 6'h04 || OpCode == 6'h02 || (OpCode == 6'h00 && Funct == 6'h08))? 1'b0: //sw, beq, j, jr
		1'b1; //others

	assign RegDst =
		(OpCode == 6'h00 || OpCode == 6'h1c)? 2'b01: //R, mul
		(OpCode == 6'h03)? 2'b10: //jal
		2'b00; //others

	assign MemRead = 
		(OpCode == 6'h23)? 1'b1: //lw
		1'b0; //others

	assign MemWrite = 
		(OpCode == 6'h2b)? 1'b1: //sw
		1'b0; //others

	assign MemtoReg = 
		(OpCode == 6'h23)? 2'b01: //lw
		(OpCode == 6'h03)? 2'b10: //jal
		2'b00; //others

	assign ALUSrcA =
		(OpCode == 6'h00 && (Funct == 6'h00 || Funct == 6'h02 || Funct == 6'h03))? 1'b1: //sll, slrl, sra
		1'b0; //others

	assign ALUSrcB =
		(OpCode == 6'h00 || OpCode == 6'h1c || OpCode == 6'h04)? 1'b0: //R, mul, eq
		1'b1; //others

	assign ExtOp =
		(OpCode == 6'h0c)? 1'b0: //andi
		1'b1; //others

	assign LuiOp = 
		(OpCode == 6'h0f)? 1'b1: //lui
		1'b0; //others
	
	// set ALUOp
	assign ALUOp[2:0] = 
		(OpCode == 6'h00)? 3'b010: 
		(OpCode == 6'h04)? 3'b001: 
		(OpCode == 6'h0c)? 3'b100: 
		(OpCode == 6'h0a || OpCode == 6'h0b)? 3'b101: 
		(OpCode == 6'h1c && Funct == 6'h02)? 3'b110:
		3'b000; //mul
		
	assign ALUOp[3] = OpCode[0];
	
endmodule