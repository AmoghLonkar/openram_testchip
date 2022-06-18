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
//#include "verilog/dv/caravel/defs.h"
#include <defs.h>
//#include "verilog/dv/caravel/stub.c"
#include <stub.c>

// Caravel allows user project to use 0x30xx_xxxx address space on Wishbone bus
// OpenRAM
// 0x30c0_0000 till 30c0_03ff -> 256 Words of OpenRAM (1024 Bytes)
#define SRAM8_BASE_ADDRESS		0x30000000
#define SRAM8_SIZE_DWORDS		256ul			
#define SRAM8_SIZE_BYTES		(4ul * SRAM8_SIZE_DWORDS)
#define SRAM8_ADDRESS_MASK		(SRAM8_SIZE_BYTES - 1)
#define SRAM8_MEM(offset)		(*(volatile uint32_t*)(SRAM8_BASE_ADDRESS + (offset & SRAM8_ADDRESS_MASK)))

#define SRAM9_BASE_ADDRESS		0x30000400
#define SRAM9_SIZE_DWORDS		512ul			
#define SRAM9_SIZE_BYTES		(4ul * SRAM9_SIZE_DWORDS)
#define SRAM9_ADDRESS_MASK		(SRAM9_SIZE_BYTES - 1)
#define SRAM9_MEM(offset)		(*(volatile uint32_t*)(SRAM9_BASE_ADDRESS + (offset & SRAM9_ADDRESS_MASK)))

#define SRAM10_BASE_ADDRESS		0x30000c00
#define SRAM10_SIZE_DWORDS		512ul			
#define SRAM10_SIZE_BYTES		(4ul * SRAM10_SIZE_DWORDS)
#define SRAM10_ADDRESS_MASK		(SRAM10_SIZE_BYTES - 1)
#define SRAM10_MEM(offset)		(*(volatile uint32_t*)(SRAM10_BASE_ADDRESS + (offset & SRAM10_ADDRESS_MASK)))

//#define SRAM10_BASE_ADDRESS		0x30000c00
//#define SRAM10_SIZE_DWORDS		1024ul			
//#define SRAM10_SIZE_BYTES		(4ul * SRAM10_SIZE_DWORDS)
//#define SRAM10_ADDRESS_MASK		(SRAM10_SIZE_BYTES - 1)
//#define SRAM10_MEM(offset)		(*(volatile uint32_t*)(SRAM10_BASE_ADDRESS + (offset & SRAM10_ADDRESS_MASK)))

//#define SRAM11_BASE_ADDRESS		0x30001c00
//#define SRAM11_SIZE_DWORDS		1024ul			
//#define SRAM11_SIZE_BYTES		(4ul * SRAM11_SIZE_DWORDS)
//#define SRAM11_ADDRESS_MASK		(SRAM11_SIZE_BYTES - 1)
//#define SRAM11_MEM(offset)		(*(volatile uint32_t*)(SRAM11_BASE_ADDRESS + (offset & SRAM11_ADDRESS_MASK)))

//#define SRAM12_BASE_ADDRESS		0x30002c00
//#define SRAM12_SIZE_DWORDS		2048ul			
//#define SRAM12_SIZE_BYTES		(4ul * SRAM12_SIZE_DWORDS)
//#define SRAM12_ADDRESS_MASK		(SRAM12_SIZE_BYTES - 1)
//#define SRAM12_MEM(offset)		(*(volatile uint32_t*)(SRAM12_BASE_ADDRESS + (offset & SRAM12_ADDRESS_MASK)))

