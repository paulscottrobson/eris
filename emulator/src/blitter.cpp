// ****************************************************************************
// ****************************************************************************
//
//		Name:		blitter.cpp
//		Purpose:	Blitter code.
//		Created:	8th March 2020
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************
// ****************************************************************************

#include "sys_processor.h"
#include "hardware.h"
#include <stdio.h>
#include <stdlib.h>

static BYTE8 vRAM[DWIDTH*DHEIGHT/2];
static BYTE8 paletteMap[16];
static BYTE8 blitterX,blitterY;
static WORD16 blitterData;

static BYTE8 BlitterReadvRAM(WORD16 x,WORD16 y);
static void BlitterWritevRAM(WORD16 x,WORD16 y,BYTE8 data);

// ****************************************************************************
//
//							Initialise Blitter
//
// ****************************************************************************

void BlitterInitialise(void) {
	for (int i = 0;i < 16;i++) {
		int c = (i & 1)+(i & 2)*2+(i & 4)*4;
		paletteMap[i] = c * ((i < 8) ? 3 : 2);
	}
	for (int x = 0;x < DWIDTH;x++) {
		for (int y = 0;y < DHEIGHT;y++) {
			int n = x/7+y/7;
			BlitterWritevRAM(x,y,n);
			HWWritePixel(x,y,paletteMap[n & 0x0F]);
		}
	}
}

// ****************************************************************************
//
//							Nibble access vRAM
//
// ****************************************************************************

static BYTE8 BlitterReadvRAM(WORD16 x,WORD16 y) {
	WORD16 addr = (x >> 1) + y * (DWIDTH >> 1);
	return (x & 1) ? (vRAM[addr] & 0x0F):(vRAM[addr] >> 4);
}

static void BlitterWritevRAM(WORD16 x,WORD16 y,BYTE8 data) {
	WORD16 addr = (x >> 1) + y * (DWIDTH >> 1);
	data &= 0x0F;
	if (x & 1) {
		vRAM[addr] = (vRAM[addr] & 0xF0) | data;
	}
	else {
		vRAM[addr] = (vRAM[addr] & 0x0F) | (data << 4);
	}
}

// ****************************************************************************
//
//							Get Blitter Status
//
// ****************************************************************************

void BlitterGetStatus(CPUSTATUS *s) {
	s->blitterX = blitterX;
	s->blitterY = blitterY;
	s->blitterData = blitterData;
}

// ****************************************************************************
//
//					 Read/Write Pixel at a given coordinate
//							  Returns BBGGRR format
//
// ****************************************************************************


BYTE8 BlitterGetPixel(WORD16 x,WORD16 y) {
	return paletteMap[BlitterReadvRAM(x,y)];
}


// ****************************************************************************
//
//								Update the palette
//
// ****************************************************************************

void HWWritePalette(BYTE8 port,BYTE8 data) {
}

// ****************************************************************************
//
//							Write to the blitter port
//
// ****************************************************************************

void BlitterWrite(BYTE8 port,WORD16 data) {
}

