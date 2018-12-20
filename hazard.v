`timescale 1ns / 1ps
`include"defines.h"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 19:39:30
// Design Name: 
// Module Name: hazard
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


module hazard(
    input wire[4:0] rsD,rtD,rsE,rtE,rdE,rdM,writereg2E,writeregM,writeregW,
    input wire branchD,regwriteE,memtoregE,regwriteM,memtoregM,regwriteW,balD,jumpD,jrD,
    input wire [1:0]hilo_weM,hilo_weW,hilo_weE,
    input wire [4:0]alucontrolE,
    input wire div_ready,
    input wire cp0weM,
    input wire [31:0] cp0_epcM,excepttypeM,
    output wire div_start,
    output wire stallF,stallD,stallE,flushF,flushD,flushE,flushM,flushW,
    output wire  [1:0]forwardaE,forwardbE,
    output wire [1:0]forwardaD,forwardbD,
    output wire forwardcp0E,
    output wire [1:0]forwardhiloE,
    output reg [31:0]newpcM
    );
    wire lwstall,flush_except;
    // always@(*)begin

    //     if((rsE != 0) && (rsE == writeregM) && regwriteM)
    //         forwardaE <= 2'b10;
    //     else if((rsE != 0) && (rsE == writeregW) && regwriteW)
    //         forwardaE <= 2'b01;
    //     else
    //         forwardaE <= 2'b00;
    //     if((rtE != 0) && (rtE == writeregM) && regwriteM)
    //         forwardbE <= 2'b10;
    //     else if((rtE != 0) && (rtE == writeregW) && regwriteW)
    //         forwardbE <= 2'b01;
    //     else
    //         forwardbE <= 2'b00;
    // end
    assign forwardaE = ((rsE != 0) && (rsE == writeregM) && regwriteM) ? 2'b10 :
                       ((rsE != 0) && (rsE == writeregW) && regwriteW) ? 2'b01 :
                       2'b00;
    assign forwardbE = ((rtE != 0) && (rtE == writeregM) && regwriteM) ? 2'b10 :
                       ((rtE != 0) && (rtE == writeregW) && regwriteW) ? 2'b01 :
                       2'b00;
    assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE;
    //normal forward
    //assign forwardaD = ((rsD != 0) && (rsD == writeregM) && regwriteM);
    assign forwardaD = (rsD == 0) ? 2'b00:
                       (rsD == writereg2E & regwriteE) ? 2'b01:
                       (rsD == writeregM & regwriteM) ? 2'b10:
                       (rsD == writeregW & regwriteW) ?2'b11: 2'b00;
    assign forwardbD = (rtD == 0) ? 2'b00:
                       (rtD == writereg2E & regwriteE) ? 2'b01:
                       (rtD == writeregM & regwriteM) ? 2'b10:
                       (rtD == writeregW & regwriteW) ?2'b11: 2'b00;
    //hilp forward
    assign forwardhiloE =   (hilo_weE==2'b00 & (hilo_weM==2'b10 | hilo_weM==2'b01 | hilo_weM==2'b11))?2'b01:
                            (hilo_weE==2'b00 & (hilo_weW==2'b10 | hilo_weW==2'b01 | hilo_weW==2'b11))?2'b10:
                            2'b00;
    
    assign forwardcp0E = ((rdE!=0)&(rdE == rdM)&(cp0weM))?1'b1:1'b0;
    
    //assign branchstall = ((branchD | jrD | balD )&& regwriteE && (writeregE == rsD || writeregE == rtD)) || (branchD && memtoregM && (writeregM == rsD || writeregM == rtD));
    //div stall
    assign div_start = ((alucontrolE == `DIV_CONTROL) & (div_ready == `DivResultNotReady))  ? 1'b1 : 
                       ((alucontrolE == `DIVU_CONTROL) & (div_ready == `DivResultNotReady)) ? 1'b1 :
                       ((alucontrolE == `DIV_CONTROL) & (div_ready == `DivResultReady))     ? 1'b0 : 
                       ((alucontrolE == `DIVU_CONTROL) & (div_ready == `DivResultReady))    ? 1'b0 :  
                       1'b0;            

    assign stallF = (lwstall | div_start);
    assign stallD = stallF;
    assign stallE = div_start;

    assign flush_except = (excepttypeM != 32'b0);
   
    assign flushF = flush_except;	
	assign flushD = flush_except;
    assign flushE = lwstall | flush_except;
	assign flushM = flush_except;
	assign flushW = flush_except;
    always @(*) begin
		if(excepttypeM != 32'b0) begin
			/* code */
			case (excepttypeM)
				32'h00000001:begin 
					newpcM <= 32'hBFC00380;
				end
				32'h00000004:begin 
					newpcM <= 32'hBFC00380;
				end
				32'h00000005:begin 
					newpcM <= 32'hBFC00380;
				end
				32'h00000008:begin 
					newpcM <= 32'hBFC00380;
				end
				32'h00000009:begin 
					newpcM <= 32'hBFC00380;
				end
				32'h0000000a:begin 
					newpcM <= 32'hBFC00380;
				end
				32'h0000000c:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h0000000d:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h0000000e:begin 
					newpcM <= cp0_epcM;
				end
				default : /* default */;
			endcase
		end
	end


endmodule
