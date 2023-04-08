module Mux_16x1(
	
	input [15:0] m_in,
	input [3:0] m_sel,
	output m_out
);

assign m_out = m_in[m_sel];

endmodule