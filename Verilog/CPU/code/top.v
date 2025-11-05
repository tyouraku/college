`timescale 1ns / 1ps

module top(
    input clk,
    input reset, 
    output reg [6:0] BCD,
    output reg [3:0] AN
    );

    wire [31:0] an_bcd;
    
    // output declaration of clk_gen
    wire clk_50M;
    
    clk_gen myclk_gen(
        .clk     	(clk      ),
        .reset   	(reset    ),
        .clk_50M 	(clk_50M  )
    );

    CPU myCPU(
        .reset 	(reset  ),
        .clk   	(clk_50M    ),
        .bcd   	(an_bcd    )
    );
    
    always @(posedge clk or posedge reset)
    begin
        if(reset)
            BCD <= 7'd0;
        else
            BCD <= an_bcd[6:0];
            AN <= an_bcd[11:8];
    end

endmodule

