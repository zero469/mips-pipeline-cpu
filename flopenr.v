`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/08 14:17:15
// Design Name: 
// Module Name: flopenr
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


module flopenr
#(
    parameter WIDTH = 32
)
(
    input wire clk,rst,enable,
    input wire[WIDTH-1:0] d,
    output reg[WIDTH-1:0] q
);

    always@(posedge clk,posedge rst) begin
        if(rst) 
            q <= 0;
        else if(enable)
            q <= d;
    end
endmodule
