`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:40:11 05/30/2016 
// Design Name: 
// Module Name:    DecoLectura 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module DecoLecturaa (cont, dir1);  
input [4:0] cont; 
output reg [7:0] dir1;  
 
always @ * begin
case (cont)
	5'd1 : dir1 = 8'h21; 
	5'd2 : dir1 = 8'h22; 
   5'd3 : dir1 = 8'h23; 
   5'd4 : dir1 = 8'h24; 
   5'd5 : dir1 = 8'h25; 
   5'd6 : dir1 = 8'h26;  
 endcase   
end 
endmodule
