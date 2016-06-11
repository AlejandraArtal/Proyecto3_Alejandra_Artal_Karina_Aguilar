`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:06:04 06/06/2016 
// Design Name: 
// Module Name:    Proyecto3 
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
module Proyecto3(
		input wire reset,clk, /*UPP, DOWNP, LEFTP,RIGHTP,inter1, inter2, inter3,inter4,*/
		output wire A_D, R_D,W_R, C_S,
		output wire [7:0] COLOUR_OUT,
		output wire hsync, vsync,
		//input wire alarma_signal,
		output wire [9:0] pixel_x, pixel_y,
		output wire cien,
		inout  wire [7:0] io_port,
		output wire reloj,
		output wire reset2, 
		input wire ps2d, ps2c
    );
wire [7:0] out_port0, in_port0, port_id0;
wire write_strobe0, alarma_signal;
wire [7:0] codigo_letra;
reg tecla_arriba, tecla_abajo;

// Instantiate the module
RTCF instance_RTCF (
    .reset(reset), 
    .clk(clk), 
    .A_D(A_D), 
    .R_D(R_D), 
    .W_R(W_R), 
    .C_S(C_S), 
	 .UPP(tecla_arriba),
	 .DOWN(tecla_abajo),
    .COLOUR_OUT(COLOUR_OUT), 
    .hsync(hsync), 
    .vsync(vsync), 
    .alarma_signal(alarma_signal), 
    .pixel_x(pixel_x), 
    .pixel_y(pixel_y), 
    .cien(cien), 
    .io_port(io_port), 
    .reloj(reloj), 
    .reset2(reset2), 
    .write_strobe(write_strobe0), 
    .out_port(out_port0), 
    .port_id(port_id0),
	 .dclk(dclk)
    );

// Instantiate the module
MicroControlador instance_MicroControlador (
    .out_port(out_port0), 
    .port_id(port_id0), 
    .write_strobe(write_strobe0), 
    .in_port(codigo_letra), //este es el dato que viene del teclado
    .clk(clk), 
    .reset(reset)
    );

//instaciacion del modulo del teclado
Teclado Teclado (
    .clk(dclk), 
    .reset(reset), 
    .ps2c(ps2c), 
    .ps2d(ps2d), 
    .codigo_letra(codigo_letra),
	 .alarma_signal(alarma_signal)
    );
	 
	always @* begin
		 if (codigo_letra==8'h1d) begin
			tecla_arriba = 1'b1;
			tecla_abajo = 1'b0;
		end
		else if (codigo_letra==8'h1a) begin
			tecla_arriba = 1'b0;
			tecla_abajo = 1'b1;
		end
	end


endmodule
