// ****************************************************************************
// ****************************************************************************
//
//		Name:		main.cpp
//		Purpose:	Main Program (esp version)
//		Created:	8th March 2020
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************
// ****************************************************************************

#include <fabgl.h>
#include <canvas.h>
#include "sys_processor.h"
#include "hardware.h"

#include <Preferences.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <FS.h> 
#include "SPIFFS.h"

#include "character_rom.inc"

#define FORMAT_SPIFFS_IF_FAILED true

// select one color configuration
#define USE_8_COLORS  0
#define USE_64_COLORS 1

// ****************************************************************************
//
//								Static objects
//
// ****************************************************************************

fabgl::VGAController VGAController;
fabgl::Canvas        Canvas(&VGAController);
fabgl::PS2Controller PS2Controller;
fabgl::Keyboard  Keyboard;

SoundGenerator soundGen;
SquareWaveformGenerator square1,square2;
NoiseWaveformGenerator noise1;

static RGB888 pColours[64];
static uint8_t rawPixels[64];
static int fsOpen,size;

// indicate VGA GPIOs to use for selected color configuration
#if USE_8_COLORS
	#define VGA_RED    GPIO_NUM_22
	#define VGA_GREEN  GPIO_NUM_21
	#define VGA_BLUE   GPIO_NUM_19
	#define VGA_HSYNC  GPIO_NUM_18
	#define VGA_VSYNC  GPIO_NUM_5
#elif USE_64_COLORS
	#define VGA_RED1   GPIO_NUM_22
	#define VGA_RED0   GPIO_NUM_21
	#define VGA_GREEN1 GPIO_NUM_19
	#define VGA_GREEN0 GPIO_NUM_18
	#define VGA_BLUE1  GPIO_NUM_5
	#define VGA_BLUE0  GPIO_NUM_4
	#define VGA_HSYNC  GPIO_NUM_23
	#define VGA_VSYNC  GPIO_NUM_15
#endif

#define PS2_PORT0_CLK GPIO_NUM_33
#define PS2_PORT0_DAT GPIO_NUM_32


// ****************************************************************************
//
//					  Character write - debugging
//
// ****************************************************************************

void HWWriteCharacter(BYTE8 x,BYTE8 y,BYTE8 ch) {
	RGB888 rgb,rgbx;rgb.R = rgb.G = 255;rgb.B = 0;
	int patternBase = (ch & 0xFF) * 8;
	x = x * 8;y = y * 8;
	for (int y1 = 0;y1 < 8;y1++) {
		int pattern = character_rom[patternBase+y1];
		for (int x2 = 0;x2 < 8;x2++) {
			HWWritePixelToScreen(x+x2,y+y1,(pattern & 1) ? 3 : 0);
			pattern = pattern >> 1;
		}
	}
}

// ****************************************************************************
//
//							Load file from SPIFFS
//
// ****************************************************************************

WORD16 HWLoadFile(char *fName,WORD16 override) {
	char fullName[64];
	sprintf(fullName,"/%s",fName);
	File file = SPIFFS.open(fullName);
	WORD16 r = (file != 0) ? 0 : 1;
	if (file != 0) {
		size = 0;
		WORD16 loadAddress = file.read();
		loadAddress = loadAddress + file.read()*256;
		if (override != 0) loadAddress = override;
		while (file.available()) {
			WORD16 word = file.read();
			word = word+file.read()*256;
			CPUWriteMemory(loadAddress++,word);
		}
		size = loadAddress;
	}
	return r;
}

// ****************************************************************************
//
//						Directory of SPIFFS root
//
// ****************************************************************************

void HWLoadDirectory(WORD16 target) {
    File root = SPIFFS.open("/");
    int count = 0;
    File file = root.openNextFile();
    while(file){
        if(!file.isDirectory()){
        	if (count != 0) CPUWriteMemory(target++,32);
        	count++;
            const char *p = file.name();
            while (*p != '\0') {	
            	if (*p != '/') CPUWriteMemory(target++,*p);
            	p++;
            }
        }
        file = root.openNextFile();
    }
    CPUWriteMemory(target,0);
}

// ****************************************************************************
//
//								Pixel update
//
// ****************************************************************************

void HWWritePixelToScreen(WORD16 x,WORD16 y,BYTE8 colour) {
	if (x >= DWIDTH || y >= DHEIGHT) return;
	//Canvas.setPixel(x,y,pColours[colour & 0x3F]);
	//BYTE8 *pLine = DisplayController.getScanline(y);
	//pLine[x^2] = x;
	BYTE8 rp = rawPixels[colour & 0x3F];
	VGAController.setRawPixel(x,y,rp);
}

// ****************************************************************************
//		
//							Get keyboard activity
//
// ****************************************************************************

int HWGetScanCode(void) {
	return Keyboard.getNextScancode(0);
}

// ****************************************************************************
//
//							  Set channel pitches
//
// ****************************************************************************

void HWSetAudio(BYTE8 channel,WORD16 freq) {
	if (channel == 0) {
		noise1.enable(freq != 0);
		//if (freq != 0) noise1.setFrequency(AUDIOCLOCK/freq);
	}
	if (channel == 1) {
		square1.enable(freq != 0);
		if (freq != 0) square1.setFrequency(AUDIOCLOCK/freq);
	}
	if (channel == 2) {
		square2.enable(freq != 0);
		if (freq != 0) square2.setFrequency(AUDIOCLOCK/freq);
	}
}

// ****************************************************************************
//
//								Set up code
//
// ****************************************************************************

#define CONVCOL(n) 	((n) == 3) ? 255 : ((n) * 80)

void setup()
{
	#if USE_8_COLORS
	VGAController.begin(VGA_RED, VGA_GREEN, VGA_BLUE, VGA_HSYNC, VGA_VSYNC);
	#elif USE_64_COLORS
	VGAController.begin(VGA_RED1, VGA_RED0, VGA_GREEN1, VGA_GREEN0, VGA_BLUE1, VGA_BLUE0, VGA_HSYNC, VGA_VSYNC);
	#endif

	fsOpen = SPIFFS.begin(FORMAT_SPIFFS_IF_FAILED);

	//HWLoadFile("/basicdemo2");

	VGAController.setResolution(QVGA_320x240_60Hz);
	VGAController.enableBackgroundPrimitiveExecution(false);
	Keyboard.begin(PS2_PORT0_CLK, PS2_PORT0_DAT,false,false);

	for (int i = 0;i < 64;i++) {
		pColours[i].R = CONVCOL((i & 3));
		pColours[i].G = CONVCOL(((i >> 2) & 3));
		pColours[i].B = CONVCOL(((i >> 4) & 3));

		//BYTE8 r = ((i & 3)) >> 2;
		//BYTE8 g = ((colours[i] >> 4) & 0x0F) >> 2;
		//BYTE8 b = ((colours[i] >> 0) & 0x0F) >> 2;
		rawPixels[i] = VGAController.createRawPixel(RGB222(pColours[i].R>>6,pColours[i].G>>6,pColours[i].B>>6));
	}
	CPUReset();

	soundGen.attach(&square1);
	square1.enable(false);
	soundGen.attach(&square2);
	square2.enable(false);
	soundGen.attach(&noise1);
	noise1.enable(false);

	soundGen.play(true);
}

// ****************************************************************************
//
//									Execution
//
// ****************************************************************************

void loop()
{
	while (1) {
		CPUExecuteInstruction();
	}
}
