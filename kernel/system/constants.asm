; *****************************************************************************
; *****************************************************************************
;
;		Name:		constants.asm
;		Purpose:	Kernel Constants
;		Created:	8th March 2020
;		Reviewed: 	20th March 2020
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
CharWidth = 53
CharHeight = 30
;
;		Char size in Pixels
;
pixelCharWidth = 6
pixelCharHeight = 8
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
sndChannelBase = $FF40
sndNoise = sndChannelBase+0
sndTone1 = sndChannelBase+2
sndTone2 = sndChannelBase+2
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
;		Maximum size in words for each function key (characters is 2 x this)
;
functionKeySize = 12
;
;		Default # of sprite images
;
spriteDefaultImageCount = 32
;
;		Time in centiseconds between monitor events, so for 20 per second
;		this is 100/20 = 5
;
timerRate = 5	
;
;		Sprite constants
;
spriteObjectCount = 32 						; Number of sprites
spriteRecordSize = 6 						; words per sprite.
;
spX = 0 									; current settings
spY = 1
spStatus = 2
spNewX = 3									; New values
spNewY = 4
spNewStatus = 5

spNoChange = $0800 							; value in new values indicating unchanged.
;
;		Sound constants
;
sndChannels = 3 							; # of sound channels
;											; very specific code in sndupdate.asm if you change this
;
sndCompleteTime = 0							; time when current sound/slide event ends
sndPitch = 1 								; current pitch (in div 64 form)
sndSlide = 2 								; sound slide (in div 64, per 20th seconds tick)
sndQueueHead = 3 							; offset to queue head
sndQueueTail = 4							; offset to queue tail
sndQueueStart = 5 							; queue
;
sndQueueSize = 32 							; size of the sound queue per channel (POWER OF 2!)
;
sndRecordSize = sndQueueStart+sndQueueSize 	; size of one record
