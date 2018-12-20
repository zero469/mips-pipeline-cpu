`timescale 1ns / 1ps
`include"defines.h"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/08 14:40:02
// Design Name: 
// Module Name: eqcmp
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



module eqcmp(
    input wire[31:0] a,b,
    input wire[5:0]  op,
    input wire[4:0]  rt,
    output reg c
    );
    always @(*) begin 
        case(op)
             `BEQ:  c <= (a == b);
             `BNE:  c <= (a != b);
             `BGTZ: c <= ((a[31] == 1'b0) && (a != `ZeroWord));
             `BLEZ: c <= ((a[31] == 1'b1) || (a == `ZeroWord));
             `REGIMM_INST: begin 
                case(rt)
                    `BLTZ,`BLTZAL: c <= (a[31] == 1'b1);
                    `BGEZ,`BGEZAL: c <= (a[31] == 1'b0) || (a == `ZeroWord);
                  
                endcase
             end

         default: c <= 1'b0;
      endcase
    end
               ////BLTZAL  rs的值小于 0则转移
               /// BGEZAL rs的值大于等于 0则转移 


endmodule

