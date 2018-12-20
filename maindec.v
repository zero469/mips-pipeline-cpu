`timescale 1ns / 1ps
`include"defines.h"
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
//regwrite,regdst,alusrc,bracn,memen,memtoreg,jump,jal,jr,bal,memwrite;
module maindec(
    input wire[31:0] instr,
    output reg[10:0] control,
    output reg[1:0] hilo_we,
    output wire cp0we,
    output reg invalidD
    );
    wire [5:0] op,funct;
    wire [4:0] rt,rs;
    assign op = instr[31:26];
    assign funct = instr[5:0];
    assign rt = instr[20:16];
    assign rs = instr[25:21];

    assign cp0we = (op == `SPECIAL3_INST && rs == `MTC0) ? 1 : 0;
    always@(*) begin
        invalidD <= 0;
        case(op)
            `R_TYPE: begin
                case(funct)
                    `MTHI : {control,hilo_we} <= 13'b1100_0000_0001_0;
                    `MTLO : {control,hilo_we} <= 13'b1100_0000_0000_1;
                    `MFHI : {control,hilo_we} <= 13'b1100_0000_0000_0;
                    `MFLO : {control,hilo_we} <= 13'b1100_0000_0000_0;
                    `AND,`OR,`XOR,`NOR,`ADD,`ADDU,`SUB,`SUBU,`SLT,`SLTU,`SLL,
				    `SRL,`SRA,`SLLV,`SRLV,`SRAV: {control,hilo_we} <= 13'b1100_0000_0000_0;
                    `MULT : {control,hilo_we} <= 13'b1100_0000_0001_1;
                    `MULTU: {control,hilo_we} <= 13'b1100_0000_0001_1;
                    `DIV  : {control,hilo_we} <= 13'b1100_0000_0001_1;
                    `DIVU : {control,hilo_we} <= 13'b1100_0000_0001_1;
                    `JALR:  {control,hilo_we} <= 13'b1100_0000_1000_0;
                    `JR:    {control,hilo_we} <= 13'b0000_0010_1000_0;
                    
                    `SYSCALL: {control,hilo_we} <= 13'b0000_0000_0000_0;
                    `BREAK  : {control,hilo_we} <= 13'b0000_0000_0000_0;
                   default: invalidD <= 1;
                endcase

            end 
            
            
            `LW:     {control,hilo_we} <= 13'b1010_1100_0000_0;
            `LB:	 {control,hilo_we} <= 13'b1010_1100_0000_0;
            `LBU: 	 {control,hilo_we} <= 13'b1010_1100_0000_0;
            `LH: 	 {control,hilo_we} <= 13'b1010_1100_0000_0;
            `LHU:    {control,hilo_we} <= 13'b1010_1100_0000_0;

            `SW:     {control,hilo_we} <= 13'b0010_1000_0010_0; 
            `SB: 	 {control,hilo_we} <= 13'b0010_1000_0010_0;
            `SH:     {control,hilo_we} <= 13'b0010_1000_0010_0;
            
            `BEQ:    {control,hilo_we} <= 13'b0001_0000_0000_0;
            `BNE:    {control,hilo_we} <= 13'b0001_0000_0000_0;
            `BGTZ:   {control,hilo_we} <= 13'b0001_0000_0000_0;
            `BLEZ:   {control,hilo_we} <= 13'b0001_0000_0000_0;
             
            `REGIMM_INST: 
                case(rt)
                    `BLTZ:   {control,hilo_we} <= 13'b0001_0000_0000_0;
                    `BGEZ:   {control,hilo_we} <= 13'b0001_0000_0000_0;
                    `BLTZAL: {control,hilo_we} <= 13'b1001_0000_0100_0;
                    `BGEZAL: {control,hilo_we} <= 13'b1001_0000_0100_0;
                    default: invalidD <= 1;
                endcase
            `ADDI:   {control,hilo_we} <= 13'b1010_0000_0000_0;
            `ANDI:   {control,hilo_we} <= 13'b1010_0000_0000_0;
            `XORI:   {control,hilo_we} <= 13'b1010_0000_0000_0;
            `ORI:    {control,hilo_we} <= 13'b1010_0000_0000_0;
            `LUI:    {control,hilo_we} <= 13'b1010_0000_0000_0;
            `SLTI:   {control,hilo_we} <= 13'b1010_0000_0000_0;
            `ADDIU:  {control,hilo_we} <= 13'b1010_0000_0000_0;
            `SLTIU:  {control,hilo_we} <= 13'b1010_0000_0000_0;
            
            `J:      {control,hilo_we} <= 13'b0000_0010_0000_0;
            `JAL:    {control,hilo_we} <= 13'b1000_0001_0000_0;

            `SPECIAL3_INST:
                case(rs)
                    `MFC0: {control,hilo_we} <= 13'b1000_0000_0000_0;
                    `MTC0: {control,hilo_we} <= 13'b0000_0000_0000_0;
                    `ERET: {control,hilo_we} <= 13'b0000_0000_0000_0;
                    default: invalidD <= 1;
                endcase

            default: invalidD <= 1;
        endcase
    end
endmodule