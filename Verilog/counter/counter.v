`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/26 22:21:46
// Design Name: 
// Module Name: counter
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


module counter(
    input clk,
    input reset,
    output reg [3:0] cnt,
    output wire [6:0] leds,
    output [3:0] ano
    );

assign ano=4'b1111;

always @(negedge reset or posedge clk)
begin
    if(~reset) begin
        cnt<=4'b0000;
    end
    else begin
        if(cnt==4'b1001) cnt<=4'b0000;
        else cnt<=cnt+1;
    end
end

BCD7 bcd27seg (cnt,leds);

endmodule

