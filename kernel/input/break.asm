; *****************************************************************************
; *****************************************************************************
;
;		Name:		break.asm
;		Purpose:	Check for Break
;		Created:	12th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				Check break ; return R0 != 0 if break happens
;
; *****************************************************************************

.OSXCheckBreak
		;
		;		This is a fast hard-coded test for control-space
		;		
		mov 	r0,#$20 					; check control pressed ($10 column 5)
		stm 	r0,#keyboardPort
		ldm 	r0,#keyboardPort
		and 	r0,#$10
		sknz 	r0
		ret
		mov 	r0,#$08 					; check Z pressed ($01 column 3)
		stm 	r0,#keyboardPort
		ldm 	r0,#keyboardPort
		and 	r0,#$01
		ret
