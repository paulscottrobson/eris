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
static WORD16 blitterInvalid;
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
		paletteMap[i] = (i == 0) ? 0 : 7;
	}
	blitterInvalid = 1;
	for (int x = 0;x < DWIDTH;x++) {
		for (int y = 0;y < DHEIGHT;y++) {
			BlitterWritevRAM(x,y,0);
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
//								Update the palette
//
// ****************************************************************************

void HWWritePalette(BYTE8 port,WORD16 data) {
	BYTE8 colour = (data >> 8) & 0x0F;
	paletteMap[colour] = data & 7;
	blitterInvalid = 1;
	// printf("%d %d,%d,%d\n",colour,(data >> 4) & 3,(data >> 2) & 3,data & 3);
}

// ****************************************************************************
//
//							Write to the blitter port
//
// ****************************************************************************

void BlitterWrite(BYTE8 port,WORD16 data) {
	if (blitterInvalid != 0) {
		blitterInvalid = 0;
		for (int x = 0;x < DWIDTH;x++) {
			for (int y = 0;y < DHEIGHT;y++) {
				HWWritePixel(x,y,paletteMap[BlitterReadvRAM(x,y)]);
			}
		}
	}
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
		int count = (cmd & 0x1000) ? 2 : 1;								// Number of rows
		while (count-- > 0) {
			if (blitterY < DHEIGHT) {									// Legitimate row ?
				WORD16 address = (cmd & 0x2000) ? 						// Calculate source address
										(blitterData ^ 0x0F):blitterData;
				blitterRow(cmd,CPUReadMemory(address));					// Do one row of pixels.									
			}										
			blitterY++;													// Always increment Y
		}
		if ((cmd & 0x8000) == 0) blitterData++;							// Default is to increment data
	}
}

// ****************************************************************************
//
//								Blit one row out.
//
// ****************************************************************************

static void blitterRow(WORD16 cmd,WORD16 pixels) {
	if (blitterX >= DWIDTH && blitterX <= 0xFFE0) return; 				// Cannot be drawn.

	WORD16 x = blitterX;												// horizontal pos
	int count = (cmd & 0x1000) ? 2 : 1;									// Number of rows

	for (int n = 0;n < 16*count;n++) { 									// Work through the pixel.
		WORD16 isSet = (cmd & 0x4000) ? (pixels & 0x0001) 				// Is the pixel set ?
									  : (pixels & 0x8000);
		if ((isSet || (cmd & 0x0800) != 0) && (x < DWIDTH)) { 			// If set or writing background.
			BYTE8 update = isSet ? (blitterColour & blitterMask) : 0;	// Value to update.
			BYTE8 current = BlitterReadvRAM(x,blitterY);				// Current value
			BYTE8 newVal = (current & (~blitterMask)) | update; 		// Set the bits masked.
			if (current != newVal) { 									// Has it changed ?
				BlitterWritevRAM(x,blitterY,newVal);					// Update it.
				BYTE8 newPalette = paletteMap[newVal & 15];				// What physical colours ?
				BYTE8 oldPalette = paletteMap[current & 15];
				if (newPalette != oldPalette) {							// Update if physical colour changed
					HWWritePixel(x,blitterY,newPalette);					
				}
			}
		}
		x++;
		if (count == 1 || (n & 1) != 0)									// if scale 1 or odd column
			pixels = (cmd & 0x4000) ? (pixels >> 1) : (pixels << 1);	// Shift pixels
	}
}
