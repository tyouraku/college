`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/24 14:30:43
// Design Name: 
// Module Name: DataMem
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


module DataMem(
    input         reset, 
    input         clk,
    input         MemRead,
    input         MemWrite,
    input [31:0] Address,
    input [31:0] Write_data,
    output [31:0] Read_data,
    output reg [31:0] BCD
);
    
    parameter RAM_SIZE = 512;      // 512 words (2KB)
    parameter RAM_SIZE_BIT = 9;    // 2^9 = 512;

    reg [31:0] RAM_data [RAM_SIZE - 1:0];
    assign Read_data = MemRead? RAM_data[Address[RAM_SIZE_BIT + 1:2]]: 32'h00000000;
    
    integer i;
    always @(posedge reset or posedge clk) begin
        if (reset) begin         
            // 1. 存储参数
            RAM_data[0] <= 32'h00000003; // M = 3
            RAM_data[1] <= 32'h00000004; // N = 4
            RAM_data[2] <= 32'h00000005; // P = 5
            RAM_data[3] <= 32'h00000004; // S = 4
            
            // 2. values数组 
            RAM_data[4] <= 32'h00000009; // 9
            RAM_data[5] <= 32'h00000007; // 7
            RAM_data[6] <= 32'h0000000f; // 15
            RAM_data[7] <= 32'h00000009; // 9
            
            // 3. col_indices数组 
            RAM_data[8] <= 32'h00000002;   // 2
            RAM_data[9] <= 32'h00000001;   // 1
            RAM_data[10] <= 32'h00000000;   // 0
            RAM_data[11] <= 32'h00000002;   // 2
            
            // 4. row_ptr数组
            RAM_data[12] <= 32'h00000000; // 0
            RAM_data[13] <= 32'h00000001; // 1
            RAM_data[14] <= 32'h00000002; // 2
            RAM_data[15] <= 32'h00000004; // 4
            
            // 5. 稠密矩阵B
            // 第0行
            RAM_data[16] <= 32'h00000001;  // B[0][0] = 1
            RAM_data[17] <= 32'h00000004;  // B[0][1] = 4
            RAM_data[18] <= 32'h00000000;  // B[0][2] = 0
            RAM_data[19] <= 32'h0000000C;  // B[0][3] = 12
            RAM_data[20] <= 32'h0000000B;  // B[0][4] = 11
            
            // 第1行
            RAM_data[21] <= 32'h00000009;  // B[1][0] = 9
            RAM_data[22] <= 32'h00000000;  // B[1][1] = 0
            RAM_data[23] <= 32'h0000000B;  // B[1][2] = 11
            RAM_data[24] <= 32'h00000008;  // B[1][3] = 8
            RAM_data[25] <= 32'h00000002;  // B[1][4] = 2
            
            // 第2行
            RAM_data[26] <= 32'h0000000C; // B[2][0] = 12
            RAM_data[27] <= 32'h00000002; // B[2][1] = 2
            RAM_data[28] <= 32'h0000000B; // B[2][2] = 11
            RAM_data[29] <= 32'h0000000A; // B[2][3] = 10
            RAM_data[30] <= 32'h00000000; // B[2][4] = 0
            
            // 第3行
            RAM_data[31] <= 32'h0000000A; // B[3][0] = 10
            RAM_data[32] <= 32'h0000000C; // B[3][1] = 12
            RAM_data[33] <= 32'h00000000; // B[3][2] = 0
            RAM_data[34] <= 32'h00000001; // B[3][3] = 1
            RAM_data[35] <= 32'h00000009; // B[3][4] = 9

            // 段码表
            RAM_data[36] <= 32'h0000003F;
            RAM_data[37] <= 32'h00000006;
            RAM_data[38] <= 32'h0000005B;
            RAM_data[39] <= 32'h0000004F;
            RAM_data[40] <= 32'h00000066;
            RAM_data[41] <= 32'h0000006D;
            RAM_data[42] <= 32'h0000007D;
            RAM_data[43] <= 32'h00000007;
            RAM_data[44] <= 32'h0000007F;
            RAM_data[45] <= 32'h0000006F;
            RAM_data[46] <= 32'h00000077;
            RAM_data[47] <= 32'h0000007C;
            RAM_data[48] <= 32'h00000039;
            RAM_data[49] <= 32'h0000005E;
            RAM_data[50] <= 32'h00000079;
            RAM_data[51] <= 32'h00000071;

            // 清零内存
            for (i = 52; i < RAM_SIZE; i = i + 1)
                RAM_data[i] <= 32'h00000000;

        end else if (MemWrite) begin
            case (Address)
                32'h40000010:  BCD <= Write_data;
                default: RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
            endcase
        end
    end

endmodule
