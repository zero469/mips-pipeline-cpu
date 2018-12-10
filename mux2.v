`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 18:55:53
// Design Name: 
// Module Name: mux2
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


module mux2
#(
    parameter WIDTH = 32
)
(
    
    input wire[WIDTH-1:0] a,
    input wire[WIDTH-1:0] b,
    input wire op,
    output wire[WIDTH-1:0] out
);

assign out = (op == 0)? a : b;

endmodule
