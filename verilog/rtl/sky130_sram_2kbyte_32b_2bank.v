module sram_2kbyte_32b_2bank (
`ifdef USE_POWER_PINS
    vccd1,
    vssd1,
`endif
    clk0,
    addr0,
    din0,
    csb0,
    wmask0,
    web0,
    dout0,
    clk1,
    addr1,
    csb1,
    dout1
  );
  
  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH= 9;
  parameter NUM_BANKS=2;
  parameter RAM_DEPTH = 1 << ADDR_WIDTH;
  parameter BANK_SEL = 1;
  parameter NUM_WMASK = 4;
`ifdef USE_POWER_PINS
    inout vccd1;
    inout vssd1;
`endif
  input clk0;
  input [ADDR_WIDTH - 1 : 0] addr0;
  input [DATA_WIDTH - 1: 0] din0;
  input csb0;
  input web0;
  input [NUM_WMASK - 1 : 0] wmask0;
  output reg [DATA_WIDTH - 1 : 0] dout0;
  
  input clk1;
  input [ADDR_WIDTH - 1 : 0] addr1;
  input csb1;
  output reg [DATA_WIDTH - 1 : 0] dout1;
  wire [DATA_WIDTH - 1 : 0] dout0_bank0;
  wire [DATA_WIDTH - 1 : 0] dout1_bank0;
  wire [DATA_WIDTH - 1 : 0] dout0_bank1;
  wire [DATA_WIDTH - 1 : 0] dout1_bank1;
  reg web0_bank0;
  reg web0_bank1;
  reg csb0_bank0;
  reg csb1_bank0;
  reg csb0_bank1;
  reg csb1_bank1;
  reg [ADDR_WIDTH - 1 : 0] addr0_reg;
  reg [ADDR_WIDTH - 1 : 0] addr1_reg;
  sky130_sram_1kbyte_1rw1r_32x256_8 bank0 (
`ifdef USE_POWER_PINS
    .vccd1(vccd1),
    .vssd1(vssd1),
`endif
    .clk0(clk0),
    .addr0(addr0[ADDR_WIDTH - BANK_SEL - 1 : 0]),
    .din0(din0),
    .csb0(csb0_bank0),
    .web0(web0_bank0),
    .wmask0(wmask0),
    .dout0(dout0_bank0),
    .clk1(clk1),
    .addr1(addr1[ADDR_WIDTH - BANK_SEL - 1 : 0]),
    .csb1(csb1_bank0),
    .dout1(dout1_bank0)
  );
  
  sky130_sram_1kbyte_1rw1r_32x256_8 bank1 (
`ifdef USE_POWER_PINS
    .vccd1(vccd1),
    .vssd1(vssd1),
`endif
    .clk0(clk0),
    .addr0(addr0[ADDR_WIDTH - BANK_SEL - 1 : 0]),
    .din0(din0),
    .csb0(csb0_bank1),
    .web0(web0_bank1),
    .wmask0(wmask0),
    .dout0(dout0_bank1),
    .clk1(clk1),
    .addr1(addr1[ADDR_WIDTH - BANK_SEL - 1 : 0]),
    .csb1(csb1_bank1),
    .dout1(dout1_bank1)
  );
  always @(posedge clk0) begin
    addr0_reg <= addr0;
  end
  
  always @(posedge clk1) begin
    addr1_reg <= addr1;
  end
  always @(*) begin
    case (addr0_reg[ADDR_WIDTH - 1 : ADDR_WIDTH - BANK_SEL])
      0: begin
        dout0 = dout0_bank0;
      end
      1: begin
        dout0 = dout0_bank1;
      end
    endcase
  end
  always @(*) begin
    case (addr0[ADDR_WIDTH - 1 : ADDR_WIDTH - BANK_SEL])
      0: begin
        web0_bank0 = web0;
        web0_bank1 = 1'b1;
        csb0_bank0 = csb0;
        csb0_bank1 = 1'b1;
      end
      1: begin
        web0_bank1 = web0;
        web0_bank0 = 1'b1;
        csb0_bank1 = csb0;
        csb0_bank0 = 1'b1;
      end
    endcase
  end
  always @(*) begin
    case (addr1_reg[ADDR_WIDTH - 1 : ADDR_WIDTH - BANK_SEL])
      0: begin
        dout1 = dout1_bank0;
      end
      1: begin
        dout1 = dout1_bank1;
      end
    endcase
  end
  always @(*) begin
    case (addr1[ADDR_WIDTH - 1 : ADDR_WIDTH - BANK_SEL])
      0: begin
        csb1_bank0 = csb1;
        csb1_bank1 = 1'b1;
      end
      1: begin
        csb1_bank1 = csb1;
        csb1_bank0 = 1'b1;
      end
    endcase
  end
endmodule
