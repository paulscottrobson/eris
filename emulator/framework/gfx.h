// ****************************************************************************
// ****************************************************************************
//
//		Name:		gfx.h
//		Purpose:	Support library for SDL (Header)
//		Created:	1st September 2015
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************
// ****************************************************************************

#ifndef _GFX_H
#define _GFX_H

#include <SDL.h>
#include <SDL_audio.h>
#include "gfxkeys.h"

#define GRID(x,y) 			_GFXX(x),_GFXY(y)
#define GRIDSIZE 			_GFXS()

int _GFXX(int x);
int _GFXY(int y);
int _GFXS(void);

void GFXOpenWindow(const char *title,int width,int height,int colour);
void GFXStart(int autoStart);
void GFXExit(void);
void GFXCloseWindow(void);

void GFXRectangle(SDL_Rect *rc,int colour);
void GFXCharacter(int xc,int yc,int character,int size,int colour,int back);
void GFXString(int xc,int yc,const char *text,int size,int colour,int back);
void GFXNumber(int xc,int yc,int number,int base,int width,int size,int colour,int back);
int  GFXIsKeyPressed(int character);
int  GFXToASCII(int ch,int applyModifiers);
int  GFXTimer(void);
void GFXSetCharacterSize(int xSize,int ySize);
void GFXDefineCharacter(int nChar,int b1,int b2,int b3,int b4,int b5);
void GFXCloseOnDebug(void);

void GFXXRender(SDL_Surface *surface,int autoStart);
void GFXSetFrequency(int freq,int channel);

class Beeper
{
private:
	double noise;
	double freq1,freq2;
    double v1,v2;
    SDL_AudioDeviceID dev;
public:
    Beeper();
    ~Beeper();
    void setup(void);
    void setFrequency(double freq,int channel);
    void generateSamples(Sint16 *stream, int length);
};

#endif
