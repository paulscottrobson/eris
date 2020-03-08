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

static BYTE8 vRAM[320*240/2];
static BYTE8 colourMap[256];
static BYTE8 blitterX,blitterY;
static WORD16 blitterData;

static void BlitterCommand(WORD16 cmd);
static void BlitterLine(WORD16 cmd,WORD16 pixelData);

// ****************************************************************************
//
//							Initialise Blitter
//
// ****************************************************************************

void BlitterInitialise(void) {
	for (int i = 0;i < 256;i++) {
		colourMap[i] = (i >= 0xF0) ? (i & 0x0F) : (i >> 4);
	}
	for (int x = 0;x < DWIDTH;x++) {
		for (int y = 0;y < DHEIGHT;y++) {
			vRAM[x+y*DWIDTH] = (rand() & 0x0F) ? 0xF0:rand();
			HWWritePixel(x,y,BlitterGetPixel(x,y));
		}
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
//
// ****************************************************************************


BYTE8 BlitterGetPixel(WORD16 x,WORD16 y) {
	return colourMap[vRAM[x+y*DWIDTH]];
}

BYTE8 BlitterGetPixelByte(WORD16 x,WORD16 y) {
	return vRAM[x+y*DWIDTH];
}


void BlitterSetPixelByte(WORD16 x,WORD16 y,BYTE8 c) {
	BYTE8 oldColour = BlitterGetPixel(x,y);						// Old display colour
	vRAM[x+y*DWIDTH] = c;										// Update memory
	if (oldColour != colourMap[c]) {							// Display colour changed?
		HWWritePixel(x,y,colourMap[c]); 						// Update display pixel.
		//printf("(%d,%d) = $%x\n",x,y,colourMap[c]);
	}
}

// ****************************************************************************
//
//							Write to the blitter port
//
// ****************************************************************************

void BlitterWrite(BYTE8 port,WORD16 data) {
	switch (port & 7) {
		case 0:
			blitterX = data & 0xFF;
			blitterY = data >> 8;
			break;
		case 1:
			blitterData = data;
			break;
		case 2:
			BlitterCommand(data);
			break;
	}
}

// ****************************************************************************
//
//							Execute a blitter command
//
// ****************************************************************************

static void BlitterCommand(WORD16 cmd) {
	WORD16 yCount = (cmd >> 8) & 0x0F;								// # of vertical lines
	yCount = (yCount == 0) ? 16 : yCount; 							// 0 => 16 lines.
	while (yCount != 0) {
		BlitterLine(cmd,CPUReadMemory(blitterData));				// Output data
		blitterY++;													// One row down.
		if ((cmd & 0x2000) == 0) blitterData++; 					// Optional increment.
		yCount--; 													// Reduce count
	}
}

// ****************************************************************************
//
//								  Blit a row out
//
// ****************************************************************************

static void BlitterLine(WORD16 cmd,WORD16 pixelData) {
	if (blitterY >= DHEIGHT) return; 								// Off horizontally.
	if (blitterX >= DWIDTH && blitterX <= 0xF0) return; 			// Off vertically.
	WORD16 drawBackground = (cmd & 0x1000);							// Non-zero if drawing bgr.
	WORD16 writeTopPlane = (cmd & 0x8000);							// Non-zero if write top.	
	BYTE8 hFlip = (cmd & 0x4000) != 0;								// Horizontal flip.
	WORD16 pixelMask = hFlip ? 0x0001:0x8000;						// Pixel to check
	for (WORD16 pixel = 0;pixel < 16;pixel++) {
		if (drawBackground != 0 || (pixelData & pixelMask) != 0) { 	// Background or pixel set ?
			BYTE8 xc = pixel+blitterX;
			BYTE8 newColour = cmd & 0x0F;							// Work out new colour.
			if ((pixelData & pixelMask) == 0) newColour = (cmd & 0xF0) >> 4;
			BYTE8 b = BlitterGetPixelByte(xc,blitterY); 			// Old value
			if (writeTopPlane) {									// Update correct plane
				b = (b & 0x0F) | (newColour << 4);
			} else {
				b = (b & 0xF0) | newColour;
			}
			BlitterSetPixelByte(xc,blitterY,b);						// New value
		}
		pixelData = hFlip ? (pixelData >> 1) : (pixelData << 1);	// Direction to shift pixel register
	}	
}