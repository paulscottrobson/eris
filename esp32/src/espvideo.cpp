// ****************************************************************************
// ****************************************************************************
//
//		Name:		espvideo.cpp
//		Purpose:	Video Routines
//		Created:	27th April 2020
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************
// ****************************************************************************

#include "espinclude.h"

// ****************************************************************************
//
//								Static objects
//
// ****************************************************************************

fabgl::VGAController VGAController;
fabgl::Canvas        Canvas(&VGAController);

static RGB888 pColours[8];
static uint8_t rawPixels[8];

// ****************************************************************************
//
//								Pixel update
//
// ****************************************************************************

void HWWritePixelToScreen(WORD16 x,WORD16 y,BYTE8 colour) {
	if (x >= DWIDTH || y >= DHEIGHT) return;
	//Canvas.setPixel(x,y,pColours[colour & 0x3F]);					// Slow
	//BYTE8 *pLine = DisplayController.getScanline(y);
	//pLine[x^2] = x;
	BYTE8 rp = rawPixels[colour & 7];								// Quicker
	VGAController.setRawPixel(x,y,rp);
}

// ****************************************************************************
//
//						Initialise video subsystem
//
// ****************************************************************************

#define CONVCOL(n) 	(((n) == 0) ? 0 : 255)

void ESP32VideoInitialise(void) {
	#if USE_8_COLORS
	VGAController.begin(VGA_RED, VGA_GREEN, VGA_BLUE, VGA_HSYNC, VGA_VSYNC);
	#elif USE_64_COLORS
	VGAController.begin(VGA_RED1, VGA_RED0, VGA_GREEN1, VGA_GREEN0, VGA_BLUE1, VGA_BLUE0, VGA_HSYNC, VGA_VSYNC);
	#endif

	//
	//		Create 64 colour palette
	//
	VGAController.setResolution(QVGA_320x240_60Hz);
	VGAController.enableBackgroundPrimitiveExecution(false);
	for (int i = 0;i < 8;i++) {
		pColours[i].R = CONVCOL((i & 1));
		pColours[i].G = CONVCOL(((i >> 1) & 1));
		pColours[i].B = CONVCOL(((i >> 2) & 1));

		//BYTE8 r = ((i & 3)) >> 2;
		//BYTE8 g = ((colours[i] >> 4) & 0x0F) >> 2;
		//BYTE8 b = ((colours[i] >> 0) & 0x0F) >> 2;
		rawPixels[i] = VGAController.createRawPixel(RGB222(pColours[i].R>>6,pColours[i].G>>6,pColours[i].B>>6));
	}
}