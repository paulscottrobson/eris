// ****************************************************************************
// ****************************************************************************
//
//		Name:		espfileio.cpp
//		Purpose:	File I/O Routines
//		Created:	27th April 2020
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************
// ****************************************************************************

#include "espinclude.h"

// ****************************************************************************
//
//							  Check file exists
//
// ****************************************************************************

WORD16 HWFileInformation(char *fileName,WORD16 *pLoadAddress,WORD16 *pSize) {
	char fullName[64];
	sprintf(fullName,"/%s",fileName);								// SPIFFS doesn't do dirs
	fabgl::suspendInterrupts();										// And doesn't like interrupts
	WORD16 exists = SPIFFS.exists(fullName);						// If file exitst
	if (exists != 0) {
		File file = SPIFFS.open(fullName);							// Open it
		WORD16 loadAddress = file.read();							// Read in load address
		loadAddress = loadAddress + file.read()*256;
		*pLoadAddress = loadAddress;
		*pSize = file.size()/2-1;
		file.close();
	}
	fabgl::resumeInterrupts();
	return exists;
}

// ****************************************************************************
//
//							Load file from SPIFFS
//
// ****************************************************************************

WORD16 HWLoadFile(char *fName,WORD16 override) {
	char fullName[64];
	sprintf(fullName,"/%s",fName);									// SPIFFS doesn't do dirs
	fabgl::suspendInterrupts();										// And doesn't like interrupts
	WORD16 exists = SPIFFS.exists(fullName);						// If file exitst
	if (exists != 0) {
		File file = SPIFFS.open(fullName);							// Open it
		WORD16 loadAddress = file.read();							// Read in load address
		loadAddress = loadAddress + file.read()*256;
		if (override != 0) loadAddress = override;					// Override load address
		while (file.available()) {									// Read body in
			WORD16 word = file.read();
			word = word+file.read()*256;
			CPUWriteMemory(loadAddress++,word);
		}
		file.close();
	}
	fabgl::resumeInterrupts();
	return exists == 0;
}

// ****************************************************************************
//
//							Save file to SPIFFS
//
// ****************************************************************************

WORD16 HWSaveFile(char *fName,WORD16 start,WORD16 size) {
	char fullName[64];
	sprintf(fullName,"/%s",fName);									// No directories or interrupts
	fabgl::suspendInterrupts();
	File file = SPIFFS.open(fullName,FILE_WRITE);					// Open to write
	WORD16 r = (file != 0) ? 0 : 1;
	if (file != 0) {
		file.write(start & 0xFF);									// Write reload address
		file.write(start >> 8);
		while (size != 0) {											// Write body
			size--;
			WORD16 d = CPUReadMemory(start++);
			file.write(d & 0xFF);
			file.write(d >> 8);
		}
		file.close();
	}
	fabgl::resumeInterrupts();
	return r;
}

// ****************************************************************************
//								Delete file
// ****************************************************************************

WORD16 HWDeleteFile(char *fileName) {
	char fullName[64];
	sprintf(fullName,"/%s",fileName);								// No directories or interrupts
	fabgl::suspendInterrupts();
	SPIFFS.remove(fullName);
	fabgl::resumeInterrupts();
	return 0;
}

// ****************************************************************************
//
//						Directory of SPIFFS root
//
// ****************************************************************************

void HWLoadDirectory(WORD16 target) {
	fabgl::suspendInterrupts();
  	File root = SPIFFS.open("/");									// Open directory
    int count = 0;
   	File file = root.openNextFile();								// Work throughfiles
   	while(file){
       	if(!file.isDirectory()){									// Write non directories out
       		if (count != 0) CPUWriteMemory(target++,32);			// Space if not first
       		count++;
           	const char *p = file.name();							// Then name
           	while (*p != '\0') {	
           		if (*p != '/') CPUWriteMemory(target++,*p);
           		p++;
           	}
       	}
       	file.close();
       	file = root.openNextFile();
   	}
    CPUWriteMemory(target,0);										// Trailing NULL
    root.close();
	fabgl::resumeInterrupts();
}

