`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:45:29 05/19/2016 
// Design Name: 
// Module Name:    inout 
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
module test(
    input  clk,      // The standard clock
    input  DatoOpc,  // Direction of io, 1 = set output, 0 = read input
    input [7:0] DatoDirIn,    // Data to send out when direction is 1
    output[7:0] DatoDirOut,   // Result of input pin when direction is 0
    inout [7:0] io_port     // The i/o port to send data through
    );

    reg [7:0] a, b;    

    assign io_port  = DatoOpc ? a : 8'bz;
    assign DatoDirOut = b;

    always @ (posedge clk)
    begin
       b <= io_port;
       a <= DatoDirIn;
    end
endmodule
