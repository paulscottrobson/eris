; *****************************************************************************
; *****************************************************************************
;
;		Name:		blitter.asm
;		Purpose:	Blitter Routines
;		Created:	8th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;					Wait for Blitter to become available
;
; *****************************************************************************

.OSXWaitBlitter
		push 	r0 							; save work register
._OSXWBLoop
		ldm 	r0,#blitterStatus 			; wait till bit 15 goes high
		skp 	r0 
		jmp 	#_OSXWBLoop
		pop 	r0 							; restore and exit
		ret
		