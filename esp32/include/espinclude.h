// ****************************************************************************
// ****************************************************************************
//
//		Name:		espinclude.h
//		Purpose:	ESP32 Include file
//		Created:	27th April 2020
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

#define FORMAT_SPIFFS_IF_FAILED true

// ****************************************************************************
//
//								Configuration
//
// ****************************************************************************

#define USE_8_COLORS  0
#define USE_64_COLORS 1

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

void ESP32SoundInitialise(void);
void ESP32VideoInitialise(void);
void ESP32KeyboardInitialise(void);