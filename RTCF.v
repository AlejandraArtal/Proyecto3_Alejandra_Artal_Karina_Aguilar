`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:12:11 05/19/2016 
// Design Name: 
// Module Name:    RTCF 
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
module RTCF(
		input wire reset,clk, /*UPP, DOWNP, LEFTP,RIGHTP,inter1, inter2, inter3,inter4,*/
		output wire A_D, R_D,W_R, C_S,
		/*output wire dclk, */
		input wire UPP, DOWN,
		output wire [7:0] COLOUR_OUT,
		output wire hsync, vsync,
		input wire alarma_signal,
		output wire [9:0] pixel_x, pixel_y,
		output wire cien,
		inout [7:0] io_port,
		output reloj,
		output reset2,/*, interUPP,interDOWN,interEST,*/
		input write_strobe,
		input [7:0] out_port, port_id,
		output dclk
	);
//assign interUPP = UPP;
//assign interDOWN = DOWN;
reg opcpico,/* Upp1, Down1, */reg_inter1, reg_inter2, next_inter1, next_inter2;
wire opcpicow;
wire /*UPP,DOWN, */inter1, inter2;
assign reset2 = ~reset;
assign reloj = clk;
wire [7:0] DatoDirw;
wire [7:0] DatoOut;
wire DatoOpcf;
// Instantiate the module
MaquinaPrincipal MaquinaPrincipal (
    .reset(reset), 
    .clk(clk), 
    .DatoDirgIn(DatoDirw), 
    .A_D(A_D), 
    .R_D(R_D), 
    .W_R(W_R), 
    .C_S(C_S), 
    .COLOUR_OUT(COLOUR_OUT), 
    .hsync(hsync), 
    .vsync(vsync), 
    .alarma_signal(alarma_signal), 
    .cien(cien), 
    .DatoDirOut(DatoOut), 
    .LecEsc(DatoOpcf),
	 //.interE(interEST),
	 .Upp(UPP),
	 .Down(DOWN),
	 .interS(inter1),
	 .interM(inter2),
	 //.interH(inter3),
	 .OpcPico(opcpicow),
	 .dclk(dclk)
	 //
    );

// Instantiate the module
test instance_Inout (
    .clk(clk), 
    .DatoOpc(DatoOpcf), 
    .DatoDirIn(DatoDirw), 
    .DatoDirOut(DatoOut), 
    .io_port(io_port)
    );
//lógica para capturar datos del picoblaze

always @ (posedge clk) begin // logica para inicializar el RTC
	if ((port_id == 8'h1) && (write_strobe)) begin
		opcpico = 1'b1;
	end 
	else begin
		opcpico = 1'b0;
	end
end /*
always @ (posedge clk) begin // logica para inicializar el RTC
	if ((port_id == 8'h8) && (write_strobe)) begin
		alarma_signal = 1'b1;
	end 
	else begin
		alarma_signal = 1'b0;
	end
end */
/*always @ (posedge clk) begin // logica para UPP
	if ((port_id == 8'h2) && (write_strobe)) begin
		Upp1 = 1'b1;
	end 
	else begin
		Upp1 = 1'b0;
	end
end 
always @ (posedge clk) begin // logica DOWN
	if ((port_id == 8'h3) && (write_strobe)) begin
		Down1 = 1'b1;
	end 
	else begin
		Down1 = 1'b0;
	end
end */
always @ (posedge clk, posedge reset) begin // logica secuencial para registros de configuracion
	if (reset) begin
		reg_inter1 = 1'b0;
		reg_inter2 = 1'b0;
	end 
	else begin
		reg_inter1 = next_inter1;
		reg_inter2 = next_inter2;
	end
end 
always @* begin// logica combinacional
	if (write_strobe) 
	begin
		case(port_id)
		8'h4: 
			begin
				next_inter1 = out_port;
				next_inter2 = reg_inter2;
			end
		8'h5: 
			begin
				next_inter2 = out_port;
				next_inter1 = reg_inter1;
			end
		endcase
	end
end
//assign UPP = Upp1;
//assign DOWN = Down1;
assign inter1 = reg_inter1;
assign inter2 = reg_inter2;
assign opcpicow = opcpico;
//assign alarma_signalw = alarma_signal;
endmodule
