/*
 * frames.h
 *
 *  Created on: 3 janv. 2023
 *      Author: Ismer Richard
 */

#ifndef FRAMES_H_
#define FRAMES_H_

#define FRAME_SIZE 76800

int write_frame(uint32_t address, uint32_t color);

void fill_ram();

void print_ram(uint32_t address);

#endif /* FRAMES_H_ */
