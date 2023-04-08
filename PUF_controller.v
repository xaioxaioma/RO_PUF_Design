`timescale 1ns/1ps

module PUF_controller(

	input clk, start,
	input [7:0] refcount,
	output reg lfsr_DV, count_EN, ref_EN, lfsr_EN, sr_EN, ro_EN, countReset, done
	
);

reg [2:0] state;
reg [7:0] bit_count;

parameter IDLE = 3'b000, DVALID = 3'b001;
parameter INNER = 3'b010, PRE = 3'b011;
parameter OUTER = 3'b100, TEMP = 3'b101;

always@(posedge clk)
begin
	
	case(state)
	
		IDLE : begin
			done <= 1'b0;
			bit_count <= 8'b0;
			if(!start) state <= IDLE;
			else state <= DVALID;
		end
		
		DVALID : state <= INNER;
		
		INNER : begin
		
			if(refcount == 8'hFF) state <= PRE;
			else state <= INNER;
		end
		
		PRE : state <= OUTER;
		
		OUTER : begin
		
			bit_count <= bit_count + 1;
			if(bit_count == 8'hFF) 
			begin
				state <= TEMP;
				done <= 1'b1;
			end
			
			else
			begin
				state <= INNER;
				done <= 1'b0;
			end
			
		end
		
		TEMP : begin
		
			done <= 1'b0;
			if(start) state <= TEMP;
			else state <= IDLE;
			
		end
		
		default : begin
		
			state <= IDLE;
			bit_count <= 8'b0;
			done <= 1'b0;
			
		end
		
		endcase
		
end

always@(*) 
begin 
        case(state)
            IDLE: begin
                lfsr_DV <= 1'b0;
                count_EN <= 1'b0;
                ref_EN <= 1'b0;
                lfsr_EN <= 1'b0;
                sr_EN <= 1'b0;
                ro_EN <= 1'b0;
                countReset <= 1'b1;
            end
            DVALID: begin
                lfsr_DV <= 1'b1;
                count_EN <= 1'b0;
                ref_EN <= 1'b0;
                lfsr_EN <= 1'b1;
                sr_EN <= 1'b0;
                ro_EN <= 1'b0;
                countReset <= 1'b1;
            end
            INNER: begin
                lfsr_DV <= 1'b0;
                count_EN <= 1'b1;
                ref_EN <= 1'b1;
                lfsr_EN <= 1'b0;
                sr_EN <= 1'b0;
                ro_EN <= 1'b1;
                countReset <= 1'b0;
            end 
            PRE: begin
                lfsr_DV <= 1'b0;
                count_EN <= 1'b1;
                ref_EN <= 1'b0;
                lfsr_EN <= 1'b1;
                sr_EN <= 1'b1;
                ro_EN <= 1'b0;
                countReset <= 1'b0;
            end
            OUTER: begin
                lfsr_DV <= 1'b0;
                count_EN <= 1'b1;
                ref_EN <= 1'b0;
                lfsr_EN <= 1'b0;
                sr_EN <= 1'b0;
                ro_EN <= 1'b0;
                countReset <= 1'b1;
            end
            default: begin
                lfsr_DV <= 1'b0;
                count_EN <= 1'b0;
                ref_EN <= 1'b0;
                lfsr_EN <= 1'b0;
                sr_EN <= 1'b0;
                ro_EN <= 1'b0;
                countReset <= 1'b1;
            end
        endcase
    end

endmodule
