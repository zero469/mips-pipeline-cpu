`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 19:23:31
// Design Name: 
// Module Name: aludec
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


module aludec(
    input wire [5:0] op,
    input wire [5:0] funct,
    output reg [4:0] alucontrol
    );

    always@(*) begin
        case (op) 
            `SW    : alucontrol <= `ADD_CONTROL;
            `LW    : alucontrol <= `ADD_CONTROL;
            `BEQ   : alucontrol <= `SUB_CONTROL;
            `ADDI  : alucontrol <= `ADD_CONTROL;
            `ANDI  : alucontrol <= `AND_CONTROL;
            `XORI  : alucontrol <= `XOR_CONTROL;
            `ORI   : alucontrol <= `OR_CONTROL;
            `SLTI  : alucontrol <= `SLT_CONTROL;
            `LUI   : alucontrol <= `LUI_CONTROL;
            `R_TYPE: begin
                case(funct)
                    `ADD: alucontrol <= `ADD_CONTROL;
                    `SUB: alucontrol <= `SUB_CONTROL;
                    `AND: alucontrol <= `AND_CONTROL;
                    `OR : alucontrol <= `OR_CONTROL;
                    `XOR: alucontrol <= `XOR_CONTROL;
                    `NOR: alucontrol <= `NOR_CONTROL;
                    `SLT: alucontrol <= `SLT_CONTROL;
                    default  : begin end
                endcase
            end

        endcase
    end
endmodule
