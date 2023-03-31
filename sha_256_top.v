module sha_256_top(

    input clk, n_rst,
    input cs, we,

    input [7:0] addr,
    input [31:0] data_in,
    output [31:0] data_out,
    output error
);

/* Initializations */

localparam ADDR_NAME0 = 8'h00;
localparam ADDR_NAME1 = 8'h01;
localparam ADDR_VER = 8'h02;
localparam ADDR_CTRL = 8'h08;
localparam ADDR_STATUS = 8'h09;
localparam ADDR_BLOCK0 = 8'h10;
localparam ADDR_BLOCK15 = 8'h1F;
localparam ADDR_DIGEST0 = 8'h20;
localparam ADDR_DIGEST7 = 8'h27;

localparam CORE_NAME0 = 32'h73686132;
localparam CORE_NAME1 = 32'h2d323536;
localparam CORE_VER = 32'h312e3830;

localparam INIT = 0;
localparam NEXT = 1;
localparam MODE = 2;

localparam STAT_READY = 0;
localparam STAT_VALID = 1;

localparam MODE_SHA224 = 0;
localparam MODE_SHA256 = 0;

/* Register Declarations */

reg init_r, init_n;
reg next_r, next_n;
reg mode_r, mode_n;
reg mode_we;
reg ready_r;

reg [31:0] block_r [0:15];
reg block_we;

reg [255:0] digest_r;
reg valid_digest_r;

/* Wire Declarations */

wire core_ready;
wire [511:0] core_block;
wire [255:0] core_digest;
wire core_valid_digest;

reg t_data_out, t_error;

/* Core Module Initialization */

SHA_256_core core(.clk(clk), .n_rst(n_rst), .init(init_r), .next(next_r), .mode(mode_r), .block_in(core_block), .ready(core_ready), .digest(core_digest), .valid_digest(core_digest_valid));

/* Port Connextions */

assign core_block = {block_r[0], block_r[1], block_r[2], block_r[3], block_r[4], 
                     block_r[5], block_r[6], block_r[7], block_r[8], block_r[9], 
                     block_r[10], block_r[11], block_r[12], block_r[13], block_r[14], 
                     block_r[15]};

assign data_out = t_data_out;
assign error = t_error;

/* Register Update Logic */

always @(posedge clk or negedge n_rst) 
begin : reg_update
    integer i;

    if(!n_rst)
    begin
        for (i = 0; i<16 ; i=i+1) 
        begin
            block_r[i] <= 32'h0;
        end

        init_r <= 0;
        next_r <= 0;
        ready_r <= 0;
        mode_r <= MODE_SHA256;
        digest_r <= 256'h0;
        valid_digest_r <=0;
    end

    else
    begin
        ready_r <= core_ready;
        valid_digest_r <= core_valid_digest;
        init_r <= init_n;
        next_r <= next_n;

        if(mode_we) mode_r <= mode_n;
        if(core_valid_digest) digest_r <= core_digest;
        if(block_we) block_r[addr[3:0]] <= data_in;
    end
end

/* Wrapper Logic implementation */

always @(*) 
begin
    init_n = 0    ;
    next_n = 0;
    mode_n = 0;
    mode_we = 0;
    block_we = 0;
    t_data_out = 32'h0;
    t_error = 0;

    if(cs)
    begin
        if(we)
        begin
            if(addr == ADDR_CTRL)
            begin
                init_n = data_in[INIT];
                next_n = data_in[NEXT];
                mode_n = data_in[MODE];
                mode_we = 1;
            end

            if((addr >= ADDR_BLOCK0) && (addr <= ADDR_BLOCK15)) block_we = 1;
        end

        else
        begin
            if((addr >= ADDR_BLOCK0) && (addr <= ADDR_BLOCK15))
                t_data_out = block_r[addr[3:0]];

            if((addr >= ADDR_DIGEST0) && (addr <= ADDR_DIGEST7))
                t_data_out = digest_r[(7-(addr-ADDR_DIGEST0))*32 +: 32];

            case (addr)
                ADDR_NAME0 : t_data_out = CORE_NAME0;
                ADDR_NAME1 : t_data_out = CORE_NAME1;
                ADDR_VER : t_data_out = CORE_VER;
                ADDR_CTRL : t_data_out = {29'h0, mode_r, next_r, init_r};
                ADDR_STATUS : t_data_out = {30'h0, valid_digest_r, ready_r}; 
                default: begin end
            endcase
        end
    end
end
endmodule