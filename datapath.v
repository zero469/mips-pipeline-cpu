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
	output wire [31:0] pcF,
	input wire  [31:0] instrF,
	//decode stage
	input wire  invalidD,
	input wire  pcsrcD,branchD,
	input wire  jumpD,jalD,jrD,balD,
	output wire equalD,
	output wire [5:0] opD,functD,
	input wire  [1:0]hilo_weD,
	output wire [31:0] instrD,
	//execute stage
	input wire  memtoregE,
	input wire  alusrcE,regdstE,
	input wire  regwriteE,
	input wire  [4:0] alucontrolE,
	output wire flushE,
	output wire stallE,
	output wire overflow, //-------------------------new signal
	//mem stage
	input wire  memtoregM,
	input wire  regwriteM,
	output wire [31:0] aluoutM,writedata2M,
	input wire  [31:0] readdataM,
	input wire  memen,
	output wire [3:0]sel,
	input wire cp0weM,
	output wire flushM,
	//writeback stage
	input wire  memtoregW,
	input wire  regwriteW,
	output wire [31:0] pcW,
	output wire [4:0] writeregW,
	output wire [31:0]resultW,
	output wire flushW
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	wire is_in_delayslotF;
	wire [7:0] exceptF;
	wire flushF;
	//decode stage
	wire [31:0] pcplus4D;
	wire [1:0] forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire [31:0] pcD;
	wire is_in_delayslotD;
	wire [7:0] exceptD;
	wire syscallD,breakD,eretD;
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
	wire [31:0] pcE;
	wire [31:0] cp0_outE,cp0_out2E;
	wire forwardcp0E;
	wire is_in_delayslotE;
	wire [7:0] exceptE;
	//mem stage
	wire [4:0]  writeregM;
	wire [31:0] writedataM;
	wire [5:0]  opM;
	wire [31:0] pcM;
	wire [31:0] resultM;
	wire [4:0] rdM;
	//cp0 var
	wire [31:0] count_o,compare_o,status_o,cause_o,epc_o,config_o,prid_o,badvaddr;
	wire timer_int_o;
	wire is_in_delayslotM;
	wire [31:0] excepttypeM,bad_addrM;
	wire [7:0] exceptM;
	wire [31:0] newpcM;
	//excecption var
	wire adelM,adesM;
	//writeback stage
	wire [4:0] saD,saE;
	wire [1:0]hilo_weW,hilo_weM,hilo_weE;
	wire [31:0]hi_alu_outM,hi_alu_outW,hi_alu_outE,hiE,hi2E;
	wire [31:0]lo_alu_outM,lo_alu_outW,lo_alu_outE,loE,lo2E;

	wire jalE,balE,jrE;
	wire [4:0]writereg2E;
	wire [31:0]pcplus8E,aluout2E;
	wire rs_tmp;
	wire [4:0]writereg3E;
	
	//hazard detec tion
	hazard h(
		//fetch stage
		.stallF(stallF),
		.flushF(flushF),
		//decode stage
		.rsD(rsD),.rtD(rtD),
		.branchD(branchD),.balD(balD),.jumpD(jumpD),
		.jrD(jrD),
		.forwardaD(forwardaD),.forwardbD(forwardbD),
		.stallD(stallD),
		.flushD(flushD),
		//execute stage
		.rsE(rsE),.rtE(rtE),.rdE(rdE),
		.writereg2E(writereg2E),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.forwardaE(forwardaE),.forwardbE(forwardbE),
		.flushE(flushE),
		.div_ready(div_ready),
		.div_start(div_start),
		.stallE(stallE),
		.alucontrolE(alucontrolE),
		.forwardcp0E(forwardcp0E),
		//mem stage
		.rdM(rdM),
		.cp0weM(cp0weM),
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
		.cp0_epcM(epc_o),
		.excepttypeM(excepttypeM),
		.flushM(flushM),
		.newpcM(newpcM),
		//write back stage
		.writeregW(writeregW),
		.regwriteW(regwriteW),
		.flushW(flushW),
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
	wire [31:0] pcnextFD1;
	mux2 #(32) pcmux2(pcnextFD,srca2D,jrD,pcnextFD1);
	//regfile (operates in decode and writeback)
	regfile rf(.clk(~clk),.we3(regwriteW),.ra1(rsD),.ra2(rtD),.wa3(writeregW),.wd3(resultW),.rd1(srcaD),.rd2(srcbD));///
	
	
	//fetch stage logic
	pc #(32) pcreg(clk,rst,~stallF,flushF,pcnextFD1,newpcM,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	assign is_in_delayslotF = jumpD | jrD | branchD | balD | jalD;
	assign exceptF = (pcF[1:0] != 2'b00) ? 8'b10000000 : 8'b00000000;
	//decode stage
	wire [39:0] ascii;
	instdec instdec(instrD,ascii);
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcF,pcD);
	flopenrc #(1)  r4D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);
	flopenrc #(8)  r5D(clk,rst,~stallD,flushD,exceptF,exceptD);

	signext se(instrD[15:0],instrD[29:28],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux4 #(32) forwardamux(srcaD,aluout2E,resultM,resultW,forwardaD,srca2D);
	mux4 #(32) forwardbmux(srcbD,aluout2E,resultM,resultW,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];
	assign syscallD = (opD == 6'b000000 && functD == 6'b001100);
	assign breakD = (opD == 6'b000000 && functD == 6'b001101);
	assign eretD = (instrD == 32'b01000010000000000000000000011000);
	//execute stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5)  r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5)  r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5)  r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5)  r7e(clk,rst,~stallE,flushE,saD,saE);
	flopenrc #(2)  r8E(clk,rst,~stallE,flushE,hilo_weD,hilo_weE);
	//jal,bal
	flopenrc #(4)  r9E(clk,rst,~stallE,flushE,{jalD,jrD,balD,is_in_delayslotD},{jalE,jrE,balE,is_in_delayslotE});
	flopenrc #(32) r10E(clk,rst,~stallE,flushE,pcplus4D+4,pcplus8E); 
	flopenrc #(6)  r11E(clk,rst,~stallE,flushE,opD,opE);
	flopenrc #(32) r12E(clk,rst,~stallE,flushE,pcD,pcE);
	flopenrc #(8)  r13E(clk,rst,~stallE,flushE,
						{exceptD[7],syscallD,breakD,eretD,invalidD,exceptD[2:0]},
						exceptE);

	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E); //normal forward
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	
	mux3 #(32) forwardhimux(hiE,hi_alu_outM,hi_alu_outW,forwardhiloE,hi2E);//hilo forward
	mux3 #(32) forwardlomux(loE,lo_alu_outM,lo_alu_outW,forwardhiloE,lo2E);

	mux2 #(32) forwardcp0mux(cp0_outE,aluoutM,forwardcp0E,cp0_out2E);//cp0 forward


	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);


	alu alu(.a(srca2E),.b(srcb3E),.op(alucontrolE),.sa(saE),.overflow(overflow),
		.hilo_we(hilo_weE),.hi(hi2E),.lo(lo2E),.res(aluoutE),.hi_alu_out(hi_alu_outE),.lo_alu_out(lo_alu_outE),
		.cp0(cp0_out2E));
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
	floprc #(32) r1M(clk,rst,flushM,srcb2E,writedataM);
	floprc #(32) r2M(clk,rst,flushM,aluout2E,aluoutM);
	floprc #(5)  r3M(clk,rst,flushM,writereg3E,writeregM);	
	floprc #(32) r4M(clk,rst,flushM,hi_mux_outE,hi_alu_outM);
	floprc #(32) r5M(clk,rst,flushM,lo_mux_outE,lo_alu_outM);
	floprc #(2)  r6M(clk,rst,flushM,hilo_weE,hilo_weM);
	floprc #(6)  r7M(clk,rst,flushM,opE,opM);
	floprc #(32) r8M(clk,rst,flushM,pcE,pcM);
	floprc #(5)  r9M(clk,rst,flushM,rdE,rdM);
	floprc #(1)  r10M(clk,rst,flushM,is_in_delayslotE,is_in_delayslotM);
	floprc #(8)  r11M(clk,rst,flushM,
					{exceptE[7:3],overflow,exceptE[1:0]},
					exceptM);
	//lw,sw
	wire[31:0] readdata2M;
	wire[1:0] size;
	mem_sel mem_sel(.pc(pcM),
					.writedata(writedataM),
					.addr(aluoutM),
					.op(opM),
					.readdata(readdataM),
		            .writedata2(writedata2M),
					.finaldata(readdata2M),
					.sel(sel),
					.size(size),
				  	.bad_addr(bad_addrM),
					.adelM(adelM),
					.adesM(adesM));
	exception exp(.rst(rst),
				  .except(exceptM),
				  .adel(adelM),//
				  .ades(adesM),//
				  .cp0_status(status_o),
				  .cp0_cause(cause_o),
				  .excepttype(excepttypeM));
	cp0_reg cp0(.clk(clk),
				.rst(rst),
				.we_i(cp0weM),
				.waddr_i(rdM),
				.raddr_i(rdE),
	            .data_i(aluoutM),
				.int_i(6'b0),
				.excepttype_i(excepttypeM),
				.current_inst_addr_i(pcM),
				.is_in_delayslot_i(is_in_delayslotM),
				.bad_addr_i(bad_addrM),//

				.data_o(cp0_outE),
				.count_o(count_o),
				.compare_o(compare_o),
				.status_o(status_o),
				.cause_o(cause_o),
				.epc_o(epc_o),
				.config_o(config_o),
				.prid_o(prid_o),
				.badvaddr(badvaddr),
				.timer_int_o(timer_int_o));

  	mux2 #(32)  resmux(aluoutM,readdata2M,memtoregM,resultM);
	//writeback stage
	// flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	// flopr #(32) r2W(clk,rst,readdata2M,readdataW);
	floprc #(5)  r3W(clk,rst,flushW,writeregM,writeregW);
	floprc #(2)  r4W(clk,rst,flushW,hilo_weM,hilo_weW);
	floprc #(32) r5W(clk,rst,flushW,hi_alu_outM,hi_alu_outW);
	floprc #(32) r6W(clk,rst,flushW,lo_alu_outM,lo_alu_outW);
	floprc #(32) r7w(clk,rst,flushW,pcM,pcW);
	floprc #(32) r8W(clk,rst,flushW,resultM,resultW);
	
	//hilo_reg
	hilo_reg hilo(clk,rst,hilo_weW,hi_alu_outW[31:0],lo_alu_outW[31:0],hiE[31:0],loE[31:0]);

endmodule
