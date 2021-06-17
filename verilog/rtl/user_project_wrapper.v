// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
`include "openram_defines.v"
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
) (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

   // Shared control/data to the SRAMs
   wire [`ADDR_SIZE-1:0] addr0;
   wire [`DATA_SIZE-1:0] din0;
   wire 		 web0;
   wire [`WMASK_SIZE-1:0] wmask0;
   wire [`ADDR_SIZE-1:0]  addr1;
   wire [`DATA_SIZE-1:0]  din1;
   wire 		  web1;
   wire [`WMASK_SIZE-1:0] wmask1;
   // One CSB for each SRAM
   wire [`MAX_CHIPS-1:0]  csb0;
   wire [`MAX_CHIPS-1:0]  csb1;

   wire     in_select = io_in[16];
   wire     resetn = io_in[15];
   wire     gpio_clk = io_in[17];
   wire     gpio_sram_clk = io_in[18];
   wire     gpio_scan = io_in[19];
   wire     gpio_sram_load = io_in[20];

   // Only io_out[21] is output
   assign io_oeb = ~(1'b1 << 21);
   // Assign other outputs to 0
   assign io_out[`MPRJ_IO_PADS:22] = 0;
   wire     gpio_out;
   assign io_out[21] = gpio_out;
   assign io_out[20:0] = 0;

   wire sram_clk;
   clock_mux clkmux(.clk0(la_data_in[126]),
		    .clk1(gpio_sram_clk),
		    .sel(in_select),
		    .clk(sram_clk));


   openram_testchip CONTROL_LOGIC(
				  .resetn(resetn & wb_rst_i),
				  .in_select(in_select),
				  .gpio_clk(gpio_clk),
				  .gpio_scan(gpio_scan),
				  .gpio_sram_load(gpio_sram_load),

				  .la_clk(la_data_in[127]),
				  .la_in_load(la_data_in[125]),
				  .la_sram_load(la_data_in[124]),
				  .la_data_in(la_data_in[111:0]),
				  .la_data_out(la_data_out[111:0]),
				  .gpio_out(gpio_out),

				  // Shared control/data to the SRAMs
				  .left_addr0(left_addr0),
				  .left_din0(left_din0),
				  .left_web0(left_web0),
				  .left_wmask0(left_wmask0),
				  .left_addr1(left_addr1),
				  .left_web1(left_web1),
				  .left_wmask1(left_wmask1),
				  // One CSB for each SRAM
				  .left_csb0(left_csb0),
				  .left_csb1(left_csb1),

				  // Shared control/data to the SRAMs
				  .right_addr0(right_addr0),
				  .right_din0(right_din0),
				  .right_web0(right_web0),
				  .right_wmask0(right_wmask0),
				  // One CSB for each SRAM
				  .right_csb0(right_csb0),

				  // SRAM data outputs to be captured
				  .sram0_data0(sram0_data0),
				  .sram0_data1(sram0_data1),
				  .sram1_data0(sram1_data0),
				  .sram1_data1(sram1_data1),
				  .sram2_data0(sram2_data0),
				  .sram2_data1(sram2_data1),
				  .sram3_data0(sram3_data0),
				  .sram3_data1(sram3_data1),
				  .sram4_data0(sram4_data0),
				  .sram4_data1(sram4_data1),
				  .sram5_data0(sram5_data0),
				  .sram5_data1(sram5_data1),
				  .sram6_data0(sram6_data0),
				  .sram6_data1(sram6_data1),
				  .sram7_data0(sram7_data0),
				  .sram7_data1(sram7_data1),
				  .sram8_data0(sram8_data0),
				  .sram8_data1(sram8_data1),
				  .sram9_data0(sram9_data0),
				  .sram9_data1(sram9_data1),
				  .sram10_data0(sram10_data0),
				  .sram10_data1(sram10_data1),
				  .sram11_data0(sram11_data0),
				  .sram11_data1(sram11_data1),
				  .sram12_data0(sram12_data0),
				  .sram12_data1(sram12_data1),
				  .sram13_data0(sram13_data0),
				  .sram13_data1(sram13_data1),
				  .sram14_data0(sram14_data0),
				  .sram14_data1(sram14_data1),
				  .sram15_data0(sram15_data0),
				  .sram15_data1(sram15_data1)

				  );

   wire [`ADDR_SIZE-1:0] left_addr0;
   wire [`DATA_SIZE-1:0] left_din0;
   wire 		 left_web0;
   wire [`WMASK_SIZE-1:0] left_wmask0;
   wire [`ADDR_SIZE-1:0]  left_addr1;
   wire [`DATA_SIZE-1:0]  left_din1;
   wire 		  left_web1;
   wire [`WMASK_SIZE-1:0] left_wmask1;
   wire [`MAX_CHIPS-1:0]  left_csb0;
   wire [`MAX_CHIPS-1:0]  left_csb1;

   wire [`ADDR_SIZE-1:0]  right_addr0;
   wire [`DATA_SIZE-1:0]  right_din0;
   wire 		  right_web0;
   wire [`WMASK_SIZE-1:0] right_wmask0;
   wire [`MAX_CHIPS-1:0]  right_csb0;

   wire [`DATA_SIZE-1:0]  sram0_dout0;
   wire [`DATA_SIZE-1:0]  sram0_dout1;
   wire [`DATA_SIZE-1:0]  sram1_dout0;
   wire [`DATA_SIZE-1:0]  sram1_dout1;
   wire [`DATA_SIZE-1:0]  sram2_dout0;
   wire [`DATA_SIZE-1:0]  sram2_dout1;
   wire [`DATA_SIZE-1:0]  sram3_dout0;
   wire [`DATA_SIZE-1:0]  sram3_dout1;
   wire [`DATA_SIZE-1:0]  sram4_dout0;
   wire [`DATA_SIZE-1:0]  sram4_dout1;
   wire [`DATA_SIZE-1:0]  sram5_dout0;
   wire [`DATA_SIZE-1:0]  sram5_dout1;
   wire [`DATA_SIZE-1:0]  sram6_dout0;
   wire [`DATA_SIZE-1:0]  sram6_dout1;
   wire [`DATA_SIZE-1:0]  sram7_dout0;
   wire [`DATA_SIZE-1:0]  sram7_dout1;
   wire [`DATA_SIZE-1:0]  sram8_dout0;
   wire [`DATA_SIZE-1:0]  sram8_dout1;
   wire [`DATA_SIZE-1:0]  sram9_dout0;
   wire [`DATA_SIZE-1:0]  sram9_dout1;
   wire [`DATA_SIZE-1:0]  sram10_dout0;
   wire [`DATA_SIZE-1:0]  sram10_dout1;
   wire [`DATA_SIZE-1:0]  sram11_dout0;
   wire [`DATA_SIZE-1:0]  sram11_dout1;
   wire [`DATA_SIZE-1:0]  sram12_dout0;
   wire [`DATA_SIZE-1:0]  sram12_dout1;
   wire [`DATA_SIZE-1:0]  sram13_dout0;
   wire [`DATA_SIZE-1:0]  sram13_dout1;
   wire [`DATA_SIZE-1:0]  sram14_dout0;
   wire [`DATA_SIZE-1:0]  sram14_dout1;
   wire [`DATA_SIZE-1:0]  sram15_dout0;
   wire [`DATA_SIZE-1:0]  sram15_dout1;

