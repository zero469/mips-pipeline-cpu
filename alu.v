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
    input wire [1:0] hilo_we,
    input wire [31:0] hi,
    input wire [31:0] lo,
    output reg [31:0]hi_alu_out,
    output reg [31:0]lo_alu_out,
///....
    output reg [31:0] res,
    output wire overflow, zero
     );
     always@(*)begin
        case(op)
            `AND_CONTROL:   res <= a & b;
            `OR_CONTROL:    res <= a | b;
            `LUI_CONTROL:   res <= {b[15:0],{16{1'b0}}};
            `XOR_CONTROL:   res <= a ^ b;
            `NOR_CONTROL:   res <= ~(a | b);
            `ADD_CONTROL:   res <= $signed(a) + $signed(b);
            `ADDU_CONTROL:  res <= a + b;
            `SUB_CONTROL:   res <= $signed(a) - $signed(b);
            `SUBU_CONTROL:  res <= a - b;
            `MULT_CONTROL:  {hi_alu_out,lo_alu_out} <=  $signed(a) * $signed(b);
            `MULTU_CONTROL: {hi_alu_out,lo_alu_out} <=  a * b;
            `SLT_CONTROL:   res <= (($signed(a) < $signed(b)) ?  32'b1 : 32'b0);
            `SLTU_CONTROL:  res <= ((a < b) ? 32'b1 : 32'b0);
            `SLL_CONTROL:   res <= b<<sa;
            `SRL_CONTROL:   res <= b>>sa;
            `SLLV_CONTROL:  res <= b << a[4:0];
            `SRLV_CONTROL:  res <= b >> a[4:0];
            `SRA_CONTROL:   res <= ({32{b[31]}} << (6'd32-{1'b0,sa})) | b>>sa;
            `SRAV_CONTROL:  res <= ({32{b[31]}} << (6'd32-{1'b0,a[4:0]})) | b>>a[4:0];
            `SLT_CONTROL:   res <= ((a < b) ? 32'b1 : 32'b0);
            
            `MTHI_CONTROL:  hi_alu_out <= a;
            `MTLO_CONTROL:  lo_alu_out <= a;
            `MFHI_CONTROL:  res <= hi;
            `MFLO_CONTROL:  res <= lo;
        endcase
     end
     assign overflow = (op == `ADD_CONTROL || op == `SUB_CONTROL) ? ((a[31] & b[31] & (~res[31])) | ((~a[31]) & (~b[31]) & res[31])) : 1'b0;
     assign zero = (res == 32'b0) ? 1 : 0;
endmodule
/*
    add  sub  has overflow
*/ 
