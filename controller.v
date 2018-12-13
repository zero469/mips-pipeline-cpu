`timescale 1ns / 1ps
`include"defines.vh"
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
	
	//execute stage
	input wire flushE,stallE,
	input wire overflow,///////-----------------new signal
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[4:0] alucontrolE,

	//mem stage
	output wire memtoregM,memwriteM,
				regwriteM,memenD,
	//output wire [3:0] sel,
	//write back stage
	output wire memtoregW,regwriteW,
	output wire[1:0] hilo_we
 
    );
	
	//decode stage
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD;
	wire memenD,jalD,jrD,balD;
	wire[4:0] alucontrolD;
	wire[5:0]opD,functD;
	assign opD=instrD[31:26];
	assign functD=instrD[5:0];
	//execute stage
	wire memwriteE;
//regwrite,regdst,alusrc,bracn,memen,memtoreg,jump,jal,jr,bal,memwrite;
	maindec md(
		.instr(instrD),
		.control({regwriteD,regdstD,alusrcD,branchD,memenD,memtoregD,jumpD,jalD,jrD,balD,memwriteD}),
		.hilo_we(hilo_we)
		);
	aludec ad(.op(opD),.funct(functD),.alucontrol(alucontrolD));


	assign pcsrcD = branchD & equalD;
	//pipeline registers
	flopenrc #(10) regE(
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE}
		);
	flopr #(3) regM(
		clk,rst,
		{memtoregE,memwriteE,regwriteE & (~overflow)},//overflow cause error
		{memtoregM,memwriteM,regwriteM}
		);
	flopr #(2) regW(
		clk,rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
