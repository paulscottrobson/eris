; *****************************************************************************
; *****************************************************************************
;
;		Name:		constants.asm
;		Purpose:	Kernel Constants
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************
;
;		Useable memory starts here
;
ramStart = $4000 
;
;		Kernel ends here and Language/Application ROM starts
;
kernelEnd = $1000
;
;		Display size in pixels
;
PixelWidth = 320
PixelHeight = 240
;
;		Text display size
;
CharWidth = 40
CharHeight = 30
;
blitterBase = $FF20
blitterStatus = blitterBase
blitterX  = blitterBase
blitterY  = blitterBase+1
blitterData = blitterBase+2
blitterCMask = blitterBase+3
blitterCmd = blitterBase+4
;
;		Palette update
;
paletteRegister = $FF10
;
;		Keyboard port
;
keyboardPort = $FF00
;
;		100Hz timer port
;
hwTimer = $FF30
;
;		Sound channels
;
audioClock = 5000000
sndNoise = $FF40
sndTone1 = $FF41
sndTone2 = $FF42
;
;		Keyboard delay and repeat time in 1/100s
;
repeatDelay = 80
repeatSpeed = 10									
;
;		Editor tab stop, must be power of 2.
;
tabStop = 4
;
;		Buffer size required for a string to contain a converted integer
;
maxIStrSize = 10
;
;		Colour schemes for listing
;
theme_line = 2 			; green lines
theme_keyword = 6 		; cyan keywords
theme_ident = 3 		; yellow identifiers
theme_const = 1 		; red integers
theme_string = 5 		; magenta strings
theme_punc = 2			; green punctuation