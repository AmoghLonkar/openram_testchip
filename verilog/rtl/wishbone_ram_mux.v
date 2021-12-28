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
    input           wbs_or8_ack_i,
    output  [31:0]  wbs_or8_dat_o,


    // Wishbone OR (Downward Facing Port) - SRAM9
    output          wbs_or9_stb_o,
    output          wbs_or9_cyc_o,
    output          wbs_or9_we_o,
    output  [3:0]   wbs_or9_sel_o,
    input   [31:0]  wbs_or9_dat_i,
    input           wbs_or9_ack_i,
    output  [31:0]  wbs_or9_dat_o,


    // Wishbone OR (Downward Facing Port) - SRAM10
    output          wbs_or10_stb_o,
    output          wbs_or10_cyc_o,
    output          wbs_or10_we_o,
    output  [3:0]   wbs_or10_sel_o,
    input   [31:0]  wbs_or10_dat_i,
    input           wbs_or10_ack_i,
    output  [31:0]  wbs_or10_dat_o,


    // Wishbone OR (Downward Facing Port) - SRAM11
    output          wbs_or11_stb_o,
    output          wbs_or11_cyc_o,
    output          wbs_or11_we_o,
    output  [3:0]   wbs_or11_sel_o,
    input   [31:0]  wbs_or11_dat_i,
    input           wbs_or11_ack_i,
    output  [31:0]  wbs_or11_dat_o,


    // Wishbone OR (Downward Facing Port) - SRAM12
    output          wbs_or12_stb_o,
    output          wbs_or12_cyc_o,
    output          wbs_or12_we_o,
    output  [3:0]   wbs_or12_sel_o,
    input   [31:0]  wbs_or12_dat_i,
    input           wbs_or12_ack_i,
    output  [31:0]  wbs_or12_dat_o

);

parameter SRAM8_BASE_ADDR = 32'h3000_0000;
parameter SRAM8_MASK = 32'hffff_ff00;

parameter SRAM9_BASE_ADDR = 32'h3000_0400;
parameter SRAM9_MASK = 32'hffff_fe00;

parameter SRAM10_BASE_ADDR = 32'h3000_0c00;
parameter SRAM10_MASK = 32'hffff_fc00;

parameter SRAM11_BASE_ADDR = 32'h3000_1c00;
parameter SRAM11_MASK = 32'hffff_fe00;

parameter SRAM12_BASE_ADDR = 32'h3000_2c00;
parameter SRAM12_MASK = 32'hffff_fc00;

wire sram8_select;
assign sram8_select = ((wbs_ufp_adr_i & SRAM8_MASK) == SRAM8_BASE_ADDR);

wire sram9_select;
assign sram9_select = (((wbs_ufp_adr_i & SRAM9_MASK) == SRAM9_BASE_ADDR) && !sram8_select);

wire sram10_select;
assign sram10_select = (((wbs_ufp_adr_i & SRAM10_MASK) == SRAM10_BASE_ADDR) && !sram8_select && !sram9_select);

wire sram11_select;
assign sram11_select = (((wbs_ufp_adr_i & SRAM11_MASK) == SRAM11_BASE_ADDR) && !sram8_select && !sram9_select && !sram10_select);

wire sram12_select;
assign sram12_select = (((wbs_ufp_adr_i & SRAM12_MASK) == SRAM12_BASE_ADDR) && !sram8_select && !sram9_select && !sram10_select && !sram11_select);

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

// UFP -> SRAM 10
assign wbs_or10_stb_o = wbs_ufp_stb_i & sram10_select;
assign wbs_or10_cyc_o = wbs_ufp_cyc_i;
assign wbs_or10_we_o = wbs_ufp_we_i & sram10_select;
assign wbs_or10_sel_o = wbs_ufp_sel_i & {4{sram10_select}};
assign wbs_or10_dat_o = wbs_ufp_dat_i & {32{sram10_select}};

// UFP -> SRAM 11
assign wbs_or11_stb_o = wbs_ufp_stb_i & sram11_select;
assign wbs_or11_cyc_o = wbs_ufp_cyc_i;
assign wbs_or11_we_o = wbs_ufp_we_i & sram11_select;
assign wbs_or11_sel_o = wbs_ufp_sel_i & {4{sram11_select}};
assign wbs_or11_dat_o = wbs_ufp_dat_i & {32{sram11_select}};

// UFP -> SRAM 12
assign wbs_or12_stb_o = wbs_ufp_stb_i & sram12_select;
assign wbs_or12_cyc_o = wbs_ufp_cyc_i;
assign wbs_or12_we_o = wbs_ufp_we_i & sram12_select;
assign wbs_or12_sel_o = wbs_ufp_sel_i & {4{sram12_select}};
assign wbs_or12_dat_o = wbs_ufp_dat_i & {32{sram12_select}};

// SRAM8 or SRAM9 -> UFP
assign wbs_ufp_ack_o = (wbs_or8_ack_i & sram8_select) | (wbs_or9_ack_i & sram9_select) | (wbs_or10_ack_i & sram10_select) | (wbs_or11_ack_i & sram11_select) | (wbs_or12_ack_i & sram12_select);

assign wbs_ufp_dat_o = (wbs_or8_dat_i & {32{sram8_select}}) | (wbs_or9_dat_i & {32{sram9_select}}) | (wbs_or10_dat_i & {32{sram10_select}}) | (wbs_or11_dat_i & {32{sram11_select}}) | (wbs_or12_dat_i & {32{sram12_select}});

endmodule

`default_nettype wire
