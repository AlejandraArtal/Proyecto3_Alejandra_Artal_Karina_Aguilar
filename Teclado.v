`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:07:47 06/08/2016 
// Design Name: 
// Module Name:    Teclado 
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
module Teclado(
		input clk, reset,
		input ps2c, ps2d,
		output reg [7:0] codigo_letra,
		output reg alarma_signal
    );

wire [7:0] dout;
wire tecla_liberada, rx_done_tick;
reg [7:0] codigo_letra_next;

ps2_rx ps2_rx (
    .clk(clk), 
    .reset(reset), 
    .ps2d(ps2d), 
    .ps2c(ps2c), 
    .rx_en(1'b1), 
    .rx_done_tick(rx_done_tick), 
    .dout(dout)
    );
	 
FiltroFO FiltroFO (
    .clk(clk), 
    .reset(reset), 
    .codigo_tecla(dout), 
    .ready(rx_done_tick), 
    .tecla_liberada(tecla_liberada)
    );
	 
	 // Aqui es donde va la logica que saca a codigo_letra dependiendo de la letra presionada
	 
	 always @ (posedge clk) begin
			codigo_letra <= codigo_letra_next;
	 end
	 
	 always @* begin
	 //condiciones iniciales
			codigo_letra_next=codigo_letra;
			if (rx_done_tick==1'b1 && tecla_liberada==1'b0) begin
				case (dout)
					//Todos los casos dependiendo de las letras que presione
					8'h1d: codigo_letra_next=8'h1d; //letra W
					8'h1a: codigo_letra_next=8'h1a; //letra Z
					8'h1b: codigo_letra_next=8'h1b; //letra S
					8'h3a: codigo_letra_next=8'h3a; //letra M
					8'h33: codigo_letra_next=8'h33; //letra H
					8'h4b: codigo_letra_next=8'h4b; //letra L
				endcase
			end
			else if (tecla_liberada==1'b1)
				codigo_letra_next=1'b0;
	 end
	  
	 always @* begin
		if (dout==8'h2d)
			alarma_signal = 1'b1;
		else alarma_signal = 1'b0;
	 end
	 
endmodule
