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

#define DWIDTH 		(192)
#define DHEIGHT 	(144)

#define AUDIOCLOCK 	(5000000L)

#ifdef ESP32
int HWGetScanCode(void);
void HWWriteCharacter(BYTE8 x,BYTE8 y,BYTE8 ch);
void HWWritePixelToScreen(WORD16 x,WORD16 y,BYTE8 colour);
void HWSetAudio(BYTE8 channel,WORD16 freq);
#endif

void BlitterInitialise(void);
void BlitterWrite(BYTE8 port,WORD16 data);
BYTE8 BlitterGetPixel(WORD16 x,WORD16 y);
BYTE8 BlitterGetPixelByte(WORD16 x,WORD16 y);
void BlitterSetPixelByte(WORD16 x,WORD16 y,BYTE8 c);
void BlitterGetStatus(CPUSTATUS *s);

void HWWriteKeyboardLatch(BYTE8 latch);
WORD16 HWReadKeyboardColumns(void);

void HWSyncImplementation(LONG32 iCount);
void HWWriteAudio(BYTE8 channel,WORD16 freq);
void HWReset(void);
void HWSync(LONG32 iCount);
void HWWritePixel(WORD16 x,WORD16 y,BYTE8 colour);
int HWGetKeyboardRow(int row);
WORD16 HWGetSystemClock(void);

#endif
