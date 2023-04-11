`timescale 1ns/1ps

module HSSPI_TOP(

	input clk_in, n_rst,
	input MISO,
	output sclk, MOSI

);

/* ----------------------------------------------------------------------------  */

parameter IDLE = 3'b000;
parameter CHALL = 3'b001;
parameter VALID = 3'b010;
parameter ADDR = 3'b011;
parameter READ = 3'b100;
parameter WRITE = 3'b101;
parameter DONE = 3'b110;

/* ----------------------------------------------------------------------------  */

wire w_clk;
wire reset;

wire [7:0] w_RX_byte;
wire w_TX_Ready;
wire w_RX_DV;

wire [255:0] w_response;
wire w_puf_done;

wire w_res_valid;

wire w_mem_out;

/* ----------------------------------------------------------------------------   */ 

reg [7:0] r_TX_byte;
reg [7:0] r_RX_byte;
reg r_TX_DV;
reg r_RX_DV;
reg r_TX_ready;

reg r_puf_start;
reg [7:0] r_challenge;

reg r_val_start;
reg r_res_valid;

reg [7:0] r_address_buffer;
reg [7:0] r_data_buffer;
reg r_we, r_oe;
reg int_r = 0, ins_r = 0;

reg [3:0] state_curr, state_next;


/* ----------------------------------------------------------------------------   */ 

assign reset = !n_rst;

/* ----------------------------------------------------------------------------   */ 

clk_divider cL1(.clk_in(clk_in), .clk_out(w_clk));

SPI_master SPI_M(.i_Rst_L(n_rst), .i_Clk(w_clk), .i_TX_Byte(r_TX_byte), 
					  .i_TX_DV(r_TX_DV), .o_TX_Ready(w_TX_Ready), .o_RX_DV(w_RX_DV), .o_RX_Byte(w_RX_byte), 
					  .o_SPI_Clk(sclk), .i_SPI_MISO(MISO), .o_SPI_MOSI(MOSI));

PUF_TOP ROPUF(.clk(w_clk), .start(r_puf_start), .challenge(r_challenge), .response(w_response), .done(w_puf_done));

RES_validate RESV(.start(r_val_start), .data_in(w_response), .valid(w_res_valid));

SPRAM spr(.addr(r_address_buffer), .data_in(r_data_buffer), .we(r_we), .clk(w_clk), .oe(r_oe), .mem_out(w_mem_out));

/* ----------------------------------------------------------------------------   */ 

always@(posedge w_clk or negedge n_rst)
begin
	if(!n_rst)
	begin
		state_curr <= IDLE;
	end
	
	else
	begin		
		state_curr <= state_next;
	end
	
end

always@(posedge w_clk)
begin

	r_RX_byte <= w_RX_byte;
	r_TX_ready <= w_TX_Ready;
	r_res_valid <= w_res_valid;
	r_RX_DV <= w_RX_DV;

end

always@(posedge w_RX_DV)
begin
	
	if(w_RX_DV)int_r = 1'b1;
	else if(!w_RX_DV) int_r = 1'b0;

end

always@(posedge w_puf_done)
begin
	r_puf_done = 1;
end

always@(state_curr or int_r)
begin
ins_r = int_r;
		case(state_curr)
			IDLE : 
			begin
			
				r_TX_byte = 0;
				//r_RX_byte <= 0;
				r_TX_DV = 0;
				// r_TX_ready = 0;
		
				r_puf_start = 0;
				r_challenge = 0;
		
				r_val_start = 0;
				//r_res_vali <= 0;
		
				r_address_buffer = 0;
				r_data_buffer = 0;
				r_we = 0;
				r_oe = 0;
				
				state_next = CHALL;
				$display("Hello Bro");
			
			end
			
			CHALL :
			begin
				if(ins_r == 0)
				begin
				r_TX_byte = 8'h01;
				#2 r_TX_DV = 1;
				#4 r_TX_DV = 0;
				$display("Hello");
				end
				
				if(ins_r)
				begin
					r_challenge = w_RX_byte;
					r_puf_start = 1;
					state_next = VALID;
					
					$display("World");
					ins_r = 0;

				end
				else
					state_next = CHALL;
			end
			
			VALID :
			begin
				if(r_puf_done)
				begin
					r_val_start = 1;
				end
				
				if(r_res_valid)
					state_next = ADDR;
				else
				begin
					r_TX_byte = 8'hAA;
					r_TX_DV = 1;
					
					state_next = IDLE;
				end
			
					
			end
		endcase
end

endmodule
