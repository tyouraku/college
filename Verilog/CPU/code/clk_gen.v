`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/02 10:43:00
// Design Name: 
// Module Name: clk_gen
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


module clk_gen(
    input       clk,        // 假设输入 100MHz
    input       reset,
    output reg  clk_50M     // 输出 50MHz
    );

parameter   CNT = 2;

reg count;

always @(posedge clk or posedge reset)
begin
    if(reset) begin
        clk_50M <= 1'b0;
        count <= 1'd0;
    end
    else begin
        count <= (count==CNT-1'd1) ? 16'd0 : count + 16'd1;
        clk_50M <= (count==1'd0) ? ~clk_50M : clk_50M;
    end
end

endmodule
