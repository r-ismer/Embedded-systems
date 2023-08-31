/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include "system.h"
#include "nios2.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include "lt_24/frames.h"
#include "lt_24/lt_24_utils.h"
#include "camera/Camera_Controller.h"

#define WRITING_CAM 4
#define BUFFER 4

int main()
{
	// initialize components
	trdb_d5m_init(BUFFER, FRAME_SIZE * 2);
	lcd_setup();

	int counter = 0;

	while(true) {
		bool writing = false;
		do {
			writing = (IORD_32DIRECT(CAMERA_CONTROLLER_0_BASE, CAM_STATUS_ADDR) >> 2) & 1;
		} while (writing);
		IOWR_32DIRECT(LT_24_0_BASE, BUFF_ADDR, BUFFER + (FRAME_SIZE * 2 * counter));
		bool reading = false;
		do {
			reading = (IORD_32DIRECT(LT_24_0_BASE, CMD_WRITE) >> 1);
		} while (reading);
		//usleep(1000);

		//change buffer
		counter = (counter + 1) % 3;
		IOWR_32DIRECT(CAMERA_CONTROLLER_0_BASE, CAM_ADDR_ADDR, (FRAME_SIZE * 2 * counter) + BUFFER);
		IOWR_32DIRECT(CAMERA_CONTROLLER_0_BASE, CAM_START_ADDR, 0xFFFF);

	}

	return 0;
}
