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
static WORD16 blitterX,blitterY;
static WORD16 blitterData;
static BYTE8 blitterMask;
static BYTE8 blitterColour;

static BYTE8 BlitterReadvRAM(WORD16 x,WORD16 y);
static void BlitterWritevRAM(WORD16 x,WORD16 y,BYTE8 data);
static void BlitterCommand(WORD16 cmd);
static void blitterRow(WORD16 cmd,WORD16 pixels);

// ****************************************************************************
//
//							Initialise Blitter
//
// ****************************************************************************

void BlitterInitialise(void) {
	for (int i = 0;i < 16;i++) {
		int c = (i & 1)+(i & 2)*2+(i & 4)*4;
		paletteMap[i] = c * 3;
	}
	for (int x = 0;x < DWIDTH;x++) {
		for (int y = 0;y < DHEIGHT;y++) {
			int n = (rand() & 0x1F) ? 0 : (rand() & 0x0F);
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
	s->blitterMask = blitterMask;
	s->blitterColour = blitterColour;
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

void HWWritePalette(BYTE8 port,WORD16 data) {
	BYTE8 colour = (data >> 8) & 0x0F;
	paletteMap[colour] = data & 0x3F;
}

// ****************************************************************************
//
//							Write to the blitter port
//
// ****************************************************************************

void BlitterWrite(BYTE8 port,WORD16 data) {
	switch (port & 7) {
		case 0:
			blitterX = data;break;
		case 1:
			blitterY = data;break;
		case 2:
			blitterData = data;break;
		case 3:
			blitterMask = (data >> 8) & 0xFF;
			blitterColour = data & 0xFF;
			break;
		case 4:
			BlitterCommand(data);
			break;
	}
}

// ****************************************************************************
//
//									Blitter command
//
// ****************************************************************************

static void BlitterCommand(WORD16 cmd) {
	for (int row = 0;row < (cmd & 0xFF);row++) { 						// Do this many rows.
		if (blitterY < DHEIGHT) {										// Legitimate row ?
			WORD16 address = (cmd & 0x2000) ? 							// Calculate source address
									(blitterData ^ 0x0F):blitterData;
			blitterRow(cmd,CPUReadMemory(address));						// Do one row of pixels.									
		}
		blitterY++;														// Always increment Y
		if ((cmd & 0x8000) == 0) blitterData++;							// Default is to increment data
	}
}

// ****************************************************************************
//
//								Blit one row out.
//
// ****************************************************************************

static void blitterRow(WORD16 cmd,WORD16 pixels) {
	if (blitterX >= DWIDTH && blitterX <= 0xFFF0) return; 				// Cannot be drawn.

	for (int n = 0;n < 16;n++) { 										// Work through the pixel.
		WORD16 x = blitterX+n;											// Calculate horizontal pos
		WORD16 isSet = (cmd & 0x4000) ? (pixels & 0x0001) 				// Is the pixel set ?
									  : (pixels & 0x8000);
		if ((isSet || (cmd & 0x1000) != 0) && (x < DWIDTH)) { 			// If set or writing background.
			BYTE8 update = isSet ? (blitterColour & blitterMask) : 0;	// Value to update.
			BYTE8 current = BlitterReadvRAM(x,blitterY);				// Current value
			BYTE8 newVal = (current & (~blitterMask)) | update; 		// Set the bits masked.
			if (current != newVal) { 									// Has it changed ?
				BlitterWritevRAM(x,blitterY,newVal);					// Update it.
				BYTE8 newPalette = paletteMap[newVal & 0x3F];			// What physical colours ?
				BYTE8 oldPalette = paletteMap[current & 0x3F];
				if (newPalette != oldPalette) {							// Update if physical colour changed
					HWWritePixel(x,blitterY,newPalette);					
				}
			}
		}
		pixels = (cmd & 0x4000) ? (pixels >> 1) : (pixels << 1);		// Shift pixels
	}
}
