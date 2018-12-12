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
    input wire[31:0] instr,
    output reg[6:0] control,
    output reg[1:0] hilo_we
    );
    wire [5:0] op,funct;
    assign op = instr[31:26];
    assign funct = instr[5:0];
    always@(*) begin
        case(op)
            `R_TYPE: begin
                control <= 7'b1100000;
                case(funct)
                    `MTHI : hilo_we <=2'b10;
                    `MTLO : hilo_we <=2'b01;
                    `MFHI : hilo_we <=2'b00;
                    `MFLO : hilo_we <=2'b00;
                    `MULT : hilo_we <=2'b11;
                    `MULTU: hilo_we <=2'b11;
                    `DIV  : hilo_we <=2'b11;
                    `DIVU : hilo_we <=2'b11;
                endcase
            end 
            
            
            `LW:     {control,hilo_we} <= 9'b1010010_00;
            `SW:     {control,hilo_we} <= 9'b0010100_00; 
            
            `BEQ:    {control,hilo_we} <= 9'b0001000_00;
            `BNE:    {control,hilo_we} <= 9'b0001000_00;
            `BGTZ:   {control,hilo_we} <= 9'b0001000_00;
            `BLEZ:   {control,hilo_we} <= 9'b0001000_00;
            `BLTZ:   {control,hilo_we} <= 9'b0001000_00;
            `BGEZ:   {control,hilo_we} <= 9'b0001000_00;
            
            `ADDI:   {control,hilo_we} <= 9'b1010000_00;
            `ANDI:   {control,hilo_we} <= 9'b1010000_00;
            `XORI:   {control,hilo_we} <= 9'b1010000_00;
            `ORI:    {control,hilo_we} <= 9'b1010000_00;
            `LUI:    {control,hilo_we} <= 9'b1010000_00;
            `SLTI:   {control,hilo_we} <= 9'b1010000_00;
            `ADDIU:  {control,hilo_we} <= 9'b1010000_00;
            `SLTIU:  {control,hilo_we} <= 9'b1010000_00;
            
            
            `J:      {control,hilo_we} <= 9'b0000001_00;
            default: {control,hilo_we} <= 9'b0000000_00;
        endcase
    end
endmodule