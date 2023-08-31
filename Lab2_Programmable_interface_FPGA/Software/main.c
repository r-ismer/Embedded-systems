#include <stdio.h>
#include "system.h"
#include "io.h"
#include <unistd.h>

typedef unsigned int uint;

#define LED_NUM 24
#define MAX_COLOR 255

#define LED_OFFSET 2
#define BLUE_OFFSET 0
#define RED_OFFSET 1
#define GREEN_OFFSET 2


void writeRGB(uint r, uint g, uint b, uint led);
void writeLEDS(uint offset);

uint tab[24][3] = {
		{255, 0, 0},
		{255, 70, 0},
		{255, 140, 0},
		{255, 210, 0},
		{255, 255, 0},
		{210, 255, 0},
		{140, 255, 0},
		{70, 255, 0},
		{0, 255, 0},
		{0, 255, 70},
		{0, 255, 140},
		{0, 255, 210},
		{0, 255, 255},
		{0, 210,255},
		{0, 140, 255},
		{0, 70, 255},
		{0, 0, 255},
		{70, 0, 255},
		{140, 0, 255},
		{210, 0, 255},
		{255, 0, 255},
		{210, 0, 255},
		{140, 0, 255},
		{70, 0, 255},
};

int main()
{
  uint counter = 0;
  while(1) {
	  writeLEDS(counter);
	  if(++counter == LED_NUM) {
		  counter = 0;
	  }
	  usleep(20000);
  }

  return 0;
}

void writeRGB(uint r, uint g, uint b, uint led) {
	if(r > MAX_COLOR || g > MAX_COLOR || b > MAX_COLOR || led >= LED_NUM) {
		return;
	}
	IOWR_8DIRECT(WS2812_0_BASE, (led << LED_OFFSET) + BLUE_OFFSET, b);
	IOWR_8DIRECT(WS2812_0_BASE, (led << LED_OFFSET) + RED_OFFSET, r);
	IOWR_8DIRECT(WS2812_0_BASE, (led << LED_OFFSET) + GREEN_OFFSET, g);
}

void writeLEDS(uint offset) {
	for(int i = 0; i < LED_NUM; i++) {
		uint* line = tab[(offset + i) % LED_NUM];
		writeRGB(line[0], line[1], line[2], i);
	}
}
