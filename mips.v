`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 18:53:02
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	output wire memen,
	output wire [3:0]sel
    );
	
	wire [5:0] opD,functD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW,branchD,jumpD,jalD,jrD,balD;
	wire [1:0] hilo_weD;
	wire [4:0] alucontrolE;
	wire flushE,equalD;
	wire stallE;
	wire overflow;
	wire [31:0] instrD;
	controller c(
		.clk(clk),.rst(rst),
		//decode stage
		.instrD(instrD),
		.pcsrcD(pcsrcD),.branchD(branchD),.equalD(equalD),.jumpD(jumpD),.jalD(jalD),.jrD(jrD),.balD(balD),
		
		//execute stage
		.flushE(flushE),
		.stallE(stallE),
		.overflow(overflow),
		.memtoregE(memtoregE),.alusrcE(alusrcE),
		.regdstE(regdstE),.regwriteE(regwriteE),	
		.alucontrolE(alucontrolE),
		
		//mem stage
		.memtoregM(memtoregM),.memwriteM(memwriteM),
		.regwriteM(regwriteM),.memenD(memen),//.sel(sel),
		//write back stage
		.memtoregW(memtoregW),.regwriteW(regwriteW),
		.hilo_we(hilo_weD)

		
		);
	datapath dp(
		.clk(clk),.rst(rst),
		//fetch stage
		.pcF(pcF),
		.instrF(instrF),
		//decode stage
		.pcsrcD(pcsrcD),.branchD(branchD),
		.jumpD(jumpD),.jalD(jalD),.jrD(jrD),.balD(balD),
		.equalD(equalD),
		.opD(opD),.functD(functD),
		.hilo_weD(hilo_weD),
		//execute stage
		.memtoregE(memtoregE),
		.alusrcE(alusrcE),.regdstE(regdstE),
		.regwriteE(regwriteE),
		.alucontrolE(alucontrolE),
		.flushE(flushE),
		.stallE(stallE),
		.overflow(overflow),
		//mem stage
		.memtoregM(memtoregM),
		.regwriteM(regwriteM),
		.aluoutM(aluoutM),.writedata2M(writedataM),
		.readdataM(readdataM),.memen(memen),.sel(sel),
		//writeback stage
		.memtoregW(memtoregW),
		.regwriteW(regwriteW),
		.instrD(instrD)

		
	    );
	
endmodule
