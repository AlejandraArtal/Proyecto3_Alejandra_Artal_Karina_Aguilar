`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:08:51 06/06/2016 
// Design Name: 
// Module Name:    MicroControlador 
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
module MicroControlador(
   output [7:0] out_port, port_id,
	output write_strobe,
	input [7:0] in_port,
	input clk, reset
	);
wire enable, clk, reset, read_strobe, k_write_strobe;
wire [11:0] address;
wire [17:0] instruction;
wire [7:0]out_port, in_port,port_id; 
wire resetPico; 

assign resetPico = reset || rdl;
// Instantiate the module
kcpsm6 instance_kcpsm6 (
    .address(address), 
    .instruction(instruction), 
    .bram_enable(enable), 
    .in_port(in_port), 
    .out_port(out_port), 
    .port_id(port_id), 
    .write_strobe(write_strobe), 
    .k_write_strobe(k_write_strobe), 
    .read_strobe(read_strobe), 
    .interrupt(1'b0), 
    .interrupt_ack(interrupt_ack), 
    .sleep(1'b0), 
    .reset(resetPico), 
    .clk(clk)
    );
	 
// Instantiate the module
set_instrucciones instance_instrucciones (
    .address(address), 
    .instruction(instruction), 
    .enable(enable), 
    .rdl(rdl), 
    .clk(clk)
    );


endmodule
