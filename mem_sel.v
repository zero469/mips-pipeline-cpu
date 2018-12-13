`timescale 1ns / 1ps
`include "defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/13 16:06:16
// Design Name: 
// Module Name: mem_sel
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


module mem_sel(
	input wire [31:0] writedata,
	input wire [31:0] addr,//aluoutM
	input wire [5:0] op,
	input wire [31:0] readdata,
	output reg [31:0] writedata2,
	output reg [31:0] finaldata,
	output reg [3:0] sel,
	output reg [1:0] size
    );
	always @(*) begin 
		case(op)

			`LW: begin 
				size <= 2'b10;
				sel <= 4'b0000;
				finaldata <= readdata;
			end
			`LH: begin
				size <= 2'b01;
				sel <= 4'b0000;
				case(addr[1:0])
					2'b10: finaldata <= {{16{readdata[31]}},readdata[31:16]};
					2'b00: finaldata <= {{16{readdata[15]}},readdata[15:0]};
				endcase
			end 
			`LHU: begin
				size <= 2'b01;
				sel <= 4'b0000;
				case(addr[1:0])
					2'b10: finaldata <= {{16{1'b0}},readdata[31:16]};
					2'b00: finaldata <= {{16{1'b0}},readdata[15:0]};
				endcase
			end 
			`LB: begin 
				size <= 2'b00;
				sel <= 4'b0000;
				case(addr[1:0])
					2'b11: finaldata <= {{24{readdata[31]}},readdata[31:24]};
					2'b10: finaldata <= {{24{readdata[23]}},readdata[23:16]};
					2'b01: finaldata <= {{24{readdata[15]}},readdata[15:8]};
					2'b00: finaldata <= {{24{readdata[7]}},readdata[7:0]};
				endcase
			end
			`LBU: begin 
				size <= 2'b00;
				sel <= 4'b0000;
				case(addr[1:0])
					2'b11: finaldata <= {{24{1'b0}},readdata[31:24]};
					2'b10: finaldata <= {{24{1'b0}},readdata[23:16]};
					2'b01: finaldata <= {{24{1'b0}},readdata[15:8]};
					2'b00: finaldata <= {{24{1'b0}},readdata[7:0]};
				endcase
			end
			`SW: begin 
				size <= 2'b10;
				sel <= 4'b1111;
				writedata2 <= writedata;
			end 
			`SH:begin 
				size <= 2'b01;
				writedata2 <= {writedata[15:0],writedata[15:0]};
				case(addr[1:0])
					2'b10: sel <= 4'b1100;
					2'b00: sel <= 4'b0011;
				endcase
			end
				
			`SB:begin 
				size <= 2'b00;
				writedata2 <= {4{writedata[7:0]}};
				case(addr[1:0])
					2'b11: sel <= 4'b1000;
					2'b10: sel <= 4'b0100;
					2'b01: sel <= 4'b0010;
					2'b00: sel <= 4'b0001;
				endcase
			end
				
		endcase
	end
	
endmodule
