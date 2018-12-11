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
    input wire [4:0] sa,
///...
    input wire [63:0]hilo_oW,
    input wire [63:0]hilo_oM,
    input wire [63:0]hilo_i,
    input wire hilo_wirteM,
    input wire hilo_wirteW,
    output wire hilo_wirteo,
    output wire [31:0]hi_alu_out,
    output wire [31:0]lo_alu_out,
///....
    output wire [31:0] res,
    output wire overflow, zero
     );
     assign res =   (op == `AND_CONTROL) ? a & b:
                    (op == `OR_CONTROL)  ? a | b:
                    (op == `LUI_CONTROL) ? {b[15:0],{16{1'b0}}}:
                    (op == `XOR_CONTROL) ? a ^ b:
                    (op == `NOR_CONTROL) ? ~(a | b):
                    (op == `ADD_CONTROL)  ? $signed(a) + $signed(b):
                    (op == `ADDU_CONTROL) ? a + b:
                    (op == `SUB_CONTROL)  ? $signed(a) - $signed(b):
                    (op == `SUBU_CONTROL) ? a - b:
                    (op == `SLT_CONTROL)  ? (($signed(a) < $signed(b)) ? 32'b1 : 32'b0):
                    (op == `SLTU_CONTROL) ? ((a < b) ? 32'b1 : 32'b0):
                    (op == `SLL_CONTROL)  ? b<<sa:
                    (op == `SRL_CONTROL)  ? b>>sa:
                    (op == `SLLV_CONTROL) ? b << a[4:0]:
                    (op == `SRLV_CONTROL) ? b >> a[4:0]:
                    (op == `SRA_CONTROL)  ? ({32{b[31]}} << (6'd32-{1'b0,sa})) | b>>sa:
                    (op == `SRAV_CONTROL) ? ({32{b[31]}} << (6'd32-{1'b0,a[4:0]})) | b>>a[4:0]:
                    (op == `SLT_CONTROL) ? ((a < b) ? 32'b1 : 32'b0):
///....
                    (op == `MFHI_CONTROL) ? ((hilo_wirteM==1'b1)?hilo_oM[63:32]:((hilo_wirteW==1'b1)?hilo_oW[63:32]:hilo_i[63:32])):
                    (op == `MFLO_CONTROL) ? (hilo_wirteM?hilo_oM[31:0]:hilo_wirteW?hilo_oW[31:0]:hilo_i[31:0]):
///...
                    32'b0;
///...     
     assign {hi_alu_out,lo_alu_out} = (op == `MULT_CONTROL) ? $signed(a) * $signed(b):
                                      (op == `MULTU_CONTROL)? a * b:
                                      64'b0;
     
     assign hilo_wirteo = (op== `MTHI_CONTROL|| op == `MTLO_CONTROL) ? 1'b1 : 1'b0;
///...
     assign overflow = (op == `ADD_CONTROL || op == `SUB_CONTROL) ? ((a[31] & b[31] & (~res[31])) | ((~a[31]) & (~b[31]) & res[31])) : 1'b0;
     assign zero = (res == 32'b0) ? 1 : 0;
endmodule

/*
    add  sub  has overflow
*/ 
