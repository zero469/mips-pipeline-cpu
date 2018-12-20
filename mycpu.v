`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/14 10:44:41
// Design Name: 
// Module Name: mycpu
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


module mycpu(

	input wire clk,
	input wire resetn,
	input wire int,

	//inst
	output wire inst_sram_en,
	output wire [3:0]inst_sram_wen,
	output wire [31:0]inst_sram_addr,
	output wire [31:0]inst_sram_wdata,
	input wire  [31:0]inst_sram_rdata,

	//mem 
	output wire data_sram_en,
	output wire [3:0]data_sram_wen,
	output wire [31:0]data_sram_addr,
	output wire [31:0]data_sram_wdata,
	input wire  [31:0]data_sram_rdata,

	//debug debug_wb
	output wire [31:0] debug_wb_pc,//pcW
	output wire [3:0] debug_wb_rf_wen,//regwriteW
	output wire [4:0] debug_wb_rf_wnum,//writeregw
	output wire [31:0] debug_wb_rf_wdata//aluoutw

    );


//接口对接
 
	 wire rst;
	 wire[31:0] pcF,pcW;
	 wire[31:0] instrF;
	 wire memwriteM;
	 wire[31:0] aluoutM,writedataM;
	 wire[31:0] readdataM;
	 wire memen,memenM;
	 wire [4:0] writeregW;
	 wire [3:0] sel;
	 wire [31:0] resultW;
	 
	 assign rst = resetn;
	 //
	 assign inst_sram_en = 1'b1;
	 assign inst_sram_wen = 4'b0000;
	 assign inst_sram_addr = pcF;
	 assign inst_sram_wdata = 32'b0;
	 assign instrF = inst_sram_rdata;

	 //
	 assign data_sram_en = memenM;
	 assign data_sram_wen = sel;
	 assign data_sram_addr = aluoutM;
	 assign data_sram_wdata = writedataM;
	 assign readdataM = data_sram_rdata;

	 assign debug_wb_pc = pcW;// to do pcW
	 assign debug_wb_rf_wen = {4{regwriteW}};
	 assign debug_wb_rf_wnum = writeregW;
	 assign debug_wb_rf_wdata = resultW;

//

	
	wire [5:0] opD,functD;
	wire invalidD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW,branchD,jumpD,jalD,jrD,balD;
	wire [1:0] hilo_weD;
	wire [4:0] alucontrolE;
	wire flushE,flushM,flushW,equalD;
	wire stallE;
	wire overflow;
	wire [31:0] instrD;
	wire cp0weM;
	controller c(
		.clk(clk),.rst(rst),
		//decode stage
		.instrD(instrD),
		.pcsrcD(pcsrcD),.branchD(branchD),.equalD(equalD),.jumpD(jumpD),.jalD(jalD),.jrD(jrD),.balD(balD),
		.memenD(memen),
		.invalidD(invalidD),
		//execute stage
		.flushE(flushE),
		.stallE(stallE),
		.overflow(overflow),
		.memtoregE(memtoregE),.alusrcE(alusrcE),
		.regdstE(regdstE),.regwriteE(regwriteE),	
		.alucontrolE(alucontrolE),
		
		//mem stage
		.memtoregM(memtoregM),.memwriteM(memwriteM),
		.regwriteM(regwriteM),.memenM(memenM),
		.cp0weM(cp0weM),
		.flushM(flushM),
		//write back stage
		.memtoregW(memtoregW),.regwriteW(regwriteW),
		.hilo_we(hilo_weD),
		.flushW(flushW)

		
		);
	datapath dp(
		.clk(clk),.rst(rst),
		//fetch stage
		.pcF(pcF),
		.instrF(instrF),
		//decode stage
		.instrD(instrD),
		.pcsrcD(pcsrcD),.branchD(branchD),
		.jumpD(jumpD),.jalD(jalD),.jrD(jrD),.balD(balD),
		.equalD(equalD),
		.opD(opD),.functD(functD),
		.hilo_weD(hilo_weD),
		.invalidD(invalidD),
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
		.cp0weM(cp0weM),
		.flushM(flushM),
		//writeback stage
		.memtoregW(memtoregW),
		.regwriteW(regwriteW),
		.pcW(pcW),
		.writeregW(writeregW),
		.resultW(resultW),
		.flushW(flushW)
		
	    );
	
endmodule
