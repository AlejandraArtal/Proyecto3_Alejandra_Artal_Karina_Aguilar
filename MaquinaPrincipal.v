`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:29:28 04/24/2016 
// Design Name: 
// Module Name:    MaquinaPrincipal 
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
module MaquinaPrincipal(
		input wire reset,clk,
		output reg [7:0] DatoDirgIn,
		output reg A_D, R_D,W_R, C_S,
		output wire [7:0] COLOUR_OUT,
		output wire hsync, vsync,
		input wire alarma_signal,
		output wire cien,
		input [7:0] DatoDirOut,
		output reg LecEsc,/* interE,*/
		input Upp,Down, interS, interM,/* interH,*/
		input OpcPico,
		output dclk
    );
wire [7:0] dir;
reg RD, WR, AD, CS, flagIniLec2;
reg [7:0] DatoBasura;
reg [7:0] DatoHoraT,DatoHora,DatoMinT,DatoMin, DatoSeg, DatoSegT,DatoHoraC,DatoMinC, DatoSegC, DatoDiaT, DatoMesT, DatoYearT;//guardar os valores de lectura
wire [7:0] DatoTiempoOut,DatoFechaOut, DatoCronometroOut;
assign cien = clk;
reg EnableLeer;
wire [7:0] DatoDirIn2;
reg [4:0] contador,contador_next,contadors,contadors_next;
reg [20:0] contPrueba;
wire dclk;
// Instantiate the module
clockdiv clockdiv (
    .clk(clk), 
    .dclk(dclk)
    );
// Instantiate the module
DecoLecturaa instance_DecoLectura(
    .cont(contadors_next), 
    .dir1(dir)
    );
// Instantiate the module
VGA VGA (
    .clk(clk), 
    .alarma_signal(alarma_signal), 
    .cambio_dia(8'h12), 
    .cambio_mes(8'h12), 
    .cambio_year(8'h12), 
    .hora_t(DatoHoraT), 
    .hora_c(8'h12), 
    .min_t(DatoMinT), 
    .min_c(8'h12), 
    .seg_t(DatoSeg), 
    .seg_c(8'h12), 
    .COLOUR_OUT(COLOUR_OUT), 
    .hsync(hsync), 
    .vsync(vsync)
    );

// symbolic state declaration 
localparam [5:0] s0 = 6'b00000,s1 = 6'b00001,s2 = 6'b00010, s3 = 6'b00011,/* s4= 5'b00100,*/ s5= 6'b00101, s6 = 6'b00110, 
				s7 = 6'b00111, s8= 6'b01000,s9= 6'b01001, s10 = 6'b01010,s11 = 6'b01011,s12 = 6'b01100,s13 = 6'b01101,
				s14 = 6'b01110,s15 = 6'b01111,s16 = 6'b10000,s17 = 6'b10001,s18 = 6'b10010,s19 = 6'b10011,s20 = 6'b10100,
				s21 = 6'b10101,s22 = 6'b10110,s23 = 6'b10111,s24 = 6'b11000,s25 = 6'b11001,s26 = 6'b11010,s27 = 6'b11011,
				s28 = 6'b11100,s29 = 6'b11101,s30 = 6'b11110,s31 = 6'b11111,s32 = 6'b100000,s33 = 6'b100001,s34 = 6'b100010,
				s35 = 6'b100011,s36 = 6'b100100,s37 = 6'b100101,s38 = 6'b100110,s39 = 6'b100111,s40 = 6'b101000,s41 = 6'b101001,
				s42 = 6'b101010,s43 = 6'b101011,s44 = 6'b101100,s45 = 6'b101101,s46=6'b101110, s47= 6'b101111, s48= 6'b110000,
				s49= 6'b110001; 
// signal declaration 
reg [5:0] state_reg , state_next; 
// state register
	always @(posedge dclk, posedge reset) 
		if (reset ==1'b1) begin
			state_reg <= s0;
			A_D <= 8'b0;
			W_R <= 1'b0;
			R_D <= 1'b0;
			C_S <= 1'b0;
			contador <= 4'b0;
			contadors <= 4'b0;
			DatoSeg <= 8'b0;
			DatoMin <= 8'b0;
			DatoHora <= 8'b0;
			end
		else begin
			state_reg <= state_next;			
			A_D <= AD;
			W_R <= WR;
			R_D <= RD;
			C_S <= CS;
			contador <= contador_next;
			contadors <= contadors_next;
			DatoSeg <= DatoSegT;
			DatoMin <= DatoMinT;
			DatoHora <= DatoHoraT;
		end

// next-state logic and output logic 
	always @ * begin
			state_next = state_reg;
			contador_next = contador;
			contadors_next = contadors;
			DatoSegT = DatoSeg;
			case (state_reg)
				s0: begin // darle tiempo a AD
					if (contador < 5'b10110) begin
						AD= 1'b1;
						state_next= s0;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						WR =
						1'b1;
						RD = 1'b1;
						CS = 1'b1;
						contador_next = contador + 5'b1;
					end
					else if ((contador >= 5'b10110) && (contador < 5'b11000)) begin
						AD= 1'b0;
						state_next= s0;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS = 1'b1;
						contador_next =  contador + 5'b1;
					end
					else begin
						AD= 1'b0;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS = 1'b1;
						contador_next = 5'b0;
						if (OpcPico) begin
							state_next= s1;
						end
						else if (OpcPico == 1'b0) begin
							state_next= s0;
						end
					end
				end
				s1: begin// Asigna la dirección en la que se inicializa el RTC
					if (contador < 5'b0110) begin // tiempo de 50 ns
						state_next = s1;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador +1'b1;
					end
					else if (((contador >= 5'b110)) && (contador < 5'b11000) ) begin //tiempo de 50 ns
						state_next = s1;
						contador_next = contador +1'b1;
						AD = 1'b0;
						DatoDirgIn = 8'h2;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s1;
						AD = 1'b0;
						DatoDirgIn = 8'h2;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador +1'b1;
					end
					else begin
						state_next = s2;
						AD = 1'b1;
						DatoDirgIn = 8'h2;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end 
				s2: begin// RELLENOOOOOO 2, tiempo AD 10ns
					if (contador < 5'b10110) begin// mantener el tiempo en 100ns
						state_next = s2;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000))  begin// sino se mantiene el tiempo se pasa al siguiente estado
						state_next = s2;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
					end
					else   begin// sino se mantiene el tiempo se pasa al siguiente estado
						state_next = s3;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 4'b0;
					end
				end
				s3: begin// inicializa en add. 2 bit 4 en 1
					if (contador < 5'b0110) begin
						state_next = s3;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador +1'b1;
					end
					else if ((contador >= 5'b110) && (contador < 5'b11000) ) begin
						state_next = s3;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'b00010000;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador +1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s3;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'b00010000;//00001000
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next =  contador +1'b1;;
					end
					else  begin
						state_next = s5;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'b00010000;//00001000
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s5:begin// RELLEEENOOO 2, tiempo AD
					if (contador < 5'b10110) begin
						state_next = s5;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						state_next = s5;
						AD = 1'b0;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
					end
						else begin
						state_next = s6;
						AD = 1'b0;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s6: begin// Asigna la dirección en la que se inicializa el RTC
					if (contador < 5'b0110) begin // tiempo de 50 ns
						state_next = s6;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador +1'b1;
					end
					else if (((contador >= 5'b110)) && (contador < 5'b11000) ) begin //tiempo de 50 ns
						state_next = s6;
						contador_next = contador +1'b1;
						AD = 1'b0;
						DatoDirgIn = 8'h2;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s6;
						AD = 1'b0;
						DatoDirgIn = 8'h2;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next 	= contador +1'b1;
					end
					else  begin
						state_next = s7;
						AD = 1'b1;
						DatoDirgIn = 8'h2;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end 
				s7:begin// tiempo AD
					if (contador < 5'b10110) begin
						state_next = s7;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b10110) && (contador < 5'b11000)) begin
						state_next = s7;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
					end
					else begin 
						state_next = s8;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s8:begin// inicialza en add. 2 bit 4 en 0, tiempos escritura dato
					if (contador < 5'b110) begin
						state_next = s8;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110)) && (contador < 5'b11000) ) begin 
						state_next = s8;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'b00000000;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s8;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'b00000000;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else  begin
						state_next = s9;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'b00000000;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s9: begin // RELLENOOOO 2, tiempo AD
					if (contador < 5'b10110) begin
						state_next = s9;
						AD = 1'b1;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador +1'b1;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						state_next = s9;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
					end
					else begin
						state_next = s10;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s10: begin// Direccion Digital Trimming, Tiempo introducir direcciòn
					if (contador < 5'b110) begin
						state_next = s10;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110))&& (contador < 5'b11000) ) begin
						state_next = s10;
						AD = 1'b0;
						DatoDirgIn = 8'h10;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s10;
						AD = 1'b0;
						DatoDirgIn = 8'h10;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else begin
						state_next = s11;
						AD = 1'b1;
						DatoDirgIn = 8'h10;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s11: begin // tiempo AD
					if (contador < 5'b10110) begin
						state_next = s11;
						AD = 1'b1;
						DatoDirgIn = 8'dz;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000))  begin
						state_next = s11;
						AD = 1'b1;
						DatoDirgIn = 8'dz;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
					end
					else  begin
						state_next = s12;
						AD = 1'b1;
						DatoDirgIn = 8'dz;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s12: begin // dato en D2 para el digital trimming, tiempo introducir dato
					if (contador < 5'b110) begin
						state_next = s12;
						AD = 1'b1;
						DatoDirgIn = 8'dz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >=5'b110)) && (contador < 5'b11000)) begin
						state_next = s12;
						AD = 1'b1;
						DatoDirgIn = 8'b11010010;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s12;
						AD = 1'b1;
						DatoDirgIn = 8'b11010010;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else begin
						state_next = s13;
						AD = 1'b1;
						DatoDirgIn = 8'b11010010;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s13: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						CS =1'b1;
						LecEsc = 1'b1;
						contador_next = contador + 1'b1;
						state_next = s13;
					end
					else if ((contador >= 5'b10110) && (contador < 5'b11000))  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s13;
					end
					else  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s14;
					end
				end
				s14: begin// Direccion en 00 para ingresar el valor del frecuency tuning
					if (contador < 5'b110) begin
						state_next = s14;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110))&& (contador < 5'b11000) ) begin
						state_next = s14;
						AD = 1'b0;
						DatoDirgIn = 8'h0;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s14;
						AD = 1'b0;
						DatoDirgIn = 8'h0;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else begin
						state_next = s15;
						AD = 1'b1;
						DatoDirgIn = 8'h0;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s15: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						state_next = s15;
					end
					else if ((contador >= 5'b10110) && (contador < 5'b11000)) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s15;
					end
					else begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s16;
					end
				end
				s16: begin // ingresar Dato en cero en el frecuency tuning
					if (contador < 5'b110) begin
						state_next = s16;
						AD = 1'b1;
						DatoDirgIn = 8'dz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110)) && (contador < 5'b11000)) begin
						state_next = s16;
						AD = 1'b1;
						DatoDirgIn = 8'h00;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s16;
						AD = 1'b1;
						DatoDirgIn = 8'h00;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else begin
						state_next = s17;
						AD = 1'b1;
						DatoDirgIn = 8'h0;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s17: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						CS =1'b1;
						LecEsc = 1'b1;
						contador_next = contador + 1'b1;
						state_next = s17;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000))  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s17;
					end
					else  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s18;
					end
				end
				s18: begin// Direccion en 00 para ingresar el valor del frecuency tuning
					if (contador < 5'b110) begin
						state_next = s18;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110))&& (contador < 5'b11000) ) begin
						state_next = s18;
						AD = 1'b0;
						DatoDirgIn = 8'h0;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010))  begin
						state_next = s18;
						AD = 1'b0;
						DatoDirgIn = 8'h0;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else   begin
						state_next = s19;
						AD = 1'b1;
						DatoDirgIn = 8'h0;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s19: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						state_next = s19;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s19;
					end
					else begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s20;
					end
				end
				s20: begin // ingresar Dato en cero en el frecuency tuning
					if (contador < 5'b110) begin
						state_next = s20;
						AD = 1'b1;
						DatoDirgIn = 8'dz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110)) && (contador < 5'b11000)) begin
						state_next = s20;
						AD = 1'b1;
						DatoDirgIn = 8'd20;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010))  begin
						state_next = s20;
						AD = 1'b1;
						DatoDirgIn = 8'd20;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else  begin
						state_next = s21;
						AD = 1'b1;
						DatoDirgIn = 8'd20;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s21: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						CS =1'b1;
						LecEsc = 1'b1;
						contador_next = contador + 1'b1;
						state_next = s21;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000))  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s21;
					end
					else  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s22;
					end
				end
				s22: begin// Direccion en 00 para ingresar el valor del frecuency tuning
					if (contador < 5'b110) begin
						state_next = s22;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110))&& (contador < 5'b11000) ) begin
						state_next = s22;
						AD = 1'b0;
						DatoDirgIn = 8'h21;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s22;
						AD = 1'b0;
						DatoDirgIn = 8'h21;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else  begin
						state_next = s23;
						AD = 1'b1;
						DatoDirgIn = 8'h21;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s23: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						state_next = s23;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s23;
					end
					else begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s24;
					end
				end
				s24: begin // ingresar Dato en cero en el frecuency tuning
					if (contador < 5'b110) begin
						state_next = s24;
						AD = 1'b1;
						DatoDirgIn = 8'dz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110)) && (contador < 5'b11000)) begin
						state_next = s24;
						AD = 1'b1;
						DatoDirgIn = DatoSeg;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s24;
						AD = 1'b1;
						DatoDirgIn = DatoSeg;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else begin
						state_next = s25;
						AD = 1'b1;
						DatoDirgIn = DatoSeg;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s25: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						CS =1'b1;
						LecEsc = 1'b1;
						contador_next = contador + 1'b1;
						state_next = s25;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000))  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s25;
					end
					else  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s26;
					end
				end
				s26: begin// Direccion en 00 para ingresar el valor del frecuency tuning
					if (contador < 5'b110) begin
						state_next = s26;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110))&& (contador < 5'b11000) ) begin
						state_next = s26;
						AD = 1'b0;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s26;
						AD = 1'b0;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else  begin
						state_next = s27;
						AD = 1'b1;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s27: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						state_next = s27;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s27;
					end
					else begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s28;
					end
				end
				s28: begin // ingresar Dato en cero en el frecuency tuning
					if (contador < 5'b110) begin
						state_next = s28;
						AD = 1'b1;
						DatoDirgIn = 8'dz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110)) && (contador < 5'b11000)) begin
						state_next = s28;
						AD = 1'b1;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s28;
						AD = 1'b1;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else  begin
						state_next = s29;
						AD = 1'b1;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s29: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						CS =1'b1;
						LecEsc = 1'b1;
						contador_next = contador + 1'b1;
						state_next = s29;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000))  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s29;
					end
					else  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s30;
					end
				end
				s30: begin// Direccion en 00 para ingresar el valor del frecuency tuning
					if (contador < 5'b110) begin
						state_next = s30;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110))&& (contador < 5'b11000) ) begin
						state_next = s30;
						AD = 1'b0;
						DatoDirgIn = 8'h0;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010))  begin
						state_next = s30;
						AD = 1'b0;
						DatoDirgIn = 8'h0;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else begin
						state_next = s31;
						AD = 1'b1;
						DatoDirgIn = 8'h0;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s31: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						state_next = s31;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s31;
					end
					else begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s32;
					end
				end
				s32: begin // ingresar Dato en cero en el frecuency tuning
					if (contador < 5'b110) begin
						state_next = s32;
						AD = 1'b1;
						DatoDirgIn = 8'dz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110)) && (contador < 5'b11000)) begin
						state_next = s32;
						AD = 1'b1;
						DatoDirgIn = 8'd20;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010))  begin
						state_next = s32;
						AD = 1'b1;
						DatoDirgIn = 8'd20;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else begin
						state_next = s41;
						AD = 1'b1;
						DatoDirgIn = 8'd20;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
					
				end
				s41: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						CS =1'b1;
						LecEsc = 1'b1;
						contador_next = contador + 1'b1;
						state_next = s41;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000))  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s41;
					end
					else  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s42;
					end
				end
				s42: begin// Direccion en f0 para ingresar el valor del frecuency tuning
					if (contador < 5'b110) begin
						state_next = s42;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110))&& (contador < 5'b11000) ) begin
						state_next = s42;
						AD = 1'b0;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s42;
						AD = 1'b0;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else  begin
						state_next = s44;
						AD = 1'b1;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s44: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						state_next = s44;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s44;
					end
					else begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s45;
					end
				end
				s45: begin 
					if (contador < 5'b110) begin
						state_next = s45;
						AD = 1'b1;
						DatoDirgIn = 8'dz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110)) && (contador < 5'b11000)) begin
						state_next = s45;
						AD = 1'b1;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s45;
						AD = 1'b1;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else begin
						state_next = s33;
						AD = 1'b1;
						DatoDirgIn = 8'd241;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s33: begin // RELLENOOO 2, tiempo AD
					if (contador < 5'b10110) begin
						state_next = s33;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;// ahora estará la información en la memoria para utilizarse
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						//EnableLeer = 1'b0;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						state_next = s33;
						AD = 1'b0;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;// ahora estará la información en la memoria para utilizarse
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 5'b1;
						//EnableLeer = 1'b0;
					end
					else begin
						state_next = s34;
						AD = 1'b0;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;// ahora estará la información en la memoria para utilizarse
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						//EnableLeer = 1'b0;
					end
				end
				s34:begin // ingreso de comando de transferencia para ingresar a memoria de tiempo a leer datos
					if (contador < 5'b110) begin
						state_next = s34;
						AD = 1'b0;
						LecEsc = 1'b1;
						DatoDirgIn = 8'dz;
						WR = 1'b0;// ahora estará la información en la memoria para utilizarse
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
						//EnableLeer = 1'b0;
					end
					else if (((contador >= 5'b110))&& (contador < 5'b11000))  begin
						state_next = s34;
						AD = 1'b0;
						LecEsc = 1'b1;
						DatoDirgIn = 8'd241;
						WR = 1'b0;// ahora estará la información en la memoria para utilizarse
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
						//EnableLeer = 1'b0;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s34;
						AD = 1'b0;
						LecEsc = 1'b1;
						DatoDirgIn = 8'd241;
						WR = 1'b1;// ahora estará la información en la memoria para utilizarse
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						//EnableLeer = 1'b0;
					end
					else begin
						state_next = s35;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'd241;
						WR = 1'b1;// ahora estará la información en la memoria para utilizarse
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						//EnableLeer = 1'b0;
					end
				end
				s35: begin // tiempo AD
					if (contador < 5'b10110) begin
						state_next = s35;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;// ahora estará la información en la memoria para utilizarse
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						//EnableLeer = 1'b0;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						state_next = s35;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;// ahora estará la información en la memoria para utilizarse
						RD = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						//EnableLeer = 1'b0;
					end
					else begin
						state_next = s36;
						AD = 1'b1;
						LecEsc = 1'b1;
						DatoDirgIn = 8'bz;
						WR = 1'b1;// ahora estará la información en la memoria para utilizarse
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						//EnableLeer = 1'b0;
					end
				end
				s36: begin // Despues del comando de transferencia lee un dato
					if (contador < 5'b110) begin
						state_next = s36;
						AD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b0;
						CS =1'b0;
						contador_next = contador + 1'b1;
						//EnableLeer = 1'b0;
					end
					else if (((contador >= 5'b110 )&& contador < 5'b10110)) begin
						state_next = s36;
						AD = 1'b1;
						DatoBasura = DatoDirOut;
						LecEsc = 1'b0;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b0;
						CS =1'b0;
						//EnableLeer = 1'b1;
						contador_next = contador +1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s36;  ////// SALTOOOOOO (original 52)
						AD = 1'b1;
						DatoBasura = DatoDirOut;
						LecEsc = 1'b0;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador +1'b1;
						//EnableLeer = 1'b1;
						//DatoSegT = DatoSegT;
					end
					else  begin
						state_next = s37;  ////// SALTOOOOOO (original 52)
						AD = 1'b1;
						DatoBasura = DatoDirOut;
						LecEsc = 1'b0;
						DatoDirgIn = 8'bz;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						//EnableLeer = 1'b1;
						//DatoSegT = DatoSegT;
					end
				end
				s37: begin//tiempo AD
					if (contador < 5'b101) begin
						state_next = s37;
						AD = 1'b1;
						LecEsc = 1'b0;
						DatoDirgIn = 8'hz;
						DatoBasura = DatoDirOut;
						RD = 1'b1;
						WR = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b101)&& (contador < 5'b10110)) begin
						state_next = s37;
						AD = 1'b1;
						LecEsc = 1'b1 ;
						DatoDirgIn = 8'hz;
						RD = 1'b1;
						WR = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						state_next = s37;
						AD = 1'b0;
						LecEsc = 1'b1;
						DatoDirgIn = 8'hz;
						RD = 1'b1;
						WR = 1'b1;
						CS =1'b1;
						contador_next =  contador + 1'b1;
							if (contadors <= 5'b110) begin
							AD = 1'b0;
						end
						else if (contadors > 5'b110) begin
							AD = 1'b1;
						end
					end
					else begin
						LecEsc = 1'b1;
						RD = 1'b1;
						WR = 1'b1;
						DatoDirgIn = 8'hz;
						CS =1'b1;
						contador_next = 5'b0;
						if (contadors <= 5'b110) begin
							contadors_next = contadors + 1'b1;
							state_next = s38;
							AD = 1'b0;
						end
						else if (contadors > 5'b110) begin
							contadors_next = 5'b0;
							AD = 1'b1;
							if ((interS) || (interM) /*|| (interH)*/) begin
								state_next = s43;
							end
							else begin
								state_next = s33;
							end
						end
					end
				end
				s38:begin//Dirección segundos tiempo
					if (contador < 5'b110) begin
						state_next = s38;
						AD = 1'b0;
						LecEsc = 1'b1;
						RD = 1'b1;
						WR = 1'b0;
						DatoDirgIn = 8'hz;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110)) && (contador < 5'b10110)) begin
						state_next = s38;
						AD = 1'b0;
						LecEsc = 1'b1;
						RD = 1'b1;
						WR = 1'b0;
						DatoDirgIn = dir;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						state_next = s38;
						AD = 1'b0;
						LecEsc = 1'b1;
						RD = 1'b1;
						WR = 1'b1;
						DatoDirgIn = dir;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end	
					else begin
						state_next = s39;
						AD = 1'b0;
						LecEsc = 1'b1;
						RD = 1'b1;
						WR = 1'b1;
						DatoDirgIn = dir;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s39:begin//tiempo AD
					if (contador < 5'b101) begin
						state_next = s39;
						AD = 1'b1;
						LecEsc = 1'b1;
						RD = 1'b1;
						WR = 1'b1;
						DatoDirgIn = dir;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b101)&& (contador < 5'b10110)) begin
						state_next = s39;
						AD = 1'b1;
						LecEsc = 1'b1;
						RD = 1'b1;
						WR = 1'b1;
						DatoDirgIn = 8'hz;
						CS =1'b1;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						state_next = s39;
						AD = 1'b1;
						LecEsc = 1'b1;
						RD = 1'b1;
						WR = 1'b1;
						DatoDirgIn = 8'hz;
						CS =1'b1;
						contador_next =  contador + 5'b1;
					end
					else begin
						state_next = s40;
						AD = 1'b1;
						LecEsc = 1'b1;
						RD = 1'b1;
						WR = 1'b1;
						DatoDirgIn = 8'hz;
						CS =1'b1;
						contador_next = 5'b0;
					end
				end
				s40:begin//Obtención segundos Tiempo
					if (contador < 5'b110) begin
						state_next = s40;
						DatoDirgIn = 8'hz;
						AD = 1'b1;
						LecEsc = 1'b1;
						RD = 1'b0;
						WR = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if (((contador >= 5'b110)) && (contador < 5'b10110)) begin
						state_next = s40;
						AD = 1'b1;
						LecEsc = 1'b0;
						RD = 1'b0;
						WR = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
						if (contadors == 5'b1)
							begin
								DatoSegT = DatoDirOut;
							end
						if (contadors == 5'b10)
							begin
								DatoMinT = DatoDirOut;
							end
						if (contadors == 5'b11)
							begin
								DatoHoraT = DatoDirOut;
							end
						if (contadors == 5'b100)
							begin
								DatoDiaT = DatoDirOut;
							end
						if (contadors == 5'b101)
							begin
								DatoMesT = DatoDirOut;
							end
						if (contadors == 5'b110)
							begin
								DatoYearT = DatoDirOut;
							end
					end
					else  if ((contador >= 5'b10110) && (contador < 5'b11010)) begin
						state_next = s40; /// salto de inicialisación (57 original)
						AD = 1'b1;
						LecEsc = 1'b0;
						RD = 1'b1;
						WR = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						if (contadors == 5'b1)
							begin
								DatoSegT = DatoDirOut;
							end
						if (contadors == 5'b10)
							begin
								DatoMinT = DatoDirOut;
							end
						if (contadors == 5'b11)
							begin
								DatoHoraT = DatoDirOut;
							end
						if (contadors == 5'b100)
							begin
								DatoDiaT = DatoDirOut;
							end
						if (contadors == 5'b101)
							begin
								DatoMesT = DatoDirOut;
							end
						if (contadors == 5'b110)
							begin
								DatoYearT = DatoDirOut;
							end
					end
					else if ((contador >= 5'b11010) && (contador < 5'b1110))   begin
						state_next = s40; /// salto de inicialisación (57 original)
						AD = 1'b1;
						LecEsc = 1'b0;
						RD = 1'b1;
						WR = 1'b1;
						CS =1'b1;
						EnableLeer = 1'b1;
						contador_next = contador + 1'b1;
						if (contadors == 5'b1)
							begin
								DatoSegT = DatoDirOut;
							end
						if (contadors == 5'b10)
							begin
								DatoMinT = DatoDirOut;
							end
						if (contadors == 5'b11)
							begin
								DatoHoraT = DatoDirOut;
							end
						if (contadors == 5'b100)
							begin
								DatoDiaT = DatoDirOut;
							end
						if (contadors == 5'b101)
							begin
								DatoMesT = DatoDirOut;
							end
						if (contadors == 5'b110)
							begin
								DatoYearT = DatoDirOut;
							end
					end
					else   begin
						state_next = s33; /// salto de inicialisación (57 original)
						AD = 1'b1;
						LecEsc = 1'b0;
						RD = 1'b1;
						WR = 1'b1;
						CS =1'b1;
						EnableLeer = 1'b1;
						contador_next = 5'b0;
						contador_next = contador + 1'b1;
						if (contadors == 5'b1)
							begin
								DatoSegT = DatoDirOut;
							end
						if (contadors == 5'b10)
							begin
								DatoMinT = DatoDirOut;
							end
						if (contadors == 5'b11)
							begin
								DatoHoraT = DatoDirOut;
							end
						if (contadors == 5'b100)
							begin
								DatoDiaT = DatoDirOut;
							end
						if (contadors == 5'b101)
							begin
								DatoMesT = DatoDirOut;
							end
						if (contadors == 5'b110)
							begin
								DatoYearT = DatoDirOut;
							end
					end
				end
				s43: begin
				DatoSegT=DatoSegT;
				DatoMinT=DatoMinT;
				/*DatoHoraT=DatoHoraT;*/
					if (interS == 1'b1) begin
						if ((Upp == 1'b1) && (Down == 1'b0)) begin
							state_next = s43;
							if (DatoSeg == 8'h59) begin
								DatoSegT = 8'h0;
							end
							else begin
								DatoSegT = DatoSeg + 8'h1;
							end
						end
						if ((Down == 1'b1) && (Upp == 1'b0)) begin
							state_next = s43;
							if (DatoSeg == 8'h0) begin
								DatoSegT = 8'h59;
							end
							else begin
								DatoSegT = DatoSeg - 8'h1;
							end
						end
						else begin
							state_next = s43;
						end
					end
					if (interM == 1'b1) begin
						if ((Upp == 1'b1) && (Down == 1'b0)) begin
							state_next = s43;
							if (DatoMin == 8'h59) begin
								DatoMinT = 8'h0;
							end
							else begin
								DatoMinT = DatoMin + 8'h1;
							end		
						end
						if ((Down == 1'b1) && (Upp == 1'b0)) begin
							state_next = s43;
							if (DatoMin == 8'h0) begin
								DatoMinT = 8'h59;
							end
							else begin
								DatoMinT = DatoMin - 8'h1;
							end
						end
						else begin
							state_next = s43;
						end
					end
					/*if (interH == 1'b1) begin
						if ((Upp == 1'b1) && (Down == 1'b0)) begin
							state_next = s43;
							if (DatoHora == 8'h24) begin
								DatoHoraT = 8'h0;
							end
							else begin
								DatoHoraT = DatoHora + 8'h1;
							end
							
						end
						if ((Down == 1'b1) && (Upp == 1'b0)) begin
							state_next = s43;
							if (DatoHora == 8'h0) begin
								DatoHoraT = 8'h24;
							end
							else begin
								DatoHoraT = DatoHora - 8'h1;
							end
						end
						else begin
							state_next = s43;
						end
					end*/
					else begin
						state_next = s46;
					end
				end
				
				/////Escribirrr/////////////////////////////////
				s46: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						CS =1'b1;
						LecEsc = 1'b1;
						contador_next = contador + 1'b1;
						state_next = s46;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000))  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s46;
					end
					else  begin
						AD = 1'b0;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc= 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s47;
					end
				end
				s47: begin// Dirección tiempo segundos o minutos
					if (contador < 5'b110) begin
						state_next = s47;
						AD = 1'b0;
						DatoDirgIn = 8'hz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b110) && (contador < 5'b11000)) begin
						AD = 1'b0;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
						if (interS) begin
							state_next = s47;
							DatoDirgIn = 8'h21;
						end
						if (interM) begin
							state_next = s47;
							DatoDirgIn = 8'h22;
						end
					end
					else if ((contador >= 5'b11000) && (contador < 5'b11010)) begin
						AD = 1'b0;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						if (interS) begin
							state_next = s47;
							DatoDirgIn = 8'h21;
						end
						if (interM) begin
							state_next = s47;
							DatoDirgIn = 8'h22;
						end
						/*if (interH) begin
							state_next = s47;
							DatoDirgIn = 8'h23;
						end*/
					end
					else  begin
						AD = 1'b1;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						if (interS) begin
							state_next = s48;
							DatoDirgIn = 8'h21;
						end
						if (interM) begin
							state_next = s48;
							DatoDirgIn = 8'h22;
						end
						/*if (interH) begin
							state_next = s48;
							DatoDirgIn = 8'h23;
						end*/
					end
				end
				s48: begin// tiempo AD
					if (contador < 5'b10110) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						state_next = s48;
					end
					else if ((contador >= 5'b10110)&& (contador < 5'b11000)) begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next =  contador + 5'b1;
						state_next = s48;
					end
					else begin
						AD = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						DatoDirgIn = 8'bz;
						LecEsc = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						state_next = s49;
					end
				end
				s49: begin // ingresar Dato en cero en el frecuency tuning
					if (contador < 5'b110) begin
						state_next = s49;
						AD = 1'b1;
						DatoDirgIn = 8'dz;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
					end
					else if ((contador >= 5'b110) && (contador < 5'b10100)) begin
						AD = 1'b1;
						LecEsc = 1'b1;
						WR = 1'b0;
						RD = 1'b1;
						CS =1'b0;
						contador_next = contador + 1'b1;
						if (interS) begin
							state_next = s49;
							DatoDirgIn = DatoSegT;
						end
						if (interM) begin
							state_next = s49;
							DatoDirgIn = DatoMinT;
						end
						/*if (interH) begin
							state_next = s49;
							DatoDirgIn = DatoHoraT;
						end*/
					end
					else if ((contador >= 5'b10100) && (contador < 5'b11111)) begin	
						AD = 1'b0;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = contador + 1'b1;
						if (interS) begin
							state_next = s49;
							DatoDirgIn = DatoSegT;
						end
						if (interM) begin
							state_next = s49;
							DatoDirgIn = DatoMinT;
						end
						/*if (interH) begin
							state_next = s49;
							DatoDirgIn = DatoHoraT;
						end*/
					end
					else begin
						AD = 1'b0;
						LecEsc = 1'b1;
						WR = 1'b1;
						RD = 1'b1;
						CS =1'b1;
						contador_next = 5'b0;
						if (interS) begin
							state_next = s42;
							DatoDirgIn = DatoSegT;
						end
						/*if (interM) begin
							state_next = s42;
							DatoDirgIn = DatoMinT;
						end*/
					end
				end
				///////////////////////////////////////////////
				default begin
					state_next= s0; 
					contador_next = 5'b0;
					RD = 1'b0;
					WR= 1'b0;
					CS = 1'b0;
					AD = 1'b0;
					DatoDirgIn = 8'h9;
					DatoSegT = 8'h4;  
				end
			endcase
		end
endmodule
