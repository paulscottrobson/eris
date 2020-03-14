// ****************************************************************************
// ****************************************************************************
//
//		Name:		hardware_esp.c
//		Purpose:	Hardware Emulation (ESP32 Specific)
//		Created:	8th March 2020
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************
// ****************************************************************************

#include <Arduino.h>
#include "sys_processor.h"
#include "gfxkeys.h"


// ****************************************************************************
//							  Sync Hardware
// ****************************************************************************

static int keys[][16] = {
	{ 0x16,0x1E,0x26,0x25,0x2E,0x36,0x3D,0x3E,0x46,0x45,0x4E,0x55,0x66,0 },
	{ 0x0D,0x15,0x1D,0x24,0x2D,0x2C,0x35,0x3C,0x43,0x44,0x4D,0x54,0x5B,0 },
	{ 0x1C,0x1B,0x23,0x2B,0x34,0x33,0x3B,0x42,0x4B,0x4C,0x52,0x5D,0x5A,0 },
	{ 0x29,0x61,0x1A,0x22,0x21,0x2A,0x32,0x31,0x3A,0x41,0x49,0x4A,0 },
	{ 0xEB,0xF4,0xF5,0xF2,0x14,0x12,0 }
};

static BYTE8 keyStatus[256] = {0};
static int shift = 0;
static int release = 0;
static int lastKey = 0;

void HWSyncImplementation(LONG32 iCount) {
	int scanCode = HWGetScanCode();
	while (scanCode > 0) {
		if (scanCode == 0xE0) {
			shift = 0x80;
		} 
		else if (scanCode == 0xF0) {
			release = 1;
		}
		else {
			int isDown = (release == 0);
			scanCode = (scanCode & 0x7F) | shift;
			//writeCharacter(scanCode & 0x0F,(scanCode >> 4)+2,isDown ? '*' : '.');
			keyStatus[scanCode] = isDown;
			lastKey = isDown ? scanCode : -scanCode;
			shift = 0x00;
			release = 0x00;
		}
		scanCode = HWGetScanCode();
	}
	if (keyStatus[0x14] && keyStatus[0x76]) CPUReset();			/* Ctrl+ESC is Reset */

	char buffer[32];
	int m = CPUReadMemory(0x6000);
	sprintf(buffer,"%5ld %5d %5d ",millis()/1000,m,iCount/1000/1000);
	int i = 0;
	while (buffer[i] != 0) {
		HWWriteCharacter(i,15,buffer[i]);
		i++;
	}
}

// ****************************************************************************
//					Get the keys pressed for a particular row
// ****************************************************************************

int HWGetKeyboardRow(int row) {
	int word = 0;
	int p = 0;
	while (keys[row][p] != 0) {
		if (keyStatus[keys[row][p]]) word |= (1 << p);
		p++;
	}
	if (row == 4 && keyStatus[0x59]) word |= 0x20;		// Right shift.
	return word;
}

// ****************************************************************************
//					Check if key pressed (GFXKEY values)
// ****************************************************************************

int  HWIsKeyPressed(int key) {
	return 0;
}

// ****************************************************************************
//							Set a display pixel
// ****************************************************************************

void HWWritePixel(WORD16 x,WORD16 y,BYTE8 colour) {
	HWWritePixelToScreen(x,y,colour);
}

// ****************************************************************************
//						Get System time in 1/100s
// ****************************************************************************

WORD16 HWGetSystemClock(void) {
	return (millis() / 10) & 0xFFFF;
}

// ****************************************************************************
//						 Control audio channel
// ****************************************************************************

void HWWriteAudio(BYTE8 channel,WORD16 freq) {
	HWSetAudio(channel & 0x0F,freq);
}
