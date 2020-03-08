// ****************************************************************************
// ****************************************************************************
//
//		Name:		sys_processor.c
//		Purpose:	Processor Emulation.
//		Created:	8th March 2020
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************
// ****************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include "sys_processor.h"
#include "sys_debug_system.h"
#include "hardware.h"

// ****************************************************************************
//							CPU / Memory
// ****************************************************************************

#if defined(WINDOWS) || defined(LINUX)
static WORD16 romMemory[RAM_START] = {
	#include "_kernel.h"
	#include "_basic.h"
};
#else
static const WORD16 romMemory[RAM_START] = {
	#include "_kernel.h"
	#include "_basic.h"
};
#endif

static WORD16 ramMemory[RAM_END-RAM_START];						
static LONG32 cycles;													
static LONG32 iCount;													
static WORD16 instReg;

// ****************************************************************************
//							CPU Registers
// ****************************************************************************

WORD16 R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,temp16;
BYTE8  carryFlag;
LONG32 temp32;

// ****************************************************************************
//					Memory read and write macros.
// ****************************************************************************

#define FETCH() 	fetchRead()

//
//								Fetch read.
//
static inline WORD16 fetchRead(void) {
	if (R15 < RAM_START) return romMemory[R15++];
	if (R15 >= RAM_END) return 0;
	return ramMemory[(R15++)-RAM_START];
}

//
//								Full read including devices
//
static inline WORD16 READ(WORD16 a) {
	if (a < RAM_START) return romMemory[a];
	if (a >= RAM_END) {
		WORD16 d = 0;														// Default includes $FF10 blitter status 
		if (a >= 0xFF00) {
			if (a == 0xFF00) d = HWReadKeyboardColumns();					// $FF00 Keyboard state.
			if (a == 0xFF20) d = HWGetSystemClock();						// $FF20 System clock
		}
		return d;
	}
	return ramMemory[a-RAM_START];
}

//
//										Full write 
//
static inline void WRITE(WORD16 a,WORD16 d) {
	if (a >= RAM_START && a < RAM_END) {
		ramMemory[a-RAM_START] = d;
		return;
	}
	if (a >= 0xFF00) {														// Hardware ?
		switch(a & 0x00F0) {	
			case 0x00:														// $FF0x = KeyLatch
				HWWriteKeyboardLatch(d);
				break;									
			case 0x10:														// $FF1x = Blitter
				BlitterWrite(a & 0x0F,d);
				break;
			case 0x30:														// $FF3x = Audio Hardware
				HWWriteAudio(a & 0x0F,d);
				break;
		}
	}
}

// ****************************************************************************
//					 			CPU Support
// ****************************************************************************

#define CONST() 	(instReg & 0x0F)
#define SKIP(t) 	(skip(t))

static WORD16 inline add16Bit(WORD16 w1,WORD16 w2,BYTE8 carryIn) {
	temp32 = w1 + w2 + carryIn;
	carryFlag = (temp32 & 0x10000) ? 1 : 0;
	return temp32;
}

static WORD16 inline sub16Bit(WORD16 w1,WORD16 w2) {
	return add16Bit(w1,w2 ^ 0xFFFF,1);
}

static WORD16 inline mul16Bit(WORD16 w1,WORD16 w2) {
	return w1 * w2;
}

static WORD16 ror16Bit(WORD16 n,WORD16 count) {
	if (count >= 16) return 0;
	while (count != 0) {
		count--;
		n = (n >> 1) | ((n & 1) << 15);
	}
	return n;
}

static void skip(BYTE8 test) {
	if (test) {
		temp16 = READ(R15);
		R15++;
		if ((temp16 & 0x00F0) == 0x00F0) R15++;
	}
}

// ****************************************************************************
//								Reset the CPU
// ****************************************************************************

#ifdef INCLUDE_DEBUGGING_SUPPORT
static void CPULoadChunk(FILE *f,BYTE8* memory,int count);
#endif

void CPUReset(void) {
	static BYTE8 ramInit = 0;
	if (!ramInit) {																	// First time round
		ramInit = 1;	
		HWReset();																	// Reset Hardware
		R0 = R1 = R2 = R3 = R4 = R5 = R6 = R7 = R8 = R9 = R10 = R11 = R12 = R13 = R14 = 0x1111;
	}
	iCount = cycles = 0;
	carryFlag = 0;
	R15 = 0;
}

