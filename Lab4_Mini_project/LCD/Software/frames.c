/*
 * frames.c
 *
 *  Created on: 3 janv. 2023
 *      Author: Ismer Richard
 */

#include <stdio.h>
#include <stdint.h>
#include "system.h"
#include "io.h"
#include "frames.h"

int write_frame(uint32_t address, uint32_t color) {
	for(int i = 0; i < (76800 / 2); i++) {
			IOWR_32DIRECT(HPS_0_BRIDGES_BASE, address + (4 * i), color);
		}
	return HPS_0_BRIDGES_BASE + address;
}

void fill_ram() {
	int count = 0;
	for(int i = 0; i < 16 * FRAME_SIZE/4; i++) {
		switch(count){
		case 0:
			IOWR_32DIRECT(HPS_0_BRIDGES_BASE, i * 4, 0xF800F800);
			break;
		case 1:
			IOWR_32DIRECT(HPS_0_BRIDGES_BASE, i * 4, 0x001F001F);
			break;
		case 2:
			IOWR_32DIRECT(HPS_0_BRIDGES_BASE, i * 4, 0x07E007E0);
			break;
		}
		//IOWR_32DIRECT(HPS_0_BRIDGES_BASE, i * 4, (i<<16) + i);
		count = (count + 1) % 3;
	}
}

void print_ram(uint32_t address) {
	uint32_t val = IORD_32DIRECT(HPS_0_BRIDGES_BASE, address);
	printf("value in ram at address %d: %lu\n", address, val);
}
