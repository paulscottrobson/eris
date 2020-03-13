// ****************************************************************************
// ****************************************************************************
//
//		Name:		hardware_emu.c
//		Purpose:	Hardware Emulation (Emulator Specific)
//		Created:	8th March 2020
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************
// ****************************************************************************

#include "sys_processor.h"
#include "hardware.h"
#include "gfxkeys.h"
#include <stdio.h>

#include <stdlib.h>
#include "gfx.h"

// ****************************************************************************
//
//							Key codes for the ports
//
// ****************************************************************************

static int keys[][16] = {
	{ '1','2','3','4','5','6','7','8','9','0','-','=',GFXKEY_BACKSPACE,0 },
	{ GFXKEY_TAB,'Q','W','E','R','T','Y','U','I','O','P','[',']',0 },
	{ 'A','S','D','F','G','H','J','K','L',';','@','#',GFXKEY_RETURN,0 },
	{ ' ','\\','Z','X','C','V','B','N','M',',','.','/',0  },
	{ GFXKEY_LEFT,GFXKEY_RIGHT,GFXKEY_UP,GFXKEY_DOWN,GFXKEY_CONTROL,GFXKEY_SHIFT,0  }
};

// ****************************************************************************
//								  Sync CPU
// ****************************************************************************

void HWSyncImplementation(LONG32 iCount) {
}

// ****************************************************************************
//					Get the keys pressed for a particular row
// ****************************************************************************

int HWGetKeyboardRow(int row) {
	int word = 0;
	int p = 0;
	while (keys[row][p] != 0) {
		if (GFXIsKeyPressed(keys[row][p])) word |= (1 << p);
		p++;
	}
	return word;
}

// ****************************************************************************
//							Set a display pixel
// ****************************************************************************

void HWWritePixel(WORD16 x,WORD16 y,BYTE8 colour) {
	//printf("[%d %d] <- %d\n",x,y,colour);
}

// ****************************************************************************
//						Get System time in 1/100s
// ****************************************************************************

WORD16 HWGetSystemClock(void) {
	//return (GFXTimer() / 10) & 0xFFFF;
	return CPUGetEmulatedTimer();
}

// ****************************************************************************
//						 Control audio channel
// ****************************************************************************

void HWWriteAudio(BYTE8 channel,WORD16 freq) {
	int aFreq = (freq == 0) ? 0 : AUDIOCLOCK / freq;
	//printf("Write %d to channel %d = %dHz\n",freq,channel,aFreq);
	GFXSetFrequency(aFreq,channel);
}
