`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/19 14:48:16
// Design Name: 
// Module Name: exception
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


module exception(
    input wire rst,
    input wire[7:0] except,
    input wire adel,ades,
    input wire[31:0] cp0_status,cp0_cause,
    output reg[31:0] excepttype
    );
    always@(*) begin
        excepttype <= 32'b0;
        if(rst)
            excepttype <= 32'b0;
        else begin
            if(((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00) && (cp0_status[1] == 1'b0) &&(cp0_status[0] == 1'b1))
                //interrupt
                excepttype <= 32'h00000001;
            else if(except[7] == 1'b1 || adel)//adel
                excepttype <= 23'h00000004;
            else if(ades)//ades
                excepttype <= 32'h00000005;
            else if(except[6] == 1'b1)//syscal
                excepttype <= 32'h00000008;
            else if(except[5] == 1'b1)//break
                excepttype <= 32'h00000009;
            else if(except[4] == 1'b1)//eret
                excepttype <= 32'h0000000e;
            else if(except[3] == 1'b1)//invaild
                excepttype <= 32'h0000000a;
            else if(except[2] == 1'b1)//overflow
                excepttype <= 32'h0000000c;
        end
    end
endmodule
