module clk_divider #(parameter div = 5)(

	input clk_in,
	output reg clk_out = 0

);

reg [$clog2(div) : 0] t_cnt = 0;

always@(posedge clk_in)
begin

	t_cnt <= t_cnt + 1;
	if(t_cnt == div-1)
	begin
		t_cnt <= 0;
		clk_out <= ~clk_out;
	end
		
end

endmodule

	