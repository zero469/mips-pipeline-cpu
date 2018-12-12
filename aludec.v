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
            `ADDIU : alucontrol <= `ADDU_CONTROL;
            `SLTIU : alucontrol <= `SLTU_CONTROL;
            `R_TYPE: begin
                case(funct)
                    `ADD   : alucontrol <= `ADD_CONTROL;
                    `SUB   : alucontrol <= `SUB_CONTROL;
                    `AND   : alucontrol <= `AND_CONTROL;
                    `OR    : alucontrol <= `OR_CONTROL;
                    `XOR   : alucontrol <= `XOR_CONTROL;
                    `NOR   : alucontrol <= `NOR_CONTROL;
                    `SLT   : alucontrol <= `SLT_CONTROL;
                    `SLL   : alucontrol <= `SLL_CONTROL;
                    `SRL   : alucontrol <= `SRL_CONTROL;
                    `SLLV  : alucontrol <= `SLLV_CONTROL;
                    `SRLV  : alucontrol <= `SRLV_CONTROL;
                    `SRA   : alucontrol <= `SRA_CONTROL;
                    `SRAV  : alucontrol <= `SRAV_CONTROL;
                    `SLTU  : alucontrol <= `SLTU_CONTROL;
                    `ADDU  : alucontrol <= `ADDU_CONTROL;
                    `SUBU  : alucontrol <= `SUBU_CONTROL;

                    `MFHI  : alucontrol <= `MFHI_CONTROL;
                    `MTHI  : alucontrol <= `MTHI_CONTROL;
                    `MFLO  : alucontrol <= `MFLO_CONTROL;
                    `MTLO  : alucontrol <= `MTLO_CONTROL;
                    `MULT  : alucontrol <= `MULT_CONTROL;
                    `MULTU : alucontrol <= `MULTU_CONTROL;

                    `DIV   : alucontrol <= `DIV_CONTROL;
                    `DIVU  : alucontrol <= `DIVU_CONTROL;
                    default  : begin end
                endcase
            end

        endcase
    end
endmodule
