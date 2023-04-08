`timescale 1ns/1ps

module PUF_TOP(

	input clk, start,
	input [7:0] challenge,
	output [255:0] response,
	output done
);

wire [7:0] c;
wire om0, om1, winner;
wire [31:0] oc0, oc1;
wire lfsr_EN, sr_EN, count_EN, ref_EN, ro_EN, seed_DV, countReset;
wire [7:0] refcount;
wire [15:0] o0, o1;

genvar i;
generate

	for(i=0; i<16; i=i+1)
	begin : ring0
		PUF_RO ro0(ro_EN, c[7:4], o0[i]);
	end
	
	for(i=0; i<16; i=i+1)
	begin : ring1
		PUF_RO ro1(ro_EN, c[7:4], o1[i]);
	end
	
endgenerate

Mux_16x1 mux0(.m_in(o0), .m_sel(c[3:0]), .m_out(om0));
Mux_16x1 mux1(.m_in(o1), .m_sel(c[7:4]), .m_out(om1));

PUF_counter counter0(.clk(om0), .en(count_EN), .rst(countReset), .c_out(oc0));
PUF_counter counter1(.clk(om1), .en(count_EN), .rst(countReset), .c_out(oc1));
PUF_counter #(8) counter_ref(.clk(clk), .en(ref_EN), .rst(countReset), .c_out(refcount));

PUF_comparator comp(.comp_in01(oc0), .comp_in02(oc1), .comp_out(winner));

PUF_ShiftReg SR(.clk(clk), .en(sr_EN), .s_in(winner), .shift_out(response));
PUF_LFSR #(8) LFSR_0(.clk(clk), .en(lfsr_EN), .seed_DV(seed_DV), .seed(challenge), .LFSR_out(c), .LFSR_done(LFSR_done));

PUF_controller CU(.clk(clk), .start(start), .refcount(refcount), .lfsr_DV(seed_DV), .count_EN(count_EN), .ref_EN(ref_EN), .lfsr_EN(lfsr_EN), .sr_EN(sr_EN), .ro_EN(ro_EN), .countReset(countReset), .done(done));

endmodule
