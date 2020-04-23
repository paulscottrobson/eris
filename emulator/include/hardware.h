// ****************************************************************************
// ****************************************************************************
//
//		Name:		hardware.h
//		Purpose:	Hardware Emulation Header
//		Created:	15th February 2020
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************
// ****************************************************************************

#ifndef _HARDWARE_H
#define _HARDWARE_H

#define DWIDTH 		(320)
#define DHEIGHT 	(240)

#define AUDIOCLOCK 	(5000000L)

#ifdef WINDOWS
#define FILESEP 	'\\'
#else
#define FILESEP 	'/'
#endif

#ifdef ESP32
int HWGetScanCode(void);
void HWWriteCharacter(BYTE8 x,BYTE8 y,BYTE8 ch);
void HWWritePixelToScreen(WORD16 x,WORD16 y,BYTE8 colour);
void HWSetAudio(BYTE8 channel,WORD16 freq);
#endif

void BlitterInitialise(void);
void HWWritePalette(BYTE8 port,WORD16 data);
void BlitterWrite(BYTE8 port,WORD16 data);
void BlitterGetStatus(CPUSTATUS *s);

WORD16 HWFileOperation(WORD16 R0,WORD16 R1,WORD16 R2,WORD16 R3);
void HWWriteKeyboardLatch(BYTE8 latch);
WORD16 HWReadKeyboardColumns(void);

WORD16 HWLoadFile(char * fileName,WORD16 override);
void HWLoadDirectory(WORD16 target);
WORD16 HWSaveFile(char *fileName,WORD16 start,WORD16 size);
WORD16 HWFileExists(char *fileName);
WORD16 HWGetLoadSize(void);

void HWSyncImplementation(LONG32 iCount);
void HWWriteAudio(BYTE8 channel,WORD16 freq);
void HWReset(void);
void HWSync(LONG32 iCount);
BYTE8 HWGetPixel(WORD16 x,WORD16 y);
void HWWritePixel(WORD16 x,WORD16 y,BYTE8 colour);
int HWGetKeyboardRow(int row);
WORD16 HWGetSystemClock(void);

#endif
