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
#include <string.h>

static BYTE8 keyboardLatch = 0xFF;
static WORD16 rowValues[6];

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
	for (int i = 0;i < 6;i++) {
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
	for (int i = 0;i < 6;i++) {
		if (keyboardLatch & (1 << i)) r |= rowValues[i];
	}
	return r;
}

// ****************************************************************************
//						Handle File I/O operation
// ****************************************************************************

WORD16 HWFileOperation(WORD16 R0,WORD16 R1,WORD16 R2,WORD16 R3) {
	char fileName[128];
	WORD16 r = 0;
	WORD16 temp;
	//printf("Operation %d %d %d %d\n",R0,R1,R2,R3);
	if (R0 != 0 && R0 != 4) {
		fileName[0] = 0;
		int length = CPUReadMemory(R1);
		if (length > sizeof(fileName)-1) return 1;
		for (int i = 0;i < length;i++) {
			int d = CPUReadMemory(R1+1+i/2);
			fileName[i] = (i & 1) ? (d >> 8) : (d & 0xFF);
			if (R0 != 8) fileName[i] = tolower(fileName[i]);
			fileName[i+1] = '\0';
		}
		//printf("\tFilename [%s]\n",fileName);
	}
	switch(R0) {
		case 1:
			r = HWLoadFile(fileName,0);
			break;
		case 2:
			r = HWLoadFile(fileName,R2);
			break;
		case 3:
			r = HWSaveFile(fileName,R2,R3);
			break;
		case 4:
			HWLoadDirectory(R1);
			break;
		case 5:
			r = HWFileInformation(fileName,&temp,&temp) ? 0 : 1;
			break;
		case 6:
			HWFileInformation(fileName,&r,&temp);
			break;
		case 7:
			HWFileInformation(fileName,&temp,&r);
			break;
		case 8:
			HWDownloadFile(fileName);
	}
	return r;
}

// ****************************************************************************
//
//							File Download handler
//
// ****************************************************************************

WORD16 HWDownloadFile(char *download) {
	char *file,*ssid,*password,url[256],target[64];
	strcpy(url,download);
	ssid = strchr(url,';');
	if (ssid == NULL) return 1;
	*ssid++ = '\0';
	password = strchr(ssid,';');
	if (password == NULL) return 1;
	*password++ = '\0';
	file = strrchr(url,'/');
	strcpy(target,(file == NULL) ? url : file+1);
	printf("%s %s %s %s\n",url,ssid,password,target);
	for (int i = 0;i < strlen(target);i++) target[i] = tolower(target[i]);
	return HWDownloadHandler(url,target,ssid,password);
}

#if defined(WINDOWS) || defined(LINUX)
#include "hardware_emu.cpp"
#endif

#ifdef ESP32
#include "hardware_esp.cpp"
#endif

	