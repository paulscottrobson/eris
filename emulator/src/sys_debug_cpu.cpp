// ****************************************************************************
// ****************************************************************************
//
//		Name:		sys_debug_cpu.c
//		Purpose:	Debugger Code (System Dependent)
//		Created:	8th March 2020
//		Author:		Paul Robson (paul@robsons->org.uk)
//
// ****************************************************************************
// ****************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "gfx.h"
#include "sys_processor.h"
#include "debugger.h"
#include "hardware.h"


#define DBGC_ADDRESS 	(0x0F0)														// Colour scheme.
#define DBGC_DATA 		(0x0FF)														// (Background is in main.c)
#define DBGC_HIGHLIGHT 	(0xFF0)

static int colours[8]; 

static const char *opCodes[16] = { "mov","ldm","stm","add","adc","sub","and","xor",
								   "mult","ror","brl","skeq","skne","skse","sksn","skcm" };

// ****************************************************************************
//							This renders the debug screen
// ****************************************************************************

static const char *labels[] = { "PC","Cry","BXc","BYc","BDa","BMa","BCo","Cyc","Clk","Brk", NULL };

void DBGXRender(int *address,int showDisplay) {

	int n = 0;
	char buffer[32];
	CPUSTATUS *s = CPUGetStatus();
	BlitterGetStatus(s);

	GFXSetCharacterSize(36,24);
	DBGVerticalLabel(24,0,labels,DBGC_ADDRESS,-1);									// Draw the labels for the register
	#define DN(v,w) GFXNumber(GRID(28,n++),v,16,w,GRIDSIZE,DBGC_DATA,-1)			// Helper macro
	DN(s->pc,4);DN(s->carry,1);
	DN(s->blitterX,4);DN(s->blitterY,4);DN(s->blitterData,4);
	DN(s->blitterMask,2);DN(s->blitterColour,2);
	DN(s->cycles,4);
	DN(HWGetSystemClock(),4);
	DN(address[3],4);

	for (int n = 0;n < 16;n++) {
		sprintf(buffer,"R%d",n);
		GFXString(GRID(36,n),buffer,GRIDSIZE,DBGC_ADDRESS,-1);
		GFXNumber(GRID(40,n),s->r[n],16,4,GRIDSIZE,DBGC_DATA,-1);
	}
	int a = address[1];																// Dump Memory.
	for (int row = 17;row < 23;row++) {
		GFXNumber(GRID(0,row),a,16,4,GRIDSIZE,DBGC_ADDRESS,-1);
		for (int col = 0;col < 8;col++) {
			GFXNumber(GRID(5+col*5,row),CPUReadMemory(a),16,4,GRIDSIZE,DBGC_DATA,-1);
			a = (a + 1) & 0xFFFF;
		}		
	}

	int p = address[0];																// Dump program code. 
	int opc;

	for (int row = 0;row < 16;row++) {
		int isPC = (p == ((s->pc) & 0xFFFF));										// Tests.
		int isBrk = (p == address[3]);
		GFXNumber(GRID(0,row),p,16,4,
				  GRIDSIZE,isPC ? DBGC_HIGHLIGHT:DBGC_ADDRESS,	
				  isBrk ? 0xF00 : -1);
		int n = CPUReadMemory(p++);
		sprintf(buffer,"%s r%d,r%d,#%d",opCodes[n >> 12],(n >> 8) & 15,(n >> 4) & 15,n & 15);
		if ((n & 0x00F0) == 0x00F0) {
			sprintf(buffer,"%s r%d,#$%04x",opCodes[n >> 12],(n >> 8) & 15,CPUReadMemory(p++));
		}
		if (n == 0) strcpy(buffer,"break");
		GFXString(GRID(5,row),buffer,
				  GRIDSIZE,isPC ? DBGC_HIGHLIGHT:DBGC_DATA,	
				  isBrk ? 0xF00 : -1);
	}

	#define CMAP(x,s) ((((x) & 1) ? 0xF:0x0) << (s))

	if (showDisplay) {
		for (int i = 0;i < 8;i++) {
			colours[i] = CMAP(i >> 2,0)+CMAP(i >> 1,4)+CMAP(i,8);
		}
		int scale = 3;
		SDL_Rect rc;rc.w = DWIDTH * scale;rc.h = DHEIGHT * scale;
		rc.x = WIN_WIDTH/2-rc.w/2;rc.y = WIN_HEIGHT/2-rc.h/2;
		SDL_Rect rc2;rc2.w = rc.w + 64;rc2.h = rc.h + 64;
		rc2.x = WIN_WIDTH/2-rc2.w/2;rc2.y = WIN_HEIGHT/2-rc2.h/2;
		SDL_Rect rp;rp.w = rp.h = scale;
		GFXRectangle(&rc2,0x000);
		//GFXRectangle(&rc,0x000);
		for (int y = 0;y < DHEIGHT;y++) {
			rp.x = rc.x;rp.y = rc.y + y * scale;
			for (int x = 0;x < DWIDTH;x++) {
				BYTE8 p = BlitterGetPixel(x,y);
				//p = (x >> 4) & 0x0F;
				if (p != 0) {
					GFXRectangle(&rp,colours[p & 0x3F]);
				}
				rp.x += rp.w;
			}
		}
	}
}	
