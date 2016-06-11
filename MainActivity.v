`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Montvydas Klumbys 
// 
// Create Date:    
// Design Name: 
// Module Name:    MainActivity 
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
module VGA(
   input wire clk,					//clock signal
	input wire alarma_signal,
	input wire [7:0] cambio_dia, cambio_mes, cambio_year, hora_t, hora_c, min_t, min_c, seg_t, seg_c,
   output wire [7:0] COLOUR_OUT,//bit patters for colour that goes to VGA port
   output wire hsync, vsync				//Vertical Synch signal that goes into VGA port
	);
	
	reg DOWNCOUNTER = 0;		//need a downcounter to 25MHz
	
	  // signal declaration. Para el uso de la fontRom
   wire [10:0] rom_addr;
   reg [5:0] char_addr, char_addr_hora_reloj, char_addr_hora_crono; //6 bits que generaran el codigo ASCII
   reg [4:0] row_addr;
   wire [4:0] row_addr_hora_reloj, row_addr_hora_crono;
   reg [3:0] bit_addr;
   wire [3:0] bit_addr_hora_reloj, bit_addr_hora_crono;
   wire [15:0] font_word;
   wire font_bit, hora_reloj, hora_crono;
	
	//instanciacion de la fontROM
font_rom_caracteres font_rom_caracteres (
    .addr(rom_addr), 
    .data(font_word)
    );

		//Downcounter to 25MHz		
	always @(posedge dclk)begin     
		DOWNCOUNTER <= ~DOWNCOUNTER;	//Slow down the counter to 25MHz
	end
	
	//Para imprimir la palabra dia
	parameter fecha = 13'd8064;	//Se representa en 13 bits
	parameter fechaX = 8'd252;		//8 bits
	parameter fechaY = 6'd32;		// 6 bits
	
	//Para la prueba de impresion de reloj
	parameter reloj = 12'd2262;
	parameter relojX = 7'd78;
	parameter relojY = 5'd29;
	
	//Para la prueba de impresion de cronometro
	parameter crono = 13'd4995;
	parameter cronoX = 8'd185;
	parameter cronoY = 5'd27;
	
	//Para la impresion de hora minuto y segundo
	parameter horaEnc = 12'd2560; //encabezado de hora, minuto y segundo
	parameter horaEnc_x = 8'd128;
	parameter horaEnc_y = 5'd20;

	//Para la impresion de hora minuto y segundo del cronometro
	parameter horaEnc2 = 12'd2560; //encabezado de hora, minuto y segundo
	parameter horaEnc_x2 = 8'd128;
	parameter horaEnc_y2 = 5'd20;
	
	//Para la impresion de campana negra
	parameter campanaNegra = 11'd1927; //encabezado de hora, minuto y segundo
	parameter campanaNegra_x = 6'd41;
	parameter campanaNegra_y = 6'd47;
	
	//Para la impresion de campana roja
	parameter campanaRoja = 11'd1927; //encabezado de hora, minuto y segundo
	parameter campanaRoja_x = 6'd41;
	parameter campanaRoja_y = 6'd47;
	
	//Para la impresion de la palabra Ring
	parameter ring = 11'd1197; //encabezado de hora, minuto y segundo
	parameter ring_x = 6'd57;
	parameter ring_y = 5'd21;
	
	//Impresion de digitos numericos *****
	
	parameter font_rom = 11'd575;
	parameter font_rom_x = 5'd25;
	parameter font_rom_y = 6'd23;

	reg [7:0] COLOUR_DATA_fecha [0:fecha-1]; //Esta para la imagen del año
	reg [7:0] COLOUR_DATA_reloj [0:reloj-1]; //Esta para la imagen del reloj
	reg [7:0] COLOUR_DATA_crono [0:crono-1]; //Esta para la imagen del cronometro
	reg [7:0] COLOUR_DATA_horaEnc [0:horaEnc-1]; //Esta para la imagen del hora, min y seg
	reg [7:0] COLOUR_DATA_horaEnc2 [0:horaEnc2-1]; //Esta para la imagen del hora, min y seg
	reg [7:0] COLOUR_DATA_campanaNegra [0:campanaNegra-1]; //Esta para la imagen del ring negro
	reg [7:0] COLOUR_DATA_campanaRoja [0:campanaRoja-1]; //Esta para la imagen del ring rojo
	reg [7:0] COLOUR_DATA_ring [0:ring-1]; //Esta para la imagen de la palabra ring
	reg [7:0] COLOUR_DATA_cero [0:font_rom-1];
	reg [7:0] COLOUR_DATA_uno [0:font_rom-1];
	reg [7:0] COLOUR_DATA_dos [0:font_rom-1];
	reg [7:0] COLOUR_DATA_tres [0:font_rom-1];
	reg [7:0] COLOUR_DATA_cuatro [0:font_rom-1];
	reg [7:0] COLOUR_DATA_cinco [0:font_rom-1];
	reg [7:0] COLOUR_DATA_seis [0:font_rom-1];
	reg [7:0] COLOUR_DATA_siete [0:font_rom-1];
	reg [7:0] COLOUR_DATA_ocho [0:font_rom-1];
	reg [7:0] COLOUR_DATA_nueve [0:font_rom-1];

	reg [7:0] COLOUR_IN;
	wire [19:0] STATE_fecha;
	wire [19:0] STATE_reloj;
	wire [19:0] STATE_crono;
	wire [19:0] STATE_horaEnc;
	wire [19:0] STATE_horaEnc2;
	wire [19:0] STATE_campanaNegra;
	wire [19:0] STATE_campanaRoja;
	wire [19:0] STATE_ring;
	wire [19:0] STATE_dia_uno;
	wire [19:0] STATE_dia_dos;
	wire [19:0] STATE_mes_uno;
	wire [19:0] STATE_mes_dos;
	wire [19:0] STATE_year_uno;
	wire [19:0] STATE_year_dos;
	wire [19:0] STATE_year_tres;
	wire [19:0] STATE_year_cuatro;
	wire TrigRefresh;			//Trigger gives a pulse when displayed refreshed
	wire [9:0] ADDRH;			//wire for getting Horizontal pixel value
	wire [8:0] ADDRV;			//wire for getting vertical pixel value
	wire dclk, parpadeo;   //los divisores para la frecuencia general y para la generacion del parpadeo
	
	//VGA Interface gets values of ADDRH & ADDRV and by puting COLOUR_IN, gets valid output COLOUR_OUT
	//Also gets a trigger, when the screen is refreshed
	
	//Instanciaciones de modulos
	
	//Divisor de frecuencia para obtener un reloj de 50 MHz
	clockdiv clockdiv (
				 .clk(clk), 
				 .dclk(dclk)
				 );
				 
	divisor divisor (
				 .clk(dclk), 
				 .out_clk(parpadeo)
				 );
				 
	VGAInterface VGA(
				.CLK(dclk),
			   .COLOUR_IN (COLOUR_IN),
				.COLOUR_OUT(COLOUR_OUT),
				.HS(hsync),
				.VS(vsync),
				.REFRESH(TrigRefresh),
				.ADDRH(ADDRH),
				.ADDRV(ADDRV),
				.DOWNCOUNTER(DOWNCOUNTER)
				);
		
	//Impresion dia
	wire [10:0]X_fecha = 10'd194;
	wire [9:0]Y_fecha = 9'd35;
		
	//Prueba Impresion Reloj
	wire [10:0]X_reloj = 10'd83;
	wire [9:0]Y_reloj = 9'd180;
	
	//Prueba Impresion Crono
	wire [10:0]X_crono = 10'd400;
	wire [9:0]Y_crono = 9'd180;
	
	//Impresion encabezado hora, minuto, segundo
	wire [10:0]X_horaEnc = 10'd58;
	wire [9:0]Y_horaEnc = 9'd285;
		
	//Impresion encabezado hora, minuto, segundo
	wire [10:0]X_horaEnc2 = 10'd427;
	wire [9:0]Y_horaEnc2 = 9'd285;
	
	//Impresion campana negra
	wire [10:0]X_campanaNegra = 10'd478;
	wire [9:0]Y_campanaNegra = 9'd370;
	
	//Impresion campana roja
	wire [10:0]X_campanaRoja = 10'd478;
	wire [9:0]Y_campanaRoja = 9'd370;
	
	//Impresion palabra ring
	wire [10:0]X_ring = 10'd528;
	wire [9:0]Y_ring = 9'd380;
	
	//******* Se requiere hacer registros de posiciones para cada parte del dia. Por el momento realizare solamente las posiciones para los dos digitos primeros del dia
	
	//Digito uno del dia
	wire [10:0] X_dia_uno = 200;
	wire [9:0] Y_dia_uno = 87;
	
	//Digito dos del dia
	wire [10:0] X_dia_dos = 224;
	wire [9:0] Y_dia_dos = 87;
	
	//Digito uno del mes
	wire [10:0] X_mes_uno = 290;
	wire [9:0] Y_mes_uno = 87;
	
	//Digito dos del mes
	wire [10:0] X_mes_dos = 315;
	wire [9:0] Y_mes_dos = 87;
	
	//Digito uno del año
	wire [10:0] X_year_uno = 360;
	wire [9:0] Y_year_uno = 87;
	
	//Digito dos del año
	wire [10:0] X_year_dos = 385;
	wire [9:0] Y_year_dos = 87;
	
	//Digito uno del año
	wire [10:0] X_year_tres = 409;
	wire [9:0] Y_year_tres = 87;
	
	//Digito dos del año
	wire [10:0] X_year_cuatro = 433;
	wire [9:0] Y_year_cuatro = 87;
	
	//La impresion de dia
	initial
	$readmemh ("Fecha.list", COLOUR_DATA_fecha);
	
	//Prueba impresion de reloj
	initial
	$readmemh ("Reloj.list", COLOUR_DATA_reloj);
	
	//Prueba impresion de cronometro
	initial
	$readmemh ("Cronometro.list", COLOUR_DATA_crono);
	
	//impresion de hora, min y seg
	initial
	$readmemh ("HoraEncabezado.list", COLOUR_DATA_horaEnc);
	
	initial
	$readmemh ("HoraEncabezado.list", COLOUR_DATA_horaEnc2);
	
	//impresion de campana negra
	initial
	$readmemh ("campanaNegra.list", COLOUR_DATA_campanaNegra);
	
	//impresion de campana roja
	initial
	$readmemh ("campanaRoja.list", COLOUR_DATA_campanaRoja);
	
	//impresion de ring
	initial
	$readmemh ("Ring.list", COLOUR_DATA_ring);
	
	//impresion de digito cero de fecha
	initial
	$readmemh ("Cero.list", COLOUR_DATA_cero);
	
	//impresion de digito uno de fecha
	initial
	$readmemh ("Uno.list", COLOUR_DATA_uno);
	
	//impresion de digito dos de fecha
	initial
	$readmemh ("Dos.list", COLOUR_DATA_dos);
	
	//impresion de digito tres de fecha
	initial
	$readmemh ("Tres.list", COLOUR_DATA_tres);
	
	//impresion de digito cuatro de fecha
	initial
	$readmemh ("Cuatro.list", COLOUR_DATA_cuatro);
	
	//impresion de digito cinco de fecha
	initial
	$readmemh ("Cinco.list", COLOUR_DATA_cinco);
	
	//impresion de digito seis de fecha
	initial
	$readmemh ("Seis.list", COLOUR_DATA_seis);
	
	//impresion de digito siete de fecha
	initial
	$readmemh ("Siete.list", COLOUR_DATA_siete);
	
	//impresion de digito ocho de fecha
	initial
	$readmemh ("Ocho.list", COLOUR_DATA_ocho);
	
	//impresion de digito nueve de fecha
	initial
	$readmemh ("Nueve.list", COLOUR_DATA_nueve);
	
	assign STATE_fecha = ((ADDRH-X_fecha)*fechaY)+ADDRV-Y_fecha;
	assign STATE_reloj = ((ADDRH-X_reloj)*relojY)+ADDRV-Y_reloj; //X_reloj y Y_reloj son las posiciones donde se espera que sea impreso
	assign STATE_crono = ((ADDRH-X_crono)*cronoY)+ADDRV-Y_crono;
	assign STATE_horaEnc = ((ADDRH-X_horaEnc)*horaEnc_y)+ADDRV-Y_horaEnc;
	assign STATE_horaEnc2 = ((ADDRH-X_horaEnc2)*horaEnc_y2)+ADDRV-Y_horaEnc2;
	assign STATE_campanaNegra = ((ADDRH-X_campanaNegra)*campanaNegra_y)+ADDRV-Y_campanaNegra;
	assign STATE_campanaRoja = ((ADDRH-X_campanaRoja)*campanaRoja_y)+ADDRV-Y_campanaRoja;
	assign STATE_ring = ((ADDRH-X_ring)*ring_y)+ADDRV-Y_ring;
	assign STATE_dia_uno = ((ADDRH-X_dia_uno)*font_rom_y)+ADDRV-Y_dia_uno;
	assign STATE_dia_dos = ((ADDRH-X_dia_dos)*font_rom_y)+ADDRV-Y_dia_dos;
	assign STATE_mes_uno = ((ADDRH-X_mes_uno)*font_rom_y)+ADDRV-Y_mes_uno;
	assign STATE_mes_dos = ((ADDRH-X_mes_dos)*font_rom_y)+ADDRV-Y_mes_dos;
	assign STATE_year_uno = ((ADDRH-X_year_uno)*font_rom_y)+ADDRV-Y_year_uno;
	assign STATE_year_dos = ((ADDRH-X_year_dos)*font_rom_y)+ADDRV-Y_year_dos;
	assign STATE_year_tres = ((ADDRH-X_year_tres)*font_rom_y)+ADDRV-Y_year_tres;
	assign STATE_year_cuatro = ((ADDRH-X_year_cuatro)*font_rom_y)+ADDRV-Y_year_cuatro;
	
	//para las impresiones de la fontROM
	assign hora_reloj = (ADDRV[8:5]==7) && (2<=ADDRH[9:4]&&15>ADDRH[9:4]); //Se define el tamaño
	//del contenido en la cantidad de bits que se toma, y se define en cual cuadricula se desea imprimir
	//En este caso X se limita de 0 a 11 porque se imprimiran 12 caracteres en dicho espacio
   assign row_addr_hora_reloj = ADDRV[4:0];
   assign bit_addr_hora_reloj = ADDRH[3:0];
	
	always@* 
	//Imprime desde el pixel 224 hasta el 416
		case (ADDRH[9:4]) //Esto depende de la definicion de pixeles por cuadricula que se haya especificado
		//se debe ver cuales son los pixeles que me dan el numero de filas
		//por el momento se definira en el borde
			6'h2: begin
					if(hora_t>=4'h0&&hora_t<=4'h9) begin
						char_addr_hora_reloj = 6'h0; //0
					end
					else if(hora_t>=8'h10&&hora_t<=8'h19) begin
						char_addr_hora_reloj = 6'h1; //1
					end
					else char_addr_hora_reloj = 6'h2; //Si la hora es de 20 a 23
					end
			6'h3: begin
					if(hora_t==4'h1||hora_t==8'h11||hora_t==8'h21)
						char_addr_hora_reloj = 6'h1;	 //1
					else if(hora_t==4'h2||hora_t==8'h12||hora_t==8'h22)
						char_addr_hora_reloj = 6'h2; //2
					else if(hora_t==4'h3||hora_t==8'h13||hora_t==8'h23)
						char_addr_hora_reloj = 6'h3; //3
					else if(hora_t==4'h4||hora_t==8'h14)
						char_addr_hora_reloj = 6'h4; //4
					else if(hora_t==4'h5||hora_t==8'h15)
						char_addr_hora_reloj = 6'h5; //5
					else if(hora_t==4'h6||hora_t==8'h16)
						char_addr_hora_reloj = 6'h6; //6
					else if(hora_t==4'h7||hora_t==8'h17)
						char_addr_hora_reloj = 6'h7; //7
					else if(hora_t==4'h8||hora_t==8'h18)
						char_addr_hora_reloj = 6'h8; //8
					else if(hora_t==8'h20||hora_t==8'h10)
						char_addr_hora_reloj = 6'h0; //0
					else char_addr_hora_reloj = 6'h9; //9
					end
			6'h4: char_addr_hora_reloj = 6'hb; //Esta es espacio en blanco
			6'h5: char_addr_hora_reloj = 6'ha; //Esto son dos puntos
			6'h6: char_addr_hora_reloj = 6'hb; //Esto es espacio en blanco
			6'h7: begin //Primer caracter de los minutos
					if (min_t>=4'h0&&min_t<=4'h9)
						char_addr_hora_reloj = 6'h0;  //0
					else if (min_t>=8'h10&&min_t<=8'h19)
						char_addr_hora_reloj = 6'h1; //1
					else if (min_t>=8'h20&&min_t<=8'h29)
						char_addr_hora_reloj = 6'h2; //2
					else if (min_t>=8'h30&&min_t<=8'h39)
						char_addr_hora_reloj = 6'h3; //3
					else if (min_t>=8'h40&&min_t<=8'h49)
						char_addr_hora_reloj = 6'h4; //4
					else char_addr_hora_reloj = 6'h5; //5
					end
			6'h8: begin //Segundo digito de los minutos
					if (min_t==4'h1||min_t==8'h11||min_t==8'h21||min_t==8'h31||min_t==8'h41||min_t==8'h51)
						char_addr_hora_reloj = 6'h1; //El segundo digito sera 1
					else if (min_t==4'h2||min_t==8'h12||min_t==8'h22||min_t==8'h32||min_t==8'h42||min_t==8'h52)
						char_addr_hora_reloj = 6'h2; //El segundo digito sera 2
					else if (min_t==4'h3||min_t==8'h13||min_t==8'h23||min_t==8'h33||min_t==8'h43||min_t==8'h53)
						char_addr_hora_reloj = 6'h3; //El segundo digito sera 3
					else if (min_t==4'h4||min_t==8'h14||min_t==8'h24||min_t==8'h34||min_t==8'h44||min_t==8'h54)
						char_addr_hora_reloj = 6'h4; //El segundo digito sera 4
					else if (min_t==4'h5||min_t==8'h15||min_t==8'h25||min_t==8'h35||min_t==8'h45||min_t==8'h55)
						char_addr_hora_reloj = 6'h5; //El segundo digito sera 5
					else if (min_t==4'h6||min_t==8'h16||min_t==8'h26||min_t==8'h36||min_t==8'h46||min_t==8'h56)
						char_addr_hora_reloj = 6'h6; //El segundo digito sera 6
					else if (min_t==4'h7||min_t==8'h17||min_t==8'h27||min_t==8'h37||min_t==8'h47||min_t==8'h57)
						char_addr_hora_reloj = 6'h7; //El segundo digito sera 7
					else if (min_t==4'h8||min_t==8'h18||min_t==8'h28||min_t==8'h38||min_t==8'h48||min_t==8'h58)
						char_addr_hora_reloj = 6'h8; //El segundo digito sera 8
					else if (min_t==4'h9||min_t==8'h19||min_t==8'h29||min_t==8'h39||min_t==8'h49||min_t==8'h59)
						char_addr_hora_reloj = 6'h9; //El segundo digito sera 9	
					else char_addr_hora_reloj = 6'h0; //El segundo digito sera 0, cuando es 00, 10, 20, 30, 40 o 50
					end
			6'h9: char_addr_hora_reloj = 6'hb; //Esto es espacio en blanco
			6'ha: char_addr_hora_reloj = 6'ha; //Esto son dos puntos
			6'hb: char_addr_hora_reloj = 6'hb; //Esto es espacio en blanco
			6'hc: begin //Primer digito de los segundos
					if (seg_t==4'h0||seg_t==4'h1||seg_t==4'h2||seg_t==4'h3||seg_t==4'h4||seg_t==4'h5||seg_t==4'h6||seg_t==4'h7||seg_t==4'h8||seg_t==4'h9)
						char_addr_hora_reloj = 6'h0; //0
					else if (seg_t==8'h10||seg_t==8'h11||seg_t==8'h12||seg_t==8'h13||seg_t==8'h14||seg_t==8'h15||seg_t==8'h16||seg_t==8'h17||seg_t==8'h18||seg_t==8'h19)
						char_addr_hora_reloj = 6'h1; //1
					else if (seg_t==8'h20||seg_t==8'h21||seg_t==8'h22||seg_t==8'h23||seg_t==8'h24||seg_t==8'h25||seg_t==8'h26||seg_t==8'h27||seg_t==8'h28||seg_t==8'h29)
						char_addr_hora_reloj = 6'h2; //2
					else if (seg_t==8'h30||seg_t==8'h31||seg_t==8'h32||seg_t==8'h33||seg_t==8'h34||seg_t==8'h35||seg_t==8'h36||seg_t==8'h37||seg_t==8'h38||seg_t==8'h39)
						char_addr_hora_reloj = 6'h3; //3
					else if (seg_t==8'h40||seg_t==8'h41||seg_t==8'h42||seg_t==8'h43||seg_t==8'h44||seg_t==8'h45||seg_t==8'h46||seg_t==8'h47||seg_t==8'h48||seg_t==8'h49)
						char_addr_hora_reloj = 6'h4; //4
					else char_addr_hora_reloj = 6'h5; //5
					end
			6'hd: begin //Segundo digito de los segundos
					if (seg_t==4'h1||seg_t==8'h11||seg_t==8'h21||seg_t==8'h31||seg_t==8'h41||seg_t==8'h51)
						char_addr_hora_reloj = 6'h1; //El segundo digito sera 1
					else if (seg_t==4'h2||seg_t==8'h12||seg_t==8'h22||seg_t==8'h32||seg_t==8'h42||seg_t==8'h52)
						char_addr_hora_reloj = 6'h2; //El segundo digito sera 2
					else if (seg_t==4'h3||seg_t==8'h13||seg_t==8'h23||seg_t==8'h33||seg_t==8'h43||seg_t==8'h53)
						char_addr_hora_reloj = 6'h3; //El segundo digito sera 3
					else if (seg_t==4'h4||seg_t==8'h14||seg_t==8'h24||seg_t==8'h34||seg_t==8'h44||seg_t==8'h54)
						char_addr_hora_reloj = 6'h4; //El segundo digito sera 4
					else if (seg_t==4'h5||seg_t==8'h15||seg_t==8'h25||seg_t==8'h35||seg_t==8'h45||seg_t==8'h55)
						char_addr_hora_reloj = 6'h5; //El segundo digito sera 5
					else if (seg_t==4'h6||seg_t==8'h16||seg_t==8'h26||seg_t==8'h36||seg_t==8'h46||seg_t==8'h56)
						char_addr_hora_reloj = 6'h6; //El segundo digito sera 6
					else if (seg_t==4'h7||seg_t==8'h17||seg_t==8'h27||seg_t==8'h37||seg_t==8'h47||seg_t==8'h57)
						char_addr_hora_reloj = 6'h7; //El segundo digito sera 7
					else if (seg_t==4'h8||seg_t==8'h18||seg_t==8'h28||seg_t==8'h38||seg_t==8'h48||seg_t==8'h58)
						char_addr_hora_reloj = 6'h8; //El segundo digito sera 8
					else if (seg_t==4'h9||seg_t==8'h19||seg_t==8'h29||seg_t==8'h39||seg_t==8'h49||seg_t==8'h59)
						char_addr_hora_reloj = 6'h9; //El segundo digito sera 9		
					else char_addr_hora_reloj = 6'h0; //El segundo digito sera 0, cuando es 00, 10, 20, 30, 40 o 50
					end
			default:
				char_addr_hora_reloj = 6'hb;
		endcase
		
		
		//para las impresiones de la fontROM del cronometro
	assign hora_crono = (ADDRV[8:5]==7) && (25<=ADDRH[9:4]&&38>ADDRH[9:4]); //Se define el tamaño
	//del contenido en la cantidad de bits que se toma, y se define en cual cuadricula se desea imprimir
	//En este caso X se limita de 0 a 11 porque se imprimiran 12 caracteres en dicho espacio
   assign row_addr_hora_crono = ADDRV[4:0];
   assign bit_addr_hora_crono = ADDRH[3:0];
	
	always@(posedge clk) 
	//Imprime desde el pixel 224 hasta el 416
		case (ADDRH[9:4]) //Esto depende de la definicion de pixeles por cuadricula que se haya especificado
		//se debe ver cuales son los pixeles que me dan el numero de filas
		//por el momento se definira en el borde
			6'h19: begin
						if(hora_c>=4'h0&&hora_c<=4'h9) begin
							char_addr_hora_crono = 6'h0; //0
						end
						else if(hora_c>=8'h10&&hora_c<=8'h19) begin
							char_addr_hora_crono = 6'h1; //1
						end
						else char_addr_hora_crono = 6'h2; //Si la hora es de 20 a 23
					end
			6'h1a: begin
						if(hora_c==4'h1||hora_c==8'h11||hora_c==8'h21)
							char_addr_hora_crono = 6'h1;	 //1
						else if(hora_c==4'h2||hora_c==8'h12||hora_c==8'h22)
							char_addr_hora_crono = 6'h2; //2
						else if(hora_c==4'h3||hora_c==8'h13||hora_c==8'h23)
							char_addr_hora_crono = 6'h3; //3
						else if(hora_c==4'h4||hora_c==8'h14)
							char_addr_hora_crono = 6'h4; //4
						else if(hora_c==4'h5||hora_c==8'h15)
							char_addr_hora_crono = 6'h5; //5
						else if(hora_c==4'h6||hora_c==8'h16)
							char_addr_hora_crono = 6'h6; //6
						else if(hora_c==4'h7||hora_c==8'h17)
							char_addr_hora_crono = 6'h7; //7
						else if(hora_c==4'h8||hora_c==8'h18)
							char_addr_hora_crono = 6'h8; //8
						else if(hora_c==8'h10||hora_c==8'h20)
							char_addr_hora_crono = 6'h0; //0
						else char_addr_hora_crono = 6'h9;	 //9
					end
			6'h1b: char_addr_hora_crono = 6'hb; //
			6'h1c: char_addr_hora_crono = 6'ha; //:
			6'h1d: char_addr_hora_crono = 6'hb; //
			6'h1e: begin
						if (min_c>=4'h0&&min_c<=4'h9)
							char_addr_hora_crono = 6'h0;  //0
						else if (min_c>=8'h10&&min_c<=8'h19)
							char_addr_hora_crono = 6'h1; //1
						else if (min_c>=8'h20&&min_c<=8'h29)
							char_addr_hora_crono = 6'h2; //2
						else if (min_c>=8'h30&&min_c<=8'h39)
							char_addr_hora_crono = 6'h3; //3
						else if (min_c>=8'h40&&min_c<=8'h49)
							char_addr_hora_crono = 6'h4; //4
						else char_addr_hora_crono = 6'h5; //5
					end
			6'h1f: begin //Segundo digito de los minutos
						if (min_c==4'h1||min_c==8'h11||min_c==8'h21||min_c==8'h31||min_c==8'h41||min_c==8'h51)
							char_addr_hora_crono = 6'h1; //El segundo digito sera 1
						else if (min_c==4'h2||min_c==8'h12||min_c==8'h22||min_c==8'h32||min_c==8'h42||min_c==8'h52)
							char_addr_hora_crono = 6'h2; //El segundo digito sera 2
						else if (min_c==4'h3||min_c==8'h13||min_c==8'h23||min_c==8'h33||min_c==8'h43||min_c==8'h53)
							char_addr_hora_crono = 6'h3; //El segundo digito sera 3
						else if (min_c==4'h4||min_c==8'h14||min_c==8'h24||min_c==8'h34||min_c==8'h44||min_c==8'h54)
							char_addr_hora_crono = 6'h4; //El segundo digito sera 4
						else if (min_c==4'h5||min_c==8'h15||min_c==8'h25||min_c==8'h35||min_c==8'h45||min_c==8'h55)
							char_addr_hora_crono = 6'h5; //El segundo digito sera 5
						else if (min_c==4'h6||min_c==8'h16||min_c==8'h26||min_c==8'h36||min_c==8'h46||min_c==8'h56)
							char_addr_hora_crono = 6'h6; //El segundo digito sera 6
						else if (min_c==4'h7||min_c==8'h17||min_c==8'h27||min_c==8'h37||min_c==8'h47||min_c==8'h57)
							char_addr_hora_crono = 6'h7; //El segundo digito sera 7
						else if (min_c==4'h8||min_c==8'h18||min_c==8'h28||min_c==8'h38||min_c==8'h48||min_c==8'h58)
							char_addr_hora_crono = 6'h8; //El segundo digito sera 8
						else if (min_c==4'h9||min_c==8'h19||min_c==8'h29||min_c==8'h39||min_c==8'h49||min_c==8'h59)
							char_addr_hora_crono = 6'h9; //El segundo digito sera 9		
						else char_addr_hora_crono = 6'h0; //El segundo digito sera 0, cuando es 00, 10, 20, 30, 40 o 50
					end
			6'h20: char_addr_hora_crono = 6'hb; //
			6'h21: char_addr_hora_crono = 6'ha; //:
			6'h22: char_addr_hora_crono = 6'hb; //
			6'h23: begin //Primer digito de los segundos
						if (seg_c>=4'h0&&seg_c<=4'h9)
							char_addr_hora_crono = 6'h0; //0
						else if (seg_c>=8'h10&&seg_c<=8'h19)
							char_addr_hora_crono = 6'h1; //1
						else if (seg_c>=8'h20&&seg_c<=8'h29)
							char_addr_hora_crono = 6'h2; //2
						else if (seg_c>=8'h30&&seg_c<=8'h39)
							char_addr_hora_crono = 6'h3; //3
						else if (seg_c>=8'h40&&seg_c<=8'h49)
							char_addr_hora_crono = 6'h4; //4
						else char_addr_hora_crono = 6'h5; //5
					end
			6'h24: begin //Segundo digito de los segundos
						if (seg_c==4'h1||seg_c==8'h11||seg_c==8'h21||seg_c==8'h31||seg_c==8'h41||seg_c==8'h51)
							char_addr_hora_crono = 6'h1; //El segundo digito sera 1
						else if (seg_c==4'h2||seg_c==8'h12||seg_c==8'h22||seg_c==8'h32||seg_c==8'h42||seg_c==8'h52)
							char_addr_hora_crono = 6'h2; //El segundo digito sera 2
						else if (seg_c==4'h3||seg_c==8'h13||seg_c==8'h23||seg_c==8'h33||seg_c==8'h43||seg_c==8'h53)
							char_addr_hora_crono = 6'h3; //El segundo digito sera 3
						else if (seg_c==4'h4||seg_c==8'h14||seg_c==8'h24||seg_c==8'h34||seg_c==8'h44||seg_c==8'h54)
							char_addr_hora_crono = 6'h4; //El segundo digito sera 4
						else if (seg_c==4'h5||seg_c==8'h15||seg_c==8'h25||seg_c==8'h35||seg_c==8'h45||seg_c==8'h55)
							char_addr_hora_crono = 6'h5; //El segundo digito sera 5
						else if (seg_c==4'h6||seg_c==8'h16||seg_c==8'h26||seg_c==8'h36||seg_c==8'h46||seg_c==8'h56)
							char_addr_hora_crono = 6'h6; //El segundo digito sera 6
						else if (seg_c==4'h7||seg_c==8'h17||seg_c==8'h27||seg_c==8'h37||seg_c==8'h47||seg_c==8'h57)
							char_addr_hora_crono = 6'h7; //El segundo digito sera 7
						else if (seg_c==4'h8||seg_c==8'h18||seg_c==8'h28||seg_c==8'h38||seg_c==8'h48||seg_c==8'h58)
							char_addr_hora_crono = 6'h8; //El segundo digito sera 8
						else if (seg_c==4'h9||seg_c==8'h19||seg_c==8'h29||seg_c==8'h39||seg_c==8'h49||seg_c==8'h59)
							char_addr_hora_crono = 6'h9; //El segundo digito sera 9	
						else char_addr_hora_crono = 7'h00; //El segundo digito sera 0, cuando es 00, 10, 20, 30, 40 o 50
					end
			default:
				char_addr_hora_crono = 6'hb;
		endcase
	
	always @(posedge dclk) begin
		COLOUR_IN <= 8'hFF;
		char_addr= 6'b000000;
		row_addr= 5'b00000;
		bit_addr=4'b0000;
		if (ADDRH>=X_fecha && ADDRH<(X_fecha+fechaX) && ADDRV>=Y_fecha && ADDRV<(Y_fecha+fechaY))
				COLOUR_IN <= COLOUR_DATA_fecha[{STATE_fecha}];
		else if (ADDRH>=X_reloj && ADDRH<(X_reloj+relojX) && ADDRV>=Y_reloj && ADDRV<(Y_reloj+relojY))
				COLOUR_IN <= COLOUR_DATA_reloj[{STATE_reloj}];
		else if (ADDRH>=X_crono && ADDRH<(X_crono+cronoX) && ADDRV>=Y_crono && ADDRV<(Y_crono+cronoY))
			COLOUR_IN <= COLOUR_DATA_crono[{STATE_crono}];
		else if (ADDRH>=X_horaEnc && ADDRH<(X_horaEnc+horaEnc_x) && ADDRV>=Y_horaEnc && ADDRV<(Y_horaEnc+horaEnc_y))
				COLOUR_IN <= COLOUR_DATA_horaEnc[{STATE_horaEnc}];
		else if (ADDRH>=X_horaEnc2 && ADDRH<(X_horaEnc2+horaEnc_x2) && ADDRV>=Y_horaEnc2 && ADDRV<(Y_horaEnc2+horaEnc_y2))
			COLOUR_IN <= COLOUR_DATA_horaEnc2[{STATE_horaEnc2}];
		else if (ADDRH>=X_ring && ADDRH<(X_ring+ring_x) && ADDRV>=Y_ring && ADDRV<(Y_ring+ring_y))
				COLOUR_IN <= COLOUR_DATA_ring[{STATE_ring}];
		else if (ADDRH>=X_dia_uno && ADDRH<(X_dia_uno+font_rom_x) && ADDRV>=Y_dia_uno && ADDRV<(Y_dia_uno+font_rom_y)) begin
				if (cambio_dia==4'h1||cambio_dia==4'h2||cambio_dia==4'h3||cambio_dia==4'h4||cambio_dia==4'h5||cambio_dia==4'h6||cambio_dia==4'h7||cambio_dia==4'h8||cambio_dia==4'h9)
					COLOUR_IN <= COLOUR_DATA_cero[{STATE_dia_uno}];	 //El primer digito sera 0
				else if (cambio_dia==8'h10||cambio_dia==8'h11||cambio_dia==8'h12||cambio_dia==8'h13||cambio_dia==8'h14||cambio_dia==8'h15||cambio_dia==8'h16||cambio_dia==8'h17||cambio_dia==8'h18||cambio_dia==8'h19)
					COLOUR_IN <= COLOUR_DATA_uno[{STATE_dia_uno}]; //El primer digito sera 1
				else if (cambio_dia==8'h20||cambio_dia==8'h21||cambio_dia==8'h22||cambio_dia==8'h23||cambio_dia==8'h24||cambio_dia==8'h25||cambio_dia==8'h26||cambio_dia==8'h27||cambio_dia==8'h28||cambio_dia==8'h29)	
					COLOUR_IN <= COLOUR_DATA_dos[{STATE_dia_uno}]; //El primer digito sera 2
				else if (cambio_dia==8'h30||cambio_dia==8'h31)	
					COLOUR_IN <= COLOUR_DATA_tres[{STATE_dia_uno}]; //El primer digito sera 3
				else COLOUR_IN <= COLOUR_DATA_cero[{STATE_dia_uno}]; //Imprime cero					
			end
		else if (ADDRH>=X_dia_dos && ADDRH<(X_dia_dos+font_rom_x) && ADDRV>=Y_dia_dos && ADDRV<(Y_dia_dos+font_rom_y)) begin
			if (cambio_dia==4'h1||cambio_dia==8'h11||cambio_dia==8'h21||cambio_dia==8'h31)
				COLOUR_IN <= COLOUR_DATA_uno[{STATE_dia_dos}]; //El segundo digito sera 1
			else if (cambio_dia==4'h2||cambio_dia==8'h12||cambio_dia==8'h22)
				COLOUR_IN <= COLOUR_DATA_dos[{STATE_dia_dos}]; //El segundo digito sera 2
			else if (cambio_dia==4'h3||cambio_dia==8'h13||cambio_dia==8'h23)
				COLOUR_IN <= COLOUR_DATA_tres[{STATE_dia_dos}]; //El segundo digito sera 3
			else if (cambio_dia==4'h4||cambio_dia==8'h14||cambio_dia==8'h24)
				COLOUR_IN <= COLOUR_DATA_cuatro[{STATE_dia_dos}]; //El segundo digito sera 4
			else if (cambio_dia==4'h5||cambio_dia==8'h15||cambio_dia==8'h25)
				COLOUR_IN <= COLOUR_DATA_cinco[{STATE_dia_dos}]; //El segundo digito sera 5
			else if (cambio_dia==4'h6||cambio_dia==8'h16||cambio_dia==8'h26)
				COLOUR_IN <= COLOUR_DATA_seis[{STATE_dia_dos}]; //El segundo digito sera 6
			else if (cambio_dia==4'h7||cambio_dia==8'h17||cambio_dia==8'h27)
				COLOUR_IN <= COLOUR_DATA_siete[{STATE_dia_dos}]; //El segundo digito sera 7
			else if (cambio_dia==4'h8||cambio_dia==8'h18||cambio_dia==8'h28)
				COLOUR_IN <= COLOUR_DATA_ocho[{STATE_dia_dos}]; //El segundo digito sera 8
			else if (cambio_dia==4'h9||cambio_dia==8'h19||cambio_dia==8'h29)
				COLOUR_IN <= COLOUR_DATA_nueve[{STATE_dia_dos}]; //El segundo digito sera 9			
			else COLOUR_IN <= COLOUR_DATA_cero[{STATE_dia_dos}]; //El segundo digito sera 0, cuando es 10, 20 o 30
				end
		else if (ADDRH>=X_mes_uno && ADDRH<(X_mes_uno+font_rom_x) && ADDRV>=Y_mes_uno && ADDRV<(Y_mes_uno+font_rom_y))
				//Se imprime el primer digito del mes
			if (cambio_mes==8'h10||cambio_mes==8'h11||cambio_mes==8'h12)
				COLOUR_IN <= COLOUR_DATA_uno[{STATE_mes_uno}];	 // 1
			else COLOUR_IN <= COLOUR_DATA_cero[{STATE_mes_uno}];	 // Imprime 0 al primer digito de todos los meses
			//Impresion del segundo digito del mes
		else if (ADDRH>=X_mes_dos && ADDRH<(X_mes_dos+font_rom_x) && ADDRV>=Y_mes_dos && ADDRV<(Y_mes_dos+font_rom_y))
			if(cambio_mes==8'h10)
				COLOUR_IN <= COLOUR_DATA_cero[{STATE_mes_dos}]; // 0
			else if (cambio_mes==4'h1||cambio_mes==8'h11)
				COLOUR_IN <= COLOUR_DATA_uno[{STATE_mes_dos}];
			else if (cambio_mes==4'h2||cambio_mes==8'h12)
				COLOUR_IN <= COLOUR_DATA_dos[{STATE_mes_dos}]; // 2
			else if (cambio_mes==4'h3)
				COLOUR_IN <= COLOUR_DATA_tres[{STATE_mes_dos}]; //3
			else if (cambio_mes==4'h4)
				COLOUR_IN <= COLOUR_DATA_cuatro[{STATE_mes_dos}]; //4
			else if (cambio_mes==4'h5)
				COLOUR_IN <= COLOUR_DATA_cinco[{STATE_mes_dos}]; //5
			else if (cambio_mes==4'h6)
				COLOUR_IN <= COLOUR_DATA_seis[{STATE_mes_dos}]; //6
			else if (cambio_mes==4'h7)
				COLOUR_IN <= COLOUR_DATA_siete[{STATE_mes_dos}]; //7
			else if (cambio_mes==4'h8)
				COLOUR_IN <= COLOUR_DATA_ocho[{STATE_mes_dos}]; //8
			else 
				COLOUR_IN <= COLOUR_DATA_nueve[{STATE_mes_dos}]; //De lo contrario es el mes 9 
				
				//impresion del año
				//primer digito, siempre sera 2
		else if (ADDRH>=X_year_uno && ADDRH<(X_year_uno+font_rom_x) && ADDRV>=Y_year_uno && ADDRV<(Y_year_uno+font_rom_y))
				COLOUR_IN <= COLOUR_DATA_dos[{STATE_year_uno}];	
				//segundo digito, siempre sera 0
		else if (ADDRH>=X_year_dos && ADDRH<(X_year_dos+font_rom_x) && ADDRV>=Y_year_dos && ADDRV<(Y_year_dos+font_rom_y))
				COLOUR_IN <= COLOUR_DATA_cero[{STATE_year_dos}];
				//tercer digito
		else if (ADDRH>=X_year_tres && ADDRH<(X_year_tres+font_rom_x) && ADDRV>=Y_year_tres && ADDRV<(Y_year_tres+font_rom_y))
				if (cambio_year>=4'h0&&cambio_year<=4'h9)
					COLOUR_IN <= COLOUR_DATA_cero[{STATE_year_tres}]; //0
				else if (cambio_year>=8'h10&&cambio_year<=8'h19)
					COLOUR_IN <= COLOUR_DATA_uno[{STATE_year_tres}]; //1
				else if (cambio_year>=8'h20&&cambio_year<=8'h29)
					COLOUR_IN <= COLOUR_DATA_dos[{STATE_year_tres}]; //2
				else if (cambio_year>=8'h30&&cambio_year<=8'h39)
					COLOUR_IN <= COLOUR_DATA_tres[{STATE_year_tres}]; //3
				else if (cambio_year>=8'h40&&cambio_year<=8'h49)
					COLOUR_IN <= COLOUR_DATA_cuatro[{STATE_year_tres}]; //4
				else if (cambio_year>=8'h50&&cambio_year<=8'h59)
					COLOUR_IN <= COLOUR_DATA_cinco[{STATE_year_tres}]; //5
				else if (cambio_year>=8'h60&&cambio_year<=8'h69)
					COLOUR_IN <= COLOUR_DATA_seis[{STATE_year_tres}]; //6
				else if (cambio_year>=8'h70&&cambio_year<=8'h79)
					COLOUR_IN <= COLOUR_DATA_siete[{STATE_year_tres}]; //7
				else if (cambio_year>=8'h80&&cambio_year<=8'h89)
					COLOUR_IN <= COLOUR_DATA_ocho[{STATE_year_tres}]; //8
				else COLOUR_IN <= COLOUR_DATA_nueve[{STATE_year_tres}]; //9
				//cuarto digito
		else if (ADDRH>=X_year_cuatro && ADDRH<(X_year_cuatro+font_rom_x) && ADDRV>=Y_year_cuatro && ADDRV<(Y_year_cuatro+font_rom_y))
				if (cambio_year==4'h1||cambio_year==8'h11||cambio_year==8'h21||cambio_year==8'h31||cambio_year==8'h41||cambio_year==8'h51||cambio_year==8'h61||cambio_year==8'h71||cambio_year==8'h81||cambio_year==8'h91)
					COLOUR_IN <= COLOUR_DATA_uno[{STATE_year_cuatro}]; //El segundo digito sera 1
				else if (cambio_year==4'h2||cambio_year==8'h12||cambio_year==8'h22||cambio_year==8'h32||cambio_year==8'h42||cambio_year==8'h52||cambio_year==8'h62||cambio_year==8'h72||cambio_year==8'h82||cambio_year==8'h92)
					COLOUR_IN <= COLOUR_DATA_dos[{STATE_year_cuatro}]; //El segundo digito sera 2
				else if (cambio_year==4'h3||cambio_year==8'h13||cambio_year==8'h23||cambio_year==8'h33||cambio_year==8'h43||cambio_year==8'h53||cambio_year==8'h63||cambio_year==8'h73||cambio_year==8'h83||cambio_year==8'h93)
					COLOUR_IN <= COLOUR_DATA_tres[{STATE_year_cuatro}]; //El segundo digito sera 3
				else if (cambio_year==4'h4||cambio_year==8'h14||cambio_year==8'h24||cambio_year==8'h34||cambio_year==8'h44||cambio_year==8'h54||cambio_year==8'h64||cambio_year==8'h74||cambio_year==8'h84||cambio_year==8'h94)
					COLOUR_IN <= COLOUR_DATA_cuatro[{STATE_year_cuatro}]; //El segundo digito sera 4
				else if (cambio_year==4'h5||cambio_year==8'h15||cambio_year==8'h25||cambio_year==8'h35||cambio_year==8'h45||cambio_year==8'h55||cambio_year==8'h65||cambio_year==8'h75||cambio_year==8'h85||cambio_year==8'h95)
					COLOUR_IN <= COLOUR_DATA_cinco[{STATE_year_cuatro}]; //El segundo digito sera 5
				else if (cambio_year==4'h6||cambio_year==8'h16||cambio_year==8'h26||cambio_year==8'h36||cambio_year==8'h46||cambio_year==8'h56||cambio_year==8'h66||cambio_year==8'h76||cambio_year==8'h86||cambio_year==8'h96)
					COLOUR_IN <= COLOUR_DATA_seis[{STATE_year_cuatro}]; //El segundo digito sera 6
				else if (cambio_year==4'h7||cambio_year==8'h17||cambio_year==8'h27||cambio_year==8'h37||cambio_year==8'h47||cambio_year==8'h57||cambio_year==8'h67||cambio_year==8'h77||cambio_year==8'h87||cambio_year==8'h97)
					COLOUR_IN <= COLOUR_DATA_siete[{STATE_year_cuatro}]; //El segundo digito sera 7
				else if (cambio_year==4'h8||cambio_year==8'h18||cambio_year==8'h28||cambio_year==8'h38||cambio_year==8'h48||cambio_year==8'h58||cambio_year==8'h68||cambio_year==8'h78||cambio_year==8'h88||cambio_year==8'h98)
					COLOUR_IN <= COLOUR_DATA_ocho[{STATE_year_cuatro}]; //El segundo digito sera 8
				else if (cambio_year==4'h9||cambio_year==8'h19||cambio_year==8'h29||cambio_year==8'h39||cambio_year==8'h49||cambio_year==8'h59||cambio_year==8'h69||cambio_year==8'h79||cambio_year==8'h89||cambio_year==8'h99)
					COLOUR_IN <= COLOUR_DATA_nueve[{STATE_year_cuatro}]; //El segundo digito sera 9				
				else COLOUR_IN <= COLOUR_DATA_cero[{STATE_year_cuatro}]; //El segundo digito sera 0, cuando es 00, 10, 20, 30, 40, 50, 60, 70, 80 o 90
		else if (ADDRH>=X_campanaNegra && ADDRH<(X_campanaNegra+campanaNegra_x) && ADDRV>=Y_campanaNegra && ADDRV<(Y_campanaNegra+campanaNegra_y)) begin
				if (alarma_signal) begin
					if (parpadeo) begin
						COLOUR_IN <= COLOUR_DATA_campanaRoja[{STATE_campanaRoja}];
					end
					else begin
						COLOUR_IN <= COLOUR_DATA_campanaNegra[{STATE_campanaNegra}];
					end
				end
				else begin
					COLOUR_IN <= COLOUR_DATA_campanaNegra[{STATE_campanaNegra}];
				end
			end
		else if (hora_reloj)
         begin
            char_addr = char_addr_hora_reloj;
            row_addr = row_addr_hora_reloj;
            bit_addr = bit_addr_hora_reloj;
            if (font_bit)
               begin
					COLOUR_IN <= 8'h5F;
					end
				else
					COLOUR_IN <= 8'hFF;
         end
		else if (hora_crono)
         begin
            char_addr = char_addr_hora_crono;
            row_addr = row_addr_hora_crono;
            bit_addr = bit_addr_hora_crono;
            if (font_bit)
               begin
					COLOUR_IN <= 8'h5F;
					end
				else
					COLOUR_IN <= 8'hFF;
         end
		else
			COLOUR_IN <= 8'hFF;
	end
			
	assign rom_addr = {char_addr, row_addr};
   assign font_bit = font_word[~bit_addr];
	assign TrigRefresh = TrigRefresh;
	
endmodule 