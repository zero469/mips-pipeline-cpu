`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 18:53:51
// Design Name: 
// Module Name: datapath
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


///add overflow signal
module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,jalD,jrD,balD,
	output wire equalD,
	output wire[5:0] opD,functD,
	input wire [1:0]hilo_weD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[4:0] alucontrolE,
	output wire flushE,
	output wire stallE,
	output wire overflow, //-------------------------new signal
	//mem stage
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM,writedata2M,
	input wire[31:0] readdataM,
	input wire memen,
	output [3:0]sel,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	output wire[31:0] instrD
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	//decode stage
	wire [31:0] pcplus4D;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [1:0] forwardhiloE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;
	wire div_ready,div_start;
	wire div_mux_signal;
	wire [31:0] hi_div_outE,lo_div_outE;
	wire [31:0] hi_mux_outE,lo_mux_outE;
	wire [5:0] opE;
	//mem stage
	wire [4:0] writeregM;
	wire [31:0] writedataM;
	wire [5:0] opM;
	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW;
	wire [4:0] saD,saE;

////hilo
	wire [1:0]hilo_weW,hilo_weM,hilo_weE;
	wire [31:0]hi_alu_outM,hi_alu_outW,hi_alu_outE,hiE,hi2E;
	wire [31:0]lo_alu_outM,lo_alu_outW,lo_alu_outE,loE,lo2E;
///hiloend
///jal
	wire jalE,balE,jrE;
	wire [4:0]writereg2E;
	wire [31:0]pcplus8E,aluout2E;
	wire rs_tmp;
	wire [4:0]writereg3E;
///jalend
	//hazard detec tion
	hazard h(
		//fetch stage
		.stallF(stallF),
		//decode stage
		.rsD(rsD),.rtD(rtD),
		.branchD(branchD),.balD(balD),.jumpD(jumpD),
		.forwardaD(forwardaD),.forwardbD(forwardbD),
		.stallD(stallD),
		//execute stage
		.rsE(rsE),.rtE(rtE),
		.writeregE(writeregE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.forwardaE(forwardaE),.forwardbE(forwardbE),
		.flushE(flushE),
		.div_ready(div_ready),
		.div_start(div_start),
		.stallE(stallE),
		.alucontrolE(alucontrolE),
		//mem stage
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
		//write back stage
		.writeregW(writeregW),
		.regwriteW(regwriteW),
		//hilo 
		.hilo_weM(hilo_weM),
		.hilo_weE(hilo_weE),
		.hilo_weW(hilo_weW),
		.forwardhiloE(forwardhiloE)
		);

	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(.a(pcplus4F),.b(pcbranchD),.op(pcsrcD),.out(pcnextbrFD));
	mux2 #(32) pcmux(.a(pcnextbrFD),
		.b({pcplus4D[31:28],instrD[25:0],2'b00}),
		.op(jumpD|jalD),.out(pcnextFD));

	//regfile (operates in decode and writeback)
	regfile rf(.clk(~clk),.we3(regwriteW),.ra1(rsD),.ra2(rtD),.wa3(writeregW),.wd3(resultW),.rd1(srcaD),.rd2(srcbD));///

	//fetch stage logic
	flopenr #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	//decode stage
	wire [39:0] ascii;
	instdec instdec(instrD,ascii);
	flopenr #(32) r1D(clk,rst,~stallD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	signext se(instrD[15:0],instrD[29:28],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];
	//execute stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5) r7e(clk,rst,~stallE,flushE,saD,saE);
	flopenrc #(2) r8E(clk,rst,~stallE,flushE,hilo_weD,hilo_weE);
	//jal,bal
	flopenrc #(3) r9E(clk,rst,~stallE,flushE,{jalD,jrD,balD},{jalE,jrE,balE});
	flopenrc #(32) r10E(clk,rst,~stallE,flushE,pcplus4D+4,pcplus8E); 
	flopenrc #(6) r11E(clk,rst,~stallE,flushE,opD,opE);

	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E); //normal forward
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	
	mux3 #(32) forwardhimux(hiE,hi_alu_outM,hi_alu_outW,forwardhiloE,hi2E);//hilo forward
	mux3 #(32) forwardlomux(loE,lo_alu_outM,lo_alu_outW,forwardhiloE,lo2E);


	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);


	alu alu(.a(srca2E),.b(srcb3E),.op(alucontrolE),.sa(saE),.overflow(overflow),
		.hilo_we(hilo_weE),.hi(hi2E),.lo(lo2E),.res(aluoutE),.hi_alu_out(hi_alu_outE),.lo_alu_out(lo_alu_outE));
	div div(.clk(clk),.rst(rst),.op(alucontrolE),.opdata1_i(srca2E),.opdata2_i(srcb3E),
		    .start_i(div_start),.annul_i(1'b0),.result_o({hi_div_outE,lo_div_outE}),.ready_o(div_ready));
//...hilo mux2 from alu and div
	assign div_mux_signal = (alucontrolE == `DIV_CONTROL | alucontrolE == `DIVU_CONTROL) ? 1'b1 : 1'b0;
	mux2 #(32) hi_out_mux(hi_alu_outE,hi_div_outE,div_mux_signal,hi_mux_outE);
	mux2 #(32) lo_out_mux(lo_alu_outE,lo_div_outE,div_mux_signal,lo_mux_outE);
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);

	//jal,bal
	assign rs_tmp=(writereg2E==5'b00000)?1'b1:1'b0;
	mux2 #(5) wrmux2(writeregE,5'b11111,jalE|balE,writereg2E);
	mux2 #(5) wrmux4(writereg2E,5'b11111, jrE&regdstE&rs_tmp,writereg3E);
	mux2 #(32) wrmux3(aluoutE,pcplus8E,jalE|jrE|balE,aluout2E);
	//jal,bal

	//mem stage
	flopr #(32) r1M(clk,rst,srcb2E,writedataM);
	flopr #(32) r2M(clk,rst,aluout2E,aluoutM);
	flopr #(5) r3M(clk,rst,writereg3E,writeregM);	
	flopr #(32) r4M(clk,rst,hi_mux_outE,hi_alu_outM);
	flopr #(32) r5M(clk,rst,lo_mux_outE,lo_alu_outM);
	flopr #(2) r6M(clk,rst,hilo_weE,hilo_weM);
	flopr #(6) r7M(clk,rst, opE,opM);
	//lw,sw
	wire[31:0] readdata2M;
	wire[1:0] size;
	mem_sel mem_sel(.writedata(writedataM),.addr(aluoutM),.op(opM),.readdata(readdataM),
		            .writedata2(writedata2M),.finaldata(readdata2M),.sel(sel),.size(size));

	//writeback stage
	flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	flopr #(32) r2W(clk,rst,readdata2M,readdataW);
	flopr #(5) r3W(clk,rst,writeregM,writeregW);
	flopr #(2) r4W(clk,rst,hilo_weM,hilo_weW);
	flopr #(32) r5W(clk,rst,hi_alu_outM,hi_alu_outW);
	flopr #(32) r6W(clk,rst,lo_alu_outM,lo_alu_outW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	//hilo_reg
	hilo_reg hilo(clk,rst,hilo_weW,hi_alu_outW[31:0],lo_alu_outW[31:0],hiE[31:0],loE[31:0]);

endmodule
