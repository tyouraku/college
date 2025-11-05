`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/27 23:46:02
// Design Name: 
// Module Name: detector2
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


module detector2(
    input clk,
    input reset,
    input serial_in,
    output reg pulse,
    output reg [5:0] shift_reg
    );
    
always @(posedge clk or posedge reset) begin
    if (reset) begin
        shift_reg<=0;
        pulse<=1'b0;
    end else begin
        shift_reg={shift_reg[4:0], serial_in};
        pulse<=(shift_reg==6'b101011)?1'b1:1'b0;
    end
end

endmodule