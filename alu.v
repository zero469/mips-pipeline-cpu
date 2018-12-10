`timescale 1ns / 1ps
`include"defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 19:17:16
// Design Name: 
// Module Name: alu
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


module alu( 
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [4:0] op,
    output wire [31:0] res,
    output wire overflow, zero
     );
     assign res =   (op == `AND_CONTROL) ? a & b:
                    (op == `OR_CONTROL)  ? a | b:
                    (op == `LUI_CONTROL) ? {b[15:0],{16{1'b0}}}:
                    (op == `XOR_CONTROL) ? a ^ b:
                    (op == `NOR_CONTROL) ? ~(a | b):
                    (op == `ADD_CONTROL) ? a + b:
                    (op == `SUB_CONTROL) ? a - b:
                    (op == `SLT_CONTROL) ? ((a < b) ? 32'b1 : 32'b0):
                    32'b0;
     assign overflow = 0;
     assign zero = (res == 32'b0) ? 1 : 0;
endmodule
