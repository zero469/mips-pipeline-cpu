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
	output wire jumpD,
	
	//execute stage
	input wire flushE,
	input wire overflow,///////-----------------new signal
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[4:0] alucontrolE,

	//mem stage
	output wire memtoregM,memwriteM,
				regwriteM,
	//write back stage
	output wire memtoregW,regwriteW,
	output wire[1:0] hilo_we
    );
	
	//decode stage
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD;
	wire[4:0] alucontrolD;
	wire[5:0]opD,functD;
	assign opD=instrD[31:26];
	assign functD=instrD[5:0];
	//execute stage
	wire memwriteE;

	maindec md(
		.instr(instrD),
		.control({regwriteD,regdstD,alusrcD,branchD,memwriteD,memtoregD,jumpD}),
		.hilo_we(hilo_we)
		);
	aludec ad(.op(opD),.funct(functD),.alucontrol(alucontrolD));

	assign pcsrcD = branchD & equalD;

	//pipeline registers
	floprc #(10) regE(
		clk,
		rst,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE}
		);
	flopr #(8) regM(
		clk,rst,
		{memtoregE,memwriteE,regwriteE & (~overflow)},//overflow cause error
		{memtoregM,memwriteM,regwriteM}
		);
	flopr #(8) regW(
		clk,rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
