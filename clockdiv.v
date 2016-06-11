module clockdiv(
	input wire clk,		//master clock: 100MHz
	output wire dclk		//pixel clock: 50MHz
	);

//-- Numero de bits del prescaler (por defecto)
parameter N = 1; //Prescaler de 1 bit para dividir entre 2

//-- Registro para implementar contador de N bits
reg [N-1:0] count = 0;

//-- El bit más significativo se saca por la salida
assign dclk = count[N-1];

//-- Contador: se incrementa en flanco de subida
always @(posedge clk) begin
  count <= count + 1'b1;
end

endmodule
