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

.lowmemory 									; lowest memory address [$SYS+0]
		fill 	1

.highmemory									; first memory address after the end of [$SYS+1]
		fill 	1							; RAM (e.g. if RAM is $4000-$BFFF,$C000)

.textMemory 								; address of 40x30 character text buffer [$SYS+2]
		fill 	1

.spriteMemory 								; available sprite memory [$SYS+3]
		fill 	1

.spriteCount  								; sprite maximum count [$SYS+4]
		fill 	1

.xTextExtent								; screen width, characters [$SYS+5]
		fill 	1

.yTextExtent 								; screen height, characters [$SYS+6]
		fill 	1

; *****************************************************************************
;				(these can be accessed by assembler and so on)
; *****************************************************************************

.xGraphic 									; graphic cursor position.
		fill 	1
.yGraphic 	
		fill 	1

.colourMask 								; colour mask
		fill 	1		
.fgrColour 									; foreground colour
		fill 	1		
.bgrColour 									; background colour
		fill 	1		

.xTextPos 									; text position
		fill 	1
.yTextPos
		fill 	1
				
.currentKey									; character code of current key, 0 if none pressed
		fill 	1 							

.currentRowStatus 							; status of each row of the keyboard for scanning. 						
		fill 	5 							; row in order of documentation e.g. column $01 first.

.keyRepeatTime 								; timer when the key repeats.
		fill 	1

.functionKeyQueue 	 						; queue for function key expansion, 0 = not happening
		fill 	1
.functionKeyByte 							; indicates low byte (0) high byte (1)
		fill 	1		

.functionKeyDefinitions 					; 8 definitions, stored as pairs terminated by zero
		fill 	8 * functionKeySize 		; *without* a leading size.


.initialisedEnd		
;
;		This data is not initialised.
;
.randomSeed  								; random seed.
		fill 	1		

.convBuffer 								; buffer for string conversion. Up to 17 characters
		fill 	maxIStrSize					; (a sign and 16 digits)

.freeMemory		
