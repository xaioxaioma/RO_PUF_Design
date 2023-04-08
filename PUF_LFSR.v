`timescale 1ns/1ps

module PUF_LFSR #(parameter width = 8)(

	input clk, en, seed_DV,
	input [width-1:0] seed,
	
	output [width-1:0] LFSR_out,
	output LFSR_done

);

reg [width:1] reg_LFSR = 0;
reg reg_XNOR;

always@(posedge clk)
begin
	if(en == 1'b1)
	begin	
		if(seed_DV == 1'b1) reg_LFSR <= seed;
		else reg_LFSR <= {reg_LFSR[width-1:1], reg_XNOR};
	end
end

always@(*)
begin
	case(width)
	
		3 : begin reg_XNOR = reg_LFSR[3] ^~  reg_LFSR[2]; end
		4 : begin reg_XNOR = reg_LFSR[4] ^~  reg_LFSR[3]; end
		5 : begin reg_XNOR = reg_LFSR[5] ^~  reg_LFSR[3]; end
		6 : begin reg_XNOR = reg_LFSR[6] ^~  reg_LFSR[5]; end
		
		7 : begin reg_XNOR = reg_LFSR[7] ^~  reg_LFSR[6]; end
		8 : begin reg_XNOR = reg_LFSR[8] ^~  reg_LFSR[6] ^~  reg_LFSR[5] ^~  reg_LFSR[4]; end
		9 : begin reg_XNOR = reg_LFSR[9] ^~  reg_LFSR[5]; end
		10 : begin reg_XNOR = reg_LFSR[10] ^~  reg_LFSR[7]; end
		
	   11 : begin reg_XNOR = reg_LFSR[11] ^~  reg_LFSR[9]; end
		12 : begin reg_XNOR = reg_LFSR[12] ^~  reg_LFSR[6] ^~  reg_LFSR[4] ^~  reg_LFSR[1]; end
		13 : begin reg_XNOR = reg_LFSR[13] ^~  reg_LFSR[4] ^~  reg_LFSR[3] ^~  reg_LFSR[1]; end
		14 : begin reg_XNOR = reg_LFSR[14] ^~  reg_LFSR[5] ^~  reg_LFSR[3] ^~  reg_LFSR[1]; end
		
		15 : begin reg_XNOR = reg_LFSR[15] ^~  reg_LFSR[14]; end
		16 : begin reg_XNOR = reg_LFSR[16] ^~  reg_LFSR[15] ^~  reg_LFSR[13] ^~  reg_LFSR[4]; end
		17 : begin reg_XNOR = reg_LFSR[17] ^~  reg_LFSR[14]; end
		18 : begin reg_XNOR = reg_LFSR[18] ^~  reg_LFSR[11]; end
		
		19 : begin reg_XNOR = reg_LFSR[19] ^~  reg_LFSR[6] ^~  reg_LFSR[2] ^~  reg_LFSR[1]; end
		20 : begin reg_XNOR = reg_LFSR[20] ^~  reg_LFSR[17]; end
		21 : begin reg_XNOR = reg_LFSR[21] ^~  reg_LFSR[19]; end
		22 : begin reg_XNOR = reg_LFSR[22] ^~  reg_LFSR[21]; end
		
		23 : begin reg_XNOR = reg_LFSR[23] ^~  reg_LFSR[18]; end
		24 : begin reg_XNOR = reg_LFSR[24] ^~  reg_LFSR[23] ^~  reg_LFSR[22] ^~  reg_LFSR[17]; end
		25 : begin reg_XNOR = reg_LFSR[25] ^~  reg_LFSR[22]; end
		26 : begin reg_XNOR = reg_LFSR[26] ^~  reg_LFSR[6] ^~  reg_LFSR[2] ^~  reg_LFSR[1]; end
		
		27 : begin reg_XNOR = reg_LFSR[27] ^~  reg_LFSR[5] ^~  reg_LFSR[2] ^~  reg_LFSR[1]; end
		28 : begin reg_XNOR = reg_LFSR[28] ^~  reg_LFSR[25]; end
		29 : begin reg_XNOR = reg_LFSR[29] ^~  reg_LFSR[27]; end
		30 : begin reg_XNOR = reg_LFSR[30] ^~  reg_LFSR[6] ^~  reg_LFSR[4] ^~  reg_LFSR[1]; end
		
		31 : begin reg_XNOR = reg_LFSR[31] ^~  reg_LFSR[28]; end
		32 : begin reg_XNOR = reg_LFSR[32] ^~  reg_LFSR[22] ^~  reg_LFSR[2] ^~  reg_LFSR[1]; end
	endcase
end

assign LFSR_out = reg_LFSR[width:1];
assign LFSR_done = (reg_LFSR[width:1] == seed) ? 1'b1 : 1'b0;

endmodule