void main()
{

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

	/* both of the following registers need to be enabled
	   enabling just one of them or none of them causes
	   the simulation to run infinitely and stopping after
	   the timeout number of cycles */


	reg_spi_enable = 1;
	reg_wb_enable = 1;




	// GPIO pin 27 Used to flag the start/end of a test 
	// GPIO pin 29 Used to indicate error in writing/reading sram 8
	// GPIO pin 30 Used to indicate error in writing/reading sram 9

	reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
	//reg_mprj_io_34 = GPIO_MODE_MGMT_STD_OUTPUT;
	/* Apply configuration */
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);

	// Flag start of the test
	reg_mprj_datal = 0x08000000;


	SRAM8_MEM(0) = 0xdeadbeef;
	SRAM9_MEM(0) = 0xbeefdead;
	SRAM10_MEM(0) = 0xbeef1234;
//	SRAM11_MEM(0) = 0xbeef5678;
//	SRAM12_MEM(0) = 0xbeef9abc;

	SRAM8_MEM(4) = 0xdeadbee0;
	SRAM9_MEM(4) = 0xbee0dead;
	SRAM10_MEM(4) = 0xbee1dead;
//	SRAM11_MEM(4) = 0xbee2dead;
//	SRAM12_MEM(4) = 0xbee3dead;

	SRAM8_MEM(8) = 0xffffffff;
	SRAM9_MEM(8) = 0x12345678;
	SRAM10_MEM(8) = 0xabababab;
//	SRAM11_MEM(8) = 0xcdcdcdcd;
//	SRAM12_MEM(8) = 0xefefefef;

	SRAM8_MEM(12) = 0xdeaddead;
	SRAM9_MEM(12) = 0x10101010;
	SRAM10_MEM(12) = 0x20202020;
//	SRAM11_MEM(12) = 0x30303030;
//	SRAM12_MEM(12) = 0x40404040;

	if (SRAM8_MEM(0) != 0xdeadbeef) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x10000000;
	}
	if (SRAM8_MEM(4) != 0xdeadbee0) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x10000000;
	}
	if (SRAM8_MEM(8) != 0xffffffff) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x10000000;
	}
	if (SRAM8_MEM(12) != 0xdeaddead) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x10000000;
	}


	if (SRAM9_MEM(0) != 0xbeefdead) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x20000000;
	}
	if (SRAM9_MEM(4) != 0xbee0dead) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x20000000;
	}
	if (SRAM9_MEM(8) != 0x12345678) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x20000000;
	}
	if (SRAM9_MEM(12) != 0x10101010) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x20000000;
	}

	if (SRAM10_MEM(0) != 0xbeef1234) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x40000000;
	}
	if (SRAM10_MEM(4) != 0xbee1dead) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x40000000;
	}
	if (SRAM10_MEM(8) != 0xabababab) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x40000000;
	}
	if (SRAM10_MEM(12) != 0x20202020) {
		// send an error signal to the testbench
		reg_mprj_datal = 0x40000000;
	}

//	if (SRAM11_MEM(0) != 0xbeef5678) {
//		// send an error signal to the testbench
//		reg_mprj_datal = 0x80000000;
//	}
//	if (SRAM11_MEM(4) != 0xbee2dead) {
//		// send an error signal to the testbench
//		reg_mprj_datal = 0x80000000;
//	}
//	if (SRAM11_MEM(8) != 0xcdcdcdcd) {
//		// send an error signal to the testbench
//		reg_mprj_datal = 0x80000000;
//	}
//	if (SRAM11_MEM(12) != 0x30303030) {
//		// send an error signal to the testbench
//		reg_mprj_datal = 0x80000000;
//	}

//	if (SRAM12_MEM(0) != 0xbeef9abc) {
//		// send an error signal to the testbench
//		reg_mprj_datah = 0x00000004;
//	}
//	if (SRAM12_MEM(4) != 0xbee3dead) {
//		// send an error signal to the testbench
//		reg_mprj_datah = 0x00000004;
//	}
//	if (SRAM12_MEM(8) != 0xefefefef) {
//		// send an error signal to the testbench
//		reg_mprj_datah = 0x00000004;
//	}
//	if (SRAM12_MEM(12) != 0x40404040) {
//		// send an error signal to the testbench
//		reg_mprj_datah = 0x00000004;
//	}

	reg_mprj_datal = 0x00000000;			
}

