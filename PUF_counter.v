`timescale 1ns/1ps

module PUF_counter #(parameter size = 32)(

	input clk, en, rst,
	output reg [size-1:0] c_out
);

always@(posedge clk, posedge rst)
begin
	if(rst) c_out <= 0;
	else
	begin
		if(en)
			c_out <= c_out + 1;
		else
			c_out <= c_out;
	end
end

endmodule

