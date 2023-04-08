`timescale 1ns/1ps

module PUF_ShiftReg(

	input clk, s_in, en,
	output reg [255:0] shift_out

);

always@(posedge clk)
begin
	if(en) shift_out <= {s_in, shift_out[255:1]};
end

endmodule
