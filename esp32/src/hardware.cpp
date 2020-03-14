// ****************************************************************************
// ****************************************************************************
//
//		Name:		hardware.cpp
//		Purpose:	Hardware Emulation (Common)
//		Created:	8th March 2020
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************
// ****************************************************************************

#include "sys_processor.h"
#include "hardware.h"
#include "gfxkeys.h"
#include <stdio.h>

static BYTE8 keyboardLatch = 0xFF;
static WORD16 rowValues[5];

// ****************************************************************************
//							  Reset Hardware
// ****************************************************************************

void HWReset(void) {
	BlitterInitialise();
}

// ****************************************************************************
//								  Sync CPU
// ****************************************************************************

void HWSync(LONG32 iCount) {
	HWSyncImplementation(iCount);						
	for (int i = 0;i < 5;i++) {
		rowValues[i] = HWGetKeyboardRow(i);
	}	
}

// ****************************************************************************
//					Write to the keyboard latch on port 0
// ****************************************************************************

void HWWriteKeyboardLatch(BYTE8 latch) {
	keyboardLatch = latch;
}

// ****************************************************************************
//					 Read keyboard columns set by latch
// ****************************************************************************

WORD16 HWReadKeyboardColumns(void) {
	WORD16 r = 0;
	for (int i = 0;i < 5;i++) {
		if (keyboardLatch & (1 << i)) r |= rowValues[i];
	}
	return r;
}

#if defined(WINDOWS) || defined(LINUX)
#include "hardware_emu.cpp"
#endif

#ifdef ESP32
#include "hardware_esp.cpp"
#endif
