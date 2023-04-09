module SPRAM #(parameter SIZE = 256)(

	input [$clog2(SIZE)-1:0] addr,
	input [7:0] data_in,
	input we, clk,
	output reg [7:0] mem_out
);

reg [7:0] mem_spram [SIZE-1:0];

always@(posedge clk)
begin
	
	if(we) mem_spram[addr] <= data_in;
	mem_out <= mem_spram[addr];

end

endmodule
