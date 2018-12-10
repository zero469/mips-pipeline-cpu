`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 19:15:42
// Design Name: 
// Module Name: signext
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


module signext(
    input wire[15:0] x,
    input wire[1:0] type,
    output wire[31:0] y
    );
    assign y = (type == 2'b11) ? {{16{1'b0}},x}:{{16{x[15]}}, x}; 
endmodule