sky130_sram_1kbyte_1rw1r_8x1024_8 SRAM0
     (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (sram_clk),
      .csb0   (left_csb0[0]),
      .web0   (left_web0),
      .wmask0 (left_wmask0),
      .addr0  (left_addr0),
      .din0   (left_din0),
      .dout0  (sram0_dout0[7:0]),
      .clk1   (sram_clk),
      .csb1   (left_csb1[0]),
      .addr1  (left_addr1),
      .dout1  (sram0_dout1[7:0])
      );
   assign sram0_dout0[`DATA_SIZE-1:8] = 0;
   assign sram0_dout1[`DATA_SIZE-1:8] = 0;

sky130_sram_1kbyte_1rw1r_32x256_8 SRAM1
     (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (sram_clk),
      .csb0   (left_csb0[1]),
      .web0   (left_web0),
      .wmask0 (left_wmask0),
      .addr0  (left_addr0),
      .din0   (left_din0),
      .dout0  (sram1_dout0),
      .clk1   (sram_clk),
      .csb1   (left_csb1[1]),
      .addr1  (left_addr1),
      .dout1  (sram1_dout1)
      );

sky130_sram_2kbyte_1rw1r_32x512_8 SRAM2
     (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (sram_clk),
      .csb0   (left_csb0[2]),
      .web0   (left_web0),
      .wmask0 (left_wmask0),
      .addr0  (left_addr0),
      .din0   (left_din0),
      .dout0  (sram2_dout0),
      .clk1   (sram_clk),
      .csb1   (left_csb1[2]),
      .addr1  (left_addr1),
      .dout1  (sram2_dout1)
      );

sky130_sram_4kbyte_1rw1r_32x1024_8 SRAM3
     (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (sram_clk),
      .csb0   (left_csb0[3]),
      .web0   (left_web0),
      .wmask0 (left_wmask0),
      .addr0  (left_addr0),
      .din0   (left_din0),
      .dout0  (sram3_dout0),
      .clk1   (sram_clk),
      .csb1   (left_csb1[3]),
      .addr1  (left_addr1),
      .dout1  (sram3_dout1)
      );

