
module openram_testchip(
`ifdef USE_POWER_PINS
			inout vdda1,        // User area 1 3.3V supply
			inout vdda2,        // User area 2 3.3V supply
			inout vssa1,        // User area 1 analog ground
			inout vssa2,        // User area 2 analog ground
			inout vccd1,        // User area 1 1.8V supply
			inout vccd2,        // User area 2 1.8v supply
			inout vssd1,        // User area 1 digital ground
			inout vssd2,        // User area 2 digital ground
`endif
			input         resetn,
			input         clk,
			input 		  mode_select,
			input         la_in_load,
			input         la_sram_load,
			input  [`TOTAL_SIZE-1:0] la_data_in,
			// GPIO bit to clock control register
			input         gpio_in,
			input         gpio_scan,
			input         gpio_sram_load,
			input         global_csb,
			// wishbone related control signals
    		input wb_clk_i,
    		input wb_rst_i,
    		input wbs_stb_i,
    		input wbs_cyc_i,
    		input wbs_we_i,
    		input [3:0] wbs_sel_i,
    		input [31:0] wbs_dat_i,
    		input [31:0] wbs_adr_i,
			input  [`DATA_SIZE-1:0] wbs_sram8_data,
			input  [`DATA_SIZE-1:0] wbs_sram9_data,
			input  [`DATA_SIZE-1:0] wbs_sram10_data,
			input  [`DATA_SIZE-1:0] wbs_sram11_data,
			input  [`DATA_SIZE-1:0] wbs_sram12_data,
    		output wbs_ack_o,
    		output [31:0] wbs_dat_o,
			// SRAM data outputs to be captured
			input  [`DATA_SIZE-1:0] sram0_data0,
			input  [`DATA_SIZE-1:0] sram0_data1,
			input  [`DATA_SIZE-1:0] sram1_data0,
			input  [`DATA_SIZE-1:0] sram1_data1,
			input  [`DATA_SIZE-1:0] sram2_data0,
			input  [`DATA_SIZE-1:0] sram2_data1,
			input  [`DATA_SIZE-1:0] sram3_data0,
			input  [`DATA_SIZE-1:0] sram3_data1,
			input  [`DATA_SIZE-1:0] sram4_data0,
			input  [`DATA_SIZE-1:0] sram4_data1,
			input  [`DATA_SIZE-1:0] sram5_data0,
			input  [`DATA_SIZE-1:0] sram5_data1,
			input  [`DATA_SIZE-1:0] sram6_data0,
			input  [`DATA_SIZE-1:0] sram6_data1,
			input  [`DATA_SIZE-1:0] sram7_data0,
			input  [`DATA_SIZE-1:0] sram7_data1,
			input  [`DATA_SIZE-1:0] sram8_data0,
			input  [`DATA_SIZE-1:0] sram8_data1,
			input  [`DATA_SIZE-1:0] sram9_data0,
			input  [`DATA_SIZE-1:0] sram9_data1,
			input  [`DATA_SIZE-1:0] sram10_data0,
			input  [`DATA_SIZE-1:0] sram10_data1,
			input  [`DATA_SIZE-1:0] sram11_data0,
			input  [`DATA_SIZE-1:0] sram11_data1,
			input  [`DATA_SIZE-1:0] sram12_data0,
			input  [`DATA_SIZE-1:0] sram12_data1,
			input  [`DATA_SIZE-1:0] sram13_data0,
			input  [`DATA_SIZE-1:0] sram13_data1,
			input  [`DATA_SIZE-1:0] sram14_data0,
			input  [`DATA_SIZE-1:0] sram14_data1,
			input  [`DATA_SIZE-1:0] sram15_data0,
			input  [`DATA_SIZE-1:0] sram15_data1,

			// Shared control/data to the SRAMs
			output reg [`ADDR_SIZE-1:0] addr0,
			output reg [`DATA_SIZE-1:0] din0,
			output reg 	  web0,
			output reg [`WMASK_SIZE-1:0]  wmask0,
			output reg [`ADDR_SIZE-1:0] addr1,
			output reg [`DATA_SIZE-1:0] din1,
			output reg 	  web1,
			output reg [`WMASK_SIZE-1:0]  wmask1,
			// One CSB for each SRAM
			// One CSB for each SRAM
			output reg [`MAX_CHIPS-1:0] csb0,
			output reg [`MAX_CHIPS-1:0] csb1,

			output reg [`TOTAL_SIZE-1:0] la_data_out,
			output reg gpio_out
);

// Store input instruction
   reg [`TOTAL_SIZE-1:0] sram_register;
   reg 		       csb0_temp;
   reg 		       csb1_temp;

   // Mux output to connect final output data
   // into sram_register
   reg [`DATA_SIZE-1:0] read_data0;
   reg [`DATA_SIZE-1:0] read_data1;

   // SRAM input connections
   reg [`SELECT_SIZE-1:0]  chip_select;

// wires connecting sram8 wrapper to sram8 macro
	wire ram8_clk0;
	wire ram8_csb0;
	wire ram8_web0;
	wire [`WMASK_SIZE-1:0] ram8_wmask0;
	wire [7:0] ram8_addr0;
	wire [31:0] ram8_din0;
	wire [31:0] ram8_dout0;
// wires connecting sram9 wrapper to sram9 macro
	wire ram9_clk0;
	wire ram9_csb0;
	wire ram9_web0;
	wire [`WMASK_SIZE-1:0] ram9_wmask0;
	wire [7:0] ram9_addr0;
	wire [31:0] ram9_din0;
	wire [31:0] ram9_dout0;
// wires connecting sram10 wrapper to sram10 macro
	wire ram10_clk0;
	wire ram10_csb0;
	wire ram10_web0;
	wire [`WMASK_SIZE-1:0] ram10_wmask0;
	wire [7:0] ram10_addr0;
	wire [31:0] ram10_din0;
	wire [31:0] ram10_dout0;
// wires connecting sram11 wrapper to sram11 macro
	wire ram11_clk0;
	wire ram11_csb0;
	wire ram11_web0;
	wire [`WMASK_SIZE-1:0] ram11_wmask0;
	wire [7:0] ram11_addr0;
	wire [31:0] ram11_din0;
	wire [31:0] ram11_dout0;
// wires connecting sram12 wrapper to sram12 macro
	wire ram12_clk0;
	wire ram12_csb0;
	wire ram12_web0;
	wire [`WMASK_SIZE-1:0] ram12_wmask0;
	wire [7:0] ram12_addr0;
	wire [31:0] ram12_din0;
	wire [31:0] ram12_dout0;
// wires connecting between mux & sram8
	wire wbs_or8_stb;
	wire wbs_or8_cyc;
	wire wbs_or8_we;
	wire [3:0] wbs_or8_sel;
	wire [31:0] wbs_or8_dat_i;
	wire wbs_or8_ack;
	wire [31:0] wbs_or8_dat_o;
// wires connecting between mux & sram9
	wire wbs_or9_stb;
	wire wbs_or9_cyc;
	wire wbs_or9_we;
	wire [3:0] wbs_or9_sel;
	wire [31:0] wbs_or9_dat_i;
	wire wbs_or9_ack;
	wire [31:0] wbs_or9_dat_o;
// wires connecting between mux & sram10
	wire wbs_or10_stb;
	wire wbs_or10_cyc;
	wire wbs_or10_we;
	wire [3:0] wbs_or10_sel;
	wire [31:0] wbs_or10_dat_i;
	wire wbs_or10_ack;
	wire [31:0] wbs_or10_dat_o;
// wires connecting between mux & sram11
	wire wbs_or11_stb;
	wire wbs_or11_cyc;
	wire wbs_or11_we;
	wire [3:0] wbs_or11_sel;
	wire [31:0] wbs_or11_dat_i;
	wire wbs_or11_ack;
	wire [31:0] wbs_or11_dat_o;
// wires connecting between mux & sram12
	wire wbs_or12_stb;
	wire wbs_or12_cyc;
	wire wbs_or12_we;
	wire [3:0] wbs_or12_sel;
	wire [31:0] wbs_or12_dat_i;
	wire wbs_or12_ack;
	wire [31:0] wbs_or12_dat_o;

always @ (posedge clk) begin
   if(!resetn) begin
      sram_register <= {`TOTAL_SIZE{1'b0}};
   end
   // GPIO scanning for transfer
   else if(gpio_scan) begin
      sram_register <= {sram_register[`TOTAL_SIZE-2:0], gpio_in};
   end
   // LA parallel load
   else if(la_in_load) begin
      sram_register <= la_data_in;
   end
   // Store results for read out
   else if(gpio_sram_load || la_sram_load) begin

      sram_register <= {sram_register[`TOTAL_SIZE-1:`TOTAL_SIZE-`SELECT_SIZE-`ADDR_SIZE],
			read_data0,
			sram_register[`ADDR_SIZE+`DATA_SIZE+`WMASK_SIZE+`WMASK_SIZE+3:`DATA_SIZE+`WMASK_SIZE+2],
			read_data1,
			sram_register[`WMASK_SIZE+1:0]};
   end
end

	wishbone_ram_mux WB_RAM_MUX(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
		// main wishbone signals coming here
    	.wbs_ufp_stb_i(wbs_stb_i),
    	.wbs_ufp_cyc_i(wbs_cyc_i),
    	.wbs_ufp_we_i(wbs_we_i),
    	.wbs_ufp_sel_i(wbs_sel_i),
    	.wbs_ufp_dat_i(wbs_dat_i),
    	.wbs_ufp_adr_i(wbs_adr_i),
    	.wbs_ufp_ack_o(wbs_ack_o),
    	.wbs_ufp_dat_o(wbs_dat_o),
		// wishbone signals to sram 8
    	.wbs_or8_stb_o(wbs_or8_stb),
    	.wbs_or8_cyc_o(wbs_or8_cyc),
    	.wbs_or8_we_o(wbs_or8_we),
    	.wbs_or8_sel_o(wbs_or8_sel),
    	.wbs_or8_dat_i(wbs_or8_dat_i),
    	.wbs_or8_ack_i(wbs_or8_ack),
    	.wbs_or8_dat_o(wbs_or8_dat_o),
		// wishbone signals to sram 9
    	.wbs_or9_stb_o(wbs_or9_stb),
    	.wbs_or9_cyc_o(wbs_or9_cyc),
    	.wbs_or9_we_o(wbs_or9_we),
    	.wbs_or9_sel_o(wbs_or9_sel),
    	.wbs_or9_dat_i(wbs_or9_dat_i),
    	.wbs_or9_ack_i(wbs_or9_ack),
    	.wbs_or9_dat_o(wbs_or9_dat_o),
		// wishbone signals to sram 10
    	.wbs_or10_stb_o(wbs_or10_stb),
    	.wbs_or10_cyc_o(wbs_or10_cyc),
    	.wbs_or10_we_o(wbs_or10_we),
    	.wbs_or10_sel_o(wbs_or10_sel),
    	.wbs_or10_dat_i(wbs_or10_dat_i),
    	.wbs_or10_ack_i(wbs_or10_ack),
    	.wbs_or10_dat_o(wbs_or10_dat_o),
		// wishbone signals to sram 11
    	.wbs_or11_stb_o(wbs_or11_stb),
    	.wbs_or11_cyc_o(wbs_or11_cyc),
    	.wbs_or11_we_o(wbs_or11_we),
    	.wbs_or11_sel_o(wbs_or11_sel),
    	.wbs_or11_dat_i(wbs_or11_dat_i),
    	.wbs_or11_ack_i(wbs_or11_ack),
    	.wbs_or11_dat_o(wbs_or11_dat_o),
		// wishbone signals to sram 12
    	.wbs_or12_stb_o(wbs_or12_stb),
    	.wbs_or12_cyc_o(wbs_or12_cyc),
    	.wbs_or12_we_o(wbs_or12_we),
    	.wbs_or12_sel_o(wbs_or12_sel),
    	.wbs_or12_dat_i(wbs_or12_dat_i),
    	.wbs_or12_ack_i(wbs_or12_ack),
    	.wbs_or12_dat_o(wbs_or12_dat_o)
	);

	wishbone_wrapper #(.BASE_ADDR(32'h3000_0000), .ADDR_WIDTH(8)) SRAM8_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or8_stb),
    	.wbs_cyc_i(wbs_or8_cyc),
    	.wbs_we_i(wbs_or8_we),
    	.wbs_sel_i(wbs_or8_sel),
    	.wbs_dat_i(wbs_or8_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or8_ack),
    	.wbs_dat_o(wbs_or8_dat_i),
		// OpenRAM interface
    	.ram_clk0(ram8_clk0),       // (output) clock
    	.ram_csb0(ram8_csb0),       // (output) active low chip select
    	.ram_web0(ram8_web0),       // (output) active low write control
    	.ram_wmask0(ram8_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram8_addr0),	   // (output)
    	.ram_din0(wbs_sram8_data),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram8_din0)	   // (output) read from wb and sent to sram
	);

	wishbone_wrapper #(.BASE_ADDR(32'h3000_0400), .ADDR_WIDTH(9)) SRAM9_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or9_stb),
    	.wbs_cyc_i(wbs_or9_cyc),
    	.wbs_we_i(wbs_or9_we),
    	.wbs_sel_i(wbs_or9_sel),
    	.wbs_dat_i(wbs_or9_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or9_ack),
    	.wbs_dat_o(wbs_or9_dat_i),
		// OpenRAM interface
    	.ram_clk0(ram9_clk0),       // (output) clock
    	.ram_csb0(ram9_csb0),       // (output) active low chip select
    	.ram_web0(ram9_web0),       // (output) active low write control
    	.ram_wmask0(ram9_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram9_addr0),	   // (output)
    	.ram_din0(wbs_sram9_data),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram9_din0)	   // (output) read from wb and sent to sram
	);

	wishbone_wrapper #(.BASE_ADDR(32'h3000_0c00), .ADDR_WIDTH(10)) SRAM10_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or10_stb),
    	.wbs_cyc_i(wbs_or10_cyc),
    	.wbs_we_i(wbs_or10_we),
    	.wbs_sel_i(wbs_or10_sel),
    	.wbs_dat_i(wbs_or10_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or10_ack),
    	.wbs_dat_o(wbs_or10_dat_i),
		// OpenRAM interface
    	.ram_clk0(ram10_clk0),       // (output) clock
    	.ram_csb0(ram10_csb0),       // (output) active low chip select
    	.ram_web0(ram10_web0),       // (output) active low write control
    	.ram_wmask0(ram10_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram10_addr0),	   // (output)
    	.ram_din0(wbs_sram10_data),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram10_din0)	   // (output) read from wb and sent to sram
	);

	wishbone_wrapper #(.BASE_ADDR(32'h3000_1c00), .ADDR_WIDTH(9)) SRAM11_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or11_stb),
    	.wbs_cyc_i(wbs_or11_cyc),
    	.wbs_we_i(wbs_or11_we),
    	.wbs_sel_i(wbs_or11_sel),
    	.wbs_dat_i(wbs_or11_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or11_ack),
    	.wbs_dat_o(wbs_or11_dat_i),
		// OpenRAM interface
    	.ram_clk0(ram11_clk0),       // (output) clock
    	.ram_csb0(ram11_csb0),       // (output) active low chip select
    	.ram_web0(ram11_web0),       // (output) active low write control
    	.ram_wmask0(ram11_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram11_addr0),	   // (output)
    	.ram_din0(wbs_sram11_data),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram11_din0)	   // (output) read from wb and sent to sram
	);

	wishbone_wrapper #(.BASE_ADDR(32'h3000_2c00), .ADDR_WIDTH(10)) SRAM12_WRAPPER(
    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),
    	.wbs_stb_i(wbs_or12_stb),
    	.wbs_cyc_i(wbs_or12_cyc),
    	.wbs_we_i(wbs_or12_we),
    	.wbs_sel_i(wbs_or12_sel),
    	.wbs_dat_i(wbs_or12_dat_o),
    	.wbs_adr_i(wbs_adr_i),
    	.wbs_ack_o(wbs_or12_ack),
    	.wbs_dat_o(wbs_or12_dat_i),
		// OpenRAM interface
    	.ram_clk0(ram12_clk0),       // (output) clock
    	.ram_csb0(ram12_csb0),       // (output) active low chip select
    	.ram_web0(ram12_web0),       // (output) active low write control
    	.ram_wmask0(ram12_wmask0),   // (output) write (byte) mask
    	.ram_addr0(ram12_addr0),	   // (output)
    	.ram_din0(wbs_sram12_data),	   // (input) read from sram and sent through wb 
    	.ram_dout0(ram12_din0)	   // (output) read from wb and sent to sram
	);

// Splitting register bits into fields
always @(*) begin
	if (mode_select) begin
		if(wbs_stb_i && wbs_cyc_i) begin
			// select on the basis of strobe signals here
			// for example:
			// at any given time wbs_or8_stb or wbs_or9_stb will be active
			// based on that take their values and provide to the sram control signals 
			chip_select = 0;

			if(wbs_or8_stb && !wbs_or9_stb && !wbs_or10_stb && !wbs_or11_stb && !wbs_or12_stb) begin
				csb0_temp = ram8_csb0;
   				addr0 = ram8_addr0;
   				din0 = ram8_din0;
   				web0 = ram8_web0;
   				wmask0 = ram8_wmask0;
				// dont cares for now since we are just testing single port for now
   				addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   				csb1_temp = global_csb | sram_register[`WMASK_SIZE+1];
   				web1 = sram_register[`WMASK_SIZE];
   				wmask1 = sram_register[`WMASK_SIZE-1:0];
			end
			else if(!wbs_or8_stb && wbs_or9_stb && !wbs_or10_stb && !wbs_or11_stb && !wbs_or12_stb) begin
				csb0_temp = ram9_csb0;
   				addr0 = ram9_addr0;
   				din0 = ram9_din0;
   				web0 = ram9_web0;
   				wmask0 = ram9_wmask0;
				// dont cares for now since we are just testing single port for now
   				addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   				csb1_temp = global_csb | sram_register[`WMASK_SIZE+1];
   				web1 = sram_register[`WMASK_SIZE];
   				wmask1 = sram_register[`WMASK_SIZE-1:0];
			end
			else if(!wbs_or8_stb && !wbs_or9_stb && wbs_or10_stb && !wbs_or11_stb && !wbs_or12_stb) begin
				csb0_temp = ram10_csb0;
   				addr0 = ram10_addr0;
   				din0 = ram10_din0;
   				web0 = ram10_web0;
   				wmask0 = ram10_wmask0;
				// dont cares for now since we are just testing single port for now
   				addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   				csb1_temp = global_csb | sram_register[`WMASK_SIZE+1];
   				web1 = sram_register[`WMASK_SIZE];
   				wmask1 = sram_register[`WMASK_SIZE-1:0];
			end
			else if(!wbs_or8_stb && !wbs_or9_stb && !wbs_or10_stb && wbs_or11_stb && !wbs_or12_stb) begin
				csb0_temp = ram11_csb0;
   				addr0 = ram11_addr0;
   				din0 = ram11_din0;
   				web0 = ram11_web0;
   				wmask0 = ram11_wmask0;
				// dont cares for now since we are just testing single port for now
   				addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   				csb1_temp = global_csb | sram_register[`WMASK_SIZE+1];
   				web1 = sram_register[`WMASK_SIZE];
   				wmask1 = sram_register[`WMASK_SIZE-1:0];
			end
			else if(!wbs_or8_stb && !wbs_or9_stb && !wbs_or10_stb && !wbs_or11_stb && wbs_or12_stb) begin
				csb0_temp = ram12_csb0;
   				addr0 = ram12_addr0;
   				din0 = ram12_din0;
   				web0 = ram12_web0;
   				wmask0 = ram12_wmask0;
				// dont cares for now since we are just testing single port for now
   				addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   				csb1_temp = global_csb | sram_register[`WMASK_SIZE+1];
   				web1 = sram_register[`WMASK_SIZE];
   				wmask1 = sram_register[`WMASK_SIZE-1:0];
			end
			else begin
				// no address matches with the sram macros' memory map so just disable read/writes
				csb0_temp = 1'b1;
   				addr0 = sram_register[`ADDR_SIZE+`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+1:`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+2];
   				din0 = sram_register[`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+1:`PORT_SIZE+`WMASK_SIZE+2];
   				csb0_temp = global_csb | sram_register[`PORT_SIZE+`WMASK_SIZE+1];
   				web0 = sram_register[`PORT_SIZE+`WMASK_SIZE];
   				wmask0 = sram_register[`PORT_SIZE+`WMASK_SIZE-1:`PORT_SIZE];

   				addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   				din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   				csb1_temp = 1'b1;
   				web1 = sram_register[`WMASK_SIZE];
   				wmask1 = sram_register[`WMASK_SIZE-1:0];
			end
		end else begin
			// wishbone mode but did not receive request (stb && cyc != 1)
			chip_select = 0;

   			addr0 = sram_register[`ADDR_SIZE+`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+1:`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+2];
   			din0 = sram_register[`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+1:`PORT_SIZE+`WMASK_SIZE+2];
   			csb0_temp = 1'b1;
   			web0 = sram_register[`PORT_SIZE+`WMASK_SIZE];
   			wmask0 = sram_register[`PORT_SIZE+`WMASK_SIZE-1:`PORT_SIZE];

   			addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   			din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   			csb1_temp = 1'b1;
   			web1 = sram_register[`WMASK_SIZE];
   			wmask1 = sram_register[`WMASK_SIZE-1:0];
   		end
	end else begin
		// gpio/la mode
		chip_select = sram_register[`TOTAL_SIZE-1:`TOTAL_SIZE-`SELECT_SIZE];

   		addr0 = sram_register[`ADDR_SIZE+`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+1:`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+2];
   		din0 = sram_register[`DATA_SIZE+`PORT_SIZE+`WMASK_SIZE+1:`PORT_SIZE+`WMASK_SIZE+2];
   		csb0_temp = global_csb | sram_register[`PORT_SIZE+`WMASK_SIZE+1];
   		web0 = sram_register[`PORT_SIZE+`WMASK_SIZE];
   		wmask0 = sram_register[`PORT_SIZE+`WMASK_SIZE-1:`PORT_SIZE];

 		addr1 = sram_register[`PORT_SIZE-1:`DATA_SIZE+`WMASK_SIZE+2];
   		din1 = sram_register[`DATA_SIZE+`WMASK_SIZE+1:`WMASK_SIZE+2];
   		csb1_temp = global_csb | sram_register[`WMASK_SIZE+1];
   		web1 = sram_register[`WMASK_SIZE];
   		wmask1 = sram_register[`WMASK_SIZE-1:0];

	end

end

// Apply the correct CSB
always @(*) begin
	// this can be improved like the following:
    // csb0 = ~( (~{15'b111111111111111, csb0_temp}) << chip_select);
	if(mode_select) begin
		if(wbs_stb_i && wbs_cyc_i) begin
			if(wbs_or8_stb && !wbs_or9_stb && !wbs_or10_stb && !wbs_or11_stb && !wbs_or12_stb) begin
				csb0 = {7'b1111111, csb0_temp, 8'b11111111};
				csb1 = 16'b1111111111111111;
			end
			else if(!wbs_or8_stb && wbs_or9_stb && !wbs_or10_stb && !wbs_or11_stb && !wbs_or12_stb) begin
				csb0 = {6'b111111, csb0_temp, 9'b111111111};
				csb1 = 16'b1111111111111111;
			end
			else if(!wbs_or8_stb && !wbs_or9_stb && wbs_or10_stb && !wbs_or11_stb && !wbs_or12_stb) begin
				csb0 = {5'b11111, csb0_temp, 10'b1111111111};
				csb1 = 16'b1111111111111111;
			end
			else if(!wbs_or8_stb && !wbs_or9_stb && !wbs_or10_stb && wbs_or11_stb && !wbs_or12_stb) begin
				csb0 = {4'b1111, csb0_temp, 11'b11111111111};
				csb1 = 16'b1111111111111111;
			end
			else if(!wbs_or8_stb && !wbs_or9_stb && !wbs_or10_stb && !wbs_or11_stb && wbs_or12_stb) begin
				csb0 = {3'b111, csb0_temp, 12'b111111111111};
				csb1 = 16'b1111111111111111;
			end
			else begin
				// incorrect address from the wishbone interface
				csb0 = {16{1'b1}};
				csb1 = 16'b1111111111111111;
			end
		end
		else begin
			// wishbone mode but did not receive request (stb && cyc != 1)
				csb0 = {16{1'b1}};
				csb1 = 16'b1111111111111111;
		end
	end
	else begin
		// gpio/la mode	
   		csb0 = ~( (~{15'b111111111111111, csb0_temp}) << chip_select);
   		csb1 = ~(  (~{15'b111111111111111, csb1_temp}) << chip_select);
	end
end

// Mux value of correct SRAM data input to feed into
// DFF clocked by la/gpio clk
always @ (*) begin
    case(chip_select)
    4'd0: begin
       read_data0 = sram0_data0;
       read_data1 = sram0_data1;
    end
    4'd1: begin
       read_data0 = sram1_data0;
       read_data1 = sram1_data1;
    end
    4'd2: begin
       read_data0 = sram2_data0;
       read_data1 = sram2_data1;
    end
    4'd3: begin
       read_data0 = sram3_data0;
       read_data1 = sram3_data1;
    end
    4'd4: begin
       read_data0 = sram4_data0;
       read_data1 = sram4_data1;
    end
    4'd5: begin
       read_data0 = sram5_data0;
       read_data1 = sram5_data1;
    end
    4'd6: begin
       read_data0 = sram6_data0;
       read_data1 = sram6_data1;
    end
    4'd7: begin
       read_data0 = sram7_data0;
       read_data1 = sram7_data1;
    end
    4'd8: begin
       read_data0 = sram8_data0;
       read_data1 = sram8_data1;
    end
    4'd9: begin
       read_data0 = sram9_data0;
       read_data1 = sram9_data1;
    end
    4'd10: begin
       read_data0 = sram10_data0;
       read_data1 = sram10_data1;
    end
    4'd11: begin
       read_data0 = sram11_data0;
       read_data1 = sram11_data1;
    end
    4'd12: begin
       read_data0 = sram12_data0;
       read_data1 = sram12_data1;
    end
    4'd13: begin
       read_data0 = sram13_data0;
       read_data1 = sram13_data1;
    end
    4'd14: begin
       read_data0 = sram14_data0;
       read_data1 = sram14_data1;
    end
    4'd15: begin
       read_data0 = sram15_data0;
       read_data1 = sram15_data1;
    end
	default: begin
       read_data0 = sram0_data0;
       read_data1 = sram0_data1;
	end
    endcase
end

// Output logic
always @ (*) begin
   gpio_out = sram_register[`TOTAL_SIZE-1];
   la_data_out = sram_register;
end

endmodule
