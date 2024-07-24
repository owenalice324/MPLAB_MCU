
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module mcu(

	//////////// CLOCK //////////
	input CLK,

	//////////// 7-segment decoder //////////
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	
	//////////// LED /////////////
	output [9:0] LED,
	
	//////////// SWITCH //////////
	input [9:0] SW,
	
	//////////// BUTTON //////////
	input [2:0] BTN
	
);
//*******************************//

// add module here
wire [7:0]in;
seven_segment s1(.in(in[3:0]),.out(HEX0));
seven_segment s2(.in(in[7:4]),.out(HEX1));
CPU c1(.clk(CLK),.reset(~BTN[0]),.port_b_out(in));
//*******************************//

endmodule