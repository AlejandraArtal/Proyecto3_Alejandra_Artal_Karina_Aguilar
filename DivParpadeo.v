`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:25:39 04/24/2016 
// Design Name: 
// Module Name:    Disparaparpadeo 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:25:39 04/24/2016 
// Design Name: 
// Module Name:    Disparaparpadeo 
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
module divisor ( clk ,out_clk );

output out_clk ;
reg out_clk ;

input clk ;
wire clk ;

reg [23:0] m; //Necesito 26 digitos binarios para contar hasta 50 millones

initial m = 0;

always @ (posedge (clk)) begin
 if (m<25000000)
  m <= m + 1'b1;
 else   
  m <= 0;
end

always @ (m) begin
 if (m<12500000)
  out_clk <= 1;
 else
  out_clk <= 0;
end
  

endmodule 
