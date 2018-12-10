`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/08 14:26:18
// Design Name: 
// Module Name: flopenrc
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


module flopenrc
#(
    parameter WIDTH = 32
)
(
    input wire clk,rst,enable,clr,
    input wire [WIDTH -1 : 0] d,
    output reg [WIDTH -1 : 0] q
);
    always@(posedge clk,posedge rst) begin
        if(rst)
            q <= 0;
        else if(clr)
            q <= 0;
        else if(enable)
            q <= d;
    end
endmodule
