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
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>

#include <stdlib.h>
#include "gfx.h"

//
//		Really annoying.
//
#ifdef LINUX
#define MKSTORAGE()	mkdir("storage", S_IRWXU)
#else
#define MKSTORAGE()	mkdir("storage")
#endif

static BYTE8 displayRAM[DWIDTH*DHEIGHT];

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
	{ GFXKEY_F1, GFXKEY_F2, GFXKEY_F3, GFXKEY_F4, GFXKEY_F5, GFXKEY_F6, 0  },
	{ GFXKEY_LEFT,GFXKEY_RIGHT,GFXKEY_UP,GFXKEY_DOWN,GFXKEY_CONTROL,GFXKEY_SHIFT,0  }
};

// ****************************************************************************
//								  Sync CPU
// ****************************************************************************

void HWSyncImplementation(LONG32 iCount) {
	if ((SDL_GetModState() & KMOD_LCTRL) != 0 && 
		 SDL_GetKeyboardState(NULL)[SDL_SCANCODE_ESCAPE] != 0) CPUReset();			/* Ctrl+ESC is Reset */
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
//								Get display Pixel
// ****************************************************************************


BYTE8 HWGetPixel(WORD16 x,WORD16 y) {
	return displayRAM[x+y*DWIDTH];
}



// ****************************************************************************
//							Set a display pixel
// ****************************************************************************

void HWWritePixel(WORD16 x,WORD16 y,BYTE8 colour) {
	displayRAM[x+y*DWIDTH] = colour;
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
	GFXSetFrequency(aFreq,channel);
}

// ****************************************************************************
//							  Check file exists
// ****************************************************************************

WORD16 HWFileInformation(char *fileName,WORD16 *loadAddress,WORD16 *size) {
	char fullName[128];
	if (fileName[0] == 0) return 0;
	MKSTORAGE();
	sprintf(fullName,"%sstorage%c%s",SDL_GetBasePath(),FILESEP,fileName);
	FILE *f = fopen(fullName,"rb");
	if (f != NULL) {
		WORD16 addr = fgetc(f);
		addr += (fgetc(f) << 8);
		*loadAddress = addr;
		fseek(f, 0L, SEEK_END);
		*size = (WORD16)((ftell(f)-2)/2);
		fclose(f);
	}
	return (f != NULL);
}

// ****************************************************************************
//								Load file in
// ****************************************************************************

WORD16 HWLoadFile(char * fileName,WORD16 override) {
	char fullName[128];
	if (fileName[0] == 0) return 1;
	MKSTORAGE();
	sprintf(fullName,"%sstorage%c%s",SDL_GetBasePath(),FILESEP,fileName);
	FILE *f = fopen(fullName,"rb");
	if (f != NULL) {
		WORD16 addr = fgetc(f);
		addr += (fgetc(f) << 8);
		if (override != 0) addr = override;
		while (!feof(f)) {
			WORD16 data = fgetc(f);
			data += (fgetc(f) << 8);
			if (addr < 0xFF00) {
				CPUWriteMemory(addr++,data);
			}
		}
		fclose(f);
	}
	return (f != NULL) ? 0 : 1;
}

// ****************************************************************************
//								Save file out
// ****************************************************************************

WORD16 HWSaveFile(char *fileName,WORD16 start,WORD16 size) {
	char fullName[128];
	MKSTORAGE();
	sprintf(fullName,"%sstorage%c%s",SDL_GetBasePath(),FILESEP,fileName);
	FILE *f = fopen(fullName,"wb");
	if (f != NULL) {
		fputc(start & 0xFF,f);
		fputc(start >> 8,f);
		while (size != 0) {
			size--;
			WORD16 d = CPUReadMemory(start++);
			fputc(d & 0xFF,f);
			fputc(d >> 8,f);
		}
		fclose(f);
	}
	return (f != NULL) ? 0 : 1;
}

// ****************************************************************************
//							  Load Directory In
// ****************************************************************************

void HWLoadDirectory(WORD16 target) {
	int count = 0;
	DIR *dp;
	struct dirent *ep;
	char fullName[128];
	MKSTORAGE();
	sprintf(fullName,"%sstorage",SDL_GetBasePath());
	dp = opendir(fullName);
	if (dp != NULL) {
		while (ep = readdir(dp)) {
			if (ep->d_name[0] != '.') {
				if (count != 0) CPUWriteMemory(target++,32);
				char *p = ep->d_name;
				while (*p != '\0') CPUWriteMemory(target++,*p++);
				count++;
			}
		}
		closedir(dp);
	}
	CPUWriteMemory(target,0);
}

// ****************************************************************************
//								Transmit character
// ****************************************************************************

void HWTransmitCharacter(BYTE8 ch) {
	printf("%c",ch);
}

// ****************************************************************************
//							  Downloader (dummy at present)
// ****************************************************************************

WORD16 HWDownloadHandler(char *url,char *target,char *ssid,char *password) {
	printf("Download %s to %s using %s[%s]\n",url,target,ssid,password);
	return 0;
}
