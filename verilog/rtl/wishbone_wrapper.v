`default_nettype none

module wishbone_wrapper
#(
	parameter BASE_ADDR = 32'h3000_0000,
    parameter ADDR_WIDTH = 8
)
(
	`ifdef USE_POWER_PINS
	    inout vccd1,	// User area 1 1.8V supply
	    inout vssd1,	// User area 1 digital ground
	`endif

    // Wishbone port A
    input           wb_clk_i,
    input           wb_rst_i,
    input           wbs_stb_i,
    input           wbs_cyc_i,
    input           wbs_we_i,
    input   [3:0]   wbs_sel_i,
    input   [31:0]  wbs_dat_i,
    input   [31:0]  wbs_adr_i,
    output          wbs_ack_o,
    output  [31:0]  wbs_dat_o,

    // OpenRAM interface - almost dual port: RW + R
    // Port 0: RW
    output                      ram_clk0,       // clock
    output                      ram_csb0,       // active low chip select
    output                      ram_web0,       // active low write control
    output  [3:0]              	ram_wmask0,     // write (byte) mask
    output  [ADDR_WIDTH-1:0]    ram_addr0,
    input   [31:0]              ram_din0,
    output  [31:0]              ram_dout0
);

	parameter ADDR_LO_MASK = (1 << ADDR_WIDTH) - 1;
	parameter ADDR_HI_MASK = 32'hffff_ffff - ADDR_LO_MASK;
	
	wire ram_cs;
	assign ram_cs = wbs_stb_i && wbs_cyc_i && ((wbs_adr_i & ADDR_HI_MASK) == BASE_ADDR) && !wb_rst_i;
	reg ram_cs_r;
	reg ram_wbs_ack_r;
	always @(negedge wb_clk_i) begin
	    if (wb_rst_i) begin
	        ram_cs_r <= 0;
	        ram_wbs_ack_r <= 0;
	    end
	    else begin
	        ram_cs_r <= !ram_cs_r && ram_cs;
	        ram_wbs_ack_r <= ram_cs_r;
	    end
	end
	     
	assign ram_clk0 = wb_clk_i;
	assign ram_csb0 = !ram_cs_r;
	assign ram_web0 = ~wbs_we_i;
	assign ram_wmask0 = wbs_sel_i;
	assign ram_addr0 = wbs_adr_i[ADDR_WIDTH-1:0];
	assign ram_dout0 = wbs_dat_i;
	
	assign wbs_dat_o = ram_din0;
	assign wbs_ack_o = ram_wbs_ack_r && ram_cs;




endmodule

`default_nettype wire
