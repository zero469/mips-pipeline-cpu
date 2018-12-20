`timescale 1ns / 1ps
`include"defines.h"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 18:55:02
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire [31:0]instrD,
	output wire pcsrcD,branchD,
	input wire equalD,
	output wire jumpD,jalD,jrD,balD,//jump
	output wire memenD,
	output wire invalidD,
	//execute stage
	input wire flushE,stallE,
	input wire overflow,///////-----------------new signal
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[4:0] alucontrolE,

	//mem stage
	input wire flushM,
	output wire memtoregM,memwriteM,
				regwriteM,memenM,
	output wire cp0weM,
	//write back stage
	input wire flushW,
	output wire memtoregW,regwriteW,
	output wire[1:0] hilo_we
 
    );
	
	//decode stage
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD;
	wire jalD,jrD,balD;
	wire[4:0] alucontrolD;
	wire[5:0]opD,functD;
	wire cp0weD;
	assign opD=instrD[31:26];
	assign functD=instrD[5:0];
	//execute stage
	wire memwriteE;
	wire memenE;
	wire cp0weE;
//regwrite,regdst,alusrc,bracn,memen,memtoreg,jump,jal,jr,bal,memwrite;
	maindec md(
		.instr(instrD),
		.control({regwriteD,regdstD,alusrcD,branchD,memenD,memtoregD,jumpD,jalD,jrD,balD,memwriteD}),
		.hilo_we(hilo_we),
		.cp0we(cp0weD),
		.invalidD(invalidD)
		);
	aludec ad(.instr(instrD),.alucontrol(alucontrolD));


	assign pcsrcD = (branchD | balD) & equalD;
	//pipeline registers
	flopenrc #(12) regE(
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,memenD,alucontrolD,cp0weD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,memenE,alucontrolE,cp0weE}
		);
	floprc #(5) regM(
		clk,rst,flushM,
		{memtoregE,memwriteE,regwriteE & (~overflow),memenE,cp0weE},//overflow cause error
		{memtoregM,memwriteM,regwriteM,memenM,cp0weM}
		);
	floprc #(2) regW(
		clk,rst,flushW,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
