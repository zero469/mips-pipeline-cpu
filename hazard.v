`timescale 1ns / 1ps
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
    input wire[4:0] rsD,rtD,rsE,rtE,writeregE,writeregM,writeregW,
    input wire branchD,regwriteE,memtoregE,regwriteM,memtoregM,regwriteW,
    output wire stallF,stallD,flushE,
    output reg [1:0]forwardaE,forwardbE,
    output wire forwardaD,forwardbD
    );
    wire lwstall,branchstall;
    always@(*)begin
        if((rsE != 0) && (rsE == writeregM) && regwriteM)
            forwardaE <= 2'b10;
        else if((rsE != 0) && (rsE == writeregW) && regwriteW)
            forwardaE <= 2'b01;
        else
            forwardaE <= 2'b00;
        if((rtE != 0) && (rtE == writeregM) && regwriteM)
            forwardbE <= 2'b10;
        else if((rtE != 0) && (rtE == writeregW) && regwriteW)
            forwardbE <= 2'b01;
        else
            forwardbE <= 2'b00;
    end
    
    assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE;
    
    assign forwardaD = ((rsD != 0) && (rsD == writeregM) && regwriteM);
    assign forwardbD = ((rtD != 0) && (rtD == writeregM) && regwriteM);
 
    
    assign branchstall = (branchD && regwriteE && (writeregE == rsD || writeregE == rtD)) || (branchD && memtoregM && (writeregM == rsD || writeregM == rtD));
                          

    assign stallF = (lwstall || branchstall);
    assign stallD = stallF;
    //assign flushD = stallF;
    assign flushE = stallF;
endmodule
