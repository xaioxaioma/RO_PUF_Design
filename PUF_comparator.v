`timescale 1ns/1ps

module PUF_comparator(

	input [31:0] comp_in01, comp_in02,
	output reg comp_out
);

always@(*)
begin

	if(comp_in01 > comp_in02) comp_out <= 1'b0;
	else comp_out <= 1'b1;
	
end

endmodule

	