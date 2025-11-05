`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/24 15:17:40
// Design Name: 
// Module Name: Hazard
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


module Hazard(
    input MemRead_ID_EX,
    input [31:0] instr_ID_EX,
    input [31:0] instr_IF_ID,
    input branch_taken,
    input j,
    input jr,
    output stall_PC,
    output flush_IF_ID,
    output stall_IF_ID,
    output flush_ID_EX
    );

    wire [4:0] Rt_ID_EX = instr_ID_EX[20:16];
    wire [4:0] Rs_IF_ID = instr_IF_ID[25:21];
    wire [4:0] Rt_IF_ID = instr_IF_ID[20:16];
    
    // Load-use冒险检测
    wire load_use_hazard = MemRead_ID_EX && (Rt_ID_EX != 0) && ((Rt_ID_EX == Rs_IF_ID) || (Rt_ID_EX == Rt_IF_ID));

    // 控制冒险检测
    wire control_hazard = j || jr || branch_taken;

    // PC控制 (1=停止，0=正常更新)
    assign stall_PC = load_use_hazard;

    // IF/ID寄存器控制
    assign stall_IF_ID = load_use_hazard;  // 1=冻结
    assign flush_IF_ID = control_hazard;   // 1=清空

    // ID/EX寄存器控制
    assign flush_ID_EX = load_use_hazard || (branch_taken && !j && !jr);  // 1=插入气泡

endmodule
