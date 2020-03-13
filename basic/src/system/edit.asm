; *****************************************************************************
; *****************************************************************************
;
;		Name:		edit.asm
;		Purpose:	Edit Program
;		Created:	13th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		 Edit program. R0 points to the token buffer, R1 has the length.
;
; *****************************************************************************

.EditProgram
		dec 	r1 						; one fewer character, as we're converting to a code line
		inc 	r0 						; the offset goes here, the first token becomes the number
		stm 	r1,r0,#0
		ldm 	r1,r0,#1 				; clear bit 15
		and 	r1,#$7FFF
		stm 	r1,r0,#1 				
		break
