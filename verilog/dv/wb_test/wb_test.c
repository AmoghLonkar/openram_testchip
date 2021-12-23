/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include "verilog/dv/caravel/defs.h"
#include "verilog/dv/caravel/stub.c"

// Caravel allows user project to use 0x30xx_xxxx address space on Wishbone bus
// OpenRAM
// 0x30c0_0000 till 30c0_03ff -> 256 Words of OpenRAM (1024 Bytes)
#define OPENRAM_BASE_ADDRESS		0x30000000
#define OPENRAM_SIZE_DWORDS		256ul			
#define OPENRAM_SIZE_BYTES		(4ul * OPENRAM_SIZE_DWORDS)
#define OPENRAM_ADDRESS_MASK		(OPENRAM_SIZE_BYTES - 1)
#define OPENRAM_MEM(offset)		(*(volatile uint32_t*)(OPENRAM_BASE_ADDRESS + (offset & OPENRAM_ADDRESS_MASK)))


// Generates 32bits wide value out of address, not random
unsigned long generate_value(unsigned long address)
{
	return ((~address & OPENRAM_ADDRESS_MASK) << 19) + 
		((~address & OPENRAM_ADDRESS_MASK) << 12) ^
		((~address & OPENRAM_ADDRESS_MASK) << 2);
}

void main()
{
	unsigned int address = 0;

	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |
	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |
	*/

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

	reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.


	// All GPIO pins are configured to be output
	// Used to flad the start/end of a test 

	reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
	/* Apply configuration */
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);

	// Flag start of the test
	reg_mprj_datal = 0x10000000;


	// configuring them as output so that we can provide a stable de-asserted reset through caravel la pin 126	
	reg_la3_oenb = reg_la3_iena = 0x00000000;    // [127:96]
	// writing 0 so that la pin 126 gets 0 and de-activates the reset instead of keeping it dont care.
	reg_la3_data = 0x00000000;

	OPENRAM_MEM(0) = 0xdeadbeef;
	OPENRAM_MEM(4) = 0xdeadbee0;
	OPENRAM_MEM(8) = 0xffffffff;
	OPENRAM_MEM(12) = 0xdeaddead;
	// this is not working because the data is correct but sp rams send an additional x which makes this fail
	if (OPENRAM_MEM(0) != 0xdeadbeef) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x20000000;
	}
	if (OPENRAM_MEM(4) != 0xdeadbee0) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x20000000;
	}
	if (OPENRAM_MEM(8) != 0xffffffff) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x20000000;
	}
	if (OPENRAM_MEM(12) != 0xdeaddead) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x20000000;
	}



	reg_mprj_datal = 0x00000000;			
}

