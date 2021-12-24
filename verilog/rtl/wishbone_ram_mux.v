`default_nettype none

module wishbone_ram_mux
(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone UFP (Upward Facing Port)
    input           wb_clk_i,
    input           wb_rst_i,
    input           wbs_ufp_stb_i,
    input           wbs_ufp_cyc_i,
    input           wbs_ufp_we_i,
    input   [3:0]   wbs_ufp_sel_i,
    input   [31:0]  wbs_ufp_dat_i,
    input   [31:0]  wbs_ufp_adr_i,
    output          wbs_ufp_ack_o,
    output  [31:0]  wbs_ufp_dat_o,


    // Wishbone OR (Downward Facing Port) - SRAM8
    output          wbs_or8_stb_o,
    output          wbs_or8_cyc_o,
    output          wbs_or8_we_o,
    output  [3:0]   wbs_or8_sel_o,
    input   [31:0]  wbs_or8_dat_i,
//    input   [31:0]  wbs_or_adr_i,	// address connected directly from UFP
    input           wbs_or8_ack_i,
    output  [31:0]  wbs_or8_dat_o,


    // Wishbone OR (Downward Facing Port) - SRAM9
    output          wbs_or9_stb_o,
    output          wbs_or9_cyc_o,
    output          wbs_or9_we_o,
    output  [3:0]   wbs_or9_sel_o,
    input   [31:0]  wbs_or9_dat_i,
//    input   [31:0]  wbs_or_adr_i,	// address connected directly from UFP
    input           wbs_or9_ack_i,
    output  [31:0]  wbs_or9_dat_o

);

parameter SRAM8_BASE_ADDR = 32'h3000_0000;
parameter SRAM8_MASK = 32'hffff_ff00;

parameter SRAM9_BASE_ADDR = 32'h3000_0400;
parameter SRAM9_MASK = 32'hffff_fe00;


wire sram8_select;
assign sram8_select = ((wbs_ufp_adr_i & SRAM8_MASK) == SRAM8_BASE_ADDR);

wire sram9_select;
assign sram9_select = (((wbs_ufp_adr_i & SRAM9_MASK) == SRAM9_BASE_ADDR) && !sram8_select);

// UFP -> SRAM 8
assign wbs_or8_stb_o = wbs_ufp_stb_i & sram8_select;
assign wbs_or8_cyc_o = wbs_ufp_cyc_i;
assign wbs_or8_we_o = wbs_ufp_we_i & sram8_select;
assign wbs_or8_sel_o = wbs_ufp_sel_i & {4{sram8_select}};
assign wbs_or8_dat_o = wbs_ufp_dat_i & {32{sram8_select}};

// UFP -> SRAM 9
assign wbs_or9_stb_o = wbs_ufp_stb_i & sram9_select;
assign wbs_or9_cyc_o = wbs_ufp_cyc_i;
assign wbs_or9_we_o = wbs_ufp_we_i & sram9_select;
assign wbs_or9_sel_o = wbs_ufp_sel_i & {4{sram9_select}};
assign wbs_or9_dat_o = wbs_ufp_dat_i & {32{sram9_select}};

// HyperRAM or OpenRAM -> UFP
assign wbs_ufp_ack_o = (wbs_or8_ack_i & sram8_select) | (wbs_or9_ack_i & sram9_select);
assign wbs_ufp_dat_o = (wbs_or8_dat_i & {32{sram8_select}}) | (wbs_or9_dat_i & {32{sram9_select}});

endmodule

`default_nettype wire
