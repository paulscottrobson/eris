// ****************************************************************************
// ****************************************************************************
//
//		Name:		espaudio.cpp
//		Purpose:	Sound Hardware Interface
//		Created:	27th April 2020
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************
// ****************************************************************************

#include "espinclude.h"

static SoundGenerator soundGen;
static SquareWaveformGenerator square1,square2;
static NoiseWaveformGenerator noise1;

// ****************************************************************************
//
//						Initialise sound hardware
//
// ****************************************************************************

void ESP32SoundInitialise(void) {
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

