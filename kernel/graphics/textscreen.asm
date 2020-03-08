; *****************************************************************************
; *****************************************************************************
;
;		Name:		textscreen.asm
;		Purpose:	Text Screen character
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		Write character R0 (bits 0-7 only) for control characters see 
;		documentation
;
; *****************************************************************************

.OSXPrintCharacter
		push 	r0,r1,r2,r3,r4,link
		;
		and 	r0,#$FF 						; mask out bits 0-7

		pop 	r0,r1,r2,r3,r4,link 			; and exit.
		ret
