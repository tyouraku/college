`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/26 23:57:47
// Design Name: 
// Module Name: detector
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


module detector (
    input clk,
    input reset,
    input serial_in,
    output reg pulse,
    output [2:0] leds
);

reg [2:0] current_state, next_state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state<=3'b000;
        pulse<=1'b0;
    end else begin
        current_state<=next_state;
        pulse<=(next_state==3'b110)?1'b1:1'b0;
    end
end

always @(*) begin
    case (current_state)
        3'b000: begin
            if (serial_in==1'b1) next_state = 3'b001;
            else next_state=3'b000;
        end
        3'b001: begin
            if (serial_in==1'b0) next_state=3'b010;
            else next_state=3'b001;
        end
        3'b010: begin
            if (serial_in==1'b1) next_state=3'b011;
            else next_state=3'b000;
        end
        3'b011: begin
            if (serial_in==1'b0) next_state=3'b100;
            else next_state=3'b001;
        end
        3'b100: begin
            if (serial_in==1'b1) next_state=3'b101;
            else next_state=3'b000;
        end
        3'b101: begin
            if (serial_in==1'b1) next_state=3'b110;
            else next_state=3'b100;
        end
        3'b110: begin
            if (serial_in==1'b0) next_state=3'b010;
            else next_state=3'b001;
        end
        default: next_state=3'b000;
    endcase
end

LED led27seg (current_state,leds);

endmodule