// ****************************************************************************
//		Called on exit, does nothing on ESP32 but required for compilation
// ****************************************************************************

#ifdef INCLUDE_DEBUGGING_SUPPORT
#include "gfx.h"
void CPUExit(void) {	
	GFXExit();
}
#else
void CPUExit(void) {}
#endif

// ****************************************************************************
//							Execute a single instruction
// ****************************************************************************

BYTE8 CPUExecuteInstruction(void) {
	instReg = FETCH();																// Fetch opcode.
	switch(instReg >> 4) {															// Execute it.
		#include "_instructions.h"
	}
	cycles++;
	if (cycles < CYCLES_PER_FRAME) return 0;										// Not completed a frame.
	cycles = cycles - CYCLES_PER_FRAME;												// Adjust this frame rate.
	iCount += CYCLES_PER_FRAME;
	HWSync(iCount);																	// Update any hardware
	return FRAME_RATE;																// Return frame rate.
}

// ****************************************************************************
//		 						Read/Write Memory
// ****************************************************************************

WORD16 CPUReadMemory(WORD16 address) {
	return READ(address);
}

void CPUWriteMemory(WORD16 address,WORD16 data) {
	WRITE(address,data);
}

#ifdef INCLUDE_DEBUGGING_SUPPORT

// ****************************************************************************
//		Execute chunk of code, to either of two break points or frame-out, 
//		return non-zero frame rate on frame, breakpoint 0
// ****************************************************************************

BYTE8 CPUExecute(WORD16 breakPoint1,WORD16 breakPoint2) { 
	WORD16 next;
	do {
		BYTE8 r = CPUExecuteInstruction();											// Execute an instruction
		if (r != 0) return r; 														// Frame out.
		next = CPUReadMemory(R15);
	} while (R15 != breakPoint1 && R15 != breakPoint2 && next != 0);				// Stop on breakpoint or $FF break
	return 0; 
}

// ****************************************************************************
//			Return address of breakpoint for step-over, or 0 if N/A
// ****************************************************************************

WORD16 CPUGetStepOverBreakpoint(void) {
	WORD16 cmd = CPUReadMemory(R15);
	if ((cmd & 0xFF00) == 0xAD00) {													// BRL R13,...
		return R15 + (((cmd & 0x00F0) == 0x00F0) ? 2 : 1);							// After call
	}
	return 0;																		// Do a normal single step
}

void CPUEndRun(void) {
	FILE *f = fopen("memory.dump","wb");
	fwrite(ramMemory,1,sizeof(ramMemory),f);
	fclose(f);
}

static void CPULoadChunk(FILE *f,WORD16* memory,int count) {
	while (count != 0 && !feof(f)) {
		WORD16 w = fgetc(f);
		*memory = w + (fgetc(f) << 8);
		count = count--;
		memory++;
	}
}

void CPULoadBinary(char *fileName) {
	FILE *f = fopen(fileName,"rb");
	if (f != NULL) {
		int addr = fgetc(f);
		addr = addr + (fgetc(f) << 8);
		//printf("%x\n",addr);
		if (addr < RAM_START) {
			CPULoadChunk(f,romMemory+addr,sizeof(romMemory));
		} else {
			CPULoadChunk(f,ramMemory+addr-RAM_START,sizeof(ramMemory));
		}
		fclose(f);
		R15 = 0;
	}
}

// ****************************************************************************
//						Retrieve a snapshot of the processor
// ****************************************************************************

static CPUSTATUS st;																	// Status area

CPUSTATUS *CPUGetStatus(void) {
	st.r[0] = R0;st.r[1] = R1;st.r[2] = R2;st.r[3] = R3;
	st.r[4] = R4;st.r[5] = R5;st.r[6] = R6;st.r[7] = R7;
	st.r[8] = R8;st.r[9] = R9;st.r[10]= R10;st.r[11] = R11;
	st.r[12] =R12;st.r[13] =R13;st.r[14]= R14;st.r[15] = R15;
	st.cycles = cycles;
	st.pc = R15;st.carry = carryFlag;
	return &st;
}

#endif