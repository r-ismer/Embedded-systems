/*
 * lt_24_utils.h
 *
 *  Created on: 29 déc. 2022
 *      Author: Ismer Richard
 */


#ifndef LT_24_UTILS_H_
#define LT_24_UTILS_H_

#include <stdio.h>
#include "system.h"

#define FRAME_SIZE 76800

#define CMD_SET_SIZE 23
#define BUFF_ADDR 0
#define BUFF_LENGTH 4
#define CMD_CMD 8
#define CMD_NUM 12
#define CMD_WRITE 16
#define CMD_DATA 20

struct command {
	int cmd;
	int length;
	int *table;
};

void lcd_setup(void);

#endif /* LT_24_UTILS_H_ */
