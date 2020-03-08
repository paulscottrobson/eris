; *****************************************************************************
; *****************************************************************************
;
;		Name:		data.asm
;		Purpose:	Data Allocation
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

		org 	ramStart

;
;		This data is erased to $0000
;
.initialisedStart

.highmemory									; first memory address after the end of 
		fill 	1							; RAM (e.g. if RAM is $4000-$BFFF,$C000)

.textMemory 								; address of 40x30 character text buffer.
		fill 	1

.currentKey									; character code of current key, 0 if none pressed
		fill 	1 							

.currentRowStatus 							; status of each row of the keyboard for scanning. 						
		fill 	5 							; row in order of documentation e.g. column $01 first.

.keyRepeatTime 								; timer when the key repeats.
		fill 	1

.initialisedEnd		
;
;		This data is not initialised.
;
.randomSeed  								; random seed.
		fill 	1		

.convBuffer 								; buffer for string conversion. Up to 17 characters
		fill 	maxIStrSize					; (a sign and 16 digits)

.freeMemory		