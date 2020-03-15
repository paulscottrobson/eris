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
#include <ctype.h>

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


// ****************************************************************************
//						Handle File I/O operation
// ****************************************************************************

WORD16 HWFileOperation(WORD16 R0,WORD16 R1,WORD16 R2,WORD16 R3) {
	char fileName[32];
	WORD16 r = 0;
	//printf("Operation %d %d %d %d\n",R0,R1,R2,R3);
	if (R0 != 0 && R0 != 4) {
		fileName[0] = 0;
		for (int i = 0;i < CPUReadMemory(R1);i++) {
			int d = CPUReadMemory(R1+1+i/2);
			fileName[i] = tolower((i & 1) ? (d >> 8) : (d & 0xFF));
			fileName[i+1] = '\0';
		}
		//printf("\tFilename [%s]\n",fileName);
	}
	if (R0 == 1 || R0 == 2) {
		r = HWLoadFile(fileName,(R0 == 1) ? 0 : R2);
	}
	if (R0 == 4) {
		HWLoadDirectory(R1);
	}
	return r;
}

#if defined(WINDOWS) || defined(LINUX)
#include "hardware_emu.cpp"
#endif

#ifdef ESP32
#include "hardware_esp.cpp"
#endif