sky130_sram_8kbyte_1rw1r_32x2048_8 SRAM4
     (
     `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (sram_clk),
      .csb0   (left_csb0[4]),
      .web0   (left_web0),
      .wmask0 (left_wmask0),
      .addr0  (left_addr0),
      .din0   (left_din0),
      .dout0  (sram4_dout0),
      .clk1   (sram_clk),
      .csb1   (left_csb1[4]),
      .addr1  (left_addr1),
      .dout1  (sram4_dout1)
      );

// Not working yet
// sky130_sram_16kbyte_1rw1r_32x4096_8 SRAM6
//      (
//      `ifdef USE_POWER_PINS
//       .vccd1(vccd1),
//       .vssd1(vssd1),
//       `endif
//       .clk0   (sram_clk),
//       .csb0   (csb0[6]),
//       .web0   (web0),
//       .wmask0 (wmask0),
//       .addr0  (addr0),
//       .din0   (din0),
//       .dout0  (sram6_dout0),
//       .clk1   (sram_clk),
//       .csb1   (csb1[6]),
//       .addr1  (addr1),
//       .dout1  (sram6_dout1)
//       );



// Single port memories
sram_1rw0r0w_32_256_sky130 SRAM8
    (
      `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (sram_clk),
      .csb0   (right_csb0[8]),
      .web0   (right_web0),
      .wmask0 (right_wmask0),
      .addr0  (right_addr0),
      .din0   (right_din0),
      .dout0  (sram8_dout0)
     );
   assign sram8_dout1 = 0;

sram_1rw0r0w_32_512_sky130 SRAM9
    (
      `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (sram_clk),
      .csb0   (right_csb0[9]),
      .web0   (right_web0),
      .wmask0 (right_wmask0),
      .addr0  (right_addr0),
      .din0   (right_din0),
      .dout0  (sram9_dout0)
     );
   assign sram9_dout1 = 0;

sram_1rw0r0w_32_1024_sky130 SRAM10
    (
      `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (sram_clk),
      .csb0   (right_csb0[10]),
      .web0   (right_web0),
      .wmask0 (right_wmask0),
      .addr0  (right_addr0),
      .din0   (right_din0),
      .dout0  (sram10_dout0)
     );
   assign sram10_dout1 = 0;

   wire [63:0] temp_sram11_dout0;
sram_1rw0r0w_64_512_sky130 SRAM11
    (
      `ifdef USE_POWER_PINS
      .vccd1(vccd1),
      .vssd1(vssd1),
      `endif
      .clk0   (sram_clk),
      .csb0   (right_csb0[11]),
      .web0   (right_web0),
      .wmask0 (right_wmask0),
      .addr0  (right_addr0),
      .din0   ({right_din0[31:16], 32'd0, right_din0[15:0]}),
      .dout0  (temp_sram11_dout0)
     );
   assign sram11_dout1 = 0;
   assign sram11_dout0 = {temp_sram11_dout0[64:49], temp_sram11_dout0[15:0]};

// Hold dout from SRAM
// clocked by SRAM clk
reg [`DATA_SIZE-1:0] sram0_data0;
reg [`DATA_SIZE-1:0] sram0_data1;
reg [`DATA_SIZE-1:0] sram1_data0;
reg [`DATA_SIZE-1:0] sram1_data1;
reg [`DATA_SIZE-1:0] sram2_data0;
reg [`DATA_SIZE-1:0] sram2_data1;
reg [`DATA_SIZE-1:0] sram3_data0;
reg [`DATA_SIZE-1:0] sram3_data1;
reg [`DATA_SIZE-1:0] sram4_data0;
reg [`DATA_SIZE-1:0] sram4_data1;
//reg [`DATA_SIZE-1:0] sram5_data0;
//reg [`DATA_SIZE-1:0] sram5_data1;
//reg [`DATA_SIZE-1:0] sram6_data0;
//reg [`DATA_SIZE-1:0] sram6_data1;
//reg [`DATA_SIZE-1:0] sram7_data0;
//reg [`DATA_SIZE-1:0] sram7_data1;
reg [`DATA_SIZE-1:0] sram8_data0;
reg [`DATA_SIZE-1:0] sram8_data1;
reg [`DATA_SIZE-1:0] sram9_data0;
reg [`DATA_SIZE-1:0] sram9_data1;
reg [`DATA_SIZE-1:0] sram10_data0;
reg [`DATA_SIZE-1:0] sram10_data1;
reg [`DATA_SIZE-1:0] sram11_data0;
reg [`DATA_SIZE-1:0] sram11_data1;
//reg [`DATA_SIZE-1:0] sram12_data0;
//reg [`DATA_SIZE-1:0] sram12_data1;
//reg [`DATA_SIZE-1:0] sram13_data0;
//reg [`DATA_SIZE-1:0] sram13_data1;
//reg [`DATA_SIZE-1:0] sram14_data0;
//reg [`DATA_SIZE-1:0] sram14_data1;
//reg [`DATA_SIZE-1:0] sram15_data0;
//reg [`DATA_SIZE-1:0] sram15_data1;

always @(posedge sram_clk) begin
   if (!resetn) begin
      sram0_data0 <= 0;
      sram0_data1 <= 0;
      sram1_data0 <= 0;
      sram1_data1 <= 0;
      sram2_data0 <= 0;
      sram2_data1 <= 0;
      sram3_data0 <= 0;
      sram3_data1 <= 0;
      sram4_data0 <= 0;
      sram4_data1 <= 0;
      // sram5_data0 <= 0;
      // sram5_data1 <= 0;
      // sram6_data0 <= 0;
      // sram6_data1 <= 0;
      // sram7_data0 <= 0;
      // sram7_data1 <= 0;
      sram8_data0 <= 0;
      sram8_data1 <= 0;
      sram9_data0 <= 0;
      sram9_data1 <= 0;
      sram10_data0 <= 0;
      sram10_data1 <= 0;
      sram11_data0 <= 0;
      sram11_data1 <= 0;
      //sram12_data0 <= 0;
      //sram12_data1 <= 0;
      //sram13_data0 <= 0;
      //sram13_data1 <= 0;
      //sram14_data0 <= 0;
      //sram14_data1 <= 0;
      //sram15_data0 <= 0;
      //sram15_data1 <= 0;
   end
   else begin
       sram0_data0 <= sram0_dout0;
       sram0_data1 <= sram0_dout1;
       sram1_data0 <= sram1_dout0;
       sram1_data1 <= sram1_dout1;
       sram2_data0 <= sram2_dout0;
       sram2_data1 <= sram2_dout1;
       sram3_data0 <= sram3_dout0;
       sram3_data1 <= sram3_dout1;
       sram4_data0 <= sram4_dout0;
       sram4_data1 <= sram4_dout1;
       // sram5_data0 <= sram5_dout0;
       // sram5_data1 <= sram5_dout1;
       // sram6_data0 <= sram6_dout0;
       // sram6_data1 <= sram6_dout1;
       // sram7_data0 <= sram7_dout0;
       // sram7_data1 <= sram7_dout1;
       sram8_data0 <= sram8_dout0;
       sram8_data1 <= sram8_dout1;
       sram9_data0 <= sram9_dout0;
       sram9_data1 <= sram9_dout1;
       sram10_data0 <= sram10_dout0;
       sram10_data1 <= sram10_dout1;
       sram11_data0 <= sram11_dout0;
       sram11_data1 <= sram11_dout1;
       // sram12_data0 <= sram12_dout0;
       // sram12_data1 <= sram12_dout1;
       // sram13_data0 <= sram13_dout0;
       // sram13_data1 <= sram13_dout1;
       // sram14_data0 <= sram14_dout0;
       // sram14_data1 <= sram14_dout1;
       // sram15_data0 <= sram15_dout0;
       // sram15_data1 <= sram15_dout1;
   end // else: !if(in_reset)
end

   wire [`DATA_SIZE-1:0] sram5_data0 = 0;
   wire [`DATA_SIZE-1:0] sram5_data1 = 0;
   wire [`DATA_SIZE-1:0] sram6_data0 = 0;
   wire [`DATA_SIZE-1:0] sram6_data1 = 0;
   wire [`DATA_SIZE-1:0] sram7_data0 = 0;
   wire [`DATA_SIZE-1:0] sram7_data1 = 0;
   wire [`DATA_SIZE-1:0] sram12_data0 = 0;
   wire [`DATA_SIZE-1:0] sram12_data1 = 0;
   wire [`DATA_SIZE-1:0] sram13_data0 = 0;
   wire [`DATA_SIZE-1:0] sram13_data1 = 0;
   wire [`DATA_SIZE-1:0] sram14_data0 = 0;
   wire [`DATA_SIZE-1:0] sram14_data1 = 0;
   wire [`DATA_SIZE-1:0] sram15_data0 = 0;
   wire [`DATA_SIZE-1:0] sram15_data1 = 0;

endmodule	// user_project_wrapper

`default_nettype wire
