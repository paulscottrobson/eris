; *****************************************************************************
; *****************************************************************************
;
;		Name:		data.asm
;		Purpose:	Data Allocation
;		Created:	8th March 2020
;		Reviewed: 	20th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;						Pad out the kernel image to full size
;
; *****************************************************************************

		org 	kernelEnd-1
		word 	0

		org 	ramStart

; *****************************************************************************
;
;							This data is erased to $0000
;
; *****************************************************************************

.initialisedStart

; *****************************************************************************
;
;				System Variables (order must be maintained)
;					 (should be viewed as read only)
;
; *****************************************************************************

.systemVariables

.lowmemory 									; lowest memory address [sysvar(0)]
		fill 	1

.highmemory									; first memory address after the end of [sysvar(1)]
		fill 	1							; RAM (e.g. if RAM is $4000-$BFFF,$C000)

.textMemory 								; address of 53x30 character text buffer [sysvar(2)]
		fill 	1

.spriteImageMemory 							; available sprite image memory [sysvar(3)]
		fill 	1

.spriteImageCount  							; sprite image maximum number [sysvar(4)]
		fill 	1

.xTextExtent								; screen width, characters [sysvar(5)]
		fill 	1

.yTextExtent 								; screen height, characters [sysvar(6)]
		fill 	1

.defaultFont 								; standard 5 x 7 font [sysvar(7)]
		fill 	1

.xTextPos 									; x text position [sysvar(8)]
		fill 	1
.yTextPos									; y text position [sysvar(9)]
		fill 	1

.xGraphic 									; x graphic cursor position. [sysvar(10)]
		fill 	1
.yGraphic 									; y graphic cursor position. [sysvar(11)]
		fill 	1

.fgrColour 									; foreground colour [sysvar(12)]
		fill 	1		
.bgrColour 									; background colour [sysvar(13)]
		fill 	1		

.spriteAddress 								; sprite data location [sysvar(14)]
		fill 	1

.spriteCount 								; sprite count [sysvar(15)]
		fill 	1		

.soundQueueBase 							; sound queue memory [sysvar(16)]
		fill 	1
		
; *****************************************************************************
;				(these can be accessed by assembler and so on)
; *****************************************************************************

.colourMask 								; colour mask for background
		fill 	1		
.spriteMask									; colour mask for sprites
		fill	1
.spriteRotate 								; value to rotate to convert a colour to a sprite colour
		fill 	1
.activePlane 								; where graphics ops are targeted, 0 bgr, 1 sprite
		fill 	1
				
.currentKey									; character code of current key, 0 if none pressed
		fill 	1 							

.currentRowStatus 							; status of each row of the keyboard for scanning. 						
		fill 	6 							; row in order of documentation e.g. column $01 first.

.keyRepeatTime 								; timer when the key repeats.
		fill 	1

.functionKeyQueue 	 						; queue for function key expansion, 0 = not happening
		fill 	1
.functionKeyByte 							; indicates low byte (0) high byte (1)
		fill 	1		

.functionKeyDefinitions 					; 6 definitions, stored as pairs terminated by zero
		fill 	6 * functionKeySize 		; *without* a leading size.

.nextManagerEvent 							; next system manager event 	
		fill 	1
		
.initialisedEnd		
;
;		This data is not initialised.
;
.randomSeed  								; random seed.
		fill 	1		

.convBuffer 								; buffer for string conversion. Up to 17 characters
		fill 	maxIStrSize					; (a sign and 16 digits)

.blitterTemp 								; work word for blitter
		fill 	1

.spritesEnabled 							; non-zero if sprites are enabled.
		fill 	1

.spriteSelect								; address of currently selected sprite
		fill 	1

.freeMemory		
