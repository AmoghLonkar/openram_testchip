`define assert(signal, value) \
if (!(signal === value)) begin \
   $display("ASSERTION FAILED in %m: signal != value"); \
   $finish;\
end

`timescale 1ns/1ns

`include "sky130_sram_1kbyte_1rw1r_32x256_8.v"
`include "sram_1rw0r0w_32_256_sky130.v"
`include "sram_1rw0r0w_32_512_sky130.v"
`include "sram_1rw0r0w_32_1024_sky130.v"
//`include "sram_1rw0r0w_64_512_sky130.v"
`include "openram_testchip.v"

module test_chip_tb;

  reg          la_clk;
  reg          gpio_clk;
  reg          la_sram_clk;
  reg          gpio_sram_clk;
  reg          reset;
  reg          la_in_load; 
  reg          gpio_in_scan;
  reg          la_sram_load;
  reg          gpio_sram_load;
  reg          gpio_out_scan;
  reg  [111:0] la_bits;
  reg          gpio_bit;
  reg          in_select;
  wire  [31:0] sram0_rw_in;
  wire  [31:0] sram0_ro_in;
  wire  [31:0] sram1_rw_in;
  wire  [31:0] sram1_ro_in;
  wire  [31:0] sram2_rw_in;
  wire  [31:0] sram3_rw_in;
  wire  [31:0] sram4_rw_in;
  //wire  [63:0] sram5_rw_in;
  wire [54:0] sram0_connections;
  wire [54:0] sram1_connections;
  wire [47:0] sram2_connections;
  wire [45:0] sram3_connections;
  wire [46:0] sram4_connections;
  //wire [82:0] sram5_connections;
  wire [31:0] la_data0;
  wire [31:0] la_data1;
  wire gpio_data0;
  wire gpio_data1;

openram_testchip CONTROL_LOGIC(
    .la_clk(la_clk),
    .gpio_clk(gpio_clk),
    .la_sram_clk(la_sram_clk),
    .gpio_sram_clk(gpio_sram_clk),
    .reset(reset),
    .la_in_load(la_in_load),
    .gpio_in_scan(gpio_in_scan),
    .la_sram_load(la_sram_load),
    .gpio_sram_load(gpio_sram_load),
    .gpio_out_scan(gpio_out_scan),
    .la_bits(la_bits),
    .gpio_bit(gpio_bit),
    .in_select(in_select),
    .sram0_rw_in(sram0_rw_in),
    .sram0_ro_in(sram0_ro_in),
    .sram1_rw_in(sram1_rw_in),
    .sram1_ro_in(sram1_ro_in),
    .sram2_rw_in(sram2_rw_in),
    .sram3_rw_in(sram3_rw_in),
    .sram4_rw_in(sram4_rw_in),
    //.sram5_rw_in(sram5_rw_out),
    .sram0_connections(sram0_connections),
    .sram1_connections(sram1_connections),
    .sram2_connections(sram2_connections),
    .sram3_connections(sram3_connections),
    .sram4_connections(sram4_connections),
    //.sram5_connections(sram5_connections),
    .la_data0(la_data0),
    .la_data1(la_data1),
    .gpio_data0(gpio_data0),
    .gpio_data1(gpio_data1)
);

sky130_sram_1kbyte_1rw1r_32x256_8 SRAM0
     (
      .clk0   (la_sram_clk),
      .csb0   (sram0_connections[54]),
      .web0   (sram0_connections[53]),
      .wmask0 (sram0_connections[52:49]),
      .addr0  (sram0_connections[48:41]),
      .din0   (sram0_connections[40:9]),
      .dout0  (sram0_rw_in),
      .clk1   (la_sram_clk),
      .csb1   (sram0_connections[8]),
      .addr1  (sram0_connections[7:0]),
      .dout1  (sram0_ro_in));

sky130_sram_1kbyte_1rw1r_32x256_8 SRAM1
     (
      .clk0   (la_sram_clk),
      .csb0   (sram1_connections[54]),
      .web0   (sram1_connections[53]),
      .wmask0 (sram1_connections[52:49]),
      .addr0  (sram1_connections[48:41]),
      .din0   (sram1_connections[40:9]),
      .dout0  (sram1_rw_in),
      .clk1   (la_sram_clk),
      .csb1   (sram1_connections[8]),
      .addr1  (sram1_connections[7:0]),
      .dout1  (sram1_ro_in));      

sram_1rw0r0w_32_1024_sky130 SRAM2
    (
      .clk0   (la_sram_clk),
      .csb0   (sram2_connections[47]),
      .web0   (sram2_connections[46]),
      .wmask0 (sram2_connections[45:42]),
      .addr0  (sram2_connections[41:32]),
      .din0   (sram2_connections[31:0]),
      .dout0  (sram2_rw_in)); 

sram_1rw0r0w_32_256_sky130 SRAM3
    (
      .clk0   (la_sram_clk),
      .csb0   (sram3_connections[45]),
      .web0   (sram3_connections[44]),
      .wmask0 (sram3_connections[43:40]),
      .addr0  (sram3_connections[39:32]),
      .din0   (sram3_connections[31:0]),
      .dout0  (sram3_rw_in));

sram_1rw0r0w_32_512_sky130 SRAM4
    (
      .clk0   (la_sram_clk),
      .csb0   (sram4_connections[46]),
      .web0   (sram4_connections[45]),
      .wmask0 (sram4_connections[44:41]),
      .addr0  (sram4_connections[40:32]),
      .din0   (sram4_connections[31:0]),
      .dout0  (sram4_rw_in));

/*
sram_1rw0r0w_64_512_sky130 SRAM5
    (
      .clk0   (sram5_connections[83]),
      .csb0   (sram5_connections[82]),
      .web0   (sram5_connections[81]),
      .wmask0 (sram5_connections[80:73]),
      .addr0  (sram5_connections[72:64]),
      .din0   (sram5_connections[63:0]),
      .dout0  (sram5_rw_out));
*/

initial begin
    $dumpfile("testchip_tb.vcd");
    $dumpvars(0, test_chip_tb);
    la_clk = 1;
    gpio_clk = 0;
    gpio_sram_clk = 0;
    gpio_in_scan = 0;
    gpio_bit = 0;
    gpio_out_scan = 0;
    reset = 0;
    
    //Send bits using logic analyzer
    in_select = 0;
    la_in_load = 1;
    la_bits = {4'd0, 16'd1, 32'd1, 1'b0, 1'b0, 4'd15, 16'd0, 32'd0, 1'b1, 1'b1, 4'd0};
    
    #10;
    la_in_load = 0;
    la_sram_load = 1;
    la_sram_clk = 1;
    #5
    la_sram_clk = 0;
    #5
    
    
    /*
    from_analyzer = 86'd0;
    from_gpio =  1'd0;
    
    //Write 1 to address 1 in SRAM 0
    from_analyzer = {3'd0, 28'd0, 1'b0, 1'b0, 4'd15, 8'd1, 32'd1, 1'b0, 8'd0};
    #20;

    //Read from address 1 in SRAM 0
    from_analyzer = {3'd0, 28'd0, 1'b0, 1'b1, 4'd0, 8'd1, 32'd0, 1'b1, 8'd0};
    #60;
    `assert(to_la, 64'd1);
    #30;$finish;
end

always 
    #5 la_clk = !la_clk;
endmodule
