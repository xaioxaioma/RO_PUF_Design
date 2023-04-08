`timescale 1ns / 1ps

module PUF_RO(

	input en,
	input [3:0] c,
	output RO_out
);

wire #(1) t0;
wire #(1) t1;
wire #(1) t2;
wire #(1) t3;
wire #(1) t4;
wire #(1) t5;

and(t0,en,t5);
not(t1,t0);
not(t2,t1);
not(t3,t2);
not(t4,t3);
not(t5,t4);

assign RO_out = t5;

endmodule

