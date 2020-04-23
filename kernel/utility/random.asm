; *****************************************************************************
; *****************************************************************************
;
;		Name:		random.asm
;		Purpose:	Simple 16 bit PRNG.
;		Created:	8th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				16 bit LFSR / timer random number generator.
;
; *****************************************************************************

.OSXRandom16
		push 	r1
		ldm 	r0,#randomSeed 					; get random seed
		ror 	r0,#1							; bit 0 now in bit 15
		skp 	r0  							; if it was set xor with $3400
		xor 	r0,#$3400 						; which is like xoring the original with $B400
		stm 	r0,#randomSeed
		ldm 	r1,#hwTimer 					; xor it with the timer
		xor 	r0,r1,#0
		pop 	r1
		ret

; *****************************************************************************
;
;								Set the random seed
;
; *****************************************************************************

.OSXRandomSeed
		stm 	r0,#randomSeed
		ret
