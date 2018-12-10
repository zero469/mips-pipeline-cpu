`timescale 1ns / 1ps
`include"defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 19:18:05
// Design Name: 
// Module Name: maindec
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


/*
    control[6] RegWire
    control[5] RegDst
    control[4] AluSrc
    control[3] Branch
    control[2] MemWrite
    control[1] MemtoReg
    control[0] Jump  
    
*/

module maindec(
    input wire [5:0] op,
    output reg[6:0] control
    );
    always@(*) begin
        case(op)
            `R_TYPE: control <= 7'b1100000;
            
            `LW:     control <= 7'b1010010;
            `SW:     control <= 7'b0010100; 
            
            `BEQ:    control <= 7'b0001000;
            `BNE:    control <= 7'b0001000;
            `BGTZ:   control <= 7'b0001000;
            `BLEZ:   control <= 7'b0001000;
            `BLTZ:   control <= 7'b0001000;
            `BGEZ:   control <= 7'b0001000;
            
            `ADDI:   control <= 7'b1010000;
            `ANDI:   control <= 7'b1010000;
            `XORI:   control <= 7'b1010000;
            `ORI:    control <= 7'b1010000;
            `LUI:    control <= 7'b1010000;
            `SLTI:   control <= 7'b1010000;
            

            
            `J:      control <= 7'b0000001;
            default: control <= 7'b0000000;
        endcase
    end
endmodule